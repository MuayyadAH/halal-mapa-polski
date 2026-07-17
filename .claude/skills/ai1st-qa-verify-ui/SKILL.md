---
name: ai1st-qa-verify-ui
description: "Verify UI implementation against reference design using visual and structural analysis"
disable-model-invocation: true
---


**Role**: Strict UI/UX QA Engineer. Find EVERY discrepancy. NEVER assume match — VERIFY it.

User input: $ARGUMENTS

---

## Critical Rules

1. **DESCRIBE BEFORE COMPARING**: For every element — describe reference, describe implementation, compare, assign status
2. **DIFFERENT MEANS DIFFERENT**: Position, type, style, behavior, text, icons, layout — any difference = mismatch. No "close enough"
3. **CHECK EVERYTHING**: Component patterns, buttons, inputs, dropdowns, tables, tabs, cards, icons, text, spacing, actions

---

## Setup

**Parse Arguments or Ask Interactively**

If `$ARGUMENTS` provides complete input, parse directly:
- `{feature}` → feature name, reference = `specs/{FEATURE}/design/`, impl = `http://localhost:4200/{route}`
- `{feature} {url}` → feature name + implementation URL, reference = `specs/{FEATURE}/design/`

If `$ARGUMENTS` is **empty or incomplete**, ask interactively using `AskUserQuestion`:

**Step A — Reference spec**: Ask: "Which feature spec will you use as the reference design?"
Auto-detect available specs: `ls -d specs/[0-9][0-9][0-9]-*/design/ 2>/dev/null | sed 's|specs/||;s|/design/||'`
Show the **latest 2-3 specs** (highest numbers) as options. Max 3 options:
- Each spec option: label = spec folder name, description = `specs/{name}/design/`

**Step B — Implementation URL**: Ask: "What is the implementation URL?"
- Suggest default: `http://localhost:4200/{route}` (derive route from feature name)
- User can provide a custom URL via Other

Set variables: `FEATURE`, `IMPL_URL`.

**Create Verification Directory**

```bash
existing=$(ls -d specs/verify-ui-report/{feature}-* 2>/dev/null | sort -V | tail -1)
next_num=$((${existing##*-} + 1)) 2>/dev/null || next_num=1
mkdir -p specs/verify-ui-report/{feature}-${next_num}
```

Set `REPORT_DIR` = `specs/verify-ui-report/{feature}-${next_num}` (absolute path).

**Portal Authentication** (if applicable)

@../../.ai_project_memory/rules/browsing-rules.md

If target URL is a portal page, follow Portal Browsing Rules above before proceeding.

---

## STEP 1 of 2: Create Review Tasks

### 1.1 Load Reference Context (parallel reads)

No browser interaction. Read all in one batch:
1. `specs/{FEATURE}/design/description.md` — reference description (screens, elements, layout)
2. `specs/{FEATURE}/design/styles.json` — reference styles/icons/colors
3. `.ai/2_templates/verify-ui-review-tasks-template.md` — task format

### 1.2 Build Reference Inventory

From reference artifacts (description.md, styles.json, partials/):

- Catalog ALL screens: main page + each `partials/*/` (from description.md, styles.json)
- For each screen, inventory: layout pattern, header, buttons, inputs, dropdowns, tables, tabs, footer
- Record reference colors from styles.json `colors` arrays (textColors, bgColors, borderColors)
- Record reference icons from styles.json `icons` array
- Record reference element styles from styles.json `styles` array (typography, spacing, borders)

### 1.3 Generate review_tasks.md

Using `.ai/2_templates/verify-ui-review-tasks-template.md` as format, generate `{REPORT_DIR}/review_tasks.md`.

Record `FEATURE` and `IMPL_URL` at the top of review_tasks.md so Step 2 knows the context.

Create one verification task per element/aspect found in reference inventory:

- Each task: checkbox `- [ ]`, ID (VT001...), severity expectation tag, screen name
- Description: what to verify, what the reference shows (expected value)
- Tasks organized by phase:
  - **Phase 1: Structure** — layout pattern, element presence, component types per screen
  - **Phase 2: Styles** — colors, typography, spacing, borders per screen (compare styles.json outputs)
  - **Phase 3: Interactive** — modals, panels, dropdowns, forms (compare against partials/)
  - **Phase 4: Icons** — icon presence, type, color per screen (compare icons arrays)
  - **Phase 5: Design Tokens** — SCSS files use correct tokens from design-system.md
  - **Phase 6: i18n/RTL** — translation keys exist, RTL logical properties used

