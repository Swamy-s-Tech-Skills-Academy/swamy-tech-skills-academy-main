# 09C_Design-Patterns-Part4C-Observer-Pattern-Model-Updates

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Observer Pattern Parts A & B, Model-View patterns  
**Estimated Time**: Part C of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement Observer Pattern for model-view architecture and data binding
- Design property change notifications with thread-safe model updates
- Apply observer patterns for security monitoring and business rule enforcement
- Master subscription lifecycle management and memory leak prevention

## 📋 Content Sections (27-Minute Structure)

### Model-View Observer Architecture (5 minutes)

**Model Update Notification System**:

- **Property Change Events** - Automatic UI updates when model changes
- **Business Logic Observers** - Security monitoring, audit trails, validation
- **Thread-Safe Notifications** - Concurrent model updates with observer safety
- **Subscription Management** - Proper resource cleanup and memory leak prevention

```text
🏗️ MODEL-VIEW OBSERVER ARCHITECTURE
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UserAccount   │    │ AccountDisplay  │    │ SecurityMonitor │
│     (Model)     │    │     (View)      │    │   (Observer)    │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + Username      │    │ + ViewName      │    │ + AttachToAcct  │
│ + Balance       │    │ + AttachToAcct  │    │ + OnBalanceChng │
│ + IsLocked      │    │ + OnPropChanged │    │ + CheckSecurity │
├─────────────────┤    │ + OnBalanceChng │    │ + LockIfSuspect │
│ + PropertyChngd │───►│ + OnAcctLocked  │    └─────────────────┘
│ + BalanceChngd  │    └─────────────────┘
│ + AccountLocked │                ▲
└─────────────────┘                │
         │                         │
         └─────────────────────────┘
                Events Flow
```

### Thread-Safe Account Model (10 minutes)

#### Observable User Account Implementation

