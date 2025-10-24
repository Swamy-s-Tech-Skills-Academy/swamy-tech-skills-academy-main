# 06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals

**Learning Level**: Intermediate  
**Prerequisites**: SOLID Principles, Basic inheritance and interfaces  
**Estimated Time**: Part A of 3 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master the Simple Factory Pattern for basic object creation scenarios
- Understand when object creation complexity requires factory solutions
- Implement static factory methods with parameter-based object selection
- Apply Simple Factory to achieve loose coupling in payment processing systems

## 📋 Content Sections (27-Minute Structure)

### Factory Pattern Overview (5 minutes)

**Factory Pattern**: *"Create objects without specifying the exact class of object to be created."*

**Core Problem**: Direct object instantiation creates tight coupling and inflexible code.

```text
❌ TIGHT COUPLING: Direct Instantiation
┌─────────────────────────────────┐
│     OrderProcessor              │
├─────────────────────────────────┤
│ ProcessOrder() {                │
│   var validator = new           │
│     EmailValidator();           │ ← Hard dependency
│   var calculator = new          │
│     TaxCalculator();            │ ← Hard dependency  
│   var notifier = new            │
│     SmtpNotifier();             │ ← Hard dependency
│ }                               │
└─────────────────────────────────┘

✅ FACTORY PATTERN: Loose Coupling
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ OrderProcessor  │───→│ ServiceFactory  │───→│ Concrete        │
│                 │    │                 │    │ Implementations │
│ - factory       │    │ + CreateValidator│    │                 │
│ + ProcessOrder()│    │ + CreateCalculator│    │ - EmailValidator│
└─────────────────┘    │ + CreateNotifier │    │ - TaxCalculator │
                       └─────────────────┘    │ - SmtpNotifier  │
                                              └─────────────────┘
```

**Factory Pattern Variants**:

1. **Simple Factory** ← Focus of Part A: Static method creates objects based on parameters
2. **Factory Method**: Subclasses decide which concrete class to instantiate  
3. **Abstract Factory**: Creates families of related objects

**When to Use Simple Factory**:

- **Parameter-driven creation** - Object type determined by input parameters
- **Centralized instantiation logic** - Keep creation logic in one place
- **Basic decoupling needs** - Reduce direct dependencies without complex inheritance
- **Configuration-based selection** - Choose implementations based on settings

### Simple Factory Implementation (15 minutes)

#### Payment Processing System Example

