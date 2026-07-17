---
name: ai1st-kit-project-init
description: "Initialize or update project memory files (.ai_project_memory/) from templates in .ai/1_project_init/."
disable-model-invocation: true
---


## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). User input may provide answers to questions below, allowing you to skip already-answered questions.

---

## Context Loading (MANDATORY)

Before starting any work, invoke the `ai1st-kit-engineer` skill via the Skill tool to load AI-Kit framework expertise into the session. Apply its skill authoring best practices and constitution design patterns throughout this skill's execution so all generated project memory files follow AI-Kit conventions.

---

## Execution Rules (CRITICAL)

- **Do NOT use Task tool** — use direct tools only
- **Do NOT skip questions** — all questions must be answered before initialization
- Parse `$ARGUMENTS` for any pre-supplied answers (e.g., `--scope frontend,backend`)
- If `.ai_project_memory/constitution.md` already exists, this is an UPDATE — warn the user and ask for confirmation before overwriting
- When filling placeholders and you are **uncertain** about a value, **always ask the user** by suggesting 2-3 concrete options rather than guessing
- Apply AI-Kit framework conventions from ai1st-kit-engineer when filling templates — use proper XML tags, "Choose the response that / NEVER choose" patterns for behavioral rules, and respect the constitution hierarchy and context budget principles

---

## Step 0: Pre-flight Check

1. Check if `.ai_project_memory/constitution.md` already exists
   - If NO: This is a fresh initialization. Proceed to Step 1.
   - If YES: Project memory already exists. Ask the user what they want to do:

**Use `AskUserQuestion` with**:
- **Question**: "Project memory files already exist in `.ai_project_memory/`. What would you like to do?"
- **Options**:
  1. `Update specs/constitutions — modify specific sections in existing files`
  2. `Cancel — keep existing files unchanged`

**Based on selection**:

#### Option 1: Update specs/constitutions
Ask a follow-up question. Only show options for files that actually exist in `.ai_project_memory/`.

**Use `AskUserQuestion` with**:
- **Question**: "What would you like to update? Select one or more (e.g. '1,3'):"
- **Options** (only include if file exists):
  1. `Project overview (general-overview.md) — e.g., update project description, components, integrations`
  2. `Architecture (architecture.md) — e.g., add new integration, update data flow`
  3. `Constitution (constitution.md) — e.g., change naming conventions, update coding standards`
  4. `Frontend constitution — e.g., update framework version, add UI patterns`
  5. `Backend constitution — e.g., change API style, update data access layer`
  6. `Legacy analysis constitution — e.g., update source extensions, analysis tools`
  7. `Browsing rules — e.g., update portal URL, login flow`

After selection, read the chosen file(s) and ask:
- "What changes do you want to make? Describe the updates or provide new values."
- Apply the changes to the selected file(s)
- Skip to Step 5 (Placeholder Validation)

#### Option 2: Cancel
- Stop execution

**To re-initialize from scratch**: Delete `.ai_project_memory/` contents and run this command again.

---

## Step 1: Gather Project Configuration

Ask the following questions using `AskUserQuestion`. If the user provided answers in `$ARGUMENTS`, skip already-answered questions.

### Question 1: Project Scope (Constitutions to Include)

Ask the user which constitutions to include. Multiple selections are allowed — selecting both Frontend and Backend = full-stack.

**Use `AskUserQuestion` with**:
- **Question**: "Which constitutions should be included? Select all that apply (e.g. '1,2' for full-stack):"
- **Options**:
  1. `Frontend — frontend tech stack, UI patterns, commands`
  2. `Backend — backend tech stack, API design, data access`
  3. `Legacy analysis — brownfield system analysis constitution`

**Parsing rules**:
- Selections can be combined freely: e.g. "1,2" = frontend + backend (full-stack), "1,3" = frontend + legacy analysis
- Any combination is valid

**Store the parsed scope as a set of flags**:
- `SCOPE_FRONTEND` = true/false
- `SCOPE_BACKEND` = true/false
- `SCOPE_LEGACY` = true/false

### Question 2: Project Source Context

Ask the user about the project's source code situation.

**Use `AskUserQuestion` with**:
- **Question**: "Where is the project source code?"
- **Options**:
  1. `Existing project — source is in this repo (current directory)`
  2. `Existing project — source is in a different folder (I'll provide the path)`
  3. `Greenfield — no existing code yet`

**If option 2 selected**: Ask a follow-up question for the path:
- **Question**: "Please provide the absolute path to the project source code folder:"
- Store as `SOURCE_PATH`

