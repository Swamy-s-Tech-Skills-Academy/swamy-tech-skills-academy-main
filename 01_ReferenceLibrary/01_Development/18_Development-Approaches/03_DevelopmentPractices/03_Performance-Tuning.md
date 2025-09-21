# Performance Tuning — High-impact Techniques (STSA)

**Learning Level:** Practitioner
**Prerequisites:** Basic profiling tool familiarity (dotnet-trace, perf, or similar)
**Estimated Time:** 27 minutes

## Quick Overview

This module teaches identifying hotspots, measuring impact, and applying targeted fixes with minimal risk.

## Objectives

- Use simple profiling to find CPU/alloc hotspots.
- Apply low-risk optimizations (algorithms, caching, batching).
- Validate improvements with benchmarks and metrics.

## Core steps

1. Reproduce the slow scenario with a repeatable test or benchmark.
2. Capture a lightweight trace (CPU + allocations) in a representative run.
3. Identify top methods by sample count or allocation size.
4. Make the smallest change that addresses the hotspot (e.g., avoid repeated allocations, change algorithm).
5. Measure again and confirm improvement; add a regression test or benchmark.

## Small example (pseudocode demonstrating batching)

```csharp
// Inefficient: many small DB calls in a loop
foreach(var id in ids)
{
  var item = db.Load(id);
  Process(item);
}

// Improved: batch the query
var items = db.LoadMany(ids);
foreach(var item in items)
  Process(item);
```

## Quick checklist

- Is the fix measured (before/after)?
- Is complexity acceptable for maintenance?
- Are allocation hotspots reduced?

---

Helpful resources: prefer using lightweight in-app benchmarks and capture traces in a staging environment before promoting fixes to production.
