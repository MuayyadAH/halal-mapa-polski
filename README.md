# Halal Map Polskie

Modern, community-built halal discovery map for Muslims in Poland. Flutter mobile app (iOS + Android).

No ads, no tracking, no paywalls — analytics is off by default and location is only-while-using at approximate accuracy. See `.ai_project_memory/constitution.md` §1.7 for the privacy commitments and [`.ai_project_memory/`](./.ai_project_memory/) for full project context, architecture, and constitutions.

## What's shipped

The app boots into onboarding, then a 5-tab shell (**Strona / Mapa / Dodaj / Zapisane / Profil**).

| Feature | Spec | Status |
|---|---|---|
| Onboarding & location-permission flow (single CTA — no login/guest split) | `specs/001-onboarding-flow/` | ✅ |
| Home — greeting, search, category chips, prayer pill, mini-map, nearby places | `specs/002-home-screen/` | ✅ |
| Map — MapLibre custom basemap, pins/clusters, filters, list/map toggle, locate-me | `specs/003-map-screen/` | ✅ |
| Profile (guest) — coming-soon banner, Language (pl/en/ar live switch), Qibla, About | `specs/004-profile-screen/` | ✅ |
| Place detail — editorial page with community note, coordinates, Navigate/Save | — | ✅ |
| Saved (Zapisane) — bookmark list, category filter chips, nearest-first | — | ✅ |
| Prayer times — Mawaqit per-mosque times (yearly calendar cached offline), Home next-prayer pill | — | ✅ |
| Qibla compass — live heading via `flutter_compass`, static fallback | — | ✅ |
| Add (Dodaj) | — | placeholder screen |

Place data at launch comes from a published Google Sheet (CSV), loaded by `PlaceRepository` — there is no backend yet (it lives in a separate future repo).

The app is **locked to the light theme** (`app.dart` sets `themeMode: ThemeMode.light`) — the widget layer doesn't branch on brightness yet, so the device's dark-mode setting is intentionally ignored until the full dark-mode pass ships. See `.ai_project_memory/constitution-frontend.md` §2.10 / §6.6.

## Tech stack

Flutter (stable, Dart ≥ 3.5) · Riverpod (`flutter_riverpod`) · `go_router` · `maplibre_gl` (custom warm cocoa/cream style) · `geolocator` + `permission_handler` · `dio` + `csv` (Google-Sheet place source) · `flutter_secure_storage` + `shared_preferences` · `intl` + ARB (pl / en / ar with RTL) · `url_launcher`. See `.ai_project_memory/constitution-frontend.md` §I for the authoritative stack and rationale.

## Getting started

Platform folders (`android/`, `ios/`), launcher icons, splash screens, fonts, and all platform permission config are **already committed** — a normal clone needs only:

```bash
flutter pub get          # resolve dependencies
flutter gen-l10n         # generate lib/l10n/generated/app_localizations.dart from the ARB files
flutter analyze          # must be clean
flutter run              # debug on a connected device / emulator
```

The app runs without a MapTiler key — the map falls back gracefully — but the custom basemap renders fully only when a key is supplied (see below).

