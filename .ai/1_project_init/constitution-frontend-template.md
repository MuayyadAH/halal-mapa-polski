# {PROJECT} Frontend Development Constitution

**Purpose**: Self-contained frontend development guide — tech stack, commands, patterns, and standards.

---

## I. Technology Stack

### 1.1 Current Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Framework** | {CURRENT_UI_FRAMEWORK} | {CURRENT_UI_VERSION} | UI framework |
| **Language** | {CURRENT_UI_LANGUAGE} | - | UI language |
| **State Management** | {CURRENT_STATE_MANAGEMENT} | - | Application state |
| **Controls** | {CURRENT_CONTROLS} | - | UI component library |
| **Styling** | {CURRENT_STYLING} | - | CSS framework |
| **Build** | {CURRENT_BUILD_TOOL} | - | Build tool |

### 1.2 Target Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Framework** | {TARGET_UI_FRAMEWORK} | {TARGET_UI_VERSION} | Modern SPA |
| **Language** | {TARGET_UI_LANGUAGE} | - | Type-safe development |
| **State Management** | {TARGET_STATE_MANAGEMENT} | - | Application state |
| **Styling** | {TARGET_STYLING} | - | Component styling |
| **Build** | {TARGET_BUILD_TOOL} | - | Fast builds |
| **Testing** | {TARGET_E2E_FRAMEWORK} | - | E2E testing |

<!-- manual additions start -->
<!-- manual additions end -->

---

## II. Commands

### Prerequisites
- {CURRENT_IDE} (current)
- {TARGET_BUILD_TOOL} (target)

### Build

```bash
# Build solution (includes UI projects)
{BUILD_COMMAND}
```

### Test

```bash
# Unit tests
{FE_UNIT_TEST_COMMAND}

# E2E tests
{FE_E2E_TEST_COMMAND}

# Lint
{FE_LINT_COMMAND}
```

---

## III. Code Structure

```
{SOURCE_ROOT}/
├── {FRONTEND_DIR}/
│   ├── {FE_COMPONENTS}/         # UI components
│   ├── {FE_PAGES}/              # Page views
│   ├── {FE_SERVICES}/           # API clients
│   ├── {FE_STATE}/              # State management
│   └── {FE_STYLES}/             # Stylesheets
├── Common/
│   └── {ControlsLibrary}/       # Shared UI controls
└── test/
    └── {FE_TEST_DIR}/           # Frontend tests
```

---

## IV. UI Architecture

### 4.1 UI Patterns
- **{UI_PATTERN_1}**: {UI_PATTERN_1_DESCRIPTION}
- **{UI_PATTERN_2}**: {UI_PATTERN_2_DESCRIPTION}
- **{UI_PATTERN_3}**: {UI_PATTERN_3_DESCRIPTION}
- **{UI_PATTERN_4}**: {UI_PATTERN_4_DESCRIPTION}

### 4.2 Controls Library
- Custom control library for common UI patterns
- Location: `{SOURCE_ROOT}/Common/{ControlsLibrary}/`

---

## V. State Management

### 5.1 Current
- **{STATE_TYPE_1}**: {STATE_TYPE_1_DESCRIPTION}
- **{STATE_TYPE_2}**: {STATE_TYPE_2_DESCRIPTION}
- **{STATE_TYPE_3}**: {STATE_TYPE_3_DESCRIPTION}

### 5.2 Target
- **Server State**: {TARGET_SERVER_STATE}
- **URL State**: {TARGET_URL_STATE}
- **Local State**: {TARGET_LOCAL_STATE}

---

## VI. Code Quality

### 6.1 Current Code
- Follow existing patterns in {CURRENT_UI_FRAMEWORK} codebase
- Maintain consistent naming conventions
- Keep UI logic files focused

### 6.2 Future Code
- **Feature-based structure**: Organize by feature/domain
- **Component composition**: Small, composable components
- **TypeScript strict mode**: Enable all strict checks (if applicable)

---

## VII. Accessibility

- WCAG 2.1 AA compliance target
- Semantic HTML elements
- Keyboard navigation support
- Screen reader compatibility

---

## VIII. Testing

### 8.1 Current
- {CURRENT_FE_TESTING_APPROACH}

### 8.2 Target
- Unit tests: {TARGET_UNIT_TEST_FRAMEWORK}
- Integration tests: {TARGET_INTEGRATION_TEST_FRAMEWORK}
- E2E tests: {TARGET_E2E_FRAMEWORK}

---

## IX. Anti-Patterns (Avoid)

### Current {CURRENT_UI_FRAMEWORK}
- {FE_ANTIPATTERN_1}
- {FE_ANTIPATTERN_2}
- {FE_ANTIPATTERN_3}

### Future {TARGET_UI_FRAMEWORK}
- {FE_TARGET_ANTIPATTERN_1}
- {FE_TARGET_ANTIPATTERN_2}
- {FE_TARGET_ANTIPATTERN_3}

---

**Related Documents**:
- [Architecture](./architecture.md) - System architecture and integration points
- [General Overview](./general-overview.md) - Project overview
- [Backend Constitution](./constitution-backend.md) - Backend principles
