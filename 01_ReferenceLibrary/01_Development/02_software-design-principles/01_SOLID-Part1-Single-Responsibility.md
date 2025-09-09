# 01_SOLID-Part1-Single-Responsibility

**Learning Level**: Intermediate  
**Prerequisites**: Basic OOP concepts, understanding of classes and methods  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Single Responsibility Principle (SRP) and why it matters
- Identify SRP violations in existing code
- Refactor code to comply with SRP using practical techniques
- Apply SRP in real-world development scenarios

## 📋 Content Sections

### Quick Overview (5 minutes)

**Single Responsibility Principle (SRP)**: *"A class should have only one reason to change."*

```text
❌ VIOLATION: Multiple Responsibilities
┌─────────────────────────────────┐
│        CustomerService          │
├─────────────────────────────────┤
│ + ValidateCustomer()            │
│ + SaveToDatabase()              │
│ + SendWelcomeEmail()            │
│ + GenerateReport()              │
│ + CalculateLoyaltyPoints()      │
└─────────────────────────────────┘

✅ SRP COMPLIANT: Single Responsibilities
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ CustomerValidator│  │ CustomerRepository│  │ EmailService    │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ + Validate()    │  │ + Save()        │  │ + SendWelcome() │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

**Key Questions for SRP**:

- What is this class's primary purpose?
- How many reasons could cause this class to change?
- Could I describe this class in one sentence without using "and"?

### Core Concepts (15 minutes)

#### Identifying Responsibilities

**Responsibility Types**:

1. **Business Logic**: Core domain operations
2. **Data Access**: Persistence and retrieval
3. **Validation**: Input/output verification
4. **Communication**: External service integration
5. **Presentation**: UI and formatting
6. **Infrastructure**: Logging, caching, configuration

#### SRP Violation Example

```csharp
// ❌ BAD: Multiple responsibilities in one class
public class OrderProcessor
{
    public void ProcessOrder(Order order)
    {
        // Responsibility 1: Validation
        if (order.Items.Count == 0)
            throw new InvalidOperationException("Order must have items");
        
        if (order.Customer.Email == null)
            throw new InvalidOperationException("Customer email required");
        
        // Responsibility 2: Business Logic
        decimal total = 0;
        foreach (var item in order.Items)
        {
            total += item.Price * item.Quantity;
        }
        order.Total = total;
        
        // Responsibility 3: Data Access
        using var connection = new SqlConnection(connectionString);
        var command = new SqlCommand($"INSERT INTO Orders...", connection);
        command.ExecuteNonQuery();
        
        // Responsibility 4: External Communication
        var emailService = new SmtpClient();
        emailService.Send(order.Customer.Email, "Order Confirmation", 
            $"Your order #{order.Id} has been processed");
        
        // Responsibility 5: Logging
        Console.WriteLine($"Order {order.Id} processed successfully");
    }
}
```

#### SRP Compliant Solution

```csharp
// ✅ GOOD: Single responsibilities separated
public class OrderValidator
{
    public ValidationResult Validate(Order order)
    {
        var errors = new List<string>();
        
        if (order.Items.Count == 0)
            errors.Add("Order must have items");
            
        if (string.IsNullOrEmpty(order.Customer.Email))
            errors.Add("Customer email required");
        
        return new ValidationResult(errors);
    }
}

public class OrderCalculator
{
    public decimal CalculateTotal(Order order)
    {
        return order.Items.Sum(item => item.Price * item.Quantity);
    }
}

public class OrderRepository
{
    private readonly string _connectionString;
    
    public OrderRepository(string connectionString)
    {
        _connectionString = connectionString;
    }
    
    public async Task SaveAsync(Order order)
    {
        using var connection = new SqlConnection(_connectionString);
        var command = new SqlCommand("INSERT INTO Orders...", connection);
        await command.ExecuteNonQueryAsync();
    }
}

public class EmailNotificationService
{
    private readonly IEmailSender _emailSender;
    
    public EmailNotificationService(IEmailSender emailSender)
    {
        _emailSender = emailSender;
    }
    
    public async Task SendOrderConfirmationAsync(Order order)
    {
        var subject = "Order Confirmation";
        var body = $"Your order #{order.Id} has been processed";
        await _emailSender.SendAsync(order.Customer.Email, subject, body);
    }
}

// Orchestrator using dependency injection
public class OrderService
{
    private readonly OrderValidator _validator;
    private readonly OrderCalculator _calculator;
    private readonly OrderRepository _repository;
    private readonly EmailNotificationService _emailService;
    private readonly ILogger<OrderService> _logger;
    
    public OrderService(
        OrderValidator validator,
        OrderCalculator calculator,
        OrderRepository repository,
        EmailNotificationService emailService,
        ILogger<OrderService> logger)
    {
        _validator = validator;
        _calculator = calculator;
        _repository = repository;
        _emailService = emailService;
        _logger = logger;
    }
    
