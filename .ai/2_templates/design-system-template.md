# [Application Name] - Design System

**Version**: 1.0 | **Updated**: [YYYY-MM-DD] | **Status**: [Draft | Active | Archived]

> Technical implementation details, CSS code, and configuration are in [design-system-tech-spec.md](./design-system-tech-spec.md)

---

## Execution Flow (main)
```
1. Gather brand materials:
   → Brand guidelines (colors, typography, logo usage)
   → Reference designs or existing applications
   → Project wireframes showing layout structure
   → Component requirements from user stories

2. Establish design principles (Section 1):
   → Define 3-5 core design principles aligned with brand
   → Document technology stack (framework, styling, visualization)
   → Link to brand resources

3. Define application frame structure (Section 2):
   → Page container (max-width, background, centering)
   → Global header (height, background, contents)
   → Include wireframe/mockup image reference

4. Create layout system (Section 3):
   → Define column widths (sidebar, content)
   → Establish spacing grid (base unit, typically 4px or 8px)
   → Document widget/card sizing options

5. Define foundations (Section 4):
   → Color palette with hex codes and usage
   → Typography scale (font families, sizes, weights)
   → Spacing system tokens
   → Shadows and elevation levels
   → Border radius tokens
   → Iconography library

6. Document component library (Section 5):
   → Buttons (variants, states, sizing)
   → Inputs and forms (states, validation)
   → Tables (header, rows, selection)
   → Tooltips, dropdowns, badges
   → Application-specific components

7. Define interaction patterns (Section 6):
   → User workflows (selection, filtering, navigation)
   → State transitions
   → URL/deep linking parameters

8. Document data visualization (Section 7) if applicable:
   → Chart library configuration
   → Color palette for data
   → Multi-axis or specialized rendering

9. Specify accessibility requirements (Section 8):
   → WCAG compliance level (AA or AAA)
   → Contrast ratios
   → Keyboard navigation
   → Screen reader support

10. Define responsive design (Section 9):
    → Breakpoints
    → Layout transformations per breakpoint
    → Mobile-specific requirements

11. Assign DS-xxx requirement IDs:
    → DS-1xx: Page structure and layout
    → DS-2xx: Color specifications
    → DS-3xx: Typography specifications
    → DS-4xx: Component specifications
    → DS-5xx: Interaction patterns
    → DS-6xx: Data visualization
    → DS-7xx: Accessibility requirements
    → DS-8xx: Responsive design

12. Validate completeness:
    → All brand colors have hex codes?
    → All components have specifications?
    → All interactive states documented?
    → Accessibility requirements included?

13. Delete section: Execution Flow (main)
14. Return: SUCCESS (design system ready for implementation)
```

---

## Requirement ID Convention

| Prefix | Domain |
|--------|--------|
| DS-1xx | Page structure and layout |
| DS-2xx | Color specifications |
| DS-3xx | Typography specifications |
| DS-4xx | Component specifications |
| DS-5xx | Interaction patterns |
| DS-6xx | Data visualization |
| DS-7xx | Accessibility requirements |
| DS-8xx | Responsive design |

---

## 1. Overview

This design system defines the visual language for **[Application Name]**, a [application type] for [target users].

### Design Principles

| Principle | Description |
|-----------|-------------|
| **[Principle 1]** | [Description - e.g., Brand Aligned, Data-Focused, Professional] |
| **[Principle 2]** | [Description] |
| **[Principle 3]** | [Description] |
| **[Principle 4]** | [Description] |
| **[Principle 5]** | [Description] |

### Brand Resources

- [Brand Style Guide Link]
- [Brand Assets Link]

### Technology Stack

| Layer | Technology |
|-------|------------|
| Framework | [e.g., React 19 + TypeScript] |
| Styling | [e.g., Tailwind CSS] |
| Visualization | [e.g., Apache ECharts, D3.js, Chart.js] |
| State | [e.g., TanStack Query, Redux, Zustand] |

---

## 2. Application Frame Structure

### Design Reference

