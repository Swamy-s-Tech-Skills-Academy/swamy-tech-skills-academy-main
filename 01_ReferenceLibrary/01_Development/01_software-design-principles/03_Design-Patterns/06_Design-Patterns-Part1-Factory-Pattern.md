# 06_Design-Patterns-Part1-Factory-Pattern

**Learning Level**: Intermediate  
**Prerequisites**: SOLID Principles (Parts 1-5), Basic inheritance and interfaces  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Factory Pattern and its three main variants
- Identify when object creation complexity requires factory solutions
- Implement Simple Factory, Factory Method, and Abstract Factory patterns
- Apply factories to achieve loose coupling and flexible object creation

## 📋 Content Sections

### Quick Overview (5 minutes)

**Factory Pattern**: *"Create objects without specifying the exact class of object to be created."*

**Core Problem**: Direct object instantiation creates tight coupling and inflexible code.

```text
❌ TIGHT COUPLING: Direct Instantiation
┌─────────────────────────────────┐
│     OrderProcessor              │
├─────────────────────────────────┤
│ ProcessOrder() {                │
│   var validator = new           │
│     EmailValidator();           │ ← Hard dependency
│   var calculator = new          │
│     TaxCalculator();            │ ← Hard dependency  
│   var notifier = new            │
│     SmtpNotifier();             │ ← Hard dependency
│ }                               │
└─────────────────────────────────┘

✅ FACTORY PATTERN: Loose Coupling
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ OrderProcessor  │───→│ ServiceFactory  │───→│ Concrete        │
│                 │    │                 │    │ Implementations │
│ - factory       │    │ + CreateValidator│    │                 │
│ + ProcessOrder()│    │ + CreateCalculator│    │ - EmailValidator│
└─────────────────┘    │ + CreateNotifier │    │ - TaxCalculator │
                       └─────────────────┘    │ - SmtpNotifier  │
                                              └─────────────────┘
```

**Factory Pattern Variants**:

1. **Simple Factory**: Static method creates objects based on parameters
2. **Factory Method**: Subclasses decide which concrete class to instantiate  
3. **Abstract Factory**: Creates families of related objects

### Core Concepts (15 minutes)

#### Simple Factory Pattern

**Use Case**: Payment processing system

```csharp
// Simple Factory - Static method approach
public enum PaymentType
{
    CreditCard,
    PayPal,
    BankTransfer,
    Cryptocurrency
}

public abstract class PaymentProcessor
{
    public abstract Task<PaymentResult> ProcessAsync(decimal amount, string details);
    public abstract bool IsAvailable();
    public abstract string GetProviderName();
}

// Concrete implementations
public class CreditCardProcessor : PaymentProcessor
{
    public override async Task<PaymentResult> ProcessAsync(decimal amount, string details)
    {
        // Credit card processing logic
        await Task.Delay(100); // Simulate API call
        return new PaymentResult
        {
            Success = true,
            TransactionId = Guid.NewGuid().ToString(),
            ProcessedAmount = amount,
            Provider = GetProviderName()
        };
    }
    
    public override bool IsAvailable() => true;
    public override string GetProviderName() => "Stripe Credit Card";
}

public class PayPalProcessor : PaymentProcessor
{
    public override async Task<PaymentResult> ProcessAsync(decimal amount, string details)
    {
        // PayPal processing logic
        await Task.Delay(150); // Simulate API call
        return new PaymentResult
        {
            Success = amount <= 10000, // PayPal limit example
            TransactionId = $"PP-{Guid.NewGuid().ToString()[..8]}",
            ProcessedAmount = amount,
            Provider = GetProviderName()
        };
    }
    
    public override bool IsAvailable() => DateTime.Now.Hour < 22; // Maintenance window
    public override string GetProviderName() => "PayPal";
}

public class BankTransferProcessor : PaymentProcessor
{
    public override async Task<PaymentResult> ProcessAsync(decimal amount, string details)
    {
        // Bank transfer logic
        await Task.Delay(200); // Simulate bank processing
        return new PaymentResult
        {
            Success = amount >= 10, // Minimum transfer amount
            TransactionId = $"BT-{DateTime.Now:yyyyMMddHHmm}-{Random.Shared.Next(1000, 9999)}",
            ProcessedAmount = amount,
            Provider = GetProviderName()
        };
    }
    
    public override bool IsAvailable() => DateTime.Now.DayOfWeek != DayOfWeek.Sunday;
    public override string GetProviderName() => "ACH Bank Transfer";
}

// Simple Factory implementation
public static class PaymentProcessorFactory
{
    public static PaymentProcessor CreateProcessor(PaymentType paymentType)
    {
        return paymentType switch
        {
            PaymentType.CreditCard => new CreditCardProcessor(),
            PaymentType.PayPal => new PayPalProcessor(),
            PaymentType.BankTransfer => new BankTransferProcessor(),
            PaymentType.Cryptocurrency => throw new NotImplementedException("Crypto support coming soon"),
            _ => throw new ArgumentException($"Unsupported payment type: {paymentType}")
        };
    }
    
    // Factory method with availability checking
    public static PaymentProcessor CreateAvailableProcessor(PaymentType preferredType)
    {
        var processor = CreateProcessor(preferredType);
        
        if (processor.IsAvailable())
        {
            return processor;
        }
        
        // Fallback to available alternatives
        var fallbackTypes = Enum.GetValues<PaymentType>()
            .Where(t => t != preferredType)
            .ToList();
            
        foreach (var fallbackType in fallbackTypes)
        {
            try
            {
                var fallbackProcessor = CreateProcessor(fallbackType);
                if (fallbackProcessor.IsAvailable())
                {
                    return fallbackProcessor;
                }
            }
            catch (NotImplementedException)
            {
                // Skip unsupported payment types
                continue;
            }
        }
        
        throw new InvalidOperationException("No payment processors are currently available");
    }
}

// Client usage
public class PaymentService
{
    public async Task<PaymentResult> ProcessPaymentAsync(decimal amount, PaymentType preferredType, string details = "")
    {
        try
        {
            var processor = PaymentProcessorFactory.CreateAvailableProcessor(preferredType);
            var result = await processor.ProcessAsync(amount, details);
            
            Console.WriteLine($"Payment processed via {processor.GetProviderName()}: {result.TransactionId}");
            return result;
        }
        catch (Exception ex)
        {
            return new PaymentResult
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
    }
}
```

