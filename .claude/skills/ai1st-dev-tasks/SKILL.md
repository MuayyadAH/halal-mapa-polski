---
name: ai1st-dev-tasks
description: "Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts."
disable-model-invocation: true
---


## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

<!-- Nortal Enhancement: Updated paths from .specify/ to .ai/ for Nortal framework compatibility -->
1. **Setup**: Run `.ai/scripts/bash/check-prerequisites.sh --json` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").
<!-- END Nortal Enhancement -->

2. **Load design documents**: Read from FEATURE_DIR:
   - **Required**: plan.md (tech stack, libraries, structure), spec.md (user stories with priorities)
   - **Optional**: data-model.md (entities), contracts/ (API endpoints), research.md (decisions), quickstart.md (test scenarios)
   - **Optional**: design/ folder (if captured via `/ai1st-po-capture-ui`):
     - `design/description.md` - page/component analysis
     - `design/partials/*/` - UI state-specific context
     - `design/token-proposals.md` - design token alignment
   - Note: Not all projects have all documents. Generate tasks based on what's available.

<!-- Nortal Enhancement: Added MCP-enhanced task generation workflow with knowledge graph -->
3. **Execute task generation workflow**:

   **Step 3.1: Load and analyze documents** (use parallel reads for efficiency):
   - Read plan.md and extract tech stack, libraries, project structure
   - Read spec.md and extract user stories with their priorities (P1, P2, P3, etc.)
   - If data-model.md exists: Extract entities and map to user stories
   - If contracts/ exists: Map endpoints to user stories (parallel read all contract files)
   - If research.md exists: Extract decisions for setup tasks
   - If quickstart.md exists: Extract test scenarios for validation tasks

   **Step 3.2: Complex dependency analysis**:
   - **Simple cases** (< 5 user stories, linear dependencies): Direct task ordering
   - **Complex cases** (5+ stories with cross-dependencies):
     - Apply basic sequential thinking to analyze:
       - Which stories can be truly independent
       - Which tasks block others
       - Optimal parallelization strategy
       - Risk areas requiring early validation

   **Step 3.3: Store task architecture** (use knowledge graph if available):
   - Create entities for each user story
   - Create relations showing story dependencies
   - Add observations for parallelization opportunities
   - Fallback: Document in tasks.md Dependencies section if KG unavailable

   **Step 3.4: Generate task breakdown**:
   - Generate tasks organized by user story (see Task Generation Rules below)
   - Generate dependency graph showing user story completion order
   - Create parallel execution examples per user story
   - Validate task completeness (each user story has all needed tasks, independently testable)
<!-- END Nortal Enhancement -->

<!-- Nortal Enhancement: Updated template path to use Nortal framework -->
4. **Generate tasks.md**: Use `.ai/2_templates/tasks-template.md` as structure, fill with:
<!-- END Nortal Enhancement -->
   - Correct feature name from plan.md
   - Phase 1: Setup tasks (project initialization)
   - Phase 2: Foundational tasks (blocking prerequisites for all user stories)
   - Phase 3+: One phase per user story (in priority order from spec.md)
   - Each phase includes: story goal, independent test criteria, tests (if requested), implementation tasks
   - Final Phase: Polish & cross-cutting concerns
   - All tasks must follow the strict checklist format (see Task Generation Rules below)
   - Clear file paths for each task
   - Dependencies section showing story completion order
   - Parallel execution examples per story
   - Implementation strategy section (MVP first, incremental delivery)

<!-- Nortal Enhancement: Added MCP-aware reporting with knowledge graph export -->
5. **Report**: Output path to generated tasks.md and summary:
   - Total task count
   - Task count per user story
   - Parallel opportunities identified (with % parallelizable)
   - Independent test criteria for each story
   - Suggested MVP scope (typically just User Story 1)
   - Format validation: Confirm ALL tasks follow the checklist format (checkbox, ID, labels, file paths)
   - **If knowledge graph used**: Export task dependencies to `.ai/knowledge/task-dependencies-[feature].md` for team sharing
<!-- END Nortal Enhancement -->

