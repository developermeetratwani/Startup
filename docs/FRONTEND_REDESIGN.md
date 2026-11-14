# SwiftDrop editorial frontend

The four applications share a warmer ivory canvas, ink surfaces, raspberry accents, locally bundled Plus Jakarta Sans, and consistent navigation, cards, inputs, dialogs, tables and sheets. Merchant panels use lilac highlights; delivery panels use emerald.

## What changed

- Customer: photographic discovery campaign, streamlined location and support header, suggested searches, branded empty bag/search states, product image gallery with swipe and keyboard-accessible image selectors, larger boutique imagery, refreshed sign-in and splash screens.
- Merchant: animated dashboard, responsive metrics, catalog action, revised collection and order states, earnings and store profile panels, five-destination navigation.
- Driver: dashboard, earnings, profile and sign-in panels, responsive metrics, three-destination navigation and an improved offline state. The existing KYC gate is retained.
- Admin: refreshed sidebar and dashboard hierarchy, campaign studio, consistent tables and a status distribution derived from the current order feed.
- Web entry: branded loading state, titles, favicon and manifest identity for all four apps. Mobile apps remain edge-to-edge; desktop web gets a brand panel and correctly sized mobile application viewport.

## Motion and accessibility

Entrances are finite fade/slide transitions. Brand orbit artwork is painted separately from content; offstage tab tickers stop. Reduced-motion preferences disable orbit, reveal, page and image motion. Navigation exposes selected states and badges, and product gallery selectors have labelled focusable buttons. Metrics adapt to narrow viewports and enlarged text.

Existing product data, business operations and backend integrations remain in their original providers and repositories. The new order chart reflects the current feed; pre-existing demo figures elsewhere in the admin overview are not newly connected analytics. The former hardcoded customer home tracking banner was removed; order tracking remains available from My orders.

## Local verification

Use Flutter 3.35 or later (verified with 3.47.9).

```powershell
cd packages/ui_kit
flutter pub get
flutter test
flutter analyze --no-fatal-infos
cd ../../apps/driver_app
flutter test
```

For each of `customer_app`, `vendor_app`, `driver_app`, and `admin_web`:

```powershell
cd apps/customer_app # substitute the desired app
flutter analyze --no-fatal-infos
flutter build web --release
python -m http.server 3100 --bind 127.0.0.1 --directory build/web
```

Use ports 3100, 3101, 3102 and 3103 respectively to preview all apps together. Production hosting is unchanged; use the existing deployment workflow when ready.

The shared tests cover 320/390/768px layouts, 200% text, navigation, reduced motion, controller disposal, hidden-tab tickers and long product galleries. Driver tests use isolated provider overrides and never update live verification or delivery records.

Customer analysis retains existing informational async-context and deprecated radio API lints. Web compilation may report the existing optional Cupertino font warning. Live payments, KYC submissions, settlements, and delivery mutations are not exercised by visual QA.

Asset sources and the font license are in `packages/ui_kit/assets`.

## Android updates

Android builds use Gradle 8.14.7, Android Gradle Plugin 8.11.1 and Kotlin 2.2.20 to meet the installed Flutter 3.47.9 toolchain minimums. Existing application IDs and signing configurations are preserved. Gradle/AGP compatibility references: https://docs.gradle.org/8.14.7/release-notes.html and https://developer.android.com/build/releases/agp-8-11-0-release-notes.

Build a phone update with `flutter build apk --release --target-platform android-arm64`. Install it over the existing app with `adb -s DEVICE install -r --user 0 build/app/outputs/flutter-apk/app-release.apk`; do not uninstall or clear app data.
