---
name: ai1st-dev-plan-confidence
description: "Score implementation confidence after the plan is produced — gate between planning and implementation."
disable-model-invocation: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

This skill runs **after `/ai1st-dev-plan`** (and optionally `/ai1st-dev-tasks`, `/ai1st-dev-checklist`) and **before `/ai1st-dev-implement`**. It reads the plan artifacts and produces a quantitative **implementation confidence score** plus a go / hold / no-go recommendation.

Unlike `/ai1st-dev-verify` (post-implementation code review), this skill does **not** read source code — it evaluates whether the *plan itself* is ready to be implemented.

## Outline

1. **Setup**: Run `.ai/scripts/bash/check-prerequisites.sh --json` from repo root and parse JSON for `FEATURE_DIR` and `AVAILABLE_DOCS`. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load plan artifacts** (read in parallel where possible):
   - **REQUIRED**: `FEATURE_DIR/plan.md` — if missing, ERROR: "Run /ai1st-dev-plan first"
   - **REQUIRED**: `FEATURE_DIR/spec.md` — feature specification
   - **REQUIRED**: `FEATURE_DIR/research.md` — technical decisions
   - **IF EXISTS**: `FEATURE_DIR/data-model.md` — entities and relationships
   - **IF EXISTS**: `FEATURE_DIR/contracts/` — API/interface contracts
   - **IF EXISTS**: `FEATURE_DIR/quickstart.md` — integration scenarios
   - **IF EXISTS**: `FEATURE_DIR/tasks.md` — task breakdown (from /ai1st-dev-tasks)
   - **IF EXISTS**: `FEATURE_DIR/checklists/*.md` — checklists (from /ai1st-dev-checklist)
   - **IF EXISTS**: `FEATURE_DIR/design/` — UI reference (from /ai1st-po-capture-ui)
   - **REQUIRED**: `.ai_project_memory/constitution.md` — project principles

