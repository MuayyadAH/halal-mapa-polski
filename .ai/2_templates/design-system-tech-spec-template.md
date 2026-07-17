# Design System - Technical Specification

**Version**: 1.0 | **Updated**: [YYYY-MM-DD]

> This document contains implementation details for [design-system.md](./design-system.md)

---

## Execution Flow (main)
```
1. Read design-system.md for specifications:
   → Extract color palette hex codes
   → Extract typography specifications
   → Extract spacing values
   → Extract component specifications

2. Generate CSS framework configuration (Section 1):
   → Map brand colors to framework tokens
   → Configure custom font families
   → Define spacing scale
   → Configure shadow utilities

3. Create CSS component classes (Section 2):
   → Page container styles
   → Header styles
   → Sidebar styles
   → Button variants and states
   → Input variants and states
   → Table styles
   → Tooltip styles
   → Application-specific components

4. Configure visualization library (Section 3) if applicable:
   → Global chart settings
   → Chart options template
   → Multi-axis layout functions
   → Special rendering (boolean, alerts)
   → Color palette array

5. Document ARIA implementation (Section 4):
   → Chart accessibility patterns
   → Interactive element patterns
   → Live region patterns

6. Define responsive breakpoints (Section 5):
   → Mobile breakpoint styles
   → Tablet breakpoint styles
   → Desktop breakpoint styles
   → Typography scale adjustments

7. Document z-index stack (Section 6):
   → CSS custom properties for z-index
   → Layer ordering

8. Define focus states (Section 7):
   → Focus-visible styles
   → Custom focus indicators

9. Create icon mapping (Section 8):
   → Documentation placeholder → Implementation component

10. Document animation timing (Section 9):
    → Transition durations
    → Easing functions

11. Define touch gestures (Section 10) if applicable:
    → Mobile gesture mappings

12. Validate implementation completeness:
    → All colors from design-system.md included?
    → All components have CSS?
    → All states documented?
    → Accessibility patterns included?

13. Delete section: Execution Flow (main)
14. Return: SUCCESS (tech spec ready for development)
```

---

## 1. CSS Framework Configuration

```javascript
// tailwind.config.js (or equivalent framework config)
module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}', './public/index.html'],
  theme: {
    extend: {
      colors: {
        // Brand colors (from DS-2xx)
        '[brand]-primary': '#[XXXXXX]',
        '[brand]-primary-hover': '#[XXXXXX]',
        '[brand]-primary-active': '#[XXXXXX]',
        '[brand]-secondary': '#[XXXXXX]',
        '[brand]-error': '#[XXXXXX]',

        // Semantic
        'success': '#[XXXXXX]',
        'warning': '#[XXXXXX]',
        'error': '#[XXXXXX]',
        'info': '#[XXXXXX]',

        // Neutral
        'text-primary': '#[XXXXXX]',
        'text-secondary': '#[XXXXXX]',
        'text-tertiary': '#[XXXXXX]',
        'border': '#[XXXXXX]',
        'bg-page': '#[XXXXXX]',
        'bg-side': '#[XXXXXX]',

        // Chart/Data palette (if applicable)
        'chart-1': '#[XXXXXX]',
        'chart-2': '#[XXXXXX]',
        'chart-3': '#[XXXXXX]',
        'chart-4': '#[XXXXXX]',
        'chart-5': '#[XXXXXX]',
        // ... up to chart-10
      },
      fontFamily: {
        sans: ['[Body Font]', '[Fallback]', 'sans-serif'],
        headline: ['[Headline Font]', '[Fallback]', 'sans-serif'],
      },
      spacing: {
        // Custom spacing values
        '[token]': '[value]rem',  // e.g., '18': '4.5rem' (72px)
        '[token]': '[value]rem',  // e.g., '96': '24rem' (384px sidebar)
        '[token]': '[value]rem',  // e.g., '200': '100rem' (1600px container)
      },
      boxShadow: {
        'xs': '0 1px 2px rgba(0,0,0,0.05)',
        'sm': '0 2px 4px rgba(0,0,0,0.1)',
        'md': '0 4px 8px rgba(0,0,0,0.15)',
        'lg': '0 8px 16px rgba(0,0,0,0.2)',
        'xl': '0 12px 24px rgba(0,0,0,0.25)',
      },
    },
  },
  plugins: [],
};
```

