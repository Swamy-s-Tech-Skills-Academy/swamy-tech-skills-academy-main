# C# Coding Guidelines

## Introduction

> The C# Coding Guidelines serve as a comprehensive set of best practices to ensure consistency, readability, and maintainability across the codebase. By following these guidelines, we can improve code quality, reduce potential errors, and make the application easier to understand and maintain over time. Adopting these practices ensures that the codebase is efficient, scalable, and aligns with industry standards, while also fostering collaboration among developers. These guidelines cover a wide range of topics including naming conventions, design patterns, performance optimizations, and more, providing a solid foundation for writing clean, maintainable, and efficient C# code.

## 1. Avoid Unnecessary Use of Discard Pattern (\_ =)

**Purpose:** This guideline aims to enhance code readability and maintainability by minimizing unnecessary use of the discard pattern (\_ =). It helps developers focus on code that directly contributes to application logic while avoiding superfluous constructs.

### 1.1. Guideline

When calling methods whose return values are not needed, avoid using the discard pattern (\_ =) unless explicitly necessary. This improves the code's readability by reducing unnecessary elements.

### 1.2. Rationale

The discard pattern (\_ =) is typically used to explicitly ignore return values that you don't need. In cases where a method's return value is inconsequential and ignoring it is obvious, the discard can make the code unnecessarily complex.

### 1.3. Category

> Code Readability and Maintainability

### 1.4. Sub-Category

> Clarity

### 1.5. Examples

❌ Incorrect:

_ = app.UseHttpsRedirection();
_ = app.MapControllers();
app.Run();
Here, the discard (\_ =) is unnecessary as the methods UseHttpsRedirection() and MapControllers() return values that aren't intended to be used.

✔ Correct:

app.UseHttpsRedirection();
app.MapControllers();
app.Run();
Removing the discard pattern simplifies the code, making it easier to read without losing any functionality.

### 1.6. When to Use

Only use the discard pattern when you need to explicitly communicate that you're intentionally ignoring the result of a method, and the code's clarity benefits from the inclusion of \_ =.

Avoid using it when it's clear that the result of a method is not meant to be captured.
