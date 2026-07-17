---
name: ai1st-kit-engineer
description: "Activate AI-Kit framework expertise for authoring skills, constitutions, profiles, agents, and prompting best practices"
---


## User Input

```text
$ARGUMENTS
```

If the user provided a focus area (e.g., "skill authoring", "constitution review", "agent design"), narrow session behavior to that domain. If empty, activate full framework expertise.

---

## Activation Context

This skill loads the AI-Kit framework knowledge and behavioral rules into the current session. It enables expert-level assistance with authoring, reviewing, and maintaining all framework artifacts.

This is NOT a persona. It is a functional knowledge activation — structured context that makes the session aware of framework conventions, file relationships, and quality standards.

After loading, confirm activation with a brief summary of what's now available, tailored to the focus area if one was provided.

---

<ai_kit_framework_knowledge>

### Framework Architecture (7 Tiers)

The AI-Kit is a layered system where each tier serves a distinct purpose. Higher tiers depend on lower tiers for context.

| Tier | Location | Purpose | Loading |
|------|----------|---------|---------|
| 1 | `.ai/0_core_memory/` | Coding standards, security rules, decision framework | Always loaded via CLAUDE.md `@` imports |
| 2 | `.ai_project_memory/` | Constitutions, project overview, architecture, glossary (initialized from `.ai/1_project_init/` by ai1st-kit-project-init) | Always loaded (constitution.md) or on-demand |
| 3 | `.ai/2_templates/` | Document templates for AI-generated artifacts | Read when generating specific document types |
| 4 | `.claude/skills/` | Skill definitions (SKILL.md + supporting files) organized by domain prefix | Loaded when user invokes `/skill-name` or Claude auto-triggers |
| 5 | `.ai/example_prompts/` | Reusable prompt patterns and how-to guides | Reference material, read when needed |
| 7 | `.claude/agents/` | Specialist agent definitions (YAML frontmatter + markdown) | Loaded when Agent tool delegates to them |

**Context flow**: CLAUDE.md (`@` imports) loads Tier 1 + Tier 2 into every session automatically. Everything else is loaded on-demand by skills or user actions. Skill descriptions are always in context (for auto-triggering), but full skill content loads only when invoked.

### Skill System

Skills live in `.claude/skills/<skill-name>/SKILL.md`. Each skill is a directory containing a required `SKILL.md` entrypoint plus optional supporting files (templates, examples, scripts, references).

**Naming convention**: `{domain}-ai1st-{slug}` for AI-Kit workflow skills, descriptive names for others.

| Prefix | Domain | Examples |
|--------|--------|----------|
| `ai1st-kit-` | Setup & framework configuration | ai1st-kit-engineer, ai1st-kit-project-init |
| `ai1st-po-` | Product Owner workflow (UI capture, spec, clarify) | ai1st-po-capture-ui, ai1st-po-specify, ai1st-po-clarify |
| `ai1st-dev-` | Planning & implementation | ai1st-dev-plan, ai1st-dev-plan-confidence, ai1st-dev-tasks, ai1st-dev-checklist, ai1st-dev-implement, ai1st-dev-test, ai1st-dev-verify |
| `ai1st-qa-` | Quality assurance & testing | ai1st-qa-e2e-web-test-plan, ai1st-qa-verify-ui, ai1st-qa-verify-project-compliance |
| `ai1st-arch-` | Architecture & legacy analysis | ai1st-arch-legacy-sys-analysis, ai1st-arch-legacy-analysis-lite, ai1st-arch-legacy-to-modern-design, ai1st-arch-legacy-to-modern-design-lite, ai1st-arch-setup-analysis-scope, ai1st-arch-code-quality-analysis |
| `ai1st-ops-` | Operational utilities | ai1st-ops-sync-knowledge |
| *(no prefix)* | Anthropic Tier 1 & community skills | frontend-design, webapp-testing |

**AI-Kit workflow skills** (`ai1st-*`) are all `disable-model-invocation: true` — users invoke them explicitly with `/skill-name`. Anthropic and community skills are auto-triggered when the request matches their domain.

### Constitution Hierarchy

Constitutions are behavioral rule documents that govern AI behavior in specific contexts.

**Always loaded** (via CLAUDE.md `@` import chain):
```
CLAUDE.md
  @../.ai_project_memory/constitution.md           <- Tier 2 (universal principles)
    @./general-overview.md                         <- Project identity
    @./architecture.md                             <- System architecture
  @../.ai_project_memory/constitution-frontend.md  <- Frontend tech stack
  @../.ai_project_memory/constitution-backend.md   <- Backend principles
```

