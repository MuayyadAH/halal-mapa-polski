# UI Review Report: [FEATURE NAME]

**Reference**: [specs path or URL]
**Implementation**: [URL]
**Date**: [DATE]
**Review ID**: [DIR NAME]

---

## Summary

**Verdict**: [BLOCKED / NEEDS CHANGES / APPROVED]

| Metric | Count |
|--------|-------|
| Critical issues | [N] |
| Major issues | [N] |
| Minor issues | [N] |
| Total issues | [N] |

Verdict rules:
- **BLOCKED**: Any critical issues exist
- **NEEDS CHANGES**: No critical, but major issues exist
- **APPROVED**: Only minor or no issues

---

## Critical Issues

<!-- BLOCKS APPROVAL. Each checkbox = one actionable fix task.
     Format: "Fix [element]: reference shows [X] but implementation shows [Y]. Change [what] to [value] in [file:line]"
     Include: exact file path, line number, current value, expected value, design token if applicable.
     The NEXT agent marks these [X] when fixed. -->

---

## Major Issues

<!-- SHOULD FIX. Same checkbox format as Critical Issues.
     Format: "Fix [element]: reference shows [X] but implementation shows [Y]. Change [what] to [value] in [file:line]" -->

---

## Minor Issues

<!-- NICE TO FIX. Same checkbox format as Critical Issues.
     Format: "Fix [element]: reference shows [X] but implementation shows [Y]. Change [what] to [value] in [file:line]" -->

---

## Style Comparison

### Color Mismatches

<!-- Compare reference styles.json colors vs implementation impl-styles.json colors -->

| Element | Reference (hex) | Implementation (hex) | Design Token | File:Line |
|---------|----------------|---------------------|--------------|-----------|

### Typography Mismatches

<!-- Compare reference styles.json typography vs implementation -->

| Element | Ref Font/Size/Weight | Impl Font/Size/Weight | Design Token | File:Line |
|---------|---------------------|----------------------|--------------|-----------|

### Spacing Mismatches

<!-- Compare reference styles.json spacing vs implementation -->

| Element | Ref Padding/Margin | Impl Padding/Margin | Design Token | File:Line |
|---------|-------------------|---------------------|--------------|-----------|

### Icon Mismatches

<!-- Compare reference styles.json icons vs implementation icons -->

| Icon Context | Reference | Implementation | File:Line |
|-------------|-----------|----------------|-----------|

---

## Artifacts

| Artifact | Path |
|----------|------|
| Review tasks | [REPORT_DIR]/review_tasks.md |
| Report | [REPORT_DIR]/report.md |
| Impl styles | [REPORT_DIR]/impl-styles-*.json |

---

## Severity Reference

| Severity | Criteria |
|----------|----------|
| CRITICAL | Component type differs, element missing, behavior differs, wrong position, overlay missing |
| MAJOR | Style significantly different, icon wrong, text wrong, layout off |
| MINOR | Slight text variation, minor spacing, icon style variation |