```csharp
// Payment system domain models
public enum PaymentType
{
    CreditCard,
    PayPal,
    BankTransfer,
    Cryptocurrency
}

public class PaymentResult
{
    public bool Success { get; set; }
    public string TransactionId { get; set; }
    public decimal ProcessedAmount { get; set; }
    public string Provider { get; set; }
    public string ErrorMessage { get; set; }
    public DateTime ProcessedAt { get; set; } = DateTime.UtcNow;
    
    public static PaymentResult CreateSuccess(string transactionId, decimal amount, string provider)
    {
        return new PaymentResult
        {
            Success = true,
            TransactionId = transactionId,
            ProcessedAmount = amount,
            Provider = provider
        };
    }
    
    public static PaymentResult CreateFailure(string errorMessage)
    {
        return new PaymentResult
        {
            Success = false,
            ErrorMessage = errorMessage
        };
    }
}

// Abstract base for all payment processors
public abstract class PaymentProcessor
{
    public abstract Task<PaymentResult> ProcessAsync(decimal amount, string details);
    public abstract bool IsAvailable();
    public abstract string GetProviderName();
    public abstract decimal GetProcessingFee(decimal amount);
    
    protected virtual bool ValidateAmount(decimal amount)
    {
        return amount > 0 && amount <= 100000; // Basic validation
    }
}

// Concrete payment processor implementations
public class CreditCardProcessor : PaymentProcessor
{
    private readonly string _merchantId;
    private readonly bool _isTestMode;
    
    public CreditCardProcessor(string merchantId = "default", bool isTestMode = false)
    {
        _merchantId = merchantId;
        _isTestMode = isTestMode;
    }
    
    public override async Task<PaymentResult> ProcessAsync(decimal amount, string details)
    {
        if (!ValidateAmount(amount))
        {
            return PaymentResult.CreateFailure("Invalid amount for credit card processing");
        }
        
        // Simulate credit card processing API call
        await Task.Delay(_isTestMode ? 50 : 100);
        
        // Simulate occasional failures (5% failure rate in production)
        var random = new Random();
        if (!_isTestMode && random.NextDouble() < 0.05)
        {
            return PaymentResult.CreateFailure("Credit card processing failed - declined");
        }
        
        var transactionId = $"CC-{DateTime.Now:yyyyMMdd}-{Guid.NewGuid().ToString()[..8].ToUpper()}";
        return PaymentResult.CreateSuccess(transactionId, amount, GetProviderName());
    }
    
    public override bool IsAvailable()
    {
        // Credit cards available 24/7, but simulate occasional maintenance
        return DateTime.Now.Minute != 59; // Simulate 1-minute maintenance window
    }
    
    public override string GetProviderName() => "Stripe Credit Card";
    
    public override decimal GetProcessingFee(decimal amount)
    {
        return amount * 0.029m + 0.30m; // 2.9% + $0.30
    }
}

public class PayPalProcessor : PaymentProcessor
{
    private readonly string _clientId;
    private readonly bool _sandboxMode;
    
    public PayPalProcessor(string clientId = "default", bool sandboxMode = false)
    {
        _clientId = clientId;
        _sandboxMode = sandboxMode;
    }
    
    public override async Task<PaymentResult> ProcessAsync(decimal amount, string details)
    {
        if (!ValidateAmount(amount))
        {
            return PaymentResult.CreateFailure("Invalid amount for PayPal processing");
        }
        
        // PayPal has lower limits than credit cards
        if (amount > 10000)
        {
            return PaymentResult.CreateFailure("Amount exceeds PayPal limit of $10,000");
        }
        
        // Simulate PayPal API processing time
        await Task.Delay(_sandboxMode ? 25 : 150);
        
        var transactionId = $"PP-{DateTime.Now:yyyyMMddHHmm}-{Random.Shared.Next(100000, 999999)}";
        return PaymentResult.CreateSuccess(transactionId, amount, GetProviderName());
    }
    
    public override bool IsAvailable()
    {
        // PayPal maintenance window: 2 AM - 4 AM UTC
        var utcHour = DateTime.UtcNow.Hour;
        return !(utcHour >= 2 && utcHour < 4);
    }
    
    public override string GetProviderName() => "PayPal";
    
    public override decimal GetProcessingFee(decimal amount)
    {
        return amount * 0.034m + 0.35m; // 3.4% + $0.35
    }
}

public class BankTransferProcessor : PaymentProcessor
{
    private readonly string _bankCode;
    private readonly bool _instantTransfer;
    
    public BankTransferProcessor(string bankCode = "default", bool instantTransfer = false)
    {
        _bankCode = bankCode;
        _instantTransfer = instantTransfer;
    }
    
    public override async Task<PaymentResult> ProcessAsync(decimal amount, string details)
    {
        if (!ValidateAmount(amount))
        {
            return PaymentResult.CreateFailure("Invalid amount for bank transfer");
        }
        
        // Bank transfers typically have minimum amounts
        if (amount < 10)
        {
            return PaymentResult.CreateFailure("Minimum bank transfer amount is $10");
        }
        
        // Simulate bank processing time
        var processingTime = _instantTransfer ? 100 : 500;
        await Task.Delay(processingTime);
        
        var transactionId = $"ACH-{DateTime.Now:yyyyMMdd}-{Random.Shared.Next(10000, 99999)}";
        return PaymentResult.CreateSuccess(transactionId, amount, GetProviderName());
    }
    
    public override bool IsAvailable()
    {
        // Bank transfers not available on Sundays and during overnight hours
        var now = DateTime.Now;
        return now.DayOfWeek != DayOfWeek.Sunday && 
               (now.Hour >= 6 && now.Hour < 22);
    }
    
    public override string GetProviderName() => 
        _instantTransfer ? "Instant Bank Transfer" : "ACH Bank Transfer";
    
    public override decimal GetProcessingFee(decimal amount)
    {
        return _instantTransfer ? 1.50m : 0.50m; // Flat fees
    }
}

// Simple Factory implementation
public static class PaymentProcessorFactory
{
    public static PaymentProcessor CreateProcessor(PaymentType paymentType)
    {
        return paymentType switch
        {
            PaymentType.CreditCard => new CreditCardProcessor(),
            PaymentType.PayPal => new PayPalProcessor(),
            PaymentType.BankTransfer => new BankTransferProcessor(),
            PaymentType.Cryptocurrency => throw new NotImplementedException("Cryptocurrency support coming in next release"),
            _ => throw new ArgumentException($"Unsupported payment type: {paymentType}")
        };
    }
    
    // Enhanced factory method with configuration options
    public static PaymentProcessor CreateProcessor(PaymentType paymentType, Dictionary<string, object> config = null)
    {
        config ??= new Dictionary<string, object>();
        
        return paymentType switch
        {
            PaymentType.CreditCard => new CreditCardProcessor(
                merchantId: config.GetValueOrDefault("merchantId", "default").ToString(),
                isTestMode: (bool)config.GetValueOrDefault("testMode", false)
            ),
            PaymentType.PayPal => new PayPalProcessor(
                clientId: config.GetValueOrDefault("clientId", "default").ToString(),
                sandboxMode: (bool)config.GetValueOrDefault("sandboxMode", false)
            ),
            PaymentType.BankTransfer => new BankTransferProcessor(
                bankCode: config.GetValueOrDefault("bankCode", "default").ToString(),
                instantTransfer: (bool)config.GetValueOrDefault("instantTransfer", false)
            ),
            PaymentType.Cryptocurrency => throw new NotImplementedException("Cryptocurrency support coming in next release"),
            _ => throw new ArgumentException($"Unsupported payment type: {paymentType}")
        };
    }
    
    // Factory method with availability checking and fallback
    public static PaymentProcessor CreateAvailableProcessor(PaymentType preferredType, Dictionary<string, object> config = null)
    {
        // Try preferred processor first
        try
        {
            var processor = CreateProcessor(preferredType, config);
            if (processor.IsAvailable())
            {
                return processor;
            }
        }
        catch (NotImplementedException)
        {
            // Preferred type not supported, fall through to alternatives
        }
        
        // Find available alternatives
        var alternatives = Enum.GetValues<PaymentType>()
            .Where(t => t != preferredType)
            .ToList();
            
        foreach (var alternative in alternatives)
        {
            try
            {
                var processor = CreateProcessor(alternative, config);
                if (processor.IsAvailable())
                {
                    return processor;
                }
            }
            catch (NotImplementedException)
            {
                continue; // Skip unsupported types
            }
        }
        
        throw new InvalidOperationException("No payment processors are currently available");
    }
    
    // Get all supported payment types
    public static IEnumerable<PaymentType> GetSupportedTypes()
    {
        return Enum.GetValues<PaymentType>()
            .Where(t => t != PaymentType.Cryptocurrency); // Exclude unsupported types
    }
    
    // Get processor with lowest fees
    public static PaymentProcessor CreateLowestFeeProcessor(decimal amount, Dictionary<string, object> config = null)
    {
        var availableProcessors = GetSupportedTypes()
            .Select(type => CreateProcessor(type, config))
            .Where(processor => processor.IsAvailable())
            .ToList();
            
        if (!availableProcessors.Any())
        {
            throw new InvalidOperationException("No payment processors are currently available");
        }
        
        return availableProcessors
            .OrderBy(processor => processor.GetProcessingFee(amount))
            .First();
    }
}
```

