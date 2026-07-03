from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Any
import uuid
import time
import random
import math

app = FastAPI(title="StudyCompute Task Server", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Task store ──────────────────────────────────────────────────────────────
# status: "pending" | "claimed" | "completed" | "failed"

tasks: dict[str, dict] = {}
stats: dict[str, Any] = {
    "total_generated": 0,
    "total_completed": 0,
    "total_failed": 0,
    "devices": {},          # device_id -> { tasks_done, last_seen }
}

CLAIM_TIMEOUT_SECS = 60    # unclaimed after this long → back to pending


# ── Task generators ──────────────────────────────────────────────────────────

def _make_prime_task() -> dict:
    """Check primes in a random range of ~5 000 numbers."""
    start = random.randint(1_000_000, 50_000_000)
    end = start + random.randint(3_000, 8_000)
    return {
        "type": "prime_sieve",
        "payload": {"range_start": start, "range_end": end},
        "description": f"Find all primes between {start:,} and {end:,}",
    }


def _make_matrix_task() -> dict:
    """Multiply two random NxN matrices (N = 8–16)."""
    n = random.choice([8, 10, 12, 16])
    a = [[round(random.uniform(-5, 5), 2) for _ in range(n)] for _ in range(n)]
    b = [[round(random.uniform(-5, 5), 2) for _ in range(n)] for _ in range(n)]
    return {
        "type": "matrix_multiply",
        "payload": {"matrix_a": a, "matrix_b": b, "n": n},
        "description": f"Multiply two {n}×{n} matrices",
    }


def _generate_task() -> dict:
    kind = random.choice(["prime_sieve", "matrix_multiply"])
    base = _make_prime_task() if kind == "prime_sieve" else _make_matrix_task()
    task_id = str(uuid.uuid4())
    now = time.time()
    return {
        "id": task_id,
        "status": "pending",
        "created_at": now,
        "claimed_at": None,
        "completed_at": None,
        "claimed_by": None,
        "result_summary": None,
        **base,
    }


def _seed_tasks(n: int = 20):
    for _ in range(n):
        t = _generate_task()
        tasks[t["id"]] = t
    stats["total_generated"] += n


_seed_tasks(20)


# ── Helpers ──────────────────────────────────────────────────────────────────

def _reclaim_stale():
    """Return timed-out claimed tasks to pending."""
    now = time.time()
    for t in tasks.values():
        if t["status"] == "claimed" and t["claimed_at"]:
            if now - t["claimed_at"] > CLAIM_TIMEOUT_SECS:
                t["status"] = "pending"
                t["claimed_at"] = None
                t["claimed_by"] = None


def _ensure_pool(min_pending: int = 5):
    """Keep at least `min_pending` tasks available."""
    pending = sum(1 for t in tasks.values() if t["status"] == "pending")
    if pending < min_pending:
        needed = min_pending - pending + random.randint(2, 5)
        for _ in range(needed):
            t = _generate_task()
            tasks[t["id"]] = t
        stats["total_generated"] += needed


# ── Schemas ──────────────────────────────────────────────────────────────────

class ClaimRequest(BaseModel):
    device_id: str

class ResultSubmission(BaseModel):
    device_id: str
    result: Any          # flexible — prime list, matrix, error string, etc.
    success: bool = True
    error: Optional[str] = None
    duration_ms: Optional[float] = None   # how long the device took


# ── Endpoints ────────────────────────────────────────────────────────────────

@app.get("/")
def root():
    return {"status": "ok", "service": "StudyCompute Task Server"}


@app.get("/tasks/pending/count")
def pending_count():
    _reclaim_stale()
    c = sum(1 for t in tasks.values() if t["status"] == "pending")
    return {"pending": c}


@app.post("/tasks/claim")
def claim_task(body: ClaimRequest):
    """Assign the next pending task to a device and return it."""
    _reclaim_stale()
    _ensure_pool()

    pending = [t for t in tasks.values() if t["status"] == "pending"]
    if not pending:
        raise HTTPException(status_code=404, detail="No pending tasks right now")

    task = random.choice(pending)
    now = time.time()
    task["status"] = "claimed"
    task["claimed_at"] = now
    task["claimed_by"] = body.device_id

    # update device stats
    dev = stats["devices"].setdefault(body.device_id, {"tasks_done": 0, "last_seen": now})
    dev["last_seen"] = now

    return task


@app.post("/tasks/{task_id}/submit")
def submit_result(task_id: str, body: ResultSubmission):
    """Accept a completed (or failed) result from a device."""
    task = tasks.get(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    if task["status"] != "claimed":
        raise HTTPException(status_code=409, detail=f"Task is '{task['status']}', not 'claimed'")
    if task["claimed_by"] != body.device_id:
        raise HTTPException(status_code=403, detail="Task claimed by a different device")

    now = time.time()
    if body.success:
        task["status"] = "completed"
        task["result_summary"] = _summarise(task, body.result)
        stats["total_completed"] += 1
        stats["devices"][body.device_id]["tasks_done"] += 1
    else:
        task["status"] = "failed"
        task["result_summary"] = body.error or "unknown error"
        stats["total_failed"] += 1

    task["completed_at"] = now
    task["duration_ms"] = body.duration_ms
    _ensure_pool()

    return {"ok": True, "task_id": task_id, "status": task["status"]}


@app.get("/tasks/{task_id}")
def get_task(task_id: str):
    task = tasks.get(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@app.get("/stats")
def get_stats():
    _reclaim_stale()
    status_counts = {"pending": 0, "claimed": 0, "completed": 0, "failed": 0}
    for t in tasks.values():
        status_counts[t["status"]] = status_counts.get(t["status"], 0) + 1

    return {
        **stats,
        "task_counts": status_counts,
        "active_devices": len([
            d for d in stats["devices"].values()
            if time.time() - d["last_seen"] < 300   # seen in last 5 min
        ]),
    }


@app.get("/leaderboard")
def leaderboard():
    board = [
        {"device_id": did, **info}
        for did, info in stats["devices"].items()
    ]
    board.sort(key=lambda x: x["tasks_done"], reverse=True)
    return board[:20]


# ── Result summariser ────────────────────────────────────────────────────────

def _summarise(task: dict, result: Any) -> str:
    try:
        if task["type"] == "prime_sieve":
            count = len(result) if isinstance(result, list) else "?"
            return f"Found {count} primes"
        elif task["type"] == "matrix_multiply":
            if isinstance(result, list) and result:
                trace = sum(result[i][i] for i in range(min(len(result), len(result[0]))))
                return f"Matrix computed, trace={trace:.4f}"
    except Exception:
        pass
    return "Result received"
