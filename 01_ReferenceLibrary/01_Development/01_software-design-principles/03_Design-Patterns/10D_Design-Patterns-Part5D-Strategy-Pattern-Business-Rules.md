# 10D_Design-Patterns-Part5D-Strategy-Pattern-Business-Rules

**Learning Level**: Intermediate  
**Prerequisites**: Strategy Pattern Data Processing (Part C), Business logic concepts  
**Estimated Time**: Part D of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement business rule strategies for pricing and validation systems
- Design flexible discount and promotion strategy families
- Apply Strategy Pattern to complex business logic scenarios
- Master the complete Strategy Pattern for enterprise applications

## 📋 Content Sections (27-Minute Structure)

### Business Rules Strategy Foundation (5 minutes)

```csharp
// Business rule strategy interface
public interface IBusinessRuleStrategy<TInput, TOutput>
{
    string RuleName { get; }
    string Description { get; }
    int Priority { get; }
    bool IsApplicable(TInput input);
    
    Task<BusinessRuleResult<TOutput>> ApplyRuleAsync(TInput input, CancellationToken cancellationToken = default);
}

// Business rule result
public class BusinessRuleResult<T>
{
    public bool IsSuccessful { get; }
    public T Result { get; }
    public string Message { get; }
    public decimal Impact { get; }
    public Dictionary<string, object> RuleData { get; }

    public BusinessRuleResult(bool isSuccessful, T result, string message, decimal impact = 0, 
                            Dictionary<string, object> ruleData = null)
    {
        IsSuccessful = isSuccessful;
        Result = result;
        Message = message ?? string.Empty;
        Impact = impact;
        RuleData = ruleData ?? new Dictionary<string, object>();
    }

    public static BusinessRuleResult<T> Success(T result, string message, decimal impact = 0, 
                                              Dictionary<string, object> ruleData = null)
    {
        return new BusinessRuleResult<T>(true, result, message, impact, ruleData);
    }

    public static BusinessRuleResult<T> Failure(string message, decimal impact = 0)
    {
        return new BusinessRuleResult<T>(false, default(T), message, impact);
    }
}
```

### Pricing Strategy Implementations (15 minutes)

#### Regular Pricing Strategy

```csharp
public class RegularPricingStrategy : IBusinessRuleStrategy<PricingRequest, decimal>
{
    public string RuleName => "Regular Pricing";
    public string Description => "Standard pricing without any discounts or modifications";
    public int Priority => 0; // Lowest priority (fallback)

    public bool IsApplicable(PricingRequest input)
    {
        // Regular pricing is always applicable as fallback
        return input != null && input.BasePrice > 0;
    }

    public async Task<BusinessRuleResult<decimal>> ApplyRuleAsync(PricingRequest input, 
                                                                CancellationToken cancellationToken = default)
    {
        if (!IsApplicable(input))
            return BusinessRuleResult<decimal>.Failure("Invalid pricing request");

        await Task.Delay(10, cancellationToken); // Simulate async processing

        var ruleData = new Dictionary<string, object>
        {
            { "BasePrice", input.BasePrice },
            { "AppliedDiscounts", "None" },
            { "PricingTier", "Standard" }
        };

        return BusinessRuleResult<decimal>.Success(input.BasePrice, 
            "Regular pricing applied", 0, ruleData);
    }
}

// Pricing request model
public class PricingRequest
{
    public decimal BasePrice { get; set; }
    public string CustomerId { get; set; }
    public string ProductId { get; set; }
    public int Quantity { get; set; }
    public CustomerTier CustomerTier { get; set; }
    public DateTime PurchaseDate { get; set; }
    public List<string> ApplicableCoupons { get; set; } = new();
    public bool IsFirstTimePurchase { get; set; }
    public decimal CustomerLifetimeValue { get; set; }

    public PricingRequest(decimal basePrice, string customerId, string productId, int quantity = 1)
    {
        BasePrice = basePrice;
        CustomerId = customerId ?? throw new ArgumentNullException(nameof(customerId));
        ProductId = productId ?? throw new ArgumentNullException(nameof(productId));
        Quantity = quantity;
        PurchaseDate = DateTime.UtcNow;
    }
}

public enum CustomerTier
{
    Standard,
    Silver,
    Gold,
    Platinum
}
```

#### Volume Discount Strategy

