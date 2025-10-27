# 01_SOLID-Part1-Single-Responsibility - Part A

**Learning Level**: Intermediate
**Prerequisites**: Basic OOP concepts, understanding of classes and methods
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Single Responsibility Principle (SRP) and why it matters
- Identify SRP violations in real-world code examples
- Apply SRP refactoring techniques to improve code maintainability
- Design classes that have a single, well-defined purpose

## Part A of 3

Next: [01_SOLID-Part1-Single-Responsibility-PartB.md](01_SOLID-Part1-Single-Responsibility-PartB.md)

---

## 📋 Content Sections

### Quick Overview (5 minutes)

**Single Responsibility Principle (SRP)**: *"A class should have only one reason to change."*

**Core Problem**: Classes that try to do too many things become:

- Difficult to maintain and test
- Prone to bugs when requirements change
- Hard to reuse in different contexts
- Complex to understand and modify

```text
❌ SRP VIOLATION: God Class Anti-Pattern
┌─────────────────────────────────────┐
│           UserManager              │
├─────────────────────────────────────┤
│ + ValidateUser()                    │
│ + SaveUserToDatabase()              │
│ + SendWelcomeEmail()                │
│ + GenerateUserReport()              │
│ + CalculateUserDiscount()           │
│ + LogUserActivity()                 │
└─────────────────────────────────────┘
❌ Too many responsibilities = high coupling, low cohesion

✅ SRP COMPLIANT: Focused Classes
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ UserValidator   │  │ UserRepository  │  │ EmailService    │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ + Validate()    │  │ + Save()        │  │ + SendEmail()   │
└─────────────────┘  └─────────────────┘  └─────────────────┘
✅ Single purpose = loose coupling, high cohesion```csharp
**Benefits of SRP**:

- **Easier Testing** - Focused classes are simpler to test
- **Better Maintainability** - Changes affect fewer components
- **Improved Reusability** - Single-purpose classes can be reused
- **Clearer Code** - Each class has a clear, understandable role

### Core Concepts (15 minutes)

#### Understanding "Reason to Change"

**Key Question**: *"What would cause this class to be modified?"*```csharp
// ❌ BAD: Multiple reasons to change
public class Employee
{
    public string Name { get; set; }
    public decimal Salary { get; set; }
    public string Department { get; set; }

    // Reason 1: Business logic changes
    public decimal CalculateBonus()
    {
        if (Department == "Sales")
            return Salary * 0.15m;
        else if (Department == "Engineering")
            return Salary * 0.12m;
        else
            return Salary * 0.10m;
    }

    // Reason 2: Data persistence changes
    public void SaveToDatabase()
    {
        var connectionString = "Server=...";
        using var connection = new SqlConnection(connectionString);
        var sql = "INSERT INTO Employees (Name, Salary, Department) VALUES (@name, @salary, @dept)";
        // Database save logic...
    }

    // Reason 3: Reporting format changes
    public string GenerateReport()
    {
        return $"Employee Report
" +
               $"Name: {Name}
" +
               $"Salary: {Salary:C}
" +
               $"Department: {Department}
" +
               $"Bonus: {CalculateBonus():C}";
    }

    // Reason 4: Email template changes
    public void SendSalaryNotification()
    {
        var emailBody = $"Dear {Name}, your current salary is {Salary:C}";
        // Email sending logic...
    }
}```csharp
**Problems with this design**:

- **4 different reasons to change** the Employee class
- **Database changes** affect business logic class
- **Email template changes** require modifying the core Employee class
- **Testing complexity** - need database and email infrastructure to test bonus calculation

#### SRP Refactoring Strategy```csharp
// ✅ GOOD: Single Responsibility per class
public class Employee
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Salary { get; set; }
    public string Department { get; set; }
    public DateTime HireDate { get; set; }

    // Only data representation - single responsibility
    public int GetYearsOfService()
    {
        return DateTime.Now.Year - HireDate.Year;
    }
}

