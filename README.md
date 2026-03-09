# Field Service Tracker

A production-structured Flutter mobile application for field agents to log, view, and manage service tasks. Built as an enterprise take-home assignment showcasing clean architecture, BLoC state management, API integration, and CI awareness.

---

## Screenshots

| Task List | Task Detail | Add Task |
|-----------|-------------|----------|
| Filter bar · task cards · FAB | Full details · status action | Form validation · priority picker |

---

## Setup & Run

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter | `>=3.22.0` (stable channel) |
| Dart | `>=3.0.0` |
| Android SDK | API 21+ |

Check your setup:
```bash
flutter doctor
```

### Clone & Run

```bash
git clone https://github.com/YOUR_USERNAME/field_service_tracker.git
cd field_service_tracker

flutter pub get
flutter run
```

To run on a specific device:
```bash
flutter devices                   # list connected devices
flutter run -d <device-id>
```

### Run Tests

```bash
flutter test                      # all tests
flutter test --coverage           # with lcov coverage report
flutter analyze                   # static analysis
```

### Build APK (debug)

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart    # API URLs, string constants
│   │   └── app_theme.dart        # Centralised Material theme
│   ├── di/
│   │   └── service_locator.dart  # GetIt DI wiring
│   ├── errors/
│   │   ├── exceptions.dart       # Data-layer exceptions
│   │   └── failures.dart         # Domain-layer failures + Either<L,R>
│   ├── network/
│   │   └── dio_client.dart       # Dio instance + logging/error interceptors
│   └── utils/
│       └── date_utils.dart       # Date formatting helpers
│
├── data/
│   ├── datasources/
│   │   └── task_remote_datasource.dart   # Raw HTTP calls (Dio)
│   ├── models/
│   │   └── task_model.dart               # JSON ↔ DTO mapping
│   └── repositories/
│       └── task_repository_impl.dart     # Repo impl; exception → failure mapping
│
├── domain/
│   ├── entities/
│   │   └── task_entity.dart      # Pure domain objects (no Flutter, no JSON)
│   ├── repositories/
│   │   └── task_repository.dart  # Abstract interface + Either<L,R>
│   └── usecases/
│       └── task_usecases.dart    # GetTasks, UpdateTaskStatus, CreateTask
│
└── presentation/
    ├── blocs/
    │   ├── task_list/            # TaskListBloc (event/state/bloc)
    │   ├── task_detail/          # TaskDetailBloc
    │   └── add_task/             # AddTaskBloc
    ├── screens/
    │   ├── task_list_screen.dart
    │   ├── task_detail_screen.dart
    │   └── add_task_screen.dart
    └── widgets/
        ├── task_card.dart        # Reusable task list item
        ├── status_badge.dart     # Status + priority badge widgets
        └── error_view.dart       # Error, loading, empty, banner widgets

test/
├── domain/entities/task_entity_test.dart
└── presentation/blocs/
    ├── task_list_bloc_test.dart
    └── task_detail_bloc_test.dart

.github/workflows/ci.yml          # GitHub Actions: analyze + test
```

---

## State Management: Why BLoC?

**Short answer:** BLoC gives you testable, predictable, and auditable state transitions — exactly what enterprise field tooling needs.

### Rationale

| Concern | BLoC approach |
|---------|--------------|
| **Testability** | `bloc_test` lets you assert `[loading, success]` sequences in isolation, without a UI. |
| **Explicit state transitions** | Every state change is triggered by a typed Event and produces a new immutable State — no `setState` scattered across the tree. |
| **Error visibility** | Failures are first-class values (`TaskListStatus.failure` carries a message). Nothing is swallowed silently. |
| **Separation of concerns** | BLoC knows nothing about widgets. Widgets know nothing about use cases. |
| **Team scalability** | In a multi-developer team, BLoC's strict boundaries make code review straightforward. |

### Why not Riverpod?

Riverpod is excellent and would be a valid choice. BLoC was selected here because:
- The event-sourced model makes audit logging trivial (events are logged by the interceptor).
- `bloc_test` has a lower mocking overhead than Riverpod's provider overrides for this pattern.
- Enterprise code review teams tend to find explicit event enums easier to trace than provider notifiers.

---

## Architecture: Clean Architecture (3-layer)

```
Presentation (Screens + BLoCs)
        │  uses
        ▼
