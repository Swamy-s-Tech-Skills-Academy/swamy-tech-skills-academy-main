# 09B_Design-Patterns-Part4B-Observer-Pattern-UI-Events

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Observer Pattern Fundamentals (Part A), UI programming concepts  
**Estimated Time**: Part B of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement Observer Pattern for UI event handling and form validation
- Design generic observer systems with IObservable<T> interface
- Apply observer patterns to data binding and UI state management
- Master error handling and subscription lifecycle in observer systems

## 📋 Content Sections (27-Minute Structure)

### Alert Systems and Enhanced Observers (5 minutes)

**Advanced Observer Applications**:

- **Alert Systems** - Price thresholds, condition monitoring
- **Generic Observers** - Type-safe, reusable observer infrastructure
- **UI Event Systems** - Form validation, data binding, state changes
- **Error Handling** - Robust notification with exception management

```text
🔔 ALERT SYSTEM ARCHITECTURE
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Stock        │    │ StockAlertSystem│    │  AlertRule      │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + PriceChanged  │───►│ + OnPriceChanged│    │ + TargetPrice   │
│ + UpdatePrice() │    │ + SetPriceAlert │    │ + AlertType     │
└─────────────────┘    │ + Subscribe()   │    │ + CheckTrigger()│
                       └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │ Alert Messages  │
                       ├─────────────────┤
                       │ - Above/Below   │
                       │ - Email/SMS     │
                       │ - Threshold     │
                       └─────────────────┘
```

### Stock Alert System Implementation (10 minutes)

#### Advanced Alert Observer

```csharp
// Observer: Alert system for price notifications
public class StockAlertSystem
{
    public string Name { get; }
    private readonly Dictionary<string, AlertRule> _alertRules;
    private readonly object _alertLock = new object();

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
        
        // Remove alert rules for this stock
        lock (_alertLock)
        {
            _alertRules.Remove(stock.Symbol);
        }
        
        Console.WriteLine($"[{Name}] Stopped monitoring {stock.Symbol}");
    }

    public void SetPriceAlert(string symbol, decimal targetPrice, AlertType alertType)
    {
        if (string.IsNullOrEmpty(symbol))
            throw new ArgumentException("Symbol cannot be null or empty", nameof(symbol));

        lock (_alertLock)
        {
            _alertRules[symbol] = new AlertRule(targetPrice, alertType);
        }
        
        Console.WriteLine($"[{Name}] Alert set for {symbol}: {alertType} ${targetPrice:F2}");
    }

    public void RemoveAlert(string symbol)
    {
        if (string.IsNullOrEmpty(symbol)) return;

        lock (_alertLock)
        {
            if (_alertRules.Remove(symbol))
            {
                Console.WriteLine($"[{Name}] Alert removed for {symbol}");
            }
        }
    }

    private void OnStockPriceChanged(object sender, StockPriceChangedEventArgs e)
    {
        // Check for triggered alerts
        lock (_alertLock)
        {
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
                    
                    // Send notification (email, SMS, etc.)
                    SendNotification(e.Symbol, rule, e.NewPrice);
                }
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

    private void SendNotification(string symbol, AlertRule rule, decimal currentPrice)
    {
        // Simulate sending notification
        Console.WriteLine($"[{Name}] 📧 Notification sent: {symbol} alert triggered at ${currentPrice:F2}");
    }

    private class AlertRule
    {
        public decimal TargetPrice { get; }
        public AlertType AlertType { get; }
        public DateTime CreatedAt { get; }

        public AlertRule(decimal targetPrice, AlertType alertType)
        {
            TargetPrice = targetPrice;
            AlertType = alertType;
            CreatedAt = DateTime.UtcNow;
        }
    }
}

public enum AlertType
{
    Above,      // Triggers when price goes above target
    Below,      // Triggers when price goes below target
    AtOrAbove,  // Triggers when price is at or above target
    AtOrBelow   // Triggers when price is at or below target
}
```

### Generic Observer System (10 minutes)

