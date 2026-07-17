# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Use case specification from `/specs/use-cases/UC-NN/UC-NN-*.md`

## Execution Flow (/plan command scope)

```
1. Load use case specification from Input path
   → Path: /specs/use-cases/UC-NN/UC-NN-*.md
   → If not found: ERROR "No use case specification at {path}"

2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context
   → Set Structure Decision based on project type

3. Check for Implementation Conflicts (MANDATORY)
   3.1 Load all existing implementation plans:
       → Find all specs/use-cases/*/plan.md files
       → Find all specs/enablers/*/plan.md files
       → Load implementation details from each plan
   3.2 Check current spec requirements against existing implementations:
       → Compare functional requirements against implemented features
       → Check if this feature will override existing code behavior
       → Check if existing code needs modification to accommodate this feature
       → Check for conflicting defaults, validation rules, or data formats
   3.3 Document implementation conflicts found:
       → For each conflict: [NEW-REQ] will override [EXISTING-IMPL in UC-XX/EN-XX]
       → Describe what existing code will be affected
       → Propose resolution (refactor existing, modify new req, or coordinate changes)
   3.4 If conflicts found:
       → Document in "Implementation Conflicts" section below
       → Add tasks in Phase 2 to verify/refactor existing code
       → Mark plan status as "Has Implementation Conflicts - Coordination Required"
   3.5 If no conflicts found:
       → Document: "Implementation conflict check completed - no conflicts found"
       → Proceed to next step

4. Constitution Check (GATE)
   → Fill checklist based on constitution document
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"

5. Phase 0: Research → research.md
   → Resolve all NEEDS CLARIFICATION items
   → If unknowns remain: ERROR "Resolve unknowns"

6. Phase 1: Design → data-model.md, contracts/
   → Re-evaluate Constitution Check after design
   → If new violations: Refactor design, return to step 6
   → Update stack constitution with tech stack details

7. Phase 2: Task Planning → Describe approach only
   → DO NOT create tasks.md (done by /tasks command)
   → Include tasks to check for implementation conflicts with existing code

8. Complete remaining sections
   → Dependencies Analysis (prerequisites + provides)
   → Use Case Specific NFRs (extract from spec)
   → Acceptance Criteria (with BRD traceability)

9. STOP - Ready for /tasks command
```

## Summary
[Extract from use case spec or feature spec: primary requirement + technical approach from research]

## Implementation Conflicts
*Auto-populated during Execution Flow step 3 - Check for Implementation Conflicts*

**Status**: [No Conflicts Found | Has Conflicts - Coordination Required]

**Conflicts Identified**: *(if any)*
<!-- Format: [NEW-REQ] will override [EXISTING-IMPL in UC-XX/EN-XX] - Description - Resolution Plan -->
<!-- Example: FR-15.1.1 (default "Last 24 hours") will override UC-03 implementation (currently defaults to "Last 7 days") - Resolution: Update UC-03 implementation to align with UC-15 requirement -->

**Resolution Tasks**: *(if conflicts found)*
<!-- List specific tasks that will be added to Phase 2 to handle conflicts -->
<!-- Example: T001 - Review and refactor UC-03 TimeRangePicker default initialization logic -->

**Conflict Check Date**: [YYYY-MM-DD]
**Checked Against**: [List of plan.md files reviewed: UC-01, UC-02, ..., EN-01, EN-02, ...]

---

## Technical Context
**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

<!--
  INSTRUCTIONS: Populate checklist from relevant constitution files based on feature scope:
  - Frontend features: Extract principles from `../.ai_project_memory/constitution-frontend.md`
  - Backend features: Extract principles from `../.ai_project_memory/constitution-backend.md`
  - Cross-cutting: Include principles from both + `../.ai_project_memory/constitution.md`

  Format each principle as: - [ ] **[Section.Subsection]**: [Principle summary]
  Example: - [ ] **I.1**: React 19 + TypeScript (strict mode enabled)
-->

**Applicable Constitution**: [frontend / backend / both]
**Source Documents**:
- `../.ai_project_memory/constitution.md` (core principles)
- `../.ai_project_memory/constitution-[frontend|backend].md` (stack-specific)

### Compliance Checklist
*Extract relevant principles from constitution documents above*

- [ ] **[X.X]**: [Principle description from constitution]
- [ ] **[X.X]**: [Principle description from constitution]
- [ ] **[X.X]**: [Principle description from constitution]

**Violations Found**: [List any deviations with justification]
**Remediation**: [How violations will be addressed]

