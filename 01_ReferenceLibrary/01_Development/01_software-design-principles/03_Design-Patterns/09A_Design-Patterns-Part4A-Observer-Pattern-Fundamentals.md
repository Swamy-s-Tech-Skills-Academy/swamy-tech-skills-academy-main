# 09A_Design-Patterns-Part4A-Observer-Pattern-Fundamentals

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Delegate and events concepts, Event-driven programming  
**Estimated Time**: Part A of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master the Observer Pattern for loose coupling between objects
- Understand the difference between tight coupling and event-driven design
- Implement basic observer patterns using C# events and delegates
- Design a stock price monitoring system with automatic notifications

## 📋 Content Sections (27-Minute Structure)

### Pattern Overview and Problem (5 minutes)

**Observer Pattern**: *"Define a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically."*

**Core Problem**: Objects need to be notified when another object's state changes, but without tight coupling.

```text
❌ TIGHT COUPLING PROBLEM
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Subject       │────│   Observer A    │    │   Observer B    │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ - Direct refs   │────│ - Tightly       │────│ - Hard to       │
│ - Hard to modify│    │   coupled       │    │   extend        │
│ - Fixed at      │────│ - Subject knows │────│ - Subject must  │
│   compile time  │    │   all observers │    │   know all deps │
└─────────────────┘    └─────────────────┘    └─────────────────┘

✅ OBSERVER PATTERN SOLUTION
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Subject      │    │   IObserver     │    │   Observer A    │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + Attach()      │◄───│ + Update()      │◄───│ + Update()      │
│ + Detach()      │    └─────────────────┘    ├─────────────────┤
│ + Notify()      │                           │ - Handle change │
│ - observers[]   │    ┌─────────────────┐    └─────────────────┘
└─────────────────┘    │   Observer B    │
         │              ├─────────────────┤
         └──────────────│ + Update()      │
                        ├─────────────────┤
                        │ - Handle change │
                        └─────────────────┘
```

**Real-World Applications**:

- **UI Components** - Model-View updates, form validation
- **Business Logic** - Order status changes, inventory updates
- **System Events** - File system monitoring, message queues
- **Distributed Systems** - Event sourcing, CQRS patterns

### Core Observer Implementation (15 minutes)

#### Stock Price Monitoring System

```csharp
// Event arguments for stock price changes
public class StockPriceChangedEventArgs : EventArgs
{
    public string Symbol { get; }
    public decimal OldPrice { get; }
    public decimal NewPrice { get; }
    public decimal ChangePercent { get; }
    public DateTime Timestamp { get; }

    public StockPriceChangedEventArgs(string symbol, decimal oldPrice, decimal newPrice)
    {
        Symbol = symbol ?? throw new ArgumentNullException(nameof(symbol));
        OldPrice = oldPrice;
        NewPrice = newPrice;
        ChangePercent = oldPrice != 0 ? ((newPrice - oldPrice) / oldPrice) * 100 : 0;
        Timestamp = DateTime.UtcNow;
    }
}

// Subject: Stock that can be observed
public class Stock
{
    private string _symbol;
    private decimal _price;
    private readonly object _priceLock = new object();

    public string Symbol
    {
        get => _symbol;
        private set => _symbol = value ?? throw new ArgumentNullException(nameof(value));
    }

    public decimal Price
    {
        get
        {
            lock (_priceLock)
            {
                return _price;
            }
        }
        set
        {
            decimal oldPrice;
            lock (_priceLock)
            {
                oldPrice = _price;
                if (Math.Abs(oldPrice - value) < 0.01m) // No significant change
                    return;

                _price = value;
            }

            // Notify observers outside of lock to prevent deadlocks
            OnPriceChanged(new StockPriceChangedEventArgs(_symbol, oldPrice, value));
        }
    }

    // Event declaration - C# event pattern
    public event EventHandler<StockPriceChangedEventArgs> PriceChanged;

    public Stock(string symbol, decimal initialPrice)
    {
        Symbol = symbol;
        _price = initialPrice;
    }

    // Protected virtual method for raising events (template pattern)
    protected virtual void OnPriceChanged(StockPriceChangedEventArgs e)
    {
        PriceChanged?.Invoke(this, e);
    }

    // Simulate price updates (for demo)
    public void UpdatePrice(decimal newPrice)
    {
        if (newPrice < 0)
            throw new ArgumentException("Price cannot be negative", nameof(newPrice));

        Price = newPrice;
    }

    public override string ToString()
    {
        return $"{Symbol}: ${Price:F2}";
    }
}
```

