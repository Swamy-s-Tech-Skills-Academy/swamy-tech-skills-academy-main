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

---

## 2. Overview of Dependency Injection (DI) Lifetimes in ASP.NET Core

**Purpose:** This guideline outlines the three primary lifetimes of services in ASP.NET Core’s Dependency Injection (DI) system: `Transient`, `Scoped`, and `Singleton`. Understanding when to use each can improve the efficiency, scalability, and performance of your application by appropriately managing service lifetimes.

### 2.1. Transient

#### 2.1.1. Guideline

`Transient` services are created every time they are requested. Each injection provides a new instance, which makes them suitable for stateless services that do not need to retain data across requests.

#### 2.1.2. Rationale

Transient services are ideal for lightweight operations that can be frequently recreated without significant overhead. This ensures each consumer gets an independent instance, preventing unintentional sharing of state or data.

#### 2.1.3. Category

> Service Lifetime Management

#### 2.1.4. Sub-Category

> Stateless Services

#### 2.1.5. Example

- **Use Case**: Utility services that perform operations like calculations or string manipulations, where each instance is independent.

  ```csharp
  services.AddTransient<IUtilityService, UtilityService>();
  ```

#### 2.1.6. When to Use

- Use `Transient` for stateless operations that do not require sharing of data between different requests or instances.
- Avoid `Transient` for resource-heavy or state-aware services, as frequent re-instantiation can impact performance.

---

### 2.2. Scoped

#### 2.2.1. Guideline

`Scoped` services are created once per request or scope. A single instance is shared across components within the same request, but the service is reset for each new request.

#### 2.2.2. Rationale

Scoped services are useful when a service needs to maintain state across a single request but not across multiple requests. This is especially helpful for services that interact with request-specific data, like database contexts.

#### 2.2.3. Category

> Service Lifetime Management

#### 2.2.4. Sub-Category

> Stateful Services

#### 2.2.5. Example

- **Use Case**: Entity Framework Core's `DbContext` is typically registered as `Scoped` because it should maintain consistency within a request but be disposed at the end.

  ```csharp
  services.AddScoped<IRepository, Repository>();
  ```

#### 2.2.6. When to Use

- Use `Scoped` for services that need to persist data or state within a single request (e.g., working with databases).
- Avoid `Scoped` for services that need to maintain state across multiple requests or application-wide operations.

---

### 2.3. Singleton

#### 2.3.1. Guideline

`Singleton` services are created once and shared throughout the application's lifetime. A single instance is reused across all requests and consumers.

#### 2.3.2. Rationale

Singleton services are suitable for services that are expensive to initialize or hold shared state that needs to be consistent across the entire application (e.g., caching, configuration, or logging). They are long-lived and should be thread-safe if accessed concurrently.

#### 2.3.3. Category

> Service Lifetime Management

#### 2.3.4. Sub-Category

> Global Resources

#### 2.3.5. Example

- **Use Case**: Logger services or caching mechanisms that need to be shared across the entire application.

  ```csharp
  services.AddSingleton<ILogger, LoggerService>();
  ```

#### 2.3.6. When to Use

- Use `Singleton` for services that are expensive to create or hold state that must persist across the application lifecycle.
- Avoid `Singleton` for services that depend on request-specific data or that cannot safely handle concurrent access without proper synchronization.

---

## 3. Guidelines for Using File-Scoped Namespaces in `C#`

**Purpose:**  
This guideline outlines best practices for using file-scoped namespaces in C#. The file-scoped namespace feature introduced in C# 10 simplifies namespace declarations, leading to cleaner and more concise code.

### 3.1. Guideline

Use file-scoped namespaces to reduce indentation and enhance code readability when a single namespace is used throughout the file. This replaces the block-scoped (`{}`) approach, resulting in cleaner, less-indented code.

### 3.2. Rationale

By eliminating the need for braces around namespaces, file-scoped namespaces reduce unnecessary indentation, making the code more readable and easier to maintain. It aligns with modern C# language features that emphasize simplicity and clarity.

### 3.3. Category

> Code Readability and Maintainability

### 3.4. Sub-Category

