# 🏗️ SOLID Principles Deep Dive - Part E

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

**Part E of 6**

Previous: [04_SOLID-Principles-Deep-Dive-PartD.md](04_SOLID-Principles-Deep-Dive-PartD.md)
Next: [04_SOLID-Principles-Deep-Dive-PartF.md](04_SOLID-Principles-Deep-Dive-PartF.md)

---

    }
}
```

---

## 🔗 D - Dependency Inversion Principle

### Definition and Goal (DIP)

> **"High-level modules should not depend on low-level modules. Both should depend on abstractions."** - Robert C. Martin

**Core Concept**: Depend on abstractions, not concretions.

### **❌ DIP Violation Example**

```csharp
// BAD - High-level class depends on low-level implementation
public class EmailService
{
    // Direct dependency on concrete implementation
    private readonly SmtpClient _smtpClient = new SmtpClient();

    public void SendEmail(string to, string subject, string body)
    {
        _smtpClient.Send(to, subject, body);
        // Hard to test, hard to change email provider
    }
}

public class OrderService
{
    // Direct dependencies on concrete classes
    private readonly SqlOrderRepository _orderRepository = new();
    private readonly EmailService _emailService = new();

    public void ProcessOrder(Order order)
    {
        _orderRepository.Save(order);
        _emailService.SendEmail(order.CustomerEmail, "Order Confirmation", "...");
        // Tightly coupled, hard to test
    }
}
```

### **✅ DIP Compliant Solution**

```csharp
// GOOD - Depend on abstractions
public interface IEmailService
{
    Task SendEmailAsync(string to, string subject, string body);
}

public interface IOrderRepository
{
    Task SaveAsync(Order order);
    Task<Order> GetByIdAsync(int id);
}

// Low-level modules implement abstractions
public class SmtpEmailService : IEmailService
{
    private readonly SmtpClient _smtpClient;

    public SmtpEmailService(SmtpClient smtpClient)
    {
        _smtpClient = smtpClient;
    }

    public async Task SendEmailAsync(string to, string subject, string body)
    {
        await _smtpClient.SendMailAsync(to, subject, body);
    }
}

public class SqlOrderRepository : IOrderRepository
{
    private readonly string _connectionString;

    public SqlOrderRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task SaveAsync(Order order)
    {
        // SQL implementation
    }

    public async Task<Order> GetByIdAsync(int id)
    {
        // SQL implementation
        return new Order();
    }
}

// High-level module depends only on abstractions
public class OrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IEmailService _emailService;

    public OrderService(IOrderRepository orderRepository, IEmailService emailService)
    {
        _orderRepository = orderRepository;
        _emailService = emailService;
    }

    public async Task ProcessOrderAsync(Order order)
    {
        await _orderRepository.SaveAsync(order);
        await _emailService.SendEmailAsync(
            order.CustomerEmail,
            "Order Confirmation",
            "Your order has been processed");
    }
}
```