**If option 1 selected**: Set `SOURCE_PATH` to current working directory.

**Store the project type**:
- `PROJECT_TYPE` = `existing` | `greenfield`
- `SOURCE_PATH` = path to source code (only for `existing`)

---

## Step 2: Initialize Project Memory Files

### 2.1 Always Copy (all scopes)

These files are always created regardless of scope selection:

| Source (`.ai/1_project_init/`) | Target (`.ai_project_memory/`) |
|---|---|
| `constitution-template.md` | `constitution.md` |
| `general-overview-template.md` | `general-overview.md` |
| `architecture-template.md` | `architecture.md` |
| `rules/browsing-rules-template.md` | `rules/browsing-rules.md` |

**Action**: Read each template file, then Write to the target path. Do NOT modify template content — copy as-is.

### 2.2 Scope-Dependent Copies

Based on the scope flags, copy additional templates:

**If `SCOPE_FRONTEND` = true**:

| Source | Target |
|---|---|
| `constitution-frontend-template.md` | `constitution-frontend.md` |

**If `SCOPE_BACKEND` = true**:

| Source | Target |
|---|---|
| `constitution-backend-template.md` | `constitution-backend.md` |

**If `SCOPE_LEGACY` = true**:

| Source | Target |
|---|---|
| `legacy-analysis-constitution-template.md` | `legacy-analysis-constitution.md` |

---

## Step 3: Update CLAUDE.md Imports

Read `.claude/CLAUDE.md` and uncomment the relevant `@` import lines based on scope:

**If `SCOPE_FRONTEND` = true**:
Uncomment: `<!-- @../.ai_project_memory/constitution-frontend.md -->`
Result: `@../.ai_project_memory/constitution-frontend.md`

**If `SCOPE_BACKEND` = true**:
Uncomment: `<!-- @../.ai_project_memory/constitution-backend.md -->`
Result: `@../.ai_project_memory/constitution-backend.md`

**If `SCOPE_LEGACY` = true**:
Uncomment: `<!-- @../.ai_project_memory/legacy-analysis-constitution.md -->`
Result: `@../.ai_project_memory/legacy-analysis-constitution.md`

**IMPORTANT**: Only uncomment the lines — do NOT modify any other content in CLAUDE.md.

---

## Step 4: Fill Placeholders

This step replaces `{PLACEHOLDER}` tokens in the copied files with real project values. The approach depends on `PROJECT_TYPE`.

### 4.1 Existing Project (PROJECT_TYPE = `existing`)

**Use parallel Agent tasks to analyze the source code at `SOURCE_PATH` and produce structured reports.**

#### 4.1.1 Quick Scan (direct, before agents)

Before launching agents, do a fast direct scan to establish basics:
1. List top-level directories at `SOURCE_PATH` (Bash: `ls -la`)
2. Find build/config files (Glob: `**/package.json`, `**/*.csproj`, `**/*.sln`, `**/pom.xml`, `**/build.gradle`, `**/Cargo.toml`, `**/go.mod`, `**/requirements.txt`, `**/composer.json`, `**/Dockerfile*`)
3. Read the project's README if one exists

This gives you enough context to craft focused agent prompts.

#### 4.1.2 Launch Parallel Analysis Agents

Launch the following agents **in parallel** using the Agent tool. Each agent gets a focused scope and must return a structured report.

<agent_tasks>

**Agent 1: Project Overview & Components** (subagent_type: Explore)
```
Analyze the project at {SOURCE_PATH} and produce a structured report with:

1. PROJECT IDENTITY:
   - Project name (from package.json, README, .sln, pom.xml, etc.)
   - One-paragraph description of what the project does
   - Current development phase (active development, maintenance, legacy, etc.)

2. SYSTEM COMPONENTS:
   - List each major component/module/service with:
     - Name
     - Path relative to {SOURCE_PATH}
     - Brief description (1 sentence)
   - Maximum 10 components

3. KEY INTEGRATION POINTS:
   - External APIs, databases, message queues, third-party services
   - For each: name, protocol/type, purpose
   - Look in: config files, environment variables, API client code, connection strings

4. DOCUMENTATION STRUCTURE:
   - Existing docs folder location and contents
   - README summary

Format your output as a markdown report with clear sections.
Read actual files to verify — do not guess.
```