Context for task generation: $ARGUMENTS

The tasks.md should be immediately executable - each task must be specific enough that an LLM can complete it without additional context.

## Task Generation Rules

**CRITICAL**: Tasks MUST be organized by user story to enable independent implementation and testing.

**Tests are OPTIONAL**: Only generate test tasks if explicitly requested in the feature specification or by the user.

### Checklist Format (REQUIRED)

Every task MUST strictly follow this format:

```text
- [ ] [TaskID] [P?] [Story?] Description with file path
```

**Format Components**:

1. **Checkbox**: ALWAYS start with `- [ ]` (markdown checkbox)
2. **Task ID**: Sequential number (T001, T002, T003...) in execution order
3. **[P] marker**: Include ONLY if task is parallelizable (different files, no dependencies on incomplete tasks)
4. **[Story] label**: REQUIRED for user story phase tasks only
   - Format: [US1], [US2], [US3], etc. (maps to user stories from spec.md)
   - Setup phase: NO story label
   - Foundational phase: NO story label
   - User Story phases: MUST have story label
   - Polish phase: NO story label
5. **Description**: Clear action with exact file path

**Examples**:

- ✅ CORRECT: `- [ ] T001 Create project structure per implementation plan`
- ✅ CORRECT: `- [ ] T005 [P] Implement authentication middleware in src/middleware/auth.py`
- ✅ CORRECT: `- [ ] T012 [P] [US1] Create User model in src/models/user.py`
- ✅ CORRECT: `- [ ] T014 [US1] Implement UserService in src/services/user_service.py`
- ❌ WRONG: `- [ ] Create User model` (missing ID and Story label)
- ❌ WRONG: `T001 [US1] Create model` (missing checkbox)
- ❌ WRONG: `- [ ] [US1] Create User model` (missing Task ID)
- ❌ WRONG: `- [ ] T001 [US1] Create model` (missing file path)

### Task Organization

1. **From User Stories (spec.md)** - PRIMARY ORGANIZATION:
   - Each user story (P1, P2, P3...) gets its own phase
   - Map all related components to their story:
     - Models needed for that story
     - Services needed for that story
     - Endpoints/UI needed for that story
     - If tests requested: Tests specific to that story
   - Mark story dependencies (most stories should be independent)

2. **From Contracts**:
   - Map each contract/endpoint → to the user story it serves
   - If tests requested: Each contract → contract test task [P] before implementation in that story's phase

3. **From Data Model**:
   - Map each entity to the user story(ies) that need it
   - If entity serves multiple stories: Put in earliest story or Setup phase
   - Relationships → service layer tasks in appropriate story phase

4. **From Setup/Infrastructure**:
   - Shared infrastructure → Setup phase (Phase 1)
   - Foundational/blocking tasks → Foundational phase (Phase 2)
   - Story-specific setup → within that story's phase

5. **From Design Context** (if `design/` folder exists):
   - Each form in `design/partials/` → form verification task
   - Each i18n text mapping → i18n key definition task
   - Reference `design/description.md` for component verification
   - Include token alignment verification if `design/token-proposals.md` exists
   - **Visual parity verification task** (REQUIRED in Final Phase): Generate a task that compares implemented UI against `design/screenshot.png` and `design/partials/*/screenshot.png` using Playwright. Must verify: layout structure, colors/tokens, typography, icon appearance (SVG paths, fill vs stroke, size), spacing, and interactive states. Reference `design/description.md` for expected visual details (icons, colors, spacing, fonts).

### Phase Structure

- **Phase 1**: Setup (project initialization)
- **Phase 2**: Foundational (blocking prerequisites - MUST complete before user stories)
- **Phase 3+**: User Stories in priority order (P1, P2, P3...)
  - Within each story: Tests (if requested) → Models → Services → Endpoints → Integration
  - Each phase should be a complete, independently testable increment
- **Final Phase**: Polish & Cross-Cutting Concerns (accessibility, RTL, visual parity verification against design captures)

<!-- Nortal Enhancement: Added MCP usage guidelines for task generation optimization -->
## MCP Workflow Guidelines

