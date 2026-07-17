# Plan Confidence Report

**Feature**: Onboarding Flow
**Branch**: `001-onboarding-flow`
**Date**: 2026-05-27
**Overall Confidence**: **96%** → **GO**

## Dimension Scores

| Dimension | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Completeness | 25% | 100 | 25.0 |
| Constitution Alignment | 20% | 100 | 20.0 |
| Technical Decision Quality | 20% | 90 | 18.0 |
| Requirement Clarity | 15% | 100 | 15.0 |
| Task Structure | 5% | **DEFERRED** | — |
| Risk & Blockers | 15% | 90 | 13.5 |
| **Total (renormalized over 95%)** | **100%** | — | **96.3** |

> Task Structure deferred — score renormalized. Run `/ai1st-dev-tasks` to produce `tasks.md` and re-run this skill for a fully-weighted score.

## Findings by Dimension

### Completeness — 100/100

- ✅ Spec is clean — zero `[NEEDS CLARIFICATION]` markers after two specify rounds + one clarify session (`spec.md` Clarifications section)
- ✅ All required artifacts present: `plan.md`, `research.md`, `data-model.md`, `contracts/onboarding_repository.md`, `contracts/locale_service.md`, `quickstart.md`, `checklists/requirements.md`
- ✅ Feature type is UI + persistence — `data-model.md` covers persistence keys; `contracts/` covers internal Dart interfaces (no HTTP contracts needed per FR-018)
- ✅ Deferred decisions explicitly documented (hero illustrations, EN/AR translations, full splash animation refinement, page transition richness) in `spec.md` §5

### Constitution Alignment — 100/100

- ✅ Constitution Check section in `plan.md` has all 22 applicable principles checked `[x]` (universal §1.1/1.2/1.3/1.5/1.6/1.7/2/4 + frontend §I–VI, §IX–XIII)
- ✅ No violations declared, no complexity-tracking entries
- ✅ Stack constitution update correctly identified as unnecessary — no new technologies (`plan.md` "Stack Constitution Update")
- ✅ Privacy defaults (constitution §1.7) traced through FR-018 (no backend), FR-019 (no analytics), FR-013 (no sign-in), `data-model.md` (secure_storage for persistence)
- ✅ Localisation rules (constitution §V) traced through FR-004/5/6/17 + the Polish UI vocabulary table referenced in `plan.md` §4 Compliance Checklist

### Technical Decision Quality — 90/100

- ✅ All 10 research topics in `research.md` have Decision / Rationale / Alternatives / Source headings
- ✅ Dependencies pinned to specific versions in `plan.md` Technical Context: `flutter_riverpod 3.3.1`, `go_router 17.2.3`, `flutter_secure_storage 10.3.1`, `intl 0.20.2`, `permission_handler 12.0.1`
- ✅ Cross-cutting concerns explicitly surfaced (`research.md` §10 cross-cutting) — Arabic font fallback, iOS testing constraint
- ⚠️ **`research.md` §7 (native + in-app splash handoff)** declares "re-add `flutter_native_splash` to dev_dependencies as a runtime helper" — but the runtime `preserve`/`remove` API requires a regular `dependency`, not a dev_dependency. Also conflicts with the user's intentional pubspec trimming in the prior step. Should be revisited: either (a) re-add as a regular dep with explicit user approval, or (b) replace with manual `WidgetsBinding` orchestration. Suggest a `tasks.md` decision step.
- ⚠️ **`research.md` §10 cross-cutting "Arabic + Lora display headings"** identifies an app-wide theme change (`core/theme/theme.dart` per-locale font fallback) that lives outside `lib/features/auth/` — but the plan's project-structure section doesn't list `core/theme/theme.dart` as a "MODIFIED" file. Plan should be updated to include this modification, or the theme change should be promoted to a separate enabler feature.

### Requirement Clarity — 100/100

- ✅ All 20 FRs name a concrete entity, behavior, and scope. Examples:
  - **FR-004** (`spec.md:142`): "language picker (PL / EN / ع) visible on every onboarding screen" — entity (picker), behavior (switch), scope (every onboarding screen) ✅
  - **FR-010** (`spec.md:148`): "display the LocationPermission pre-prompt screen only if location has not been previously decided" — entity (pre-prompt screen), behavior (conditional display), scope (LocationPermission state) ✅
  - **FR-014** (`spec.md:152`): "Map opens to a wide Poland view with the five target cities (Warsaw, Kraków, Wrocław, Gdańsk, Poznań) marked" — entity (Map), behavior (initial viewport), scope (denial path), measurable ✅
