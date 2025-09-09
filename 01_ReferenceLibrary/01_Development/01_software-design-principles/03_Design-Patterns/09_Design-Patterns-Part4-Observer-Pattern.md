# 09_Design-Patterns-Part4-Observer-Pattern

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Singleton Pattern (Part 3), Event-driven programming concepts  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Observer Pattern for loose coupling between objects
- Implement event-driven architectures using delegates and events in C#
- Design reactive systems with automatic change notification
- Apply Observer patterns in UI, business logic, and distributed systems

## 📋 Content Sections

### Quick Overview (5 minutes)

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

### Core Concepts (15 minutes)

#### Event-Driven Architecture with C# Events

**Implementation 1: Stock Price Monitoring System**

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

            // Notify observers outside of lock
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

    // Protected virtual method for raising events
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
                // Subscribe to price changes
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
                // Unsubscribe from price changes
                holding.Stock.PriceChanged -= OnStockPriceChanged;
                _holdings.Remove(symbol);
                Console.WriteLine($"[{Name}] Removed {symbol} from portfolio");
            }
        }
    }

    // Event handler for stock price changes
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

    public void PrintSummary()
    {
        lock (_holdingsLock)
        {
            Console.WriteLine($"\n=== {Name} Portfolio Summary ===");
            foreach (var holding in _holdings.Values)
            {
                var value = holding.Shares * holding.Stock.Price;
                Console.WriteLine($"{holding.Stock.Symbol}: {holding.Shares} shares @ ${holding.Stock.Price:F2} = ${value:F2}");
            }
            Console.WriteLine($"Total Portfolio Value: ${GetTotalValue():F2}\n");
        }
    }

    private class PortfolioHolding
    {
        public Stock Stock { get; }
        public int Shares { get; set; }

        public PortfolioHolding(Stock stock, int shares)
        {
            Stock = stock;
            Shares = shares;
        }
    }
}

// Observer: Alert system for notifications
public class StockAlertSystem
{
    public string Name { get; }
    private readonly Dictionary<string, AlertRule> _alertRules;

    public StockAlertSystem(string name)
    {
        Name = name ?? throw new ArgumentNullException(nameof(name));
        _alertRules = new Dictionary<string, AlertRule>();
    }

    public void SubscribeToStock(Stock stock)
    {
        if (stock == null) throw new ArgumentNullException(nameof(stock));

        stock.PriceChanged += OnStockPriceChanged;
        Console.WriteLine($"[{Name}] Now monitoring {stock.Symbol}");
    }

    public void UnsubscribeFromStock(Stock stock)
    {
        if (stock == null) return;

        stock.PriceChanged -= OnStockPriceChanged;
        Console.WriteLine($"[{Name}] Stopped monitoring {stock.Symbol}");
    }

    public void SetPriceAlert(string symbol, decimal targetPrice, AlertType alertType)
    {
        if (string.IsNullOrEmpty(symbol))
            throw new ArgumentException("Symbol cannot be null or empty", nameof(symbol));

        _alertRules[symbol] = new AlertRule(targetPrice, alertType);
        Console.WriteLine($"[{Name}] Alert set for {symbol}: {alertType} ${targetPrice:F2}");
    }

    private void OnStockPriceChanged(object sender, StockPriceChangedEventArgs e)
    {
        // Check for alerts
        if (_alertRules.TryGetValue(e.Symbol, out var rule))
        {
            var triggered = rule.AlertType switch
            {
                AlertType.Above => e.NewPrice >= rule.TargetPrice && e.OldPrice < rule.TargetPrice,
                AlertType.Below => e.NewPrice <= rule.TargetPrice && e.OldPrice > rule.TargetPrice,
                AlertType.AtOrAbove => e.NewPrice >= rule.TargetPrice,
                AlertType.AtOrBelow => e.NewPrice <= rule.TargetPrice,
                _ => false
            };

            if (triggered)
            {
                Console.WriteLine($"[{Name}] 🚨 ALERT TRIGGERED: {e.Symbol} is {rule.AlertType} ${rule.TargetPrice:F2} " +
                                $"(Current: ${e.NewPrice:F2})");
            }
        }

        // Log all significant moves
        if (Math.Abs(e.ChangePercent) >= 2)
        {
            var direction = e.ChangePercent > 0 ? "↗️" : "↘️";
            Console.WriteLine($"[{Name}] {direction} {e.Symbol} moved {e.ChangePercent:+0.00;-0.00}% " +
                            $"to ${e.NewPrice:F2}");
        }
    }

