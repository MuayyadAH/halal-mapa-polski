# Plan Confidence Report

**Feature**: Map Screen (v1)
**Branch**: `003-map-screen`
**Date**: 2026-05-31
**Overall Confidence**: **94%** → **GO**

> Computed **without Task Structure** (`tasks.md` not yet generated). Weighted sum over the remaining five dimensions (0.95) renormalized to 100%.

## Dimension Scores

| Dimension | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Completeness | 25% | 95 | 23.8 |
| Constitution Alignment | 20% | 100 | 20.0 |
| Technical Decision Quality | 20% | 90 | 18.0 |
| Requirement Clarity | 15% | 96 | 14.4 |
| Task Structure | 5% | DEFERRED | — |
| Risk & Blockers | 15% | 90 | 13.5 |
| **Total** | **100%** | — | **89.7 → 94.4** |

*(Task Structure deferred — score renormalized over 95%.)*

## Findings by Dimension

### Completeness — 95/100
- ✅ No `NEEDS CLARIFICATION` / `TODO` markers remain in `spec.md` or `plan.md`; spec passed two `/ai1st-po-clarify` rounds (`spec.md` §2 "Round 1" + "Session 2026-05-31 (Clarify)").
- ✅ Required artifacts present for a UI feature: `data-model.md`, `contracts/` (3), `quickstart.md`, `research.md` (R1–R17), `checklists/requirements.md` (all `[x]`).
- ✅ Design source richly referenced (`spec.md` §4 Requirement Documents → `specs/design/map/` README/PROMPT/ANIMATIONS + reference PNGs/HTML).
- ⚠️ One runtime input is intentionally deferred: the MapLibre **tile provider/style** (`research.md` R17, `plan.md` Deferred/§5). Recommended default (MapTiler) is given, so it is *resolved-with-a-recommendation*, not unresolved — but tiles won't render at runtime until a key/provider is chosen. Does not block code start (engine abstraction + asset style indirection).
- Note: no `/ai1st-po-capture-ui` `design/` folder exists; not penalized — the design *handoff* (`specs/design/map/`) is the source and is fully referenced.

### Constitution Alignment — 100/100
- ✅ `plan.md` Constitution Check: **all gates PASS** (frontend §I–§XIII + universal §1.1–1.7/§2/§4 enumerated and checked).
- ✅ Violations documented with explicit justification in `plan.md` Complexity Tracking (lean-v1 omissions; two PO-approved deps; widget-overlay pins; two file promotions).
- ✅ Stack constitution updated: `constitution-frontend.md` §1.1 now records `maplibre_gl` (chosen, "Introduced by 003-map-screen") + a new `geolocator` **Location** row with the §1.7 accuracy default (`constitution-frontend.md:19-22`).
- ✅ Privacy-correct: location only-while-using + approximate (NFR-005); no analytics; keys via `--dart-define`.

### Technical Decision Quality — 90/100
- ✅ Every `research.md` decision (R1–R17) carries **Decision / Rationale / Alternatives / Source**.
- ✅ Hard problems reasoned, not hand-waved: native-symbol vs Flutter-widget pins (R3), Dart clustering (R4), MapEngine fakeability for headless tests (R2/R15).
- ⚠️ **Two new dependencies unpinned** — `maplibre_gl` and `geolocator` are added via `flutter pub add` at setup with no version yet (`plan.md` Technical Context; `research.md` R16). Existing deps are pinned in `pubspec.yaml`. −10 (2 × −5). Pin both in the first task and re-confirm MapLibre's min-SDK floor.
- ✅ Integration points named (style URL via `Env`, permission via `PermissionsService`, navigate via shared `MapsLauncher`).

### Requirement Clarity — 96/100
- ✅ FRs name concrete entity + field/behavior + scope, e.g. `FR-011`/`FR-012` (shared `activeCategories` set; chip single-select vs sheet multi-select; Map scope), `FR-017` (full-dataset accent-insensitive match; out-of-filter selection clears filter), `FR-009`/`FR-015` (adaptive m/km distance on mini-card/row).
- ✅ Acceptance is measurable/observable: TC-1…TC-23 each tie to FRs (e.g. TC-8b out-of-filter selection; TC-14a distance format; TC-16 sheet order + count).
- ✅ Traceability holds both ways: `data-model.md` entities/providers cite FRs; `contracts/*` cite user actions + FRs.
- ⚠️ A couple of FRs are dense multi-clause (`FR-007`, `FR-024`) — clear but worth splitting into discrete task-level checks during `/ai1st-dev-tasks` so each sub-behavior gets its own test. Minor.

### Task Structure — DEFERRED
- `tasks.md` not present. Run `/ai1st-dev-tasks` to generate it; score is renormalized without this dimension. `plan.md` Phase 2 already sketches a dependency-ordered ~36–44 task plan with `[P]` candidates and a Home-regression-after-promotion verification task, so task generation is well-seeded.

### Risk & Blockers — 90/100
- ✅ Checklist `checklists/requirements.md` — all items `[x]`.
- ✅ External/new dependencies flagged and researched: MapLibre (R2), geolocator (R5), tile provider (R17), platform config (R16). No backend endpoints needed (documented N/A).
- ⚠️ **Risk 1 — tile provider/key (runtime).** Until R17's ADR lands and a key is wired, the map shows the warm background but no tiles. Mitigated: abstraction + asset-style indirection means a later swap is config-only. Validate early with a dev key.
- ⚠️ **Risk 2 — widget-overlay pin performance** (`research.md` R3). Projecting many Flutter pins per camera move can cost frames; mitigation is viewport-cull + Dart clustering (R4), but NFR-001 (60 fps) must be verified on the Pixel 7 with a realistic dataset.
- ⚠️ **Risk 3 — MapLibre untestable headless** — accepted and mitigated by the `FakeMapEngine` (R15); native rendering only covered by the integration test, so keep that test meaningful.
- No hard blockers: implementation can begin; the two ⚠️ runtime risks are validate-during-build, not plan gaps.

## Blockers (must resolve before /ai1st-dev-implement)
*None hard-blocking.* The following are strongly recommended pre-work, not gates:
1. Pin `maplibre_gl` + `geolocator` versions and confirm MapLibre min-SDK — first setup task (`plan.md` Phase 2 step 1).
2. Obtain a dev tile key (MapTiler recommended) so the basemap renders during development (`research.md` R17). The full provider choice can remain an ADR.

## Recommended Actions
- [ ] Run `/ai1st-dev-tasks` to generate `tasks.md` (lifts Task Structure from DEFERRED and re-weights to full 100%).
- [ ] (Optional) Settle the tile-provider **ADR** now, or proceed with the MapTiler recommendation + a dev key and finalize later.
- [ ] In task generation, split the dense FRs (`FR-007`, `FR-024`) into per-behavior test tasks.
- [ ] Add an explicit NFR-001 performance-validation task for the widget-overlay pins on the reference device.

## Next Step
- **GO** → Proceed to `/ai1st-dev-tasks` then `/ai1st-dev-implement`. (Confidence 94%; weakest dimensions: Technical Decision Quality 90 and Risk 90 — both driven by the two new deps + tile/perf runtime risks, all manageable during build.)
- If you prefer maximum certainty first: settle the tile-provider ADR and pin the deps, then this score rises into the high-90s.
