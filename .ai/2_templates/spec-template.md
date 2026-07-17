# [Feature Name] Specification

**Feature Branch**: `[ID-feature-name]`
**Created**: [YYYY-MM-DD]
**Status**: Draft | In Review | Approved
**Priority**: High | Medium | Low
**Input**: User description: "$ARGUMENTS"
<!-- Nortal Enhancement: Added Jira Ticket field -->
**Jira Ticket**: [JIRA-ID] *(optional - if fetched via Atlassian MCP)*

---

## Specification Workflow
<!-- Nortal Enhancement: Added Specification Workflow section -->
**Focus**:
<!-- Nortal Enhancement: Added Focus and removed Quick Guidelines -->
WHAT users need and WHY (avoid HOW to implement - no tech stack, APIs, code structure). Written for business stakeholders, not developers.Maintain traceability to source documents (Business Requirements Document, Specification documents, Jira, Confluence, Figma). Produc clear, testable, and unambiguous requirements. Maintain status in Execution Flow (main)

## Execution Flow (main)
<!-- Nortal Enhancement: Enhanced execution flow with phases, context loading, ambiguity categories, Socratic dialogue, and domain model integration -->
```
PHASE 1 - Content Gathering: 
1. Load context from project documentation
2. Parse user description from Input
   → If empty: ERROR "No feature description provided"
3. Extract key concepts from description
   → Identify: actors, actions, data, constraints

PHASE 2: Specification Building (steps can be approached in order that suits feature type):
3. Fill Workflow section (User scenarios, optional Test Cases and Edge Cases)
   → If no clear user flow: ERROR "Cannot determine workflow"
   → Mark unclear aspects inline: <!-- TODO: [NEEDS CLARIFICATION: specific question] -->
   → Don't guess - if prompt doesn't specify, mark it
4. Generate Functional Requirements
   → Customer requirements are priority
   → Each requirement must be testable
   → Link to Business requirement or customer requirement for traceability where applicable {Source: BRD, ID: FR001}. Indicate if requirement is AI generated {Source: AI/Specify}.
   → Mark ambiguous requirements inline: <!-- TODO: [NEEDS CLARIFICATION: specific question] -->
5. Complete all mandatory sections
   → Section 1: Primary User Story (As a [user type], I want to [action], So that [benefit])
   → Section 2: Details (Problem statement + Clarifications subsection)
   → Section 7: Solution Overview (2-3 paragraphs, business-level description, no technical details)
   → Section 12: References (Project context + related specs + external references)
6. Identify optional sections based on feature type:
   → Key Entities (if data involved) - reference `docs/ai/12_spec/_system-wide/data-model.md`
   → UX Considerations (if user interface involved)
   → Integration Context (if external systems involved)
   → Feature-Specific Constraints (if applicable)
   → Mark unclear aspects inline: <!-- TODO: [NEEDS CLARIFICATION: specific question] -->
   
PHASE 3 - Requirement Clarification:
7. Analyze ambiguities
   7.1 Analyze against categories:
       → Functional Scope, Domain Model, User Roles, Validation, Edge Cases, Feature specific NFRs, Integration, Assumptions, UX Journey, Traceability, Deferred Decisions
   7.2 For each unclear aspect:
       → Mark with inline comment: <!-- TODO: [NEEDS CLARIFICATION: specific question] -->
   7.3 Prioritize by impact
       → Critical (blocks architecture/data model/core behavior)
       → Important (affects edge cases/validation/user flow)
       → Deferrable (can be resolved during planning phase)
7A. Check for Requirement Conflicts (MANDATORY)
   7A.1 Load all existing specifications:
       → Read specs/use-cases/use-cases-overview.md for UC list
       → Read specs/enablers/enablers-overview.md for EN list
       → Load all UC-XX/*.md and EN-XX/*.md specification files
   7A.2 Compare new requirements against existing ones:
       → Check for logical conflicts in functional requirements
       → Check for conflicting defaults (e.g., default values, initial states)
       → Check for conflicting behaviors (e.g., validation rules, data formats)
       → Check for conflicting constraints (e.g., time ranges, data limits)
       → Check for conflicting non-functional requirements (e.g., performance targets)
   7A.3 Document conflicts found:
       → For each conflict: [NEW-REQ-ID] conflicts with [EXISTING-SPEC:REQ-ID]
       → Describe the conflict clearly
       → Propose resolution (update new req, update old req, or both)
   7A.4 If conflicts found:
       → Mark spec status as "Has Conflicts - Needs Resolution"
       → Document conflicts in Section 2 (Details) → Requirement Conflicts subsection
       → STOP - conflicts must be resolved before proceeding
   7A.5 If no conflicts found:
       → Document in Section 2: "Requirement conflict check completed - no conflicts found"
       → Proceed to next step
8. Conduct Socratic Dialogue (Phase 3 continues)
   8.1 Ask clarifying questions
       → Maximum 4 questions per round (single-step questions only)
       → Default 2 rounds, optional 3rd round if critical gaps remain (ask from user if needed/allowed)
   8.2 Document Q&A
       → Record all Q&A with timestamps in Clarifications section
   8.3 Mark deferred decisions
       → Include rationale and resolution phase (Planning/Architecture/Implementation)
9. Run Review Checklist
   9.1 Check for clarity issues
       → If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
       → If implementation details found: ERROR "Remove tech details"
   9.2 Verify completeness
       → All mandatory sections completed
       → All Q&A documented with timestamps
   9.3 Verify traceability
       → BRD/Jira/Confluence/Figma references included (if applicable)
   9.4 Verify no requirement conflicts remain
       → If conflicts found in step 7A: ERROR "Conflicts must be resolved"
       → All conflicts documented and resolved
10. Clean up generated specification
    → Remove all <!-- Nortal Enhancement: ... --> comment lines from generated spec
    → Remove "Specification Workflow" section from generated spec
    → Remove section annotations like *(optional)* and *(mandatory)* from headers
    → These are template documentation, not needed in final specification
11. Return with status
    → If requirement conflicts: "Has Conflicts - Needs Resolution"
    → If no TODO markers: "Ready for /ai1st-dev-plan"
    → If TODO markers remain: "Needs /ai1st-po-clarify"
    → SUCCESS (spec ready for planning)
```

