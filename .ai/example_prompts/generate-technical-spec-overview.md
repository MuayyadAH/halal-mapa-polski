# Generate Technical Specification Overview

## How to Use This Prompt

**Purpose**: This prompt orchestrates the generation of compact technical specification overviews for all enablers and use cases. These overviews help customer technical architects review implementation plans without being overwhelmed by implementation details.

**When to Use**:
- After completing implementation plans (plan.md) for enablers and use cases
- Before presenting technical approach to customer stakeholders
- When customer technical architect needs high-level implementation overview

**How to Launch**:

```
Read the prompt file at .ai/example_prompts/generate-technical-spec-overview.md and execute it.
Generate technical specification overviews for all enablers and use cases.
```

**Alternative (specific items only)**:

```
Read the prompt file at .ai/example_prompts/generate-technical-spec-overview.md and execute it.
Generate technical specification overviews only for UC-01, UC-02, and EN-06.
```

---

## Objective

Generate compact technical specification overviews (technical-spec-overview.md) for all enablers and use cases. These documents summarize implementation plans for customer technical review, focusing on architecture decisions, implementation scope, and technical validation without duplicating use case business context.

---

## Input Documents

Read these documents to understand scope:

1. **Enablers Overview**: `specs/enablers/enablers-overview.md` - Lists all enablers with dependencies
2. **Use Cases Overview**: `specs/use-cases/use-cases-overview.md` - Lists all use cases with dependencies
3. **Business Requirements**: `docs/BRD.md` - Original customer specification and requirements
4. **Project Overview**: `../.ai_project_memory/general-overview.md` - Project summary and key facts
5. **Constitution**: `../.ai_project_memory/constitution.md` - Core development principles
6. **Backend Constitution**: `../.ai_project_memory/constitution-backend.md` - Backend-specific principles
7. **Frontend Constitution**: `../.ai_project_memory/constitution-frontend.md` - Frontend-specific principles

## Output Requirements

For each enabler/use case, generate:

```
specs/[enablers|use-cases]/[ID]/
├── plan.md                      # Implementation plan (detailed)
├── research.md                  # Phase 0 research
├── tasks.md                     # Implementation tasks
└── technical-spec-overview.md   # Customer-facing technical summary (this workflow)
```

**Example**: `specs/enablers/EN-06/technical-spec-overview.md`, `specs/use-cases/UC-01/technical-spec-overview.md`

---

## Execution Strategy

**Constraint**: Process items sequentially following dependency order.

**Resilience Design**: Stateless and idempotent - checks filesystem before each item.

### Phase 1: Initial Setup

1. **Read overview documents**:
   - Read `specs/enablers/enablers-overview.md`
   - Read `specs/use-cases/use-cases-overview.md`
   - Parse dependency graph to determine processing order

2. **Read project context** (once at start):
   - Read `docs/BRD.md` for business requirements
   - Read `../.ai_project_memory/general-overview.md` for project summary

3. **Scan existing overviews**:
   - Check `specs/enablers/*/technical-spec-overview.md` for existing enabler overviews
   - Check `specs/use-cases/*/technical-spec-overview.md` for existing use case overviews
   - Identify which items still need overviews

4. **Determine processing order** (dependency-aware):
   ```
   EN-01 → EN-02 → EN-03 → EN-04, EN-05 → EN-06 → EN-07, EN-08
                                      ↓
                                    UC-01 → UC-02 to UC-20
   ```

### Phase 2: Iterative Overview Generation

For each item in dependency order:

1. **Check if overview exists**:
   - Skip if `specs/[type]/[ID]/technical-spec-overview.md` already exists

2. **Check if plan exists**:
   - Warn and skip if `specs/[type]/[ID]/plan.md` does not exist (prerequisite)

3. **Read item specification**:
   - Read full specification file (e.g., `specs/enablers/EN-06-multi-platform-data-service.md`)

4. **Read implementation plan**:
   - Read `specs/[type]/[ID]/plan.md`
   - Extract: summary, technical context, design decisions, component structure

5. **Read research findings**:
   - Read `specs/[type]/[ID]/research.md`
   - Extract: alternatives considered, key decisions, rationale

6. **Read task breakdown**:
   - Read `specs/[type]/[ID]/tasks.md`
   - Count tasks to estimate effort and timeline

7. **Generate overview document**:
   - Follow template structure (4 sections)
   - Keep compact (60-120 rows)
   - Focus on technical decisions and implementation scope
   - Use future tense ("to be created", "to be implemented")

8. **Write overview file**:
   - Create `specs/[type]/[ID]/technical-spec-overview.md`

9. **Proceed to next item**

### Phase 3: Verification

1. Scan all item directories for `technical-spec-overview.md` files
2. Compare against overview documents
3. Report any missing overviews

---

## Document Structure Template

**Reference Examples**:
- `specs/enablers/EN-01/technical-spec-overview.md` (infrastructure example)
- `specs/use-cases/UC-01/technical-spec-overview.md` (use case example)

