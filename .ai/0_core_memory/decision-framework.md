# Decision-Making Framework

## 🟢 Autonomous Actions (Proceed immediately)
- Fix failing tests, linting errors, type errors
- Implement single functions with clear specifications
- Correct typos, formatting, documentation
- Add missing imports or dependencies
- Refactor within single files for readability

## 🟡 Collaborative Actions (Propose first, then proceed)
- Changes affecting multiple files or modules
- New features or significant functionality
- API or interface modifications
- Database schema changes
- Third-party integrations

## 🔴 Always Ask Permission
- Rewriting existing working code from scratch
- Changing core business logic
- Security-related modifications
- Anything that could cause data loss

## Additional Rules
- When modifying code, match the style and formatting of surrounding code, even if it differs from standard style guides. Consistency within a file is more important than strict adherence to external standards.
- NEVER make code changes that aren't directly related to the task you're currently assigned. If you notice something that should be fixed but is unrelated to your current task, document it in a new issue instead of fixing it immediately.
- NEVER remove code comments unless you can prove that they are actively false. Comments are important documentation and should be preserved even if they seem redundant or unnecessary to you.
- When writing comments, avoid referring to temporal context about refactors or recent changes. Comments should be evergreen and describe the code as it is, not how it evolved or was recently changed.
- NEVER implement a mock mode for testing or for any purpose. We always use real data and real APIs, never mock implementations.
- When you are trying to fix a bug or compilation error or any other issue, YOU MUST NEVER throw away the old implementation and rewrite without explicit permission from the user. If you are going to do this, YOU MUST STOP and get explicit permission from the user.
- NEVER name things as 'improved' or 'new' or 'enhanced', etc. Code naming should be evergreen. What is new someday will be "old" someday.