**Section Requirements**:
- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

### For AI Generation
When creating this spec from a user prompt:
1. **Mark all ambiguities**: Use [NEEDS CLARIFICATION: specific question] for any assumption you'd need to make
2. **Don't guess**: If the prompt doesn't specify something (e.g., "login system" without auth method), mark it
3. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
4. **Common underspecified areas**:
   - User types and permissions
   - Data retention/deletion policies
   - Performance targets and scale
   - Error handling behaviors
   - Integration requirements
   - Security/compliance needs

---

**Tracking Open Items**:
<!-- Nortal Enhancement: Added open item tracking protocol with markers and rules -->

Use these markers to track incomplete or uncertain aspects during specification development:
- `<!-- TODO: [NEEDS CLARIFICATION: specific question] -->` - Mark sections needing user clarification
- `<!-- FIXME: section description and what's needed -->` - Mark sections needing rework or completion
- `[NEEDS CLARIFICATION: specific question]` - Inline marker for ambiguous requirements (use in FR descriptions)

**Tracking rules**:
<!-- Nortal Enhancement: Added open item tracking protocol with markers and rules -->
1. Every TODO/FIXME must include specific question or action needed
2. Document all Q&A in Section 2 (Details) → Clarifications subsection with timestamps
3. If TODO/FIXME markers remain after all clarification rounds, spec status is "Needs /ai1st-po-clarify"
4. Deferred decisions must be documented in Section 3 with rationale and resolution phase
5. Before marking spec complete, verify no TODO/FIXME markers remain (or all are explicitly deferred)

---

## 1. Primary User Story *(mandatory)*
<!-- Nortal Enhancement: Clarified structure and terminology -->
[Describe the main user journey in plain language. Start with standard user story format: As a [user type] I want to [action] So that [benefit]].

## 2. Details *(optional)*

**Problem:** [What problem does this feature solve?]

