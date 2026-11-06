# 🛠️ Tech Stack — Hyperlocal Fashion Marketplace

> [!IMPORTANT]
> This document defines the canonical technology decisions for the entire platform. All contributors must adhere to these choices. Do not introduce alternative databases, auth providers, or state management libraries without updating this document and getting team approval.

---

## 1. Platform Overview

| Layer | Technology | Rationale |
|---|---|---|
| Mobile Apps | Flutter (Dart) | Single codebase for Android & iOS, rich UI, strong performance |
| Backend & Database | Firebase | Realtime capabilities, auth, storage, functions — all integrated |
| Cloud Functions | Firebase Cloud Functions (Node.js 20) | Server-side logic, commission calculations, webhooks |
| Authentication | Firebase Authentication | Multi-provider, role-based claims, secure token handling |
| Database | Cloud Firestore | NoSQL, realtime, scalable, offline-first support |
| File Storage | Firebase Storage | Product images, driver/vendor documents |
| Realtime Updates | Firestore Realtime Listeners + Firebase RTDB (presence) | Order tracking, delivery status, driver availability |
| Notifications | Firebase Cloud Messaging (FCM) | Push notifications across all three apps |
| Analytics | Firebase Analytics | Business KPIs, funnel tracking |
| Crash Reporting | Firebase Crashlytics | Stability monitoring for all three apps |
| Remote Config | Firebase Remote Config | Feature flags, commission rates, campaign toggles |
| Performance | Firebase Performance Monitoring | App startup time, network latency |

---

## 2. Mobile Applications

### 2.1 Flutter Version & Environment

```yaml
Flutter SDK: >=3.22.0
Dart SDK: >=3.4.0
Target Android SDK: 35 (minSdk: 23)
Target iOS: 14.0+
```

### 2.2 Shared Flutter Dependencies

```yaml
# Firebase Core
firebase_core: ^3.x
firebase_auth: ^5.x
cloud_firestore: ^5.x
firebase_storage: ^12.x
firebase_messaging: ^15.x
firebase_analytics: ^11.x
firebase_crashlytics: ^4.x
firebase_remote_config: ^5.x
firebase_performance: ^0.10.x

# State Management
flutter_riverpod: ^2.x          # Chosen for scalability and testability
riverpod_annotation: ^2.x

# Navigation
go_router: ^14.x                # Declarative routing, deep link support

# Networking & Local Storage
dio: ^5.x                       # HTTP client for REST calls to Cloud Functions
hive_flutter: ^1.x              # Local caching, offline cart persistence
shared_preferences: ^2.x        # Simple key-value preferences

# Maps & Location
google_maps_flutter: ^2.x
geolocator: ^13.x
geocoding: ^3.x

# UI & Design
flutter_svg: ^2.x
cached_network_image: ^3.x
shimmer: ^3.x                   # Loading skeleton screens
lottie: ^3.x                    # Micro-animations
fl_chart: ^0.x                  # Earnings/analytics charts (vendor & driver)
image_picker: ^1.x              # Product image uploads
permission_handler: ^11.x

# Payments
razorpay_flutter: ^1.x          # Online payments (COD handled internally)

# Utilities
intl: ^0.19.x                   # Formatting, localization
uuid: ^4.x                      # Local UUID generation
equatable: ^2.x                 # Value equality
freezed: ^2.x                   # Immutable data classes
json_annotation: ^4.x
logger: ^2.x
connectivity_plus: ^6.x
url_launcher: ^6.x
```

### 2.3 Three Independent Flutter Apps

| App | Package Name | Firebase App Alias |
|---|---|---|
| Customer App | `com.yourcompany.hyperlocal.customer` | `hyperlocal-customer` |
| Vendor App | `com.yourcompany.hyperlocal.vendor` | `hyperlocal-vendor` |
| Driver App | `com.yourcompany.hyperlocal.driver` | `hyperlocal-driver` |

> [!NOTE]
> All three apps connect to the **same Firebase project**. Firebase custom claims on `idToken` differentiate roles: `customer`, `vendor`, `driver`, `admin`.

---

## 3. Firebase Backend

### 3.1 Firebase Services Used