```csharp
// Model with observable properties and thread-safe operations
public class UserAccount
{
    private string _username;
    private decimal _balance;
    private bool _isLocked;
    private readonly object _lock = new object();

    // Standard property change notification
    public event EventHandler<PropertyChangedEventArgs> PropertyChanged;
    
    // Specialized event for balance changes with old/new values
    public event EventHandler<BalanceChangedEventArgs> BalanceChanged;
    
    // Security-related events for account locking
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

            // Notify balance change outside of lock to prevent deadlocks
            if (oldBalance != value)
            {
                OnBalanceChanged(new BalanceChangedEventArgs(oldBalance, value));
            }
        }
    }

    public bool IsLocked
    {
        get
        {
            lock (_lock) { return _isLocked; }
        }
        private set
        {
            lock (_lock)
            {
                if (_isLocked != value)
                {
                    _isLocked = value;
                    OnPropertyChanged(nameof(IsLocked));
                }
            }
        }
    }

    public UserAccount(string username, decimal initialBalance)
    {
        if (string.IsNullOrEmpty(username))
            throw new ArgumentException("Username cannot be null or empty", nameof(username));
        if (initialBalance < 0)
            throw new ArgumentException("Initial balance cannot be negative", nameof(initialBalance));

        _username = username;
        _balance = initialBalance;
        _isLocked = false;
    }

    public bool Deposit(decimal amount)
    {
        if (IsLocked)
        {
            Console.WriteLine($"Cannot deposit to locked account: {Username}");
            return false;
        }
        
        if (amount <= 0) 
            throw new ArgumentException("Deposit amount must be positive", nameof(amount));

        Balance += amount;
        Console.WriteLine($"[Account] Deposited ${amount:F2} to {Username}");
        return true;
    }

    public bool Withdraw(decimal amount)
    {
        if (IsLocked)
        {
            Console.WriteLine($"Cannot withdraw from locked account: {Username}");
            return false;
        }
        
        if (amount <= 0) 
            throw new ArgumentException("Withdrawal amount must be positive", nameof(amount));

        lock (_lock)
        {
            if (_balance >= amount)
            {
                Balance -= amount;
                Console.WriteLine($"[Account] Withdrew ${amount:F2} from {Username}");
                return true;
            }
        }

        Console.WriteLine($"[Account] Insufficient funds for {Username}: ${_balance:F2} < ${amount:F2}");
        return false;
    }

    public void LockAccount(string reason)
    {
        if (!IsLocked)
        {
            IsLocked = true;
            Console.WriteLine($"[Account] Account {Username} locked: {reason}");
            OnAccountLocked(new AccountEventArgs(reason));
        }
    }

    public void UnlockAccount(string reason)
    {
        if (IsLocked)
        {
            IsLocked = false;
            Console.WriteLine($"[Account] Account {Username} unlocked: {reason}");
            OnPropertyChanged(nameof(IsLocked));
        }
    }

    // Thread-safe event notification methods
    protected virtual void OnPropertyChanged(string propertyName)
    {
        // Create copy to avoid race conditions
        var handler = PropertyChanged;
        handler?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

    protected virtual void OnBalanceChanged(BalanceChangedEventArgs e)
    {
        var handler = BalanceChanged;
        handler?.Invoke(this, e);
    }

    protected virtual void OnAccountLocked(AccountEventArgs e)
    {
        var handler = AccountLocked;
        handler?.Invoke(this, e);
    }
}

// Specialized event argument classes
public class PropertyChangedEventArgs : EventArgs
{
    public string PropertyName { get; }
    public DateTime Timestamp { get; }

    public PropertyChangedEventArgs(string propertyName)
    {
        PropertyName = propertyName ?? throw new ArgumentNullException(nameof(propertyName));
        Timestamp = DateTime.UtcNow;
    }
}

public class BalanceChangedEventArgs : EventArgs
{
    public decimal OldBalance { get; }
    public decimal NewBalance { get; }
    public decimal Change => NewBalance - OldBalance;
    public bool IsDeposit => Change > 0;
    public bool IsWithdrawal => Change < 0;
    public DateTime Timestamp { get; }

    public BalanceChangedEventArgs(decimal oldBalance, decimal newBalance)
    {
        OldBalance = oldBalance;
        NewBalance = newBalance;
        Timestamp = DateTime.UtcNow;
    }
}

public class AccountEventArgs : EventArgs
{
    public string Reason { get; }
    public DateTime Timestamp { get; }

    public AccountEventArgs(string reason)
    {
        Reason = reason ?? throw new ArgumentNullException(nameof(reason));
        Timestamp = DateTime.UtcNow;
    }
}
```

### Display View Observers (5 minutes)

#### Account Display Views with Observer Pattern

