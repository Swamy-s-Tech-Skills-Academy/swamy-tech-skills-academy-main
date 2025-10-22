# 02_SOLID-Part2-Open-Closed-Principle - Part A

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Single Responsibility Principle (Part 1), Basic inheritance and interfaces  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Open/Closed Principle (OCP) and its strategic importance

## Part A of 3

Next: [02_SOLID-Part2-Open-Closed-Principle-PartB.md](02_SOLID-Part2-Open-Closed-Principle-PartB.md)

---

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
```csharp
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
```csharp
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
            // Return the price of the cheapest item (free item)
            return categoryItems.First().Price;
        }
        
        return 0m;
    }
    
    public bool IsApplicable(Order order)
    {
        return order.Items.Count(i => i.Category.Equals(_category, StringComparison.OrdinalIgnoreCase)) >= 2;
    }
}

// Context class using strategies
public class DiscountEngine
{
    private readonly List<IDiscountStrategy> _availableStrategies;
    
    public DiscountEngine()
    {
        _availableStrategies = new List<IDiscountStrategy>();
    }
    
    public void RegisterStrategy(IDiscountStrategy strategy)
    {
        if (strategy == null)
            throw new ArgumentNullException(nameof(strategy));
            
        _availableStrategies.Add(strategy);
    }
    
    public void RemoveStrategy(IDiscountStrategy strategy)
    {
        _availableStrategies.Remove(strategy);
    }
    
    public DiscountResult CalculateBestDiscount(Order order)
    {
        if (order == null)
            throw new ArgumentNullException(nameof(order));
            
        var applicableStrategies = _availableStrategies
            .Where(s => s.IsApplicable(order))
            .ToList();
            
        if (!applicableStrategies.Any())
        {
            return new DiscountResult
            {
                DiscountAmount = 0m,
                StrategyUsed = "No applicable discounts",
                FinalTotal = order.Total
            };
        }
        
        var bestStrategy = applicableStrategies
            .OrderByDescending(s => s.CalculateDiscount(order))
            .First();
            
        var discountAmount = bestStrategy.CalculateDiscount(order);
        
        return new DiscountResult
        {
            DiscountAmount = discountAmount,
            StrategyUsed = bestStrategy.Name,
            FinalTotal = order.Total - discountAmount
        };
    }
    
    public List<string> GetAvailableDiscounts(Order order)
    {
        return _availableStrategies
            .Where(s => s.IsApplicable(order))
            .Select(s => s.Name)
            .ToList();
    }
}

public class DiscountResult
{
    public decimal DiscountAmount { get; set; }
    public string StrategyUsed { get; set; }
    public decimal FinalTotal { get; set; }
}
```csharp
### Practical Implementation (8 minutes)

#### Adding New Discount Types Without Modification

```csharp
// ✅ NEW: Seasonal discount strategy - added without modifying existing code
public class SeasonalDiscountStrategy : IDiscountStrategy
{
    private readonly decimal _percentage;
    private readonly DateTime _startDate;
    private readonly DateTime _endDate;
    private readonly string _season;
    
    public SeasonalDiscountStrategy(decimal percentage, DateTime startDate, DateTime endDate, string season)
    {
        _percentage = percentage;
        _startDate = startDate;
        _endDate = endDate;
        _season = season;
    }
    
    public string Name => $"{_season} Special - {_percentage * 100}% Off";
    
    public decimal CalculateDiscount(Order order)
    {
        return order.Total * _percentage;
    }
    
    public bool IsApplicable(Order order)
    {
        var now = DateTime.Now.Date;
        return now >= _startDate.Date && now <= _endDate.Date && order.Total > 0;
    }
}

// ✅ NEW: Customer loyalty discount - added without modifying existing code
public class LoyaltyDiscountStrategy : IDiscountStrategy
{
    private readonly int _requiredPoints;
    private readonly decimal _discountPerPoint;
    
    public LoyaltyDiscountStrategy(int requiredPoints, decimal discountPerPoint)
    {
        _requiredPoints = requiredPoints;
        _discountPerPoint = discountPerPoint;
    }
    
    public string Name => $"Loyalty Discount ({_requiredPoints}+ points)";
    
    public decimal CalculateDiscount(Order order)
    {
        if (order.Customer?.LoyaltyPoints >= _requiredPoints)
        {
            var pointsToUse = Math.Min(order.Customer.LoyaltyPoints, (int)(order.Total / _discountPerPoint));
            return pointsToUse * _discountPerPoint;
        }
        return 0m;
    }
    
    public bool IsApplicable(Order order)
    {
        return order.Customer?.LoyaltyPoints >= _requiredPoints;
    }
}

// Usage Example: Configuration without modifying core classes
public class DiscountConfiguration
{
    public static DiscountEngine CreateProductionEngine()
    {
        var engine = new DiscountEngine();
        
        // Standard discounts
        engine.RegisterStrategy(new PercentageDiscountStrategy(0.10m)); // 10% off
        engine.RegisterStrategy(new FixedAmountDiscountStrategy(25m));   // $25 off
        engine.RegisterStrategy(new BuyOneGetOneStrategy("Electronics"));
        
        // Seasonal promotions (can be added/removed without code changes)
        engine.RegisterStrategy(new SeasonalDiscountStrategy(
            0.20m, 
            new DateTime(2025, 11, 25), 
            new DateTime(2025, 11, 30), 
            "Black Friday"));
            
        engine.RegisterStrategy(new SeasonalDiscountStrategy(
            0.15m,
            new DateTime(2025, 12, 1),
            new DateTime(2025, 12, 31),
            "Holiday"));
        
        // Loyalty program
        engine.RegisterStrategy(new LoyaltyDiscountStrategy(100, 0.50m));
        
        return engine;
    }
}
```csharp
---

## ✅ Key Takeaways (2 minutes)

### **Open/Closed Principle Benefits Achieved**

✅ **Extension Without Modification**: New discount types added without changing existing code  
✅ **Reduced Risk**: No chance of breaking existing discount calculations  
✅ **Parallel Development**: Teams can develop new strategies independently  
✅ **Easy Testing**: Each strategy can be unit tested in isolation  
✅ **Configuration Flexibility**: Discount combinations can be changed at runtime  

### **Design Patterns Applied**

- **Strategy Pattern**: Encapsulates discount algorithms in interchangeable objects
- **Template Method**: Common interface with varied implementations
- **Factory Pattern**: Centralized configuration and registration of strategies
- **Composition**: Building complex discount engines from simple strategy objects

### **What's Next**

**Part B** will cover:

- Advanced OCP scenarios with inheritance hierarchies
- Plugin architectures and dynamic loading
- Framework extension points and hooks
- Performance considerations in extensible systems

---

## 🔗 Series Navigation

- **Current**: Part A - Strategy Pattern Foundation ✅
- **Next**: [02_SOLID-Part2-Open-Closed-Principle-PartB.md](02_SOLID-Part2-Open-Closed-Principle-PartB.md)
- **Series**: SOLID Principles Mastery Track

**Last Updated**: October 22, 2025  
**Format**: 30-minute focused learning segment