    private class AlertRule
    {
        public decimal TargetPrice { get; }
        public AlertType AlertType { get; }

        public AlertRule(decimal targetPrice, AlertType alertType)
        {
            TargetPrice = targetPrice;
            AlertType = alertType;
        }
    }
}

public enum AlertType
{
    Above,
    Below,
    AtOrAbove,
    AtOrBelow
}
```

**Usage Example**

```csharp
public class ObserverPatternExample
{
    public void DemonstrateStockMonitoring()
    {
        // Create stocks
        var apple = new Stock("AAPL", 150.00m);
        var microsoft = new Stock("MSFT", 300.00m);
        var tesla = new Stock("TSLA", 250.00m);

        // Create observers
        var myPortfolio = new Portfolio("My Investment Portfolio");
        var alertSystem = new StockAlertSystem("Price Alert System");

        // Subscribe to stocks
        myPortfolio.AddStock(apple, 100);
        myPortfolio.AddStock(microsoft, 50);
        myPortfolio.AddStock(tesla, 25);

        alertSystem.SubscribeToStock(apple);
        alertSystem.SubscribeToStock(microsoft);
        alertSystem.SubscribeToStock(tesla);

        // Set price alerts
        alertSystem.SetPriceAlert("AAPL", 160.00m, AlertType.Above);
        alertSystem.SetPriceAlert("MSFT", 290.00m, AlertType.Below);
        alertSystem.SetPriceAlert("TSLA", 300.00m, AlertType.AtOrAbove);

        // Show initial portfolio
        myPortfolio.PrintSummary();

        // Simulate price changes
        Console.WriteLine("=== Simulating Market Activity ===");

        apple.UpdatePrice(155.50m);   // +3.67% increase
        microsoft.UpdatePrice(285.00m); // -5% decrease (triggers alert)
        tesla.UpdatePrice(262.50m);   // +5% increase

        apple.UpdatePrice(165.00m);   // +6.13% increase (triggers alert)
        microsoft.UpdatePrice(295.00m); // +3.51% recovery
        tesla.UpdatePrice(305.00m);   // +22% total increase (triggers alert)

        // Final portfolio summary
        myPortfolio.PrintSummary();

        // Clean up subscriptions
        Console.WriteLine("=== Cleaning Up Subscriptions ===");
        myPortfolio.RemoveStock("TSLA");
        alertSystem.UnsubscribeFromStock(apple);
    }
}
```

#### Generic Observer Pattern Implementation

**Implementation 2: Generic Event System**

```csharp
// Generic observer interface
public interface IObserver<T>
{
    void OnNext(T value);
    void OnError(Exception error);
    void OnCompleted();
}

// Generic subject interface
public interface IObservable<T>
{
    IDisposable Subscribe(IObserver<T> observer);
}

// Generic subject implementation
public class Subject<T> : IObservable<T>
{
    private readonly List<IObserver<T>> _observers = new List<IObserver<T>>();
    private readonly object _lock = new object();
    private bool _isCompleted = false;

    public IDisposable Subscribe(IObserver<T> observer)
    {
        if (observer == null) throw new ArgumentNullException(nameof(observer));

        lock (_lock)
        {
            if (_isCompleted)
            {
                observer.OnCompleted();
                return new DisposableAction(() => { }); // No-op disposal
            }

            _observers.Add(observer);
            return new DisposableAction(() => Unsubscribe(observer));
        }
    }

    public void OnNext(T value)
    {
        List<IObserver<T>> currentObservers;

        lock (_lock)
        {
            if (_isCompleted) return;
            currentObservers = new List<IObserver<T>>(_observers);
        }

        // Notify observers outside of lock to prevent deadlocks
        foreach (var observer in currentObservers)
        {
            try
            {
                observer.OnNext(value);
            }
            catch (Exception ex)
            {
                // Notify observer of error, but continue with other observers
                try
                {
                    observer.OnError(ex);
                }
                catch
                {
                    // Observer's error handler failed - remove it
                    Unsubscribe(observer);
                }
            }
        }
    }