<img src="./UI_wireframe.png" alt="[Application Name] Wireframe" width="800"/>

### Page Container

| ID | Property | Value |
|----|----------|-------|
| DS-101 | Page background | #[XXXXXX] |
| DS-102 | Page width | 100% viewport |
| DS-103 | Page min-height | 100vh |
| DS-109 | Container max-width | [NNNN]px |
| DS-110 | Container alignment | Centered (margin: 0 auto) |
| DS-111 | Container background | #FFFFFF |

### Global Header

| ID | Property | Value |
|----|----------|-------|
| DS-104 | Height | [NN]px fixed |
| DS-105 | Background | #[XXXXXX] |
| DS-106 | Text color | #[XXXXXX] |
| DS-107 | Position | [Part of container / Fixed] |
| DS-108 | Contents | [Logo + Title + User Profile] |

**Header Structure**: `[Logo] [Title/Details] [Actions/Profile]`

#### [Header Section 1 - e.g., Title Area]

| Line | Content | Font |
|------|---------|------|
| 1 | [Main title] | [Font] [Size], #[Color] |
| 2 | [Subtitle] | [Font] [Size], #[Color] |
| 3 | [Metadata] | [Font] [Size], #[Color] |

#### [Header Section 2 - e.g., User Profile]

| Property | Value |
|----------|-------|
| Size | [NN]x[NN]px |
| Background | [rgba or hex] |
| Border | [specification] |
| Border-radius | [specification] |

---

## 3. Layout System

| ID | Property | Value |
|----|----------|-------|
| DS-112 | Left/sidebar width | [NNN]px fixed |
| DS-113 | Content width | Dynamic ([NNN]px on [NNNN]px screens) |
| DS-114 | Base spacing unit | [N]px |
| DS-115 | Content gutter | [NN]px |
| DS-116 | Content padding | [NN]px |

