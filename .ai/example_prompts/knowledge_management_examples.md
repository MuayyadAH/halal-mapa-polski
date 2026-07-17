# Knowledge Management Example Prompts

> **Purpose**: Simple examples for using the knowledge management system
> **Last Updated**: 2025-10-28

---

## Quick Reference

### Where to Find Information

```markdown
# Project Overview
Read ../.ai_project_memory/general-overview.md

# System Architecture
Read ../.ai_project_memory/architecture.md

# Coding Standards
Read .ai/0_core_memory/coding-standards.md
Read .ai/0_core_memory/decision-framework.md

# Project Documentation
Read docs/ directory files
```

---

## Common Scenarios

### Example 1: Starting a New Feature

**Scenario**: You're implementing a new feature

```markdown
User: I need to add a new feature. What do I need to know?

Steps:
1. Read ../.ai_project_memory/general-overview.md - Project context
2. Read ../.ai_project_memory/architecture.md - System architecture
3. Read the relevant stack constitution (constitution-frontend.md or constitution-backend.md)
4. Check specs/ for feature specifications if available
4. Look at existing code structure
5. Follow coding standards from .ai/0_core_memory/coding-standards.md

Result: Clear understanding of architecture and patterns to use
```

---

### Example 2: Understanding Project Setup

**Scenario**: How do I run this project?

```markdown
User: How do I get this project running?

Quick Answer:
Read ../.ai_project_memory/constitution-backend.md or constitution-frontend.md - Commands section

Shows:
- Prerequisites required
- Build commands
- Test commands
- Package management

Result: Project running in under 5 minutes
```

---

### Example 3: Checking Code Standards

**Scenario**: What coding standards should I follow?

```markdown
User: What are the coding standards for this project?

Steps:
1. Read .ai/0_core_memory/coding-standards.md - Core principles
2. Read ../.ai_project_memory/constitution.md - Project-specific conventions

Key Points:
- Simple, clean, maintainable solutions
- Match surrounding code style
- Tests are mandatory
- Fix root causes, don't work around

Result: Clear guidelines for writing code
```

---

### Example 4: Making Architectural Decisions

**Scenario**: Should I make a significant architectural change?

```markdown
User: Should I refactor the data layer for this feature?

Steps:
1. Read ../.ai_project_memory/general-overview.md
   - Check: Current architecture approach
2. Read .ai/0_core_memory/decision-framework.md
   - Check: Is this a "Always Ask" decision? Yes!

Action: Ask user before changing architecture

Result: Avoided making unauthorized architectural change
```

---

### Example 5: Finding Technical Documentation

**Scenario**: Where are the detailed implementation notes?

```markdown
User: Show me the detailed technical documentation

Answer:
Read ../.ai_project_memory/architecture.md
Read the relevant stack constitution (constitution-frontend.md or constitution-backend.md)
Read docs/ for additional documentation

Contains:
- System architecture and integration points
- Tech stack, commands, and code structure (per stack)
- Architecture decisions
- Design patterns used

Result: Complete technical reference
```

---

## Session Workflow

### Session Start Template

```markdown
# Starting work on [FEATURE]

Pre-flight checklist:
1. Read ../.ai_project_memory/general-overview.md - Project context
2. Read ../.ai_project_memory/architecture.md - System architecture
3. Read the relevant stack constitution (constitution-frontend.md or constitution-backend.md)
4. Review coding standards in .ai/0_core_memory/
4. Check relevant docs/ and specs/ files

Ready to start: [Yes/No]
```

---

### During Development

```markdown
# Quick lookups during coding

Question: "What are the code style conventions?"
Answer: ../.ai_project_memory/constitution.md
        → Follow project-specific patterns
        → Match surrounding code style

Question: "Should I write tests?"
Answer: .ai/0_core_memory/coding-standards.md
        → "NO EXCEPTIONS POLICY: Every project MUST have unit tests,
           integration tests, AND end-to-end tests"

Question: "Can I disable this check to move faster?"
Answer: .ai/0_core_memory/decision-framework.md
        → "NEVER disable functionality instead of fixing the root cause"
```

---

## Simple Best Practices

### 1. Read Before You Code

Always check existing documentation before starting:
- `.ai_project_memory/general-overview.md` - Project overview
- `.ai_project_memory/architecture.md` - System architecture
- `.ai/0_core_memory/` - Standards and guidelines

### 2. Follow the Decision Framework

Before making changes, check the traffic light system:
- **Autonomous** - Fix bugs, add tests, correct typos
- **Collaborative** - Propose multi-file changes first
- **Always Ask** - Architecture, security, data loss risk

### 3. Write Tests

Ensure test coverage for implemented features:
- Write tests that cover business logic
- Verify edge cases from specifications
- Keep tests independent and focused

### 4. Keep It Simple

From coding standards:
> "We prefer simple, clean, maintainable solutions over clever or complex ones"

---

## File Reference Guide

| File | Purpose | When to Read |
|------|---------|--------------|
| `.ai_project_memory/general-overview.md` | Project overview and context | Start of every session |
| `.ai_project_memory/architecture.md` | System architecture, integration points | When you need system-level context |
| `.ai_project_memory/constitution-frontend.md` | FE tech stack, commands, patterns | When doing frontend work |
| `.ai_project_memory/constitution-backend.md` | BE tech stack, commands, patterns | When doing backend work |
| `.ai/0_core_memory/coding-standards.md` | Core coding principles | Before writing code |
| `.ai/0_core_memory/decision-framework.md` | Decision-making rules | Before making changes |
| `docs/*.md` | Project documentation | When implementing features |
| `specs/` | Feature specifications | When implementing specific features |
| `README.md` | Getting started guide | First time setup |

---

## Success Pattern

**Efficient Session Flow**:

1. **Setup** (2 minutes)
   - Read `.ai_project_memory/general-overview.md` for project context
   - Check relevant `.ai/` files for guidelines

2. **Plan** (5 minutes)
   - Review existing code structure
   - Check `docs/` and `specs/` for patterns
   - Follow decision framework

3. **Implement** (main work)
   - Write tests for business logic
   - Follow code style from constitution
   - Keep it simple and maintainable

4. **Verify** (before completion)
   - Tests passing
   - Code follows standards
   - No disabled functionality

**Total overhead**: ~7 minutes of reading saves hours of rework

---

## Quick Start

**First time working on this project?**

```markdown
# 5-Minute Orientation

1. Read README.md (1 min) - What is this project?
2. Read ../.ai_project_memory/general-overview.md (2 min) - Project details
3. Read ../.ai_project_memory/architecture.md (2 min) - System architecture
4. Read the relevant stack constitution for commands and setup

Done! You're ready to contribute.
```

---

**Remember**: Always read documentation before coding. Understanding the project context saves time and prevents mistakes.
