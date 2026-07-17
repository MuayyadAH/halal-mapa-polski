# Halal Map Polskie Project Constitution

<!-- Always loaded by this constitution -->
@./general-overview.md
@./architecture.md

**Purpose**: Universal development principles that apply to all developers working on Halal Map Polskie regardless of layer.
**Loaded by**: CLAUDE.md (always active)

**Stack-Specific Rules** (loaded separately per role):
- [Frontend Constitution](./constitution-frontend.md) - Flutter tech stack, commands, patterns

The backend lives in a separate repository (future); rules for it live in that repo's own constitution.

---

## 1. Code Quality Standards

### 1.1 Code Organization
- **Feature-first layout**: Code is organized under `lib/features/<feature>/` with `data/`, `domain/`, and `presentation/` sub-layers per feature. Cross-feature plumbing lives under `lib/core/`.
- **Single Responsibility Principle**: Each widget, service, or function has one clear purpose.
- **DRY**: Extract reusable logic into shared widgets or `lib/core/` modules — but prefer duplication over the wrong abstraction.
- **Root directory discipline**: Project root is reserved for Flutter scaffolding (`pubspec.yaml`, `analysis_options.yaml`, `README.md`, `CLAUDE.md`) plus platform folders (`android/`, `ios/`, `web/` if used). Application code belongs under `lib/`. Tests under `test/` and `integration_test/`.

### 1.2 Code Style
- **Formatter**: `dart format` is the source of truth. Never hand-format around it.
- **Linter**: `flutter analyze` must be clean before commit. Project uses `analysis_options.yaml` extending `flutter_lints` (or stricter — TBD).
- **Naming conventions** (Dart/Flutter standard):
  - **Files**: `snake_case.dart` (e.g., `place_detail_screen.dart`)
  - **Classes, enums, typedefs, extensions**: `PascalCase` (e.g., `PlaceCard`, `VerificationStatus`)
  - **Variables, methods, parameters**: `lowerCamelCase` (e.g., `nearbyPlaces`, `submitReview`)
  - **Constants**: `lowerCamelCase` for `const`/`final`; `SCREAMING_SNAKE_CASE` reserved for environment keys
  - **Localization keys**: `lowerCamelCase` matching the source ARB
  - Descriptive names: avoid abbreviations except widely accepted ones (`id`, `url`, `api`, `ar`/`en`/`pl` locale codes).

### 1.3 Error Handling Philosophy
- **No silent failures**: Network and storage errors surface to the user as actionable messages, never as console-only logs.
- **User-facing messages are localized**: Every visible error string lives in the ARB files (pl / en / ar) — never hard-coded English in widgets.
- **Structured logging**: Use a single logger abstraction (`lib/core/logging/`) so destinations (console, crash reporter, analytics) can be swapped. Log operation, timestamp, and relevant non-PII context.
- **Trust-sensitive failures get extra care**: When a verification claim, moderation action, or report submission fails, the UI must clearly state what happened — trust is the product's core value.

### 1.4 Documentation Philosophy
- **Self-documenting code**: Widget and method names should make comments unnecessary.
- **Comments for "why", not "what"**: Explain non-obvious constraints, RTL edge cases, accessibility decisions, halal/Islamic terminology assumptions.
- **Public APIs documented**: Public methods on shared `core/` modules use `///` DartDoc comments.
- **No personal information**: Never include person names, internal employee identifiers, or private contact info in generated documentation.

### 1.5 Localization & RTL First-Class
- **All user-visible strings live in ARB files** — `lib/l10n/app_pl.arb`, `app_en.arb`, `app_ar.arb`. No string literals in widget trees.
- **RTL must be tested** for every screen. Use `Directionality` and locale-aware widgets; never hard-code `EdgeInsets.only(left: ...)` — use `EdgeInsetsDirectional`.
- **Polish is the primary locale**. Polish copy is the source of truth; English and Arabic translations are derived from it.

