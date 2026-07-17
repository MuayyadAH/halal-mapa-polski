# Generate Use Case Specification Files

## How to Use This Prompt

**Purpose**: This prompt orchestrates the generation of comprehensive use case specification files for all use cases defined in `specs/use-cases/use-cases-overview.md` using parallel documentation agents.

**When to Use**:
- You have a `use-cases-overview.md` file with a list of use cases
- You have a use case template at `.ai/2_templates/UC-00-template.md`
- You want to generate detailed specification files for all (or remaining) use cases

**How to Launch**:

Copy and paste the following command to your Claude Code session:

```
Read the prompt file at .ai/example_prompts/generate-use-cases.md and execute it.
Generate use case specification files for all use cases in specs/use-cases/use-cases-overview.md.
```

**Alternative (if you want to generate specific use cases only)**:

```
Read the prompt file at .ai/example_prompts/generate-use-cases.md and execute it.
Generate use case specification files only for UC-01, UC-02, and UC-03.
```

**What Happens**:
1. The orchestrator reads all source documents (BRD, overview, design system, template)
2. Scans filesystem to identify which use case files already exist
3. Launches 3 documentation agents in parallel to generate content for missing use cases
4. Receives generated markdown content from each agent
5. Writes the content to disk using Write tool (errors if write fails)
6. Repeats until all use cases have specification files

**Expected Output**:
- Individual `.md` files in `specs/use-cases/` directory
- Naming pattern: `UC-01-application-framework.md`, `UC-02-building-and-sensor-selection.md`, etc.
- Each file follows the template structure with all sections filled

**Progress Tracking**:
- Filesystem scanning (always enabled - checks existing files before each batch)
- Knowledge Graph MCP (if available - shows progress summaries)
- TodoWrite (optional - batch-level todos)

**Resumability**: If interrupted, simply re-run the same command. The orchestrator will skip already-generated files and continue with the remaining ones.

---

## Objective

Generate comprehensive use case specification files for all use cases defined in the project using parallel documentation agents.

## Input Documents

Read the following documents to gather requirements and context:

1. **Business Requirements**: `docs/BRD.md` - Contains detailed functional requirements
2. **Use Cases Overview**: `specs/use-cases/use-cases-overview.md` - Lists all use cases with requirement mappings
3. **Design System**: `specs/design/design-system.md` - Brand guidelines, UI components, design patterns (if available)

## Template

Use the template at `.ai/2_templates/UC-00-template.md` as the structure for each use case file.

**IMPORTANT**: The template contains a "Use Case Generation Workflow" section with step-by-step instructions and a quality checklist. Follow these steps when generating use case documents. Remove the workflow section from the final output.

## Output Requirements

Generate individual use case specification files in `specs/use-cases/` directory.

**File Naming Convention**: `UC-NN-kebab-case-title.md`

**Filename Generation**:
1. Extract use case number from overview (e.g., UC-01, UC-15)
2. Convert use case title to kebab-case (e.g., "Application Framework" → "application-framework")
3. Combine: `UC-01-application-framework.md`

## Instructions for Each Use Case

For each use case file, complete the following template sections:

### Header Section
- **UC-[NN]**: Use the title from use-cases-overview.md
- **Priority**: Extract from use case category in overview (Must Have = Critical/High, Should Have = High/Medium, Could Have = Medium/Low)
- **Route/Location**: Based on the use case type (extract from description or infer from context)

### BRD Traceability
Complete the traceability table linking this use case to BRD requirements:
- Map **FR-xxxx** (functional requirements) from BRD that this use case implements
- Map **NFR-xx** (non-functional requirements) from BRD that this use case addresses
- For each mapping, describe how the UC supports the requirement
- For technical enabler UCs without direct BRD requirements, document indirect support

### User Story
Extract user perspective from BRD requirements. Format:
- **As a** [user role from project context]
- **I want to** [main capability from use case description]
- **So that** [business value from BRD rationale]

### Description
Expand the brief description from use-cases-overview.md using:
- Detailed explanation from corresponding BRD requirements
- Context about why this feature exists
- How it fits into the overall system architecture

