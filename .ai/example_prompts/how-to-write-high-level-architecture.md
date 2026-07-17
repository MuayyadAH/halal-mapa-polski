# How to Write High-Level Architecture Documentation

This guide explains how to create comprehensive high-level architecture documentation for software projects.

## Quick Start

Use this prompt to create architecture documentation:

```
Create a high-level architecture document for [PROJECT_NAME].

Context:
- Customer: [CUSTOMER_NAME]
- Purpose: [Brief description]
- Key technologies: [Tech stack]
- Integration points: [External systems]

Use the high-level-architecture-template.md from .ai/2_templates/ as the structure.
Save to docs/architecture/high-level-architecture.md
```

## Document Structure

The high-level architecture template includes these sections:

### 1. Executive Summary
- Purpose and scope
- Key recommendations table
- Decision areas with confidence levels

### 2. Business Context
- Business drivers with priorities
- Stakeholders (RACI-style)
- Impacted business processes

### 3. Requirements Analysis
- Functional requirements overview
- Quality attributes (NFRs) with measurable targets
- Constraints (regulatory, technical, organizational)
- Assumptions with risks

### 4. Current State Analysis (As-Is)
- Existing systems landscape
- Integration points
- Technical debt and pain points

### 5. Architecture Decision Records (ADRs)
- Context, options, evaluation criteria
- Weighted scoring matrix
- Recommendation with consequences

### 6. Target Architecture (To-Be)
- Architecture diagram (embedded)
- System context
- Architecture layers table
- Key components

### 7-14. Supporting Sections
- Integration architecture
- Security architecture
- Infrastructure and deployment
- Operations and observability
- Risk assessment
- Roadmap and phasing
- Cost estimation
- Decision points and next steps

## Example Prompts

### Creating from Scratch
```
Create a high-level architecture document for a web application that:
- Visualizes IoT sensor data
- Uses React frontend and NestJS backend
- Integrates with Databricks for data storage
- Uses Azure AD for authentication
- Deploys to Azure Container Apps

Include architecture diagram using PlantUML.
```

### Updating Existing Document
```
Update the high-level architecture document at docs/architecture/high-level-architecture.md:
- Add a new ADR for caching strategy (Redis vs in-memory)
- Update the risk assessment section
- Add cost estimates for the new caching layer
```

### Creating Architecture Diagram
```
Create an architecture diagram for the high-level architecture document.
Include: UI, Backend, Database, Identity, Cloud Services, CI/CD.
Use the architecture-diagram-template.md for styling.
Embed in the Target Architecture section with PlantUML source in a details block.
```

## Best Practices

### 1. Keep Decisions Traceable
Link ADRs to specific requirements:
```markdown
| Decision Area | Recommended Option | Rationale |
|--------------|-------------------|-----------|
| Database | PostgreSQL | Supports FR-007 ACID requirements |
```

### 2. Use Measurable Targets
```markdown
| Attribute | Requirement | Measurable Target |
|-----------|-------------|-------------------|
| Performance | Response time | < 200ms for 95th percentile |
```

### 3. Embed Diagrams with Source
```markdown
![Architecture](./architecture.png)

<details>
<summary>PlantUML Source</summary>

\`\`\`plantuml
@startuml
...
@enduml
\`\`\`

</details>
```

### 4. Include Cost Estimates
```markdown
| Component | Sizing | Estimated Cost |
|-----------|--------|----------------|
| Compute | 2 vCPU, 4GB | $50/month |
| Database | Standard | $30/month |
| **Total** | | **$80/month** |
```

### 5. Document Risks with Mitigations
```markdown
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Query latency > 3s | Medium | High | Add caching layer |
```

## Section Completion Order

| Phase | Sections to Complete |
|-------|---------------------|
| Discovery | 2. Business Context, 3. Requirements, 4. Current State |
| Architecture | 5. ADRs, 6. Target Architecture, 7. Integration, 8. Security |
| Planning | 9. Infrastructure, 10. Operations, 12. Roadmap, 13. Costs |
| Review | 1. Executive Summary, 11. Risks, 14. Next Steps |

## Related Templates

- `.ai/2_templates/high-level-architecture-template.md` - Full document template
- `.ai/2_templates/architecture-diagram-template.md` - PlantUML diagram styling
- `.ai/2_templates/adr-template.md` - Standalone ADR template
