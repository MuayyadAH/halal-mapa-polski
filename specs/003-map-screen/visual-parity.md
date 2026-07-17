# Visual Parity Review — Map Screen (v1)

**Date**: 2026-05-31 · **Against**: `specs/design/map/reference/01-map-view.png`, `02-list-view.png`, `README.md`
**Method**: manual comparison (Flutter native — no Playwright per Constitution §XII).

## Map view — matches
- ✅ Top search bar: parchment-glass pill, leading magnifier, "Szukaj na mapie…", trailing filter glyph.
- ✅ Map/Lista toggle (left) + category chips row (right).
- ✅ Teardrop category pins (correct colours + upright glyphs); cocoa count cluster; blue user dot.
- ✅ Floating bottom sheet (rounded card, grab handle, "N miejsc" header + "Pokaż listę" link, horizontal mini-cards: gradient icon tile, name, "Kategoria · dist", navigate button).
- ✅ Locate-me FAB (parchment glass, crosshair).

## Lista view — matches
- ✅ "Filtruj listę…" bar + filter glyph; Map/Lista toggle (Lista active) + "Najbliższe ▾" sort pill.
- ✅ Header "Wszystkie miejsca" (Lora) + count subtitle; warm gradient background.
- ✅ Rows: 54dp gradient icon tile, name, "Kategoria · …" meta, trailing distance (Lora) + navigate button, dividers.

## Documented deviations (intentional — lean v1 data / app shell)
| Design shows | v1 | Why |
|---|---|---|
| Open/closed status ("Otwarte · do 22:00" / "Zamknięte") on cards + rows | omitted | No opening-hours in the Google-Sheet data (spec §2; FR-013). Returns with an Hours column. |
| Address + district ("Marszałkowska 8 · Śródmieście"); walk time ("5 min") | omitted (comment shown instead) | Not in the data / not derivable (no routing). |
| Sub "84 miejsca halal w Warszawie" | "N miejsc" | No city/per-place city data. |
| 4-tab dock (Strona / Mapa / Zapisane / O nas) | existing **5-tab** nav (Strona/Mapa/Dodaj/Zapisane/Profil) | App-shell decision (FR-001; mirrors 002). The Map renders content only. |

## Accessibility note (deferred refinement)
The design's chrome is compact (chips ~34dp, toggle/sort ~30–34dp, navigate 24dp) — below the WCAG/Constitution **≥44dp** target. Kept at the design sizes for fidelity per PO direction; enlarging tap targets without breaking the look is a follow-up (e.g. transparent hit-padding). Icon-only controls all carry `Semantics` labels.

**Conclusion**: layout, chrome, pins, sheet, and list structure are faithful to the reference; all gaps trace to the documented lean-data + 5-tab-shell decisions, not implementation drift.
