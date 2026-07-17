# Quickstart: Profile Tab — Guest (v1)

**Feature**: `004-profile-screen` | **Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

How to build, run, and verify the guest Profile experience. **No new dependencies** — the current `pubspec.yaml` is sufficient.

## Prerequisites
- Flutter stable (per `pubspec.yaml`), a device/emulator (Pixel 7 / API 34 reference).
- `flutter pub get` (no new packages).

## Run
```bash
flutter pub get
flutter gen-l10n                  # after adding Profile ARB keys
flutter run                       # launch on device/emulator
# Optional: override placeholder link URLs at runtime
flutter run \
  --dart-define=SUGGEST_FORM_URL=https://forms.gle/your-form \
  --dart-define=WEBSITE_URL=https://halalmap.pl \
  --dart-define=PRIVACY_URL=https://halalmap.pl/privacy \
  --dart-define=TERMS_URL=https://halalmap.pl/terms
```

## Manual verification (happy path)
1. Launch → tap the **Profil** tab (5th). **Screen 1** renders inside the 5-tab shell (no separate dock), blocks fade/scale in (staggered).
2. Confirm the **coming-soon banner**: glowing clock ring, "● Wkrótce" badge (floating), headline "Konta są już *w drodze*" (last word italic + sand), subline, and the "Powiadom mnie, gdy będzie gotowe" button.
3. Confirm groups: **Preferencje** → only a **Language** row (value = current language; **no Dark-mode row**); **Społeczność** → **Zaproponuj miejsce** (external arrow); **Informacje** → **About** (value `v 1.0.0`, chevron) + **Polityka prywatności**. Footer (two lines) at the bottom.
4. Tap **Language** → **Screen 2**: kicker `Ustawienia`, title `Język`, section label, and exactly **three** radios — Polski / English / العربية (Arabic in Amiri). **No** "missing language" helper.
5. Tap **English** → the whole UI switches to English **instantly, no restart**; the radio moves; you **stay** on Screen 2 (now in English). Tap **العربية** → UI flips to **RTL**, Amiri renders. Tap back → Screen 1's Language value reflects the choice.
6. Tap **About** → **Screen 3**: app-mark card (glowing pin, name, version, mission), **Suggest-a-place** CTA card, **Linki** group (Website / Privacy / Terms / Open-source licenses), footer.
7. Tap **Website / Privacy / Terms / Suggest / Notify** → opens the (placeholder) URL externally. Tap **Open-source licenses** → Flutter's native license page opens in-app.
8. Back chevrons pop correctly.

## Reduced motion
- Enable OS "reduce motion" → reopen Profil: no entrance stagger, no glow/float/shimmer, no press-scale; everything renders at final state; language selection still updates the radio.

## Failure path
- With no browser/handler (or a bad URL), tapping an external link shows a brief localized "couldn't open" SnackBar — no crash.

## Tests
```bash
flutter test test/features/profile/                 # widget tests (3 screens × pl/en/ar × motion)
flutter test test/shared/widgets/                    # BackHeader / SettingRow / GroupCard
flutter test test/core/links/                        # ExternalLinkLauncher
flutter test integration_test/profile_flow_test.dart # open → change language → about → link → licenses → back
flutter analyze                                      # must be clean (incl. no dead code from removed settings stub)
dart format .
```

## Definition-of-done checks
- All FR-001…FR-021 and TC-1…TC-21 covered; the orphaned `/profile/settings` route + `SettingsScreen` stub are removed and `flutter analyze` is clean.
- Polish copy verbatim; pl/en/ar + RTL verified; WCAG AA (labels, ≥44 dp, contrast); no analytics/PII.
