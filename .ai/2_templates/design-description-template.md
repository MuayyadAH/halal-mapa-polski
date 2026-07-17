# Page Design: [PAGE NAME]

**URL:** [full URL]
**Captured:** [date]
**Feature Branch**: [NNN-feature-name]
**Layout:** Uses shared-layout (header, sidebar, footer) - see `specs/NNN-shared-layout/`

## Purpose

[1-2 sentences describing what this page does and who uses it]

## Main Content

[Description of the unique page content, excluding shared layout]

## Captured States

| State | Folder | Description |
|-------|--------|-------------|
| Main | [partials/main/](partials/main/) | Main page view |
| Filters | [partials/filters/](partials/filters/) | Filter panel expanded |
| [Modal] | [partials/modal-[name]/](partials/modal-[name]/) | [Modal name] modal open |
| Search | [partials/search/](partials/search/) | Search results filtered |

> Each folder contains: `screenshot.png`, `styles.json`, `description.md`

## Key Sections

### [Section Name]
- **Location**: [Position on page - top, center, etc.]
- **Contains**: [List of elements/components in this section]
- **Data**: [What data is displayed]

### [Another Section]
...

## Interactive Elements

| Element | Type | Action/Behavior | State |
|---------|------|-----------------|-------|
| [Button name] | Button | [What happens on click] | See [partials/modal-x/](partials/modal-x/) |
| [Input field] | Input | [What data it accepts, validation] | - |
| [Link] | Link | [Where it navigates] | - |
| [Dropdown] | Select | [Options and behavior] | See [partials/dropdown-x/](partials/dropdown-x/) |

## Modals & Panels

### [Modal/Panel Name]
- **Trigger**: [Button or action that opens this modal]
- **Partial**: [partials/modal-[name]/](partials/modal-[name]/)
- **Position**: [Describe observed position - centered, edge-attached, etc.]
- **Backdrop**: [Describe backdrop - color, blur, click behavior]
- **Animation**: [Opening animation if observed]
- **Dimensions**: [Approximate size or constraints]
- **Structure**:
  - Header: [Title, close button position]
  - Body: [Main content sections]
  - Footer: [Action buttons and positions]
- **Close behavior**: [X button, Escape key, click outside]

### [Another Modal]
...

## Forms

### [Form Name]
| Field | Type | Required | Validation | Options/Placeholder |
|-------|------|----------|------------|---------------------|
| [Field 1] | text | Yes | min 3 chars | "Enter name..." |
| [Field 2] | select | No | - | Option A, Option B, Option C |
| [Field 3] | date | Yes | future dates | - |
| [Field 4] | checkbox | No | - | - |

## Dropdowns & Filters

> Mark source as **TBD**. No guesses or assumptions. Backend analysis (/ai1st-dev-plan) will resolve it.

### [Dropdown Name]
- **Source**: TBD
- **Default**: [All] / [first option]
- **Observed count**: [N] options at capture time
- **Sample values**: [list a few representative values observed]

### [Another Dropdown]
...

## Element Color Map

> **CRITICAL**: This section maps every distinct text/background color from the reference to a design system variable.
> Colors are extracted via Playwright `getComputedStyle()` — not guessed from visual appearance.
> The implementer MUST use the mapped variable, not a semantic guess like `$color-text-secondary`.

### Text Colors