| Service | Purpose |
|---|---|
| **Firestore** | Primary database — users, stores, products, orders, deliveries |
| **Firebase Auth** | Authentication for all four user roles |
| **Cloud Functions** | Commission calculation, payment webhooks, referral rewards, settlements |
| **Firebase Storage** | Product images, store banners, driver/vendor KYC documents |
| **Firebase RTDB** | Driver live location (high-frequency writes — optimized for RTDB) |
| **FCM** | Push notifications for order updates, delivery status |
| **Remote Config** | Commission rate (%), referral reward values, feature flags |
| **Firebase Extensions** | Stripe/Razorpay payment extension (if available) |

### 3.2 Cloud Functions Runtime

```
Runtime: Node.js 20
Region: asia-south1 (Mumbai — closest to Gujarat)
Memory: 256MB default, 512MB for payment/settlement functions
Timeout: 60s default, 540s for batch settlement jobs
```

### 3.3 Firestore Security Rules Strategy

- All collections are **deny-all by default**
- Access granted only through explicit rules per collection
- Role enforcement via Firebase Auth custom claims
- Sensitive writes (commission, settlements, coin redemptions) are **Cloud Function-only** — Firestore rules block direct client writes to those collections
- Financial audit collections are **append-only** from clients

---

## 4. Payment Integration

| Provider | Use Case |
|---|---|
| **Razorpay** | Primary online payment gateway |
| **COD** | Cash on delivery — order marked as `payment_pending` until delivery confirmation |
| **Store Coins** | Internal credit system — managed via Cloud Functions, not a payment gateway |

> [!CAUTION]
> Payment order creation and verification **must** happen in Cloud Functions. Never trust client-side payment confirmation. Always verify Razorpay signature server-side before marking an order as paid.

---

## 5. Maps & Location

| Capability | Solution |
|---|---|
| Store discovery radius | Firestore GeoPoint + geohash queries |
| Driver live tracking | Firebase RTDB (`/driver_locations/{driverId}`) |
| Customer address | Google Maps Places API + Geocoding API |
| Driver navigation | In-app Google Maps / deep-link to Google Maps / Ola Maps |

---

## 6. State Management Pattern

```
Riverpod 2.x (Code Generation)
├── Providers scoped per feature module
├── AsyncNotifier for async state (orders, products)
├── StateNotifier for local UI state (cart, filters)
└── StreamProvider for Firestore realtime listeners
```

---

## 7. Environment Configuration

```
Environments: development | staging | production
Config via: Firebase Remote Config + .env (non-secret) + dart-define
Secrets: Never hardcoded. Use Firebase Functions config or Secret Manager.
```

---

## 8. Code Quality & Tooling

| Tool | Purpose |
|---|---|
| `flutter_lints` + custom `analysis_options.yaml` | Static analysis |
| `very_good_analysis` | Stricter lint rules |
| `freezed` + `json_serializable` | Code generation for models |
| `build_runner` | Runs code generation |
| `flutter_test` + `mockito` | Unit and widget tests |
| `integration_test` | End-to-end tests |
| GitHub Actions | CI/CD — lint, test, build |
| Firebase App Distribution | Internal testing builds |

---

## 9. Hosting & Admin Dashboard

> [!NOTE]
> The Admin Dashboard is a **Flutter Web** app connected to the same Firebase project. It runs in a restricted environment accessible only to admin-role users.

| Component | Technology |
|---|---|
| Admin Dashboard | Flutter Web |
| Hosting | Firebase Hosting |
| Access Control | Firebase Auth (admin custom claim) |

---

## 10. Version Control & Project Structure

```
Monorepo (recommended):
hyperlocal/
├── apps/
│   ├── customer_app/      # Flutter app
│   ├── vendor_app/        # Flutter app
│   ├── driver_app/        # Flutter app
│   └── admin_web/         # Flutter Web app
├── packages/
│   ├── core/              # Shared models, Firebase wrappers, utilities
│   ├── ui_kit/            # Shared design system, components, theme
│   └── domain/            # Shared business logic, repository interfaces
├── functions/             # Firebase Cloud Functions (Node.js)
├── firestore.rules        # Firestore security rules
├── storage.rules          # Storage security rules
├── firestore.indexes.json # Composite indexes
└── firebase.json
```