---

## 2. CSS Components

### 2.1 Page Container

```css
/* DS-109, DS-110, DS-111 */
.page-container {
  max-width: [NNNN]px;
  margin: 0 auto;
  background: #FFFFFF;
}

/* DS-101 */
.page-background {
  background: #[XXXXXX];
  min-height: 100vh;
  width: 100%;
}
```

### 2.2 Header

```css
/* DS-104, DS-105, DS-106 */
.header {
  height: [NN]px;
  background: #[XXXXXX];
  color: #FFFFFF;
  display: flex;
  align-items: center;
  padding: 0 24px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header-logo {
  height: [NN]px;
  width: auto;
  margin-left: [NN]px;
}

.header-title {
  font-family: '[Headline Font]', sans-serif;
  font-size: [NN]px;
  font-weight: 700;
  color: #FFFFFF;
  line-height: 1.2;
}

.header-subtitle {
  font-family: '[Font]', sans-serif;
  font-size: [NN]px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.9);
  margin-top: 4px;
}

.header-metadata {
  font-family: '[Font]', sans-serif;
  font-size: [NN]px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.8);
  text-transform: uppercase;
  margin-top: 4px;
}

.user-profile-btn {
  width: [NN]px;
  height: [NN]px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  cursor: pointer;
  transition: background-color 150ms;
}

.user-profile-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}
```

### 2.3 Sidebar

```css
/* DS-117 through DS-122 */
.sidebar {
  width: [NNN]px;
  height: calc(100vh - [header]px);
  background: #[XXXXXX];
  border-right: 1px solid #[XXXXXX];
  padding: [NN]px;
  overflow-y: auto;
  z-index: 50;
}

.sidebar-section {
  padding: [NN]px;
  margin-bottom: [NN]px;
}

.sidebar-title {
  font: [NN]px [Font] bold;
  color: #[XXXXXX];
  margin-bottom: [NN]px;
}
```

### 2.4 Buttons

```css
/* DS-401 through DS-407 */

/* Primary Button */
.btn-primary {
  height: [NN]px;
  padding: [N]px [NN]px;
  background: #[XXXXXX];
  color: #FFFFFF;
  border: none;
  border-radius: [N]px;
  font: bold [NN]px [Font];
  cursor: pointer;
  min-width: [NN]px;
  transition: all 150ms;
}

.btn-primary:hover {
  background: #[XXXXXX];
}

.btn-primary:active {
  background: #[XXXXXX];
}

.btn-primary:disabled {
  background: #[XXXXXX];
  color: #[XXXXXX];
  cursor: not-allowed;
}

.btn-primary:focus {
  outline: 2px solid #[XXXXXX];
  outline-offset: 2px;
}

/* Secondary Button (Outlined) */
.btn-secondary {
  height: [NN]px;
  padding: [N]px [NN]px;
  background: transparent;
  color: #[XXXXXX];
  border: 1px solid #[XXXXXX];
  border-radius: [N]px;
  font: bold [NN]px [Font];
  cursor: pointer;
}

.btn-secondary:hover {
  background: #[XXXXXX];
}

/* Ghost Button */
.btn-ghost {
  height: [NN]px;
  padding: [N]px [NN]px;
  background: transparent;
  color: #[XXXXXX];
  border: none;
  border-radius: [N]px;
  font: bold [NN]px [Font];
  cursor: pointer;
}

.btn-ghost:hover {
  background: #[XXXXXX];
}

/* [Application-Specific Button - e.g., Time Range] */
.time-btn {
  height: [NN]px;
  padding: 0 [NN]px;
  border: 1px solid #[XXXXXX];
  border-radius: [N]px;
  background: transparent;
  color: #[XXXXXX];
  font: bold [NN]px [Font];
  cursor: pointer;
}

.time-btn.active {
  background: #[XXXXXX];
  border-color: #[XXXXXX];
  color: #FFFFFF;
}

.time-btn:hover:not(.active) {
  background: #[XXXXXX];
}
```