**On-demand** (read when relevant workflow activates):
- `legacy-analysis-constitution.md` — Analysis workflow rules, gates, read-only policy
- `constitution-gap-analysis.md` — Gap analysis methodology, parity criteria

**Context budget rule**: Always-loaded constitutions consume context tokens in EVERY session. Only universally needed instructions belong there. Domain-specific rules should be on-demand constitutions, loaded by the skills that need them.

### Profile Customization Pattern

Profiles live in `.ai_project_memory/rules/` and encode project-specific knowledge that makes generic skills work for a specific project.

**Pattern**: `generic skill` + `project-specific profile` = customized behavior

| Component | Location | Contains |
|-----------|----------|----------|
| Profile files | `.ai_project_memory/rules/*.md` | Technology stack, file extensions, scan patterns, module discovery rules, domain terminology |
| Skill `--profile` param | `.claude/skills/*/SKILL.md` | Skills accept `--profile <path>` and read profile values at runtime |

**Why this matters**: This separation is what makes skills reusable across projects without modification. The profile encodes the project differences; the skill encodes the workflow.

### Agent Delegation Model

Agents are specialist sub-processes defined in `.claude/agents/`. Skills can delegate work to agents via `context: fork` with an `agent` field, or the main conversation can use the Agent tool directly.

**Available agent types** (built-in):
| Agent | Model | Purpose |
|-------|-------|---------|
| Explore | — | Fast codebase exploration, read-only |
| Plan | — | Architecture and implementation planning |
| general-purpose | — | Multi-step research and implementation |
| architecture-agent | opus | ADRs, diagrams, trade-offs, architectural decisions |
| documentation-agent | haiku | API docs, guides |
| verification-agent | sonnet | Post-implementation verification, bug reports |

**Orchestration rules**:
- **PARALLEL**: Independent read-only tasks (analysis + documentation, verify + other)
- **SEQUENTIAL**: Dependent chain (Architecture -> Dev -> Verify -> Docs)
- **DIRECT**: No agent needed for <50 lines, configs, quick fixes, <2min tasks

**Skills + Agents integration**:
- Skill with `context: fork` + `agent: Explore` = skill content becomes the prompt for an Explore subagent
- Subagent with `skills` field = custom agent preloads skill content at startup

### Template Library

Templates in `.ai/2_templates/` provide standardized document structures. Skills reference them when generating artifacts.

Project init templates in `.ai/1_project_init/` (copied to `.ai_project_memory/` by ai1st-kit-project-init):
- `constitution-template.md`, `constitution-frontend-template.md`, `constitution-backend-template.md` — Constitution scaffolds
- `general-overview-template.md`, `architecture-template.md` — Project identity and architecture
- `legacy-analysis-constitution-template.md` — Legacy analysis workflow rules
- `rules/browsing-rules-template.md` — Playwright browsing rules

Document templates in `.ai/2_templates/`:
- `spec-template.md`, `plan-template.md`, `tasks-template.md` — Feature lifecycle
- `adr-template.md` — Architecture Decision Records
- `agent-file-template.md` — Agent definition scaffold
- `review-template.md`, `verify-ui-template.md` — Verification templates
- `brd-template.md`, `srs-template.md`, `UC-00-template.md` — Requirements documents

</ai_kit_framework_knowledge>

---

<skill_authoring_best_practices>

### SKILL.md Structure

**Authoritative reference**: https://code.claude.com/docs/en/skills — always consult this for the latest skill features, frontmatter fields, and conventions. The guidance below is a curated summary for AI-Kit skill authoring.

Every skill requires a `SKILL.md` file with YAML frontmatter + markdown content. The skill directory can include supporting files.

**1. Frontmatter** (YAML between `---` markers):

```yaml
---
name: my-skill
description: "What the skill does and when to use it. Front-load the key use case."
disable-model-invocation: true
allowed-tools: Read Grep Glob
argument-hint: "[feature-name]"
---
```

Key frontmatter fields:

| Field | When to use |
|-------|------------|
| `name` | Display name. Lowercase, hyphens only. Defaults to directory name if omitted. |
| `description` | How Claude decides when to use it. Front-load the key use case. Max ~250 chars before truncation. |
| `disable-model-invocation` | `true` for workflow skills with side effects (all `ai1st-*` skills). |
| `user-invocable` | `false` for background knowledge Claude uses automatically but users shouldn't invoke directly. |
| `allowed-tools` | Pre-approve tools so Claude doesn't prompt for each use. Space-separated or YAML list. |
| `context` | `fork` to run in an isolated subagent context. Use for research, exploration, heavy tasks. |
| `agent` | Which agent type when `context: fork` is set (e.g., `Explore`, `Plan`, `general-purpose`). |
| `model` | Override model for this skill (e.g., `sonnet` for lighter tasks). |
| `effort` | Override effort level: `low`, `medium`, `high`, `max`. |
| `argument-hint` | Shown during autocomplete: `[issue-number]`, `[filename] [format]`. |
| `paths` | Glob patterns limiting when skill auto-activates. |