> Syntax Simplification

### 3.5. Example

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

### 3.6. When to Use

- Use file-scoped namespaces when a file contains a single namespace and additional indentation would not add clarity to the structure.
- Prefer file-scoped namespaces in smaller files or when adhering to modern C# conventions.

---

## 4. Using Dependency Injection in Primary Constructors

**Purpose:**

To ensure proper use of Dependency Injection (DI) in ASP.NET Core controllers by utilizing the primary constructor pattern. This guideline helps prevent common mistakes, such as the incorrect use of the in keyword, ensuring seamless integration with ASP.NET Core's DI system.

### 4.1. Guideline

When injecting dependencies like `ILogger<T>` into a controller's primary constructor, avoid using the in keyword for parameters. This will ensure that ASP.NET Core's Dependency Injection functions properly and avoids runtime errors related to ByRef types. The in keyword should only be used for performance optimization when passing a large value type by reference, enforcing read-only behavior, which is ideal for immutable value types but not suitable for reference types.

- **Use `in` for Large Value Types:** Employ the `in` keyword to pass large value types (e.g., structs) by reference, optimizing for performance where necessary.
- **Avoid `in` for Reference Types:** Do not use the `in` keyword for reference types (e.g., classes or interfaces) as they are already passed by reference. Applying `in` can lead to runtime errors.
- **Consistency in ASP.NET Core Applications:** Stick to conventional parameter passing (without `in`) for dependency injection in ASP.NET Core, especially for services like `ILogger<T>`.

### 4.2. Rationale

The `in` keyword is used primarily to pass value types by reference, preventing modification and avoiding copying overhead. However, for reference types such as `ILogger<T>`, using `in` is unnecessary since they are already passed by reference. Moreover, it can lead to runtime exceptions, as ASP.NET Core’s DI system does not support handling `ByRef` types in this context. Using `in` for value types allows the runtime to avoid copying the entire value, which can be expensive for large structs. However, reference types are already passed by reference. Applying the `in` keyword to reference types is unnecessary and can lead to runtime issues, making the code more error-prone.

### 4.3. Category

> Dependency Injection

### 4.4. Sub-Category

> Constructor Injection

### 4.5. Examples:\*\*

❌ **Incorrect:**

```csharp
public class TestController(in ILogger<TestController> logger) : Controller
{
    private readonly ILogger<TestController> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    public IActionResult Index()
    {
        _logger.LogInformation("Test page visited at {time}", DateTime.Now);
        return View();
    }
}
```

In this example, using the `in` keyword will result in runtime errors due to ASP.NET Core’s inability to handle `ByRef` types through Dependency Injection.

---

✔ **Correct:**

```csharp
public class TestController(ILogger<TestController> logger) : Controller
{
    public IActionResult Index()
    {
        logger.LogInformation("Test page visited at {time}", DateTime.Now);
        return View();
    }
}
```

In this correct version, the `logger` is passed directly into the primary constructor without the `in` keyword. This ensures that Dependency Injection works correctly and the logger is utilized within the method as expected.

### 4.6. When to Use

- Use the `in` keyword for large value types where avoiding copying improves performance, but avoid it for reference types such as `ILogger<T>`.
- Do not apply the `in` keyword to parameters in primary constructors for ASP.NET Core controllers, especially when using Dependency Injection.

---

## 5. Choosing Between Classic Parameterized Constructors and Primary Constructors for Dependency Injection (DI) in ASP.NET Core

When deciding between **Classic Parameterized Constructors** and **Primary Constructors** for Dependency Injection (DI) in ASP.NET Core, the choice impacts the readability, consistency, and maintainability of the code. Here's a set of guidelines to help you choose the appropriate approach:

### 5.1. Classic Parameterized Constructors

#### 5.1.1. Guideline

Use **Classic Parameterized Constructors** when adhering to established patterns, particularly when:

- Targeting frameworks or versions of C# that do not support **Primary Constructors**.
- Following traditional, well-documented patterns for dependency injection.
- Your project involves complex DI scenarios where multiple dependencies or additional logic (e.g., validation or transformation) are needed in the constructor body.

