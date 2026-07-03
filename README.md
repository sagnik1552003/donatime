# Donatime

Donatime is a Pomodoro-style focus timer built with Flutter. While you study or work, it optionally donates your device's idle compute cycles to background tasks fetched from a remote server — turning idle screen time into contributed compute time.

## Features

- **Focus timer** — a circular slider-based timer for focus and break sessions, with adjustable duration and session type (`focus` / `break`).
- **Background compute donation** — when enabled, active focus sessions claim small compute tasks (e.g. prime sieving, matrix multiplication) from a backend, run them locally, and submit the results back.
- **Session history** — completed sessions are persisted locally with [Hive](https://pub.dev/packages/hive) and browsable from the Sessions tab.
- **Analytics** — a dedicated screen for reviewing focus session stats over time.
- **Account tab** — space for user/device-level settings.
- **Multi-tab navigation** — bottom navigation with independent tab histories, powered by `go_router`'s `StatefulShellRoute`.

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart SDK `^3.5.0`) |
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Navigation | [go_router](https://pub.dev/packages/go_router) (`StatefulShellRoute.indexedStack`) |
| Local storage | [hive](https://pub.dev/packages/hive) / [hive_flutter](https://pub.dev/packages/hive_flutter) |
| Networking | [dio](https://pub.dev/packages/dio) |
| Other | `percent_indicator`, `path_provider`, `uuid` |

## Project Structure

```
lib/
├── main.dart                     # App entrypoint, Hive init, theming
├── navigation/
│   ├── app_router.dart           # go_router route/shell configuration
│   └── main_scaffold.dart        # Bottom nav scaffold
├── theme/
│   └── forest_theme.dart         # App theme definition
├── features/
│   ├── timer/
│   │   ├── timer_screen.dart
│   │   ├── active_timer_screen.dart
│   │   └── state/
│   │       ├── timer_state.dart      # TimerState model (progress, session type, compute flags)
│   │       └── timer_notifier.dart   # Timer countdown + compute loop orchestration
│   ├── sessions/
│   │   ├── sessions_screen.dart
│   │   └── models/
│   │       └── session_model.dart    # Hive-persisted session record
│   ├── analytics/
│   │   └── analytics_screen.dart
│   └── account/
│       └── account_screen.dart
├── services/
│   └── compute/
│       ├── compute_service.dart      # HTTP client: claim/submit tasks, fetch stats
│       ├── compute_manager.dart      # Poll-claim-run-submit loop
│       ├── task_runner.dart          # Executes compute task payloads
│       └── models/
│           └── task.dart             # ComputeTask model
└── widgets/
    └── circular_time_slider.dart     # Custom circular timer control
```

## How Compute Donation Works

1. When a focus session starts with `computeEnabled` set, `TimerNotifier` spins up a `ComputeManager`.
2. `ComputeManager` polls the backend via `ComputeService.claimTask()`, which `POST`s to `/tasks/claim`.
3. If a task is available, `TaskRunner` executes it locally (currently supports `prime_sieve` and `matrix_multiply` task types).
4. The result and timing are reported back via `ComputeService.submitResult()` (`POST /tasks/:id/submit`).
5. If no task is available, the manager backs off for 10 seconds before polling again; errors trigger a 5 second retry delay.

This requires a compute backend exposing `/tasks/claim`, `/tasks/:id/submit`, and `/stats` endpoints (not included in this repo).

## Backend
 
Donatime pairs with a lightweight **FastAPI** task server (`StudyCompute Task Server`) that generates, distributes, and tracks compute tasks in memory.
 
### Stack
 
- [FastAPI](https://fastapi.tiangolo.com/) `>=0.111.0`
- [Uvicorn](https://www.uvicorn.org/) `>=0.29.0` (ASGI server)
### Run it
 
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```
 
Interactive API docs: `http://localhost:8000/docs`
 
### API
 
| Endpoint | Method | Description |
|---|---|---|
| `/tasks/claim` | `POST` | Claims the next pending task for a `device_id`. Returns `404` if none are pending. |
| `/tasks/{task_id}/submit` | `POST` | Submits a result (`result`, `success`, `duration_ms`) for a claimed task. |
| `/tasks/{task_id}` | `GET` | Fetch a single task by id. |
| `/tasks/pending/count` | `GET` | Count of currently pending tasks. |
| `/stats` | `GET` | Global stats: totals generated/completed/failed, active devices, per-status counts. |
| `/leaderboard` | `GET` | Top 20 devices ranked by tasks completed. |
 
### Task lifecycle & pool management
 
- The server seeds **20 tasks** on startup and keeps a rolling pool of **at least 5 pending tasks**, auto-generating more as they're claimed (`_ensure_pool`).
- Tasks move through `pending → claimed → completed/failed`.
- A task **claimed but not submitted within 60 seconds** is automatically reclaimed back to `pending` (`_reclaim_stale`), so a dropped connection doesn't strand a task.
- Device activity is tracked in-memory per `device_id` (`tasks_done`, `last_seen`); a device counts as "active" in `/stats` if seen in the last 5 minutes.
- Two task types are generated at random:
  - **`prime_sieve`** — find all primes in a random range of ~3,000–8,000 numbers between 1M and 50M.
  - **`matrix_multiply`** — multiply two random N×N matrices (N ∈ {8, 10, 12, 16}).
- On submission, the server stores a short human-readable `result_summary` (e.g. prime count, or matrix trace) rather than the full payload.
> **Note:** State is in-memory only — restarting the server clears all tasks and stats. There's no persistence layer or auth; it's designed for local development and small-scale testing rather than production deployment as-is.
 
### Client integration
 
The backend repo ships its own copy of `compute_service.dart`, meant to be dropped into `lib/services/` of a Flutter client:
 
```dart
final service = ComputeService(
  deviceId: 'device-abc',
  baseUrl: 'http://10.0.2.2:8000', // Android emulator loopback, or your server IP
);
 
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
 
You can run multiple Flutter app instances (or vary `device_id`) against one backend to simulate distributed load across devices.
## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.5.0`)
- A configured platform toolchain for whichever target you build (Android Studio / Xcode / etc.)

### Setup

```bash
git clone <this-repo-url>
cd donatime
flutter pub get
```

### Run

```bash
flutter run
```

## Configuration

`ComputeService` expects a `baseUrl` and `deviceId` at construction time — point this at your own compute backend to enable task donation. Without a reachable backend, focus/break timing still works normally; only the compute donation loop will fail silently and back off.

## Status

This is an actively developed side project. Current focus areas include Dockerizing/deploying the companion backend and expanding the compute task catalog.
