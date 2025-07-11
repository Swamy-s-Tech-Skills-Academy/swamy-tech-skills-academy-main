# Design Patterns Quick Reference 🧱

> **Quick Access**: Decision matrix for reusable code solutions  
> **Context**: Architecture decisions, code reviews, .NET development  
> **Last Updated**: Week 2 Implementation

---

## 📋 **Problem → Pattern Decision Matrix**

| Problem                                | When to Use                         | Pattern         | Implementation Complexity | ShyvnTech Use Case      |
| -------------------------------------- | ----------------------------------- | --------------- | ------------------------- | ----------------------- |
| **Multiple ways to create objects**    | Need flexibility in object creation | Factory/Builder | ⭐⭐                      | AI model instantiation  |
| **Need exactly one instance**          | Global access to shared resource    | Singleton       | ⭐                        | Configuration manager   |
| **Incompatible interfaces**            | Legacy system integration           | Adapter         | ⭐⭐                      | External API wrappers   |
| **Add behavior without inheritance**   | Runtime feature enhancement         | Decorator       | ⭐⭐⭐                    | AI response enrichment  |
| **Multiple algorithms for same task**  | Configurable behavior               | Strategy        | ⭐⭐                      | Payment processing      |
| **Notify multiple objects of changes** | Event-driven updates                | Observer        | ⭐⭐⭐                    | Real-time notifications |
| **Complex object construction**        | Step-by-step object creation        | Builder         | ⭐⭐                      | Query builders          |
| **Expensive object creation**          | Performance optimization            | Prototype       | ⭐⭐                      | Template cloning        |

---

## 🏭 **Creational Patterns** (Object Creation)

### **Factory Method Pattern**

**When to Use**: Multiple ways to create similar objects

```csharp
// ✅ Factory Pattern for AI Models
public interface IAIModel {
    string ProcessText(string input);
}

public class GPTModel : IAIModel {
    public string ProcessText(string input) => $"GPT: {input}";
}

public class ClaudeModel : IAIModel {
    public string ProcessText(string input) => $"Claude: {input}";
}

public static class AIModelFactory {
    public static IAIModel CreateModel(string type) => type switch {
        "gpt" => new GPTModel(),
        "claude" => new ClaudeModel(),
        _ => throw new ArgumentException("Unknown model type")
    };
}

// Usage
var model = AIModelFactory.CreateModel("gpt");
var result = model.ProcessText("Hello world");
```

### **Singleton Pattern**

**When to Use**: Need exactly one instance (logging, configuration)

```csharp
// ✅ Thread-safe Singleton for Configuration
public sealed class AppConfig {
    private static readonly Lazy<AppConfig> _instance =
        new Lazy<AppConfig>(() => new AppConfig());

    public static AppConfig Instance => _instance.Value;

    private AppConfig() {
        // Load configuration
    }

    public string GetSetting(string key) =>
        Environment.GetEnvironmentVariable(key) ?? "";
}

// Usage
var config = AppConfig.Instance;
var apiKey = config.GetSetting("AI_API_KEY");
```

### **Builder Pattern**

**When to Use**: Complex object construction with many optional parameters

```csharp
// ✅ Builder for Complex Queries
public class QueryBuilder {
    private string _select = "*";
    private string _from = "";
    private string _where = "";
    private string _orderBy = "";

    public QueryBuilder Select(string fields) {
        _select = fields; return this;
    }

    public QueryBuilder From(string table) {
        _from = table; return this;
    }

    public QueryBuilder Where(string condition) {
        _where = condition; return this;
    }

    public QueryBuilder OrderBy(string field) {
        _orderBy = field; return this;
    }

    public string Build() =>
        $"SELECT {_select} FROM {_from}" +
        (!string.IsNullOrEmpty(_where) ? $" WHERE {_where}" : "") +
        (!string.IsNullOrEmpty(_orderBy) ? $" ORDER BY {_orderBy}" : "");
}

// Usage
var query = new QueryBuilder()
    .Select("name, email")
    .From("users")
    .Where("active = 1")
    .OrderBy("name")
    .Build();
```

