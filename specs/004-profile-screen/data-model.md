# Phase 1 Data Model: Profile Tab — Guest (v1)

**Feature**: `004-profile-screen` | **Date**: 2026-05-31 | **Spec**: [spec.md](./spec.md)

This feature is **presentational**. It introduces **no new persisted domain entities** — the only persisted state is the app locale, already owned by `localeNotifierProvider` (001). The "entities" below are a reused enum, a small view model, and a configuration object.

---

## Reused — `AppLocale` (enum) + `localeNotifierProvider`

- **Source**: `lib/features/auth/domain/onboarding_state.dart` / `.../state/locale_notifier.dart` (001).
- **Values (MVP, unchanged)**: `pl`, `en`, `ar`. Adding TR/UK is out of scope (spec FC-4).
- **Read**: Screen 1 (Language row value), Screen 2 (selected radio). **Write**: Screen 2 only, via `setLocale(...)` (FR-010).
- **Persistence**: secure storage key `selected_locale` (existing) — written async on change; visible change is synchronous/reactive (no restart, R2).
- **Helpers needed (new, pure)**: `AppLocale.nativeName` (`Polski` / `English` / `العربية`) and `AppLocale.englishName` (`Polish` / `English` / `Arabic`) for the picker rows. Arabic native name renders in the Amiri font (`HmpFonts.arabic`).

## View model — `LanguageOption` (transient, Screen 2)

One per selectable language; built from `AppLocale` + the active locale. Not persisted.

| Field | Meaning |
|---|---|
| `locale` | the `AppLocale` this row selects |
| `nativeName` | localized native name (Arabic uses Amiri) |
| `englishName` | trailing-value English name |
| `isSelected` | `locale == active locale` (drives the radio) |

**Invariant (tested)**: the option list is exactly `[pl, en, ar]` in that order — no TR/UK (FR-009, FC-4). Exactly one `isSelected` at a time (FR-010).

## Configuration — `ExternalDestinations` (build-time, via `Env`)

The outbound targets. **Placeholder values for v1**, overridable by `--dart-define` (R5, FR-016). Not user data, not secrets.

| Key (Env) | Used by | v1 placeholder |
|---|---|---|
| `SUGGEST_FORM_URL` | "Notify me" button (S1), "Suggest a place" row (S1) + card (S3) | `https://forms.gle/REPLACE-suggest-place` |
| `WEBSITE_URL` | Website row (S3 LINKS) | `https://example.pl` |
| `PRIVACY_URL` | Privacy policy row (S1 INFO + S3 LINKS) | `https://example.pl/privacy` |
| `TERMS_URL` | Terms of use row (S3 LINKS) | `https://example.pl/terms` |
| `appVersion` (const) | version line (banner footer, About card, footers) | `1.0.0` |

- **Note**: "Open-source licenses" has **no URL** — it triggers `showLicensePage` (R4).
- **Relationships**: consumed by the `ExternalLinkLauncher` (see contracts). The same `SUGGEST_FORM_URL` backs both the notify button and the suggest rows (one form).

## Runtime UI state (no provider beyond locale)

The Profile screens are **stateless w.r.t. app data** — they fetch nothing on load (no network call until a user taps an external link). Local widget state only:
- entrance `AnimationController` (one per screen, via `EntranceController`);
- ambient loop controllers (glow / badge-float / shimmer) — local to their widgets;
- press state (inside `PressableScale`).

No `AsyncValue`, no loading/empty/error data states (nothing to load). The only failure surface is a one-shot SnackBar when an external launch fails (FR-014).

---

## Entity relationship summary

```
AppLocale (reused, persisted) ──read──▶ Screen 1 Language-row value
        ▲                      ──read──▶ Screen 2 LanguageOption.isSelected
        └──write (setLocale)────────────  Screen 2 radio tap  (FR-010, app-wide, no restart)

Env.ExternalDestinations (build-time) ──▶ ExternalLinkLauncher.open(uri)  (FR-014/016)
showLicensePage (Flutter)            ──▶ Open-source licenses row          (FR-015)
```

No migrations. No backend. No new persisted keys (locale key already exists).
