# 📋 Development Rules — Hyperlocal Fashion Marketplace

> [!IMPORTANT]
> These rules are **non-negotiable**. Every developer and AI agent working on this project must follow them without exception. Violations risk security breaches, data inconsistency, or financial errors.

---

## 1. Security Rules

### 1.1 Firebase Keys & Secrets
- ❌ **NEVER** hardcode Firebase service account keys, API keys, or secrets in Flutter code or committed files
- ❌ **NEVER** use the Firebase Admin SDK in client-side Flutter code
- ✅ Use `google-services.json` / `GoogleService-Info.plist` only (these contain public config, not service-role keys)
- ✅ All privileged operations (commission calculation, settlements, refunds) **must** run inside Cloud Functions using the Admin SDK
- ✅ Store sensitive config in Firebase Secret Manager, not in environment files committed to git

### 1.2 Authentication & Authorization
- All Firestore and Storage access **must** go through Firebase Auth
- Role enforcement uses **Firebase Auth custom claims** (`role: customer | vendor | driver | admin`)
- Custom claims are set **only** by Cloud Functions — never by client code
- Always verify token claims server-side in Cloud Functions before executing privileged logic
- Session tokens are short-lived; refresh token handling must be graceful (silent refresh)

### 1.3 Firestore Security Rules
- **Default deny**: every collection starts with `allow read, write: if false`
- Rules are written per-collection with minimum necessary permissions
- Never use `allow read, write: if request.auth != null` as a blanket rule
- Financial collections (`commission_records`, `settlements`, `coin_transactions`) are **write-protected** from clients — Cloud Functions only
- Audit collections are **append-only** — no updates or deletes allowed from any client

### 1.4 Payment Security
- Razorpay order creation happens **only** in Cloud Functions
- Payment signature verification happens **only** in Cloud Functions
- Client sends `razorpay_payment_id`, `razorpay_order_id`, `razorpay_signature` to a Cloud Function for verification
- Order status transitions to `paid` only after server-side signature verification passes
- COD orders are confirmed only after the driver marks delivery complete

---

## 2. Database Rules

### 2.1 Data Integrity
- Every Firestore document must have `createdAt` and `updatedAt` timestamp fields
- Use `FieldValue.serverTimestamp()` — never client-side `DateTime.now()` for financial records
- All financial amounts are stored in **paise (smallest currency unit)** as integers — never floats
- Order total = `productValue + deliveryCharge - discount - coinRedemption`; always recalculate server-side
- Commission = configurable rate from Remote Config, never hardcoded

### 2.2 Data Relationships
- Maintain referential integrity manually (Firestore is NoSQL — enforce via Cloud Functions)
- Order documents embed a snapshot of product price at order time (price can change later)
- Never delete — use soft deletes (`isDeleted: true`, `deletedAt: timestamp`) for all business entities
- Vendor/Driver profiles are never permanently deleted; they are deactivated

### 2.3 Indexing
- All query fields must have corresponding Firestore indexes defined in `firestore.indexes.json`
- Composite indexes required for: store discovery by location+category, orders by vendor+status+date, deliveries by driver+status
- Never perform unbounded queries on large collections without pagination

### 2.4 Driver Live Location
- Driver live location goes to **Firebase RTDB** (`/driver_locations/{driverId}`), not Firestore
- Location updates occur at max 5-second intervals while driver is online
- Location data is NOT stored permanently — it is overwritten on each update
- Historical route data is not stored in Phase 1

---

## 3. Code Architecture Rules

