# 10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals

**Learning Level**: Intermediate  
**Prerequisites**: Observer Pattern (Part 4), Polymorphism concepts  
**Estimated Time**: Part A of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master the Strategy Pattern for algorithm family encapsulation
- Understand how Strategy eliminates conditional complexity in business logic
- Design interchangeable behavior systems for payment processing
- Apply Strategy Pattern for runtime algorithm selection

## 📋 Content Sections (27-Minute Structure)

### Quick Overview (5 minutes)

**Strategy Pattern**: *"Define a family of algorithms, encapsulate each one, and make them interchangeable. Strategy lets the algorithm vary independently from clients that use it."*

**Core Problem**: Need to switch between different algorithms or behaviors at runtime without complex conditional statements or inheritance hierarchies.

```text
❌ CONDITIONAL COMPLEXITY PROBLEM
┌─────────────────────────────────────────┐
│           PaymentProcessor              │
├─────────────────────────────────────────┤
│ + ProcessPayment(type, amount)          │
│   {                                     │
│     if (type == "CreditCard")           │
│       // Credit card logic              │
│     else if (type == "PayPal")          │
│       // PayPal logic                   │
│     else if (type == "BankTransfer")    │
│       // Bank transfer logic            │
│     else if (type == "Cryptocurrency")  │
│       // Crypto logic                   │
│   }                                     │
└─────────────────────────────────────────┘
❌ Violates Open/Closed Principle, hard to extend, complex testing

✅ STRATEGY PATTERN SOLUTION
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Context     │    │   IStrategy     │    │CreditCardStrategy│
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ - strategy      │◄───│ + Execute()     │◄───│ + Execute()     │
│ + SetStrategy() │    └─────────────────┘    └─────────────────┘
│ + Execute()     │              ▲                       
└─────────────────┘              │              ┌─────────────────┐
                                 └──────────────│PayPalStrategy   │
                                                ├─────────────────┤
                                                │ + Execute()     │
                                                └─────────────────┘
✅ Open for extension, easy testing, clear separation of concerns
```

### Core Concepts (15 minutes)

**Real-World Applications**:

- **Payment Systems** - Credit card, PayPal, bank transfer, cryptocurrency strategies
- **Data Processing** - Different sorting, compression, encryption algorithms
- **Business Rules** - Pricing strategies, discount calculations, validation rules
- **UI Rendering** - Different themes, layouts, responsive strategies

#### Strategy Pattern Foundation

