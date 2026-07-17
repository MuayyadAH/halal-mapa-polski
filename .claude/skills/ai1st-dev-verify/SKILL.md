---
name: ai1st-dev-verify
description: "Perform rigorous code review of implementation against spec, plan, and constitution"
disable-model-invocation: true
---

<!-- Tanel: DRAFT needs review and probably modifications -->

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

CRITICAL: Before proceeding, ask the user what scope to review. DO NOT ASSUME.

Ask: "What scope should I review?"
- **Option 1**: Feature branch changes only (git diff main...HEAD)
- **Option 2**: Uncommitted changes only (git diff HEAD)
- **Option 3**: Entire project/codebase
- **Option 4**: Specific directory or file path

Wait for user confirmation before proceeding.

Given the review scope, do this:

1. Load `.ai/2_templates/review-template.md` to understand the review process and report structure.

2. Determine feature context based on scope:
   - If user provided feature path (e.g., `specs/003-user-auth`), use it
   - If reviewing branch changes, check git branch for feature pattern (NNN-feature-name)
   - If feature context exists, load: spec.md, plan.md, tasks.md
   - If no feature context (uncommitted/project/path review), skip feature-specific checks

3. Load project context to understand principles, standards, and restrictions:
   - Read `constitution.md` at project root
   - Follow any `@import` directives found in constitution to load additional context files
   - Read project general overview from `specs/general`
   - Read all domain model descriptions from `specs/domain-model`

4. Collect files to review based on confirmed scope:
   - **Branch changes**: git diff main...HEAD (or specified base branch)
   - **Uncommitted**: git diff HEAD
   - **Entire project**: all source files in repository
   - **Specific path**: files in specified directory/path

5. Execute review template's Execution Flow:
   - Run all applicable checklists from template
   - Document findings with file:line references
   - Skip feature-specific checks if no feature context

6. Generate review report following template structure:
   - Overall verdict: APPROVE / REQUEST CHANGES / COMMENT
   - Critical issues (blocking)
   - Major issues (should fix)
   - Minor issues (nice-to-have)
   - Positive observations
   - Actionable next steps

7. Provide concrete feedback:
   - File paths and line numbers for each issue
   - Reference violated spec/plan/constitution sections
   - Suggest specific fixes

Note: This command is READ-ONLY and does NOT modify code. It produces a review report. To fix issues, use `/fix` command after reviewing the report.