### Actors
Identify actors involved (extract from BRD and use case context):
- **Primary User**: Main user performing actions
- **System**: The application itself
- **External Systems**: Any backend services or third-party integrations
- **Other Stakeholders**: Additional actors relevant to the use case

### Preconditions
List what must be true before the use case can execute:
- User authentication state (if applicable)
- Required data availability
- Previous use case completion (if dependent)
- System state requirements

### Main Flow
Write numbered steps describing the happy path:
1. User performs initial action
2. System responds or validates
3. User provides additional input
4. System processes and displays result

### Functional Requirements
Extract from BRD requirements mapped to this use case:
- **Use `[FR-xxxx.x]` format** for requirement IDs (e.g., [FR-1002.1], [FR-1002.2])
- Group requirements by category (e.g., Core Functionality, Data Integration, State Management)
- List all mandatory requirements (SHALL/MUST keywords)
- Include recommended requirements (SHOULD keywords)
- Include BRD reference line: `*BRD references: [FR-xxxx (Requirement Name)]*`
- For technical enablers, use `[IMPL-xx]` format instead of `[FR-xxxx.x]`

### Alternative Flows
Describe variations from main flow:
- Optional user actions
- Different data conditions
- Configuration variants
- Edge cases

### Exception Flows
Document error conditions and handling:
- Network failures
- Invalid user input
- Missing or corrupt data
- Authorization failures
- System errors

### Postconditions
State of the system after successful completion:
- Data changes persisted
- UI state updated
- Any state synchronization (e.g., URL parameters)
- Notifications or logs generated

### Business Value
Explain benefits delivered by this use case:
- User productivity improvements
- Operational efficiency gains
- Cost savings
- Risk reduction
- Competitive advantages

### Use Case Specific NFRs
**IMPORTANT**: This section is for NFRs **specific to this use case only**, NOT generic architecture NFRs.

**What belongs here:**
- Use case-specific performance targets (e.g., "Dropdown renders in < 200ms with 1000 items")
- Specific scalability limits (e.g., "Support up to 500 sensors per building")
- Feature-specific accessibility requirements beyond baseline WCAG 2.1 AA

**What does NOT belong here** (belongs in `../.ai_project_memory/constitution.md` instead):
- Generic architecture NFRs (e.g., "Consistent naming conventions across codebase")
- Project-wide standards (e.g., "Test coverage > 80%")
- General maintainability requirements

**Format:**
- Use `[NFR-xx.x]` format for performance/scalability (e.g., [NFR-01.1], [NFR-01.2])
- Use `[DS-xxx]` format for design system references (e.g., [DS-704], [DS-701])
- Include BRD/DS reference lines where applicable
- Organize under subsections: Performance, Scalability, Accessibility (as applicable)
- **Leave section empty** (with note) if no UC-specific NFRs apply

### UI/UX Notes
Reference design-system.md for (if available):
- Brand colors and palette
- Typography specifications
- Component patterns
- Layout structure
- Accessibility requirements
- Responsive design considerations

### Data Requirements
Identify data entities involved:
- List primary data entities
- Describe relationships between entities
- Specify required fields and validation rules
- Note any data transformation requirements

### External Dependencies
List required integrations:
- External APIs or services
- Authentication providers
- Data storage systems
- Third-party libraries
- Other system components

### Acceptance Criteria
Write Definition of Done criteria that verify all requirements are met:

**Format:**
- Start with BRD reference line: `*BRD references: [FR-xxxx, NFR-xx, etc.]*`
- Start with Design System reference line: `*Design System references: [DS-xxx, etc.]*`
- Include standard preamble bullets:
  - All Functional Requirements ([FR-xxxx.x]) listed above are implemented and tested
  - All Use Case Specific NFRs ([NFR-xx.x], [DS-xxx]) listed above are verified
  - UI matches design system specifications
  - Error handling implemented for all exception flows
- **Group additional criteria by functional area** (e.g., Layout, Navigation, Accessibility, Performance)
- Reference specific requirement IDs: `[FR-1002.1] User can open building dropdown...`
- **Remove bracketed instruction placeholder text** from template
- Ensure each criterion is testable and verifiable