```csharp
// Strategy interface
public interface IPaymentStrategy
{
    string StrategyName { get; }
    decimal ProcessingFee { get; }
    TimeSpan EstimatedProcessingTime { get; }
    bool SupportsRefunds { get; }
    
    Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request, CancellationToken cancellationToken = default);
    Task<RefundResult> ProcessRefundAsync(RefundRequest request, CancellationToken cancellationToken = default);
}

// Payment request model
public class PaymentRequest
{
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "USD";
    public string Description { get; set; }
    public Dictionary<string, object> PaymentDetails { get; set; } = new();
    public string CustomerId { get; set; }
    public string OrderId { get; set; }
    
    public PaymentRequest(decimal amount, string customerId, string orderId, string description = null)
    {
        Amount = amount;
        CustomerId = customerId ?? throw new ArgumentNullException(nameof(customerId));
        OrderId = orderId ?? throw new ArgumentNullException(nameof(orderId));
        Description = description ?? $"Payment for order {orderId}";
    }
}

// Payment result
public class PaymentResult
{
    public bool IsSuccessful { get; }
    public string TransactionId { get; }
    public string Message { get; }
    public decimal ProcessingFee { get; }
    public DateTime ProcessedAt { get; }
    public Dictionary<string, object> Metadata { get; }

    public PaymentResult(bool isSuccessful, string transactionId, string message, 
                        decimal processingFee, Dictionary<string, object> metadata = null)
    {
        IsSuccessful = isSuccessful;
        TransactionId = transactionId ?? string.Empty;
        Message = message ?? string.Empty;
        ProcessingFee = processingFee;
        ProcessedAt = DateTime.UtcNow;
        Metadata = metadata ?? new Dictionary<string, object>();
    }

    public static PaymentResult Success(string transactionId, decimal processingFee, 
                                      string message = "Payment processed successfully", 
                                      Dictionary<string, object> metadata = null)
    {
        return new PaymentResult(true, transactionId, message, processingFee, metadata);
    }

    public static PaymentResult Failure(string message, decimal processingFee = 0, 
                                      Dictionary<string, object> metadata = null)
    {
        return new PaymentResult(false, string.Empty, message, processingFee, metadata);
    }
}

// Context class
public class PaymentProcessor
{
    private IPaymentStrategy _strategy;
    
    public string CurrentStrategy => _strategy?.StrategyName ?? "No strategy set";
    public decimal EstimatedFee => _strategy?.ProcessingFee ?? 0;

    public PaymentProcessor(IPaymentStrategy initialStrategy = null)
    {
        _strategy = initialStrategy;
    }

    public void SetStrategy(IPaymentStrategy strategy)
    {
        _strategy = strategy ?? throw new ArgumentNullException(nameof(strategy));
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request, 
                                                       CancellationToken cancellationToken = default)
    {
        if (_strategy == null)
            return PaymentResult.Failure("No payment strategy configured");

        if (request == null)
            return PaymentResult.Failure("Payment request cannot be null");

        if (request.Amount <= 0)
            return PaymentResult.Failure("Payment amount must be greater than zero");

        try
        {
            return await _strategy.ProcessPaymentAsync(request, cancellationToken);
        }
        catch (Exception ex)
        {
            return PaymentResult.Failure($"Payment processing failed: {ex.Message}");
        }
    }

    public async Task<RefundResult> ProcessRefundAsync(RefundRequest request, 
                                                     CancellationToken cancellationToken = default)
    {
        if (_strategy == null)
            throw new InvalidOperationException("No payment strategy configured");

        if (!_strategy.SupportsRefunds)
            throw new NotSupportedException($"Strategy '{_strategy.StrategyName}' does not support refunds");

        return await _strategy.ProcessRefundAsync(request, cancellationToken);
    }
}
```

### Pattern Components Deep Dive (5 minutes)

#### Key Components

1. **Strategy Interface** - Defines the contract for all concrete strategies
2. **Concrete Strategies** - Implement specific algorithms or behaviors
3. **Context** - Maintains reference to strategy and delegates work to it
4. **Client** - Configures context with appropriate strategy

#### Benefits Achieved

- **Open/Closed Principle** - Open for extension (new strategies), closed for modification
- **Single Responsibility** - Each strategy has one specific algorithm
- **Runtime Flexibility** - Change behavior without changing client code
- **Testability** - Easy to unit test individual strategies in isolation
- **Maintainability** - Clear separation of algorithm families

### Key Takeaways & Next Steps (2 minutes)

**Mastered in Part A**:

- Strategy Pattern eliminates conditional complexity through polymorphism
- Payment processing foundation with strategy interface and context
- Runtime algorithm selection without code modification
- Clear separation between algorithm families and their usage

**Next Steps**:

- **Part B**: E-Commerce Payment Strategies implementation (Credit Card, PayPal, Bank Transfer)
- **Part C**: Data Processing Strategies (Sorting algorithms, compression strategies)
- **Part D**: Business Rules Strategies (Pricing models, validation rules) + Key Takeaways

## 🔗 Related Topics

**Prerequisites**:

- **[Observer Pattern (Part 4)](09_Design-Patterns-Part4-Observer-Pattern.md)**
- [Polymorphism fundamentals](../../01_software-design-principles/)

**Builds Upon**:

- Interface design principles
- Open/Closed Principle
- Single Responsibility Principle

**Enables**:

- **[Part B - Payment Strategies](10B_Design-Patterns-Part5B-Strategy-Pattern-Payment-Systems.md)**
- [Algorithm family management](../../algorithm-patterns/)
- [Business rule engines](../../business-patterns/)

**Cross-References**:

- [State Pattern](../behavioral-patterns/) for state-dependent behavior
- [Command Pattern](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md) for action encapsulation
