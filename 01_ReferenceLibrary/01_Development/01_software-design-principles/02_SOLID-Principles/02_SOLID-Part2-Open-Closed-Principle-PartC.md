# 02_SOLID-Part2-Open-Closed-Principle - Part C

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Single Responsibility Principle (Part 1), Basic inheritance and interfaces  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Open/Closed Principle (OCP) and its strategic importance

## Part C of 3

Previous: [02_SOLID-Part2-Open-Closed-Principle-PartB.md](02_SOLID-Part2-Open-Closed-Principle-PartB.md)

---

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


    ##### Pattern 2: Decorator Pattern
csharp
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
    private readonly ILogger`LoggedNotificationSender` _logger;
    
    public LoggedNotificationSender(INotificationSender inner, 
                                  ILogger`LoggedNotificationSender` logger)
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

    ##### Dependency Injection Configuration
csharp
// Configure services for OCP compliance
public void ConfigureServices(IServiceCollection services)
{
    // Register discount strategies
    services.AddTransient`IDiscountStrategy, PercentageDiscountStrategy`(provider =>
        new PercentageDiscountStrategy(0.10m));
    services.AddTransient`IDiscountStrategy, FixedAmountDiscountStrategy`(provider =>
        new FixedAmountDiscountStrategy(50m));
    services.AddTransient`IDiscountStrategy, BuyOneGetOneStrategy`(provider =>
        new BuyOneGetOneStrategy("Electronics"));
    services.AddTransient`IDiscountStrategy, LoyaltyDiscountStrategy`(provider =>
        new LoyaltyDiscountStrategy(100, 0.01m));
    
    // Register calculator with all strategies
    services.AddTransient`DiscountCalculator`();
    
    // Decorator pattern setup
    services.AddTransient`EmailNotificationSender`();
    services.Decorate`INotificationSender, EncryptedNotificationSender`();
    services.Decorate`INotificationSender, LoggedNotificationSender`();
}
```text

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
