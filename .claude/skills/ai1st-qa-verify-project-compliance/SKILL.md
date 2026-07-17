---
name: ai1st-qa-verify-project-compliance
description: "Project-wide constitutional compliance verification (versions, structure, dependencies, security)"
disable-model-invocation: true
---


The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

## Purpose

Automated constitutional compliance verification. Validates that the codebase adheres to the project's constitution files — checking exact versions, structural hygiene, coding standards, dependency health, and security.

This command implements the "fine detail" testing philosophy: when a constitution says "MUST use X version Y", verify the **exact version**, not just presence.

## Pre-Flight

1. **Load constitution files** (read all that exist):
   - `.ai_project_memory/constitution.md` — Core principles
   - `.ai_project_memory/constitution-backend.md` or similar — Backend standards
   - `.ai_project_memory/constitution-frontend.md` or similar — Frontend standards
   - `.ai_project_memory/tech-stack/technical-overview.md` — Tech stack decisions
   - Follow any `@import` directives found in constitution files

2. **Detect project type** by scanning for:
   - `package.json` (Node.js/frontend)
   - `pom.xml` / `build.gradle` (Java/Spring)
   - `*.csproj` / `*.sln` (.NET)
   - `Dockerfile` (container config)
   - Adapt checks below to the detected stack

3. **Ask scope** using AskUserQuestion:
   - **Full compliance check** — All 6 phases (recommended)
   - **Quick check** — Phases 1-2 only (versions + structure)
   - **Dependencies only** — Phases 3-4 only (health + consistency)
   - **Custom** — User specifies which phases

## Execution Phases

Execute phases in order. Each phase produces a section in the final report.

### Phase 1: Constitution Version Compliance

For every technology version mandated in the constitution ("MUST use X version Y"):

1. **Extract exact version** from package.json, pom.xml, or equivalent
2. **Compare major version** against constitution requirement
3. **Fail if mismatch** — report exact current vs required

Check areas:
- Framework versions (React, Angular, Spring, NestJS, etc.)
- Language versions (TypeScript, Java, C#, etc.)
- Runtime versions in Dockerfiles (Node, JDK, .NET)
- Database driver versions if specified

**Critical rule**: Check the **exact version number**, not just package presence. "React installed" is NOT sufficient — verify "React 19" if constitution mandates v19.

### Phase 2: Structural Audit

1. **Root directory discipline** — No code files in project root (only configs, README, AGENTS.md)
2. **Dev tools in production dependencies** — Flag ESLint, Vitest, Playwright, TypeScript, @types/*, PostCSS, Tailwind in `dependencies` (should be `devDependencies`)
3. **Transitive dependencies** — Flag explicitly listed packages that should be auto-resolved
4. **Feature-based structure** — Verify code follows the architecture pattern defined in constitution
5. **No planning artifacts** — No TODO.md, NEXT-STEPS.md, ROADMAP.md in source

### Phase 3: Code Constitution Compliance

Verify coding standards from constitution files:

**General checks** (adapt to detected language):
- No hardcoded secrets, connection strings, API keys in source code
- No empty catch blocks (silent failures)
- No excessive `any` type usage (TypeScript)
- No inline styles (if constitution mandates CSS framework)
- No tokens in localStorage (if constitution specifies storage approach)
- Error boundaries / error handling present
- Component/class size within limits

**Backend-specific** (if backend constitution exists):
- API documentation decorators present (OpenAPI/Swagger)
- Layered architecture compliance (Controller → Service → Repository)
- Test coverage meets threshold

**Frontend-specific** (if frontend constitution exists):
- Accessibility patterns present
- State management follows constitution
- Routing follows constitution pattern

### Phase 4: Dependency Health

1. **Deprecation check** — Query package registry for deprecated packages in production dependencies
2. **Outdated packages** — Identify security-critical packages more than 6 months old
3. **Cross-package consistency** — If monorepo, verify shared tool versions match (ESLint, TypeScript, Prettier across packages)

### Phase 5: Security Scan

1. **No secrets in code** — Scan for patterns: connection strings, API keys, passwords, tokens
2. **Dependency vulnerabilities** — Run `npm audit` / `mvn dependency-check` or equivalent
3. **Dockerfile security** — Check for `latest` tags, root user, exposed secrets

### Phase 6: Modernization Assessment

1. **Framework currency** — How many major versions behind current stable?
2. **Runtime currency** — Is runtime version approaching EOL?
3. **Modern features** — Are framework-specific modern features configured? (e.g., React Compiler for React 19+, standalone components for Angular 17+)

## Output: Compliance Report

Generate a structured markdown report:

```markdown
# Constitutional Compliance Report
**Date**: {YYYY-MM-DD}
**Scope**: {Full / Quick / Dependencies / Custom}
**Constitution Files**: {list of files read}

## Executive Summary
- **Overall Status**: PASS / FAIL / WARN
- **Critical Issues**: {count}
- **Warnings**: {count}
- **Checks Passed**: {count}

## Phase 1: Version Compliance
| Technology | Constitution Requires | Actual | Status |
|------------|----------------------|--------|--------|
| {tech} | {required version} | {actual version} | PASS/FAIL |

## Phase 2: Structural Audit
| Check | Status | Details |
|-------|--------|---------|
| {check name} | PASS/FAIL/WARN | {details} |

## Phase 3: Code Compliance
| Standard | Status | Occurrences | Details |
|----------|--------|-------------|---------|
| {standard} | PASS/FAIL/WARN | {count} | {file:line refs} |

## Phase 4: Dependency Health
| Check | Status | Details |
|-------|--------|---------|
| Deprecated packages | PASS/FAIL | {list} |
| Outdated critical | PASS/WARN | {list} |
| Cross-package consistency | PASS/FAIL | {mismatches} |

## Phase 5: Security
| Check | Status | Details |
|-------|--------|---------|
| Secrets in code | PASS/FAIL | {findings} |
| Vulnerabilities | PASS/FAIL | {critical/high count} |

## Phase 6: Modernization
| Technology | Current | Latest Stable | Gap | Severity |
|------------|---------|---------------|-----|----------|
| {tech} | {ver} | {ver} | {N major} | CRITICAL/HIGH/MEDIUM |

## Recommendations
1. **Priority 1 (Block)**: {critical issues}
2. **Priority 2 (Review)**: {high issues}
3. **Priority 3 (Future)**: {improvement items}
```

## Rules

- This command is **READ-ONLY** — produces a report, does not modify code
- Use **exit code semantics**: FAIL = blocking issues found, WARN = non-blocking issues, PASS = clean
- Always provide **file:line references** for findings
- When constitution is ambiguous, document as WARN (not FAIL)
- For version checks: extract **exact version numbers** from manifest files, not just package presence
- Adapt all checks to the project's actual tech stack — skip irrelevant checks (e.g., skip React checks for a Java-only project)
- If no constitution files exist, report as FAIL with recommendation to create them via `/ai1st-kit-project-init`
