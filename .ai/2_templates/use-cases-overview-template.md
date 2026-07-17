# [Project Name] - Use Cases Overview

## Status
[Draft | Active | Archived]

## Purpose
[Document user-facing functionality organized as use cases. Use cases define what users can do with the system and map to business requirements.]

---

## Execution Flow (for AI agents)
```
1. Document purpose:
   → This document tracks user-facing features as use cases
   → Use cases define functionality from user perspective
   → Differentiate: Use Cases = user features, Enablers = technical infrastructure
   → Location: specs/use-cases/use-cases-overview.md

2. Gather project context:
   → Read general-overview.md for business context and user profiles
   → Read BRD.md for functional requirements (FR-xxxx)
   → Review existing use case folders in specs/use-cases/
   → Check enablers-overview.md for technical dependencies

3. Identify use cases from requirements:
   → Map each FR-xxxx to a use case
   → Group related FRs into single use cases where appropriate
   → Identify implicit use cases (e.g., UC-01 often = application framework)
   → Consider user workflows and journeys

4. For each use case:
   → Assign ID: UC-XX format (sequential numbering)
   → Map to BRD requirements (FR-xxxx references)
   → Write one-paragraph description
   → Identify enabler dependencies
   → Identify use case dependencies

5. Prioritize use cases:
   → Must Have: PoC/MVP blockers (core user value)
   → Should Have: Important but deferrable
   → Could Have: Nice to have enhancements
   → Use MoSCoW prioritization

6. Organize by priority:
   → Create status table with priority indicators
   → Track implementation status (Planned/Implemented/Verified)

7. Identify dependencies:
   → Map UC-to-UC dependencies (e.g., UC-15 depends on UC-10)
   → Map UC-to-EN dependencies (e.g., UC-01 depends on EN-03, EN-06)
   → Create dependency table

8. Plan phased execution:
   → Phase 1: Foundation use cases (can run in parallel)
   → Phase 2: Enhancement layer (depends on Phase 1)
   → Phase 3: Advanced features (depends on Phase 1+2)

9. Create related documentation:
   → For each use case, create folder: specs/use-cases/UC-XX/
   → Minimum files: UC-XX-specification.md (or spec.md)
   → Standard files: plan.md, tasks.md
   → Optional: research.md, test/ folder

10. Cross-reference documents:
    → Link to enablers-overview.md
    → Link to BRD.md
    → Link to design-system.md

11. Validate completeness:
    → All FRs covered by use cases
    → Dependencies form a valid DAG (no cycles)
    → Priorities align with project timeline

12. Delete section: Execution Flow (for AI agents)
13. Return: SUCCESS (Use cases overview ready for review)
```

### Related Files and Locations
```
Use Cases Overview Location:
→ specs/use-cases/use-cases-overview.md

Individual Use Case Folders:
→ specs/use-cases/UC-XX/
  ├── UC-XX-specification.md OR spec.md (required)
  ├── plan.md (implementation plan)
  ├── tasks.md (task breakdown)
  ├── research.md (optional - investigation notes)
  └── test/ (optional - test artifacts)

Reference Documents:
→ docs/BRD.md (business requirements with FR-xxxx)
→ specs/enablers/enablers-overview.md (technical dependencies)
→ specs/design/design-system.md (UI/UX guidelines)
→ ../.ai_project_memory/general-overview.md (project context)
```

---

## Use Case Priority Summary

| Priority | Use Cases | Description |
|----------|-----------|-------------|
| **Must Have** | UC-01, UC-02, ... | Release blockers - core functionality |
| **Should Have** | UC-XX, UC-XX, ... | High priority, deferrable if needed |
| **Could Have** | UC-XX, UC-XX, ... | Nice to have enhancements |

### Status Legend
- **Verified**: Implementation complete and verified with test report
- **Implemented**: Code complete, awaiting verification
- **Planned**: Specification complete, not yet implemented

**Must Have (X use cases)**
| Use Case | Name | Status |
|----------|------|--------|
| UC-01 | [Use Case Name] | [Verified/Implemented/Planned] |
| UC-02 | [Use Case Name] | [Verified/Implemented/Planned] |
| UC-03 | [Use Case Name] | [Verified/Implemented/Planned] |

**Should Have (X use cases)**
| Use Case | Name | Status |
|----------|------|--------|
| UC-XX | [Use Case Name] | [Verified/Implemented/Planned] |
| UC-XX | [Use Case Name] | [Verified/Implemented/Planned] |

**Could Have (X use cases)**
| Use Case | Name | Status |
|----------|------|--------|
| UC-XX | [Use Case Name] | [Verified/Implemented/Planned] |
| UC-XX | [Use Case Name] | [Verified/Implemented/Planned] |

