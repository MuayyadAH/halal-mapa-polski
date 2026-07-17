---
name: ai1st-dev-plan
description: "Execute the implementation planning workflow using the plan template to generate design artifacts."
disable-model-invocation: true
---


## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

<!-- Nortal Enhancement: Updated paths from .specify/ to .ai/ for Nortal framework compatibility -->
1. **Setup**: Run `.ai/scripts/bash/setup-plan.sh --json` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load context**: Read FEATURE_SPEC and `.ai_project_memory/constitution.md`. Load IMPL_PLAN template (already copied).
<!-- END Nortal Enhancement -->

3. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md
   - Phase 1: Update stack constitution with new technologies
   - Re-evaluate Constitution Check post-design

4. **Stop and report**: Command ends after Phase 2 planning. Report branch, IMPL_PLAN path, and generated artifacts.

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task
   - For each **TBD** dropdown source in design/description.md → search backend for existing endpoints. Flag missing endpoints for user decision.

<!-- Nortal Enhancement: Added MCP workflow integration with fallback and knowledge graph storage -->
2. **MCP-enhanced research** (use if available, fallback to manual):

   **Primary workflow** (if MCP servers available):
   - **Atlassian MCP**: Fetch related Jira tickets, Confluence BRDs
     - Tool: `mcp__atlassian__search` with feature keywords
     - Fallback: Skip if MCP unavailable, proceed to manual research
   - **Context7 MCP**: Fetch library documentation for dependencies
     - Tool: `mcp__context7__resolve-library-id` then `get-library-docs`
     - Fallback: Use web search or skip if critical info missing
   - **Knowledge Graph**: Store research findings for session memory
     - Tool: `mcp__knowledge-graph__create_entities` for decisions
     - Fallback: Document in research.md only if KG unavailable

   **Fallback workflow** (if MCP not available):
   - Use Task tool to delegate research to specialized agent
   - Use WebSearch for library documentation
   - Store findings directly in research.md

3. **Complex decision-making**:
   - Use basic sequential thinking to analyze trade-offs step-by-step
   - Store final decision in knowledge graph if available

4. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]
   - Source: [MCP/WebSearch/Manual] (for traceability)

**Output**: research.md with all NEEDS CLARIFICATION resolved
<!-- END Nortal Enhancement -->

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

<!-- Nortal Enhancement: Added knowledge graph architectural decisions and optimized agent context update -->
3. **Store architectural decisions** (if knowledge graph available):
   - Create entities for key design patterns used
   - Create relations between components
   - Add observations for rationale
   - Fallback: Skip if KG unavailable, proceed to stack constitution update

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

**Output**: data-model.md, /contracts/*, quickstart.md, updated stack constitution
<!-- END Nortal Enhancement -->

<!-- Nortal Enhancement: Added MCP usage guidelines for token efficiency -->
## MCP Workflow Guidelines

**When to use MCP vs direct tools**:

| Scenario | Use MCP | Use Direct Tool | Rationale |
|----------|---------|----------------|-----------|
| Fetch Jira requirements | ✅ Atlassian MCP | ❌ | Structured data, auth handled |
| Library documentation | ✅ Context7 MCP | ❌ | Up-to-date, version-specific |
| Session memory (temp) | ✅ Knowledge Graph | ❌ | Quick storage/retrieval |
| Permanent decisions | ❌ | ✅ research.md | Git-versioned, team-shared |
| Web search (general) | ❌ | ✅ WebSearch | No MCP equivalent |
| Code search | ❌ | ✅ Grep/Glob | Faster, more precise |

**Token optimization**:
- MCP fetch costs: Atlassian (2-3K), Context7 (3-5K), KG (50-200)
- Always check `.ai/knowledge/` files FIRST before MCP
- Cache MCP results in research.md for re-use
- Use knowledge graph for session temp data, export to files at end

**Graceful degradation**:
```
Try MCP → If unavailable/error → Log warning → Use fallback → Continue
```
Never block on MCP failures. All MCP features are OPTIONAL enhancements.
<!-- END Nortal Enhancement -->

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications

<!-- Nortal Enhancement: Added Claude-specific optimization rules -->
- **Token efficiency**: Avoid reading large files multiple times; cache in variables
- **Parallel tool calls**: When possible, make multiple Read/Grep calls in one message
- **Task delegation**: Use Task tool for complex sub-workflows (research, design)
- **Knowledge graph**: Session memory only; export valuable findings to git files
- **Deep analysis**: Reserve for genuine complexity (architecture trade-offs, not simple lookups)
- **MCP fallback**: Never block on MCP; always have fallback to direct tools
<!-- END Nortal Enhancement -->