#### Portfolio Observer Implementation

```csharp
// Observer: Portfolio that tracks multiple stocks
public class Portfolio
{
    public string Name { get; }
    private readonly Dictionary<string, PortfolioHolding> _holdings;
    private readonly object _holdingsLock = new object();

    public Portfolio(string name)
    {
        Name = name ?? throw new ArgumentNullException(nameof(name));
        _holdings = new Dictionary<string, PortfolioHolding>();
    }

    public void AddStock(Stock stock, int shares)
    {
        if (stock == null) throw new ArgumentNullException(nameof(stock));
        if (shares <= 0) throw new ArgumentException("Shares must be positive", nameof(shares));

        lock (_holdingsLock)
        {
            if (_holdings.ContainsKey(stock.Symbol))
            {
                _holdings[stock.Symbol].Shares += shares;
            }
            else
            {
                _holdings[stock.Symbol] = new PortfolioHolding(stock, shares);
                // Subscribe to price changes - Observer pattern subscription
                stock.PriceChanged += OnStockPriceChanged;
            }
        }

        Console.WriteLine($"[{Name}] Added {shares} shares of {stock.Symbol} at ${stock.Price:F2}");
    }

    public void RemoveStock(string symbol)
    {
        if (string.IsNullOrEmpty(symbol))
            throw new ArgumentException("Symbol cannot be null or empty", nameof(symbol));

        lock (_holdingsLock)
        {
            if (_holdings.TryGetValue(symbol, out var holding))
            {
                // Unsubscribe from price changes - Observer pattern unsubscription
                holding.Stock.PriceChanged -= OnStockPriceChanged;
                _holdings.Remove(symbol);
                Console.WriteLine($"[{Name}] Removed {symbol} from portfolio");
            }
        }
    }

    // Event handler for stock price changes - Observer pattern notification
    private void OnStockPriceChanged(object sender, StockPriceChangedEventArgs e)
    {
        lock (_holdingsLock)
        {
            if (_holdings.TryGetValue(e.Symbol, out var holding))
            {
                var oldValue = holding.Shares * e.OldPrice;
                var newValue = holding.Shares * e.NewPrice;
                var changeAmount = newValue - oldValue;

                Console.WriteLine($"[{Name}] {e.Symbol} changed from ${e.OldPrice:F2} to ${e.NewPrice:F2} " +
                                $"({e.ChangePercent:+0.00;-0.00}%) - Portfolio impact: ${changeAmount:+0.00;-0.00}");

                // Alert on significant changes
                if (Math.Abs(e.ChangePercent) >= 5)
                {
                    Console.WriteLine($"[{Name}] ⚠️  ALERT: {e.Symbol} moved {e.ChangePercent:+0.00;-0.00}%!");
                }
            }
        }
    }

    public decimal GetTotalValue()
    {
        lock (_holdingsLock)
        {
            return _holdings.Values.Sum(h => h.Shares * h.Stock.Price);
        }
    }

    public void PrintPortfolio()
    {
        lock (_holdingsLock)
        {
            Console.WriteLine($"\n[{Name}] Portfolio Summary:");
            Console.WriteLine("Symbol".PadRight(8) + "Shares".PadRight(10) + "Price".PadRight(10) + "Value");
            Console.WriteLine(new string('-', 40));
            
            foreach (var holding in _holdings.Values)
            {
                var value = holding.Shares * holding.Stock.Price;
                Console.WriteLine($"{holding.Stock.Symbol.PadRight(8)}" +
                                $"{holding.Shares.ToString().PadRight(10)}" +
                                $"${holding.Stock.Price:F2}".PadRight(10) +
                                $"${value:F2}");
            }
            
            Console.WriteLine(new string('-', 40));
            Console.WriteLine($"Total Value: ${GetTotalValue():F2}\n");
        }
    }
}

// Supporting class for portfolio holdings
public class PortfolioHolding
{
    public Stock Stock { get; }
    public int Shares { get; set; }

    public PortfolioHolding(Stock stock, int shares)
    {
        Stock = stock ?? throw new ArgumentNullException(nameof(stock));
        Shares = shares;
    }
}
```

### Practical Usage Example (5 minutes)