public class BonusCalculator
{
    // Single responsibility: Calculate bonuses based on business rules
    public decimal CalculateBonus(Employee employee)
    {
        return employee.Department switch
        {
            "Sales" => employee.Salary * 0.15m,
            "Engineering" => employee.Salary * 0.12m,
            "Marketing" => employee.Salary * 0.11m,`_ => employee.Salary * 0.10m
        };
    }

    public decimal CalculateYearEndBonus(Employee employee)
    {
        var baseBonus = CalculateBonus(employee);
        var serviceMultiplier = 1.0m + (employee.GetYearsOfService() * 0.02m);
        return baseBonus * serviceMultiplier;
    }
}

public class EmployeeRepository
{
    private readonly string`_connectionString;

    public EmployeeRepository(string connectionString)
    {`_connectionString = connectionString;
    }

    // Single responsibility: Employee data persistence
    public async Task`Employee` GetByIdAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        var sql = "SELECT * FROM Employees WHERE Id = @id";
        return await connection.QuerySingleOrDefaultAsync`Employee`(sql, new { id });
    }

    public async Task SaveAsync(Employee employee)
    {
        using var connection = new SqlConnection(_connectionString);
        var sql = @"INSERT INTO Employees (Name, Salary, Department, HireDate)
                    VALUES (@Name, @Salary, @Department, @HireDate)";
        await connection.ExecuteAsync(sql, employee);
    }

    public async Task UpdateAsync(Employee employee)
    {
        using var connection = new SqlConnection(_connectionString);
        var sql = @"UPDATE Employees SET Name = @Name, Salary = @Salary,
                    Department = @Department WHERE Id = @Id";
        await connection.ExecuteAsync(sql, employee);
    }
}

public class EmployeeReportGenerator
{
    private readonly BonusCalculator`_bonusCalculator;

    public EmployeeReportGenerator(BonusCalculator bonusCalculator)
    {`_bonusCalculator = bonusCalculator;
    }

    // Single responsibility: Generate employee reports
    public string GenerateDetailedReport(Employee employee)
    {
        var bonus =`_bonusCalculator.CalculateBonus(employee);
        var yearEndBonus =`_bonusCalculator.CalculateYearEndBonus(employee);

        return $"""
            Employee Detailed Report
            ========================
            Name: {employee.Name}
            Department: {employee.Department}
            Hire Date: {employee.HireDate:yyyy-MM-dd}
            Years of Service: {employee.GetYearsOfService()}
            Current Salary: {employee.Salary:C}
            Regular Bonus: {bonus:C}
            Year-End Bonus: {yearEndBonus:C}
            """;
    }

    public string GenerateSummaryReport(Employee employee)
    {
        return $"{employee.Name} ({employee.Department}) - {employee.Salary:C}";
    }
}

public class EmployeeNotificationService
{
    private readonly IEmailService`_emailService;

    public EmployeeNotificationService(IEmailService emailService)
    {`_emailService = emailService;
    }

    // Single responsibility: Employee notifications
    public async Task SendSalaryUpdateNotificationAsync(Employee employee, decimal newSalary)
    {
        var subject = "Salary Update Notification";
        var body = $"""
            Dear {employee.Name},

            We're pleased to inform you that your salary has been updated to {newSalary:C}.
            This change is effective immediately.

            Best regards,
            HR Department
            """;

        await`_emailService.SendEmailAsync(employee.Name, subject, body);
    }

    public async Task SendBonusNotificationAsync(Employee employee, decimal bonusAmount)
    {
        var subject = "Bonus Notification";
        var body = $"""
            Dear {employee.Name},

            Congratulations! You have earned a bonus of {bonusAmount:C}.
            The bonus will be included in your next paycheck.

            Thank you for your hard work!
            HR Department
            """;

        await`_emailService.SendEmailAsync(employee.Name, subject, body);
    }
}```csharp

### Practical Implementation (8 minutes)

#### Orchestrating Single-Responsibility Classes```csharp
public class EmployeeService
{
    private readonly EmployeeRepository`_repository;
    private readonly BonusCalculator`_bonusCalculator;
    private readonly EmployeeReportGenerator`_reportGenerator;
    private readonly EmployeeNotificationService`_notificationService;
    private readonly ILogger`EmployeeService``_logger;

    public EmployeeService(
        EmployeeRepository repository,
        BonusCalculator bonusCalculator,
        EmployeeReportGenerator reportGenerator,
        EmployeeNotificationService notificationService,
        ILogger`EmployeeService` logger)
    {`_repository = repository;
       `_bonusCalculator = bonusCalculator;`_reportGenerator = reportGenerator;
       `_notificationService = notificationService;`_logger = logger;
    }

    public async Task`string` ProcessAnnualReviewAsync(int employeeId)
    {
        try
        {
            // Each operation delegates to single-responsibility classes
            var employee = await`_repository.GetByIdAsync(employeeId);
            if (employee == null)
                return $"Employee {employeeId} not found";

            var bonus =`_bonusCalculator.CalculateYearEndBonus(employee);
            var report =`_reportGenerator.GenerateDetailedReport(employee);

            await`_notificationService.SendBonusNotificationAsync(employee, bonus);`_logger.LogInformation("Annual review completed for employee {EmployeeId}", employeeId);

            return report;
        }
        catch (Exception ex)
        {
           `_logger.LogError(ex, "Failed to process annual review for employee {EmployeeId}", employeeId);
            throw;
        }
    }

    public async Task UpdateSalaryAsync(int employeeId, decimal newSalary)
    {
        var employee = await`_repository.GetByIdAsync(employeeId);
        if (employee == null)
            throw new ArgumentException($"Employee {employeeId} not found");

        var oldSalary = employee.Salary;
        employee.Salary = newSalary;

        await`_repository.UpdateAsync(employee);
        await`_notificationService.SendSalaryUpdateNotificationAsync(employee, newSalary);`_logger.LogInformation("Salary updated for employee {EmployeeId}: {OldSalary} -> {NewSalary}",
                             employeeId, oldSalary, newSalary);
    }
}
```csharp
---

## ✅ Key Takeaways (2 minutes)

### **Single Responsibility Benefits Achieved**

✅ **Clear Purpose**: Each class has one well-defined responsibility
✅ **Easy Testing**: Individual components can be tested in isolation
✅ **Better Maintainability**: Changes are localized to specific classes
✅ **Improved Reusability**: Single-purpose classes can be reused across contexts
✅ **Reduced Coupling**: Classes depend on abstractions rather than concrete implementations

### **Identification Techniques**

- **Ask "Why would this class change?"** - Multiple answers indicate SRP violation
- **Count the verbs** in class methods - too many different action types suggest multiple responsibilities
- **Look for unrelated imports** - classes that need many different libraries often do too much
- **Check method cohesion** - methods should work together toward the same goal

### **What's Next**

**Part B** will cover:

- Advanced SRP refactoring techniques with practical examples
- Dependency injection patterns for loose coupling
- Testing strategies for single-responsibility classes
- Common SRP violation patterns and their solutions

---

## 🔗 Series Navigation

- **Current**: Part A - SRP Foundation ✅
- **Next**: [01_SOLID-Part1-Single-Responsibility-PartB.md](01_SOLID-Part1-Single-Responsibility-PartB.md)
- **Then**: [01_SOLID-Part1-Single-Responsibility-PartC.md](01_SOLID-Part1-Single-Responsibility-PartC.md)
- **Series**: SOLID Principles Mastery Track

**Last Updated**: October 22, 2025
**Format**: 30-minute focused learning segment

---

## 🔗 Language-Specific Implementations

**Learn principles here, implement in language domains:**

### **Available Implementations**

- **C#**: [C# SOLID Implementation](../../03_CSharp/03_SOLID-Implementation/)
- **Python**: [Python SOLID Implementation](../../02_Python/06_SOLID-Implementation/)
- **Java**: [Java SOLID Implementation](../../04_Java/03_SOLID-Implementation/)

### **Future Languages**

- TypeScript, Go, Rust implementations coming soon

---

## 🗺️ Learning Progression

### **Recommended Learning Path**```mermaid
graph TD
    A[Prerequisites: OOP Fundamentals] --> B[01: Single Responsibility]
    B --> C[02: Open/Closed]
    C --> D[03: Liskov Substitution]
    D --> E[04: Interface Segregation]
    E --> F[05: Dependency Inversion]
    F --> G[Language Implementation]
    F --> H[Design Patterns]

    style A fill:#e1f5fe
    style B fill:#e8f5e8
    style C fill:#e8f5e8
    style D fill:#e8f5e8
    style E fill:#e8f5e8
    style F fill:#e8f5e8
    style G fill:#fff3e0
    style H fill:#f3e5f5```csharp

### **Alternative Learning Paths**

- **Quick Review**: Use Track guide for rapid overview
- **Deep Study**: Use Deep Dive for comprehensive analysis
- **Reference Use**: Jump to specific principles as needed

---

## 🎯 Success Criteria

By completing this series, you will:

- ✅ **Identify SOLID violations** in existing codebases
- ✅ **Refactor code** to comply with SOLID principles
- ✅ **Design new systems** with SOLID principles from the start
- ✅ **Lead code reviews** using SOLID as quality gates
- ✅ **Mentor teams** on SOLID principle application
- ✅ **Make architectural decisions** based on SOLID compliance

---

## 🔗 Related Topics

### **Prerequisites**

- [OOP Fundamentals](../01_OOP-fundamentals/) - Essential foundation

### **Builds Upon**

- Object-oriented design concepts
- Basic software engineering principles

### **Enables**

- [Design Patterns](../03_Design-Patterns/) - GoF patterns and beyond
- [Clean Architecture](../04_Architectural-Patterns/) - Enterprise architecture
- [Advanced Principles](../05_Advanced-Principles/) - Modern design concepts

### **Cross-References**

- **Testing**: [TDD Principles](../07_Testability-and-TDD/)
- **Performance**: [Performance by Design](../10_Scalability-and-Performance-Principles/)
- **Security**: [Security by Design](../11_Security-by-Design/)

---

*Last Updated: September 11, 2025*
*Part of STSA Lead Architect Knowledge Base*
