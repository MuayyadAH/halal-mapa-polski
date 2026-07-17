# How to Evaluate Architecture Options

**Purpose**: Reusable methodology for evaluating architectural options in future projects

---

## Step 1: Define Requirements

- List functional requirements (features, scale, users)
- List non-functional requirements (performance, cost, reliability)
- Document constraints (budget, timeline, team skills)
- Identify must-have vs nice-to-have criteria

## Step 2: Generate Options

- Create at least 4 distinct architectural options
- Cover spectrum: simple → complex, cheap → expensive
- Include different hosting approaches (serverless, containers, K8s)
- Include different data platform options
- Document each option with: components, costs, pros/cons

## Step 3: Create Scoring Matrix

- Define 5-6 evaluation criteria (simplicity, cost, performance, etc.)
- Assign weights based on project priorities (sum to 100%)
- Score each option 1-5 on each criterion
- Calculate weighted totals

## Step 4: Research Validation

- Validate ALL technical claims with recent sources (last 1-2 years)
- Research: pricing, performance benchmarks, production case studies
- Check platform reliability (outage history, StatusGator, IsDown)
- Verify library versions and maturity status
- Document expert consensus from community
- Correct any unverified claims or outdated assumptions

## Step 5: Integrate Team Context

- Discover team constraints (primary expertise, limited resources)
- Add "Team Expertise" as evaluation criterion (25% weight)
- Recalculate scores with team context
- Identify resource bottleneck risks
- Leverage existing infrastructure when available

## Step 6: Document as ADR

- Convert analysis to Architecture Decision Record format
- ADR sections: Status, Context, Decision, Consequences, Alternatives
- Decision section: Chosen architecture with clear rationale
- Consequences: Benefits, trade-offs, risks with mitigations
- Alternatives: Preserve full research and scoring
- Create visual diagrams (PlantUML) for PoC and production

## Step 7: Validate and Simplify

- Question assumptions with fresh perspective
- Remove unnecessary complexity (do we really need X?)
- Ensure clear separation of concerns in architecture
- Verify modern approaches over legacy (e.g., REST API vs ODBC)
- Update cost estimates and risk assessments

