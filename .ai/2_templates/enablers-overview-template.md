# [Project Name] - Technical Enablers Overview

## Status
[Draft | Active | Archived]

## Purpose
[Document infrastructure, platform, and tooling enablers that support use case implementation. Enablers are non-user-facing technical capabilities that enable feature development.]

---

## Execution Flow (for AI agents)
```
1. Document purpose:
   → This document tracks infrastructure and platform enablers
   → Enablers are technical foundations that support use cases
   → Differentiate: Enablers = technical infrastructure, Use Cases = user-facing features
   → Location: specs/enablers/enablers-overview.md

2. Gather project context:
   → Read general-overview.md for business context
   → Read BRD.md for non-functional requirements
   → Review existing enabler folders in specs/enablers/
   → Check use-cases-overview.md for dependencies

3. Identify enablers from requirements:
   → Infrastructure enablers (hosting, IaC, networking)
   → Data platform enablers (databases, data access)
   → Security enablers (authentication, authorization)
   → DevOps enablers (CI/CD, monitoring)
   → Framework enablers (backend/frontend foundations)
   → Testing enablers (test infrastructure)

4. For each enabler:
   → Assign ID: EN-XX format (sequential numbering)
   → Map to BRD requirements (NFR-xx, FR-xx, Section references)
   → List components and technologies
   → Identify dependencies (which enablers it depends on)
   → Identify what it enables (use cases, other enablers)
   → Define completion criteria (Definition of Done)

5. Organize enablers by priority:
   → Critical (blockers for core functionality)
   → High Priority (should have for production)
   → Nice to Have (improvements and optimizations)

6. Create dependency graph:
   → Map enabler-to-enabler dependencies
   → Map enabler-to-use-case dependencies
   → Identify parallel execution opportunities

7. Estimate costs (if applicable):
   → Monthly cost estimates per enabler
   → Total PoC/MVP cost projection

8. Define implementation phases:
   → Phase 1: Foundation (Week 1-2)
   → Phase 2: Core Stack (Week 2-3)
   → Phase 3: Quality & DevOps (Week 3-4)

9. Create related documentation:
   → For each enabler, create folder: specs/enablers/EN-XX/
   → Minimum files: EN-XX-specification.md
   → Optional: plan.md, tasks.md, research.md

10. Cross-reference documents:
    → Link to use-cases-overview.md
    → Link to BRD.md
    → Link to architecture.md

11. Validate completeness:
    → All NFRs covered by enablers
    → All infrastructure mentioned in BRD has an enabler
    → Dependencies form a valid DAG (no cycles)

12. Delete section: Execution Flow (for AI agents)
13. Return: SUCCESS (Enablers overview ready for review)
```

### Related Files and Locations
```
Enablers Overview Location:
→ specs/enablers/enablers-overview.md

Individual Enabler Folders:
→ specs/enablers/EN-XX-name/
  ├── EN-XX-specification.md (required)
  ├── plan.md (optional - implementation plan)
  ├── tasks.md (optional - task breakdown)
  └── research.md (optional - investigation notes)

Reference Documents:
→ docs/BRD.md (business requirements)
→ specs/use-cases/use-cases-overview.md (use case dependencies)
→ ../.ai_project_memory/general-overview.md (project context)
→ ../.ai_project_memory/architecture.md (system architecture)
```

---

## Enabler Status Summary

### Status Legend
- **Verified**: Implementation complete and verified with test report
- **Implemented**: Code complete, awaiting verification
- **Planned**: Specification complete, not yet implemented

| Enabler | Name | Status |
|---------|------|--------|
| EN-01 | [Enabler Name] | [Verified/Implemented/Planned] |
| EN-02 | [Enabler Name] | [Verified/Implemented/Planned] |
| EN-03 | [Enabler Name] | [Verified/Implemented/Planned] |

---

## Critical Enablers (Blockers)

### EN-01: [Enabler Name]