### 2.5 Inputs

```css
/* DS-408 through DS-413 */

/* Text Input */
.input {
  height: [NN]px;
  padding: [NN]px [NN]px;
  border: 1px solid #[XXXXXX];
  border-radius: [N]px;
  background: #FFFFFF;
  font: [NN]px [Font];
  color: #[XXXXXX];
  width: 100%;
}

.input:focus {
  border: 2px solid #[XXXXXX];
  box-shadow: 0 0 0 3px rgba([R], [G], [B], 0.1);
  outline: none;
}

.input:disabled {
  background: #[XXXXXX];
  color: #[XXXXXX];
  cursor: not-allowed;
}

.input.error {
  border: 2px solid #[XXXXXX];
}

/* Search Input */
.search-container {
  position: relative;
  margin-bottom: [N]px;
}

.search-icon {
  position: absolute;
  left: [NN]px;
  top: 50%;
  transform: translateY(-50%);
  width: [NN]px;
  height: [NN]px;
  color: #[XXXXXX];
}

.search-input {
  width: 100%;
  height: [NN]px;
  padding: [NN]px [NN]px [NN]px [NN]px;  /* Extra left padding for icon */
  border: 1px solid #[XXXXXX];
  border-radius: [N]px;
}

/* Checkbox */
input[type="checkbox"] {
  width: [NN]px;
  height: [NN]px;
  accent-color: #[XXXXXX];
  border: 2px solid #[XXXXXX];
  border-radius: 2px;
  cursor: pointer;
}

/* Tailwind equivalent */
.checkbox {
  @apply h-5 w-5 rounded-sm border-2 border-gray-300
         text-[brand]-primary focus:ring-2 focus:ring-[brand]-primary
         focus:ring-offset-2;
}

/* Checkbox wrapper for touch target */
.checkbox-wrapper {
  padding: [NN]px;  /* Expand to 44x44 hit area */
}
```

### 2.6 [Application-Specific Component - e.g., Counter Badge]

```css
/* DS-5XXa through DS-5XXe */
.counter-badge {
  height: [NN]px;
  padding: [N]px [NN]px;
  background: #[XXXXXX];
  border: 1px solid #[XXXXXX];
  border-radius: [N]px;
  font: bold [NN]px [Font];
  color: #[XXXXXX];
}

.counter-badge.at-limit {
  background: #[XXXXXX];
  border-color: #[XXXXXX];
  color: #FFFFFF;
}
```

### 2.7 [Application-Specific Component - e.g., List Items]

```css
/* DS-5XXa through DS-5XXf */
.item-list {
  display: flex;
  flex-direction: column;
  gap: [N]px;
}

.item {
  height: [NN]px;
  padding: [N]px [NN]px;
  display: flex;
  align-items: center;
  gap: [NN]px;
  background: transparent;
  transition: background-color 150ms;
  cursor: pointer;
}

.item:hover {
  background: #[XXXXXX];
}

.item.selected {
  background: #[XXXXXX];
}
```

### 2.8 Dropdown

```css
.dropdown-button {
  height: [NN]px;
  padding: [N]px [NN]px [N]px [NN]px;
  border: 1px solid #[XXXXXX];
  border-radius: [N]px;
  background: #FFFFFF;
  font: [NN]px [Font];
  color: #[XXXXXX];
  cursor: pointer;
}

.dropdown-menu-item {
  height: [NN]px;
  padding: [NN]px [NN]px;
  background: #FFFFFF;
  color: #[XXXXXX];
  font: [NN]px [Font];
  cursor: pointer;
}

.dropdown-menu-item:hover,
.dropdown-menu-item.active {
  background: #[XXXXXX];
  color: #FFFFFF;
}
```

