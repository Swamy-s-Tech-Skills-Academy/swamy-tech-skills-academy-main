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

## 2. Overview of Dependency Injection (DI) Lifetimes in ASP.NET Core

**Purpose:** This guideline outlines the three primary lifetimes of services in ASP.NET Core’s Dependency Injection (DI) system: `Transient`, `Scoped`, and `Singleton`. Understanding when to use each can improve the efficiency, scalability, and performance of your application by appropriately managing service lifetimes.

---

### **2.1. Transient**

#### 2.1.1 Guideline

`Transient` services are created every time they are requested. Each injection provides a new instance, which makes them suitable for stateless services that do not need to retain data across requests.

#### 2.1.2 Rationale

Transient services are ideal for lightweight operations that can be frequently recreated without significant overhead. This ensures each consumer gets an independent instance, preventing unintentional sharing of state or data.

#### 2.1.3 Category

> Service Lifetime Management

#### 2.1.4 Sub-Category

> Stateless Services

#### 2.1.5 Example

- **Use Case**: Utility services that perform operations like calculations or string manipulations, where each instance is independent.

  ```csharp
  services.AddTransient<IUtilityService, UtilityService>();
  ```

#### 2.1.6 When to Use

- Use `Transient` for stateless operations that do not require sharing of data between different requests or instances.
- Avoid `Transient` for resource-heavy or state-aware services, as frequent re-instantiation can impact performance.

---

### **2.2. Scoped**

#### 2.2.1 Guideline

`Scoped` services are created once per request or scope. A single instance is shared across components within the same request, but the service is reset for each new request.

#### 2.2.2 Rationale

Scoped services are useful when a service needs to maintain state across a single request but not across multiple requests. This is especially helpful for services that interact with request-specific data, like database contexts.

#### 2.2.3 Category

> Service Lifetime Management

#### 2.2.4 Sub-Category

> Stateful Services

#### 2.2.5 Example

- **Use Case**: Entity Framework Core's `DbContext` is typically registered as `Scoped` because it should maintain consistency within a request but be disposed at the end.

  ```csharp
  services.AddScoped<IRepository, Repository>();
  ```

#### 2.2.6 When to Use

- Use `Scoped` for services that need to persist data or state within a single request (e.g., working with databases).
- Avoid `Scoped` for services that need to maintain state across multiple requests or application-wide operations.

---

### **2.3. Singleton**

#### 2.3.1 Guideline

`Singleton` services are created once and shared throughout the application's lifetime. A single instance is reused across all requests and consumers.

#### 2.3.2 Rationale

Singleton services are suitable for services that are expensive to initialize or hold shared state that needs to be consistent across the entire application (e.g., caching, configuration, or logging). They are long-lived and should be thread-safe if accessed concurrently.

#### 2.3.3 Category

> Service Lifetime Management

#### 2.3.4 Sub-Category

> Global Resources

#### 2.3.5 Example

- **Use Case**: Logger services or caching mechanisms that need to be shared across the entire application.

  ```csharp
  services.AddSingleton<ILogger, LoggerService>();
  ```

#### 2.3.6 When to Use

- Use `Singleton` for services that are expensive to create or hold state that must persist across the application lifecycle.
- Avoid `Singleton` for services that depend on request-specific data or that cannot safely handle concurrent access without proper synchronization.

### Guidelines for Using File-Scoped Namespaces in C#

**Purpose:**  
This guideline outlines best practices for using file-scoped namespaces in C#. The file-scoped namespace feature introduced in C# 10 simplifies namespace declarations, leading to cleaner and more concise code.

---

### **1.1. File-Scoped Namespace Declaration**

#### 1.1.1 Guideline

Use file-scoped namespaces to reduce indentation and enhance code readability when a single namespace is used throughout the file. This replaces the block-scoped (`{}`) approach, resulting in cleaner, less-indented code.

#### 1.1.2 Rationale

By eliminating the need for braces around namespaces, file-scoped namespaces reduce unnecessary indentation, making the code more readable and easier to maintain. It aligns with modern C# language features that emphasize simplicity and clarity.

#### 1.1.3 Category

**Code Readability and Maintainability**

#### 1.1.4 Sub-Category

**Syntax Simplification**

#### 1.1.5 Example

- **Use Case**: A single file with a single namespace, typically in smaller or more modular classes.

  ```csharp
  // File-scoped namespace
  namespace MyApp.Models;

  public class Product
  {
      public int Id { get; set; }
      public string Name { get; set; }
  }
  ```

  Compared to the block-scoped version:

  ```csharp
  namespace MyApp.Models
  {
      public class Product
      {
          public int Id { get; set; }
          public string Name { get; set; }
      }
  }
  ```

