# [Screen Name] - Software Requirements Specification

**Document Code**: ITX-[MODULE]-[NNN].[VERSION]
**Module**: [Module Name]
**Version**: X.X
**Date**: YYYY-MM-DD
**Status**: Draft | In Review | Approved

---

## Version Control

| Version | Responsible Person | Date | Comments |
|---------|-------------------|------|----------|
| 1.0 | [Name] | YYYY-MM-DD | Initial version |

---

## Summary

[1-2 sentence functional description of the screen's purpose]

<!--
INSTRUCTION: Describe WHAT the screen does, not HOW it's implemented.
Example: "This screen allows users to view and manage payment records, including filtering, sorting, and initiating new payments."
-->

---

## Prototype

**Figma/Design Link**: [URL]

<!--
INSTRUCTION: Link to the UI design. If no design exists, mark as "To be designed".
-->

---

## Permissions

| Role | Access Level | Notes |
|------|--------------|-------|
| [Role Name] | View / Edit / Admin | [Special conditions] |

<!--
INSTRUCTION: List all user roles that can access this screen and their permission level.
-->

---

## Starting Event

**Navigation Path**: [Menu] → [Submenu] → [Screen]

**URL Pattern**: `/module/screen` (if applicable)

<!--
INSTRUCTION: Document how users reach this screen. Include menu path and any direct URL patterns.
-->

---

## Initial State

**Pre-conditions**:
- [Condition 1 - e.g., User must be authenticated]
- [Condition 2 - e.g., User must have required permission]

**Default View**:
- [What the user sees when screen loads]
- [Default filter/sort settings]
- [Empty state behavior]

<!--
INSTRUCTION: Describe what the screen looks like when first loaded.
-->

---

## Attributes

| # | Field Name | Database | Format and Validation |
|---|------------|----------|----------------------|
| 1 | [Display Name] | [TABLE.COLUMN] | [Data type, format, constraints] |
| 2 | [Display Name] | [TABLE.COLUMN] | [Data type, format, constraints] |

<!--
INSTRUCTION: Map each UI field to its database column. Include:
- Data type (varchar, number, date, etc.)
- Format (e.g., "YYYY-MM-DD", "999,999.99")
- Length constraints
- Required/Optional
- Default values

Example:
| 1 | Document Date | ACC_PAYMENT.DOCUMENT_DATE | Date, YYYY-MM-DD, Required |
| 2 | Amount | ACC_PAYMENT.AMOUNT | Number(15,2), >= 0, Required |
-->

---

## Validation Rules

| Rule ID | Field(s) | Condition | Error Message |
|---------|----------|-----------|---------------|
| VR01 | [Field] | [Validation condition] | [User-facing error message] |
| VR02 | [Field] | [Validation condition] | [User-facing error message] |

<!--
INSTRUCTION: Document all validation rules. Use VR## numbering.

Example:
| VR01 | Amount | Must be greater than 0 | "Amount must be a positive number" |
| VR02 | Document Date | Cannot be future date | "Document date cannot be in the future" |
| VR03 | Amount, Balance | Amount <= Available Balance | "Insufficient balance for this payment" |
-->

---

## Actions

| # | Action | Trigger | Behavior | Result |
|---|--------|---------|----------|--------|
| 1 | [Action Name] | [Button/Link/Event] | [What happens] | [Outcome/Navigation] |
| 2 | [Action Name] | [Button/Link/Event] | [What happens] | [Outcome/Navigation] |

<!--
INSTRUCTION: Document all user actions available on this screen.

Example:
| 1 | Save | Click "Save" button | Validates form, saves to database | Success message, stays on screen |
| 2 | Submit | Click "Submit" button | Validates, changes status to "Submitted" | Navigates to confirmation screen |
| 3 | Cancel | Click "Cancel" button | Discards changes | Returns to list screen |
-->

---

## Views

### View.1 [View Name]

**Purpose**: [What this view shows]

#### Attributes
| Field Name | Database | Format |
|------------|----------|--------|
| [Field] | [TABLE.COLUMN] | [Format] |

#### Validations
- VR-V1-01: [View-specific validation]

#### Actions
- [View-specific actions]

<!--
INSTRUCTION: If the screen has multiple views (tabs, panels, modes), document each separately.
-->

---

## Modal Windows

### [Modal Name]

**Trigger**: [What opens this modal]
**Purpose**: [What the modal is for]

#### Attributes
| Field Name | Database | Format |
|------------|----------|--------|
| [Field] | [TABLE.COLUMN] | [Format] |

#### Validations
| Rule ID | Condition | Error Message |
|---------|-----------|---------------|
| VR-M01 | [Condition] | [Message] |

#### Actions
| Action | Behavior | Result |
|--------|----------|--------|
| [Action] | [Behavior] | [Result] |

<!--
INSTRUCTION: Document any modal/popup windows triggered from this screen.
-->

---

## Additional Requirements

### Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-01 | [Performance/Security/Usability requirement] | [Measurable target] |

### Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| [Edge case description] | [How system should behave] |

<!--
INSTRUCTION: Document any requirements not covered above.
-->

---

## Open Issues

| # | Issue | Status | Resolution |
|---|-------|--------|------------|
| 1 | [Pending decision/question] | Open / Resolved | [Resolution if resolved] |

<!--
INSTRUCTION: Track unresolved questions or decisions. Remove when resolved.
-->

---

## Traceability

### BRD Mapping

| SRS Requirement | BRD Source | Notes |
|-----------------|------------|-------|
| VR01 | FR-[xxxx] | [Mapping notes] |
| Action 1 | FR-[xxxx] | [Mapping notes] |

### Related SRS Documents

| Document Code | Screen Name | Relationship |
|---------------|-------------|--------------|
| ITX-[MODULE]-[NNN] | [Screen] | [Parent/Child/Related] |

<!--
INSTRUCTION: Link all requirements back to BRD functional requirements.
Document relationships to other SRS documents in the same user flow.
-->

---

## Review Checklist

- [ ] All attributes mapped to database columns
- [ ] All validation rules documented with error messages
- [ ] All actions documented with expected behavior
- [ ] Permissions defined for all user roles
- [ ] Traceability to BRD requirements complete
- [ ] Prototype link included
- [ ] Open issues tracked or resolved

---

*Template Version: 1.0*
*Based on: OTA ITX-TPR document format*
