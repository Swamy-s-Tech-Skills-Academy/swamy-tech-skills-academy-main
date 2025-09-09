# 02_SOLID-Part2-Open-Closed-Principle

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Single Responsibility Principle (Part 1), Basic inheritance and interfaces  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Open/Closed Principle (OCP) and its strategic importance
- Identify OCP violations and their maintenance costs
- Apply inheritance and composition patterns to achieve OCP compliance
- Design extensible systems using interfaces and abstract classes

## 📋 Content Sections

### Quick Overview (5 minutes)

**Open/Closed Principle (OCP)**: *"Software entities should be open for extension but closed for modification."*

```text
❌ OCP VIOLATION: Modification Required
┌─────────────────────────────────────┐
│         PaymentProcessor            │
├─────────────────────────────────────┤
│ + ProcessPayment(type, amount)      │
│   {                                 │
│     if (type == "Credit")           │
│       // Credit card logic          │
│     else if (type == "PayPal")      │
│       // PayPal logic               │
│     else if (type == "Bitcoin") ← NEW│
│       // Bitcoin logic              │
│   }                                 │
└─────────────────────────────────────┘

✅ OCP COMPLIANT: Extension Without Modification
┌─────────────────┐
│ IPaymentMethod  │
├─────────────────┤
│ + Process()     │
└─────────────────┘
        ↑
┌───────┼───────┬─────────────┐
│       │       │             │
Credit  PayPal  Bitcoin   NewMethod
Card   Method   Method      ← ADD
```

**Core Benefits**:

- **Risk Reduction**: No existing code modification = no regression bugs
- **Parallel Development**: Teams can add features independently
- **System Stability**: Core functionality remains untouched
- **Future-Proofing**: Easy to add new requirements

### Core Concepts (15 minutes)

#### The Extension vs Modification Dilemma

**Scenario**: E-commerce discount system

```csharp
// ❌ BAD: Violates OCP - requires modification for new discount types
public class DiscountCalculator
{
    public decimal CalculateDiscount(Order order, string discountType)
    {
        switch (discountType)
        {
            case "PERCENTAGE":
                return order.Total * 0.1m; // 10% off
            case "FIXED":
                return 50m; // $50 off
            case "BOGO":
                return order.Items.Where(i => i.Category == "Electronics")
                          .Min(i => i.Price);
            // Adding new discount types requires modifying this method
            // Risk: Breaking existing discount calculations
            default:
                throw new ArgumentException($"Unknown discount type: {discountType}");
        }
    }
}
```

**Problems with this approach**:

- Every new discount type requires changing existing code
- Risk of breaking existing discount calculations
- Difficult to unit test individual discount strategies
- Violates Single Responsibility (handles multiple discount types)

#### OCP Solution: Strategy Pattern

```csharp
// ✅ GOOD: OCP compliant using Strategy Pattern
public interface IDiscountStrategy
{
    decimal CalculateDiscount(Order order);
    string Name { get; }
    bool IsApplicable(Order order);
}

public class PercentageDiscountStrategy : IDiscountStrategy
{
    private readonly decimal _percentage;
    
    public PercentageDiscountStrategy(decimal percentage)
    {
        _percentage = percentage;
    }
    
    public string Name => $"{_percentage * 100}% Discount";
    
    public decimal CalculateDiscount(Order order)
    {
        return order.Total * _percentage;
    }
    
    public bool IsApplicable(Order order)
    {
        return order.Total > 0;
    }
}

public class FixedAmountDiscountStrategy : IDiscountStrategy
{
    private readonly decimal _amount;
    
    public FixedAmountDiscountStrategy(decimal amount)
    {
        _amount = amount;
    }
    
    public string Name => $"${_amount} Off";
    
    public decimal CalculateDiscount(Order order)
    {
        return Math.Min(_amount, order.Total);
    }
    
    public bool IsApplicable(Order order)
    {
        return order.Total >= _amount;
    }
}

public class BuyOneGetOneStrategy : IDiscountStrategy
{
    private readonly string _category;
    
    public BuyOneGetOneStrategy(string category)
    {
        _category = category;
    }
    
    public string Name => $"BOGO {_category}";
    
    public decimal CalculateDiscount(Order order)
    {
        var categoryItems = order.Items
            .Where(i => i.Category.Equals(_category, StringComparison.OrdinalIgnoreCase))
            .OrderBy(i => i.Price)
            .ToList();
            
        if (categoryItems.Count >= 2)
        {
            return categoryItems.First().Price; // Free cheapest item
        }
        
        return 0;
    }
    
    public bool IsApplicable(Order order)
    {
        return order.Items.Count(i => 
            i.Category.Equals(_category, StringComparison.OrdinalIgnoreCase)) >= 2;
    }
}

// Context class - closed for modification, open for extension
public class DiscountCalculator
{
    private readonly List<IDiscountStrategy> _strategies;
    
    public DiscountCalculator(IEnumerable<IDiscountStrategy> strategies)
    {
        _strategies = strategies.ToList();
    }
    
    public DiscountResult CalculateBestDiscount(Order order)
    {
        var applicableDiscounts = _strategies
            .Where(strategy => strategy.IsApplicable(order))
            .Select(strategy => new DiscountResult
            {
                Strategy = strategy.Name,
                Amount = strategy.CalculateDiscount(order)
            })
            .OrderByDescending(d => d.Amount)
            .ToList();
            
        return applicableDiscounts.FirstOrDefault() ?? 
               new DiscountResult { Strategy = "None", Amount = 0 };
    }
}
```

