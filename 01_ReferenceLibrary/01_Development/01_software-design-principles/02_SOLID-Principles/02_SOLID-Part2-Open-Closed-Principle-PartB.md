# 02_SOLID-Part2-Open-Closed-Principle - Part B

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Single Responsibility Principle (Part 1), Basic inheritance and interfaces  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Open/Closed Principle (OCP) and its strategic importance

## Part B of 3

Previous: [02_SOLID-Part2-Open-Closed-Principle-PartA.md](02_SOLID-Part2-Open-Closed-Principle-PartA.md)
Next: [02_SOLID-Part2-Open-Closed-Principle-PartC.md](02_SOLID-Part2-Open-Closed-Principle-PartC.md)

---

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
    private readonly List`IDiscountStrategy` _strategies;

    public DiscountCalculator(IEnumerable`IDiscountStrategy` strategies)
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

```text

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
        if (now >= _startDate && now `= _endDate)
        {
            return order.Total * _percentage;
        }
        return 0;
    }
    
    public bool IsApplicable(Order order)
    {
        var now = DateTime.Now.Date;
        return now `= _startDate && now `= _endDate && order.Total ` 0;
    }
}
```text

### Practical Implementation (8 minutes)

#### OCP Implementation Patterns

##### Pattern 1: Template Method Pattern

```csharp
// Abstract base class defines algorithm structure
public abstract class ReportGenerator
{
    public string GenerateReport(IEnumerable`Order` orders)
    {
        var processedData = ProcessData(orders);
        var formattedData = FormatData(processedData);
        return GenerateOutput(formattedData);
    }
    
    protected virtual object ProcessData(IEnumerable`Order` orders)
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