**2. User Input** (standard block):
```markdown
## User Input

\```text
$ARGUMENTS
\```
```

`$ARGUMENTS` is the raw text after the slash command. Use `$ARGUMENTS[0]`, `$1`, etc. for positional args. Shell-style quoting applies for multi-word values.

**3. Dynamic Context Injection** (shell commands that run before Claude sees the skill):
```markdown
## Environment
!`git branch --show-current`
!`cat package.json | jq '.version'`
```

The `` !`command` `` syntax runs shell commands during skill loading. Output replaces the placeholder. Claude only sees the result.

**4. Supporting Files** (keep SKILL.md under 500 lines):
```
my-skill/
├── SKILL.md           # Main instructions (required)
├── references/        # Detailed reference docs (loaded when needed)
│   └── api-guide.md
├── templates/         # Templates Claude fills in
│   └── output.md
└── scripts/           # Scripts Claude can execute
    └── validate.sh
```

Reference supporting files from SKILL.md: "For API details, see [references/api-guide.md](references/api-guide.md)."

**5. Execution Rules** (for workflow skills):
Define constraints upfront — what tools to use, what to avoid, time targets.
```markdown
## Execution Rules

- Use direct tools only — avoid unnecessary Agent delegation
- Parse params from `$ARGUMENTS` — one AskUserQuestion maximum
- Run validations in parallel where possible
```

**6. Steps with Gates**:
Steps are numbered. Gates are mandatory human review points where the skill STOPS and waits for user input.

**7. Completion Summary**:
Every workflow skill ends with a summary showing what was created/changed and what to do next.

### Claude 4.6 Prompting Best Practices

Reference: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices

Key patterns to apply when writing skills:

<prompting_principles>

**Be clear and direct.**
State exactly what to do, not what to "consider." Claude 4.6 responds best to explicit instructions. "Extract all file paths from the config" beats "you might want to look at file paths."

**Add context for "why", not just "what".**
Explaining motivation helps Claude generalize. Instead of "NEVER use ellipses", say "Your response will be read aloud by TTS, so never use ellipses since TTS can't pronounce them." Claude is smart enough to infer related rules.

**Use XML tags for structured context.**
Wrap distinct content types in descriptive tags (`<instructions>`, `<context>`, `<rules>`). This prevents Claude from confusing rules with data. Nest tags for hierarchies.

**Avoid over-prompting for Claude 4.6.**
These models follow instructions well with concise prompts. Excessive repetition or SHOUTING IN CAPS degrades performance. Where older models needed "CRITICAL: You MUST use this tool when...", Claude 4.6 works better with "Use this tool when...". Instructions that previously undertriggered tools will now overtrigger — dial them back.

**Give functional roles, not persona claims.**
Claude Code ignores identity claims ("You are an expert architect"). Instead, use functional behavioral rules: "Apply architecture review standards: check for single responsibility, layer violations, and coupling metrics."

**Put instructions before data.**
Place rules and constraints before the content they apply to. For long documents, put data at the top and the query/instructions at the end — this can improve response quality by up to 30%.

**Use examples effectively.**
A few well-crafted examples (3-5) dramatically improve accuracy and consistency. Wrap in `<example>` tags. Make them relevant, diverse, and covering edge cases.

**Prefer "do this" over "don't do that".**
Instead of "Do not use markdown", say "Write smoothly flowing prose paragraphs." Positive instructions are more reliably followed.

**Match prompt style to desired output.**
If you want plain text output, write the prompt in plain text. If you want structured markdown, use structured markdown in the prompt.

</prompting_principles>

<agentic_patterns>

**Parallel tool calls.**
When multiple independent reads/searches are needed, make all calls in a single message. Claude 4.6 excels at parallel execution. Don't sequence what can be parallel.

**Minimize hallucinations.**
Include `<investigate_before_answering>` blocks: "Never speculate about code you have not opened. Read the file before answering." Claude 4.6 is less prone to hallucination but this guidance still helps.

**Balance autonomy and safety.**
For skills with side effects, include guidance about confirming destructive actions. For read-only skills, let Claude proceed freely.