#### Adding New Features Without Modification

```csharp
// ✅ NEW: Adding loyalty discount without touching existing code
public class LoyaltyDiscountStrategy : IDiscountStrategy
{
    private readonly int _requiredPoints;
    private readonly decimal _discountPerPoint;
    
    public LoyaltyDiscountStrategy(int requiredPoints, decimal discountPerPoint)
    {
        _requiredPoints = requiredPoints;
        _discountPerPoint = discountPerPoint;
    }
    
    public string Name => "Loyalty Points Discount";
    
    public decimal CalculateDiscount(Order order)
    {
        if (order.Customer.LoyaltyPoints >= _requiredPoints)
        {
            var pointsToUse = Math.Min(order.Customer.LoyaltyPoints, 
                                     (int)(order.Total / _discountPerPoint));
            return pointsToUse * _discountPerPoint;
        }
        return 0;
    }
    
    public bool IsApplicable(Order order)
    {
        return order.Customer?.LoyaltyPoints >= _requiredPoints;
    }
}

// ✅ NEW: Seasonal discount without modifying existing code
public class SeasonalDiscountStrategy : IDiscountStrategy
{
    private readonly DateTime _startDate;
    private readonly DateTime _endDate;
    private readonly decimal _percentage;
    
    public SeasonalDiscountStrategy(DateTime startDate, DateTime endDate, decimal percentage)
    {
        _startDate = startDate;
        _endDate = endDate;
        _percentage = percentage;
    }
    
    public string Name => $"Seasonal {_percentage * 100}% Off";
    
    public decimal CalculateDiscount(Order order)
    {
        var now = DateTime.Now.Date;
        if (now >= _startDate && now <= _endDate)
        {
            return order.Total * _percentage;
        }
        return 0;
    }
    
    public bool IsApplicable(Order order)
    {
        var now = DateTime.Now.Date;
        return now >= _startDate && now <= _endDate && order.Total > 0;
    }
}
```

### Practical Implementation (8 minutes)

#### OCP Implementation Patterns

##### Pattern 1: Template Method Pattern

```csharp
// Abstract base class defines algorithm structure
public abstract class ReportGenerator
{
    public string GenerateReport(IEnumerable<Order> orders)
    {
        var processedData = ProcessData(orders);
        var formattedData = FormatData(processedData);
        return GenerateOutput(formattedData);
    }
    
    protected virtual object ProcessData(IEnumerable<Order> orders)
    {
        return orders.Where(o => o.Status == OrderStatus.Completed);
    }
    
    protected abstract object FormatData(object data);
    protected abstract string GenerateOutput(object formattedData);
}

// Extensions without modifying base class
public class PdfReportGenerator : ReportGenerator
{
    protected override object FormatData(object data)
    {
        // PDF-specific formatting
        return ConvertToPdfFormat(data);
    }
    
    protected override string GenerateOutput(object formattedData)
    {
        return GeneratePdfDocument(formattedData);
    }
    
    private object ConvertToPdfFormat(object data) { /* Implementation */ return data; }
    private string GeneratePdfDocument(object data) { /* Implementation */ return "PDF"; }
}

public class ExcelReportGenerator : ReportGenerator
{
    protected override object FormatData(object data)
    {
        // Excel-specific formatting
        return ConvertToExcelFormat(data);
    }
    
    protected override string GenerateOutput(object formattedData)
    {
        return GenerateExcelWorkbook(formattedData);
    }
    
    private object ConvertToExcelFormat(object data) { /* Implementation */ return data; }
    private string GenerateExcelWorkbook(object data) { /* Implementation */ return "Excel"; }
}
```