### Client Usage Examples (5 minutes)

#### Basic Payment Service

```csharp
public class PaymentService
{
    public async Task<PaymentResult> ProcessPaymentAsync(decimal amount, PaymentType preferredType, string details = "")
    {
        try
        {
            // Use simple factory with availability checking
            var processor = PaymentProcessorFactory.CreateAvailableProcessor(preferredType);
            
            Console.WriteLine($"Processing ${amount:F2} via {processor.GetProviderName()}");
            Console.WriteLine($"Processing fee: ${processor.GetProcessingFee(amount):F2}");
            
            var result = await processor.ProcessAsync(amount, details);
            
            if (result.Success)
            {
                Console.WriteLine($"✅ Payment successful: {result.TransactionId}");
            }
            else
            {
                Console.WriteLine($"❌ Payment failed: {result.ErrorMessage}");
            }
            
            return result;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Payment processing error: {ex.Message}");
            return PaymentResult.CreateFailure(ex.Message);
        }
    }
    
    public async Task<PaymentResult> ProcessWithLowestFeesAsync(decimal amount, string details = "")
    {
        try
        {
            // Use factory to find processor with lowest fees
            var processor = PaymentProcessorFactory.CreateLowestFeeProcessor(amount);
            
            Console.WriteLine($"Selected lowest fee processor: {processor.GetProviderName()}");
            Console.WriteLine($"Fee: ${processor.GetProcessingFee(amount):F2}");
            
            return await processor.ProcessAsync(amount, details);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Could not process with lowest fees: {ex.Message}");
            return PaymentResult.CreateFailure(ex.Message);
        }
    }
}

// Usage demonstration
public class SimpleFactoryDemo
{
    public static async Task RunDemo()
    {
        Console.WriteLine("=== Simple Factory Pattern Demo ===\n");
        
        var paymentService = new PaymentService();
        
        // Test different payment types
        var testPayments = new[]
        {
            (100.00m, PaymentType.CreditCard),
            (2500.00m, PaymentType.PayPal),
            (50.00m, PaymentType.BankTransfer),
            (75.00m, PaymentType.Cryptocurrency) // Will fallback to available processor
        };
        
        foreach (var (amount, preferredType) in testPayments)
        {
            Console.WriteLine($"\n--- Processing {preferredType} payment for ${amount:F2} ---");
            await paymentService.ProcessPaymentAsync(amount, preferredType);
        }
        
        // Demonstrate lowest fee selection
        Console.WriteLine("\n--- Finding Lowest Fee Processor for $500 ---");
        await paymentService.ProcessWithLowestFeesAsync(500.00m);
        
        // Show supported payment types
        Console.WriteLine("\n--- Supported Payment Types ---");
        var supportedTypes = PaymentProcessorFactory.GetSupportedTypes();
        foreach (var type in supportedTypes)
        {
            var processor = PaymentProcessorFactory.CreateProcessor(type);
            Console.WriteLine($"✓ {type}: {processor.GetProviderName()} (Available: {processor.IsAvailable()})");
        }
    }
}
```