**Reduce overengineering.**
Claude 4.6 tends to overengineer. Include: "Only make changes that are directly requested. Keep solutions simple. Don't add features, abstractions, or documentation beyond what was asked."

**Context awareness.**
Claude 4.6 tracks its remaining context window. For long-running skills, include: "Save progress to disk periodically. Your context will be compacted as it fills."

**Subagent delegation.**
Claude 4.6 has a strong predilection for subagents and may spawn them when direct tool calls are faster. Include guidance: "Use subagents when tasks can run in parallel or require isolated context. For simple searches, use direct Grep/Glob/Read calls."

</agentic_patterns>

### Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Correct Approach |
|-------------|-------------|------------------|
| Persona adoption ("You are an expert architect") | Claude Code rejects identity claims | Use functional behavioral rules instead |
| Embedding volatile knowledge in skills | Content goes stale, bloats context | Reference by file path or `@import`. Use supporting files. |
| Duplicating constitution rules in skills | Creates drift, wastes context | "Read `constitution.md` before proceeding" |
| Vague completion criteria | No way to verify success | Define explicit output checklist |
| No `$ARGUMENTS` block | Skill can't receive parameters | Always include User Input section |
| Over-prompting with CAPS and repetition | Claude 4.6 overtriggers on aggressive instructions | Use normal, clear language. State rules once. |
| Giant monolithic SKILL.md (>500 lines) | Context overload, reduced instruction following | Split into SKILL.md + supporting files in references/ |
| Missing or vague description | Claude can't auto-trigger; autocomplete unhelpful | Front-load the key use case in description (max 250 chars) |
| Using `context: fork` for reference/knowledge skills | Subagent has no task to perform | Only use `context: fork` for skills with explicit work instructions |
| Hardcoding project paths in reusable skills | Breaks portability | Use `--profile` parameter, `${CLAUDE_SKILL_DIR}`, or dynamic context injection |

</skill_authoring_best_practices>

---

<session_operating_rules>

### When Creating Skills

1. **Choose the right prefix**: `ai1st-kit-` for setup, `ai1st-dev-` for dev workflow, `ai1st-qa-` for QA, `ai1st-po-` for PO, or no prefix for general tools.
2. **Create the directory**: `.claude/skills/<skill-name>/SKILL.md` as the entrypoint. Add supporting files for large reference material.
3. **Write clear frontmatter**: `name`, `description` (front-loaded, <250 chars), `disable-model-invocation: true` for workflow skills.
4. **Follow structural patterns**: User Input (`$ARGUMENTS`), Execution Rules, Steps, Gates, Completion Summary.
5. **Profile-parameterize** project-specific values. If the skill references technology, file patterns, or paths that vary by project, accept a `--profile` parameter or use dynamic context injection.
6. **Keep SKILL.md under 500 lines**. Move detailed reference material to supporting files.
7. **Define success criteria**: What artifacts does the skill produce? What does "done" look like?
8. **Test the skill**: After writing, invoke it with `/skill-name` and verify it follows its own instructions.

### When Reviewing Skills

1. **Check anti-patterns**: Persona claims? Hardcoded paths? Missing frontmatter? Missing `$ARGUMENTS`? Over 500 lines?
2. **Verify constitution compliance**: Does the skill respect the constitution hierarchy? Does it avoid duplicating rules already in constitutions?
3. **Assess context budget**: How many lines load into context? Could sections be moved to supporting files?
4. **Validate prompting quality**: XML tags for structured sections? Specific instructions? Concise language (no over-prompting)?
5. **Check description quality**: Is it front-loaded with the key use case? Under 250 characters? Will Claude auto-trigger correctly?
6. **Verify invocation control**: Should it be `disable-model-invocation: true`? Does it have side effects? Should users invoke it or should Claude auto-trigger?

### When Designing Constitutions

1. **Determine loading strategy**: Always-loaded (via CLAUDE.md `@` chain) or on-demand (read by specific skills)?
2. **Scope appropriately**: Universal principles in `constitution.md`. Stack-specific in `constitution-frontend.md` / `constitution-backend.md`. Workflow-specific in dedicated constitutions.
3. **Use behavioral rules** with clear conditional structure for steering behavior.
4. **Include governance**: Version, rationale, amendment process, precedence rules.
5. **Watch context budget**: Every line in an always-loaded constitution costs tokens in every session. Be ruthlessly concise.

### When Working with Profiles