**When to use MCP in task generation**:

| Scenario | Use MCP | Fallback | Benefit |
|----------|---------|----------|---------|
| Complex dependencies (5+ stories) | ✅ Basic sequential thinking | Manual analysis | Optimal parallelization |
| Task architecture storage | ✅ Knowledge Graph | tasks.md only | Session memory, quick lookup |
| Parallel document reads | ❌ Direct Read tool | N/A | Faster than sequential |
| Simple linear tasks | ❌ | Direct generation | Avoid MCP overhead |

**Complex analysis criteria**:
- **Use when**: 5+ user stories with potential cross-dependencies
- **Skip when**: < 5 stories, linear flow, simple CRUD
- **Output**: Dependency graph, parallelization strategy, risk analysis

**Knowledge graph usage**:
- **During generation**: Store story dependencies, task relationships
- **After generation**: Export to `.ai/knowledge/task-dependencies-[feature].md`
- **Never block**: If KG unavailable, document directly in tasks.md

**Token optimization**:
- **Parallel reads**: Read all contracts/ files in single message (batch Read calls)
- **Cache extractions**: Store spec.md user stories in variable, reuse for each phase
- **Avoid re-reads**: Once plan.md loaded, cache tech stack; don't re-read
- **Estimated savings**: 3-5K tokens per task generation (parallel reads + caching)

**Graceful degradation**:
```
Try Basic Sequential Thinking → If complex dependency analysis needed
  → If unavailable: Manual dependency graph
Try Knowledge Graph → For task architecture storage
  → If unavailable: Document in tasks.md Dependencies section
Always proceed: MCP features are enhancements, never blockers
```
<!-- END Nortal Enhancement -->

<!-- Nortal Enhancement: Added Claude-specific optimization for task generation -->
## Token Efficiency Rules

**Document loading**:
- ✅ **DO**: Read all contract files in parallel (single message, multiple Read calls)
- ✅ **DO**: Cache spec.md user stories in variable after first extraction
- ✅ **DO**: Load plan.md once, extract tech stack, reuse throughout
- ❌ **DON'T**: Re-read same file multiple times
- ❌ **DON'T**: Read files sequentially when parallel is possible

**Task generation**:
- ✅ **DO**: Generate all tasks for a story in one pass
- ✅ **DO**: Use template structure to avoid re-generating sections
- ✅ **DO**: Validate format once at end, not per-task
- ❌ **DON'T**: Generate tasks one-by-one in separate messages

**Knowledge management**:
- ✅ **DO**: Use knowledge graph for session temp storage (cheap: 50-200 tokens)
- ✅ **DO**: Export valuable findings to git files at end
- ❌ **DON'T**: Store everything in knowledge graph (use for architecture only)
- ❌ **DON'T**: Skip export step (knowledge graph is session-only)

**Complex analysis**:
- ✅ **DO**: Use for genuine complexity (cross-dependencies, risk analysis)
- ❌ **DON'T**: Use for simple linear task ordering (overhead: 500-1K tokens)

**Estimated token usage**:
- Simple feature (3 stories, linear): ~5K tokens
- Complex feature (5+ stories, dependencies): ~8K tokens (with detailed analysis)
- Very complex (10+ stories, microservices): ~12K tokens (with full MCP suite)

**Target efficiency**: < 10K tokens per task generation (achievable with caching + parallel reads)
<!-- END Nortal Enhancement -->

## Key Rules

- Use absolute paths
- STRICT checklist format (checkbox, ID, markers, file path)
- User story organization (one phase per story)
- Tests optional unless requested

<!-- Nortal Enhancement: Added Claude-specific execution rules -->
- **Parallel reads**: Always batch document loading in single message
- **Cache extractions**: Store user stories/tech stack in variables, reuse
- **MCP fallback**: Never block on MCP; always have manual fallback
- **Knowledge graph export**: If used, export task dependencies to git file
- **Complex analysis**: Reserve for complex (5+ story) dependency analysis
- **Validation**: Confirm ALL tasks match strict checklist format before reporting
<!-- END Nortal Enhancement -->