```csharp
// Main dashboard view observer
public class AccountDisplayView
{
    public string ViewName { get; }
    private readonly Dictionary<string, object> _lastKnownValues;

    public AccountDisplayView(string viewName)
    {
        ViewName = viewName ?? throw new ArgumentNullException(nameof(viewName));
        _lastKnownValues = new Dictionary<string, object>();
    }

    public void AttachToAccount(UserAccount account)
    {
        if (account == null) throw new ArgumentNullException(nameof(account));

        account.PropertyChanged += OnPropertyChanged;
        account.BalanceChanged += OnBalanceChanged;
        account.AccountLocked += OnAccountLocked;

        Console.WriteLine($"[{ViewName}] Attached to account: {account.Username}");
        
        // Initial display
        RefreshDisplay(account);
    }

    public void DetachFromAccount(UserAccount account)
    {
        if (account == null) return;

        account.PropertyChanged -= OnPropertyChanged;
        account.BalanceChanged -= OnBalanceChanged;
        account.AccountLocked -= OnAccountLocked;

        Console.WriteLine($"[{ViewName}] Detached from account: {account.Username}");
        _lastKnownValues.Clear();
    }

    private void OnPropertyChanged(object sender, PropertyChangedEventArgs e)
    {
        var account = (UserAccount)sender;
        
        // Track property changes for delta detection
        var currentValue = GetPropertyValue(account, e.PropertyName);
        var hasChanged = !_lastKnownValues.TryGetValue(e.PropertyName, out var lastValue) 
                        || !Equals(currentValue, lastValue);

        if (hasChanged)
        {
            _lastKnownValues[e.PropertyName] = currentValue;
            Console.WriteLine($"[{ViewName}] 🔄 Property '{e.PropertyName}' updated for {account.Username}: {currentValue}");
            
            // Trigger UI refresh for specific property
            RefreshProperty(e.PropertyName, currentValue);
        }
    }

    private void OnBalanceChanged(object sender, BalanceChangedEventArgs e)
    {
        var account = (UserAccount)sender;
        var transactionType = e.IsDeposit ? "💰 Deposit" : "💸 Withdrawal";
        var arrow = e.IsDeposit ? "↗️" : "↘️";
        
        Console.WriteLine($"[{ViewName}] {arrow} {transactionType}: {account.Username} " +
                         $"${e.OldBalance:F2} → ${e.NewBalance:F2} " +
                         $"({(e.Change > 0 ? "+" : "")}{e.Change:F2})");

        // Update balance display with animation effect
        AnimateBalanceChange(e.OldBalance, e.NewBalance);
    }

    private void OnAccountLocked(object sender, AccountEventArgs e)
    {
        var account = (UserAccount)sender;
        Console.WriteLine($"[{ViewName}] 🔒 ACCOUNT LOCKED: {account.Username} - {e.Reason}");
        
        // Show lock screen overlay
        ShowLockOverlay(e.Reason);
    }

    private void RefreshDisplay(UserAccount account)
    {
        Console.WriteLine($"[{ViewName}] 📊 Account Overview:");
        Console.WriteLine($"[{ViewName}]   User: {account.Username}");
        Console.WriteLine($"[{ViewName}]   Balance: ${account.Balance:F2}");
        Console.WriteLine($"[{ViewName}]   Status: {(account.IsLocked ? "🔒 LOCKED" : "✅ Active")}");
    }

    private void RefreshProperty(string propertyName, object value)
    {
        // Simulate UI property refresh
        Console.WriteLine($"[{ViewName}] 🎨 Refreshing UI element: {propertyName} = {value}");
    }

    private void AnimateBalanceChange(decimal oldBalance, decimal newBalance)
    {
        // Simulate balance animation
        Console.WriteLine($"[{ViewName}] 🎬 Animating balance change: ${oldBalance:F2} → ${newBalance:F2}");
    }

    private void ShowLockOverlay(string reason)
    {
        // Simulate lock screen overlay
        Console.WriteLine($"[{ViewName}] 🚫 Displaying lock overlay: {reason}");
    }

    private object GetPropertyValue(UserAccount account, string propertyName)
    {
        return propertyName switch
        {
            nameof(UserAccount.Username) => account.Username,
            nameof(UserAccount.Balance) => account.Balance,
            nameof(UserAccount.IsLocked) => account.IsLocked,
            _ => null
        };
    }
}

// Security monitoring observer
public class SecurityMonitor
{
    private readonly Dictionary<string, TransactionHistory> _accountHistories;
    private readonly object _historyLock = new object();

    public SecurityMonitor()
    {
        _accountHistories = new Dictionary<string, TransactionHistory>();
    }

    public void AttachToAccount(UserAccount account)
    {
        if (account == null) throw new ArgumentNullException(nameof(account));

        account.BalanceChanged += OnBalanceChanged;
        
        lock (_historyLock)
        {
            _accountHistories[account.Username] = new TransactionHistory();
        }

        Console.WriteLine($"[Security] 🛡️  Monitoring started for: {account.Username}");
    }

    public void DetachFromAccount(UserAccount account)
    {
        if (account == null) return;

        account.BalanceChanged -= OnBalanceChanged;
        
        lock (_historyLock)
        {
            _accountHistories.Remove(account.Username);
        }

        Console.WriteLine($"[Security] 🛡️  Monitoring stopped for: {account.Username}");
    }

    private void OnBalanceChanged(object sender, BalanceChangedEventArgs e)
    {
        var account = (UserAccount)sender;
        var transactionAmount = Math.Abs(e.Change);

        lock (_historyLock)
        {
            if (_accountHistories.TryGetValue(account.Username, out var history))
            {
                history.AddTransaction(transactionAmount, e.IsDeposit);

                // Security checks
                CheckLargeTransaction(account, transactionAmount);
                CheckSuspiciousPattern(account, history);
                CheckDailyLimit(account, history);
            }
        }
    }

    private void CheckLargeTransaction(UserAccount account, decimal amount)
    {
        const decimal largeTransactionThreshold = 10000m;
        
        if (amount > largeTransactionThreshold)
        {
            Console.WriteLine($"[Security] 🚨 LARGE TRANSACTION ALERT: {account.Username} - ${amount:F2}");
            
            // Could trigger additional verification requirements
            if (amount > 50000m)
            {
                Console.WriteLine($"[Security] 🔒 EXTREME AMOUNT: Temporary account lock for verification");
                account.LockAccount($"Large transaction verification required: ${amount:F2}");
            }
        }
    }

    private void CheckSuspiciousPattern(UserAccount account, TransactionHistory history)
    {
        // Check for multiple large transactions in short time period
        var recentLargeCount = history.GetRecentLargeTransactionCount(TimeSpan.FromHours(1), 1000m);
        
        if (recentLargeCount >= 3)
        {
            Console.WriteLine($"[Security] ⚠️  SUSPICIOUS PATTERN: {account.Username} - " +
                            $"{recentLargeCount} large transactions in past hour");
            account.LockAccount("Suspicious transaction pattern detected");
        }

        // Check for rapid-fire transactions
        var recentTransactionCount = history.GetRecentTransactionCount(TimeSpan.FromMinutes(5));
        if (recentTransactionCount >= 10)
        {
            Console.WriteLine($"[Security] ⚠️  RAPID TRANSACTIONS: {account.Username} - " +
                            $"{recentTransactionCount} transactions in 5 minutes");
            account.LockAccount("Rapid transaction pattern detected");
        }
    }

    private void CheckDailyLimit(UserAccount account, TransactionHistory history)
    {
        const decimal dailyWithdrawalLimit = 5000m;
        
        var todayWithdrawals = history.GetDailyWithdrawalTotal();
        if (todayWithdrawals > dailyWithdrawalLimit)
        {
            Console.WriteLine($"[Security] 🚫 DAILY LIMIT EXCEEDED: {account.Username} - " +
                            $"${todayWithdrawals:F2} > ${dailyWithdrawalLimit:F2}");
            account.LockAccount($"Daily withdrawal limit exceeded: ${todayWithdrawals:F2}");
        }
    }

    private class TransactionHistory
    {
        private readonly List<TransactionRecord> _transactions = new List<TransactionRecord>();

        public void AddTransaction(decimal amount, bool isDeposit)
        {
            _transactions.Add(new TransactionRecord(amount, isDeposit, DateTime.UtcNow));
        }

        public int GetRecentTransactionCount(TimeSpan timeWindow)
        {
            var cutoff = DateTime.UtcNow - timeWindow;
            return _transactions.Count(t => t.Timestamp >= cutoff);
        }

        public int GetRecentLargeTransactionCount(TimeSpan timeWindow, decimal threshold)
        {
            var cutoff = DateTime.UtcNow - timeWindow;
            return _transactions.Count(t => t.Timestamp >= cutoff && t.Amount >= threshold);
        }

        public decimal GetDailyWithdrawalTotal()
        {
            var today = DateTime.UtcNow.Date;
            return _transactions
                .Where(t => t.Timestamp.Date == today && !t.IsDeposit)
                .Sum(t => t.Amount);
        }

        private class TransactionRecord
        {
            public decimal Amount { get; }
            public bool IsDeposit { get; }
            public DateTime Timestamp { get; }

            public TransactionRecord(decimal amount, bool isDeposit, DateTime timestamp)
            {
                Amount = amount;
                IsDeposit = isDeposit;
                Timestamp = timestamp;
            }
        }
    }
}
```

