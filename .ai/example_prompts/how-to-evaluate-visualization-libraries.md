# How to Evaluate Visualization Libraries

**Purpose**: Reusable methodology for evaluating visualization libraries in future projects

---

## Step 1: Define Requirements

- Identify visualization type needed (charts, maps, graphs, 3D)
- List critical features (e.g., multi-axis support, real-time updates)
- Define performance requirements (data volume, update frequency)
- Document constraints (budget, timeline, tech stack compatibility)
- List evaluation criteria (features, performance, licensing, learning curve)

## Step 2: Select Candidate Libraries

- Research 5-7 candidate libraries covering:
  - Commercial options (if budget allows)
  - Open source popular options
  - Specialized/niche options
  - Low-level libraries (for comparison)
- Check: active maintenance, documentation quality, community size
- Verify: compatibility with project tech stack (React, Vue, Angular, etc.)

## Step 3: Create Scoring Matrix

- Define 6-8 evaluation criteria
- Assign weights based on importance (sum to 100%)
- Weight critical requirements heavily (25%+ each)
- Score each library 1-5 on each criterion
- Calculate weighted totals

## Step 4: Collect Evidence

- Capture screenshots from official documentation
- Find examples of critical features (multi-axis, 3D, etc.)
- Automate screenshot capture if evaluating many libraries (Puppeteer)
- Document deployment requirements (WASM, special configs)
- Check bundle sizes and performance benchmarks

## Step 5: Research Validation

- Search for production use cases (recent years)
- Validate performance claims with recent benchmarks
- Check licensing changes or updates
- Review tech stack integration quality
- Assess documentation completeness
- Identify known issues or regressions

## Step 6: Adjust Scores Based on Research

- Update scores based on validation findings
- Document changes and rationale
- Recalculate weighted totals
- Rank libraries by final score

## Step 7: Create Decision Tree

- Build decision tree based on key factors:
  - Budget (free vs commercial)
  - Timeline (fast development vs custom)
  - Performance (millions of points vs moderate data)
  - Team expertise (library familiarity)
- Provide clear recommendation with rationale
- Identify risks and mitigation strategies

## Step 8: Document and Commit

- Create analysis document with full evaluation
- Create research validation report with evidence
- Commit to git with clear decision rationale
- Reference decision in architecture documentation