```csharp
// Demo: Stock price monitoring with multiple observers
public class StockMarketDemo
{
    public static void RunDemo()
    {
        Console.WriteLine("=== Observer Pattern Demo - Stock Market ===\n");

        // Create stocks (subjects)
        var appleStock = new Stock("AAPL", 150.00m);
        var microsoftStock = new Stock("MSFT", 300.00m);
        var googleStock = new Stock("GOOGL", 2500.00m);

        // Create portfolios (observers)
        var conservativePortfolio = new Portfolio("Conservative Fund");
        var aggressivePortfolio = new Portfolio("Growth Fund");
        var dayTrader = new Portfolio("Day Trader");

        // Subscribe portfolios to stocks
        conservativePortfolio.AddStock(appleStock, 100);
        conservativePortfolio.AddStock(microsoftStock, 50);

        aggressivePortfolio.AddStock(appleStock, 200);
        aggressivePortfolio.AddStock(googleStock, 10);

        dayTrader.AddStock(appleStock, 500);
        dayTrader.AddStock(microsoftStock, 100);
        dayTrader.AddStock(googleStock, 5);

        // Show initial portfolio values
        conservativePortfolio.PrintPortfolio();
        aggressivePortfolio.PrintPortfolio();
        dayTrader.PrintPortfolio();

        Console.WriteLine("=== Simulating Market Changes ===\n");

        // Simulate market changes - observers automatically notified
        Console.WriteLine("Apple stock rises 3%:");
        appleStock.UpdatePrice(154.50m);

        Console.WriteLine("\nMicrosoft stock drops 7%:");
        microsoftStock.UpdatePrice(279.00m);

        Console.WriteLine("\nGoogle stock surges 8%:");
        googleStock.UpdatePrice(2700.00m);

        // Show final portfolio values
        Console.WriteLine("\n=== Final Portfolio Values ===");
        conservativePortfolio.PrintPortfolio();
        aggressivePortfolio.PrintPortfolio();
        dayTrader.PrintPortfolio();

        // Demonstrate unsubscription
        Console.WriteLine("Day trader exits Apple position:");
        dayTrader.RemoveStock("AAPL");

        Console.WriteLine("\nApple continues to move (day trader no longer notified):");
        appleStock.UpdatePrice(160.00m);
    }
}
```

### Key Takeaways & Observer Benefits (2 minutes)

**Observer Pattern Benefits**:

- **Loose Coupling** - Subjects don't need to know concrete observer types
- **Dynamic Subscription** - Observers can subscribe/unsubscribe at runtime
- **Broadcast Communication** - One event notifies multiple observers simultaneously
- **Separation of Concerns** - Business logic separated from notification logic

**C# Event System Advantages**:

- **Type Safety** - Strongly typed event arguments
- **Memory Management** - Automatic cleanup when references released
- **Thread Safety** - Event invocation is thread-safe by default
- **Null Safety** - Null-conditional operator prevents null reference exceptions

**Pattern Applications Demonstrated**:

- **Stock Market** - Price changes notify multiple portfolios
- **Thread-Safe Notifications** - Lock-based synchronization for concurrent access
- **Resource Management** - Proper subscription/unsubscription lifecycle
- **Event Arguments** - Rich event data with change calculations

**Next in Series**:

- **[Part B - UI Event Systems](09B_Design-Patterns-Part4B-Observer-Pattern-UI-Events.md)**
- **[Part C - Model Update Notifications](09C_Design-Patterns-Part4C-Observer-Pattern-Model-Updates.md)**  
- **[Part D - Enterprise Messaging Patterns](09D_Design-Patterns-Part4D-Observer-Pattern-Enterprise.md)**

## 🔗 Related Topics

**Prerequisites**:

- [Singleton Pattern](08A_Design-Patterns-Part3A-Singleton-Pattern-Fundamentals.md) for state management
- Delegate and event concepts in C#
- Thread-safety and synchronization

**Builds Upon**:

- Event-driven programming principles
- Publish-subscribe messaging patterns
- Loose coupling architectural principles

**Enables**:

- [Mediator Pattern](../behavioral-patterns/mediator/) for complex interactions
- [Command Pattern](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md) for event-driven commands
- [Strategy Pattern](10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals.md) for event handling strategies

**Next Patterns**:

- [Model-View-Controller](../../architectural-patterns/mvc/) for UI architecture
- [Event Sourcing](../../architectural-patterns/event-sourcing/) for system state management