### Model-View Demo (5 minutes)

```csharp
// Comprehensive model-view-observer demonstration
public class ModelViewObserverDemo
{
    public static void RunDemo()
    {
        Console.WriteLine("=== Model-View Observer Pattern Demo ===\n");

        // Create account model
        var account = new UserAccount("alice.smith", 2500.00m);

        // Create view observers
        var dashboardView = new AccountDisplayView("Dashboard");
        var mobileView = new AccountDisplayView("Mobile App");
        var securityMonitor = new SecurityMonitor();

        // Attach all observers
        Console.WriteLine("--- Setting up observers ---");
        dashboardView.AttachToAccount(account);
        mobileView.AttachToAccount(account);
        securityMonitor.AttachToAccount(account);

        Console.WriteLine("\n--- Normal account activity ---");
        account.Deposit(500.00m);
        account.Withdraw(100.00m);
        account.Deposit(1500.00m);

        Console.WriteLine("\n--- Large transaction (security alert) ---");
        account.Withdraw(15000.00m); // Should trigger large transaction alert

        Console.WriteLine("\n--- Suspicious pattern simulation ---");
        account.Deposit(2000.00m);
        account.Withdraw(1800.00m);
        account.Deposit(1900.00m); // Should trigger suspicious pattern

        Console.WriteLine("\n--- Cleanup ---");
        dashboardView.DetachFromAccount(account);
        mobileView.DetachFromAccount(account);
        securityMonitor.DetachFromAccount(account);

        Console.WriteLine("\n--- Post-cleanup activity (no observers) ---");
        if (!account.IsLocked)
        {
            account.Deposit(100.00m); // Should not trigger any observer notifications
        }
    }
}
```

