# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/use-cases/UC-NN/`
**Prerequisites**: plan.md (required), UC-NN-*.md, research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from use case directory (/specs/use-cases/UC-NN/)
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure, work streams
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Assign work stream tag from plan.md
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Group related tasks by feature area
5. Number tasks sequentially (T001, T002...)
6. List task and stream dependencies
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Delete section: Execution Flow (main)
10. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [STREAM] [P?] Description`
- **[STREAM]**: Work stream tag from plan.md ([API], [UI], [DB], [TEST], [INFRA], [INT])
- **[P]**: Can run in parallel (different files, no dependencies within same stream)
- Include exact file paths in descriptions
- Tasks with same stream can be assigned to same executor
- Tasks with different streams and [P] can run in parallel across executors

## Path Conventions
- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

## Implementation Workflow (per /ai1st-dev-implement)

1. **Load Context**: Read `tasks.md`, `plan.md`, `data-model.md`, `contracts/`, `specs/design/design-system.md`, `specs/design/design-system-tech-spec.md` (for implementation), `specs/use-cases/use-cases-overview.md`, `specs/enablers/enablers-overview.md`
2. **Setup Verification**: Create/verify ignore files (`.gitignore`, `.dockerignore`, etc.) based on tech stack
3. **Parse Tasks**: Extract phases, dependencies, parallel markers `[P]`, and execution flow
4. **Execute**: Phase-by-phase, respect dependencies, write tests (don't run), mark `[X]` on completion
5. **Validate**: Confirm all tasks done, features match spec
6. **Update Overview**: Update overview file status in Phase 3.6 after verification complete

## Phase 3.1: Setup
- [ ] T001 [INFRA] Create project structure per implementation plan
- [ ] T002 [INFRA] Initialize [language] project with [framework] dependencies
- [ ] T003 [INFRA] [P] Configure linting and formatting tools
- [ ] T004 [INT] [P] **Check for implementation conflicts**: Review existing code in related features (from plan.md Implementation Conflicts section) to ensure no behavioral conflicts before starting implementation

## Phase 3.2: Tests
<!-- Constitution Reference: Tests MUST cover implemented functionality -->
<!-- Frontend: Tests validate component-page integration -->
- [ ] T005 [API] [P] Contract test POST /api/users in tests/contract/test_users_post.py
- [ ] T006 [API] [P] Contract test GET /api/users/{id} in tests/contract/test_users_get.py
- [ ] T007 [TEST] [P] Integration test user registration in tests/integration/test_registration.py
- [ ] T008 [TEST] [P] Integration test auth flow in tests/integration/test_auth.py

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T009 [API] [P] User model in src/models/user.py
- [ ] T010 [API] [P] UserService CRUD in src/services/user_service.py
- [ ] T011 [API] [P] CLI --create-user in src/cli/user_commands.py
- [ ] T012 [API] POST /api/users endpoint
- [ ] T013 [API] GET /api/users/{id} endpoint
- [ ] T014 [API] Input validation
- [ ] T015 [API] Error handling and logging

## Phase 3.4: Integration
- [ ] T016 [INT] Connect UserService to DB
- [ ] T017 [API] Auth middleware
- [ ] T018 [API] Request/response logging
- [ ] T019 [API] CORS and security headers

## Phase 3.5: Polish
- [ ] T020 [TEST] [P] Unit tests for validation in tests/unit/test_validation.py
- [ ] T021 [TEST] Performance tests (<200ms)
- [ ] T022 [API] [P] Update docs/api.md
- [ ] T023 [API] Remove duplication
- [ ] T024 [TEST] Run manual testing checklist

## Phase 3.6: Documentation Updates
<!-- CRITICAL: Update overview files to reflect implementation status -->
**Use Cases:**
- [ ] T024 [DOC] Update use-cases-overview.md status (✅ Human Verified, 🟢 Verified, 🔵 Implemented, 🟡 Deferred) in specs/use-cases/use-cases-overview.md
- [ ] T025 [DOC] Update detailed UC-XX section with status note if deferred or blocked

**Enablers:**
- [ ] T026 [DOC] Update enablers-overview.md status (✅ Human Verified, 🟢 Verified, 🔵 Implemented) in specs/enablers/enablers-overview.md

## Dependencies
*List task dependencies as simple references*

### Task Dependencies
- T004 (check conflicts) → should complete before tests (T005-T008)
- Tests (T005-T008) → before implementation (T009-T015)
- T009 → blocks T010, T016
- T017 → blocks T019
- Implementation (T009-T015) → before polish (T020-T024)

### Work Stream Dependencies
*Cross-stream dependencies from plan.md*
- [API] tasks can start immediately after setup
- [UI] tasks depend on [API] endpoints (can mock initially)
- [TEST] integration tests depend on [API] and [UI] implementations
- [INT] tasks coordinate across streams

## Parallel Execution Examples

### Same Stream Parallel (within one executor)
```
# [API] stream tasks T004-T005 (same executor):
Task: "[API] Contract test POST /api/users in tests/contract/test_users_post.py"
Task: "[API] Contract test GET /api/users/{id} in tests/contract/test_users_get.py"
```

### Cross-Stream Parallel (multiple executors)
```
# Launch across streams simultaneously:
Executor 1 (API): "[API] T004 Contract test POST /api/users"
Executor 2 (TEST): "[TEST] T006 Integration test registration"
Executor 3 (UI): "[UI] T025 Create user list component"
```

## Notes
- [P] tasks = different files, no dependencies within same stream
- [STREAM] tags enable parallel execution across multiple executors
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts, wrong stream assignment

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → [API] contract test task [P]
   - Each endpoint → [API] implementation task

2. **From Data Model**:
   - Each entity → [API] or [DB] model creation task [P]
   - Relationships → [API] service layer tasks

3. **From User Stories**:
   - Each story → [TEST] integration test [P]
   - UI flows → [UI] component tasks

4. **Stream Assignment**:
   - Backend endpoints, services, DTOs → [API]
   - Frontend components, pages, hooks → [UI]
   - Database schemas, migrations → [DB]
   - E2E tests, integration tests → [TEST]
   - IaC, CI/CD, deployment → [INFRA]
   - Cross-stream coordination → [INT]

5. **Ordering**:
   - Setup → Models → Services → Endpoints → Tests → Polish
   - Stream dependencies from plan.md
   - Task dependencies block parallel execution within stream

## Task Completeness Checklist
*GATE: Verified before implementation begins*

- [ ] All acceptance criteria from plan.md have corresponding tasks
- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All acceptance criteria have corresponding test tasks
- [ ] Parallel tasks are truly independent (different files)
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task
- [ ] Each task has correct work stream tag
- [ ] Stream dependencies match plan.md Work Streams section
