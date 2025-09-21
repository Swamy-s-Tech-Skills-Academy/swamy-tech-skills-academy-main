# Code Reviews — Practical Guide (STSA)

**Learning Level:** Practitioner
**Prerequisites:** Basic C# or language knowledge, Git fundamentals
**Estimated Time:** 27 minutes (self-contained module)

## Quick Overview

Code reviews improve quality, spread knowledge, and catch defects early. This short module teaches a pragmatic, original checklist, hands-on examples, and a lightweight review workflow.

## Learning Objectives

- Run focused code reviews that balance correctness, readability, and maintainability.
- Provide concise, actionable review feedback.
- Use simple review templates that scale across teams.

## Review Checklist (Practical, prioritized)

1. Build & tests: Does the change compile and do tests pass?
2. Intent: Is the PR title and summary clear about the problem and solution?
3. Scope: Is the change small and focused (single behavior/bug)?
4. Correctness: Does the implementation correctly follow the described behavior?
5. Readability: Can a maintainer understand the code without running it?
6. Naming: Are variables, methods, and classes named to reveal intent?
7. Edge cases: Are nulls, empty inputs, and boundary cases covered?
8. Tests: Are there meaningful unit tests for important behaviors?
9. Performance & allocations: Any obvious O(N^2) or heavy allocations introduced?
10. Security & secrets: No secrets or insecure defaults checked in.

## Example review comment templates

1. Concise improvement suggestion:

   - "Suggest renaming `GetData()` to `FetchUserProfile()` — clarifies what data is returned."

2. Correctness with reproduction:

   - "When input X is empty this throws NRE — add guard `if (string.IsNullOrEmpty(x))` and add test."

3. Small nit (non-blocking):

   - "Nit: prefer expression-bodied property for simple getter."

## Lightweight workflow

1. Run automated checks (build + unit tests + linting).
2. Reviewer scans PR description and checks points 1–4 in the checklist above.
3. Add 1–3 review comments with clear suggested changes.
4. Author responds and pushes a focused follow-up commit.

## Example (small original snippet)

```csharp
// Before (unclear intent)
public string GetData(int id) { return repo.Find(id)?.Name; }

// After (clearer intent and null-safety)
public string? FetchUserName(int userId)
{
  var user = _userRepo.Find(userId);
  return user?.Name;
}
```

## Key takeaways

- Keep reviews focused on high-value problems (correctness, design, tests).
- Use short, specific comments; suggest fixes rather than only pointing out problems.

---

*If you'd like, I can generate a small PR template file to include this checklist automatically.*

# Code Reviews — Practical Guide (STSA)

**Learning Level:** Practitioner
**Prerequisites:** Basic C# or language knowledge, Git fundamentals
**Estimated Time:** 27 minutes (self-contained module)

## Quick Overview

Code reviews improve quality, spread knowledge, and catch defects early. This short module teaches a pragmatic, original checklist, hands-on examples, and a lightweight review workflow.

## Learning Objectives

- Run focused code reviews that balance correctness, readability, and maintainability.
- Provide concise, actionable review feedback.
- Use simple review templates that scale across teams.

## Review Checklist (Practical, prioritized)

1. Build & tests: Does the change compile and do tests pass?
2. Intent: Is the PR title and summary clear about the problem and solution?
3. Scope: Is the change small and focused (single behavior/bug)?
4. Correctness: Does the implementation correctly follow the described behavior?
5. Readability: Can a maintainer understand the code without running it?
6. Naming: Are variables, methods, and classes named to reveal intent?
7. Edge cases: Are nulls, empty inputs, and boundary cases covered?
8. Tests: Are there meaningful unit tests for important behaviors?
9. Performance & allocations: Any obvious O(N^2) or heavy allocations introduced?
10. Security & secrets: No secrets or insecure defaults checked in.

## Example review comment templates

1. Concise improvement suggestion:

   - "Suggest renaming `GetData()` to `FetchUserProfile()` — clarifies what data is returned."