    public void OnError(Exception error)
    {
        List<IObserver<T>> currentObservers;

        lock (_lock)
        {
            if (_isCompleted) return;
            currentObservers = new List<IObserver<T>>(_observers);
            _observers.Clear();
            _isCompleted = true;
        }

        foreach (var observer in currentObservers)
        {
            try
            {
                observer.OnError(error);
            }
            catch
            {
                // Ignore errors in error handlers
            }
        }
    }

    public void OnCompleted()
    {
        List<IObserver<T>> currentObservers;

        lock (_lock)
        {
            if (_isCompleted) return;
            currentObservers = new List<IObserver<T>>(_observers);
            _observers.Clear();
            _isCompleted = true;
        }

        foreach (var observer in currentObservers)
        {
            try
            {
                observer.OnCompleted();
            }
            catch
            {
                // Ignore errors in completion handlers
            }
        }
    }

    private void Unsubscribe(IObserver<T> observer)
    {
        lock (_lock)
        {
            _observers.Remove(observer);
        }
    }

    public int ObserverCount
    {
        get
        {
            lock (_lock)
            {
                return _observers.Count;
            }
        }
    }
}

// Helper class for disposable actions
public class DisposableAction : IDisposable
{
    private readonly Action _action;
    private bool _disposed = false;

    public DisposableAction(Action action)
    {
        _action = action ?? throw new ArgumentNullException(nameof(action));
    }

    public void Dispose()
    {
        if (!_disposed)
        {
            _action();
            _disposed = true;
        }
    }
}

// Concrete observer implementations
public class LoggingObserver<T> : IObserver<T>
{
    private readonly string _name;

    public LoggingObserver(string name)
    {
        _name = name ?? throw new ArgumentNullException(nameof(name));
    }

    public void OnNext(T value)
    {
        Console.WriteLine($"[{_name}] Received: {value}");
    }

    public void OnError(Exception error)
    {
        Console.WriteLine($"[{_name}] Error: {error.Message}");
    }

    public void OnCompleted()
    {
        Console.WriteLine($"[{_name}] Completed");
    }
}

public class FilteringObserver<T> : IObserver<T> where T : IComparable<T>
{
    private readonly string _name;
    private readonly Func<T, bool> _filter;

    public FilteringObserver(string name, Func<T, bool> filter)
    {
        _name = name ?? throw new ArgumentNullException(nameof(name));
        _filter = filter ?? throw new ArgumentNullException(nameof(filter));
    }

    public void OnNext(T value)
    {
        if (_filter(value))
        {
            Console.WriteLine($"[{_name}] Filtered value: {value}");
        }
    }

    public void OnError(Exception error)
    {
        Console.WriteLine($"[{_name}] Error in filtering: {error.Message}");
    }

    public void OnCompleted()
    {
        Console.WriteLine($"[{_name}] Filtering completed");
    }
}

// Usage example for generic observer
public class GenericObserverExample
{
    public void DemonstrateGenericObserver()
    {
        var subject = new Subject<int>();

        // Create observers
        var logger = new LoggingObserver<int>("Logger");
        var evenFilter = new FilteringObserver<int>("EvenFilter", x => x % 2 == 0);
        var largeFilter = new FilteringObserver<int>("LargeFilter", x => x > 50);

        // Subscribe observers
        using var subscription1 = subject.Subscribe(logger);
        using var subscription2 = subject.Subscribe(evenFilter);
        using var subscription3 = subject.Subscribe(largeFilter);

        Console.WriteLine($"Observer count: {subject.ObserverCount}");

        // Publish values
        Console.WriteLine("\n=== Publishing Values ===");
        subject.OnNext(10);  // Even, not large
        subject.OnNext(25);  // Odd, not large
        subject.OnNext(60);  // Even, large
        subject.OnNext(75);  // Odd, large

        // Demonstrate error handling
        Console.WriteLine("\n=== Error Handling ===");
        subject.OnError(new InvalidOperationException("Test error"));

        // Subscriptions are automatically disposed at end of using blocks
    }
}
```

### Practical Implementation (8 minutes)

#### Event-Driven UI Updates

**Implementation 3: Model-View Observer Pattern**

```csharp
// Model with observable properties
public class UserAccount
{
    private string _username;
    private decimal _balance;
    private readonly object _lock = new object();

    public event EventHandler<PropertyChangedEventArgs> PropertyChanged;
    public event EventHandler<BalanceChangedEventArgs> BalanceChanged;
    public event EventHandler<AccountEventArgs> AccountLocked;