### Related Items
Link to related use cases:
- **Dependencies**: Use cases that must be implemented first
- **Related Features**: Use cases often used together
- **Future Enhancements**: Potential extensions or improvements

## Execution Strategy

**Use parallel documentation agents with orchestrator verification** to generate all use case files:

**Constraint**: Maximum 3 agents running concurrently at any time.

**Resilience Design**: This orchestration is designed to be **stateless** and **idempotent**, making it resilient to context compacting and interruptions. The orchestrator can be safely interrupted and restarted at any time.

**Orchestrator Responsibilities**:

1. **Initial Setup** (read documents once):
   - Read `docs/BRD.md` - Extract all functional requirements
   - Read `specs/use-cases/use-cases-overview.md` - Parse all use case entries
   - Read `specs/design/design-system.md` - Load design specifications (if available)
   - Read `.ai/2_templates/UC-00-template.md` - Load template structure
   - **Scan filesystem**: Check which `UC-NN-*.md` files already exist in `specs/use-cases/`
   - **Identify missing**: Compare existing files against overview to determine which use cases still need files
   - Calculate total batches needed: `ceil(missing_use_cases / 3)`
   - **Optional - If Knowledge Graph MCP available**: Store orchestration metadata:
     - Create entity: `UseCaseGeneration` with observations:
       - Total use cases: 20
       - Use case list: UC-01 through UC-20 with titles
       - Total batches: 7
       - Start timestamp
     - Create entities for each use case: `UC-01`, `UC-02`, etc. with status "pending" or "completed" (if file exists)

2. **Per-Batch Processing** (stateless - checks filesystem each iteration):
   - **Re-scan filesystem**: Verify current state (which files exist) before selecting next batch
   - **Optional - If Knowledge Graph MCP available**: Query use case entities to check status
   - **Identify remaining**: Determine which use cases still need files (not present on filesystem)
   - **Select next batch**: Choose next 3 missing use cases (or remaining if < 3)
   - For each use case in batch:
     - Extract use case details from overview (number, title, description, BRD mapping)
     - Extract relevant BRD requirements (filter by requirement IDs in BRD mapping)
     - Prepare targeted context package for this use case
   - Launch 3 documentation agents in parallel with pre-filtered context
   - **Wait for agent responses**: Each agent returns generated markdown content as a message
   - **Write files to disk**: For each agent response, use Write tool to save content to `specs/use-cases/UC-XX-[kebab-case-title].md` (Write tool will error if it fails)
   - **Optional - If Knowledge Graph MCP available**: Update use case entities with status "completed" for successfully written files
   - Proceed to next batch

3. **Final Verification**:
   - Scan `specs/use-cases/` directory for all `UC-NN-*.md` files
   - Compare against use-cases-overview.md to ensure all use cases have corresponding files
   - **Optional - If Knowledge Graph MCP available**: Query use case entities to generate completion summary
   - Report any missing use cases
   - **Optional - If Knowledge Graph MCP available**: Add completion timestamp to `UseCaseGeneration` entity

**Resilience Features**:

- **Stateless**: Orchestrator relies on filesystem state, not conversation memory
- **Idempotent**: Can be run multiple times safely - skips use cases that already have files
- **Resumable**: If interrupted, restart will continue from where it left off
- **No duplicate work**: Already-generated files are never regenerated
- **Context-compact safe**: If context is compacted mid-process, re-scanning filesystem restores state
- **Optional Knowledge Graph tracking**: If Knowledge Graph MCP is available, use it for session-level progress visibility and status queries (complementary to filesystem verification)

**Knowledge Graph MCP Integration** (Optional):

If Knowledge Graph MCP is available in the environment, use it for enhanced progress tracking:

**Checking Availability**:
- Attempt to use `mcp__knowledge-graph__read_graph` tool
- If successful, Knowledge Graph MCP is available
- If tool is not found, gracefully continue without Knowledge Graph tracking