---

## 🔧 **Structural Patterns** (Object Composition)

### **Adapter Pattern**

**When to Use**: Incompatible interfaces, legacy system integration

```csharp
// ✅ Adapter for External Payment APIs
public interface IPaymentProcessor {
    bool ProcessPayment(decimal amount, string cardNumber);
}

// External library with different interface
public class StripeAPI {
    public string ChargeCard(string token, int cents) => "charge_123";
}

public class StripeAdapter : IPaymentProcessor {
    private readonly StripeAPI _stripe = new();

    public bool ProcessPayment(decimal amount, string cardNumber) {
        var cents = (int)(amount * 100);
        var token = ConvertToToken(cardNumber);
        var result = _stripe.ChargeCard(token, cents);
        return !string.IsNullOrEmpty(result);
    }

    private string ConvertToToken(string cardNumber) =>
        $"tok_{cardNumber.GetHashCode()}";
}
```

### **Decorator Pattern**

**When to Use**: Add responsibilities to objects dynamically

```csharp
// ✅ Decorator for AI Response Enhancement
public interface ITextProcessor {
    string Process(string text);
}

public class BaseProcessor : ITextProcessor {
    public string Process(string text) => text;
}

public class TimestampDecorator : ITextProcessor {
    private readonly ITextProcessor _processor;

    public TimestampDecorator(ITextProcessor processor) =>
        _processor = processor;

    public string Process(string text) =>
        $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {_processor.Process(text)}";
}

public class ValidationDecorator : ITextProcessor {
    private readonly ITextProcessor _processor;

    public ValidationDecorator(ITextProcessor processor) =>
        _processor = processor;

    public string Process(string text) {
        if (string.IsNullOrEmpty(text))
            throw new ArgumentException("Text cannot be empty");
        return _processor.Process(text);
    }
}

// Usage - Chain decorators
ITextProcessor processor = new BaseProcessor();
processor = new ValidationDecorator(processor);
processor = new TimestampDecorator(processor);
var result = processor.Process("Hello world");
```

### **Composite Pattern**

**When to Use**: Tree-like structures, uniform treatment of individual/groups

```csharp
// ✅ Composite for UI Components
public interface IUIComponent {
    void Render();
}

public class Button : IUIComponent {
    public string Text { get; set; }
    public void Render() => Console.WriteLine($"Button: {Text}");
}

public class Panel : IUIComponent {
    private readonly List<IUIComponent> _children = new();

    public void Add(IUIComponent component) => _children.Add(component);

    public void Render() {
        Console.WriteLine("Panel:");
        foreach (var child in _children) {
            child.Render();
        }
    }
}

// Usage
var loginPanel = new Panel();
loginPanel.Add(new Button { Text = "Login" });
loginPanel.Add(new Button { Text = "Cancel" });
loginPanel.Render();
```

---

## ⚡ **Behavioral Patterns** (Object Interaction)

### **Strategy Pattern**

**When to Use**: Multiple algorithms for the same task

```csharp
// ✅ Strategy for Payment Processing
public interface IPaymentStrategy {
    bool ProcessPayment(decimal amount);
}

public class CreditCardStrategy : IPaymentStrategy {
    public bool ProcessPayment(decimal amount) {
        Console.WriteLine($"Processing ${amount} via Credit Card");
        return true;
    }
}

public class PayPalStrategy : IPaymentStrategy {
    public bool ProcessPayment(decimal amount) {
        Console.WriteLine($"Processing ${amount} via PayPal");
        return true;
    }
}

public class PaymentContext {
    private IPaymentStrategy _strategy;

    public void SetStrategy(IPaymentStrategy strategy) =>
        _strategy = strategy;

    public bool ExecutePayment(decimal amount) =>
        _strategy.ProcessPayment(amount);
}

// Usage
var payment = new PaymentContext();
payment.SetStrategy(new CreditCardStrategy());
payment.ExecutePayment(100.00m);
```

### **Observer Pattern**

**When to Use**: One-to-many dependency, event notifications

