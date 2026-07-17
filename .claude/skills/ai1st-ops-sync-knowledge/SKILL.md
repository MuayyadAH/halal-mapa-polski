---
name: ai1st-ops-sync-knowledge
description: "Export session knowledge from Knowledge Graph MCP to git-versioned markdown files"
disable-model-invocation: true
---


<!-- Tomi: DRAFT needs review and probably modifications -->

# Sync Knowledge Graph to Git Files

You are tasked with exporting valuable knowledge from the current session's Knowledge Graph to git-versioned markdown files for team sharing.

## Context

**Problem**: Knowledge Graph MCP stores data locally, not in git, so team members don't have access. This slash command ensures important knowledge is persisted to version-controlled files.

**Knowledge Files Location**:
- `.ai/knowledge/decisions.md` - Architectural decision records
- `.ai/knowledge/patterns.md` - Code patterns and best practices
- `.ai/knowledge/optimization.md` - Token/MCP optimization strategies
- `.ai/knowledge/legacy-analysis-{module}.md` - Legacy analysis enriched entities (from ai1st-arch-legacy-sys-analysis/ai1st-arch-legacy-analysis-lite/ai1st-arch-legacy-to-modern-design/ai1st-arch-legacy-to-modern-design-lite)

## Your Tasks

### 1. Read Current Knowledge Graph

Use `mcp__knowledge-graph__read_graph` to see all entities and relations currently stored.

### 2. Categorize Knowledge

Review each entity and categorize:
- **Architectural Decisions** → Export to `decisions.md`
- **Code Patterns** → Export to `patterns.md`
- **Optimization Strategies** → Export to `optimization.md`
- **Legacy Analysis (ai1st-arch-legacy-sys-analysis/ai1st-arch-legacy-analysis-lite/ai1st-arch-legacy-to-modern-design/ai1st-arch-legacy-to-modern-design-lite)** → Export to `legacy-analysis-{module}.md`
- **Temporary/Session-only** → Skip (don't persist)

#### Legacy Analysis Entity Export Rules

When KG contains entities from legacy analysis commands (ai1st-arch-legacy-sys-analysis, ai1st-arch-legacy-analysis-lite, ai1st-arch-legacy-to-modern-design, ai1st-arch-legacy-to-modern-design-lite), apply these rules:

| Entity Type | Export? | Target File | Rationale |
|-------------|---------|-------------|-----------|
| `GlossaryTerm` (TERM-*) | YES | `legacy-analysis-{module}.md` | Enriched with verified/discovered observations beyond Glossary.md |
| `StatusValue` (STATUS-*) | YES | `legacy-analysis-{module}.md` | Business-term-to-code-enum mappings |
| `Gate` (GATE-*) | YES | `legacy-analysis-{module}.md` | Audit trail of human decisions |
| `UserStory` (US-*) | YES | `legacy-analysis-{module}.md` | TO-BE story definitions with mapping |
| `ProcessStep` (STEP-*) | YES | `legacy-analysis-{module}.md` | Process completion record |
| `BusinessRule` (BR-*) | SKIP | - | Canonical home is LBR-{module}.md |
| `Requirement` (FR-*) | SKIP | - | Canonical home is SRS/BRS-{module}.md |
| `Module` (MOD-*) | SKIP | - | Defined in PROJECT-SCOPE.md |
| `ScopeBoundary` (SCOPE-*) | SKIP | - | Defined in PROJECT-SCOPE.md |
| `Session` (SESSION-*) | SKIP | - | Temporary session state |

**Legacy Analysis Export Format**:
```markdown
## Legacy Analysis: {Module} ({date})

### Enriched Terms
| Term | Meaning | Code Evidence | Verified |
|------|---------|---------------|----------|
| AT | Additional Tax | AdditionalTax.java | 2026-02-10 |

### Status Mappings
| Business Term | Code Enum | Type |
|---------------|-----------|------|
| Paid | balanceAmount == 0 | DERIVED |

### Gate Decisions
| Gate | Status | Date | Notes |
|------|--------|------|-------|
| Gate 0.5 | APPROVED | 2026-02-10 | Terminology verified |

### User Stories (if TO-BE completed)
| ID | Story | Screen | Priority |
|----|-------|--------|----------|
| US-001 | As a taxpayer, I want to view claims | Claims List | MUST |

### Process Steps
| Step | Status | Entities Created |
|------|--------|-----------------|
| STEP-601-1 | complete | BR:32, FR:8, INT:5 |
```

### 3. Export to Markdown Files

For each valuable entity:

**Decisions Format**:
```markdown
## ADR-NNN: [Entity Name] (YYYY-MM-DD)

**Decision**: [What was decided]

**Rationale**: [Why - from observations]

**Alternatives Considered**: [If available]

**Impact**: [Consequences]

**Related**: [Links to other docs]
```

**Patterns Format**:
```markdown
## [Pattern Name]

[Code example from observations]

**Key Points**:
- [Observation 1]
- [Observation 2]

**Reference**: [Source from observations]
```

**Optimization Format**:
```markdown
## [Optimization Name]

**Problem**: [What issue it solves]

**Solution**: [Strategy from observations]

**Token Savings**: [If measured]
```

### 4. Update Files

Use the `Edit` tool to add new knowledge to existing files. **Do NOT overwrite** existing content - append or integrate carefully.

### 5. Summary Report

After syncing, provide:
- ✅ Number of entities exported
- 📁 Which files were updated
- 🔍 Entities skipped (temporary only)
- 💡 Recommendation: Should any knowledge be moved to constitution.md or general-overview.md instead?

### 6. Clean Up (Optional)

Ask user: "Should I delete temporary entities from Knowledge Graph to keep it clean?"

## Guidelines

- **Preserve existing content**: Use Edit, not Write
- **Add dates**: All new entries should have YYYY-MM-DD
- **Link to sources**: Reference constitution.md, general-overview.md, Context7, etc.
- **Quality over quantity**: Only export valuable, reusable knowledge
- **Team perspective**: Would this help a new team member? If no, skip it

## Example Workflow

```bash
User: /ai1st-ops-sync-knowledge

Claude:
1. Reading Knowledge Graph... Found 7 entities
2. Categorizing:
   - "MapStruct Patterns" → patterns.md
   - "Lean Scope Decision" → decisions.md
   - "MCP Token Costs" → optimization.md
   - "Session TODO" → Skip (temporary)
3. Updating files...
   ✅ decisions.md: Added ADR-004
   ✅ patterns.md: Added MapStruct section
   ✅ optimization.md: Updated MCP costs table
4. Summary: 3 entities exported, 1 skipped

Should I delete temporary entities from Knowledge Graph?
```

## Success Criteria

- [ ] All valuable knowledge exported to markdown files
- [ ] Files are readable and well-formatted
- [ ] Team members can git pull and access knowledge
- [ ] No loss of important information
- [ ] Knowledge Graph cleaned of stale data (if user approves)