### 1.6 Trust & Community UX
- **Verification state is always visible** on any place card or detail view (added-by, verified-by-owner, community-confirmed, reported-pending).
- **Community moderation surfaces transparently** — users should be able to see why content was removed or hidden, with appeal paths.
- **Halal claims are never silently made**: never display "halal" without an underlying verification source.

### 1.7 Privacy Defaults & Data Discipline

Privacy is a constitutional commitment of Halal Map Polskie, not a configurable post-launch toggle. The product's About screen reads "no ads, no tracking, no paywalls — ever." Code and feature design must encode that.

- **Analytics is OFF by default.** No behavioral analytics SDK runs unless the user has explicitly opted in via Settings. The Settings → Privacy → Analytics toggle defaults to *Wyłączone* (Disabled).
- **Location is only-while-using.** Background location is not used for any feature. Settings → Privacy → Location defaults to *Tylko podczas użycia* (Only while using).
- **Location accuracy defaults to approximate.** Settings → Privacy → Accuracy defaults to *Przybliżona* (Approximate). Precise location is requested only when the user explicitly enables it.
- **No third-party trackers.** No Google Analytics, no Facebook Pixel, no marketing tags. Crash reporting (if added) is self-hosted Sentry or equivalent and is opt-in.
- **Anonymous-by-design flows.** The donation flow (post-MVP) does not require an account and is never linked to user identity. Anonymous browsing is fully functional — sign-in is requested only at the point of contribution.
- **PII minimization.** Collect only what the feature needs. Never log PII into application logs. Never display another user's email or phone in UI without their consent.
- **GDPR alignment.** Data export and deletion paths exist for any account-bearing user. Anonymous donations carry no PII to export or delete.

These defaults are non-negotiable for MVP. Any feature that would change them must surface a constitutional amendment in an ADR.

## 2. Security and Compliance

- **NEVER** embed API keys, signing certificates, keystores, or auth tokens in source code or git.
- **NEVER** store auth tokens or PII in `SharedPreferences` — use `flutter_secure_storage`.
- Use build-time configuration (`--dart-define`, flavor configs) for environment-specific values.
- Handle PII and sensitive data with care; EU GDPR applies since users are in Poland.
- Moderation actions, reports, and owner-claim evidence are sensitive — treat them with the same care as auth data.

## 3. Git Workflow Standards

### 3.1 Tracking Requirements
- **Tracking IDs**: Use `HMP-<n>` (Halal Map Polskie) format for issue references in commits and branches once an issue tracker is set up. Until then, commits stand on their own.
- **Git Configuration**: Configure `user.email` and `user.name` per-clone.
- **Work Logging**: Significant decisions go into ADRs under `docs/adr/` (use `.ai/2_templates/adr-template.md`).

### 3.2 Commit Messages
- **Conventional Commits**: `type(scope): description`
  - Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`, `perf`, `build`
  - Example: `feat(map): add masjid filter chip with prayer-time badge`
- **NEVER** use `--no-verify` when committing.

### 3.3 Branch Strategy
- **Feature branches**: `feat/<short-slug>`, `fix/<short-slug>` off `main`.
- **Main branch protection**: Never force-push to `main`. Merge via PR with green CI.

## 4. Testing Requirements

- Tests MUST cover the functionality being implemented.
- **Three test types are mandatory** (per core coding standards):
  - **Unit tests** — `test/` — Dart logic, view models, domain services. `flutter test`.
  - **Widget tests** — `test/` — Widget behavior in isolation with `WidgetTester`. `flutter test`.
  - **Integration tests** — `integration_test/` — End-to-end flows on a real device/emulator. `flutter test integration_test/`. Replaces Playwright-style E2E; Playwright does not apply to Flutter native apps.
- NEVER ignore test output — logs contain critical information.
- **Test output must be pristine to pass** — no skipped tests without explicit authorization, no leaked warnings.

---

**See Also**: general-overview.md and architecture.md (loaded via `@` above)
