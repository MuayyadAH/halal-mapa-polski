# {PROJECT} Backend Development Constitution

**Purpose**: Self-contained backend development guide — tech stack, commands, patterns, and standards.

---

## I. Technology Stack

### 1.1 Current Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Framework** | {CURRENT_FRAMEWORK} | {CURRENT_FRAMEWORK_VERSION} | Application runtime |
| **Language** | {CURRENT_LANGUAGE} | {CURRENT_LANGUAGE_VERSION} | Backend language |
| **API** | {CURRENT_API} | - | {CURRENT_API_DESCRIPTION} |
| **Data Access** | {CURRENT_DATA_ACCESS} | - | Database wrapper |
| **Database** | {CURRENT_DATABASE} | {CURRENT_DATABASE_VERSION} | Primary data store |
| **Testing** | {TEST_FRAMEWORK} | - | Unit testing |

### 1.2 Target Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Framework** | {TARGET_FRAMEWORK} | {TARGET_FRAMEWORK_VERSION} | Modern runtime |
| **Language** | {TARGET_LANGUAGE} | {TARGET_LANGUAGE_VERSION} | Modern language |
| **API** | {TARGET_API} | - | {TARGET_API_DESCRIPTION} |
| **ORM** | {TARGET_ORM} | - | Type-safe data access |
| **Database** | {TARGET_DATABASE} | {TARGET_DATABASE_VERSION} | Modern RDBMS |
| **Hosting** | {TARGET_HOSTING} | - | Cloud hosting |
| **Testing** | {TARGET_TEST_FRAMEWORK} | - | Unit and E2E testing |

<!-- manual additions start -->
<!-- manual additions end -->

---

## II. Commands

### Prerequisites
- {IDE}
- {SDK}
- {DATABASE_CLIENT}
- Git

### Build

```bash
# Build main solution
{BUILD_COMMAND}

# Build specific services
{BUILD_SERVICES_COMMAND_1}
{BUILD_SERVICES_COMMAND_2}

# Build tools
{BUILD_TOOLS_COMMAND}
```

### Test

```bash
# Run all tests
{TEST_COMMAND}

# Run specific test project with output
{TEST_SPECIFIC_COMMAND}
```

### Package Management

```bash
# Restore packages
{RESTORE_COMMAND}

# Clean build artifacts
{CLEAN_COMMAND}
```

---

## III. Code Structure

### Source

```
{SOURCE_ROOT}/
├── src/
│   ├── Common/
│   │   ├── {CommonLibrary}/           # Shared utilities
│   │   ├── {DataAccessLibrary}/       # Database wrapper
│   │   └── {ControlsLibrary}/         # UI controls
│   ├── {API_DIR}/
│   │   ├── {Service1}/               # {Service1_DESCRIPTION}
│   │   └── {Service2}/               # {Service2_DESCRIPTION}
│   ├── {SYNC_DIR}/
│   │   ├── {SyncAgent1}/             # {SyncAgent1_DESCRIPTION}
│   │   └── {SyncAgent2}/             # {SyncAgent2_DESCRIPTION}
│   └── Tools/
│       ├── {Tool1}/                   # {Tool1_DESCRIPTION}
│       └── {Tool2}/                   # {Tool2_DESCRIPTION}
└── test/
    └── {TestProject}/
```

### Database

```
{DB_ROOT}/
├── functions/     # SQL functions
├── packages/      # {DB_LANGUAGE} packages
├── procedures/    # Stored procedures
├── tables/        # Table definitions
└── views/         # Database views
```

---

## IV. API Design

### 4.1 Current
- **{CURRENT_API_TYPE}**: {CURRENT_API_DESCRIPTION}
- **Location**: `{SOURCE_ROOT}/{API_DIR}/`
  - `{Service1}` - {Service1_DESCRIPTION}
  - `{Service2}` - {Service2_DESCRIPTION}

### 4.2 Target
- **{TARGET_API_TYPE}**: {TARGET_API_DESCRIPTION}
- **RATIONALE**: {TARGET_API_RATIONALE}

---

## V. Data Access

### 5.1 Current Architecture
- **{DataAccessLibrary}**: {DATA_ACCESS_DESCRIPTION}
- **{CURRENT_ORM}**: {CURRENT_ORM_DESCRIPTION}
- **Location**: `{SOURCE_ROOT}/Common/{DataAccessLibrary}/`

### 5.2 Database Layer
- **RDBMS**: {CURRENT_DATABASE}
- **Data Model**: {DATA_MODEL_TYPE}
- **Business Logic**: {DB_LOGIC_DESCRIPTION}
- **Location**: `{DB_ROOT}/`

### 5.3 Target Architecture
- **{TARGET_ORM}**: For {TARGET_DATABASE} access
- **{TARGET_DATA_PATTERN}**: {TARGET_DATA_PATTERN_DESCRIPTION}
- **RATIONALE**: {TARGET_DATA_RATIONALE}

---

## VI. Security

### 6.1 Connection Management
- **NEVER** store connection strings in code or configuration committed to git
- Use environment-specific configuration files
- Database credentials managed via secure configuration

### 6.2 Data Protection
- Handle PII and sensitive data with care
- Log errors without exposing sensitive data
- Validate all external input

---

## VII. Error Handling

### 7.1 Logging
- Use structured logging with context
- Log operation name, timestamp, relevant identifiers
- **NEVER** log credentials or sensitive PII

### 7.2 Error Responses
- Return meaningful error messages to callers
- Include error codes for programmatic handling
- Log full details server-side for debugging

---

## VIII. Testing

### 8.1 Unit Testing
- Framework: {TEST_FRAMEWORK}
- Location: `{SOURCE_ROOT}/test/`
- Target: Cover business logic in services

### 8.2 Integration Testing
- {INTEGRATION_TEST_APPROACH}
- {INTEGRATION_TEST_TOOLS}

---

## IX. Anti-Patterns (Avoid)

- {BE_ANTIPATTERN_1}
- {BE_ANTIPATTERN_2}
- {BE_ANTIPATTERN_3}
- {BE_ANTIPATTERN_4}
- {BE_ANTIPATTERN_5}

---

**Related Documents**:
- [Architecture](./architecture.md) - System architecture and integration points
- [General Overview](./general-overview.md) - Project overview
- [Frontend Constitution](./constitution-frontend.md) - Frontend principles
