# Knowledge Base

> **Git-versioned team knowledge for quick reference**

## Purpose

This directory stores **permanent, team-shared knowledge** that is:
- ✅ Git-versioned (shared with entire team via repository)
- ✅ Extracted from expensive sources (Context7, constitution.md, codebase analysis)
- ✅ Frequently accessed during development
- ✅ Valuable for onboarding and daily work

## Files

| File | Purpose | When to Read |
|------|---------|--------------|
| **decisions.md** | Architectural Decision Records (ADRs) | When making similar decisions, code reviews |
| **patterns.md** | Code patterns and best practices | During implementation, need quick example |
| **optimization.md** | MCP/Context7 usage strategies | Start of session, planning new features |

---

## Knowledge Management Strategy

### Two-Tier Knowledge System

**1. Knowledge Graph MCP (Session Memory)**
- ✅ Temporary notes during active work
- ✅ Quick lookups within current session
- ✅ Brainstorming and exploration
- ❌ NOT git-versioned (lost after session)
- ❌ NOT shared with team

**2. Markdown Files (Permanent Knowledge)**
- ✅ Git-versioned (committed to repository)
- ✅ Shared with entire team
- ✅ Source of truth for decisions and patterns
- ✅ Survives across sessions and agents

### When to Use Which

**Use Knowledge Graph MCP when**:
- Taking notes during exploratory work
- Recording session-specific context
- Tracking temporary decisions or ideas
- Maintaining state during active development

**Use Markdown Files when**:
- Architectural decision is final
- Pattern is validated and reusable
- Information should be shared with team
- Knowledge should persist permanently

---

## How AI Assistants Should Use This

### Start of Session
1. **READ**: `.ai/knowledge/optimization.md` - Understand efficient MCP usage
2. **SKIM**: `.ai/knowledge/decisions.md` - Recent architectural decisions
3. **REFERENCE**: `.ai/knowledge/patterns.md` - When implementing similar code

### During Session
- **Need code example?** → Check `patterns.md` first
- **Making architectural choice?** → Check `decisions.md` for precedent
- **Using expensive MCP?** → Check `optimization.md` for best practices

### End of Session Workflow
1. **Export valuable knowledge from Knowledge Graph MCP**:
   - Use `/ai1st-ops-sync-knowledge` slash command
   - Or manually review Knowledge Graph entities
2. **Extract to appropriate markdown file**:
   - Architectural decisions → `decisions.md`
   - Code patterns → `patterns.md`
   - MCP insights → `optimization.md`
3. **Commit to git** for team sharing 

---

## Maintenance Guidelines

### When to Update

**decisions.md**:
- ✅ Made significant architectural decision
- ✅ Chose technology or pattern over alternatives
- ✅ Team agreed on new standard approach
- ❌ One-off feature decisions (put in feature spec instead)

**patterns.md**:
- ✅ Discovered reusable pattern from Context7 or codebase
- ✅ Team standardized on approach
- ❌ Experimental patterns (wait for validation)

**optimization.md**:
- ✅ Discovered new MCP/Context7 optimization technique
- ✅ Identified repeated expensive operations
- ❌ One-time savings (not repeatable)

### How to Update

**Manual Edit**:
- Use `Edit` tool to add new entries
- Follow existing format (see templates in each file)
- Add date (YYYY-MM-DD) to all entries

**Automated Export from Knowledge Graph**:
- Use `/ai1st-ops-sync-knowledge` slash command at end of session
- Review generated entries before committing
- Move valuable knowledge to appropriate markdown file

---

## Relationship to Other Documentation

### Quick Reference vs Source of Truth

| Document | Type | Purpose | Read Frequency |
|----------|------|---------|----------------|
| `.ai/knowledge/*.md` | **Quick Reference** | Fast lookups, summaries | Every session |
| `.ai_project_memory/constitution.md` | **Source of Truth** | Complete architectural principles | Weekly, gate reviews |
| `.ai_project_memory/general-overview.md` | **Source of Truth** | Project context and architecture | Session start |
| `specs/NNN-feature/` | **Source of Truth** | Feature requirements, design | Per feature |

### Extraction Strategy

This directory contains **distilled knowledge** extracted from larger sources:

1. Identify frequently-accessed information in large documents (constitution.md, Context7 docs)
2. Extract key decision or pattern to appropriate `.ai/knowledge/` file
3. Reference in daily development without re-reading full source

**Example**: constitution.md principle "DTOs MUST be flat structures" → Extract to `decisions.md` as "ADR-002: Flat DTOs Only" for quick reference

---

## Lookup Priority for AI Assistants

When answering questions about architecture, patterns, or decisions:

1. **CHECK HERE FIRST**: `.ai/knowledge/*.md` files (quick reference)
2. **If not found**: Use Knowledge Graph MCP (session memory)
3. **If still not found**: Read full source documents (constitution.md, general-overview.md)
4. **If still not found**: Use expensive MCP tools (Context7, Atlassian)
5. **After finding answer**: Consider extracting to `.ai/knowledge/` for future sessions

---

## Version Control

**Commit Guidelines**:
- ✅ Commit all updates to `.ai/knowledge/` files to git
- ✅ Include in feature branch PRs when relevant
- ✅ Use descriptive commit messages: `docs: add ADR-004 for circuit breaker pattern`
- ✅ Team reviews knowledge updates in PRs

**Important**: This directory is git-versioned (NOT in .gitignore) - it's shared team knowledge

---

**Last Updated**: 2025-11-24
**Maintained By**: Development team