## Project Structure

### Documentation (this use case)
```
specs/use-cases/UC-NN/
├── UC-NN-*.md           # Use case specification (input)
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->
```
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Update stack constitution** (incremental, O(1) operation):
   - Read the relevant `.ai_project_memory/constitution-frontend.md` or `constitution-backend.md`
   - Extract technology stack from Technical Context above:
     - Language/Version + Primary Dependencies = tech stack entry
     - Storage (if not N/A) = additional tech entry
   - Add to Technology Stack table (if not already present):
     - Format: `| {Layer} | {Technology} | {Version} | {Purpose} |`
     - Example: `| Framework | FastAPI | 0.104+ | REST API framework |`
     - Example: `| ORM | SQLAlchemy | 2.0+ | Database access layer |`
   - Add to Commands section if new build/test commands introduced:
     - Example: `alembic upgrade head  # Run database migrations`
   - Preserve any manual additions between `<!-- manual additions start -->` and `<!-- manual additions end -->` markers

**Output**: data-model.md, /contracts/*, failing tests, updated stack constitution

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.ai/2_templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model)
- Each contract → contract test task [P]
- Each entity → model creation task [P]
- Each user story → integration test task
- Implementation tasks for each component

**Ordering Strategy**:
- Dependency order: Models before services before UI
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 25-30 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Dependencies Analysis

### Prerequisites
*What must exist before this feature can be implemented*

| Dependency | Source | Status | Notes |
|------------|--------|--------|-------|
| [e.g., Container Apps] | [EN-03] | [Required/Optional] | [Deployment target] |
| [e.g., API endpoint] | [UC-XX] | [Required/Optional] | [Data source] |

### Provides (to other features)
*What this feature enables for downstream use cases*

| Output | Used By | Description |
|--------|---------|-------------|
| [e.g., Layout components] | [UC-02 to UC-20] | [Shared app shell] |
| [e.g., Auth context] | [All use cases] | [User authentication state] |

---

## Work Streams

*Define work streams to enable parallel execution by multiple resources (developers, AI agents, specialists).*

<!--
  INSTRUCTIONS: Identify which work streams this feature requires.
  - Each stream represents an independent area of work
  - Tasks are tagged with stream identifiers for assignment
  - Streams with no cross-dependencies can execute in parallel
-->

### Stream Definitions

| Stream | Tag | Scope | Typical Executor |
|--------|-----|-------|------------------|
| Backend API | [API] | Controllers, services, DTOs, API tests | Backend dev / API agent |
| Frontend UI | [UI] | Components, pages, hooks, UI tests | Frontend dev / UI agent |
| Database | [DB] | Schemas, migrations, queries | Backend dev / DB agent |
| Testing | [TEST] | E2E tests, integration tests, test infra | QA / Test agent |
| Infrastructure | [INFRA] | IaC, CI/CD, deployment configs | DevOps / Infra agent |
| Integration | [INT] | Cross-stream coordination, contracts | Full-stack dev / Lead |

### Active Streams for This Feature
*Check streams that apply to this feature*

- [ ] [API] - Backend endpoints and services
- [ ] [UI] - Frontend components and pages
- [ ] [DB] - Database changes
- [ ] [TEST] - Test infrastructure
- [ ] [INFRA] - Infrastructure changes
- [ ] [INT] - Integration coordination

### Stream Dependencies
*List dependencies between streams (simple references, not graph)*

- [UI] depends on: [API] endpoints ready (can mock initially)
- [TEST] depends on: [API] and [UI] implementations
- [INT] depends on: All streams ready for integration testing

---

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

---

## Use Case Specific NFRs

*Extract NFRs specific to this feature from the use case specification. Include only measurable, testable requirements unique to this feature's functionality.*

*BRD NFR references: [NFR-xx (Requirement Name)] - if applicable*
*Design System references: [DS-xxx (Component/Pattern)] - if applicable*

### Performance *(if applicable)*
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| [e.g., Initial load] | [< 10 seconds] | [Lighthouse CI] |

### Scalability *(if applicable)*
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| [e.g., Concurrent users] | [1-5 users] | [Load testing] |

*Note: Generic project NFRs are defined in `../.ai_project_memory/constitution.md`. Only include UC-specific NFRs here.*

---

## Acceptance Criteria

*Definition of Done for this feature. Extract from use case specification and organize by functional area.*

### Instructions (remove in final plan)

**CRITICAL: Every criterion MUST have a traceability ID prefix.** No untagged criteria allowed.

#### Traceability ID Types
| Tag Format | Source | When to Use |
|------------|--------|-------------|
| `[FR-xxxx.x]` | BRD.md | Functional requirement from Business Requirements Document |
| `[NFR-xx]` | BRD.md | Non-functional requirement from BRD |
| `[DS-xxx]` | design-system.md | Design system component or pattern |
| `[UC-NN-IMPL-xx]` | This plan | Implementation detail NOT in BRD (use case specific) |
| `[EN-NN-IMPL-xx]` | This plan | Implementation detail NOT in BRD (enabler specific) |

#### Tag Selection Decision Guide

**Choose the tag based on WHAT the criterion describes:**

| Criterion Type | Tag | Examples |
|----------------|-----|----------|
| **User action or system behavior** (what the system does) | `[FR-xxxx.x]` | "User can zoom by dragging", "System saves configuration" |
| **Quality attribute** (how well, applies across features) | `[NFR-xx]` | "< 200ms response", "Smooth animation (> 45 FPS)", "99.9% uptime" |
| **Visual/interaction pattern** (how it looks/feels) | `[DS-xxx]` | "Selection highlight appears", "Button uses primary color", "8px spacing" |
| **Implementation detail** (derived, not in BRD) | `[IMPL-xx]` | "Y-axes rescale to fit data", "Cache invalidated on update" |

**Decision Flow:**
1. Is it a **specific functional behavior** stated in BRD? → Use `[FR-xxxx.x]`
2. Is it about **visual design, UI components, or interaction patterns**? → Use `[DS-xxx]`
3. Is it about **performance, reliability, scalability, or accessibility**? → Use `[NFR-xx]`
4. Is it **derived from requirements** but not explicitly stated? → Use `[IMPL-xx]`

**Common NFR Categories** (check BRD.md NFR section):
- Performance: response times, frame rates, throughput
- Reliability: uptime, error handling, data integrity
- Scalability: concurrent users, data volume limits
- Accessibility: WCAG compliance, keyboard navigation
- Security: authentication, authorization, encryption

#### Steps
1. Copy Functional Requirements from use case spec, grouped by category
2. Copy Use Case Specific NFRs from section above
3. **Tag every criterion** with appropriate ID:
   - First, check BRD.md for matching `[FR-xxxx.x]` or `[NFR-xx]`
   - Then, check design-system.md for matching `[DS-xxx]`
   - If no BRD/DS match exists, use `[UC-NN-IMPL-xx]` or `[EN-NN-IMPL-xx]` with running number
4. Ensure each criterion is testable and verifiable
5. Remove this instruction block

#### IMPL Tag Usage
- Use `IMPL` tags for implementation details derived from requirements but not explicitly stated in BRD
- Running number resets per use case/enabler (e.g., UC-07-IMPL-01, UC-07-IMPL-02)
- Document why IMPL criteria exist (derived from which parent requirement)

**Example** (UC-07 Zoom Operation):
```markdown
### Zoom Operation
- [FR-1006.1] User can zoom by clicking and dragging on graph    ← functional behavior
- [DS-507] Visual selection highlight appears during drag         ← visual pattern
- [NFR-01] Zoom completes in < 200ms after mouse release          ← performance quality
- [NFR-01] Zoom animation smooth (> 45 FPS)                       ← performance quality
- [UC-07-IMPL-01] Y-axes rescale to fit zoomed data (derived from FR-1006) ← impl detail
```

### BRD Traceability
*BRD references: [FR-xxxx (Requirement Name), FR-yyyy (Requirement Name)]*
*Design System references: [DS-xxx (Layout), DS-yyy (Component)] - See [design-system.md](../../design/design-system.md)*
*Implementation-specific: [UC-NN-IMPL-xx] or [EN-NN-IMPL-xx] for derived requirements*

*Note: For technical enabler features without direct BRD requirements, document which BRD requirements the enabler supports indirectly.*

### [Category 1 - e.g., Layout]
- [DS-xxx] [Criterion description with measurable target]
- [FR-xxxx.x] [Criterion description]

### [Category 2 - e.g., Authentication]
- [FR-xxxx.x] [Criterion description]
- [NFR-xx] [Performance/accessibility criterion]
- [UC-NN-IMPL-xx] [Implementation detail derived from FR-xxxx]

### [Category 3 - e.g., Performance]
- [NFR-xx] [Performance target with measurement method]

---
*Based on Constitution - See `../.ai_project_memory/constitution.md`*
