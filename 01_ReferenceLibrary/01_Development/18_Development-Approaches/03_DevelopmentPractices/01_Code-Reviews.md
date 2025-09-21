# Code Reviews — Practical Guide (STSA)

**Learning Level:** Practitioner
**Prerequisites:** Basic C# or language knowledge, Git fundamentals
**Estimated Time:** 27 minutes

## Quick Overview

Code reviews improve quality, spread knowledge, and catch defects early. This concise module provides a practical checklist, short comment templates, and a minimal workflow you can adopt immediately.

## Learning Objectives

- Run focused code reviews that prioritize correctness, readability, and maintainability.
- Provide concise, actionable feedback that authors can act on quickly.
- Use a small, repeatable review checklist across PRs.

## Review Checklist (prioritized)

1. Build & tests: Does the change compile and do tests pass?
2. Intent: Is the PR title and summary clear about problem & approach?
3. Scope: Is the change small and focused on a single behavior or bug?
4. Correctness: Does the implementation match the described behavior?
5. Readability & naming: Can a maintainer understand intent from names?
6. Edge cases: Are nulls, empty/invalid inputs, and boundaries handled?
7. Tests: Are there meaningful unit tests for key behaviors?
8. Performance & allocations: Any obvious algorithmic or allocation concerns?
9. Security & secrets: No secrets or insecure defaults checked in.

## Short review comment templates

- Suggestion: "Rename `GetData()` → `FetchUserProfile()` to clarify returned data."
- Bug with repro: "With empty input X this throws NRE — add guard `if (string.IsNullOrEmpty(x))` and a unit test."
- Nit (non-blocking): "Prefer expression-bodied property for single-line getter."

## Minimal review workflow

1. Run automated checks (build, unit tests, lint).
2. Reviewer reads PR summary and verifies checklist items 1–4.
3. Leave 1–3 focused comments with suggested fixes.
4. Author applies a small follow-up commit; reviewer verifies and merges.

## Small original example (C#)

```csharp
// Before (unclear intent)
public string GetData(int id) { return repo.Find(id)?.Name; }

// After (clear intent + null-safety)
public string? FetchUserName(int userId)
{
  var user = _userRepo.Find(userId);
  return user?.Name;
}
```

## Key takeaways

- Keep comments short and prescriptive (point + suggested change).
- Focus reviewer effort on correctness, tests, and design rather than formatting.

---

If you want, I can add a small `PULL_REQUEST_TEMPLATE.md` that includes this checklist so every PR has a starting point.
