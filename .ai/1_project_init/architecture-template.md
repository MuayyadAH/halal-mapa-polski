# {PROJECT} System Architecture

**Target Audience**: All developers and architects
**Purpose**: System-level architecture, integration points, and cross-cutting concerns

---

## System Components Overview

### Core Components

1. **{COMPONENT_1}** (`{COMPONENT_1_PATH}`) - {COMPONENT_1_DESCRIPTION}
   - `{SUBCOMPONENT_1A}` - {SUBCOMPONENT_1A_DESCRIPTION}
   - `{SUBCOMPONENT_1B}` - {SUBCOMPONENT_1B_DESCRIPTION}

2. **{COMPONENT_2}** (`{COMPONENT_2_PATH}`) - {COMPONENT_2_DESCRIPTION}
   - `{SUBCOMPONENT_2A}` - {SUBCOMPONENT_2A_DESCRIPTION}
   - `{SUBCOMPONENT_2B}` - {SUBCOMPONENT_2B_DESCRIPTION}

3. **{COMPONENT_3}** (`{COMPONENT_3_PATH}`) - {COMPONENT_3_DESCRIPTION}
   - `{SUBCOMPONENT_3A}` - {SUBCOMPONENT_3A_DESCRIPTION}

4. **{COMPONENT_4}** (`{COMPONENT_4_PATH}`) - {COMPONENT_4_DESCRIPTION}
   - `{SUBCOMPONENT_4A}` - {SUBCOMPONENT_4A_DESCRIPTION}

5. **Database Layer** (`{DB_ROOT}/`) - {DB_DESCRIPTION}

---

## Integration Architecture

### External Systems

| System | Protocol | Purpose |
|--------|----------|---------|
| **{INTEGRATION_1}** | {PROTOCOL_1} | {PURPOSE_1} |
| **{INTEGRATION_2}** | {PROTOCOL_2} | {PURPOSE_2} |
| **{INTEGRATION_3}** | {PROTOCOL_3} | {PURPOSE_3} |

### Data Flow

```
{SOURCE_SYSTEMS}
    ↓ (Import)
{PROCESSING_LAYER}
    ↓ (Transform)
{DATABASE}
    ↓ (Expose)
{API_SERVICES}
    ↓ (Consume)
{CONSUMERS}
```

---

## Data Architecture

### {DATA_MODEL_TYPE} Model

**Characteristics**:
- {DATA_MODEL_CHARACTERISTIC_1}
- {DATA_MODEL_CHARACTERISTIC_2}
- {DATA_MODEL_CHARACTERISTIC_3}

**Target**: {TARGET_DATA_MODEL} in {TARGET_DATABASE}

---

## Security Architecture

### System-Level Security
- Database credentials in environment-specific configuration files
- Service-level authentication between components
- {HOSTING_DESCRIPTION}

### Security Rules
- **NEVER** store connection strings in code
- **NEVER** commit credentials to git
- Use environment-specific configuration files
- See `.ai/0_core_memory/security-rules.md` for full rules

---

## Modernization Strategy (Optional)

*This section applies to projects undergoing legacy modernization.*

### {MODERNIZATION_PATTERN}
1. **Phase 1**: {PHASE_1_DESCRIPTION}
2. **Phase 2**: {PHASE_2_DESCRIPTION}
3. **Phase 3**: {PHASE_3_DESCRIPTION}
4. **Phase 4**: {PHASE_4_DESCRIPTION}

---

**Related Documents**:
- [General Overview](./general-overview.md) - Project overview and context
- [Backend Constitution](./constitution-backend.md) - Backend tech stack, commands, patterns
- [Frontend Constitution](./constitution-frontend.md) - Frontend tech stack, commands, patterns