**Agent 2: Tech Stack & Architecture** (subagent_type: Explore)
```
Analyze the project at {SOURCE_PATH} and produce a structured report with:

1. LANGUAGES & FRAMEWORKS:
   - Primary language(s) with versions (from config/lock files)
   - Frameworks with versions
   - Build tools and commands (from package.json scripts, Makefile, build files)

2. ARCHITECTURE PATTERN:
   - Identified pattern (MVC, Clean Architecture, Microservices, Monolith, etc.)
   - Evidence: which directories/files indicate this pattern

3. DATA LAYER:
   - Database type(s) (look for ORMs, connection strings, migration files)
   - Data access pattern (ORM, raw SQL, repository pattern, etc.)
   - Database file/migration locations

4. TESTING SETUP:
   - Test framework(s) with versions
   - Test file locations and naming conventions
   - Test commands (from package.json scripts, build files)

5. CODE STRUCTURE:
   - Directory tree (top 2-3 levels)
   - Source code root path
   - Key directory purposes

Format your output as a markdown report with clear sections.
Read actual files to verify — do not guess.
```

**Agent 3: Code Conventions & Patterns** (subagent_type: Explore)
```
Analyze the project at {SOURCE_PATH} and produce a structured report with:

1. NAMING CONVENTIONS:
   - File naming (camelCase, PascalCase, kebab-case, snake_case)
   - Class/component naming pattern
   - Function/method naming pattern
   - Variable naming pattern
   - Sample 3-5 actual names from the codebase for each

2. ERROR HANDLING:
   - Pattern used (try/catch, Result types, error boundaries, etc.)
   - Logging approach (structured logging, console, framework logger)
   - Example from codebase

3. STATE MANAGEMENT (if frontend in scope):
   - State management library/pattern
   - State organization

4. API DESIGN (if backend in scope):
   - API style (REST, GraphQL, gRPC, SOAP, etc.)
   - Route/endpoint organization
   - Authentication pattern

5. SECURITY PATTERNS:
   - Auth mechanism (JWT, cookies, OAuth, etc.)
   - Config/secrets management approach
   - Hosting/deployment clues (Dockerfile, cloud configs, CI/CD files)

Format your output as a markdown report with clear sections.
Read actual files to verify — do not guess.
```

</agent_tasks>

**If `SCOPE_FRONTEND` = true**, also launch:

**Agent 4: Frontend Analysis** (subagent_type: Explore)
```
Analyze the frontend code at {SOURCE_PATH} and produce a structured report with:

1. FRONTEND STACK:
   - UI framework + version
   - Language (JS/TS) + version
   - State management library
   - UI component library / CSS framework
   - Build tool + version

2. CODE STRUCTURE:
   - Frontend source root
   - Components directory
   - Pages/views directory
   - Services/API clients directory
   - State management directory
   - Styles directory

3. UI PATTERNS:
   - Component patterns (functional, class-based, composition, etc.)
   - Routing approach
   - Form handling approach
   - Key UI libraries

4. ANTI-PATTERNS observed (if any):
   - Large components, prop drilling, inconsistent patterns, etc.

Format your output as a markdown report. Read actual files to verify.
```

**If `SCOPE_BACKEND` = true**, also launch:

**Agent 5: Backend Analysis** (subagent_type: Explore)
```
Analyze the backend code at {SOURCE_PATH} and produce a structured report with:

1. BACKEND STACK:
   - Framework + version
   - Language + version
   - API type and style
   - Data access / ORM
   - Database + version
   - Test framework

2. CODE STRUCTURE:
   - Backend source root
   - Services / controllers directory
   - Data access / repository directory
   - Common / shared libraries
   - Database scripts location

3. BUILD & RUN COMMANDS:
   - Build command
   - Test command
   - Package restore command
   - Clean command

4. API DESIGN:
   - Endpoint organization
   - Service descriptions

5. ANTI-PATTERNS observed (if any)

Format your output as a markdown report. Read actual files to verify.
```

#### 4.1.3 Merge Agent Reports & Fill Placeholders

Once all agents complete, merge their reports into a unified project context.

**Fill each file using the merged context**:

1. **`general-overview.md`** — Use Agent 1 report (identity, components, integrations)
2. **`architecture.md`** — Use Agent 2 report (stack, structure, data layer) + Agent 1 (integrations)
3. **`constitution.md`** — Use Agent 3 report (conventions, patterns, error handling)
4. **`constitution-frontend.md`** (if exists) — Use Agent 4 report
5. **`constitution-backend.md`** (if exists) — Use Agent 5 report
6. **`legacy-analysis-constitution.md`** (if exists) — Use Agent 2 report (languages, file extensions, tools)
7. **`rules/browsing-rules.md`** — Ask user for portal URL (cannot be derived from code)

