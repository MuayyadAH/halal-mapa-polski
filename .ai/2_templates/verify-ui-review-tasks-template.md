# UI Review Tasks: [FEATURE NAME]

**Reference**: [specs path or URL]
**Implementation**: [URL]
**Date**: [DATE]
**Review ID**: [DIR NAME]

---

## Execution Flow
```
1. Load this file
2. For each unchecked task: verify the specific finding
3. Determine exact fix: file path, line, current value, expected value
4. Mark task as [X] after processing
5. Generate report.md from all findings using verify-ui-template.md
6. Delete this section when starting execution
```

## Format: `[ID] [SEVERITY] Description`

- **Checkbox**: Always `- [ ]`
- **ID**: Sequential (VT001, VT002...)
- **Severity**: [CRITICAL], [MAJOR], or [MINOR]
- **Description**: What to verify — element name, screen, what reference shows

---

## Phase 1: Structure Verification

<!-- Verify layout patterns, element presence, component types per screen.
     One task per screen for: layout pattern, header, element inventory.
     Source: reference description.md vs implementation snapshot. -->

## Phase 2: Style & Token Comparison

<!-- Compare extracted styles data: reference styles.json vs implementation impl-styles-{screen}.json.
     One task per style category per screen: colors, typography, spacing, borders.
     One task for design token usage verification in SCSS files.
     Source: styles.js extraction output comparison + design-system.md. -->

## Phase 3: Interactive Element Verification

<!-- Verify modals, panels, dropdowns, forms match reference partials.
     One task per interactive element: trigger, layout, fields, behavior.
     Compare scoped styles for modals/panels: reference partials/*/styles.json vs implementation.
     Source: reference partials/ vs implementation interactions. -->

## Phase 4: Icon & Asset Verification

<!-- Compare icons array from styles.js extraction: reference vs implementation.
     One task per icon mismatch: missing, different, wrong color/size.
     Source: reference styles.json icons vs implementation impl-styles.json icons. -->

## Phase 5: i18n/RTL Compliance

<!-- Verify translation keys exist in en.json and ar.json.
     Verify RTL logical properties used instead of physical (left/right → inset-inline).
     Source: implementation source files. -->

---

## Dependencies

- Phase 1 → before Phase 3 (structure needed for interactive verification)
- Phase 2 → independent (can run alongside Phase 1)
- Phase 4 → after Phase 1 and 3 (all screens must be captured)
- Phase 5 → independent