| UI Element | Reference Hex | RGB | Design System Variable | Font Size | Weight |
|-----------|---------------|-----|----------------------|-----------|--------|
| [Page/modal title] | [#hex] | [rgb(r,g,b)] | [$variable] | [Npx] | [N] |
| [Field labels] | [#hex] | [rgb(r,g,b)] | [$variable] | [Npx] | [N] |
| [Field values] | [#hex] | [rgb(r,g,b)] | [$variable] | [Npx] | [N] |
| [Section titles] | [#hex] | [rgb(r,g,b)] | [$variable] | [Npx] | [N] |
| [Table headers (th)] | [#hex] | [rgb(r,g,b)] | [$variable] | [Npx] | [N] |
| [Table body (td)] | [#hex] | [rgb(r,g,b)] | [$variable] | [Npx] | [N] |
| [Button text] | [#hex] | [rgb(r,g,b)] | [$variable] | [Npx] | [N] |
| [Links] | [#hex] | [rgb(r,g,b)] | [$variable] | [Npx] | [N] |
| [Pagination text] | [#hex] | [rgb(r,g,b)] | [$variable] | [Npx] | [N] |

### Background Colors

| UI Element | Reference Hex | RGB | Design System Variable |
|-----------|---------------|-----|----------------------|
| [Page/modal bg] | [#hex] | [rgb(r,g,b)] | [$variable] |
| [Table header row] | [#hex] | [rgb(r,g,b)] | [$variable] |
| [Total/footer row] | [#hex] | [rgb(r,g,b)] | [$variable] |
| [Buttons] | [#hex] | [rgb(r,g,b)] | [$variable] |

### Border Colors

| UI Element | Reference Hex | RGB | Design System Variable |
|-----------|---------------|-----|----------------------|
| [Table borders] | [#hex] | [rgb(r,g,b)] | [$variable] |
| [Input borders] | [#hex] | [rgb(r,g,b)] | [$variable] |

### Unmapped Colors

| Hex | RGB | Context | Suggested Variable |
|-----|-----|---------|-------------------|
| [#hex] | [rgb(r,g,b)] | [where used] | [$proposed-variable] |

> **Note**: If unmapped colors are found, add proposals to [token-proposals.md](token-proposals.md).

## Design Token Mapping

> Maps extracted `styles` array values (typography, spacing, borders) to project design tokens.
> Color mapping is in the Element Color Map above — not repeated here.

### Typography
| Element | Property | Value | Token | Match |
|---------|----------|-------|-------|-------|
| [Page title] | font-size | [Npx] | [$font-size-*] | [exact/close/none] |
| [Labels] | font-weight | [N] | [$font-weight-*] | [exact/close/none] |

### Spacing
| Element | Property | Value | Token | Match |
|---------|----------|-------|-------|-------|
| [Card] | padding | [Npx] | [$spacing-*] | [exact/close/none] |
| [Section] | margin | [Npx] | [$spacing-*] | [exact/close/none] |

### Borders
| Element | Property | Value | Token | Match |
|---------|----------|-------|-------|-------|
| [Table] | border-width | [Npx] | [$border-width] | [exact/close/none] |
| [Input] | border-radius | [Npx] | [$border-radius-*] | [exact/close/none] |

### Unmapped Styles
| Property | Value | Context | Suggested Token |
|----------|-------|---------|-----------------|
| [property] | [value] | [where used] | [proposed token] |

> **Note**: See [token-proposals.md](token-proposals.md) for detailed token addition proposals.

## Data Requirements

### Displayed Data
- [List of data fields shown on this page - observe column headers, labels, values]

### User Inputs
- [List of user actions and inputs observed - filters, form fields, buttons]

## RTL/i18n Considerations

- [RTL layout notes]
- [Translation requirements]

## i18n Text Mapping

> Document all visible text for translation key planning. This ensures translation keys are defined before implementation.

### Page-Level Text
| Location | Visible Text | Suggested Key |
|----------|--------------|---------------|
| Page Title | [Title text from UI] | `[feature].title` |
| Page Subtitle | [Subtitle text from UI] | `[feature].subtitle` |

### Button Labels
| Button | Visible Text | Suggested Key |
|--------|--------------|---------------|
| [Primary Action] | [Text] | `[feature].actions.[action]` |
| [Secondary Action] | [Text] | `[feature].actions.[action]` |

### Form Labels
| Form | Field | Visible Label | Suggested Key |
|------|-------|---------------|---------------|
| [Form Name] | [Field 1] | [Label text] | `[feature].form.[field]` |
| [Form Name] | [Field 2] | [Label text] | `[feature].form.[field]` |

### Table Headers
| Table | Column | Visible Header | Suggested Key |
|-------|--------|----------------|---------------|
| [Table Name] | [Column 1] | [Header text] | `[feature].table.[column]` |
| [Table Name] | [Column 2] | [Header text] | `[feature].table.[column]` |

### Dropdown Options
| Dropdown | Option Text | Suggested Key |
|----------|-------------|---------------|
| [Filter Name] | [Option text] | `[feature].filters.[option]` |

### Placeholders & Hints
| Element | Placeholder Text | Suggested Key |
|---------|------------------|---------------|
| [Search input] | [Placeholder text] | `[feature].placeholders.[field]` |

### Messages & Labels
| Context | Text | Suggested Key |
|---------|------|---------------|
| [Empty state] | [Message text] | `[feature].messages.[type]` |
| [Info box] | [Message text] | `[feature].info.[type]` |

> **Key Naming Convention**:
> - `[feature].title` / `[feature].subtitle` - Page headers
> - `[feature].actions.*` - Button labels
> - `[feature].form.*` - Form field labels
> - `[feature].table.*` - Table column headers
> - `[feature].filters.*` - Filter/dropdown options
> - `[feature].placeholders.*` - Input placeholders
> - `[feature].messages.*` - Status messages, empty states
> - `[feature].info.*` - Info boxes, tooltips

## Icons & SVG Assets

> Icons matched against the Icon Registry in `specs/design/design-system.md`. Existing icons reference their registry name; new icons are saved as `.svg` files in `icons/`.

| Icon | Visual | Registry Match | File | Dimensions | Style | Color | Count |
|------|--------|----------------|------|------------|-------|-------|-------|
| Search | Magnifying glass | `search` (existing) | — | 24×24 | fill | #066DCC | ×3 |
| Download | Arrow pointing down | — | [download.svg](icons/download.svg) | 24×24 | fill | #066DCC | ×1 |

### Font/Class-Based Icons

| Library | Icon Name | Context | Registry Match | Color | Size | Count |
|---------|-----------|---------|----------------|-------|------|-------|
| material | search | Search input | `search` (existing) | rgb(0,0,0) | 24px | ×3 |
| font-awesome | chevron-down | Dropdown toggle | `chevron-down` (existing) | rgb(53,71,125) | 14px | ×5 |

## Styling Notes

- [Any framework-agnostic styling patterns observed]
- [How to implement using project design tokens]
- [Material component recommendations for Angular]

## Placeholder Status

[If this page shows "Coming Soon" or is incomplete:]
- [ ] This page is a PLACEHOLDER
- Placeholder content: [Describe what's shown]
- Expected functionality: [What it should do when complete]