2. Correctness with reproduction:

   - "When input X is empty this throws NRE — add guard `if (string.IsNullOrEmpty(x))` and add test."

3. Small nit (non-blocking):

   - "Nit: prefer expression-bodied property for simple getter."

## Lightweight workflow

1. Run automated checks (build + unit tests + linting).
2. Reviewer scans PR description and checks points 1–4 in the checklist above.
3. Add 1–3 review comments with clear suggested changes.
4. Author responds and pushes a focused follow-up commit.

## Example (small original snippet)

```csharp
// Before (unclear intent)
public string GetData(int id) { return repo.Find(id)?.Name; }

// After (clearer intent and null-safety)
public string? FetchUserName(int userId)
{
  var user = _userRepo.Find(userId);
  return user?.Name;
}
```

## Key takeaways

- Keep reviews focused on high-value problems (correctness, design, tests).
- Use short, specific comments; suggest fixes rather than only pointing out problems.

---

*If you'd like, I can generate a small PR template file to include this checklist automatically.*

# Code Reviews — Practical Guide (STSA)

**Learning Level:** Practitioner
**Prerequisites:** Basic C# or language knowledge, Git fundamentals
**Estimated Time:** 27 minutes (self-contained module)

## Quick Overview

Code reviews improve quality, spread knowledge, and catch defects early. This short module teaches a pragmatic, original checklist, hands-on examples, and a lightweight review workflow.

## Learning Objectives

- Run focused code reviews that balance correctness, readability, and maintainability.
- Provide concise, actionable review feedback.
- Use simple review templates that scale across teams.

## Review Checklist (Practical, prioritized)

1. Build & tests: Does the change compile and do tests pass?
2. Intent: Is the PR title and summary clear about the problem and solution?
3. Scope: Is the change small and focused (single behavior/bug)?
4. Correctness: Does the implementation correctly follow the described behavior?
5. Readability: Can a maintainer understand the code without running it?
6. Naming: Are variables, methods, and classes named to reveal intent?
7. Edge cases: Are nulls, empty inputs, and boundary cases covered?
8. Tests: Are there meaningful unit tests for important behaviors?
9. Performance & allocations: Any obvious O(N^2) or heavy allocations introduced?
10. Security & secrets: No secrets or insecure defaults checked in.

## Example review comment templates

1. Concise improvement suggestion:

   - "Suggest renaming `GetData()` to `FetchUserProfile()` — clarifies what data is returned."

2. Correctness with reproduction:

   - "When input X is empty this throws NRE — add guard `if (string.IsNullOrEmpty(x))` and add test."

3. Small nit (non-blocking):

   - "Nit: prefer expression-bodied property for simple getter."

## Lightweight workflow

- Run automated checks (build + unit tests + linting).
- Reviewer scans PR description and checks point 1–4 in the checklist above.
- Add 1–3 review comments with clear suggested changes.
- Author responds and pushes a focused follow-up commit.

## Example (small original snippet)

```csharp
// Before (unclear intent)
public string GetData(int id) { return repo.Find(id)?.Name; }

// After (clearer intent and null-safety)
public string? FetchUserName(int userId)
{
  var user = _userRepo.Find(userId);
  return user?.Name;
}
```

## Key takeaways

- Keep reviews focused on high-value problems (correctness, design, tests).
- Use short, specific comments; suggest fixes rather than only pointing out problems.

---

*If you'd like, I can generate a small PR template file to include this checklist automatically.*

# Code Reviews — Practical Guide (STSA)

**Learning Level:** Practitioner
**Prerequisites:** Basic C# or language knowledge, Git fundamentals
**Estimated Time:** 27 minutes (self-contained module)

## Quick Overview

Code reviews improve quality, spread knowledge, and catch defects early. This short module teaches a pragmatic, original checklist, hands-on examples, and a lightweight review workflow.

## Learning Objectives

- Run focused code reviews that balance correctness, readability, and maintainability.
- Provide concise, actionable review feedback.
- Use simple review templates that scale across teams.

