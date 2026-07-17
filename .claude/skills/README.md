# Installed Skills

**Purpose**: Single source of truth for all skills installed in this AI-Kit — what each one does, how it's invoked, where it came from.
**Last Updated**: 2026-05-11
**Total Skills**: 35

---

## Naming Convention

| Prefix | Domain | Invocation |
|--------|--------|------------|
| `ai1st-kit-` | Setup & framework configuration | Manual (`disable-model-invocation: true`) |
| `ai1st-po-` | Product Owner workflow (UI capture, spec, clarify) | Manual |
| `ai1st-dev-` | Development workflow (plan, implement, verify) | Manual |
| `ai1st-qa-` | Quality assurance & testing (E2E, test plans, UI verify) | Manual |
| `ai1st-arch-` | Architecture & legacy analysis (AS-IS, TO-BE) | Manual |
| `ai1st-ops-` | Operational utilities (knowledge sync) | Manual |
| *(no prefix)* | Anthropic Tier 1 & community skills | Auto-triggered |

All `ai1st-*` workflow skills are explicitly user-invoked via `/skill-name`. Anthropic Tier 1 and community skills auto-trigger when a request matches their description.

---

## AI-Kit Workflow Skills (`ai1st-*`)

Migrated from the legacy `.claude/commands/` set. These encode the AI-Kit feature lifecycle from spec to verify.

### Kit — Setup & Configuration (2)

| Skill | Purpose |
|-------|---------|
| `ai1st-kit-engineer` | Activate AI-Kit framework expertise for authoring skills, constitutions, profiles, agents, and prompting best practices. |
| `ai1st-kit-project-init` | Initialize or update project memory files (`.ai_project_memory/`) from templates in `.ai/1_project_init/`. |

### PO — Discovery & Specification (3)

| Skill | Purpose |
|-------|---------|
| `ai1st-po-capture-ui` | Capture UI page context (screenshot + analysis) using Playwright. Supports site-wide discovery, single page, or component capture modes. |
| `ai1st-po-specify` | Create or update the feature specification from a natural language feature description. |
| `ai1st-po-clarify` | Identify underspecified areas in the current feature spec by asking up to 5 highly targeted clarification questions and encoding answers back into the spec. |

### Dev — Planning & Implementation (7)

| Skill | Purpose |
|-------|---------|
| `ai1st-dev-checklist` | Generate a custom checklist for the current feature based on user requirements. |
| `ai1st-dev-plan` | Execute the implementation planning workflow using the plan template to generate design artifacts. |
| `ai1st-dev-plan-confidence` | Score implementation confidence after the plan is produced — gate between planning and implementation. |
| `ai1st-dev-tasks` | Generate an actionable, dependency-ordered `tasks.md` for the feature based on available design artifacts. |
| `ai1st-dev-implement` | Execute the implementation plan by processing and executing all tasks defined in `tasks.md`. |
| `ai1st-dev-test` | Execute a specific test task from the test plan. |
| `ai1st-dev-verify` | Perform rigorous code review of implementation against spec, plan, and constitution. |

### QA — Testing & Verification (7)

| Skill | Purpose |
|-------|---------|
| `ai1st-qa-test-plan-documentation` | Create formal test plan and test case documentation from feature specifications for customer/QA delivery. |
| `ai1st-qa-e2e-web-test-plan` | Design structured test plans for web automation using Playwright Test Agents. |
| `ai1st-qa-e2e-web-test-generate` | Implement test plans for web automation using Playwright test agents. |
| `ai1st-qa-e2e-web-test-debug-and-fix` | Execute, debug and fix failing E2E tests using Playwright test agents. |
| `ai1st-qa-e2e-web-test-sync` | Keep the test case specs updated with the latest changes in their implementation. |
| `ai1st-qa-verify-ui` | Verify UI implementation against reference design using visual and structural analysis. |
| `ai1st-qa-verify-project-compliance` | Project-wide constitutional compliance verification (versions, structure, dependencies, security). |

### Arch — Architecture & Legacy Analysis (6)

| Skill | Purpose |
|-------|---------|
| `ai1st-arch-setup-analysis-scope` | Setup analysis module folder structure and generate `PROJECT-SCOPE.md` for legacy analysis. |
| `ai1st-arch-legacy-sys-analysis` | Execute the 9-step legacy AS-IS brownfield system analysis workflow, producing Arc42 architecture documentation. |
| `ai1st-arch-legacy-analysis-lite` | Lightweight AS-IS legacy system analysis producing Arc42 documentation and requirements traceability matrix. |
| `ai1st-arch-code-quality-analysis` | Deep code quality analysis with metrics, CVE scanning, and architectural recommendations. |
| `ai1st-arch-legacy-to-modern-design` | Generate complete TO-BE modernization spec-kit (5 files) from AS-IS requirements analysis. |
| `ai1st-arch-legacy-to-modern-design-lite` | Generate TO-BE Software Requirements Specification from AS-IS analysis. |

### Ops — Maintenance (1)

| Skill | Purpose |
|-------|---------|
| `ai1st-ops-sync-knowledge` | Export session knowledge from Knowledge Graph MCP to git-versioned markdown files. |

---

## Anthropic Tier 1 Skills (Auto-Triggered)

Adopted from https://github.com/anthropics/skills. Auto-trigger when the user's request matches the description.