> Rebuilding platform folders from scratch is only needed if `android/`/`ios/` are ever deleted. In that case run `flutter create . --project-name halal_map_polskie --org pl.halalmap --platforms=android,ios --no-pub`, then re-apply the permission/app-id/SDK edits (location, camera, photos, notifications; `applicationId pl.kolektywmuzulmanow.halalmapapolski` (the store identity — iOS bundle id is the same value); `minSdk`/`targetSdk` follow Flutter's defaults, but `compileSdk` is pinned to `maxOf(flutter.compileSdkVersion, 37)` — required by `flutter_secure_storage` 11 and `permission_handler` 13; iOS `Info.plist` usage strings + `CFBundleLocalizations` pl/en/ar; `platform :ios, '13.0'`).

## Environment variables (`--dart-define`)

All keys are read in `lib/core/env/env.dart` (plus `lib/core/places/data/places_config.dart`). Defaults make the app runnable with no flags; override per build.

| Key | Purpose | Default |
|---|---|---|
| `MAP_TILES_KEY` | MapTiler tiles key, substituted into the custom style's `{key}` placeholder. **Never committed.** | *(empty — basemap degrades)* |
| `MAP_STYLE_URL_LIGHT` | MapLibre style URL (light) | `asset://assets/map_styles/halalmap-light.json` |
| `MAP_STYLE_URL_DARK` | MapLibre style URL (dark) | `asset://assets/map_styles/halalmap-dark.json` |
| `PLACES_SHEET_ID` | Published Google-Sheet id for the launch place list (not secret) | `1z2UpkDUv7VoDsCbzsBm1fXq7UODZe3iHXj2988G_dms` |
| `API_BASE_URL` | Backend base URL (future) | `http://localhost:8080` |
| `SENTRY_DSN` | Crash reporter (opt-in; empty = disabled) | *(empty)* |
| `SUGGEST_FORM_URL` | Profile "Suggest a place" / notify form | `https://forms.gle/REPLACE-suggest-place` |
| `WEBSITE_URL` | Profile → website link | `https://example.pl` |
| `PRIVACY_URL` | Profile → privacy policy link | `https://example.pl/privacy` |
| `TERMS_URL` | Profile → terms link | `https://example.pl/terms` |

```bash
flutter run \
  --dart-define=MAP_TILES_KEY=your_maptiler_key \
  --dart-define=API_BASE_URL=https://api.halalmap.pl
```

For local development, put your keys in `dart_define.local.json` (gitignored — never commit it) and run:

```bash
flutter run --dart-define-from-file=dart_define.local.json
```

```json
{ "MAP_TILES_KEY": "your_maptiler_key" }
```

## Testing

```bash
flutter test                    # unit + widget (test/)
flutter test integration_test/  # end-to-end flows on a device/emulator
flutter analyze && dart format . # quality gate before commit
```

Integration suites cover the app smoke boot plus the home, map, and profile flows (`integration_test/`).

## CI & iOS builds (`codemagic.yaml`)

Codemagic runs two workflows (setup notes are in the header comment of `codemagic.yaml`):

- **Analyze & Test** — on every PR: `flutter pub get` → `gen-l10n` → `analyze` → `test`.
- **iOS (unsigned, for Sideloadly)** — on pushes to `develop`: builds an **unsigned** `Runner-unsigned.ipa` (no paid Apple Developer account needed). `MAP_TILES_KEY` comes from the Codemagic secret group `halalmap_secrets`. Download the artifact and sideload it onto an iPhone from Windows with [Sideloadly](https://sideloadly.io) using a free Apple ID (7-day validity, re-sideload to refresh; trust the profile under Settings → General → VPN & Device Management on first launch).

Android release builds are local for now: `flutter build apk --release` / `flutter build appbundle --release`.

## Fonts

The four brand families are **bundled and active** (committed under `assets/fonts/`, declared in `pubspec.yaml`): Plus Jakarta Sans (UI/body), Lora (display headings; italic 500 is the brand voice), Amiri (Arabic text only), JetBrains Mono (small chrome labels).

To regenerate launcher icons / splash screens from a new source image, temporarily add `flutter_native_splash` and `flutter_launcher_icons` as dev_dependencies, run their generators, then remove the packages again.

## Project structure

```
lib/
├── main.dart, app.dart          # entry point + root widget / ProviderScope
├── core/                        # cross-cutting: theme, map, location, places,
│                                #   prayer_times, routing, env, links, storage, …
├── features/                    # auth (onboarding), home, map, profile,
│                                #   contribute, saved, places
├── shared/widgets/              # reused widgets (PressableScale, FadeRiseIn, …)
└── l10n/                        # app_pl.arb (source of truth), app_en.arb, app_ar.arb
test/                            # mirrors lib/ — unit + widget tests
integration_test/                # end-to-end flows
```

Feature-first layout with `data/` `domain/` `presentation/` sub-layers per feature when complexity warrants. The authoritative design system, component library, and screen catalogue live in [`.ai_project_memory/constitution-frontend.md`](./.ai_project_memory/constitution-frontend.md).