    public async Task<ProcessResult> ProcessOrderAsync(Order order)
    {
        try
        {
            // Validate
            var validationResult = _validator.Validate(order);
            if (!validationResult.IsValid)
                return ProcessResult.Failed(validationResult.Errors);
            
            // Calculate
            order.Total = _calculator.CalculateTotal(order);
            
            // Save
            await _repository.SaveAsync(order);
            
            // Notify
            await _emailService.SendOrderConfirmationAsync(order);
            
            // Log
            _logger.LogInformation("Order {OrderId} processed successfully", order.Id);
            
            return ProcessResult.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process order {OrderId}", order.Id);
            return ProcessResult.Failed($"Processing failed: {ex.Message}");
        }
    }
}
```

### Practical Implementation (8 minutes)

#### SRP Refactoring Checklist

##### Step 1: Identify Responsibilities

```csharp
// Analysis technique: Method grouping
public class CustomerManager
{
    // Data validation group
    public bool IsValidEmail(string email) { }
    public bool IsValidPhone(string phone) { }
    
    // Data persistence group  
    public void SaveCustomer(Customer customer) { }
    public Customer GetCustomer(int id) { }
    
    // Business logic group
    public decimal CalculateDiscount(Customer customer) { }
    public bool IsEligibleForPremium(Customer customer) { }
    
    // Communication group
    public void SendWelcomeEmail(Customer customer) { }
    public void SendPromotionalSms(Customer customer) { }
}
```

##### Step 2: Extract Classes

```csharp
public class CustomerValidator
{
    public ValidationResult Validate(Customer customer)
    {
        var result = new ValidationResult();
        
        if (!IsValidEmail(customer.Email))
            result.AddError("Invalid email format");
            
        if (!IsValidPhone(customer.Phone))
            result.AddError("Invalid phone format");
            
        return result;
    }
    
    private bool IsValidEmail(string email) => 
        !string.IsNullOrEmpty(email) && email.Contains("@");
        
    private bool IsValidPhone(string phone) => 
        !string.IsNullOrEmpty(phone) && phone.All(char.IsDigit);
}

public class CustomerRepository
{
    private readonly IDbContext _context;
    
    public CustomerRepository(IDbContext context)
    {
        _context = context;
    }
    
    public async Task<Customer> GetByIdAsync(int id)
    {
        return await _context.Customers.FindAsync(id);
    }
    
    public async Task SaveAsync(Customer customer)
    {
        _context.Customers.Add(customer);
        await _context.SaveChangesAsync();
    }
}

public class CustomerBusinessLogic
{
    public decimal CalculateDiscount(Customer customer)
    {
        if (customer.YearsAsCustomer >= 5)
            return 0.15m; // 15% discount
        if (customer.YearsAsCustomer >= 2)
            return 0.10m; // 10% discount
        return 0.05m; // 5% discount
    }
    
    public bool IsEligibleForPremium(Customer customer)
    {
        return customer.YearsAsCustomer >= 1 && 
               customer.TotalPurchases >= 1000m;
    }
}

public class CustomerNotificationService
{
    private readonly IEmailService _emailService;
    private readonly ISmsService _smsService;
    
    public CustomerNotificationService(IEmailService emailService, ISmsService smsService)
    {
        _emailService = emailService;
        _smsService = smsService;
    }
    
    public async Task SendWelcomeAsync(Customer customer)
    {
        await _emailService.SendAsync(customer.Email, 
            "Welcome!", "Thank you for joining us!");
    }
    
    public async Task SendPromotionalSmsAsync(Customer customer, string message)
    {
        await _smsService.SendAsync(customer.Phone, message);
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**SRP Benefits**:

- ✅ **Maintainability**: Changes to validation don't affect data access
- ✅ **Testability**: Each class can be unit tested independently
- ✅ **Reusability**: Components can be used in different contexts
- ✅ **Team Development**: Different developers can work on different responsibilities

**Common SRP Mistakes**:

- ❌ God classes that do everything
- ❌ Utility classes with unrelated methods
- ❌ Controllers that contain business logic
- ❌ Models that validate themselves

**Quick SRP Assessment**:

1. Can you describe the class purpose in one sentence without "and"?
2. How many reasons could cause this class to change?
3. Could you split this class into smaller, focused classes?

### Next Steps

**Immediate Actions**:

- Review your current codebase for SRP violations
- Practice the refactoring techniques shown above
- Continue to Part 2: **Open/Closed Principle (OCP)**

**Advanced Learning**:

- Dependency Injection patterns for SRP
- Testing strategies for single-responsibility classes
- Microservices architecture and SRP

## 🔗 Related Topics

**Prerequisites**: Object-Oriented Programming fundamentals, Basic design patterns  
**Builds Upon**: Clean Code principles, SOLID foundation concepts  
**Enables**: Open/Closed Principle (Part 2), Dependency Injection patterns  
**Related**: Clean Architecture, Domain-Driven Design, Unit Testing strategies