```markdown
# Technical Specification Overview: [ID] - [Feature Name]

**Status**: Draft
**Target Audience**: Customer Technical Architect
**Related Documents**: [Link to spec], [Link to plan]
**Last Updated**: [DATE]

---

## Technical Approach

[1-2 paragraph summary describing what this enabler/use case implements]

**Architecture Pattern**: [High-level pattern description]

**Key Decisions**:
1. **[Decision Name]**: [1-sentence rationale]
2. **[Decision Name]**: [1-sentence rationale]
3. **[Decision Name]**: [1-sentence rationale]
4. **[Decision Name]**: [1-sentence rationale]

**[Optional Context Section]**: (e.g., "Layout Structure" for UI, "Azure Resources" for infrastructure)
- [Key detail 1]
- [Key detail 2]
- [Key detail 3]

---

## Implementation Scope

**[Resources/Components to be Created]**:
- [Item 1]: [Brief context if needed]
- [Item 2]: [Brief context if needed]
- [Item 3]: [Brief context if needed]

**Files to be Created**:

```
path/to/files/
├── file1.ext
├── file2.ext
└── subdirectory/
    ├── file3.ext
    └── file4.ext
```

---

## Integration & Dependencies

**Provides To**: [List of downstream consumers]

**Depends On**:
- [Dependency 1]
- [Dependency 2]

**Testing Strategy**:
- [Test approach 1]
- [Test approach 2]
- [Test approach 3]

**Estimated Effort**: [X developer-days]

---

## Acceptance Criteria

*Same criteria as plan.md - for customer technical review*

- [ ] [Acceptance criterion 1 from plan.md]
- [ ] [Acceptance criterion 2 from plan.md]
- [ ] [Acceptance criterion 3 from plan.md]
...

---

**Prepared By**: [Role]
**Review Requested From**: Customer Technical Architect
**Next Steps**: [Approval process and next actions]
```

---

## Content Guidelines

### Writing Style

**DO**:
- Use future tense ("to be created", "to be implemented")
- Focus on technical decisions and architecture
- Keep file trees clean without inline comments
- Reference plan.md for detailed implementation
- Avoid duplicating use case business context

**DON'T**:
- Include code snippets or detailed implementation code
- Add inline comments in file trees
- Duplicate business value/user workflow from use case spec
- Include performance targets, risks, or key questions sections
- Add "Business Value" or standalone "Effort" in summary
- Use personal names (use roles: "Architect", "Developer", "Team")

### Length Guidelines

**Target Document Length**: 60-120 rows

**Section Priorities**:
1. **Technical Approach** (30%): Architecture pattern + key decisions
2. **Implementation Scope** (40%): Resources/components + file structure
3. **Integration & Dependencies** (20%): Dependencies + testing + effort
4. **Acceptance Criteria** (10%): Same criteria as plan.md for customer review

### Technical Depth

**Right Level of Detail**:
- ✅ "React 19 + TypeScript for type safety and team expertise"
- ✅ "Terraform IaC for reproducible infrastructure provisioning"
- ✅ "TanStack Query for automatic caching and background refetching"
- ❌ Detailed configuration values or code snippets
- ❌ Implementation specifics covered in plan.md
- ❌ Step-by-step instructions

---

## Processing Order Example

Based on current project dependencies:

**Round 1**: EN-01 (no dependencies)
**Round 2**: EN-02 (depends on EN-01)
**Round 3**: EN-03 (depends on EN-01, EN-02)
**Round 4**: EN-04, EN-05 (depends on EN-01, EN-03)
**Round 5**: EN-06 (depends on EN-02, EN-03, EN-04)
**Round 6**: EN-07 (depends on EN-06)
**Round 7**: UC-01 (depends on EN-03, EN-04, EN-06)
**Round 8**: EN-08 (depends on UC-01)
**Round 9+**: UC-02 through UC-20 (can be parallelized)

---

## Quality Checklist

Before marking an overview complete:

- [ ] **Compact**: 60-120 rows (not 200+)
- [ ] **Technical focus**: Architecture decisions, not business value
- [ ] **Clean file trees**: No inline comment descriptions
- [ ] **Future tense**: "to be created", "to be implemented"
- [ ] **No duplication**: Doesn't repeat use case business context
- [ ] **Correct references**: Links to spec and plan are accurate
- [ ] **Complete sections**: All 4 sections filled with relevant content
- [ ] **No unnecessary sections**: No performance targets, risks, or key questions
- [ ] **No personal names**: Used roles instead of individual names

---

## Success Criteria

A successful batch generation run:
- ✅ All items with completed plans have technical specification overviews
- ✅ Items without plans are skipped with clear warning
- ✅ Existing overviews are not overwritten
- ✅ All overviews are compact (60-120 rows)
- ✅ Processing completed in dependency order
- ✅ Clear summary of processed vs. skipped items

A successful individual overview:
- ✅ Customer technical architect can understand implementation approach in 5-10 minutes
- ✅ Technical decisions are clearly explained with rationale
- ✅ Implementation scope is clear (resources + file structure)
- ✅ Integration points and dependencies are explicit
- ✅ Testing strategy and effort estimate are realistic
- ✅ Document is compact, focused, and easy to scan