**BRD Mapping**: [NFR-XX, Section X]
**Description**: [One paragraph describing what this enabler provides and why it's critical]

**Components**: [List key components, e.g., "Resource Group, Managed Identity, Key Vault"]
**Depends On**: [None or list of enabler IDs]
**Enables**: [List of enabler IDs and/or use case IDs that depend on this]

---

### EN-02: [Enabler Name]

**BRD Mapping**: [FR-XXXX, NFR-XX]
**Description**: [One paragraph describing what this enabler provides]

**Components**: [List key components]
**Depends On**: EN-01
**Enables**: [List of enabler/use case IDs]

---

## High Priority Enablers (Should Have)

### EN-XX: [Enabler Name]

**BRD Mapping**: [FR-XXXX, NFR-XX]
**Description**: [One paragraph describing what this enabler provides]

**Components**: [List key components]
**Depends On**: [List of enabler IDs]
**Enables**: [What this enables]

---

## Nice to Have Enablers (Could Have)

### EN-XX: [Enabler Name]

**BRD Mapping**: [FR-XXXX, NFR-XX]
**Description**: [One paragraph describing what this enabler provides]

**Components**: [List key components]
**Depends On**: [List of enabler IDs]
**Enables**: [What this enables]

---

## Enabler Dependencies

[List all enabler dependencies in a clear format]

- **EN-01**: [Name] (no dependencies)
- **EN-02**: [Name] → depends on EN-01
- **EN-03**: [Name] → depends on EN-01, EN-02
- **UC-XX**: [Name] → depends on EN-XX, EN-XX

---

## Technology Stack Summary

| Component | Technology | Enabler |
|-----------|------------|---------|
| **[Category]** | [Technology/Tool] | EN-XX |
| **[Category]** | [Technology/Tool] | EN-XX |
| **[Category]** | [Technology/Tool] | EN-XX |

---

## Implementation Phases

### Phase 1: Foundation (Week X)
- **EN-01**: [Brief description of work]
- **EN-02**: [Brief description of work]

### Phase 2: Application Stack (Week X)
- **EN-03**: [Brief description of work]
- **EN-04**: [Brief description of work]

### Phase 3: Quality & DevOps (Week X)
- **EN-05**: [Brief description of work]
- **EN-06**: [Brief description of work]

---

## Cost Estimates

| Enabler | Monthly Cost | Notes |
|---------|-------------|-------|
| EN-01 | $X-Y | [Brief explanation] |
| EN-02 | $X-Y | [Brief explanation] |
| **Total** | **$X-Y/month** | [Phase/environment] estimate |

---

## Definition of Done (All Enablers)

### EN-01: [Enabler Name]
- [ ] [Completion criterion 1]
- [ ] [Completion criterion 2]
- [ ] [Completion criterion 3]

### EN-02: [Enabler Name]
- [ ] [Completion criterion 1]
- [ ] [Completion criterion 2]
- [ ] [Completion criterion 3]

---

## Enablers vs Use Cases

| Type | Purpose | Example |
|------|---------|---------|
| **Enabler** | Infrastructure, frameworks, testing | EN-01 to EN-XX |
| **Use Case** | User-facing functionality | UC-01 to UC-XX |

**Key distinction**:
- **Enablers** provide technical capabilities (no direct user interaction)
- **Use Cases** implement user-facing features
- Backend framework is typically an Enabler (EN-XX)
- Frontend framework is typically a Use Case (UC-01) since it defines user experience

---

## Related Documentation

- **Use Cases**: [../use-cases/use-cases-overview.md](../use-cases/use-cases-overview.md)
- **Domain Model**: [../domain-model/domain-model-overview.md](../domain-model/domain-model-overview.md)
- **Design System**: [../design/design-system.md](../design/design-system.md)
- **Business Requirements**: [../../docs/BRD.md](../../docs/BRD.md)
- **Project Overview**: [../../../.ai_project_memory/general-overview.md](../../../.ai_project_memory/general-overview.md)
- **Architecture**: [../../../.ai_project_memory/architecture.md](../../../.ai_project_memory/architecture.md)

---

**Document Version**: 1.0
**Last Updated**: [YYYY-MM-DD]