    public string Username
    {
        get
        {
            lock (_lock) { return _username; }
        }
        set
        {
            lock (_lock)
            {
                if (_username != value)
                {
                    _username = value;
                    OnPropertyChanged(nameof(Username));
                }
            }
        }
    }

    public decimal Balance
    {
        get
        {
            lock (_lock) { return _balance; }
        }
        private set
        {
            decimal oldBalance;
            lock (_lock)
            {
                oldBalance = _balance;
                if (_balance != value)
                {
                    _balance = value;
                    OnPropertyChanged(nameof(Balance));
                }
            }

            if (oldBalance != value)
            {
                OnBalanceChanged(new BalanceChangedEventArgs(oldBalance, value));
            }
        }
    }

    public bool IsLocked { get; private set; }

    public UserAccount(string username, decimal initialBalance)
    {
        Username = username;
        Balance = initialBalance;
    }

    public bool Deposit(decimal amount)
    {
        if (IsLocked) return false;
        if (amount <= 0) throw new ArgumentException("Deposit amount must be positive");

        Balance += amount;
        return true;
    }

    public bool Withdraw(decimal amount)
    {
        if (IsLocked) return false;
        if (amount <= 0) throw new ArgumentException("Withdrawal amount must be positive");

        lock (_lock)
        {
            if (_balance >= amount)
            {
                Balance -= amount;
                return true;
            }
        }

        return false; // Insufficient funds
    }

    public void LockAccount(string reason)
    {
        if (!IsLocked)
        {
            IsLocked = true;
            OnPropertyChanged(nameof(IsLocked));
            OnAccountLocked(new AccountEventArgs(reason));
        }
    }

    protected virtual void OnPropertyChanged(string propertyName)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

    protected virtual void OnBalanceChanged(BalanceChangedEventArgs e)
    {
        BalanceChanged?.Invoke(this, e);
    }

    protected virtual void OnAccountLocked(AccountEventArgs e)
    {
        AccountLocked?.Invoke(this, e);
    }
}

// Event argument classes
public class PropertyChangedEventArgs : EventArgs
{
    public string PropertyName { get; }

    public PropertyChangedEventArgs(string propertyName)
    {
        PropertyName = propertyName;
    }
}

public class BalanceChangedEventArgs : EventArgs
{
    public decimal OldBalance { get; }
    public decimal NewBalance { get; }
    public decimal Change => NewBalance - OldBalance;

    public BalanceChangedEventArgs(decimal oldBalance, decimal newBalance)
    {
        OldBalance = oldBalance;
        NewBalance = newBalance;
    }
}

public class AccountEventArgs : EventArgs
{
    public string Reason { get; }
    public DateTime Timestamp { get; }

    public AccountEventArgs(string reason)
    {
        Reason = reason;
        Timestamp = DateTime.UtcNow;
    }
}

// View observers
public class AccountDisplayView
{
    private readonly string _viewName;

    public AccountDisplayView(string viewName)
    {
        _viewName = viewName;
    }

    public void AttachToAccount(UserAccount account)
    {
        account.PropertyChanged += OnPropertyChanged;
        account.BalanceChanged += OnBalanceChanged;
        account.AccountLocked += OnAccountLocked;
    }

    public void DetachFromAccount(UserAccount account)
    {
        account.PropertyChanged -= OnPropertyChanged;
        account.BalanceChanged -= OnBalanceChanged;
        account.AccountLocked -= OnAccountLocked;
    }

    private void OnPropertyChanged(object sender, PropertyChangedEventArgs e)
    {
        var account = (UserAccount)sender;
        Console.WriteLine($"[{_viewName}] Property '{e.PropertyName}' changed for {account.Username}");
    }

    private void OnBalanceChanged(object sender, BalanceChangedEventArgs e)
    {
        var account = (UserAccount)sender;
        var changeType = e.Change > 0 ? "Deposit" : "Withdrawal";
        Console.WriteLine($"[{_viewName}] {changeType}: {account.Username}'s balance " +
                         $"${e.OldBalance:F2} → ${e.NewBalance:F2} (${Math.Abs(e.Change):F2})");
    }

    private void OnAccountLocked(object sender, AccountEventArgs e)
    {
        var account = (UserAccount)sender;
        Console.WriteLine($"[{_viewName}] 🔒 Account {account.Username} locked: {e.Reason}");
    }
}

