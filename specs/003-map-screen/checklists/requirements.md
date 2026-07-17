# Specification Quality Checklist: Map Screen (v1)

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-05-31
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
  - Note: MapLibre (`maplibre_gl`) and "a geolocation package" are named deliberately — they are explicit Product-Owner decisions captured in Clarifications (R1) and the constitution mandate, not incidental implementation leakage. The exact tile provider, style, and geolocation plugin are left to planning (§5).
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details) — except the deliberately-decided engine/location capability noted above
- [x] All acceptance scenarios are defined (TC-1 … TC-23)
- [x] Edge cases are identified
- [x] Scope is clearly bounded (Out of Scope + Deferred Decisions)
- [x] Dependencies and assumptions identified (FC/FA + Integration Context)

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria (FR↔TC traceability tags present)
- [x] User scenarios cover primary flows (Map view, Lista view, search, filter, sort, navigate, location)
- [x] Feature meets measurable outcomes defined in NFRs
- [x] No unintended implementation details leak into the specification

## Notes

- Conflicts between the `specs/design/map` handoff and the launch data reality (no hours/address/walk-time/ratings) are documented and resolved in §2; the resolution mirrors the precedent set by `002-home-screen`.
- The one capability added beyond the 002 lean-guest baseline is **device location** (user-dot, locate-me, distance, Najbliższe sort) — explicitly approved in Clarifications R1.
- Ready for `/ai1st-po-clarify` (optional — no open markers) or `/ai1st-dev-plan`.