### 2.9 Tooltip

```css
/* DS-414 through DS-419 */
.tooltip {
  max-width: [NNN]px;
  background: rgba(0, 0, 0, 0.85);
  color: #FFFFFF;
  padding: [NN]px;
  border-radius: [N]px;
  font: [NN]px [Font];
  box-shadow: 0 4px 8px rgba(0,0,0,0.2);
  z-index: 400;
}
```

### 2.10 Widget Container

```css
.widget {
  background: #FFFFFF;
  border: 2px solid #[XXXXXX];
  border-radius: [N]px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  margin-bottom: [NN]px;
}

.widget-header {
  height: [NN]px;
  padding: 0 [NN]px;
  border-bottom: 1px solid #[XXXXXX];
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.widget-title {
  font: bold [NN]px [Font];
  color: #[XXXXXX];
}

.widget-content {
  padding: [NN]px;
}
```

### 2.11 Table

```css
.table {
  width: 100%;
  border-collapse: collapse;
  background: #FFFFFF;
  border: 1px solid #[XXXXXX];
  border-radius: [N]px;
}

.table-header {
  background: #[XXXXXX];
  font: bold [NN]px [Font];
  color: #[XXXXXX];
  padding: [NN]px [NN]px;
  border-bottom: 2px solid #[XXXXXX];
  text-align: left;
}

.table-row {
  min-height: [NN]px;
  padding: [NN]px [NN]px;
  border-bottom: 1px solid #[XXXXXX];
  font: [NN]px [Font];
  color: #[XXXXXX];
}

.table-row:hover {
  background: #[XXXXXX];
}

.table-row.selected {
  background: #[XXXXXX];
  border-left: [N]px solid #[XXXXXX];
}

.table-cell {
  padding: [NN]px [NN]px;
  vertical-align: middle;
}

/* Status indicators */
.status-dot {
  width: [NN]px;
  height: [NN]px;
  border-radius: 50%;
  display: inline-block;
  margin-right: [N]px;
}

.status-dot.good { background: #[XXXXXX]; }
.status-dot.warning { background: #[XXXXXX]; }
.status-dot.error { background: #[XXXXXX]; }
```

---

## 3. Visualization Library Configuration

### 3.1 Global Settings

```javascript
const chartInit = {
  renderer: 'canvas',  // or 'svg'
  useDirtyRect: true,
  locale: 'EN',
  devicePixelRatio: window.devicePixelRatio
};
```

### 3.2 Chart Options

```javascript
const chartOptions = {
  grid: {
    left: [NN],
    right: [NN],
    top: [NN],
    bottom: [NN],
    containLabel: true
  },
  xAxis: {
    type: '[type]',  // 'time', 'category', 'value'
    axisLabel: {
      formatter: [formatterFunction],
      color: '#[XXXXXX]',
      fontSize: [NN],
      fontFamily: '[Font]'
    },
    axisLine: {
      lineStyle: { color: '#[XXXXXX]' }
    }
  },
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(0, 0, 0, 0.85)',
    textStyle: {
      color: '#FFFFFF',
      fontSize: [NN],
      fontFamily: '[Font]'
    }
  },
  legend: {
    type: 'scroll',
    top: [NN],
    right: [NN],
    textStyle: {
      color: '#[XXXXXX]',
      fontSize: [NN],
      fontFamily: '[Font]'
    },
    itemWidth: [NN],
    itemHeight: [NN]
  },
  dataZoom: [{
    type: 'slider',
    bottom: [NN],
    height: [NN],
    fillerColor: 'rgba([R], [G], [B], 0.2)',
    borderColor: '#[XXXXXX]'
  }]
};
```