**Requirement Conflicts:** *(auto-populated during Phase 3, Step 7A)*
<!-- This subsection documents any conflicts found between new requirements and existing specifications -->
<!-- Format: [NEW-REQ-ID] conflicts with [EXISTING-SPEC:REQ-ID] - Description - Proposed Resolution -->
<!-- Example: FR-003 conflicts with UC-03:FR-1003.5 - Both specify different default time ranges (24h vs 7d) - Resolution: Update UC-03 to align with UC-15 -->
<!-- If no conflicts: "Requirement conflict check completed - no conflicts found (checked against all UC-XX and EN-XX specifications on YYYY-MM-DD)" -->

<!-- Nortal Enhancement: ?? -->
## 3. Workflow *(mandatory)*

**Business Workflow:** *(mandatory)*
- Step 1: [User action/system response]
- Step 2: [User action/system response]

**Test Cases / Acceptance Scenarios:** *(mandatory)*
<!-- Nortal Enhancement: Changed format, added identifiers -->
- **TC-1:** [Test case name] - Given [context], when [action]
    - then [expected result]
    - and [additional result]
    {Source: UX Spec, ID: UC001}
- **TC-2:** [Test case name] - Given [context], when [action]
    - then [expected result]
    {Source: UX Spec, ID: UC002}

**Edge Cases:** *(mandatory)*
<!-- Nortal Enhancement: Added Linked Q&A -->
- What happens when [boundary condition]? [Answer from Q&A]
- How does system handle [error scenario]? [Answer from Q&A]

---

## 4. Requirements *(mandatory)*
<!-- Nortal Enhancement: Added Customer Requirements subsection -->
**Requirement Documents:** 
Link to source requirements for traceability:
- **BRD:** [Name & Date] - [path/url]
- **Jira Project/Board:** [Name & Date] - [path/url]
- **Confluence Use case/requirements page:** [Name & Date] - [path/url]
- **Figma design:** [Name & Date] - [path/url]

**Functional Requirements:**
- **FR-001**: System MUST [specific capability, e.g., "allow users to create accounts"] {Source: [UX Spec], ID: [UX-ID]}
- **FR-002**: System MUST [specific capability, e.g., "validate email addresses"]{Source: [BRD], ID: [BR-ID]}
- **FR-003**: Users MUST be able to [key interaction, e.g., "reset their password"]{Source: [Sys Spec], ID: [SYS-ID]}
- **FR-004**: System MUST [data requirement, e.g., "persist user preferences"]{Source: [AI], ID: [N/A]}
- **FR-005**: System MUST [behavior, e.g., "log all security events"]{Source: [AI], ID: [N/A]}

*Example of marking unclear requirements:*
- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

**Feature-Specific Non-Functional Requirements (NFRs):**

**Note:** Include only NFRs specific to this feature. General project NFRs are defined in `docs/ai/10_project_context/*`.

- **NFR-001**: [Feature-specific performance requirement, e.g., "Search results MUST return within 2 seconds for up to 10,000 records"]
- **NFR-002**: [Feature-specific scalability requirement, e.g., "System MUST support 100 concurrent users for this feature"]
- **NFR-003**: [Feature-specific security requirement, e.g., "User data MUST be encrypted at rest using AES-256"]
- **NFR-004**: [Feature-specific availability requirement, e.g., "Feature MUST have 99.9% uptime during business hours"]

<!-- Nortal Enhancement: Added Out of Scope subsection -->
**Out of Scope:** *(optional)*

Explicitly document what is NOT included:
- **[Feature/Capability]** - [Rationale for exclusion]
- **[Feature/Capability]** - [Rationale for exclusion]


<!-- Nortal Enhancement: Added Clarifications section for recording Q&A -->
**Clarifications:** *(auto-populated during dialogue)*
- YYYY-MM-DD Q: [question] → A: [answer]
- YYYY-MM-DD Q: [question] → A: [answer]

---

<!-- Nortal Enhancement: Added Deferred Decisions section -->
## 5. Deferred Decisions *(optional)*

Document decisions that can be resolved in later phases:

- **Item:** [Deferred decision] - **Rationale:** [Why deferred] - **Resolution phase:** Planning | Architecture | Implementation
---

## 6. Definition of Done *(mandatory)*