#### 1.1.6 When to Use

- Use file-scoped namespaces when a file contains a single namespace and additional indentation would not add clarity to the structure.
- Prefer file-scoped namespaces in smaller files or when adhering to modern C# conventions.

---

### **1.2. Reducing Indentation in Large Codebases**

#### 1.2.1 Guideline

In large codebases with deep nesting levels or long namespace declarations, file-scoped namespaces can help reduce indentation and improve overall readability.

#### 1.2.2 Rationale

Nested namespaces or long names can increase indentation depth unnecessarily. Using file-scoped namespaces flattens the code structure, allowing developers to focus on the core functionality rather than navigating through layers of indentation.

#### 1.2.3 Category

**Code Readability**

#### 1.2.4 Sub-Category

**Indentation Reduction**

#### 1.2.5 Example

- **Use Case**: A large project with deeply nested namespaces.

  ```csharp
  // Instead of:
  namespace MyApp.Infrastructure.Data.Repositories
  {
      public class UserRepository { ... }
  }
  ```

  Use file-scoped for a cleaner, more concise approach:

  ```csharp
  namespace MyApp.Infrastructure.Data.Repositories;

  public class UserRepository { ... }
  ```

#### 1.2.6 When to Use

- Use file-scoped namespaces in large or deeply nested projects where reducing the indentation improves readability.
- Avoid using file-scoped namespaces in files with multiple namespaces, as block-scoped namespaces provide better visual clarity in such cases.

---

### **1.3. Compatibility and Consistency Across Files**

#### 1.3.1 Guideline

Ensure consistency across the project by using either file-scoped or block-scoped namespaces, but avoid mixing both styles within the same project or solution unless required for legacy reasons.

#### 1.3.2 Rationale

Maintaining consistency in the use of file-scoped or block-scoped namespaces across files within the same project improves readability and ensures a uniform coding style. This minimizes confusion for other developers and enhances maintainability.

#### 1.3.3 Category

**Code Consistency**

#### 1.3.4 Sub-Category

**Coding Standards**

#### 1.3.5 Example

- **Inconsistent**:

  ```csharp
  // File 1 (uses block-scoped namespace)
  namespace MyApp.Services
  {
      public class EmailService { ... }
  }

  // File 2 (uses file-scoped namespace)
  namespace MyApp.Data;

  public class DatabaseContext { ... }
  ```

- **Consistent**:

  ```csharp
  // Both files use file-scoped namespaces
  namespace MyApp.Services;

  public class EmailService { ... }

  namespace MyApp.Data;

  public class DatabaseContext { ... }
  ```

#### 1.3.6 When to Use

- Use file-scoped namespaces consistently across all files in new projects.
- If working on legacy projects or where the style has already been set, prefer consistency over forcing new syntax unless refactoring the entire project is justified.

---

### **1.4. Avoid Using File-Scoped Namespaces with Multiple Namespaces in a File**

#### 1.4.1 Guideline

Avoid using file-scoped namespaces in files that contain multiple namespaces, as this can create ambiguity and reduce clarity.

#### 1.4.2 Rationale

Block-scoped namespaces are more suitable when multiple namespaces are used within a single file, as it clearly separates the logical areas of the code.

#### 1.4.3 Category

**Code Clarity**

#### 1.4.4 Sub-Category

**Namespace Management**

#### 1.4.5 Example

- **Incorrect (file-scoped with multiple namespaces)**:

  ```csharp
  namespace MyApp.Models;
  namespace MyApp.Services;

  public class MyService { ... }
  ```

- **Correct (block-scoped with multiple namespaces)**:

  ```csharp
  namespace MyApp.Models
  {
      public class MyModel { ... }
  }

  namespace MyApp.Services
  {
      public class MyService { ... }
  }
  ```

#### 1.4.6 When to Use

- Use block-scoped namespaces when a file contains multiple namespaces to enhance clarity and separation of concerns.

---

### **1.5. General Guidelines**

- **File-Scoped**: Use for simplicity and reduced indentation, particularly in smaller files or files with a single namespace.
- **Block-Scoped**: Retain for files with multiple namespaces or where legacy code consistency is important.
- **Consistency**: Ensure the same style is applied across the entire project to maintain readability and coding standards.

By following these guidelines, developers can make better use of file-scoped namespaces in C# to improve code readability, maintainability, and consistency across projects.