#### Factory Method Pattern

**Use Case**: Document processing system

```csharp
// Factory Method Pattern - Subclasses decide concrete implementation
public abstract class DocumentProcessor
{
    // Factory method - subclasses implement this
    protected abstract IDocumentParser CreateParser();
    protected abstract IDocumentValidator CreateValidator();
    
    // Template method using factory methods
    public async Task<ProcessingResult> ProcessDocumentAsync(string filePath)
    {
        var parser = CreateParser();
        var validator = CreateValidator();
        
        try
        {
            // Parse document
            var document = await parser.ParseAsync(filePath);
            
            // Validate content
            var validationResult = await validator.ValidateAsync(document);
            if (!validationResult.IsValid)
            {
                return ProcessingResult.Failed(validationResult.Errors);
            }
            
            // Process business logic
            var processedDocument = await ApplyBusinessLogic(document);
            
            return ProcessingResult.Success(processedDocument);
        }
        catch (Exception ex)
        {
            return ProcessingResult.Failed($"Processing failed: {ex.Message}");
        }
    }
    
    protected virtual async Task<ProcessedDocument> ApplyBusinessLogic(ParsedDocument document)
    {
        // Default business logic - can be overridden
        return new ProcessedDocument
        {
            Id = Guid.NewGuid(),
            Content = document.Content,
            ProcessedAt = DateTime.UtcNow,
            Metadata = document.Metadata
        };
    }
}

// Concrete factory implementations
public class PdfDocumentProcessor : DocumentProcessor
{
    protected override IDocumentParser CreateParser()
    {
        return new PdfParser();
    }
    
    protected override IDocumentValidator CreateValidator()
    {
        return new PdfValidator();
    }
    
    protected override async Task<ProcessedDocument> ApplyBusinessLogic(ParsedDocument document)
    {
        var processed = await base.ApplyBusinessLogic(document);
        
        // PDF-specific business logic
        processed.Metadata["ExtractedImages"] = ExtractImageCount(document);
        processed.Metadata["PageCount"] = GetPageCount(document);
        
        return processed;
    }
    
    private int ExtractImageCount(ParsedDocument document) => 
        document.Content.Count(c => c == '[' && document.Content.Contains("image"));
        
    private int GetPageCount(ParsedDocument document) =>
        document.Metadata.ContainsKey("Pages") ? int.Parse(document.Metadata["Pages"]) : 1;
}

public class WordDocumentProcessor : DocumentProcessor
{
    protected override IDocumentParser CreateParser()
    {
        return new WordParser();
    }
    
    protected override IDocumentValidator CreateValidator()
    {
        return new WordValidator();
    }
    
    protected override async Task<ProcessedDocument> ApplyBusinessLogic(ParsedDocument document)
    {
        var processed = await base.ApplyBusinessLogic(document);
        
        // Word-specific business logic
        processed.Metadata["WordCount"] = CountWords(document.Content);
        processed.Metadata["HasTrackChanges"] = CheckTrackChanges(document);
        
        return processed;
    }
    
    private int CountWords(string content) => content.Split(' ', StringSplitOptions.RemoveEmptyEntries).Length;
    private bool CheckTrackChanges(ParsedDocument document) => document.Metadata.ContainsKey("TrackChanges");
}

// Document processor factory
public static class DocumentProcessorFactory
{
    public static DocumentProcessor CreateProcessor(string fileExtension)
    {
        return fileExtension.ToLowerInvariant() switch
        {
            ".pdf" => new PdfDocumentProcessor(),
            ".doc" or ".docx" => new WordDocumentProcessor(),
            ".txt" => new TextDocumentProcessor(),
            _ => throw new NotSupportedException($"File type {fileExtension} is not supported")
        };
    }
    
    public static DocumentProcessor CreateProcessorByPath(string filePath)
    {
        var extension = Path.GetExtension(filePath);
        return CreateProcessor(extension);
    }
}
```