1. **Profiles are reference documents**, not skills. They contain declarative knowledge (what technology, what patterns, what paths), not procedural instructions.
2. **Profiles encode project differences**. Everything that makes Project A different from Project B belongs in a profile, not in a reusable skill.
3. **Standard sections**: Technology, Source Layout, File Extensions, File Conventions, Scan Patterns, Custom Categories, Domain Terminology, Module Discovery, Analysis Paths.
4. **Profiles are read by skills at runtime** via `--profile` parameter. The skill determines which profile sections to read.

### When Authoring Agent Definitions

1. **YAML frontmatter is required**: `name`, `description`, `model`, `tools` fields.
2. **Description drives auto-delegation**: Claude automatically matches tasks to agents based on the `description` field. Write descriptions with clear domain keywords so Claude routes relevant tasks to the right agent.
3. **Model selection is the primary differentiator**: `opus` for architectural decisions and complex reasoning. `sonnet` for implementation and verification. `haiku` for documentation and lightweight tasks.
4. **When an agent earns its place**: An agent must provide at least one of: (a) model routing different from default, (b) tool restrictions that enforce constraints, (c) unique structured output format, or (d) behavioral rules not covered by constitutions.
5. **Tool specification**: List only the tools the agent actually needs. Fewer tools = more focused agent.
6. **Skills can invoke agents**: Use `context: fork` + `agent: <name>` in skill frontmatter to delegate work to a specific agent type.

</session_operating_rules>

---

## Quick Reference

### Common Tasks Cheat Sheet

| Task | Start Here |
|------|-----------|
| Create a new AI-Kit skill | Create `.claude/skills/<name>/SKILL.md`. Use frontmatter + User Input + Steps pattern. Check README.md for naming convention. |
| Create a project-specific skill | Same as above, but may hardcode project values. Consider wrapping a reusable skill instead. |
| Create a new constitution | Read `.ai/1_project_init/constitution-template.md`. Decide always-loaded vs on-demand. |
| Create a new profile | Read `.ai/1_project_init/rules/` for structure. Encode technology + conventions + paths. |
| Create a new agent | Read `.ai/2_templates/agent-file-template.md` and existing agents in `.claude/agents/`. |
| Review a skill for quality | Check anti-patterns table above. Verify frontmatter, description, `$ARGUMENTS`, SKILL.md size (<500 lines). |
| Add framework knowledge | Write to `.ai/0_core_memory/` (framework) or `.ai_project_memory/` (project-specific). |

### File Locations Quick Map

```
.claude/
  CLAUDE.md                          <- Entry point. @imports Tier 1 + Tier 2.
  settings.json                      <- Permission rules, hooks, model config.
  skills/
    <skill-name>/
      SKILL.md                       <- Skill entrypoint (required)
      references/                    <- Supporting reference docs (optional)
      templates/                     <- Output templates (optional)
      scripts/                       <- Helper scripts (optional)
    README.md                        <- Installed skills index
  agents/
    *.md                             <- Agent definitions (YAML frontmatter + markdown)

.ai/
  0_core_memory/                     <- Tier 1: Always-loaded standards
  1_project_init/                    <- Templates for .ai_project_memory/ (copied by ai1st-kit-project-init)
  2_templates/                       <- Tier 3: Document templates (spec, plan, ADR, etc.)
  example_prompts/                   <- Tier 5: Reusable prompt patterns
  scripts/bash/                      <- Helper scripts used by skills

.ai_project_memory/                  <- Tier 2: Project context (populated by ai1st-kit-project-init)
  constitution.md                    <- Universal principles (always loaded)
  constitution-*.md                  <- Domain-specific (on-demand or always loaded per CLAUDE.md config)
  general-overview.md                <- Project identity (always loaded)
  architecture.md                    <- System architecture (always loaded)
  rules/                             <- Profiles + browsing rules (project-specific)
    *-profile.md                     <- Technology + conventions + paths
```

### Skill Lifecycle Quick Reference

```
/ai1st-kit-project-init   -> Initialize project memory
/ai1st-po-specify         -> Create feature spec (Socratic dialogue)
/ai1st-po-clarify         -> Reduce spec ambiguity (up to 5 questions)
/ai1st-dev-checklist       -> Generate requirements quality checklist
/ai1st-dev-plan            -> Generate implementation plan + design artifacts
/ai1st-dev-tasks           -> Generate dependency-ordered task list
/ai1st-dev-implement       -> Execute implementation tasks
/ai1st-dev-test            -> Execute test tasks
/ai1st-dev-verify          -> Code review against spec, plan, constitution
```

---

*Version: 2.0 | Updated: 2026-04-13 | Migration: commands -> skills*
