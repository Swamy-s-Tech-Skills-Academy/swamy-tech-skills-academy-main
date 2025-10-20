# 05B_Day01_Craft_Diagnostic

**Learning Level**: Advanced  
**Prerequisites**: Week 05 overview, engineering scorecards, incident reports, peer feedback surveys  
**Estimated Time**: 2 × 27-minute loops

## 🎯 Objectives for Today

- Conduct a rigorous skill diagnostic across code quality, testing, reliability, and observability.
- Prioritize craft gaps using data-backed evidence and stakeholder input.

## ⏱️ Loop Map

| Loop | Focus | Output |
| --- | --- | --- |
| 01 | Skill diagnostic | Craft gap matrix |
| 02 | Prioritization | Priority heatmap |

## 🔎 Loop 01 – Skill Diagnostic

**Target Output**: Craft gap matrix listing current proficiency vs. desired state.

### Step-by-step (Loop 01)

1. Aggregate data: code review comments, defect leakage metrics, test coverage, mean time to restore, observability adoption.
2. Interview tech leads to capture qualitative insights on skill gaps (pair programming, debugging, narrative clarity).
3. Rate each skill area on **Current Proficiency**, **Business Impact**, and **Urgency** (scale 1–5).
4. Document root causes (knowledge gap, process issue, tool limitation).

### Craft Gap Matrix

| Skill | Current | Target | Gap | Impact | Urgency | Root Cause |
| --- | --- | --- | --- | --- | --- | --- |

### ASCII Summary

```text
Skill: Automated Testing
Current: 2/5
Target: 4/5
Impact: High (defect leakage)
Urgency: High
Root Cause: Insufficient lab practice + flaky tests
```text
## 🔥 Loop 02 – Prioritization

**Target Output**: Priority heatmap focusing Week 05 labs on the highest leverage skills.

### Step-by-step (Loop 02)

1. Plot skills using an **Impact vs. Urgency** grid to identify must-tackle areas.
2. Validate priorities with architecture, engineering management, and product leaders.
3. Select top 4–5 skills for lab development.
4. Note dependencies on toolchain or heuristics from previous clusters.

### Priority Heatmap

| Impact \ Urgency | Low | Medium | High |
| --- | --- | --- | --- |
| High |  |  | ⭐️ Focus Area |
| Medium |  |  |  |
| Low |  |  |  |

### Checklist

- [ ] Data sources corroborate qualitative feedback.
- [ ] Top skills cover multiple personas (backend, frontend, SRE).
- [ ] Dependencies captured for lab design.

## ✅ Exit Criteria for Day 1

- Craft gap matrix completed with data-backed ratings.
- Priority heatmap zeroing in on 4–5 skills.
- Alignment from key stakeholders on focus areas for lab creation.

## 🛠️ Tools & Resources

- Analytics platforms (SonarQube, Code Climate, LaunchDarkly metrics).
- Incident postmortems and retrospectives.
- Team health surveys or engagement tools.

## 🔄 Handoff to Day 2

- Convert prioritized skills into lab design objectives tomorrow.
- Gather example codebases or systems where gaps manifest most clearly.
- Flag toolchain enablers required for lab execution (scripts, datasets).