**For each file**:
- Read the file and identify all `{PLACEHOLDER}` tokens
- Map each placeholder to the relevant agent report finding
- If a value **can be confidently mapped** from agent reports: fill it directly
- If a value is **ambiguous or agents disagree**: ask the user via `AskUserQuestion`, presenting what the agents found and suggesting 2-3 options
- If a value **cannot be determined** from code (e.g., business context, timelines, user types): ask the user with a brief explanation of what's needed
- Write the updated file

### 4.2 Greenfield Project (PROJECT_TYPE = `greenfield`)

**No source code to analyze — guide the user through providing project information.**

Ask the user how they want to provide project context:

**Use `AskUserQuestion` with**:
- **Question**: "How would you like to define your project? Choose your approach:"
- **Options**:
  1. `High-level description — I'll describe the project briefly, AI fills in the details`
  2. `Guided Q&A — Ask me targeted questions for each section`
  3. `Detailed specs — I'll provide comprehensive information upfront`
  4. `Minimal — Just fill in project name and leave other placeholders for later`

**Based on the chosen approach**:

#### Option 1: High-level description
- Ask: "Please describe your project in a few sentences — what it does, who uses it, what tech stack you're planning."
- From the description, fill as many placeholders as possible
- For anything not covered, ask targeted follow-up questions (batch related questions together, max 3-4 per round)

#### Option 2: Guided Q&A
- Work through each file section by section
- For each section, ask 2-4 targeted questions
- Suggest sensible defaults where applicable (e.g., "For a React + Node.js project, I'd suggest these naming conventions: ... Would you like to use these or customize?")
- **File order**: `general-overview.md` → `architecture.md` → `constitution.md` → scope-dependent files

#### Option 3: Detailed specs
- Ask: "Please provide your project specifications. Include as much as you can: project name, description, tech stack, architecture, components, integrations, team conventions."
- Parse the response and fill all placeholders
- Ask about any gaps

#### Option 4: Minimal
- Ask only for: Project name, brief one-line description, primary language/framework
- Fill these in `general-overview.md` and `constitution.md`
- Leave remaining placeholders as `{PLACEHOLDER}` with a `<!-- TODO: ... -->` comment
- Note: The validation step (Step 5) will report these as remaining placeholders

---

## Step 5: Placeholder Validation

**This step is MANDATORY — never skip it.**

After filling placeholders, validate ALL created files for remaining `{PLACEHOLDER}` tokens.

1. Read each file that was created in Step 2
2. Search for any remaining `{...}` placeholder patterns (regex: `\{[A-Z][A-Z0-9_]+\}`)
3. Compile a report:

```markdown
## Placeholder Validation Report

### Fully Resolved
- `constitution.md` — 0 remaining
- `general-overview.md` — 0 remaining
...

### Placeholders Remaining
- `architecture.md` — 3 remaining:
  - Line 42: `{DATA_MODEL_TYPE}` — needs: type of data model (relational, document, etc.)
  - Line 55: `{HOSTING_DESCRIPTION}` — needs: hosting/deployment setup
  - Line 61: `{MODERNIZATION_PATTERN}` — needs: modernization strategy (if applicable, otherwise remove section)
...
```

4. If there are remaining placeholders:
   - Ask the user via `AskUserQuestion`: "There are {N} placeholders remaining across {M} files (see report above). How would you like to proceed?"
   - Options: `["Help me fill them now", "Leave them for later — I'll fill them manually", "Remove sections with unfilled placeholders"]`
   - If "fill now": work through remaining placeholders one file at a time, asking the user for values
   - If "leave": proceed to summary
   - If "remove": remove the sections containing unfilled placeholders and proceed

---

## Step 6: Completion Summary

Present a summary to the user:

```markdown
## Project Initialization Complete

**Scope**: {list of selected scopes}
**Project type**: {existing | greenfield}
**Source path**: {SOURCE_PATH or "N/A (greenfield)"}

### Files Created & Status
| File | Placeholders | Status |
|------|-------------|--------|
| `constitution.md` | 0 remaining | Ready |
| `general-overview.md` | 0 remaining | Ready |
| `architecture.md` | 2 remaining | Needs attention |
...

### CLAUDE.md Imports Updated
{list which @imports were uncommented, or "No changes" if none}

### Next Steps
{If all placeholders resolved}:
  1. Review the filled files in `.ai_project_memory/` to verify accuracy
  2. Commit the initialized project memory

{If placeholders remain}:
  1. Fill remaining `{PLACEHOLDER}` tokens in the files listed above
  2. Run `/project-init` again to re-validate, or manually search for `{` in `.ai_project_memory/`

### Suggested Commit
`chore: initialize project memory (scope: {scopes})`
```