### 3.3 Multi-Axis Layout

```javascript
// Y-axes configuration pattern
// Alternating left/right positioning with offset

function generateYAxes(items) {
  return items.map((item, index) => {
    const isLeft = index % 2 === 0;
    const sideIndex = Math.floor(index / 2);

    return {
      position: isLeft ? 'left' : 'right',
      offset: sideIndex * [NN],  // e.g., 60px per axis
      name: `${item.name} (${item.unit})`,
      nameLocation: 'end',
      nameRotate: isLeft ? 0 : 90,
      nameTextStyle: {
        color: CHART_COLORS[index],
        fontSize: [NN],
        fontWeight: 'bold'
      },
      axisLine: {
        lineStyle: { color: CHART_COLORS[index] }
      }
    };
  });
}

// Example for 6 items:
const yAxisConfig = [
  { position: 'left', offset: 0 },    // Item 1
  { position: 'right', offset: 0 },   // Item 2
  { position: 'left', offset: 60 },   // Item 3
  { position: 'right', offset: 60 },  // Item 4
  { position: 'left', offset: 120 },  // Item 5
  { position: 'right', offset: 120 }, // Item 6
];
```

### 3.4 Special Rendering (Boolean/Alert/etc.)

```javascript
// Shaded intervals for boolean/alert states
const booleanSeries = {
  type: 'custom',
  name: '[Series Name]',
  renderItem: function(params, api) {
    const start = api.value(0);
    const end = api.value(1);
    const height = params.coordSys.height;

    return {
      type: 'rect',
      shape: {
        x: api.coord([start, 0])[0],
        y: 0,
        width: api.coord([end, 0])[0] - api.coord([start, 0])[0],
        height: height
      },
      style: {
        fill: '#[XXXXXX]',  // Alert/highlight color
        opacity: 0.15
      },
      z: 1  // Behind line series (z: 2)
    };
  },
  data: [
    // [startTimestamp, endTimestamp]
  ]
};
```

### 3.5 Chart Color Palette

```javascript
const CHART_COLORS = [
  '#[XXXXXX]', // Color 1 (Brand primary)
  '#[XXXXXX]', // Color 2 (Brand secondary)
  '#[XXXXXX]', // Color 3
  '#[XXXXXX]', // Color 4
  '#[XXXXXX]', // Color 5
  '#[XXXXXX]', // Color 6
  '#[XXXXXX]', // Color 7
  '#[XXXXXX]', // Color 8
  '#[XXXXXX]', // Color 9
  '#[XXXXXX]', // Color 10
];
```

---

## 4. ARIA Implementation

### 4.1 Chart Accessibility

```html
<div
  role="img"
  aria-label="[Chart description - e.g., Time-series chart showing Temperature, Pressure]"
  aria-describedby="chart-description"
>
  <canvas></canvas>
</div>
<div id="chart-description" class="sr-only">
  [Detailed description for screen readers]
  Use data table below for accessible view.
</div>
```

### 4.2 Interactive Element

```html
<button
  aria-label="[Action description - e.g., Toggle Temperature sensor, currently visible]"
  aria-pressed="true"
>
  <span aria-hidden="true">[Visual indicator]</span> [Label]
</button>
```

### 4.3 Form Control

```html
<label>
  <input
    type="checkbox"
    aria-label="[Selection description]"
    aria-describedby="[id]-desc"
  />
  <span id="[id]-desc">[Descriptive text]</span>
</label>
```

### 4.4 Live Regions

```html
<!-- Polite (non-urgent updates) -->
<div role="status" aria-live="polite" aria-atomic="true" class="sr-only">
  <!-- Announce: "Loaded 3 items. View updated." -->
</div>

<!-- Assertive (urgent errors/alerts) -->
<div role="alert" aria-live="assertive" class="sr-only">
  <!-- Announce: "Error loading data. Please retry." -->
</div>
```

