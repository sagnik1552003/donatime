# StudyCompute Backend

FastAPI task server for the StudyCompute distributed computing Flutter app.

## Setup

```bash
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Swagger UI at: http://localhost:8000/docs

---

## API Reference

### `POST /tasks/claim`
Claim the next pending task.

**Body:** `{ "device_id": "my-device-123" }`

**Response:**
```json
{
  "id": "uuid",
  "type": "prime_sieve",
  "description": "Find all primes between 3,000,000 and 3,007,400",
  "payload": { "range_start": 3000000, "range_end": 3007400 },
  "status": "claimed"
}
```
Returns `404` if no tasks are pending.

---

### `POST /tasks/{task_id}/submit`
Submit a result for a claimed task.

**Body:**
```json
{
  "device_id": "my-device-123",
  "result": [3000017, 3000041, ...],
  "success": true,
  "duration_ms": 342.5
}
```

For `matrix_multiply`, `result` is a 2D array `[[float]]`.  
For `prime_sieve`, `result` is a list of integers `[int]`.

---

### `GET /stats`
Global server statistics.

```json
{
  "total_generated": 25,
  "total_completed": 18,
  "total_failed": 0,
  "active_devices": 2,
  "task_counts": { "pending": 5, "claimed": 2, "completed": 18, "failed": 0 }
}
```

### `GET /leaderboard`
Top 20 devices by tasks completed.

### `GET /tasks/pending/count`
Quick check: how many tasks are pending.

---

## Task types

| Type | Payload fields | Result |
|---|---|---|
| `prime_sieve` | `range_start`, `range_end` | `List<int>` of primes found |
| `matrix_multiply` | `matrix_a`, `matrix_b`, `n` | `List<List<double>>` result matrix |

---

## Flutter integration

Copy `compute_service.dart` into `lib/services/`.

```dart
final service = ComputeService(
  deviceId: 'device-abc',
  baseUrl: 'http://10.0.2.2:8000', // or your server IP
);

// Claim + run + submit in one go:
final task = await service.claimTask();
if (task != null) {
  final (:result, :durationMs) = await TaskRunner.run(task);
  await service.submitResult(
    taskId: task.id,
    result: result,
    success: true,
    durationMs: durationMs,
  );
}
```

## Notes

- Tasks claimed but not submitted within **60 seconds** are automatically recycled back to pending.
- The server auto-generates new tasks to keep at least 5 pending at all times.
- Run multiple Flutter instances (or use different `device_id` values) to simulate distributed load.