Domain (Entities + Use Cases + Repository interface)
        │  implemented by
        ▼
Data (Models + Remote Data Source + Repository impl)
```

The dependency rule is strictly observed: inner layers never import outer ones. The `Either<Failure, T>` type (a minimal home-grown implementation to avoid the `dartz` dependency) is the boundary contract between data and domain.

---

## API Integration

**Mock API:** [JSONPlaceholder](https://jsonplaceholder.typicode.com) — `GET /todos?_limit=20`, `PATCH /todos/:id`, `POST /todos`.

### How it works

1. `GET /todos` fetches 20 todos on app launch.
2. JSONPlaceholder `completed: bool` is mapped to `TaskStatus.completed / pending`. In-session status overrides (`inProgress`) are tracked in a `Map<String, TaskStatus>` on the repository — JSONPlaceholder has no concept of "in progress".
3. `PATCH /todos/:id` is called on every status update. The response is acknowledged but since JSONPlaceholder always returns the same shape, the override map drives the UI.
4. `POST /todos` simulates task creation. The returned id (always `201` from JSONPlaceholder) is discarded in favour of a UUID so locally-created tasks have unique, collision-safe IDs.

### Error handling

| Layer | Mechanism |
|-------|-----------|
| Network | Dio interceptor converts `DioException` → typed `AppException` subtypes |
| Repository | `try/catch` maps every `AppException` subtype to a `Failure` subclass — no raw exceptions reach the BLoC |
| BLoC | `result.fold(onFailure, onSuccess)` — explicitly handles both branches |
| UI | `TaskListStatus.failure`, `SnackBar` on update failures — no silent states |

---

## CI/CD

`.github/workflows/ci.yml` runs on every push/PR to `main` or `develop`:

1. `flutter pub get` — install dependencies
2. `flutter analyze --no-fatal-infos` — static analysis
3. `flutter test --coverage` — all unit + BLoC tests

A debug APK build step is included but commented out — it requires a signing key that shouldn't live in a public CI file.

---

## Assumptions & Trade-offs

| Decision | Reason |
|----------|--------|
| **JSONPlaceholder** for mock API | Free, no auth, well-known — avoids MockAPI setup friction. |
| **Minimal `Either<L,R>`** instead of `dartz`/`fpdart` | Keeps dependencies lean; the 20-line implementation covers every use case here. |
| **Session-scoped in-memory cache** | Persisting tasks across cold starts would require `shared_preferences` or a local DB — out of scope for a 24-hour window. |
| **No dark mode** | Theme is single-mode; dark mode is a `ThemeData` swap, trivially addable. |
| **Portrait lock** | Standard for enterprise field apps; landscape adds complexity without field-use value. |
| **20-task limit** | JSONPlaceholder returns 200 items; 20 is more realistic for a task list UX. |

---

## What I'd Improve With More Time

1. **Offline-first with Drift (SQLite)** — cache tasks locally, sync on reconnect with a `SyncBloc`.
2. **Push notifications** — FCM integration so agents get notified of new task assignments.
3. **Authentication layer** — JWT-based login screen with a `AuthBloc` and route guards.
4. **Integration tests** — `flutter_test` widget tests + patrol or integration_test for full-flow E2E.
5. **Release build pipeline** — GitHub Actions step to build a signed APK and upload to Firebase App Distribution.
6. **Pagination** — `ScrollController`-triggered `TaskListFetchedNextPage` event for large task sets.
7. **Real error logging** — Replace `print` in the Dio interceptor with `firebase_crashlytics` or `sentry_flutter`.
8. **Internationalisation** — `flutter_localizations` + ARB files for multi-language field teams.

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | BLoC state management |
| `bloc` | Core BLoC library |
| `equatable` | Value equality for states/events/entities |
| `dio` | HTTP client with interceptor support |
| `get_it` | Service locator / DI container |
| `intl` | Date formatting |
| `uuid` | Collision-safe IDs for locally-created tasks |
| `bloc_test` | BLoC unit testing DSL |
| `mocktail` | Null-safe mocking |