public class SecurityMonitor
{
    private readonly Dictionary<string, List<decimal>> _transactionHistory;

    public SecurityMonitor()
    {
        _transactionHistory = new Dictionary<string, List<decimal>>();
    }

    public void AttachToAccount(UserAccount account)
    {
        account.BalanceChanged += OnBalanceChanged;
        _transactionHistory[account.Username] = new List<decimal>();
    }

    private void OnBalanceChanged(object sender, BalanceChangedEventArgs e)
    {
        var account = (UserAccount)sender;
        var changeAmount = Math.Abs(e.Change);

        _transactionHistory[account.Username].Add(changeAmount);

        // Security checks
        if (changeAmount > 10000)
        {
            Console.WriteLine($"[Security] 🚨 Large transaction detected: {account.Username} - ${changeAmount:F2}");
        }

        // Check for suspicious patterns (multiple large transactions)
        var recentLarge = _transactionHistory[account.Username]
            .TakeLast(5)
            .Count(amount => amount > 1000);

        if (recentLarge >= 3)
        {
            Console.WriteLine($"[Security] ⚠️  Suspicious activity: {account.Username} - " +
                            $"Multiple large transactions detected");
            account.LockAccount("Suspicious transaction pattern detected");
        }
    }
}

// Usage example
public class MvcObserverExample
{
    public void DemonstrateModelViewObserver()
    {
        // Create model
        var account = new UserAccount("john.doe", 1000.00m);

        // Create views/observers
        var mainView = new AccountDisplayView("Main Dashboard");
        var mobileView = new AccountDisplayView("Mobile App");
        var securityMonitor = new SecurityMonitor();

        // Attach observers
        mainView.AttachToAccount(account);
        mobileView.AttachToAccount(account);
        securityMonitor.AttachToAccount(account);

        Console.WriteLine("=== Account Activity Simulation ===");

        // Normal transactions
        account.Deposit(500.00m);
        account.Withdraw(150.00m);

        // Large transactions to trigger security alerts
        account.Deposit(5000.00m);
        account.Withdraw(2000.00m);
        account.Deposit(3000.00m); // This should trigger suspicious activity

        Console.WriteLine("\n=== Final State ===");
        Console.WriteLine($"Account: {account.Username}");
        Console.WriteLine($"Balance: ${account.Balance:F2}");
        Console.WriteLine($"Locked: {account.IsLocked}");
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Observer Pattern Benefits**:

- ✅ **Loose coupling**: Subjects don't need to know observer details
- ✅ **Dynamic relationships**: Observers can subscribe/unsubscribe at runtime
- ✅ **Open/closed principle**: New observers can be added without modifying subjects
- ✅ **Broadcast communication**: One-to-many notification automatically

**Observer Pattern Considerations**:

- ⚠️ **Memory leaks**: Unsubscribed observers can prevent garbage collection
- ⚠️ **Performance impact**: Many observers can slow down notifications
- ⚠️ **Ordering dependencies**: Notification order may matter
- ⚠️ **Error propagation**: One observer's error can affect others

**Modern C# Features**:

- **Events and delegates** - Built-in observer pattern support
- **INotifyPropertyChanged** - Standard interface for property change notification
- **Reactive Extensions (Rx)** - Advanced observable sequences
- **CancellationToken** - For managing subscription lifetimes

**Best Practices**:

- Always unsubscribe from events to prevent memory leaks
- Use weak references for long-lived subjects with short-lived observers
- Handle exceptions in observers to prevent cascading failures
- Consider using `IDisposable` for subscription management

### Next Steps

**Immediate Actions**:

- Implement proper cleanup using `IDisposable` subscription pattern
- Explore Reactive Extensions (Rx.NET) for advanced scenarios
- Continue to **Strategy Pattern**: Algorithm selection and polymorphism

**Advanced Topics**:

- Event sourcing with observer patterns
- MVVM (Model-View-ViewModel) architecture
- Reactive programming paradigms

## 🔗 Related Topics

**Prerequisites**: Singleton Pattern (Part 3), Event-driven programming, Delegates and events in C#  
**Builds Upon**: Interface design, Event handling, Memory management  
**Enables**: Strategy Pattern, Model-View architectures, Reactive programming  
**Related**: Mediator pattern, Publish-Subscribe pattern, Event sourcing