#### 5.2.2. Rationale

Classic parameterized constructors have long been the standard for DI in ASP.NET Core. They offer:

- **Flexibility**: You can include logic like null checks, initialization, or transformations within the constructor body.
- **Familiarity**: Since this approach is widely used, it aligns with most existing codebases and is easily understood by developers accustomed to classic DI patterns.

#### 5.2.3. Example

```csharp
public class TestController : Controller
{
    private readonly ILogger<TestController> _logger;

    public TestController(ILogger<TestController> logger)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public IActionResult Index()
    {
        _logger.LogInformation("Test page visited at {time}", DateTime.Now);
        return View();
    }
}
```

In this example, the **Classic Parameterized Constructor** initializes the `ILogger<T>` service, checks for null values, and assigns it to the private field.

#### 5.2.4. When to Use

- Use classic constructors when your application targets an older version of C# (before C# 12) or when there are additional initialization or validation requirements.
- If the code needs to remain familiar and consistent with other parts of a larger project where primary constructors are not yet adopted.
- Use them for consistency across larger teams or projects that rely on more traditional DI methods.

### 5.2. Primary Constructors

#### 5.2.1. Guideline:

Use **Primary Constructors** when you want to simplify and modernize DI, especially for scenarios where:

- There is no complex initialization logic needed beyond assigning injected dependencies to fields.
- You are targeting C# 12 or later, and leveraging the language’s modern features for more concise, cleaner code.
- The project or team prioritizes newer features and prefers more compact syntax with fewer lines of boilerplate code.

#### 5.2.2. Rationale:

Primary constructors are introduced in C# 12 and allow for cleaner, more concise code. They reduce the need for explicit field declarations and constructor bodies by automatically assigning injected dependencies. Benefits include:

- **Brevity**: You can eliminate boilerplate code, reducing the verbosity of dependency injection.
- **Simplicity**: If DI is straightforward without the need for additional constructor logic, primary constructors streamline the process.

#### 5.2.3. Example:

```csharp
public class TestController(ILogger<TestController> logger) : Controller
{
    public IActionResult Index()
    {
        logger.LogInformation("Test page visited at {time}", DateTime.Now);
        return View();
    }
}
```

In this example, the **Primary Constructor** automatically initializes the logger without explicit constructor logic, providing a more concise syntax.

#### 5.2.4. When to Use - Primary Constructor

- Use primary constructors for simple DI scenarios where no additional logic (e.g., validation) is required in the constructor.
- When targeting C# 12+ and aiming to reduce boilerplate code for a cleaner, more concise syntax.
- When starting new projects and modernizing the codebase, favoring newer language features for simplicity.

### 5.3. Comparative Analysis:\*\*

#### **Classic Parameterized Constructors:**

| **Pros**                               | **Cons**                                           |
| -------------------------------------- | -------------------------------------------------- |
| Widely used and familiar               | More verbose, especially for simple DI cases       |
| Flexibility for additional logic       | Requires explicit field declaration and assignment |
| Well-documented in ASP.NET Core guides | Can become bloated with many dependencies          |

---

#### **Primary Constructors:**

| **Pros**                               | **Cons**                                   |
| -------------------------------------- | ------------------------------------------ |
| Concise and modern                     | Limited to simple scenarios                |
| Reduces boilerplate code               | Cannot handle complex initialization logic |
| Eliminates redundant constructor logic | Requires C# 12+                            |

---

### 5.4. Recommendation

- **For simple scenarios**: Use **Primary Constructors** to streamline code and reduce verbosity, especially if you are targeting C# 12 or later.
- **For complex scenarios**: Use **Classic Parameterized Constructors** if you need to include additional logic, validation, or initialization in your constructor, or when working with older frameworks.

This balance allows you to leverage the latest language features while still adhering to familiar patterns when necessary.

### 5.6. Additional Considerations

- **Team Familiarity**: Consider the experience and familiarity of your development team with C# features. If your team is accustomed to classic constructors, a gradual shift towards primary constructors might be beneficial.
- **Code Review and Maintenance**: Discuss and document the chosen approach in code reviews to ensure consistency across the codebase.
