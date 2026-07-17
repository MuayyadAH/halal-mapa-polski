# ADR-[NNN]: [Decision Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]

## Context
[Describe the forces at play, including technological, business, and project-specific constraints. Explain why a decision needs to be made. Include:]

- [Key requirement or problem to solve]
- [Relevant constraints (timeline, budget, team expertise)]
- [Technical requirements that influence the decision]
- [Business drivers or stakeholder needs]

## Decision
We will use **[chosen option/technology/approach]** for [specific purpose].

[Optionally expand with a brief rationale summary]

## Consequences

### Positive
- **[Benefit 1]**: [Explanation]
- **[Benefit 2]**: [Explanation]
- **[Benefit 3]**: [Explanation]

### Negative
- **[Drawback 1]**: [Explanation and mitigation if applicable]
- **[Drawback 2]**: [Explanation and mitigation if applicable]

## Alternatives Considered
- **[Alternative 1]**: [Why not chosen - brief explanation]
- **[Alternative 2]**: [Why not chosen - brief explanation]
- **[Alternative 3]**: [Why not chosen - brief explanation]

---

## Execution Flow (for AI agents)
```
1. Identify the decision needed:
   → What specific technology, pattern, or approach requires a decision?
   → Why does this need to be documented as an ADR?
   → Is this a significant, cross-cutting decision with long-term impact?

2. Gather context:
   → What are the business requirements driving this decision?
   → What are the technical requirements and constraints?
   → What is the timeline and team expertise?
   → Are there existing patterns or conventions to follow?

3. Research alternatives:
   → Identify 2-4 viable options
   → Evaluate each against requirements
   → Consider: performance, scalability, maintainability, cost, learning curve
   → Document pros/cons for each

4. Make the decision:
   → Select the option that best fits requirements and constraints
   → Be explicit about the choice
   → Summarize the key rationale

5. Document consequences:
   → List 2-5 positive consequences (benefits)
   → List 1-3 negative consequences (trade-offs)
   → Include mitigation strategies for negatives where possible

6. Document alternatives:
   → List alternatives considered
   → Briefly explain why each was not chosen
   → This provides context for future readers

7. Set status:
   → "Proposed" for decisions pending approval
   → "Accepted" for approved decisions
   → "Deprecated" for decisions no longer in use
   → "Superseded by ADR-XXX" when replaced by another decision

8. File naming:
   → Use format: ADR-NNN-[descriptive-title].md
   → Example: ADR-001-visualization-library.md
   → Place in: docs/architecture/ or similar location

9. Validate ADR quality:
   → Is the context clear enough for someone unfamiliar with the project?
   → Is the decision explicit and actionable?
   → Are consequences balanced (not just positive)?
   → Are alternatives fairly represented?

10. Delete section: Execution Flow (for AI agents)
11. Return: SUCCESS (ADR ready for review)
```

---

## ADR Numbering Convention

| Range | Domain |
|-------|--------|
| ADR-001 to ADR-099 | Technology stack decisions (frameworks, libraries, platforms) |
| ADR-100 to ADR-199 | Architecture patterns and approaches |
| ADR-200 to ADR-299 | Infrastructure and deployment |
| ADR-300 to ADR-399 | Security and authentication |
| ADR-400 to ADR-499 | Data and integration |
| ADR-500 to ADR-599 | Development workflow and tooling |

## ADR Best Practices

1. **One decision per ADR**: Keep ADRs focused on a single decision
2. **Immutable once accepted**: Don't modify accepted ADRs; create new ones to supersede
3. **Context is key**: Future readers need to understand the constraints at decision time
4. **Be honest about trade-offs**: Document negative consequences clearly
5. **Keep it concise**: ADRs should be readable in 2-3 minutes
6. **Link related ADRs**: Reference other ADRs when decisions are related
7. **Update status**: Mark as Deprecated or Superseded when no longer current

## When to Create an ADR

Create an ADR when the decision:
- Has significant impact on system architecture
- Affects multiple components or teams
- Is difficult or costly to reverse
- Represents a departure from existing patterns
- Involves technology selection with long-term implications
- Resolves a contentious debate among team members

## When NOT to Create an ADR

Don't create an ADR for:
- Minor implementation details
- Decisions that are easily reversible
- Standard conventions already documented elsewhere
- Individual feature design choices (use design docs instead)
