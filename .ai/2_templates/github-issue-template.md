# GitHub Issue Template

Use this template for creating GitHub issues with Copilot and human workflow instructions.

---

## Issue Structure

```markdown
**Priority**: {High|Medium|Low} | **Effort**: {Low|Medium|High} | **Use Cases**: {UC-XX, UC-YY}

**Topics**:
- Topic N: {Brief description of improvement/fix}

**Rationale**: {Why this issue is prioritized this way}

---

## Acceptance Criteria
- [ ] {Specific, testable criterion 1}
- [ ] {Specific, testable criterion 2}
- [ ] BRD, Use case specification, use case plan, use case tasks are updated

## Files to Modify
- `{path/to/file1.ts}`
- `{path/to/file2.tsx}`

---

## Instructions for Copilot

**IMPORTANT: Analysis-first workflow**

### Step 1: Include analysis in PR description

When you create a PR for this issue, the PR description MUST include:

1. **Related Use Cases & Requirements** - Reference `specs/use-cases/` and `docs/BRD.md`
2. **Current Implementation** - Document relevant files with code quotes and line numbers
3. **Specification vs Implementation Gap** - Compare requirements against implementation
4. **Root Cause Analysis** - Explain why current behavior occurs
5. **Implementation Plan** - List concrete changes (file, function, what to change)

### Step 2: Implement the fixes

After documenting analysis in PR description, proceed with code changes.

### Step 3: Update specifications

After code changes, update relevant spec files in `specs/use-cases/` to document the fixes.

---

## Instructions for Reviewers (Humans)

### PR Review Workflow

1. **Review PR description** - Verify analysis is complete and accurate
2. **Review code changes** - Check implementation matches the plan
3. **Checkout branch locally** for UI testing:
   ```bash
   git fetch origin
   git checkout {branch-name}
   cd packages/UI && npm install && npm run dev
   cd packages/API && npm install && npm run start:dev
   ```
4. **Test in browser** - Verify acceptance criteria are met
5. **Approve or request changes** - Leave review comments
6. **Squash and merge** - After approval, use "Squash and merge" button

### Testing Checklist
- [ ] UI renders correctly
- [ ] Feature works as specified
- [ ] No console errors
- [ ] No regressions in related features

---

## Detailed Topic Specifications

### Topic N: {Title}
> Original: {original feedback text}

**Use Case**: {UC-XX (Name)}

**Description**: {Detailed description of the issue/improvement}

**Current Implementation** (`{file.ts:line-range}`):
- {Current behavior point 1}
- {Current behavior point 2}

**Required Changes**:
- {Change 1}
- {Change 2}

**Complexity**: {Low|Medium|High}
**Dependencies**: {None or list dependencies}
```

---

## Notes

- **Copilot limitations**: Copilot cannot post comments to issues directly. It can only include content in PR descriptions and reply to PR comments.
- **Squash merge required**: All PRs must use squash merge per project constitution.
- **Specification updates**: Implementation changes must be reflected in spec files.