3. **Evaluate confidence across six dimensions** (each scored 0–100):

   ### Dimension 1: Completeness (weight 25%)
   - Are all `NEEDS CLARIFICATION` markers resolved in plan.md / research.md?
   - Every **TBD** in spec.md or design/description.md addressed?
   - Required artifacts present for the feature type (data-model.md if persistence; contracts/ if APIs; design/ if UI)?
   - **Score**: `100 - (20 × unresolved_markers) - (15 × missing_required_artifacts)`, floor at 0.

   ### Dimension 2: Constitution Alignment (weight 20%)
   - Constitution Check section in plan.md: all gates **PASS**?
   - Violations documented with explicit justification?
   - Stack constitution (`constitution-frontend.md` / `constitution-backend.md`) updated with new tech?
   - **Score**: 100 if all pass; `-30` per unjustified violation; `-10` per missing stack update.

   ### Dimension 3: Technical Decision Quality (weight 20%)
   - Each decision in research.md has **Decision / Rationale / Alternatives / Source**?
   - Dependencies pinned to versions? Integration points named?
   - No hand-waving ("TBD", "figure out later", "somehow")?
   - **Score**: `100 − (10 × decisions_missing_rationale) − (5 × unpinned_dependencies)`.

   ### Dimension 4: Requirement Clarity (weight 15%)
   Always scored from `spec.md` — **never deferred**. Measures whether the business intent is specific enough that an implementer (human or AI) can act without guessing.
   - Each functional requirement names a concrete **entity/artifact** (not only a verb)?
   - Each requirement names the specific **field / attribute / behavior** being changed or added?
   - Each requirement names the **scope / context** (which module, screen, API, flow) so the target is unambiguous?
   - Acceptance criteria are **measurable / observable** (not "works well", "is fast", "feels right")?
   - Data-model entities trace to spec requirements (FR-###)? Contracts trace to user actions in spec.md?
   - No unresolved `NEEDS CLARIFICATION` / `TBD` inside requirement statements?
   - **Vague-requirement heuristic**: flag any requirement using "add / update / handle / support / improve / enhance" without a named entity **and** a named field/behavior **and** a named scope.
     - Example LOW: *"add new field to search"* → no entity, no field, no scope → vague
     - Example MED: *"add new field is_claimed to search"* → field named, scope ambiguous → partially vague
     - Example HIGH: *"add new field is_claimed to company search"* → entity + field + scope → clear
   - **Score**: `100 − (15 × vague_requirements) − (10 × requirements_without_measurable_acceptance) − (10 × orphan_entity_or_endpoint)`, floor at 0.

   ### Dimension 5: Task Structure (weight 5%)
   - If `tasks.md` exists: phases (Setup / Tests / Core / Integration / Polish) populated? Parallel markers `[P]` consistent with file-coordination rules? No circular dependencies?
   - If `tasks.md` missing: mark dimension as **DEFERRED** and note "Run /ai1st-dev-tasks for full score". See step 4 for how DEFERRED affects the overall score.
   - **Score**: `100 − (15 × missing_phase) − (20 × circular_dep) − (10 × inconsistent_parallel_marker)`, floor at 0.

   ### Dimension 6: Risk & Blockers (weight 15%)
   - Checklists (`checklists/*.md`): all items checked `[X]`? (If checklists missing, note but do not penalize heavily.)
   - External dependencies (third-party APIs, new libraries, infra changes) flagged and researched?
   - Missing backend endpoints noted in plan?
   - **Score**: 100 − (5 × incomplete_checklist_items) − (15 × unresolved_blocker).

4. **Compute overall confidence**: weighted average of the six dimensions. Round to nearest integer %.
   - If **Dimension 5 (Task Structure)** is `DEFERRED`, omit it from the sum and **renormalize** the remaining weights to 100% (effectively: divide weighted sum by 0.95). Flag in the report that the score is computed without Task Structure.
   - No other dimension may be deferred.

5. **Determine recommendation**:
   - **≥ 85%** → **GO**: proceed to `/ai1st-dev-implement`
   - **70–84%** → **HOLD**: address listed gaps, then re-run this skill
   - **< 70%** → **NO-GO**: re-run `/ai1st-dev-plan` (and `/ai1st-po-clarify` if spec gaps) before continuing

6. **Write report** to `FEATURE_DIR/plan-confidence.md` using the structure below. Also print a condensed summary to the user.

## Report Structure

```markdown
# Plan Confidence Report

**Feature**: {feature name}
**Branch**: {branch}
**Date**: {YYYY-MM-DD}
**Overall Confidence**: **{NN}%** → **{GO | HOLD | NO-GO}**

## Dimension Scores

| Dimension | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Completeness | 25% | {NN} | {NN.N} |
| Constitution Alignment | 20% | {NN} | {NN.N} |
| Technical Decision Quality | 20% | {NN} | {NN.N} |
| Requirement Clarity | 15% | {NN} | {NN.N} |
| Task Structure | 5% | {NN \| DEFERRED} | {NN.N \| —} |
| Risk & Blockers | 15% | {NN} | {NN.N} |
| **Total** | **100%** | — | **{NN.N}** |

> If **Task Structure** is DEFERRED, the total is renormalized over the remaining 95% and the table notes `(Task Structure deferred — score renormalized)`.

## Findings by Dimension

### Completeness — {NN}/100
- ✅ {positive observation with artifact:line reference}
- ⚠️ {gap with artifact:line reference and suggested fix}

### Constitution Alignment — {NN}/100
...

### Technical Decision Quality — {NN}/100
...

### Requirement Clarity — {NN}/100
- ✅ {FR with named entity + field + scope, spec.md:line}
- ⚠️ {vague requirement at spec.md:line — missing {entity | field | scope}; suggest rewrite: "..."}

### Task Structure — {NN}/100 | DEFERRED
- (If DEFERRED) Run `/ai1st-dev-tasks` to produce tasks.md; score renormalized without this dimension.
- (If scored) ✅/⚠️ findings referencing tasks.md:line

### Risk & Blockers — {NN}/100
...

## Blockers (must resolve before /ai1st-dev-implement)
1. {blocker} — fix in `{file}:{line}`
2. ...

## Recommended Actions
- [ ] {action with owning artifact}
- [ ] ...

## Next Step
- **GO** → Run `/ai1st-dev-implement`
- **HOLD** → Address blockers above, re-run `/ai1st-dev-plan-confidence`
- **NO-GO** → Re-run `/ai1st-dev-plan` (and `/ai1st-po-clarify` if spec gaps)
```

## Key Rules

- Use absolute paths everywhere.
- This skill is **READ-ONLY** — it does not modify plan artifacts, only writes the confidence report.
- If a required artifact is missing, ERROR with the exact skill (e.g. `/ai1st-dev-plan`, `/ai1st-dev-tasks`) that produces it.
- Cite every finding with `file_path:line_number` so the user can jump to the source.
- **Token efficiency**: read artifacts once, cache in variables, make Read/Grep calls in parallel.
- **Task delegation**: for large plans, delegate per-dimension scoring to the `verification-agent` sub-agent in parallel.
- Do **not** read source code — source-code review belongs to `/ai1st-dev-verify` (post-implementation).
- Never auto-approve `GO`: always surface weakest-scoring dimension, even at 95%+.