### Layout Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ Page Background (#[XXXXXX]) - Full Viewport                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Page Container ([NNNN]px, white)                         │   │
│  │ ┌────────────────────────────────────────────────────┐   │   │
│  │ │ Header ([NN]px, #[XXXXXX])                         │   │   │
│  │ └────────────────────────────────────────────────────┘   │   │
│  │ ┌────────┬───────────────────────────────────────────┐   │   │
│  │ │ Side   │  Content Area                             │   │   │
│  │ │ [NNN]  │  ┌─────────────────────────────────────┐  │   │   │
│  │ │  px    │  │ Widget/Content                      │  │   │   │
│  │ │        │  └─────────────────────────────────────┘  │   │   │
│  │ └────────┴───────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Sidebar

| ID | Property | Value |
|----|----------|-------|
| DS-117 | Width | [NNN]px fixed |
| DS-118 | Height | calc(100vh - [header]px) |
| DS-118a | Section spacing | [NN]px vertical |
| DS-118b | Section order | [Component 1] above [Component 2] |
| DS-118c | Section padding | [NN]px internal |
| DS-119 | Background | #[XXXXXX] |
| DS-120 | Border-right | 1px solid #[XXXXXX] |
| DS-121 | Padding | [NN]px |
| DS-122 | Overflow-y | auto (scrollable) |

### Widget Sizing

| Type | Columns | Width |
|------|---------|-------|
| Small | 3/12 | 25% |
| Medium | 4/12 | 33.33% |
| Large | 6/12 | 50% |
| Full | 12/12 | 100% |

---

## 4. Foundations

### 4.1 Color Palette

> **Single source of truth** - All documents should reference this palette.

#### Brand Colors

| ID | Role | Hex | Usage |
|----|------|-----|-------|
| DS-201 | Primary | #[XXXXXX] | Buttons, interactive elements |
| DS-202 | Primary (Header) | #[XXXXXX] | Header background only |
| DS-203 | Secondary | #[XXXXXX] | Accents, secondary emphasis |
| DS-204 | Error | #[XXXXXX] | Error states, alerts |
| DS-205 | Success | #[XXXXXX] | Success states |
| DS-206 | Warning | #[XXXXXX] | Warning states |
| DS-207 | Info | #[XXXXXX] | Info messages |

**Button States**:
| State | Color |
|-------|-------|
| Default | #[XXXXXX] |
| Hover | #[XXXXXX] (lighter) |
| Active | #[XXXXXX] (darker) |

#### Neutral Colors

| ID | Role | Hex | Usage |
|----|------|-----|-------|
| DS-208 | Text Primary | #[XXXXXX] | Body text |
| DS-209 | Text Secondary | #[XXXXXX] | Labels |
| - | Text Tertiary | #[XXXXXX] | Disabled, placeholders |
| DS-210 | Border/Divider | #[XXXXXX] | Borders, separators |
| DS-211 | Page Background | #[XXXXXX] | App frame background |
| DS-212 | Sidebar Background | #[XXXXXX] | Sidebar panel |

#### Chart/Data Colors (if applicable)

| ID | # | Color | Hex |
|----|---|-------|-----|
| DS-213/214 | 1 | [Name] | #[XXXXXX] |
| | 2 | [Name] | #[XXXXXX] |
| | 3 | [Name] | #[XXXXXX] |
| | 4 | [Name] | #[XXXXXX] |
| | 5 | [Name] | #[XXXXXX] |

All chart colors have minimum 3:1 contrast against white (WCAG 2.1 AA for graphical objects).

---

### 4.2 Typography

| ID | Style | Font | Size/Line Height | Weight | Usage |
|----|-------|------|------------------|--------|-------|
| DS-301 | Headline | [Font] | - | - | Headers, branding |
| DS-302 | Body | [Font] | - | - | All UI text |
| DS-303 | App Title | [Font] | [NN]px/[NN]px | Bold | Header title |
| DS-304 | H1 | [Font] | [NN]px/[NN]px | Bold | Section headers |
| DS-305 | Body | [Font] | [NN]px/[NN]px | Regular | Content, labels |
| DS-306 | Button | [Font] | [NN]px/[NN]px | Bold | Interactive elements |
| DS-307 | Caption | [Font] | [NN]px/[NN]px | Regular | Tooltips, small text |

**Letter Spacing**: Headings [N.NN]em, Body 0, Buttons [N.NN]em

---

### 4.3 Spacing System

**Base Unit**: [N]px

| Token | Value | Tailwind | Usage |
|-------|-------|----------|-------|
| space-1 | [N]px | p-1 | Icon padding |
| space-2 | [N]px | p-2 | Default spacing |
| space-3 | [NN]px | p-3 | Card padding |
| space-4 | [NN]px | p-4 | Section padding |
| space-6 | [NN]px | p-6 | Column gap |
| space-8 | [NN]px | p-8 | Section margins |

**Component-Specific**:
| Component | Padding |
|-----------|---------|
| Button | [N]px x [NN]px |
| Input | [NN]px x [NN]px |
| Card/Panel | [NN]px all sides |
| Touch target | [NN]x[NN]px |

---

### 4.4 Shadows & Elevation

| Level | Shadow | Usage |
|-------|--------|-------|
| xs | 0 1px 2px rgba(0,0,0,0.05) | Subtle |
| sm | 0 2px 4px rgba(0,0,0,0.1) | Cards, inputs |
| md | 0 4px 8px rgba(0,0,0,0.15) | Elevated cards |
| lg | 0 8px 16px rgba(0,0,0,0.2) | Dropdowns |
| xl | 0 12px 24px rgba(0,0,0,0.25) | Modals |

**Z-Index Stack**: Base 0, Sticky 10, Header 100, Dropdowns 200, Modals 300, Tooltips 400, Notifications 500

---

### 4.5 Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| rounded-sm | 2px | Checkboxes |
| rounded | 4px | Buttons, inputs |
| rounded-md | 6px | Cards |
| rounded-lg | 8px | Sections, containers |
| rounded-full | 9999px | Avatars, pills |

---

### 4.6 Iconography

> **Emojis in documentation are placeholders only** - Use SVG icons in implementation.

| Library | Usage | Implementation |
|---------|-------|----------------|
| [Icon Library 1] | Navigation, actions | @[package] |
| [Icon Library 2] | Technical/domain | @[package] |
| Custom | Brand elements, logos | src/assets/icons/ |

**Icon Sizing**:
| Size | Dimensions | Usage |
|------|------------|-------|
| Small | 16x16px | Buttons, metadata |
| Medium | 20x20px | Navigation, lists |
| Large | 24x24px | Section headers |
| Display | 32x32px+ | Empty states |

---

## 5. Component Library

### 5.1 Buttons

| ID | Property | Value |
|----|----------|-------|
| DS-401 | Primary background | #[XXXXXX] |
| DS-402 | Primary text | #FFFFFF |
| DS-403 | Padding | [N]px [NN]px |
| DS-404 | Border-radius | [N]px |
| DS-405 | Font | [NN]px [Font] Bold |
| DS-406 | Min touch target | [NN]x[NN]px |
| DS-407 | Focus indicator | 2px outline |

**Button Variants**:

| Variant | Background | Border | Text |
|---------|------------|--------|------|
| Primary | #[XXXXXX] | none | #FFFFFF |
| Primary Hover | #[XXXXXX] | none | #FFFFFF |
| Primary Disabled | #[XXXXXX] | none | #[XXXXXX] |
| Secondary | #[XXXXXX] | none | #FFFFFF |
| Tertiary (Outlined) | transparent | 1px #[XXXXXX] | #[XXXXXX] |
| Ghost | transparent | none | #[XXXXXX] |

**Standard Button**: Height [NN]px, min-width [NN]px

---

### 5.2 Inputs & Forms

| ID | Property | Value |
|----|----------|-------|
| DS-408 | Input height | [NN]px |
| DS-409 | Border | 1px solid #[XXXXXX] |
| DS-410 | Border-radius | [N]px |
| DS-411 | Focus border | 2px #[XXXXXX] |
| DS-412 | Error border | 2px #[XXXXXX] |
| DS-413 | Checkbox size | [NN]x[NN]px visual, [NN]x[NN]px hit area |
| DS-413a | Checkbox accent | #[XXXXXX] |

**Input States**:
| State | Style |
|-------|-------|
| Default | 1px gray border |
| Focus | 2px primary border + shadow |
| Error | 2px error border |
| Disabled | Gray background, muted text |

---

### 5.3 Tables

**Table Structure**:
| Element | Style |
|---------|-------|
| Header | #[XXXXXX] background, [NN]px Bold, #[XXXXXX] |
| Row | [NN]px min-height, 1px bottom border |
| Cell | [NN]px [NN]px padding |
| Hover | #[XXXXXX] background |
| Selected | #[XXXXXX] background, [N]px left border #[XXXXXX] |

**Status Indicators**: [Colors and sizes for status dots]

---

### 5.4 Tooltips

| ID | Property | Value |
|----|----------|-------|
| DS-414 | Background | rgba(0,0,0,0.85) |
| DS-415 | Text color | #FFFFFF |
| DS-416 | Max-width | [NNN]px |
| DS-417 | Border-radius | [N]px |
| DS-418 | Content | [Description of content] |
| DS-419 | Position | [Positioning behavior] |

---

### 5.5 [Application-Specific Component 1]

| ID | Property | Value |
|----|----------|-------|
| DS-5XXa | [Property] | [Value] |
| DS-5XXb | [Property] | [Value] |

---

### 5.6 [Application-Specific Component 2]

| ID | Property | Value |
|----|----------|-------|
| DS-5XXa | [Property] | [Value] |
| DS-5XXb | [Property] | [Value] |

---

## 6. Interaction Patterns

### 6.1 [Pattern 1 - e.g., Time Range Selection]

| ID | Requirement |
|----|-------------|
| DS-501 | [Requirement description] |
| DS-501a | [Sub-requirement] |
| DS-501b | [Sub-requirement] |

---

### 6.2 [Pattern 2 - e.g., Item Selection]

| ID | Requirement |
|----|-------------|
| DS-504 | [Requirement description] |
| DS-505 | [Requirement description] |

**Workflow**: [Step 1] → [Step 2] → [Step 3] → [Result]

---

### 6.3 [Pattern 3 - e.g., Chart Interactions]

| ID | Requirement |
|----|-------------|
| DS-507 | [Requirement description] |
| DS-508 | [Requirement description] |

---

## 7. Data Visualization

| ID | Requirement |
|----|-------------|
| DS-601 | [Renderer type] |
| DS-602 | [Max items] |
| DS-603 | [Axis configuration] |
| DS-604 | [Layout behavior] |
| ~~DS-605~~ | ~~[Offset/spacing]~~ (DEPRECATED: use DS-811/812 for responsive values) |
| DS-606 | [Color matching] |
| DS-607 | [Special rendering - e.g., boolean states] |
| DS-608 | [Alert/highlight color] |
| DS-609 | [Z-index layering] |
| DS-610 | [Legend configuration] |

**[Axis/Layout Configuration]**:
| [Category] | Position |
|---------|----------|
| [Item 1] | [Position] |
| [Item 2] | [Position] |

---

## 8. Accessibility

### WCAG 2.1 AA Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| DS-701 | Normal text contrast | 4.5:1 minimum |
| DS-702 | Large text contrast | 3:1 minimum |
| DS-703 | Graphical objects | 3:1 minimum |
| DS-704 | Keyboard accessible | All interactive elements |
| DS-705 | Focus indicator | 2px solid #[XXXXXX], 2px offset |
| DS-709 | Touch target | [NN]x[NN]px minimum |

### Keyboard Navigation

| Key | Action |
|-----|--------|
| Tab | Next element |
| Shift+Tab | Previous element |
| Space | Toggle checkbox, activate button |
| Enter | Activate button, submit, select |
| Escape | Close modal, cancel |
| Arrow keys | Navigate within components |

### Screen Reader Support

| ID | Requirement |
|----|-------------|
| DS-710 | [Screen reader requirement 1] |
| DS-711 | ARIA labels on all interactive elements |
| DS-712 | Status changes via aria-live |

---

## 9. Responsive Design

| ID | Breakpoint | Layout |
|----|------------|--------|
| DS-801 | ≥[NNNN]px (Desktop) | [Layout description] |
| DS-802 | [NNNN]-[NNNN]px (Laptop) | [Layout description] |
| DS-803 | [NNN]-[NNNN]px (Tablet) | [Layout description] |
| DS-804 | <[NNN]px (Mobile) | [Layout description] |
| DS-805 | Mobile [component] | [Specification] |
| DS-806 | Mobile font reduction | -[N]px |
| DS-807 | Mobile touch target | [NN]x[NN]px |

---

## 10. File Structure

```
src/
├── features/
│   ├── [feature-1]/
│   │   ├── components/
│   │   ├── hooks/
│   │   └── types/
│   ├── [feature-2]/
│   │   ├── components/
│   │   ├── hooks/
│   │   └── types/
│   └── [feature-3]/
│       ├── components/
│       ├── hooks/
│       └── utils/
├── shared/
│   ├── components/
│   ├── hooks/
│   └── utils/
└── api/
    └── generated/
```

---

## 11. References

### Design Assets

| Asset | File |
|-------|------|
| Wireframe | UI_wireframe.png |
| [Component] wireframe | UI_[component]_wireframe.png |
| Buttons | UI_components_buttons.png |
| Table | UI_components_table.png |

### Technical Documentation

- [Visualization Library Documentation Link]
- [CSS Framework Documentation Link]
- [WCAG 2.1 Link](https://www.w3.org/WAI/WCAG21/quickref/)
- [Technical Spec](./design-system-tech-spec.md)

---

## 12. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | [YYYY-MM-DD] | Initial design system |

---

**Status**: [Draft | Active | Archived] - [Ready for Implementation | In Review | etc.]
