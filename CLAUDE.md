# BringIt Store App — AI Engineering Instructions

Read the root `CLAUDE.md` first. This file adds store app-specific directives.

---

## ROLE

You are a senior Flutter engineer on the BringIt store app. This app is used by restaurant/store owners to manage orders, menu items, products, and view analytics. You do not mark a task done without running the app on a simulator and validating the feature.

---

## MANDATORY: TEST EVERY CHANGE

After every code change:
1. Run `flutter run` on iOS or Android simulator
2. Navigate to the affected screen — verify it renders correctly
3. Test the full user flow for the feature (not just opening the screen)
4. Test error state (kill the server, trigger a 4xx) — UI must handle it gracefully
5. Test empty state — what does the screen show with no data?

---

## ARCHITECTURE

```
lib/
├── core/
│   ├── constants/      # API base URL, app-wide constants
│   ├── network/        # Dio client setup (interceptors, auth headers)
│   ├── services/       # Firebase storage, push notifications
│   ├── storage/        # GetStorage wrapper
│   └── theme/          # Colors, text styles, app theme
├── data/
│   ├── models/         # Data classes with fromJson/toJson
│   └── repositories/   # API calls via Dio — return typed models
├── modules/
│   └── <feature>/
│       ├── bindings/   # GetX dependency injection
│       ├── controllers/ # Business logic, state, API calls
│       └── views/      # Widgets only — no logic here
└── routes/             # GetX route definitions
```

**Layer rules:**
- Views are dumb — they observe controller state and call controller methods only
- Controllers hold all state and call repositories
- Repositories make all HTTP calls — controllers never use Dio directly

---

## STORE APP USER FLOWS

The store owner uses this app to:
1. **Auth** — OTP login, store setup (name, type, location, banner, ID card)
2. **Dashboard** — overview of today's orders, revenue, status
3. **Orders** — incoming orders (accept/reject), in-progress, completed history
4. **Menu** — categories and menu items management
5. **Products** — individual product CRUD with images
6. **Riders** — view assigned riders for active orders
7. **Analytics** — revenue charts, order counts, top products
8. **Notifications** — order alerts, system messages
9. **Settings** — store profile, availability toggle, operating hours

Every feature must be complete end-to-end. A store owner must be able to use the app without needing anything outside it.

---

## ORDER MANAGEMENT (CRITICAL)

Order state machine:
```
PENDING → ACCEPTED → PREPARING → READY → ASSIGNED → PICKED_UP → DELIVERED
                  ↘ REJECTED
```
- Store can: accept, reject, mark as preparing, mark as ready
- Status updates must emit Socket.IO events — the user app is listening
- Real-time incoming orders must appear without a manual refresh (Socket.IO)

---

## UI STANDARDS

- Show `CircularProgressIndicator` or shimmer during loading
- Show an informative empty state widget when lists are empty
- Show `SnackBar` (GetX `Get.snackbar`) for success and error feedback
- Never leave a screen in a broken state silently — always show the error

---

## RUNNING

```bash
flutter pub get
flutter run
flutter run --release   # for performance testing
```

Notify when done: `tput bel`