---

## Must Have Use Cases (Release Blockers)

### UC-01: [Use Case Name - Usually Application Framework]

**BRD Mapping**: [FR-xxxx, FR-xxxx]
**Description**: [One paragraph describing what this use case delivers to users. Focus on user value, not technical implementation.]

---

### UC-02: [Use Case Name]

**BRD Mapping**: [FR-xxxx]
**Description**: [One paragraph describing the user-facing functionality]

---

### UC-03: [Use Case Name]

**BRD Mapping**: [FR-xxxx]
**Description**: [One paragraph describing the user-facing functionality]

---

## Should Have Use Cases (High Priority, Deferrable)

### UC-XX: [Use Case Name]

**BRD Mapping**: [FR-xxxx]
**Description**: [One paragraph describing the user-facing functionality]

---

### UC-XX: [Use Case Name]

**BRD Mapping**: [FR-xxxx]
**Description**: [One paragraph describing the user-facing functionality]

---

## Could Have Use Cases (Nice to Have)

### UC-XX: [Use Case Name]

**BRD Mapping**: [FR-xxxx]
**Description**: [One paragraph describing the user-facing functionality]

---

## Phased Execution Plan

This section provides implementation guidance for Should Have and Could Have use cases.

### Critical Dependencies (← means "depends on")

| Dependent UC | Required UC | Reason |
|--------------|-------------|--------|
| UC-XX | ← UC-XX | [Why this dependency exists] |
| UC-XX | ← UC-XX | [Why this dependency exists] |
| UC-XX | ← UC-XX, UC-XX | [Why this dependency exists] |

### Recommended Phases

| Phase | Use Cases | Approach | Description |
|-------|-----------|----------|-------------|
| **1** | UC-XX, UC-XX, UC-XX | Parallel | Independent foundational features |
| **2** | UC-XX, UC-XX | Sequential | Depends on Phase 1 completions |
| **3** | UC-XX, UC-XX | Sequential | Complex features requiring Phase 1+2 |

### Phase 1: Foundation Layer (Parallel Execution)

**Priority**: [Must Have / Should Have]
**Approach**: Can be developed simultaneously by multiple developers

| UC | Name | Focus | Key Deliverables |
|----|------|-------|------------------|
| UC-XX | [Name] | [Frontend/Backend/Full Stack] | [List 2-4 key deliverables] |
| UC-XX | [Name] | [Frontend/Backend/Full Stack] | [List 2-4 key deliverables] |

### Phase 2: Enhancement Layer (Sequential After Phase 1)

**Priority**: [Should Have / Could Have]
**Approach**: Must wait for specific Phase 1 completions

| UC | Name | Waits For | Key Deliverables |
|----|------|-----------|------------------|
| UC-XX | [Name] | UC-XX | [List 2-4 key deliverables] |
| UC-XX | [Name] | UC-XX | [List 2-4 key deliverables] |

### Phase 3: Advanced Features (Sequential After Phase 2)

**Priority**: Could Have
**Approach**: Complex features requiring Phase 1+2 foundations

| UC | Name | Waits For | Key Deliverables |
|----|------|-----------|------------------|
| UC-XX | [Name] | UC-XX + UC-XX | [List 2-4 key deliverables] |

### Implementation Notes

- **Phase 1 Parallel Safety**: These use cases modify different files and have no runtime dependencies
- **[Note about infrastructure requirements]**: [e.g., "UC-XX requires Redis infrastructure"]
- **[Note about missing specs]**: [e.g., "UC-XX folder doesn't exist yet"]

---

## Use Case Dependencies on Enablers

[Map which enablers each use case depends on]

| Use Case | Depends On Enablers | Notes |
|----------|---------------------|-------|
| UC-01 | EN-03, EN-06 | Requires app infrastructure and backend API |
| UC-02 | EN-06 | Requires data endpoints |
| UC-XX | EN-XX, EN-XX | [Notes] |

---

## Related Documentation

- **Enablers**: [../enablers/enablers-overview.md](../enablers/enablers-overview.md)
- **Domain Model**: [../domain-model/domain-model-overview.md](../domain-model/domain-model-overview.md)
- **Design System**: [../design/design-system.md](../design/design-system.md)
- **Business Requirements**: [../../docs/BRD.md](../../docs/BRD.md)
- **Project Overview**: [../../../.ai_project_memory/general-overview.md](../../../.ai_project_memory/general-overview.md)

---

**Document Version**: 1.0
**Last Updated**: [YYYY-MM-DD]