| Skill | Purpose | License |
|-------|---------|---------|
| `skill-creator` | Guide for creating effective skills. Use when extending Claude with specialized knowledge, workflows, or tool integrations. | Apache 2.0 |
| `doc-coauthoring` | Structured workflow for co-authoring documentation, proposals, technical specs, decision docs. | Apache 2.0 |
| `frontend-design` | Create distinctive, production-grade frontend interfaces. Avoids generic AI aesthetics in web components, pages, dashboards. | Apache 2.0 |
| `webapp-testing` | Toolkit for interacting with and testing local web applications using Playwright (snapshots, console, network). | Apache 2.0 |
| `internal-comms` | Write internal communications (status reports, leadership updates, 3P updates, FAQs, incident reports). | Apache 2.0 |
| `docx` | Word document creation, editing, and analysis with tracked changes, comments, formatting preservation. | Source-Available |

---

## Community & Custom Skills

| Skill | Purpose | License |
|-------|---------|---------|
| `arc42-documentation` | Generic Arc42 architecture documentation templates with Context7 integration for AS-IS or TO-BE system documentation. | Custom |
| `c4-diagrams` | Create C4 model architecture diagrams using PlantUML (system context, container, component diagrams). | Custom |
| `changelog-maintenance` | Maintain changelog for software releases. Handles semantic versioning, changelog formats, and release notes. | Community |

---

## Skill Lifecycle Quick Reference

The full feature lifecycle stitched together with `/<skill>` invocations:

```
/ai1st-kit-project-init       → Initialize project memory
/ai1st-po-capture-ui          → (Optional) Capture UI context for spec input
/ai1st-po-specify             → Create feature spec (Socratic dialogue)
/ai1st-po-clarify             → Reduce spec ambiguity (up to 5 questions)
/ai1st-dev-checklist          → Generate requirements quality checklist
/ai1st-dev-plan               → Generate implementation plan + design artifacts
/ai1st-dev-plan-confidence    → Score plan confidence (gate before implement)
/ai1st-dev-tasks              → Generate dependency-ordered task list
/ai1st-dev-implement          → Execute implementation tasks
/ai1st-dev-test               → Execute test tasks
/ai1st-dev-verify             → Code review against spec, plan, constitution
/ai1st-qa-verify-ui           → Verify UI against reference design
/ai1st-qa-verify-project-compliance → Constitutional compliance check
```

Architecture / legacy analysis runs as a parallel track:

```
/ai1st-arch-setup-analysis-scope     → PROJECT-SCOPE.md + folder structure
/ai1st-arch-legacy-sys-analysis      → Full 9-step AS-IS Arc42 analysis
  (or /ai1st-arch-legacy-analysis-lite for fewer gates)
/ai1st-arch-code-quality-analysis    → Metrics + CVE + arch recommendations
/ai1st-arch-legacy-to-modern-design  → TO-BE spec-kit (5 files)
  (or /ai1st-arch-legacy-to-modern-design-lite for SRS-only)
```

---

## Skill Anatomy

Each skill is a directory under `.claude/skills/<skill-name>/` containing a required `SKILL.md` plus optional supporting files:

```
<skill-name>/
├── SKILL.md           # Entrypoint with YAML frontmatter + instructions (required)
├── references/        # Detailed reference docs loaded on demand
├── templates/         # Output templates the skill fills in
└── scripts/           # Helper scripts the skill can execute
```

`SKILL.md` frontmatter commonly used in this kit:

```yaml
---
name: skill-name
description: "Front-loaded use case (≤250 chars)"
disable-model-invocation: true   # All `ai1st-*` workflow skills
allowed-tools: Read Grep Glob    # Optional pre-approved toolset
argument-hint: "[feature-name]"  # Optional autocomplete hint
context: fork                    # Optional — run skill in a subagent
agent: Explore                   # Required when context: fork
---
```

Authoritative reference for skill features and frontmatter: https://code.claude.com/docs/en/skills

---

## Adding or Updating Skills

### From the Anthropic upstream

```bash
# Local clone of https://github.com/anthropics/skills
UPSTREAM="/path/to/skills/skills"

# Copy a single skill into the kit
cp -r "$UPSTREAM/<skill-name>" .claude/skills/
```

After copying, verify the SKILL.md frontmatter, license file, and any embedded paths.

### Authoring a new AI-Kit workflow skill

1. Pick a domain segment (`kit`, `po`, `dev`, `qa`, `arch`, `ops`) — the skill name becomes `ai1st-<domain>-<slug>`.
2. Create `.claude/skills/ai1st-<domain>-<slug>/SKILL.md`.
3. Use frontmatter with `disable-model-invocation: true` for workflow side effects.
4. Add the skill to the relevant table in this file.
5. Validate by invoking `/skill-name` and confirming the workflow runs end to end.

For deeper guidance, run `/ai1st-kit-engineer` and follow the skill authoring best practices it loads.

### Plugin marketplace (alternative)

```bash
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills
```

---

## Maintenance

| Cadence | Action |
|---------|--------|
| Per feature | When adding/removing/renaming a skill, update the relevant table in this file. |
| Monthly | Diff against the Anthropic upstream — review new skills for adoption. |
| Quarterly | Review skill usage; archive unused, consolidate overlapping skills. |

---

## Notes

- **Source-available skills** (e.g. `docx`): treat as reference; do not modify license terms.
- **Apache 2.0 skills**: customizable, must retain license notices.
- **Custom AI-Kit skills** (`ai1st-*`): governed by the project repository license.
- All workflow skills are guarded by `disable-model-invocation: true` — they only run when explicitly invoked.

---

## Resources

- **Claude Code Skills Docs**: https://code.claude.com/docs/en/skills
- **Anthropic Skills Repo**: https://github.com/anthropics/skills
- **Agent Skills Standard**: https://agentskills.io