```csharp
public class VolumeDiscountStrategy : IBusinessRuleStrategy<PricingRequest, decimal>
{
    public string RuleName => "Volume Discount";
    public string Description => "Discounts based on quantity purchased";
    public int Priority => 50;

    private readonly Dictionary<int, decimal> _volumeDiscounts = new()
    {
        { 10, 0.05m },   // 5% for 10+ items
        { 25, 0.10m },   // 10% for 25+ items
        { 50, 0.15m },   // 15% for 50+ items
        { 100, 0.20m }   // 20% for 100+ items
    };

    public bool IsApplicable(PricingRequest input)
    {
        return input != null && input.Quantity >= 10;
    }

    public async Task<BusinessRuleResult<decimal>> ApplyRuleAsync(PricingRequest input, 
                                                                CancellationToken cancellationToken = default)
    {
        if (!IsApplicable(input))
            return BusinessRuleResult<decimal>.Failure("Volume discount not applicable");

        await Task.Delay(15, cancellationToken);

        var applicableDiscount = _volumeDiscounts
            .Where(kvp => input.Quantity >= kvp.Key)
            .OrderByDescending(kvp => kvp.Key)
            .FirstOrDefault();

        if (applicableDiscount.Key == 0)
            return BusinessRuleResult<decimal>.Failure("No volume discount tier matched");

        var discountAmount = input.BasePrice * input.Quantity * applicableDiscount.Value;
        var finalPrice = (input.BasePrice * input.Quantity) - discountAmount;

        var ruleData = new Dictionary<string, object>
        {
            { "DiscountPercentage", applicableDiscount.Value * 100 },
            { "DiscountAmount", discountAmount },
            { "QuantityThreshold", applicableDiscount.Key },
            { "TotalBeforeDiscount", input.BasePrice * input.Quantity }
        };

        return BusinessRuleResult<decimal>.Success(finalPrice, 
            $"Volume discount of {applicableDiscount.Value:P0} applied for {input.Quantity} items", 
            discountAmount, ruleData);
    }
}
```

#### Loyalty Tier Strategy

```csharp
public class LoyaltyTierStrategy : IBusinessRuleStrategy<PricingRequest, decimal>
{
    public string RuleName => "Loyalty Tier Discount";
    public string Description => "Discounts based on customer loyalty tier";
    public int Priority => 75;

    private readonly Dictionary<CustomerTier, decimal> _tierDiscounts = new()
    {
        { CustomerTier.Silver, 0.05m },    // 5%
        { CustomerTier.Gold, 0.10m },      // 10%
        { CustomerTier.Platinum, 0.15m }   // 15%
    };

    public bool IsApplicable(PricingRequest input)
    {
        return input != null && input.CustomerTier != CustomerTier.Standard;
    }

    public async Task<BusinessRuleResult<decimal>> ApplyRuleAsync(PricingRequest input, 
                                                                CancellationToken cancellationToken = default)
    {
        if (!IsApplicable(input))
            return BusinessRuleResult<decimal>.Failure("Loyalty tier discount not applicable");

        await Task.Delay(10, cancellationToken);

        if (!_tierDiscounts.TryGetValue(input.CustomerTier, out var discountRate))
            return BusinessRuleResult<decimal>.Failure($"No discount configured for tier {input.CustomerTier}");

        var baseAmount = input.BasePrice * input.Quantity;
        var discountAmount = baseAmount * discountRate;
        var finalPrice = baseAmount - discountAmount;

        var ruleData = new Dictionary<string, object>
        {
            { "CustomerTier", input.CustomerTier.ToString() },
            { "DiscountPercentage", discountRate * 100 },
            { "DiscountAmount", discountAmount },
            { "CustomerLifetimeValue", input.CustomerLifetimeValue }
        };

        return BusinessRuleResult<decimal>.Success(finalPrice,
            $"Loyalty tier discount of {discountRate:P0} applied for {input.CustomerTier} customer",
            discountAmount, ruleData);
    }
}
```

#### First-Time Customer Strategy

```csharp
public class FirstTimeCustomerStrategy : IBusinessRuleStrategy<PricingRequest, decimal>
{
    public string RuleName => "First-Time Customer Discount";
    public string Description => "Welcome discount for new customers";
    public int Priority => 60;

    private const decimal FIRST_TIME_DISCOUNT = 0.15m; // 15%
    private const decimal MAX_DISCOUNT_AMOUNT = 50.00m;

    public bool IsApplicable(PricingRequest input)
    {
        return input != null && input.IsFirstTimePurchase;
    }

    public async Task<BusinessRuleResult<decimal>> ApplyRuleAsync(PricingRequest input, 
                                                                CancellationToken cancellationToken = default)
    {
        if (!IsApplicable(input))
            return BusinessRuleResult<decimal>.Failure("First-time customer discount not applicable");

        await Task.Delay(12, cancellationToken);

        var baseAmount = input.BasePrice * input.Quantity;
        var calculatedDiscount = baseAmount * FIRST_TIME_DISCOUNT;
        var actualDiscount = Math.Min(calculatedDiscount, MAX_DISCOUNT_AMOUNT);
        var finalPrice = baseAmount - actualDiscount;

        var ruleData = new Dictionary<string, object>
        {
            { "DiscountPercentage", FIRST_TIME_DISCOUNT * 100 },
            { "CalculatedDiscount", calculatedDiscount },
            { "ActualDiscount", actualDiscount },
            { "MaxDiscountCap", MAX_DISCOUNT_AMOUNT },
            { "WelcomeBonus", true }
        };

        return BusinessRuleResult<decimal>.Success(finalPrice,
            $"First-time customer discount of ${actualDiscount:F2} applied",
            actualDiscount, ruleData);
    }
}
```

### Business Rules Engine (5 minutes)