### Key Takeaways & Memory Management (2 minutes)

**Model-View Observer Benefits**:

- **Automatic UI Updates** - Views stay synchronized with model changes
- **Business Logic Separation** - Security monitoring decoupled from UI
- **Thread-Safe Operations** - Proper locking prevents race conditions
- **Event-Driven Architecture** - Loose coupling between components

**Memory Leak Prevention**:

- **Always detach observers** - Use `DetachFromAccount()` in disposal
- **Weak event patterns** - Consider WeakEventManager for long-lived objects
- **IDisposable subscribers** - Automatic cleanup with using statements
- **Event handler copies** - Prevent race conditions in notification methods

**Next in Series**:

- **[Part D - Enterprise Messaging Patterns](09D_Design-Patterns-Part4D-Observer-Pattern-Enterprise.md)**

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Observer Fundamentals](09A_Design-Patterns-Part4A-Observer-Pattern-Fundamentals.md)**
- **[Part B - UI Event Systems](09B_Design-Patterns-Part4B-Observer-Pattern-UI-Events.md)**
- Thread-safe programming concepts

**Builds Upon**:

- Model-View architecture patterns
- Property change notification
- Event-driven programming

**Enables**:

- [Model-View-ViewModel (MVVM)](../../architectural-patterns/mvvm/) for data binding
- [Event Sourcing](../../architectural-patterns/event-sourcing/) for audit trails
- [Command Query Responsibility Segregation (CQRS)](../../architectural-patterns/cqrs/) for read/write separation

**Next Patterns**:

- [Mediator Pattern](../behavioral-patterns/mediator/) for component communication
- [Chain of Responsibility](../behavioral-patterns/chain-of-responsibility/) for request processing
