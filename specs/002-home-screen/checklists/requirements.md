# Specification Quality Checklist: Home Screen (v1)

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-05-30
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- One round of Socratic dialogue (4 critical decisions) was sufficient because the design handoff (`handoff_home_v1`) is high-fidelity and self-declared as the source of truth, and the project's tech choices (Riverpod, go_router, bundled fonts, theme tokens, existing 5-tab shell) are already settled.
- Intentional handoff-vs-constitution conflicts (lean v1 omissions, 4-tab dock, chip vocabulary) are documented and resolved in spec §2 (Requirement Conflicts) and §11 (FC-3), not left as open clarifications.
- Remaining open items are captured as **Deferred Decisions** (chip vocabulary, bookmark persistence mechanism, EN/AR translations, curation rules, real photos, mini-map fidelity), each with a resolution phase — none block planning.
- FR-001–FR-023 (post data-source rewrite) are phrased as observable system behaviors; the few unavoidable platform references (reduced-motion setting, ARB localization) describe WHAT, not framework HOW.
- **Clarify session 2026-05-30** refined three interaction behaviors: city cards open the **Mapa** tab (not an in-place Home filter); the **"Wszystkie miejsca" browse-all section is removed** from Home (deep browsing lives in the Map feature); and **category chips filter the Featured row in place**. Nearest-first ("closest") ordering was requested but is infeasible without location, so it is deferred to the Map feature / post-v1 location hook. Spec updated accordingly (FR-002, FR-006, FR-014, FR-018, FR-021, FR-023; TCs renumbered to TC-1…TC-16).
- **Data-source session 2026-05-30 (during planning):** the real launch data is a shared Google Sheet (`Longitude, Latitude, Name, Category, Comment, Mawaqit Link`) with no city/hours/featured. Decisions: load it **live** at runtime (relaxes the offline guarantee); **drop "Popularne miasta", per-card city, and open/closed status** for v1; **auto-pick** featured; and make the **places data layer shared** (`lib/core/places/`) so Home and the future Map use one source. Spec rewritten accordingly (FR-001…FR-023, TC-1…TC-17). Plan/research/data-model/contracts realigned.
- Ready for `/ai1st-dev-plan` → `/ai1st-dev-tasks` (planning is complete; this re-plan reflects the real data source).