Save file. Output review_tasks.md path and task count summary to user.

**Then run `/compact` to free context before proceeding to Step 2.**

---

## STEP 2 of 2: Execute Review Tasks and Generate Report

**Context recovery after compact** — re-read only what's needed:
1. `{REPORT_DIR}/review_tasks.md` — the task list (source of truth for Step 2)
2. `specs/{FEATURE}/design/styles.json` — reference styles for comparison
3. `specs/{FEATURE}/design/description.md` — reference descriptions
4. `specs/{FEATURE}/design/snapshot.md` — reference accessibility tree (for structure tasks)
5. `specs/design/design-system.md` — design tokens (for token verification tasks)
6. `.ai/2_templates/verify-ui-template.md` — report format

### Capture Script Router

Read `.ai/scripts/capture/router.js`, set `DIR` (absolute path to `.ai/scripts/capture`), `CMD`, and `OPTS`, pass to `browser_run_code`.

| Command | OPTS | Use |
|---------|------|-----|
| `styles` | `{}` | Main page style + icon + color extraction |
| `styles` | `{ containerSelector: '...' }` | Scoped extraction for modals/panels |
| `snapshot` | `{}` | Page content snapshot |
| `snapshot` | `{ selector: '...' }` | Modal/panel scoped snapshot |

### 2.1 Process Tasks One by One

Load `{REPORT_DIR}/review_tasks.md`. For each unchecked task:

1. **Capture**: Navigate to the relevant screen/element in implementation
   - Use `mcp__playwright__browser_navigate` — reuse returned snapshot, do NOT call `browser_snapshot` redundantly
   - 1-second max waits
   - If trigger needed: `mcp__playwright__browser_click`, reuse returned snapshot
   - Run `CMD = 'styles'` via router → **Write** to `{REPORT_DIR}/impl-styles-{screen}.json` (once per screen, skip if already captured)
   - For modals/panels: run `CMD = 'styles'` with `OPTS.containerSelector`
2. **Compare**: Check the specific element/aspect described in the task
   - Reference value (from review_tasks.md description) vs implementation value (from capture)
   - Classify finding: CRITICAL / MAJOR / MINOR
3. **Record**: Note the finding with:
   - What reference shows vs what implementation shows
   - Exact file path and line number for the fix
   - Current (wrong) value and expected value
   - Design system token name if applicable
4. **Mark** task as `[X]` in review_tasks.md

Severity classification:

| Severity | Criteria |
|----------|----------|
| CRITICAL | Component type differs, element missing, behavior differs, wrong position, overlay missing |
| MAJOR | Style significantly different, icon wrong, text wrong, layout off |
| MINOR | Slight text variation, minor spacing, icon style variation |

### 2.2 Generate Report

After all tasks processed, using `.ai/2_templates/verify-ui-template.md`, generate `{REPORT_DIR}/report.md`:

1. Fill **Summary**: verdict, issue counts
   - BLOCKED: any critical issues
   - NEEDS CHANGES: no critical, but major issues
   - APPROVED: only minor or no issues
2. Fill **Critical Issues**: `- [ ]` checkboxes with specific fix descriptions
3. Fill **Major Issues**: `- [ ]` checkboxes with specific fix descriptions
4. Fill **Minor Issues**: `- [ ]` checkboxes with specific fix descriptions
5. Fill **Style Comparison** tables: color/typography/spacing/icon mismatches
6. Fill **Artifacts**: list all generated files

Checkbox format: `- [ ] Fix [element]: reference shows [X] but implementation shows [Y]. Change [what] to [value] in [file:line]`

Save to `{REPORT_DIR}/report.md`.

---

## Rules

- **READ-ONLY**: produces report only, does not modify implementation code
- **NO sub-agents**: all work done directly
- **Use capture scripts**: `router.js` + `styles.js` for style/icon/color extraction
- **Reuse navigate/click snapshots**: avoid redundant `browser_snapshot` calls
- **1-second max waits**: modern SPAs load fast
- **Sequential discipline**: finish each step completely before starting the next
- **Context-safe**: tasks tracked in review_tasks.md — if context compacts, re-read file and continue

## Cleanup

```bash
rm -rf .playwright-mcp/
```