### 4.5 Counter/Status Badge

```html
<span aria-live="polite">[N]/[Max] selected</span>
```

---

## 5. Responsive Breakpoints

```css
/* Mobile (< [NNN]px) */
@media (max-width: [NNN]px) {
  .sidebar {
    width: 100%;
    position: fixed;
    top: 0;
    left: 0;
    z-index: 100;
  }

  .chart-container {
    min-height: [NNN]px;
  }

  body {
    font-size: [NN]px;  /* Reduced from desktop */
  }

  .btn, .input {
    min-height: [NN]px;  /* Larger touch targets */
  }
}

/* Tablet Portrait ([NNN]px - [NNNN]px) */
@media (min-width: [NNN]px) and (max-width: [NNNN]px) {
  .sidebar {
    width: 80%;
    max-width: [NNN]px;
    position: fixed;
    top: 0;
    left: 0;
    z-index: 100;
  }

  .sidebar-backdrop {
    background: rgba(0, 0, 0, 0.3);
  }
}

/* Tablet Landscape ([NNNN]px - [NNNN]px) */
@media (min-width: [NNNN]px) and (max-width: [NNNN]px) {
  .sidebar {
    width: [NNN]px;
  }

  .sidebar.collapsed {
    width: 0;
    padding: 0;
    overflow: hidden;
  }
}

/* Desktop (≥ [NNNN]px) */
@media (min-width: [NNNN]px) {
  .sidebar {
    width: [NNN]px;
  }
}

/* Typography scale */
:root {
  --text-h1: [NN]px;
  --text-body: [NN]px;
  --text-small: [NN]px;
}

@media (max-width: [NNN]px) {
  :root {
    --text-h1: [NN]px;
    --text-body: [NN]px;
    --text-small: [NN]px;
  }
}
```

---

## 6. Z-Index Stack

```css
:root {
  --z-base: 0;
  --z-sticky: 10;
  --z-sidebar: 50;
  --z-header: 100;
  --z-dropdown: 200;
  --z-modal: 300;
  --z-tooltip: 400;
  --z-notification: 500;
}
```

---

## 7. Focus States

```css
/* Standard focus indicator */
:focus-visible {
  outline: 2px solid #[XXXXXX];
  outline-offset: 2px;
  border-radius: [N]px;
}

/* Never remove focus without replacement */
/* .no-outline { outline: none; } - NEVER DO THIS */
```

---

## 8. Icon Mapping

| Documentation Placeholder | Implementation |
|---------------------------|----------------|
| [Emoji/Text] Search | `<[IconComponent] />` |
| [Emoji/Text] Settings | `<[IconComponent] />` |
| [Emoji/Text] Info | `<[IconComponent] />` |
| [Emoji/Text] Download | `<[IconComponent] />` |
| [Emoji/Text] Share | `<[IconComponent] />` |
| [Emoji/Text] Reset | `<[IconComponent] />` |

All icons from `@[icon-package]/[variant]`.

---

## 9. Animation Timing

```css
/* Standard transitions */
.transition-default {
  transition: all 150ms ease-in-out;
}

/* Icon rotation */
.transition-rotate {
  transition: transform 200ms ease-in-out;
}

/* Button press */
.btn:active {
  transform: scale(0.95);
  transition: transform 150ms;
}

/* Expanded/collapsed state */
.expandable {
  transition: height 200ms ease-in-out;
}
```

---

## 10. Touch Gestures (Mobile)

| Gesture | Action |
|---------|--------|
| Pinch | [Action - e.g., Zoom in/out] |
| Two-finger drag | [Action - e.g., Pan] |
| Long press | [Action - e.g., Show tooltip] |
| Swipe left | [Action - e.g., Navigate forward] |
| Swipe right | [Action - e.g., Navigate backward] |

---

**Related**: [design-system.md](./design-system.md)
