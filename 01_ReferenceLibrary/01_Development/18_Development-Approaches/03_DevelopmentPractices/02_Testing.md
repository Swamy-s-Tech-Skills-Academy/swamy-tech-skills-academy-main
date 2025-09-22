# Testing Fundamentals — Practical Exercises (STSA)

**Learning Level:** Practitioner
**Prerequisites:** Basic unit testing framework familiarity (e.g., xUnit, NUnit)
**Estimated Time:** 27 minutes

## Quick Overview

This module focuses on writing meaningful unit tests, layering tests (unit, integration), and producing small examples that teach good habits.

## Objectives

- Write clear, fast unit tests.
- Use table-driven tests for multiple cases.
- Create integration tests for critical flows.

## Core patterns

- Arrange/Act/Assert structure.
- Single assertion per behavior when practical.
- Use test doubles (mocks/fakes) for external dependencies.

## Short original example (xUnit)

```csharp
[Fact]
public void Add_ReturnsSum_WhenInputsAreValid()
{
  // Arrange
  var calc = new Calculator();

  // Act
  var result = calc.Add(2, 3);

  // Assert
  Assert.Equal(5, result);
}
```

## Test organization

- Keep tests in a parallel folder (e.g., `src/MyLib.Tests`).
- Group by feature and name tests clearly: `MethodName_StateUnderTest_ExpectedBehavior`.

## Quick checklist for reviewers

1. Tests exist for new behavior.
2. Tests are deterministic and fast.
3. Edge cases covered (nulls, empty, overflow where relevant).