### 3.1 Folder Structure (per Flutter app)
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   └── utils/
├── data/
│   ├── datasources/      # Firebase/API calls
│   ├── models/           # Firestore DTOs (json_serializable)
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Pure business objects (freezed)
│   ├── repositories/     # Abstract repository interfaces
│   └── usecases/         # Single-responsibility business operations
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/        # Riverpod providers
└── main.dart
```

### 3.2 Layer Separation
- **Presentation** layer knows nothing about Firebase or Firestore directly
- **Data** layer handles all Firebase SDK calls and maps to domain entities
- **Domain** layer contains pure Dart — no Flutter, no Firebase imports
- Use repository pattern — all data access goes through repository interfaces
- Use cases are single-responsibility: one use case = one business action

### 3.3 State Management
- Use **Riverpod 2.x** with code generation (`@riverpod` annotation)
- Never use `setState` for anything beyond isolated, local widget animation state
- Providers are defined at feature level, not globally dumped in one file
- Use `AsyncNotifierProvider` for async data; `StreamProvider` for Firestore real-time streams
- Always handle loading, error, and data states in UI

### 3.4 Shared Code
- Business logic shared across apps lives in the `packages/domain/` package
- UI components shared across apps live in `packages/ui_kit/`
- Firebase wrappers shared across apps live in `packages/core/`
- **Never** copy-paste business logic between apps — extract to shared package

---

## 4. API & Cloud Functions Rules

### 4.1 Cloud Function Design
- Each function has a **single responsibility**
- Functions are organized by domain: `orders/`, `payments/`, `referrals/`, `settlements/`
- All functions validate input before processing
- All functions return structured responses: `{ success: boolean, data?: any, error?: string }`
- Use Firebase callable functions for client-triggered operations
- Use Firestore triggers for event-driven operations (order placed → commission calculated)

### 4.2 Error Handling
- Cloud Functions throw `HttpsError` with appropriate codes (`unauthenticated`, `permission-denied`, `invalid-argument`)
- Flutter app handles all `FirebaseFunctionsException` gracefully — never crash on function error
- Never expose internal error details to clients — log internally, return generic messages externally
- All Cloud Function errors are logged to Firebase Crashlytics (server-side logging)

### 4.3 Idempotency
- Payment and commission functions must be **idempotent** — safe to retry without double-charging
- Use idempotency keys (Razorpay order ID or a UUID generated pre-call) to prevent duplicate processing
- Order status transitions are **one-way** (state machine) — validate before transitioning

---

## 5. UI/UX Rules

### 5.1 Design Consistency
- All apps use the shared `ui_kit` package for typography, colors, spacing, and component library
- Color tokens are defined once — never use raw hex codes in widget files
- Use `Theme.of(context)` for all styling — no hardcoded colors in widget trees
- Typography scale: Display / Headline / Title / Body / Label — use the defined scale

### 5.2 Loading & Error States
- Every async operation shows a skeleton loader (Shimmer) — never a blank white screen
- Every error state shows a user-friendly message with a retry option
- Network errors must be caught and displayed gracefully
- Offline state must be detected and communicated to the user

### 5.3 Performance
- Product images must be loaded via `CachedNetworkImage` with appropriate cache duration
- Firestore queries must be paginated (use `startAfterDocument` for pagination)
- Never fetch entire collections — always filter and paginate
- Avoid rebuilding large widget subtrees — scope Riverpod providers correctly

### 5.4 Navigation
- Use `GoRouter` for all navigation — no direct `Navigator.push` in feature code
- Deep links must be handled for order status updates and referral links
- Each app's route structure is defined in a single router file

---

## 6. Financial Logic Rules

### 6.1 Commission
- Commission rate is fetched from **Firebase Remote Config** at app startup
- Recalculated on the server (Cloud Function) at order completion — never trusted from client
- Commission record is created as a separate Firestore document linked to the order
- Formula: `commission = orderProductTotal * commissionRate`

### 6.2 Settlements
- Vendor settlements are batched (daily/weekly — configurable via Remote Config)
- Settlement = sum of `retailerEarnings` from completed orders in period - any applicable deductions
- Each settlement creates an immutable `settlement` document and updates vendor balance
- Settlement disputes are handled via support tickets, not direct document edits

### 6.3 Store Coins (Referral Rewards)
- Coin issuance triggered by Cloud Function on qualifying purchase event
- 1 Store Coin = ₹1 (configurable via Remote Config)
- Redemption capped per order (configurable)
- All coin transactions logged in `coin_transactions` collection (append-only)
- Fraud prevention: referral attribution locked at first qualifying order — no retroactive re-attribution

---

## 7. Version Control Rules

- Main branch: `main` (production-ready only)
- Development branch: `develop`
- Feature branches: `feature/<ticket-id>-short-description`
- Hotfix branches: `hotfix/<description>`
- Never commit directly to `main`
- Pull requests require at least one review before merge
- Commit messages follow Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- `google-services.json`, `GoogleService-Info.plist`, and `.env` files are in `.gitignore`

---

## 8. Testing Rules

- All Cloud Functions must have unit tests before deployment
- All repository classes must have unit tests with mocked Firebase
- Payment and commission calculation logic must have 100% unit test coverage
- Use `fake_cloud_firestore` for Firestore unit tests in Flutter
- Integration tests cover critical user flows: registration → browse → cart → checkout → order tracking

---

## 9. Naming Conventions

| Item | Convention | Example |
|---|---|---|
| Dart files | `snake_case` | `order_repository.dart` |
| Classes | `PascalCase` | `OrderRepository` |
| Variables / functions | `camelCase` | `fetchOrders()` |
| Constants | `SCREAMING_SNAKE` | `MAX_COIN_REDEMPTION` |
| Firestore collections | `camelCase` (plural) | `orders`, `productVariants` |
| Firestore document fields | `camelCase` | `createdAt`, `vendorId` |
| Cloud Function names | `camelCase` | `createOrder`, `verifyPayment` |
| Riverpod providers | `camelCase` + `Provider` suffix | `ordersProvider`, `cartNotifierProvider` |

---

## 10. What You Must Never Do

| ❌ Prohibited | ✅ Correct Alternative |
|---|---|
| Hardcode commission rates | Fetch from Remote Config |
| Write financial totals from client | Calculate in Cloud Functions |
| Use floats for money | Use integers (paise) |
| Delete financial records | Soft delete with status flag |
| Expose service-role keys to Flutter | Use Cloud Functions + Admin SDK |
| Duplicate business logic across apps | Extract to shared `domain` package |
| Use `allow read, write: if true` | Write specific Firestore rules |
| Trust payment status from client | Verify signature in Cloud Functions |
| Store driver location in Firestore | Use Firebase RTDB for location |
| Query Firestore without pagination | Always paginate large result sets |