```csharp
// ✅ Observer for Real-time Notifications
public interface IObserver {
    void Update(string message);
}

public interface ISubject {
    void Attach(IObserver observer);
    void Detach(IObserver observer);
    void Notify(string message);
}

public class OrderService : ISubject {
    private readonly List<IObserver> _observers = new();

    public void Attach(IObserver observer) => _observers.Add(observer);
    public void Detach(IObserver observer) => _observers.Remove(observer);

    public void Notify(string message) {
        foreach (var observer in _observers) {
            observer.Update(message);
        }
    }

    public void CreateOrder(string orderId) {
        // Order creation logic
        Notify($"Order {orderId} created");
    }
}

public class EmailService : IObserver {
    public void Update(string message) =>
        Console.WriteLine($"Email: {message}");
}

public class SMSService : IObserver {
    public void Update(string message) =>
        Console.WriteLine($"SMS: {message}");
}

// Usage
var orderService = new OrderService();
orderService.Attach(new EmailService());
orderService.Attach(new SMSService());
orderService.CreateOrder("ORD-001");
```

### **Command Pattern**

**When to Use**: Decouple invoker from receiver, undo operations

```csharp
// ✅ Command for Undo/Redo Operations
public interface ICommand {
    void Execute();
    void Undo();
}

public class CreateFileCommand : ICommand {
    private readonly string _fileName;

    public CreateFileCommand(string fileName) => _fileName = fileName;

    public void Execute() {
        File.WriteAllText(_fileName, "");
        Console.WriteLine($"Created file: {_fileName}");
    }

    public void Undo() {
        File.Delete(_fileName);
        Console.WriteLine($"Deleted file: {_fileName}");
    }
}

public class CommandInvoker {
    private readonly Stack<ICommand> _history = new();

    public void ExecuteCommand(ICommand command) {
        command.Execute();
        _history.Push(command);
    }

    public void Undo() {
        if (_history.Count > 0) {
            var command = _history.Pop();
            command.Undo();
        }
    }
}
```

---

## 🎯 **Pattern Selection Guide**

### **Quick Decision Tree**

```
What do you need?

└── Object Creation?
    ├── Simple creation → Factory Method
    ├── Complex setup → Builder
    ├── Single instance → Singleton
    └── Copy existing → Prototype

└── Object Structure?
    ├── Interface mismatch → Adapter
    ├── Add features → Decorator
    ├── Tree structure → Composite
    └── Simplified interface → Facade

└── Object Behavior?
    ├── Multiple algorithms → Strategy
    ├── Notify many objects → Observer
    ├── Undo operations → Command
    └── Complex workflows → State
```

---

## 🚀 **ShyvnTech Implementation Priorities**

### **Week 2-3: Foundation Patterns**

1. **Factory** - AI model creation
2. **Strategy** - Payment processing
3. **Observer** - Real-time notifications

### **Week 4-5: Enhancement Patterns**

4. **Decorator** - Feature enhancement
5. **Adapter** - Legacy integrations
6. **Builder** - Complex configurations

### **Week 6+: Advanced Patterns**

7. **Command** - Undo/redo operations
8. **Composite** - UI hierarchies
9. **Prototype** - Template systems

---

## 🎯 **Code Review Checklist**

- [ ] **Factory**: Are object creation responsibilities centralized?
- [ ] **Strategy**: Are algorithms interchangeable without client changes?
- [ ] **Observer**: Are dependencies loosely coupled for notifications?
- [ ] **Decorator**: Can features be added/removed dynamically?
- [ ] **Adapter**: Are incompatible interfaces properly bridged?
- [ ] **Singleton**: Is thread safety handled correctly?

---

## 📚 **Related Quick References**

- [SOLID Principles](SOLID_PRINCIPLES_CHEAT_SHEET.md) - Foundation for all patterns
- [Architecture Patterns](ARCHITECTURE_PATTERNS_MATRIX.md) - System-level patterns
- [System Design Checklist](SYSTEM_DESIGN_CHECKLIST.md) - Implementation guidance

---

**💡 Pro Tip**: Start with Strategy and Observer patterns - they're most commonly used in modern applications and directly support your AI/coaching platform needs!