```csharp
public class PricingEngine
{
    private readonly List<IBusinessRuleStrategy<PricingRequest, decimal>> _strategies;

    public PricingEngine()
    {
        _strategies = new List<IBusinessRuleStrategy<PricingRequest, decimal>>
        {
            new RegularPricingStrategy(),
            new VolumeDiscountStrategy(),
            new LoyaltyTierStrategy(),
            new FirstTimeCustomerStrategy()
        };
    }

    public async Task<PricingEngineResult> CalculatePriceAsync(PricingRequest request, 
                                                             CancellationToken cancellationToken = default)
    {
        if (request == null)
            return PricingEngineResult.Failure("Pricing request cannot be null");

        var applicableStrategies = _strategies
            .Where(s => s.IsApplicable(request))
            .OrderByDescending(s => s.Priority)
            .ToList();

        if (!applicableStrategies.Any())
            return PricingEngineResult.Failure("No applicable pricing strategies found");

        var results = new List<BusinessRuleResult<decimal>>();
        var baseAmount = request.BasePrice * request.Quantity;
        var currentPrice = baseAmount;

        foreach (var strategy in applicableStrategies)
        {
            var result = await strategy.ApplyRuleAsync(request, cancellationToken);
            
            if (result.IsSuccessful)
            {
                results.Add(result);
                currentPrice = result.Result;
                
                // Update request for next strategy to build upon this result
                var tempRequest = new PricingRequest(currentPrice / request.Quantity, 
                                                   request.CustomerId, request.ProductId, request.Quantity)
                {
                    CustomerTier = request.CustomerTier,
                    IsFirstTimePurchase = request.IsFirstTimePurchase,
                    CustomerLifetimeValue = request.CustomerLifetimeValue,
                    PurchaseDate = request.PurchaseDate
                };
                request = tempRequest;
            }
        }

        var totalSavings = baseAmount - currentPrice;

        return PricingEngineResult.Success(currentPrice, totalSavings, results);
    }
}

public class PricingEngineResult
{
    public bool IsSuccessful { get; }
    public decimal FinalPrice { get; }
    public decimal TotalSavings { get; }
    public List<BusinessRuleResult<decimal>> AppliedRules { get; }
    public string Message { get; }

    public PricingEngineResult(bool isSuccessful, decimal finalPrice, decimal totalSavings, 
                             List<BusinessRuleResult<decimal>> appliedRules, string message)
    {
        IsSuccessful = isSuccessful;
        FinalPrice = finalPrice;
        TotalSavings = totalSavings;
        AppliedRules = appliedRules ?? new List<BusinessRuleResult<decimal>>();
        Message = message ?? string.Empty;
    }

    public static PricingEngineResult Success(decimal finalPrice, decimal totalSavings, 
                                            List<BusinessRuleResult<decimal>> appliedRules)
    {
        return new PricingEngineResult(true, finalPrice, totalSavings, appliedRules, "Pricing calculated successfully");
    }

    public static PricingEngineResult Failure(string message)
    {
        return new PricingEngineResult(false, 0, 0, null, message);
    }
}
```

### Key Takeaways & Pattern Summary (2 minutes)

**Strategy Pattern Mastery Achieved (Parts A-D)**:

- **Payment Processing** - Runtime algorithm selection for different payment methods
- **Data Processing** - Performance-optimized algorithm strategies based on data characteristics  
- **Business Rules** - Flexible pricing and validation rule engines
- **Enterprise Applications** - Scalable strategy families for complex business logic

**Pattern Benefits Realized**:

- **Eliminates Conditional Complexity** - No more complex if/else chains
- **Open/Closed Principle** - Easy to add new strategies without modifying existing code
- **Runtime Flexibility** - Change behavior based on context without recompilation
- **Testability** - Individual strategies can be unit tested in isolation
- **Maintainability** - Clear separation of algorithm families and responsibilities

**Real-World Applications Demonstrated**:

- E-commerce pricing engines with multiple discount strategies
- Payment processing systems with different gateway strategies
- Data processing pipelines with algorithm selection based on input characteristics
- Business rule engines for complex enterprise applications

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Strategy Fundamentals](10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals.md)**
- **[Part B - Payment Systems](10B_Design-Patterns-Part5B-Strategy-Pattern-Payment-Systems.md)**
- **[Part C - Data Processing](10C_Design-Patterns-Part5C-Strategy-Pattern-Data-Processing.md)**

**Builds Upon**:

- Business logic separation principles
- Rule engine architectures
- Enterprise application patterns

**Enables**:

- [Decorator Pattern](11A_Design-Patterns-Part6A-Decorator-Pattern-Fundamentals.md) for behavior enhancement
- [Command Pattern](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md) for action encapsulation
- [Enterprise rule engines](../../business-patterns/rule-engines/)

**Next Patterns**:

- [State Pattern](../behavioral-patterns/state/) for state-dependent behavior
- [Template Method](../behavioral-patterns/template-method/) for algorithm skeletons
- [Chain of Responsibility](../behavioral-patterns/chain-of-responsibility/) for request handling