#### Abstract Factory Pattern

**Use Case**: Cross-platform UI components

```csharp
// Abstract Factory - Creates families of related objects
public interface IUIComponentFactory
{
    IButton CreateButton();
    ITextBox CreateTextBox();
    ICheckBox CreateCheckBox();
    ILabel CreateLabel();
}

// Abstract product interfaces
public interface IButton
{
    void Render();
    void OnClick(Action callback);
    void SetText(string text);
}

public interface ITextBox
{
    void Render();
    void SetPlaceholder(string placeholder);
    string GetValue();
    void SetValue(string value);
}

// Windows implementation family
public class WindowsUIFactory : IUIComponentFactory
{
    public IButton CreateButton() => new WindowsButton();
    public ITextBox CreateTextBox() => new WindowsTextBox();
    public ICheckBox CreateCheckBox() => new WindowsCheckBox();
    public ILabel CreateLabel() => new WindowsLabel();
}

public class WindowsButton : IButton
{
    private string _text = "Button";
    private Action _clickHandler;
    
    public void Render()
    {
        Console.WriteLine($"[Windows Button: {_text}]");
    }
    
    public void OnClick(Action callback)
    {
        _clickHandler = callback;
        Console.WriteLine($"Windows button '{_text}' click handler registered");
    }
    
    public void SetText(string text)
    {
        _text = text;
    }
}

public class WindowsTextBox : ITextBox
{
    private string _value = "";
    private string _placeholder = "";
    
    public void Render()
    {
        var display = !string.IsNullOrEmpty(_value) ? _value : $"[{_placeholder}]";
        Console.WriteLine($"Windows TextBox: [{display}]");
    }
    
    public void SetPlaceholder(string placeholder)
    {
        _placeholder = placeholder;
    }
    
    public string GetValue() => _value;
    
    public void SetValue(string value)
    {
        _value = value;
    }
}

// macOS implementation family  
public class MacOSUIFactory : IUIComponentFactory
{
    public IButton CreateButton() => new MacOSButton();
    public ITextBox CreateTextBox() => new MacOSTextBox();
    public ICheckBox CreateCheckBox() => new MacOSCheckBox();
    public ILabel CreateLabel() => new MacOSLabel();
}

public class MacOSButton : IButton
{
    private string _text = "Button";
    
    public void Render()
    {
        Console.WriteLine($"◉ {_text} ◉  (macOS style)");
    }
    
    public void OnClick(Action callback)
    {
        Console.WriteLine($"macOS button '{_text}' registered for clicks");
    }
    
    public void SetText(string text)
    {
        _text = text;
    }
}

// UI Application using Abstract Factory
public class UIApplication
{
    private readonly IUIComponentFactory _componentFactory;
    
    public UIApplication(IUIComponentFactory componentFactory)
    {
        _componentFactory = componentFactory;
    }
    
    public void CreateLoginForm()
    {
        // Create consistent family of UI components
        var usernameLabel = _componentFactory.CreateLabel();
        var usernameTextBox = _componentFactory.CreateTextBox();
        var passwordLabel = _componentFactory.CreateLabel();
        var passwordTextBox = _componentFactory.CreateTextBox();
        var loginButton = _componentFactory.CreateButton();
        var rememberCheckBox = _componentFactory.CreateCheckBox();
        
        // Configure components
        usernameTextBox.SetPlaceholder("Enter username");
        passwordTextBox.SetPlaceholder("Enter password");
        loginButton.SetText("Login");
        
        // Render form
        Console.WriteLine("=== Login Form ===");
        usernameLabel.SetText("Username:");
        usernameLabel.Render();
        usernameTextBox.Render();
        
        passwordLabel.SetText("Password:");
        passwordLabel.Render();
        passwordTextBox.Render();
        
        rememberCheckBox.SetText("Remember me");
        rememberCheckBox.Render();
        
        loginButton.Render();
        Console.WriteLine("==================");
    }
}

// Factory selection based on environment
public static class UIFactoryProvider
{
    public static IUIComponentFactory GetFactory()
    {
        if (OperatingSystem.IsWindows())
        {
            return new WindowsUIFactory();
        }
        else if (OperatingSystem.IsMacOS())
        {
            return new MacOSUIFactory();
        }
        else
        {
            return new LinuxUIFactory(); // Would implement similar pattern
        }
    }
}
```

