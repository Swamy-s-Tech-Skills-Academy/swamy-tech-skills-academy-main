# 🏗️ SOLID Principles Deep Dive - Part F

Advanced OOP Design Principles with C# Implementation

> 📖 **12-minute deep dive** | 🎯 **Focus**: SOLID principles mastery | 🏗️ **Advanced**: Beyond basic OOP concepts

## ✅ **SOLID Coverage Map**

This guide provides **comprehensive understanding and practical application** of SOLID principles in modern C# development:

### 🎯 **Single Responsibility Principle (SRP)**

✅ Class responsibility definition and boundaries
✅ Refactoring techniques for SRP violations
✅ Real-world examples and anti-patterns
✅ Testing implications of good SRP design

### 🔐 **Open/Closed Principle (OCP)**

✅ Extension without modification strategies
✅ Strategy pattern and polymorphism application
✅ Plugin architecture examples
✅ Modern C# features supporting OCP

### 🔄 **Liskov Substitution Principle (LSP)**

✅ Behavioral subtyping rules
✅ Contract preservation in inheritance
✅ Common LSP violations and fixes
✅ Interface design for substitutability

### 🎭 **Interface Segregation Principle (ISP)**

✅ Client-specific interface design
✅ Fat interface problems and solutions
✅ Role-based interface modeling
✅ Dependency injection implications

### 🔗 **Dependency Inversion Principle (DIP)**

✅ Abstraction over concretion
✅ Dependency injection patterns
✅ IoC container integration
✅ Testability and maintainability benefits

---

## Part F of 6

Previous: [04_SOLID-Principles-Deep-Dive-PartE.md](04_SOLID-Principles-Deep-Dive-PartE.md)

---

### **DI Container Configuration**

```csharp
// Program.cs - Dependency injection setup
public class Program
{
    public static void Main(string[] args)
    {
        var services = new ServiceCollection();

        // Register dependencies
        services.AddScoped`IOrderRepository, SqlOrderRepository`();
        services.AddScoped`IEmailService, SmtpEmailService`();
        services.AddScoped`OrderService`();

        // Configuration
        services.AddSingleton`SmtpClient`();
        services.AddSingleton("connectionString");

        var serviceProvider = services.BuildServiceProvider();

        // Resolve high-level service
        var orderService = serviceProvider.GetService`OrderService`();
    }
}
```

---

## 🎯 SOLID in Practice: Complete Example

### **E-commerce Order Processing System**

```csharp
// S - Single Responsibility: Each class has one job
public class Order
{
    public int Id { get; set; }
    public string CustomerEmail { get; set; }
    public decimal Total { get; set; }
    public List`OrderItem` Items { get; set; } = new();
}

public class OrderItem
{
    public string ProductName { get; set; }
    public decimal Price { get; set; }
    public int Quantity { get; set; }
}

// O - Open/Closed: Extensible discount strategies
public interface IDiscountCalculator
{
    decimal CalculateDiscount(Order order);
}

public class RegularDiscount : IDiscountCalculator
{
    public decimal CalculateDiscount(Order order) => order.Total * 0.05m;
}

public class PremiumDiscount : IDiscountCalculator
{
    public decimal CalculateDiscount(Order order) => order.Total * 0.15m;
}

// L - Liskov: Proper inheritance hierarchy
public abstract class NotificationSender
{
    public abstract Task SendAsync(string recipient, string message);
}

public class EmailNotificationSender : NotificationSender
{
    public override async Task SendAsync(string recipient, string message)
    {
        // Email implementation
        await Task.Delay(100); // Simulate async work
    }
}

public class SmsNotificationSender : NotificationSender
{
    public override async Task SendAsync(string recipient, string message)
    {
        // SMS implementation
        await Task.Delay(50); // Simulate async work
    }
}

// I - Interface Segregation: Focused interfaces
public interface IOrderRepository
{
    Task SaveAsync(Order order);
    Task`Order` GetByIdAsync(int id);
}

public interface IInventoryService
{
    Task`bool` IsAvailableAsync(string productName, int quantity);
    Task ReserveAsync(string productName, int quantity);
}

public interface IPaymentProcessor
{
    Task`bool` ProcessPaymentAsync(decimal amount, string paymentMethod);
}

// D - Dependency Inversion: High-level depends on abstractions
public class OrderService
{
    private readonly IOrderRepository`_orderRepository;
    private readonly IInventoryService`_inventoryService;
    private readonly IPaymentProcessor`_paymentProcessor;
    private readonly IDiscountCalculator`_discountCalculator;
    private readonly NotificationSender`_notificationSender;

    public OrderService(

