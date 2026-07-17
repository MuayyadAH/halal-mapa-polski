---
name: ai1st-dev-test
description: "Execute a specific test task from test plan"
disable-model-invocation: true
---


<!-- Nortal Enhancement: Separated testing phase from implementation for better control and clarity -->
## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

<!-- Nortal Enhancement: Updated script path from .specify/ to .ai/ for Nortal framework compatibility -->
1. Run `.ai/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").
<!-- END Nortal Enhancement -->

2. **Check test checklists status** (if FEATURE_DIR/checklists/test*.md exists):
   - Scan test-related checklist files in the checklists/ directory
   - For each test checklist, count:
     * Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
     * Completed items: Lines matching `- [X]` or `- [x]`
     * Incomplete items: Lines matching `- [ ]`
   - Create a status table:
     ```
     | Test Checklist | Total | Completed | Incomplete | Status |
     |----------------|-------|-----------|------------|--------|
     | test-unit.md   | 15    | 15        | 0          | ✓ PASS |
     | test-e2e.md    | 8     | 5         | 3          | ✗ FAIL |
     ```
   - Calculate overall status:
     * **PASS**: All test checklists have 0 incomplete items
     * **FAIL**: One or more test checklists have incomplete items

   - **If any test checklist is incomplete**:
     * Display the table with incomplete item counts
     * **STOP** and ask: "Some test checklists are incomplete. Do you want to proceed with testing anyway? (yes/no)"
     * Wait for user response before continuing
     * If user says "no" or "wait" or "stop", halt execution
     * If user says "yes" or "proceed" or "continue", proceed to step 3

   - **If all test checklists are complete**:
     * Display the table showing all checklists passed
     * Automatically proceed to step 3

3. Load and analyze the test context:
   - **REQUIRED**: Read tasks.md for test tasks and dependencies
   - **REQUIRED**: Read plan.md for test strategy and coverage requirements
   - **IF EXISTS**: Read contracts/ for API specifications and expected behaviors
   - **IF EXISTS**: Read data-model.md for entities to test
   - **IF EXISTS**: Read research.md for testing constraints and tools
   - **IF EXISTS**: Read quickstart.md for test scenarios

4. **Test Setup Verification**:
   - **REQUIRED**: Verify test framework configuration:

   **Detection & Verification Logic**:
   - Check package.json for test scripts → verify test configuration exists
   - Check for Jest config (jest.config.js, jest.config.ts) → verify coverage settings
   - Check for Vitest config (vitest.config.ts) → verify coverage settings
   - Check for Playwright config (playwright.config.ts) → verify E2E setup
   - Check for testing library packages → verify installed
   - Check for test utilities and mocks setup

   **Common Test Stack by Technology** (from plan.md):
   - **Node.js/TypeScript**: Jest/Vitest, Testing Library, MSW, Supertest
   - **Java/Spring Boot**: JUnit 5, Mockito, TestContainers, RestAssured
   - **Python**: pytest, unittest, mock, httpx
   - **Go**: testing package, testify, httptest

   **Coverage Configuration**:
   - Verify coverage thresholds are set (typically 80-90%)
   - Verify coverage reports directory configured
   - Verify coverage formats configured (lcov, html, text)

5. Parse tasks.md test section and extract:
   - **Test phases**: Unit tests, Integration tests, E2E tests, Performance tests
   - **Test dependencies**: Which implementation tasks must complete first
   - **Test details**: ID, description, files to test, coverage targets
   - **Execution flow**: Test order and dependency requirements

6. Execute tests following the test plan:
   - **Phase-by-phase execution**: Complete each test phase before moving to next
   - **Respect dependencies**: Verify implementation tasks completed before testing
   - **Align with specs**: Tests should align with specifications and contracts
   - **File-based coverage**: Track coverage for each tested module
   - **Validation checkpoints**: Verify tests pass and coverage meets targets

7. Test execution rules:
   - **Unit tests first**: Test individual components/services in isolation with mocks
   - **Integration tests**: Test component interactions with real dependencies
   - **E2E tests**: Test complete workflows from user perspective
   - **Performance tests**: Test response times, load handling, resource usage
   - **Coverage validation**: Ensure coverage meets plan.md requirements

8. Progress tracking and error handling:
   - Report progress after each completed test phase
   - Halt execution if critical tests fail (unit, integration)
   - For E2E/performance tests, report failures but may continue
   - Provide clear error messages with test failure details
   - Generate coverage reports and highlight gaps
   - Suggest fixes for failing tests or coverage gaps
   - **IMPORTANT**: Mark completed test tasks as [X] in tasks.md

9. Test completion validation:
   - Verify all required test tasks are completed
   - Check that test coverage meets plan.md requirements
   - Validate that all tests pass (or document expected failures)
   - Confirm test files follow project conventions
   - Generate final coverage report with breakdown by module
   - Report final status with test summary and coverage metrics

<!-- Nortal Enhancement: Updated note to reference separate implementation command -->
Note: This command assumes implementation is complete. Run `/ai1st-dev-implement` first if implementation tasks are not yet done. If test tasks don't exist in tasks.md, run `/ai1st-dev-tasks` to regenerate the task list with test tasks included.
<!-- END Nortal Enhancement -->

<!-- Nortal Enhancement: Added separation rationale -->
## Why Separate Test Command?

The Nortal framework separates implementation from testing into two commands for several benefits:

1. **Faster Iteration**: Run implementation without waiting for tests during development
2. **Better CI/CD**: Separate build and test stages in pipelines
3. **Debugging**: Re-run tests without re-implementing when debugging test failures
4. **Clearer Responsibilities**: Each command has a single, clear purpose
5. **Error Isolation**: Test failures don't block implementation progress tracking

Compare to SpecKit's `/speckit.implement` which runs both phases together.
<!-- END Nortal Enhancement -->