### Practical Implementation (8 minutes)

#### Factory Pattern Best Practices

```csharp
// Configuration-driven factory with dependency injection
public interface IProcessorFactory
{
    T CreateProcessor<T>(string processorType) where T : class;
    IEnumerable<string> GetAvailableProcessors<T>();
}

public class ConfigurableProcessorFactory : IProcessorFactory
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ProcessorConfiguration _config;
    
    public ConfigurableProcessorFactory(IServiceProvider serviceProvider, ProcessorConfiguration config)
    {
        _serviceProvider = serviceProvider;
        _config = config;
    }
    
    public T CreateProcessor<T>(string processorType) where T : class
    {
        var processorConfig = _config.GetProcessorConfig<T>(processorType);
        if (processorConfig == null)
        {
            throw new InvalidOperationException($"Processor type '{processorType}' not configured for {typeof(T).Name}");
        }
        
        var processor = _serviceProvider.GetService(processorConfig.ImplementationType) as T;
        if (processor == null)
        {
            throw new InvalidOperationException($"Could not create processor of type {processorConfig.ImplementationType}");
        }
        
        return processor;
    }
    
    public IEnumerable<string> GetAvailableProcessors<T>()
    {
        return _config.GetAvailableProcessorTypes<T>();
    }
}

// Dependency injection setup
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddFactoryPatterns(this IServiceCollection services)
    {
        // Register factories
        services.AddSingleton<IProcessorFactory, ConfigurableProcessorFactory>();
        services.AddSingleton<IUIComponentFactory, UIFactoryProvider.GetFactory>;
        
        // Register concrete implementations
        services.AddTransient<CreditCardProcessor>();
        services.AddTransient<PayPalProcessor>();
        services.AddTransient<BankTransferProcessor>();
        
        services.AddTransient<PdfDocumentProcessor>();
        services.AddTransient<WordDocumentProcessor>();
        
        return services;
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Factory Pattern Benefits**:

- ✅ **Loose Coupling**: Clients don't depend on concrete classes
- ✅ **Single Responsibility**: Object creation logic centralized
- ✅ **Open/Closed**: Easy to add new product types
- ✅ **Testability**: Can inject mock factories for testing

**When to Use Factory Patterns**:

- **Simple Factory**: Few related classes, simple creation logic
- **Factory Method**: Subclasses need different object creation behavior
- **Abstract Factory**: Need families of related objects (cross-platform, themes)

**Factory Pattern Guidelines**:

1. **Use when object creation is complex** or varies based on context
2. **Combine with dependency injection** for ultimate flexibility  
3. **Keep factory interfaces simple** - focus on creation, not configuration
4. **Consider configuration-driven factories** for runtime flexibility

### Next Steps

**Immediate Actions**:

- Implement factory patterns in your current projects
- Practice with dependency injection containers
- Continue to Part 2: **Builder Pattern**

**Advanced Applications**:

- Plugin architectures using factories
- Microservice communication patterns
- Configuration-driven system composition

## 🔗 Related Topics

**Prerequisites**: SOLID Principles, Dependency injection fundamentals  
**Builds Upon**: Dependency Inversion Principle, Open/Closed Principle  
**Enables**: Builder Pattern (Part 2), Plugin architectures, Flexible system design  
**Related**: Strategy Pattern, Template Method Pattern, Abstract Factory variations