- All functional requirements (FR-001 to FR-XXX) implemented and verified
- All test cases (TC-001 to TC-XXX, if defined in Section 4) pass
- Edge cases (if defined in Section 4) handled and tested
<!-- Nortal Enhancement: Added additional DoD criteria -->
- User acceptance testing completed (if applicable)
- Integration with dependent services verified (if applicable)
- Security testing completed (if applicable)
- Accessibility testing completed (if applicable)
- Documentation completed (if applicable)

---

## 8. Key Entities *(optional - include if feature involves data)*

<!-- Nortal Enhancement: Enhanced entity documentation format -->
**Data Model Reference:**
- System-wide model: `docs/ai/12_spec/_system-wide/data-model.md` (if exists)
- Feature-specific entities below:

**[Entity Name]:** [What it represents]
- **Purpose:** [Business purpose]
- **Key attributes:** [Business-relevant attributes without types]
- **Relationships:** [Relations to other entities]

**[Entity Name]:** [What it represents]
- **Purpose:** [Business purpose]
- **Key attributes:** [Business-relevant attributes without types]
- **Relationships:** [Relations to other entities]

---

<!-- Nortal Enhancement: Added UX Considerations section -->
## 9. UX Considerations *(optional - include if feature involves user interface)*

**Note:** This section captures business-level user experience needs, NOT technical UI specifications (defer to architecture phase).

**User Interface Context:**
- **Primary user actions:** [What users need to do]
- **User journey touchpoints:** [Where feature appears in user flow]
- **Accessibility needs:** [Business requirements for accessibility]
- **Usability considerations:** [Business expectations for ease of use]

**Design References:** *(if available)*
- Figma: [Link to design file]
- Confluence: [Link to design documentation]
- Design system: [Relevant design patterns to follow]

---

<!-- Nortal Enhancement: Added Integration Context section -->
## 10. Integration Context *(optional - include if feature involves external systems)*

**Note:** This section describes WHAT systems to integrate with and WHY, NOT HOW to integrate (defer to architecture phase).

**External Systems:**
- **[System Name]:** [What it provides]
  - **Business purpose:** [Business value of integration]
  - **Data exchange:** [What information flows between systems]
  - **Timing:** [When integration occurs in user/business flow]

**Integration Constraints:**
- [Any business-level constraints on integration approach]

---

<!-- Nortal Enhancement: Added Feature-Specific Constraints section -->
## 11. Feature-Specific Constraints *(optional)*

**Note:** General project constraints, NFRs, and technical standards are defined in: `docs/ai/10_project_context/*`

This section covers ONLY feature-specific constraints:

**FC-1:** [Feature-Specific Constraint]
- **Description:** [What constraint is unique to this feature]
- **Impact:** [How it affects implementation]

### Feature-Specific Assumptions

**FA-1:** [Feature Assumption]
- [Assumption description]
- [Validation plan]

---

<!-- Nortal Enhancement: Enhanced References section -->
## 12. References *(mandatory)*

**Project Context:**
- Project Context: `docs/ai/10_project_context/project-context.md`
- Business Requirements: `docs/ai/10_project_context/business-requirements.md` (if exists)
- Domain Model: `docs/ai/12_spec/_system-wide/data-model.md` (if exists)
- **Constitution**: `.ai_project_memory/constitution.md` - Architectural principles and constraints
  - Frontend features: Must comply with Principles I-X (Provider hierarchy, component-page integration, accessibility, DAL abstraction, TypeScript strict mode, i18n ready)

**Related Specifications:**
- [List other related feature specs]

**External References:** *(if available)*
- Confluence Documentation: [Links to related pages]
- Jira Issues: [Links to related tickets]
- Figma Designs: [Links to design files]

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

<!-- Nortal Enhancement: Added Traceability & Context checklist section -->
### Traceability & Context
- [ ] BRD requirements linked (if BRD exists)
- [ ] Jira/Confluence references included (if applicable)
- [ ] Figma designs referenced (if applicable)
- [ ] All clarifications documented with timestamps
- [ ] Deferred decisions documented (if any)

---

## Execution Status
*Updated by main() during processing*

- [ ] User description parsed
- [ ] Key concepts extracted
- [ ] Ambiguities marked
- [ ] User scenarios defined
- [ ] Requirements generated
- [ ] Entities identified
- [ ] Review checklist passed

---