##### Pattern 2: Decorator Pattern

```csharp
// Base interface
public interface INotificationSender
{
    Task SendAsync(string recipient, string message);
}

// Basic implementation
public class EmailNotificationSender : INotificationSender
{
    private readonly IEmailService _emailService;
    
    public EmailNotificationSender(IEmailService emailService)
    {
        _emailService = emailService;
    }
    
    public async Task SendAsync(string recipient, string message)
    {
        await _emailService.SendAsync(recipient, "Notification", message);
    }
}

// Extensions through decoration - no modification of existing classes
public class EncryptedNotificationSender : INotificationSender
{
    private readonly INotificationSender _inner;
    private readonly IEncryptionService _encryptionService;
    
    public EncryptedNotificationSender(INotificationSender inner, 
                                     IEncryptionService encryptionService)
    {
        _inner = inner;
        _encryptionService = encryptionService;
    }
    
    public async Task SendAsync(string recipient, string message)
    {
        var encryptedMessage = await _encryptionService.EncryptAsync(message);
        await _inner.SendAsync(recipient, encryptedMessage);
    }
}

public class LoggedNotificationSender : INotificationSender
{
    private readonly INotificationSender _inner;
    private readonly ILogger<LoggedNotificationSender> _logger;
    
    public LoggedNotificationSender(INotificationSender inner, 
                                  ILogger<LoggedNotificationSender> logger)
    {
        _inner = inner;
        _logger = logger;
    }
    
    public async Task SendAsync(string recipient, string message)
    {
        _logger.LogInformation("Sending notification to {Recipient}", recipient);
        try
        {
            await _inner.SendAsync(recipient, message);
            _logger.LogInformation("Successfully sent notification to {Recipient}", recipient);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send notification to {Recipient}", recipient);
            throw;
        }
    }
}
```

##### Dependency Injection Configuration

```csharp
// Configure services for OCP compliance
public void ConfigureServices(IServiceCollection services)
{
    // Register discount strategies
    services.AddTransient<IDiscountStrategy, PercentageDiscountStrategy>(provider =>
        new PercentageDiscountStrategy(0.10m));
    services.AddTransient<IDiscountStrategy, FixedAmountDiscountStrategy>(provider =>
        new FixedAmountDiscountStrategy(50m));
    services.AddTransient<IDiscountStrategy, BuyOneGetOneStrategy>(provider =>
        new BuyOneGetOneStrategy("Electronics"));
    services.AddTransient<IDiscountStrategy, LoyaltyDiscountStrategy>(provider =>
        new LoyaltyDiscountStrategy(100, 0.01m));
    
    // Register calculator with all strategies
    services.AddTransient<DiscountCalculator>();
    
    // Decorator pattern setup
    services.AddTransient<EmailNotificationSender>();
    services.Decorate<INotificationSender, EncryptedNotificationSender>();
    services.Decorate<INotificationSender, LoggedNotificationSender>();
}
```

### Key Takeaways & Next Steps (2 minutes)

**OCP Success Indicators**:

- ✅ New features added without modifying existing code
- ✅ Changes isolated to new classes/modules
- ✅ Existing functionality remains stable
- ✅ Easy to unit test new behaviors

**Common OCP Mistakes**:

- ❌ Switch statements that grow over time
- ❌ If-else chains for type checking
- ❌ Modifying existing methods for new requirements
- ❌ Hard-coded dependencies in business logic

**OCP Design Questions**:

1. How would I add a new variation of this behavior?
2. What parts of the system would I need to change?
3. Can I extend functionality through composition or inheritance?
4. Are my abstractions stable and well-defined?

### Next Steps

**Immediate Actions**:

- Identify switch statements in your codebase that violate OCP
- Practice Strategy and Decorator patterns
- Continue to Part 3: **Liskov Substitution Principle (LSP)**

**Advanced Techniques**:

- Plugin architectures using OCP
- Event-driven extensions
- Configuration-based behavior modification

## 🔗 Related Topics

**Prerequisites**: Single Responsibility Principle, Interface design, Inheritance concepts  
**Builds Upon**: Strategy Pattern, Template Method Pattern, Decorator Pattern  
**Enables**: Liskov Substitution Principle (Part 3), Plugin architectures, Dependency Injection  
**Related**: Design Patterns, Clean Architecture, Domain-Driven Design