**Entity Structure**:
```
UseCaseGeneration (main orchestration entity)
├─ observation: "Total use cases: 20"
├─ observation: "Total batches: 7"
├─ observation: "Start time: 2025-11-27T10:00:00Z"
├─ observation: "Status: in_progress"
└─ observation: "Completion time: 2025-11-27T10:45:00Z" (added at end)

UC-01 (use case entity)
├─ observation: "Title: Application Framework"
├─ observation: "Status: completed"
├─ observation: "File: specs/use-cases/UC-01-application-framework.md"
└─ observation: "Completed at batch: 1"

UC-02 (use case entity)
├─ observation: "Title: Building and Sensor Selection"
├─ observation: "Status: pending"
└─ (status updated to "completed" after file generation)
```

**Benefits**:
- Query progress mid-execution: "How many use cases completed?"
- Session-level visibility even if context compacts
- Complementary to filesystem verification (filesystem is still source of truth)
- Helps generate status summaries for user

**Agent Responsibilities**:

Each documentation agent receives a **targeted context package** containing:
- **Template structure**: Complete UC-00-template.md content
- **Use case info**: Number, title, description, BRD requirement IDs
- **Relevant BRD requirements**: Only the requirements mapped to this use case (pre-filtered)
- **Design system excerpts**: Relevant design patterns (if applicable)
- **Project conventions**: Terminology, formatting guidelines

**CRITICAL - Agent Output**:
- Sub-agents are **stateless** and return a **single message** back to orchestrator
- Sub-agents **CANNOT write files** - they return generated content as text
- Sub-agents MUST generate complete markdown content for the use case specification
- Orchestrator receives the response and writes it to disk using Write tool

**Agent Task Prompt Format**:
```
You are a documentation agent. Your task is to GENERATE a complete use case specification file.

**IMPORTANT**: You are a sub-agent and cannot write files directly. Generate the complete markdown content and return it in your response. The orchestrator will write it to disk.

**Use Case**: UC-XX: [Title]
**Output File**: specs/use-cases/UC-XX-[kebab-case-title].md

**Template Structure**: [UC-00-template.md content]
**BRD Requirements**: [Pre-filtered requirements]
**Design System**: [Relevant design patterns]

**Instructions**:
1. Follow the "Use Case Generation Workflow" in the template (Steps 1-8)
2. Complete BRD Traceability table with FR-xxxx and NFR-xx mappings
3. Use correct ID formats: [FR-xxxx.x] for requirements, [NFR-xx.x] for NFRs, [DS-xxx] for design system
4. For technical enablers, use [IMPL-xx] instead of [FR-xxxx.x]
5. Include ONLY use-case-specific NFRs (not generic architecture NFRs)
6. Remove bracketed instruction text from Acceptance Criteria section
7. Verify against Quality Checklist before returning
8. **REMOVE the "Use Case Generation Workflow" section from final output**
9. Return the COMPLETE markdown file content (without workflow section)

Return the complete file content as markdown. The orchestrator will write it to disk.
```

**Orchestrator File Writing**:
After receiving responses from all agents in a batch:
1. Extract the generated markdown content from each agent's response
2. Write each content to the appropriate file path using Write tool (will error immediately if write fails)

## Quality Checklist