## Review Checklist (Practical, prioritized)

1. Build & tests: Does the change compile and do tests pass?
2. Intent: Is the PR title and summary clear about the problem and solution?
3. Scope: Is the change small and focused (single behavior/bug)?
4. Correctness: Does the implementation correctly follow the described behavior?
5. Readability: Can a maintainer understand the code without running it?
6. Naming: Are variables, methods, and classes named to reveal intent?
7. Edge cases: Are nulls, empty inputs, and boundary cases covered?
8. Tests: Are there meaningful unit tests for important behaviors?
9. Performance & allocations: Any obvious O(N^2) or heavy allocations introduced?
10. Security & secrets: No secrets or insecure defaults checked in.

## Example review comment templates

1. Concise improvement suggestion:
   - "Suggest renaming `GetData()` to `FetchUserProfile()` — clarifies what data is returned."

2. Correctness with reproduction:
   - "When input X is empty this throws NRE — add guard `if (string.IsNullOrEmpty(x))` and add test."

# Code Reviews — Practical Guide (STSA)

**Learning Level:** Practitioner
**Prerequisites:** Basic C# or language knowledge, Git fundamentals
**Estimated Time:** 27 minutes (self-contained module)

## Quick Overview

Code reviews improve quality, spread knowledge, and catch defects early. This short module teaches a pragmatic, original checklist, hands-on examples, and a lightweight review workflow.

## Learning Objectives

- Run focused code reviews that balance correctness, readability, and maintainability.
- Provide concise, actionable review feedback.
- Use simple review templates that scale across teams.

## Review Checklist (Practical, prioritized)

1. Build & tests: Does the change compile and do tests pass?
2. Intent: Is the PR title and summary clear about the problem and solution?
3. Scope: Is the change small and focused (single behavior/bug)?
4. Correctness: Does the implementation correctly follow the described behavior?
5. Readability: Can a maintainer understand the code without running it?
6. Naming: Are variables, methods, and classes named to reveal intent?
7. Edge cases: Are nulls, empty inputs, and boundary cases covered?
8. Tests: Are there meaningful unit tests for important behaviors?
9. Performance & allocations: Any obvious O(N^2) or heavy allocations introduced?
10. Security & secrets: No secrets or insecure defaults checked in.

## Example review comment templates

1. Concise improvement suggestion:
   - "Suggest renaming `GetData()` to `FetchUserProfile()` — clarifies what data is returned."

2. Correctness with reproduction:
   - "When input X is empty this throws NRE — add guard `if (string.IsNullOrEmpty(x))` and add test."

3. Small nit (non-blocking):
   - "Nit: prefer expression-bodied property for simple getter."

## Lightweight workflow

- Run automated checks (build + unit tests + linting).
- Reviewer scans PR description and checks point 1–4 in the checklist above.
- Add 1–3 review comments with clear suggested changes.
- Author responds and pushes a focused follow-up commit.

## Example (small original snippet)

```csharp
// Before (unclear intent)
public string GetData(int id) { return repo.Find(id)?.Name; }

// After (clearer intent and null-safety)
public string? FetchUserName(int userId)
{
  var user = _userRepo.Find(userId);
  return user?.Name;
}
```

## Key takeaways

- Keep reviews focused on high-value problems (correctness, design, tests).
- Use short, specific comments; suggest fixes rather than only pointing out problems.

---

*If you'd like, I can generate a small PR template file to include this checklist automatically.*

- Author responds and pushes a focused follow-up commit.

## Example (small original snippet)

```csharp
// Before (unclear intent)
public string GetData(int id) { return repo.Find(id)?.Name; }

// After (clearer intent and null-safety)
public string? FetchUserName(int userId)
{
  var user = _userRepo.Find(userId);
  return user?.Name;
}
```

## Key takeaways

- Keep reviews focused on high-value problems (correctness, design, tests).
- Use short, specific comments; suggest fixes rather than only pointing out problems.

---

*If you'd like, I can generate a small PR template file to include this checklist automatically.*
