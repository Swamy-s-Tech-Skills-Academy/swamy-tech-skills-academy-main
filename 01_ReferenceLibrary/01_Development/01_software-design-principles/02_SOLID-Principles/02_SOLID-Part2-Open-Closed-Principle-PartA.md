# 02_SOLID-Part2-Open-Closed-Principle - Part A

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Single Responsibility Principle (Part 1), Basic inheritance and interfaces  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Open/Closed Principle (OCP) and its strategic importance

**Part A of 3**

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