Before considering a use case file complete, verify (aligned with template's Quality Checklist):

- [ ] All template sections are filled (no placeholder text like "[TODO]")
- [ ] BRD Traceability table completed with FR-xxxx and NFR-xx mappings
- [ ] Requirement IDs use correct format ([FR-xxxx.x], [NFR-xx.x], [DS-xxx], or [IMPL-xx] for enablers)
- [ ] User story follows "As a... I want... So that..." format
- [ ] Main flow has clear numbered steps
- [ ] Use Case Specific NFRs contain only UC-specific items (or empty with note if none apply)
- [ ] Acceptance Criteria reference all FRs and NFRs from the document
- [ ] Bracketed instruction placeholder text removed from Acceptance Criteria section
- [ ] Design system references are accurate (if design system exists)
- [ ] File naming follows convention: `UC-NN-kebab-case-name.md`
- [ ] Markdown formatting is correct (headers, lists, bold/italic)
- [ ] No personal names in documentation (use roles instead)
- [ ] Related use cases are cross-referenced
- [ ] Workflow section removed from final output

## Example Orchestrator Workflow

**Initial Setup**:
```
1. Read specs/use-cases/use-cases-overview.md
2. Parse all use case entries (UC-01 through UC-NN)
3. Extract use case number, title, and kebab-case filename for each
4. Read .ai/2_templates/UC-00-template.md - Note the "Use Case Generation Workflow" section
5. Scan specs/use-cases/ directory for existing UC-NN-*.md files
6. Compare existing files against overview to identify missing use cases
7. Calculate total batches needed: ceil(missing_use_cases / 3)
8. (Optional) If Knowledge Graph MCP available:
   - Create UseCaseGeneration entity with metadata
   - Create UC-01 through UC-20 entities with initial status
```

**Per-Batch Execution Pattern** (Stateless - Safe to Interrupt):
```
1. Re-scan specs/use-cases/ directory to get current state
2. (Optional) If Knowledge Graph MCP available: Query use case entities for status
3. Identify which use cases still need files (not present on filesystem)
4. Select next 3 missing use cases (or remaining if < 3)

5. Launch 3 parallel documentation-agent tasks (or fewer for final batch):
   - Agent 1: Generate content for UC-XX-[kebab-case-title].md
   - Agent 2: Generate content for UC-YY-[kebab-case-title].md
   - Agent 3: Generate content for UC-ZZ-[kebab-case-title].md

6. Wait for all agents to return their responses
   - Agent 1 returns: Complete markdown content for UC-XX
   - Agent 2 returns: Complete markdown content for UC-YY
   - Agent 3 returns: Complete markdown content for UC-ZZ

7. Orchestrator writes files to disk (using Write tool):
   - Write Agent 1 response → specs/use-cases/UC-XX-[kebab-case-title].md
   - Write Agent 2 response → specs/use-cases/UC-YY-[kebab-case-title].md
   - Write Agent 3 response → specs/use-cases/UC-ZZ-[kebab-case-title].md
   - (Write tool will error immediately if any write fails)

8. (Optional) If Knowledge Graph MCP available:
   - Update UC-XX, UC-YY, UC-ZZ entities with status "completed"
   - Add observation with batch number and timestamp

9. Proceed to next batch (loop back to step 1)

10. Loop until re-scan shows no missing use cases
```

**Repeat pattern until all use cases are processed**.

**Recovery from Interruption**:
```
If the orchestration is interrupted (context compacting, error, manual stop):
1. Simply restart the orchestrator
2. It will scan the filesystem and skip already-generated files
3. (Optional) If Knowledge Graph MCP available:
   - Query UseCaseGeneration entity to understand previous progress
   - Query use case entities to see which were completed
   - Provide user with progress summary (e.g., "15/20 use cases completed")
4. Continue processing only the remaining missing use cases
5. No manual intervention or state recovery needed
```

Each agent receives this full prompt with their specific:
- Assigned use case number (e.g., UC-05)
- Use case title from overview (e.g., "User Authentication")
- Expected output filename (e.g., "UC-05-user-authentication.md")

## Notes

- **Consistency**: Maintain consistent terminology across all use cases based on project conventions
- **Traceability**: Every functional requirement should trace back to specific BRD requirement IDs using [FR-xxxx.x] format
- **Completeness**: All use cases should be fully specified regardless of priority
- **Design Alignment**: UI/UX sections must align with design-system.md specifications (if available)
- **Performance**: Include specific performance targets in Use Case Specific NFRs section (not generic NFRs)
- **Optional Sections**: Remove optional sections entirely if they don't apply (don't leave as "N/A")
- **NFR Separation**: Generic architecture NFRs belong in `../.ai_project_memory/constitution.md`, NOT in use case files
- **Resilience**: This orchestration is designed to survive context compacting and interruptions - simply restart and it will continue from where it left off
- **Progress Visibility** (Optional): Use TodoWrite tool to create batch-level todos for user visibility (e.g., "Generate UC-01, UC-02, UC-03"), mark completed after writing files
- **Knowledge Graph MCP** (Optional): If available, use for session-level progress tracking and status queries. **IMPORTANT**: Filesystem is source of truth; Knowledge Graph is complementary for visibility only
- **Error Handling**: Write tool will error immediately if file write fails; orchestrator should handle errors and continue with next batch