- ✅ All 4 NFRs have measurable targets (`spec.md:160-164`): 10s wall clock; 3 locales + RTL; WCAG 2.1 AA; 60 fps on Pixel 7
- ✅ All 13 test cases have concrete Given/When/Then structures
- ✅ Data-model entities trace cleanly: `OnboardingStatus` → FR-002; `AppLocale` → FR-004/5/6; `LocationPermissionStatus` → FR-010/11; persistence keys → FR-012, FR-017
- ✅ Contracts trace to user actions: `OnboardingRepository.markCompleted()` → FR-012; `LocaleNotifier.setLocale()` → FR-004/17
- ✅ Zero vague-requirement heuristic triggers — every "MUST" statement names the system component being changed

### Task Structure — DEFERRED

- `tasks.md` does not yet exist. Score deferred and total renormalized over 95%.
- Run `/ai1st-dev-tasks` to produce the task breakdown. Then re-run `/ai1st-dev-plan-confidence` for a fully-weighted score.

### Risk & Blockers — 90/100

- ✅ Checklist `specs/001-onboarding-flow/checklists/requirements.md` has all 13 items checked
- ✅ All third-party libraries are already in pubspec, resolved, and verified to compile (the scaffold smoke test ran clean before this feature work began)
- ✅ No missing backend endpoints — feature is fully offline (FR-018)
- ✅ Deferred decisions explicitly scoped with rationale and resolution phase (`spec.md` §5)
- ⚠️ **Cross-cutting theme change for Arabic fonts** (`research.md` §10) — needs implementation in `lib/core/theme/theme.dart` to provide Amiri fallback for `displayMedium`/`headlineSmall` when locale is `ar`. This is necessary for FR-006 to work correctly on heading text but lives outside the onboarding feature module. **Recommend**: add to `tasks.md` as an early task (before the Onboard screens) so headings render correctly when developers test the AR path during implementation.
- ⚠️ **`flutter_native_splash` re-add decision** (`research.md` §7) — Cross-references the prior trim. Either re-add as a regular dependency (~50 KB) or replace with manual `WidgetsBinding` orchestration. **Recommend**: add explicit decision task to `tasks.md`. Not a blocker for `/ai1st-dev-implement` start, but should be resolved early to avoid a visible-flash regression on cold launch.
- ✅ iOS testing constraint is documented and accepted (Windows dev machine — `research.md` cross-cutting + `quickstart.md` Known constraints)
- ✅ Hero illustration placeholders + EN/AR translator placeholders documented and acceptable for v1

## Blockers (must resolve before /ai1st-dev-implement)

None of strict-blocking severity. The two yellow items above are non-blocking but warrant early `tasks.md` entries:

1. **Arabic-font theme work in `core/theme/theme.dart`** — affects every heading in the app, not just onboarding. Update the plan's Project Structure to include `lib/core/theme/theme.dart` as MODIFIED, and add this as an early task in `tasks.md`.
2. **`flutter_native_splash` runtime usage decision** — clarify in `research.md` §7 and add a decision task in `tasks.md`.

## Recommended Actions

- [ ] Update `plan.md` Project Structure to mark `lib/core/theme/theme.dart` as MODIFIED (for the Arabic-font fallback work)
- [ ] Update `research.md` §7 to reflect that `flutter_native_splash` runtime API requires regular `dependency` (not dev_dependency); state the manual `WidgetsBinding` alternative explicitly
- [ ] Run `/ai1st-dev-tasks` to produce `tasks.md`. Ensure it includes:
  - Early task for the theme.dart Arabic-font fallback
  - Decision task for the flutter_native_splash runtime approach
  - ARB key additions to `app_pl.arb` (canonical) before any widget code references them
- [ ] After `tasks.md` exists, re-run `/ai1st-dev-plan-confidence` for the fully-weighted score (Task Structure dimension included)

## Next Step

**GO** → Proceed to `/ai1st-dev-tasks` to generate the task breakdown, then `/ai1st-dev-implement`. The two yellow items above are quality refinements, not blockers; they can be absorbed into `tasks.md` rather than forcing another plan iteration.

If you want to address the yellow items in `plan.md` / `research.md` before generating tasks (cleaner for the implementer), do that first. Either path is acceptable — score remains ≥ 85%.
