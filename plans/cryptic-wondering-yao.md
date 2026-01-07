# Plan: README.md Corrections

## Overview
Implement 7 validated corrections from meta-review to improve README.md alignment with RFQ and AI agent usability.

---

## Corrections

### 1. Add User Roles Section
**Location:** After `Platform Capabilities` (line ~210)
**Change:** Add new section

```markdown
## User Roles

| Role | Scope | Capabilities |
|------|-------|--------------|
| **Admin** | System-wide | Full configuration, user management, all data access |
| **Operations** | Run assignments, fitness status | View/edit daily assignments, fitness updates, mileage actuals |
| **Maintenance** | Planning, scheduling, resources | View/edit maintenance plans, track allocation, cost data |
```

---

### 2. Budget Forecasting as Explicit Output
**Location:** System Outputs table (line ~59)
**Change:** Add row after "Cost Compliance"

```markdown
| **Budget Forecast**      | Projected maintenance costs per fleet over planning horizon        | Web UI, Export |
```

---

### 3. Clarify Simulation Reports
**Location:** System Outputs table (line ~60)
**Change:** Replace current Simulation Reports row

```markdown
| **Simulation Reports**   | Scenario comparison: cost impact, compliance risk, fleet wear distribution | PDF, Excel     |
```

---

### 4. Reduce EAM Prominence
**Location:** Multiple sections
**Changes:**
- Glossary (line 26): Keep as-is (informational)
- Architecture diagram (line 146-147): Change label to `(Integration)`
- Delivery Phases (line 124): Reword to `EAM integration capability, financial modeling`
- For AI Agents (line 176-177): Move under new `### Optional Integrations` subsection

---

### 5. Define Train Fitness in Glossary
**Location:** Glossary table (line 23)
**Change:** Expand definition

```markdown
| **Train Fitness**     | Binary operational readiness (fit/unfit) determined by external source (EAM/manual). Unfit trains excluded from run assignments | State       |
```

---

### 6. Define Maintenance Profile in Glossary
**Location:** Glossary table (after Fleet, line 21)
**Change:** Add row

```markdown
| **Maintenance Profile** | Set of PM intervals, overhaul schedules, and resource requirements specific to a fleet type | Entity      |
```

---

### 7. Enhance AI Agents Section
**Location:** For AI Agents section (lines 152-195)
**Changes:**

#### 7a. Add Optimization Objective (after "System purpose")
```markdown
**Optimization objective:** Minimize mileage variance across fleet while respecting maintenance windows and resource constraints.
```

#### 7b. Add Configurable Thresholds (after Fixed Parameters)
```markdown
### Configurable Thresholds
| Parameter | Default | Description |
|-----------|---------|-------------|
| `mileage_underrun_pct` | -10% | Trigger warning below target |
| `mileage_overrun_pct` | +10% | Trigger warning above target |
| `planning_horizon_years` | 10 | Long-term planning window |
```

#### 7c. Add Constraint Priority (after Business Rules)
```markdown
### Constraint Priority (highest to lowest)
1. **Train Fitness** - Unfit trains never assigned
2. **Maintenance Windows** - Scheduled maintenance blocks availability
3. **Resource Limits** - Man-hours, track slots per depot
4. **Mileage Balance** - Optimize within above constraints
```

---

## Files to Modify
- `README.md` - All 7 corrections

## Execution Order
1. Glossary updates (#5, #6) - foundational definitions
2. System Outputs (#2, #3) - explicit outputs
3. EAM reduction (#4) - structural change
4. User Roles (#1) - new section
5. AI Agents enhancements (#7a, #7b, #7c) - final polish

---

## Validation
After edits, verify:
- [ ] No broken markdown tables
- [ ] Glossary terms used consistently
- [ ] AI Agents section sufficient for autonomous decision-making
