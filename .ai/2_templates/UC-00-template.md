# UC-[NN]: [Use Case Name]

**Priority**: [Critical | High | Medium | Low]
**Route/Location**: [URL path, screen name, or module location]

---

## Use Case Generation Workflow

*This section describes how to create a use case document using this template. Remove this section from the final use case document.*

### Step 0: Create Use Case Folder
1. Create folder: `specs/use-cases/UC-NN/` (e.g., `specs/use-cases/UC-01/`)
2. Copy this template to: `specs/use-cases/UC-NN/UC-NN-kebab-case-title.md`
3. Folder structure after completion:
   ```
   specs/use-cases/UC-NN/
   ├── UC-NN-kebab-case-title.md  # Use case specification (this file)
   ├── plan.md                     # Implementation plan (/plan command)
   ├── research.md                 # Research findings (/plan command)
   └── tasks.md                    # Implementation tasks (/tasks command)
   ```

### Step 1: Gather Source Documents
1. Read `docs/BRD.md` - Extract functional requirements (FR-xxxx) and NFRs mapped to this use case
2. Read `specs/use-cases/use-cases-overview.md` - Get use case number, title, description, and BRD mappings
3. Read `specs/design/design-system.md` - Load design specifications and component references (DS-xxx)
4. Read `../.ai_project_memory/constitution.md` - Understand project-wide NFRs (don't duplicate here)

### Step 2: Complete Header and Traceability
1. Fill header: UC number, title, priority, route/location
2. Complete BRD Traceability table: Map FR-xxxx and NFR-xx from BRD to this use case
3. For technical enablers without direct BRD requirements, document indirect support

### Step 3: Write User Story and Description
1. User Story: Follow "As a [role] I want to [action] So that [benefit]" format
2. Description: Expand on what, why, and how it fits into the system
3. Actors: List all actors (users, system, external services)

### Step 4: Define Flows and Requirements
1. Preconditions: What must be true before this use case begins
2. Main Flow: Numbered happy path steps
3. Functional Requirements: Use `[FR-xxxx.x]` format with BRD traceability
4. Alternative Flows: Variations from main flow
5. Exception Flows: Error conditions and handling

### Step 5: Document NFRs (Use Case Specific Only)
1. Include ONLY NFRs specific to this use case (measurable, testable)
2. Use `[NFR-xx.x]` for performance/scalability, `[DS-xxx]` for design system
3. Do NOT include generic architecture NFRs (they belong in constitution.md)
4. Leave section empty if no UC-specific NFRs apply

### Step 6: Complete Supporting Sections
1. Postconditions: System state after successful completion
2. Business Value: Benefits delivered (quantify if possible)
3. UI/UX Notes: Design patterns, layout, accessibility (reference design-system.md)
4. Data Requirements: Entities, fields, relationships
5. External Dependencies: APIs, services, libraries (use bullet list)

### Step 7: Write Acceptance Criteria
1. Remove the bracketed instruction placeholder text
2. Reference all FR-xxxx.x and NFR-xx.x IDs from this document
3. Group by functional area (e.g., Layout, Navigation, Accessibility)
4. Ensure each criterion is testable and verifiable

### Step 8: Add Related Items
1. Related Use Cases: Dependencies and related features
2. Related Features: Enabler specs (EN-xx)
3. Related ADRs: Architectural decisions

### Quality Checklist (before finalizing)
- [ ] Use case folder created: `specs/use-cases/UC-NN/`
- [ ] File follows naming convention: `UC-NN/UC-NN-kebab-case-title.md`
- [ ] All template sections filled (no placeholder text like "[TODO]")
- [ ] BRD Traceability table completed
- [ ] Requirement IDs use correct format ([FR-xxxx.x], [NFR-xx.x], [DS-xxx])
- [ ] Use Case Specific NFRs contain only UC-specific items (or empty if none)
- [ ] Acceptance Criteria reference all FRs and NFRs
- [ ] Bracketed instruction text removed from Acceptance Criteria
- [ ] No personal names (use roles instead)

---

## BRD Traceability

*Link this use case to Business Requirements Document (BRD) requirements for traceability.*

| BRD Requirement | Description | UC Support |
|-----------------|-------------|------------|
| **FR-xxxx** | [Requirement name] | [How this UC implements/supports it] |
| **NFR-xx** | [Requirement name] | [How this UC addresses it] |

*Note: For technical enabler UCs without direct BRD requirements, document which BRD requirements the enabler supports indirectly.*

## User Story

**As a** [type of user or role]
**I want to** [perform some action or achieve some goal]
**So that** [realize some business value or benefit]

## Description

[Provide a brief overview of the use case. Describe what this functionality does, why it exists, and how it fits into the larger system. Include key context that helps understand the purpose and scope.]

## Actors

- **[Actor Name]**: [Description of the actor's role and responsibilities in this use case]
- **[Actor Name]**: [Description of another actor if applicable]

## Preconditions

[List any conditions that must be true before this use case can begin:]

- [Precondition 1]
- [Precondition 2]

## Main Flow

[Describe the primary happy path through the use case. Number each step:]

1. [Actor] performs [action]
2. System [responds or processes]
3. [Actor] [next action]
4. System [final result or state change]

## Functional Requirements

[Categorized list of functional requirements with BRD traceability. Use `[FR-xxxx.x]` format for requirement IDs.]

*BRD references: [FR-xxxx (Requirement Name), FR-yyyy (Requirement Name)]*

### [Category 1 - e.g., Core Functionality]
- **[FR-xxxx.1]**: [Requirement description]
- **[FR-xxxx.2]**: [Requirement description]

### [Category 2 - e.g., Data Integration]
- **[FR-yyyy.1]**: [Requirement description]
- **[FR-yyyy.2]**: [Requirement description]

### [Category 3 - e.g., State Management]
- **[FR-zzzz.1]**: [Requirement description]

## Use Case Specific NFRs

[Quality attributes and constraints **specific to this use case only**. This section captures measurable, testable NFRs that are unique to this use case's functionality.]

**What belongs here:**
- Use case-specific performance targets (e.g., "Filter selection applies to data within 200ms")
- Specific scalability limits (e.g., "Support up to 500 sensors in dropdown")
- Feature-specific accessibility requirements beyond baseline WCAG 2.1 AA

**What does NOT belong here** (belongs in project constitution/memory instead):
- Generic architecture NFRs (e.g., "Consistent naming conventions across codebase")
- Project-wide standards (e.g., "Test coverage > 80%")
- General maintainability requirements

*This section may be empty if no use case-specific NFRs apply. Generic project NFRs are defined in `../.ai_project_memory/constitution.md`.*

*BRD references: [NFR-xx (Requirement Name)] - if applicable*

*Design System references: [DS-xxx (Component/Pattern)] - if applicable*

### Performance *(if applicable)*
- **[NFR-xx]** [Specific metric, e.g., "Dropdown renders in < 200ms with 1000 items"]

### Scalability *(if applicable)*
- **[NFR-xx]** [Specific limit, e.g., "Support up to 500 sensors per building"]

### Accessibility *(if applicable)*
- **[DS-xxx]** [Feature-specific requirement beyond baseline WCAG 2.1 AA]

## Alternative Flows

[Describe deviations from the main flow, including error conditions and edge cases]

### [Alternative Flow Name 1]

[Description of what happens in this alternative scenario]

### [Alternative Flow Name 2]

[Description of another alternative scenario]

## Exception Flows

[Optional section for error handling and failure scenarios]

### [Exception Name]

**Trigger**: [What causes this exception]
**Handling**: [How the system responds]

## Postconditions

[List the state of the system after successful completion:]

- [Postcondition 1]
- [Postcondition 2]

## Business Value

[Explain the business benefits and value delivered by this use case:]

- [Benefit 1 - quantify if possible]
- [Benefit 2 - explain impact]
- [Benefit 3 - describe value to users or organization]

## UI/UX Notes

[Optional section for interface-specific guidance]

- [Design pattern or component to use]
- [Layout considerations]
- [Accessibility requirements]
- [Mobile/responsive behavior]

## Data Requirements

[Optional section describing data entities and their relationships]

- **[Entity Name]**: [Required fields, validation rules, relationships]
- **[Entity Name]**: [Required fields, validation rules, relationships]

## External Dependencies

[List any external systems, APIs, or services required]

- **[Dependency Name]**: [Purpose and integration points]
- **[Dependency Name]**: [Purpose and integration points]

## Acceptance Criteria

[Definition of Done for this use case. All listed Functional Requirements and Use Case Specific NFRs must be met. Include additional completion criteria required before client review.]

*Note: Remove the bracketed instruction text above when writing actual use cases. Keep only the bullet points below, customized for the specific use case.*

- All Functional Requirements ([FR-xxxx.x]) listed above are implemented and tested
- All Use Case Specific NFRs ([NFR-xx], [DS-xxx]) listed above are verified
- UI matches design system specifications
- Error handling implemented for all exception flows
- [Additional use-case-specific criteria]

---

**Related Use Cases**: [UC-XX Name], [UC-YY Name]
**Related Features**: [Link to feature specs if applicable]
**Related ADRs**: [Link to architectural decision records if applicable]
