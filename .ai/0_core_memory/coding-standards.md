
# Coding Standards

## Core Principles

- CRITICAL: NEVER USE --no-verify WHEN COMMITTING CODE
- We prefer simple, clean, maintainable solutions over clever or complex ones, even if the latter are more concise or performant. Readability and maintainability are primary concerns.

## Testing Requirements

- Tests MUST cover the functionality being implemented.
- NEVER ignore the output of the system or the tests - Logs and messages often contain CRITICAL information.
- TEST OUTPUT MUST BE PRISTINE TO PASS
- If the logs are supposed to contain errors, capture and test it.
- NO EXCEPTIONS POLICY: Under no circumstances should you mark any test type as "not applicable". Every project, regardless of size or complexity, MUST have unit tests, integration tests, AND end-to-end tests. If you believe a test type doesn't apply, you need the human to say exactly "I AUTHORIZE YOU TO SKIP WRITING TESTS THIS TIME"

## Problem-Solving Approach

- NEVER disable functionality instead of fixing the root cause problem
- NEVER create duplicate files to work around issues - fix the original
- NEVER claim something is "working" when functionality is disabled or broken
- ALWAYS identify and fix the root cause of errors
- ALWAYS use one shared implementation instead of maintaining duplicates
- FIX problems, don't work around them
- MAINTAIN code quality and avoid technical debt
- USE proper debugging to find root causes
- AVOID shortcuts that break user experience