#### IObservable<T> Generic Implementation

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
    private Exception _error = null;

    public IDisposable Subscribe(IObserver<T> observer)
    {
        if (observer == null) throw new ArgumentNullException(nameof(observer));

        lock (_lock)
        {
            if (_error != null)
            {
                observer.OnError(_error);
                return new DisposableAction(() => { }); // No-op disposal
            }

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
            if (_isCompleted || _error != null) return;
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
            if (_isCompleted || _error != null) return;
            
            _error = error;
            currentObservers = new List<IObserver<T>>(_observers);
            _observers.Clear();
        }

        // Notify all observers of error
        foreach (var observer in currentObservers)
        {
            try
            {
                observer.OnError(error);
            }
            catch
            {
                // Observer's error handler failed - ignore
            }
        }
    }

    public void OnCompleted()
    {
        List<IObserver<T>> currentObservers;

        lock (_lock)
        {
            if (_isCompleted || _error != null) return;
            
            _isCompleted = true;
            currentObservers = new List<IObserver<T>>(_observers);
            _observers.Clear();
        }

        // Notify all observers of completion
        foreach (var observer in currentObservers)
        {
            try
            {
                observer.OnCompleted();
            }
            catch
            {
                // Observer's completion handler failed - ignore
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
}

// Helper class for subscription disposal
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
```

#### UI Form Validation Observer

```csharp
// Form validation using generic observer pattern
public class FormValidationSystem
{
    private readonly Subject<ValidationResult> _validationSubject;
    private readonly Dictionary<string, Func<string, bool>> _validators;

    public FormValidationSystem()
    {
        _validationSubject = new Subject<ValidationResult>();
        _validators = new Dictionary<string, Func<string, bool>>();
    }

    public IDisposable Subscribe(IObserver<ValidationResult> observer)
    {
        return _validationSubject.Subscribe(observer);
    }

    public void AddValidator(string fieldName, Func<string, bool> validator)
    {
        if (string.IsNullOrEmpty(fieldName))
            throw new ArgumentException("Field name cannot be null or empty", nameof(fieldName));
        if (validator == null)
            throw new ArgumentNullException(nameof(validator));

        _validators[fieldName] = validator;
    }

    public void ValidateField(string fieldName, string value)
    {
        if (!_validators.TryGetValue(fieldName, out var validator))
        {
            return; // No validator for this field
        }

        try
        {
            var isValid = validator(value);
            var result = new ValidationResult(fieldName, value, isValid, 
                isValid ? null : $"{fieldName} validation failed");
            
            _validationSubject.OnNext(result);
        }
        catch (Exception ex)
        {
            var result = new ValidationResult(fieldName, value, false, 
                $"Validation error for {fieldName}: {ex.Message}");
            
            _validationSubject.OnNext(result);
        }
    }

    public void CompleteValidation()
    {
        _validationSubject.OnCompleted();
    }
}

// Validation result class
public class ValidationResult
{
    public string FieldName { get; }
    public string Value { get; }
    public bool IsValid { get; }
    public string ErrorMessage { get; }
    public DateTime Timestamp { get; }

    public ValidationResult(string fieldName, string value, bool isValid, string errorMessage)
    {
        FieldName = fieldName ?? throw new ArgumentNullException(nameof(fieldName));
        Value = value;
        IsValid = isValid;
        ErrorMessage = errorMessage;
        Timestamp = DateTime.UtcNow;
    }
}

// Form field observer
public class FormFieldObserver : IObserver<ValidationResult>
{
    public string Name { get; }
    private readonly HashSet<string> _watchedFields;

    public FormFieldObserver(string name, params string[] watchedFields)
    {
        Name = name ?? throw new ArgumentNullException(nameof(name));
        _watchedFields = new HashSet<string>(watchedFields ?? Enumerable.Empty<string>());
    }

    public void OnNext(ValidationResult result)
    {
        if (_watchedFields.Count == 0 || _watchedFields.Contains(result.FieldName))
        {
            var status = result.IsValid ? "✅ VALID" : "❌ INVALID";
            Console.WriteLine($"[{Name}] {status} - {result.FieldName}: {result.Value}");
            
            if (!result.IsValid && !string.IsNullOrEmpty(result.ErrorMessage))
            {
                Console.WriteLine($"[{Name}]   Error: {result.ErrorMessage}");
            }
        }
    }

    public void OnError(Exception error)
    {
        Console.WriteLine($"[{Name}] Validation system error: {error.Message}");
    }

    public void OnCompleted()
    {
        Console.WriteLine($"[{Name}] Validation completed");
    }
}
```

### Practical Usage Example (2 minutes)

```csharp
// Demo: Advanced observer patterns
public class AdvancedObserverDemo
{
    public static void RunDemo()
    {
        Console.WriteLine("=== Advanced Observer Pattern Demo ===\n");

        // 1. Stock alert system demo
        RunStockAlertDemo();
        
        Console.WriteLine("\n" + new string('=', 50) + "\n");
        
        // 2. Form validation demo
        RunFormValidationDemo();
    }

    private static void RunStockAlertDemo()
    {
        Console.WriteLine("--- Stock Alert System ---");
        
        var stock = new Stock("AAPL", 150.00m);
        var alertSystem = new StockAlertSystem("Alert Monitor");
        
        // Subscribe to stock and set alerts
        alertSystem.SubscribeToStock(stock);
        alertSystem.SetPriceAlert("AAPL", 155.00m, AlertType.Above);
        alertSystem.SetPriceAlert("AAPL", 145.00m, AlertType.Below);
        
        // Simulate price changes
        stock.UpdatePrice(152.00m); // No alert
        stock.UpdatePrice(156.00m); // Above alert triggered
        stock.UpdatePrice(143.00m); // Below alert triggered
        
        alertSystem.UnsubscribeFromStock(stock);
    }

    private static void RunFormValidationDemo()
    {
        Console.WriteLine("--- Form Validation System ---");
        
        var validationSystem = new FormValidationSystem();
        
        // Set up validators
        validationSystem.AddValidator("email", email => 
            !string.IsNullOrEmpty(email) && email.Contains("@"));
        validationSystem.AddValidator("password", password => 
            !string.IsNullOrEmpty(password) && password.Length >= 8);
        validationSystem.AddValidator("age", age => 
            int.TryParse(age, out var ageValue) && ageValue >= 18);
        
        // Set up observers
        var emailObserver = new FormFieldObserver("Email Validator", "email");
        var passwordObserver = new FormFieldObserver("Password Validator", "password");
        var generalObserver = new FormFieldObserver("General Validator");
        
        using var emailSub = validationSystem.Subscribe(emailObserver);
        using var passwordSub = validationSystem.Subscribe(passwordObserver);
        using var generalSub = validationSystem.Subscribe(generalObserver);
        
        // Simulate form input validation
        validationSystem.ValidateField("email", "user@example.com");
        validationSystem.ValidateField("email", "invalid-email");
        validationSystem.ValidateField("password", "12345");
        validationSystem.ValidateField("password", "securepassword123");
        validationSystem.ValidateField("age", "17");
        validationSystem.ValidateField("age", "25");
        
        validationSystem.CompleteValidation();
    }
}
```

### Key Takeaways & UI Benefits (2 minutes)

**Advanced Observer Pattern Benefits**:

- **Alert Systems** - Conditional notifications with complex triggering rules
- **Generic Observers** - Type-safe, reusable observer infrastructure
- **Error Handling** - Robust notification with exception isolation
- **Subscription Management** - Proper resource cleanup with IDisposable

**UI Event System Applications**:

- **Form Validation** - Real-time field validation with multiple validators
- **Data Binding** - Automatic UI updates when model changes
- **State Management** - Component state synchronization
- **Event Aggregation** - Centralized event handling across components

**Next in Series**:

- **[Part C - Model Update Notifications](09C_Design-Patterns-Part4C-Observer-Pattern-Model-Updates.md)**
- **[Part D - Enterprise Messaging Patterns](09D_Design-Patterns-Part4D-Observer-Pattern-Enterprise.md)**

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Observer Fundamentals](09A_Design-Patterns-Part4A-Observer-Pattern-Fundamentals.md)**
- Generic interfaces and type safety
- IDisposable pattern for resource management

**Builds Upon**:

- UI programming and event handling
- Form validation patterns
- Generic programming concepts

**Enables**:

- [Mediator Pattern](../behavioral-patterns/mediator/) for UI component communication
- [MVVM Pattern](../../architectural-patterns/mvvm/) for UI data binding
- [Reactive Extensions](../../libraries/reactive-extensions/) for complex event streams

**Next Patterns**:

- [Command Pattern](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md) for UI actions
- [State Pattern](../behavioral-patterns/state/) for UI state management