### Simple Factory Benefits & Trade-offs (2 minutes)

**Simple Factory Advantages**:

- **Centralized Creation Logic** - All object creation in one place for easy maintenance
- **Parameter-Based Selection** - Choose implementation based on runtime values
- **Reduced Client Coupling** - Clients don't need to know concrete classes
- **Easy Testing** - Mock factories for unit testing scenarios

**Simple Factory Limitations**:

- **Open/Closed Principle Violation** - Adding new types requires modifying factory
- **Static Dependencies** - Hard to inject dependencies into created objects
- **Limited Flexibility** - Cannot handle complex creation scenarios
- **Single Responsibility Concerns** - Factory knows about all concrete implementations

**When Simple Factory Works Best**:

- Small to medium number of concrete implementations (typically < 10)
- Creation logic is parameter-driven and relatively simple
- Implementations have similar construction requirements
- Centralized configuration and fallback logic are beneficial

**When to Consider Alternatives**:

- **Factory Method Pattern** - When subclasses should control object creation
- **Abstract Factory Pattern** - When creating families of related objects
- **Dependency Injection** - When objects need complex dependencies injected

**Next Learning Steps**:

- **Part B: Factory Method Pattern** - Subclass-controlled creation (Coming Soon)
- **Part C: Abstract Factory Pattern** - Object family creation (Coming Soon)

## 🔗 Related Topics

**Prerequisites**:

- [SOLID Principles](../02_SOLID-Principles/) - Foundation for loose coupling
- Basic inheritance and interface concepts
- Exception handling and error management

**Builds Upon**:

- Open/Closed Principle for extensible design
- Dependency Inversion for abstract dependencies
- Strategy Pattern for algorithm selection

**Enables**:

- Factory Method Pattern (Coming Soon) - Advanced factory scenarios
- Abstract Factory Pattern (Coming Soon) - Object family creation
- Dependency Injection Patterns (Coming Soon) - Modern object creation

**Next Patterns**:

- [Builder Pattern](07A_Design-Patterns-Part2A-Builder-Pattern-Fundamentals.md) - Complex object construction
- [Singleton Pattern](08A_Design-Patterns-Part3A-Singleton-Pattern-Fundamentals.md) - Instance management
