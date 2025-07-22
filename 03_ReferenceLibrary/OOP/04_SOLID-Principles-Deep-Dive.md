# 🏗️ SOLID Principles Deep Dive

**Advanced OOP Design Principles with C# Implementation**

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

## 🎯 S - Single Responsibility Principle

### **Definition**

> **"A class should have only one reason to change."** - Robert C. Martin

**Core Concept**: Each class should have one job, one purpose, one responsibility.

### **❌ SRP Violation Example**

```csharp
// BAD - Multiple responsibilities in one class
public class User
{
    public string Name { get; set; }
    public string Email { get; set; }

    // Responsibility 1: User data management
    public void UpdateProfile(string name, string email)
    {
        Name = name;
        Email = email;
    }

    // Responsibility 2: Email sending (should be separate!)
    public void SendWelcomeEmail()
    {
        var smtpClient = new SmtpClient();
        // Email sending logic...
    }

    // Responsibility 3: Data persistence (should be separate!)
    public void SaveToDatabase()
    {
        using var connection = new SqlConnection("connectionString");
        // Database saving logic...
    }

    // Responsibility 4: Email validation (should be separate!)
    public bool IsValidEmail(string email)
    {
        return email.Contains("@") && email.Contains(".");
    }
}
```

### **✅ SRP Compliant Solution**

```csharp
// GOOD - Single responsibility: User data model
public class User
{
    public string Name { get; set; }
    public string Email { get; set; }

    public void UpdateProfile(string name, string email)
    {
        Name = name;
        Email = email;
    }
}

// GOOD - Single responsibility: Email operations
public class EmailService
{
    public void SendWelcomeEmail(User user)
    {
        var smtpClient = new SmtpClient();
        // Email sending logic...
    }
}

// GOOD - Single responsibility: Data persistence
public class UserRepository
{
    public void Save(User user)
    {
        using var connection = new SqlConnection("connectionString");
        // Database saving logic...
    }
}

// GOOD - Single responsibility: Email validation
public class EmailValidator
{
    public bool IsValid(string email)
    {
        return email.Contains("@") && email.Contains(".");
    }
}
```

### **SRP Benefits**

- ✅ **Easier Testing**: Each class has focused, testable behavior
- ✅ **Better Maintainability**: Changes affect only relevant classes
- ✅ **Improved Readability**: Clear purpose and focused functionality
- ✅ **Reduced Coupling**: Classes depend on fewer things

---

## 🔐 O - Open/Closed Principle

### **Definition**

> **"Software entities should be open for extension but closed for modification."** - Bertrand Meyer

**Core Concept**: Add new functionality by extending existing code, not by changing it.

### **❌ OCP Violation Example**

```csharp
// BAD - Adding new shapes requires modifying existing code
public class AreaCalculator
{
    public double CalculateArea(object shape)
    {
        if (shape is Rectangle rectangle)
        {
            return rectangle.Width * rectangle.Height;
        }
        else if (shape is Circle circle)
        {
            return Math.PI * circle.Radius * circle.Radius;
        }
        // Problem: Adding Triangle requires modifying this method!
        else if (shape is Triangle triangle)
        {
            return 0.5 * triangle.Base * triangle.Height;
        }
        
        throw new ArgumentException("Unknown shape type");
    }
}
```

### **✅ OCP Compliant Solution**

```csharp
// GOOD - Open for extension, closed for modification
public abstract class Shape
{
    public abstract double CalculateArea();
}

public class Rectangle : Shape
{
    public double Width { get; set; }
    public double Height { get; set; }

    public override double CalculateArea() => Width * Height;
}

public class Circle : Shape
{
    public double Radius { get; set; }

    public override double CalculateArea() => Math.PI * Radius * Radius;
}

// NEW shapes can be added without modifying existing code
public class Triangle : Shape
{
    public double Base { get; set; }
    public double Height { get; set; }

    public override double CalculateArea() => 0.5 * Base * Height;
}

// Calculator doesn't need to change when new shapes are added
public class AreaCalculator
{
    public double CalculateArea(Shape shape) => shape.CalculateArea();
}
```

### **Modern C# OCP with Strategy Pattern**

```csharp
// Interface for extensible behavior
public interface IDiscountStrategy
{
    decimal CalculateDiscount(decimal amount);
}

// Concrete strategies
public class RegularCustomerDiscount : IDiscountStrategy
{
    public decimal CalculateDiscount(decimal amount) => amount * 0.05m;
}

public class PremiumCustomerDiscount : IDiscountStrategy
{
    public decimal CalculateDiscount(decimal amount) => amount * 0.15m;
}

// Context class - closed for modification, open for extension
public class PriceCalculator
{
    private readonly IDiscountStrategy _discountStrategy;

    public PriceCalculator(IDiscountStrategy discountStrategy)
    {
        _discountStrategy = discountStrategy;
    }

    public decimal CalculatePrice(decimal basePrice)
    {
        var discount = _discountStrategy.CalculateDiscount(basePrice);
        return basePrice - discount;
    }
}
```

---

## 🔄 L - Liskov Substitution Principle

### **Definition**

> **"Objects of a superclass should be replaceable with objects of a subclass without breaking the application."** - Barbara Liskov

**Core Concept**: Derived classes must be substitutable for their base classes.

### **❌ LSP Violation Example**

```csharp
// BAD - Rectangle-Square violation of LSP
public class Rectangle
{
    public virtual int Width { get; set; }
    public virtual int Height { get; set; }

    public int CalculateArea() => Width * Height;
}

public class Square : Rectangle
{
    // Violates LSP - changing width affects height unexpectedly
    public override int Width
    {
        get => base.Width;
        set
        {
            base.Width = value;
            base.Height = value; // Side effect!
        }
    }

    public override int Height
    {
        get => base.Height;
        set
        {
            base.Height = value;
            base.Width = value; // Side effect!
        }
    }
}

// This code breaks with Square - violates client expectations
public void TestRectangle(Rectangle rectangle)
{
    rectangle.Width = 5;
    rectangle.Height = 10;
    
    // Expected: 50, but with Square: 100 (unexpected behavior!)
    Assert.AreEqual(50, rectangle.CalculateArea());
}
```

### **✅ LSP Compliant Solution**

```csharp
// GOOD - Proper abstraction that supports substitution
public abstract class Shape
{
    public abstract int CalculateArea();
}

public class Rectangle : Shape
{
    public int Width { get; set; }
    public int Height { get; set; }

    public override int CalculateArea() => Width * Height;
}

public class Square : Shape
{
    public int Side { get; set; }

    public override int CalculateArea() => Side * Side;
}

// Works correctly with any Shape subclass
public void TestShape(Shape shape)
{
    var area = shape.CalculateArea();
    // No unexpected side effects, behavior is predictable
}
```

### **LSP with Preconditions and Postconditions**

```csharp
// Base class contract
public abstract class FileProcessor
{
    // Precondition: file must exist and be readable
    // Postcondition: returns non-null result
    public abstract string ProcessFile(string filePath);
    
    protected void ValidateFile(string filePath)
    {
        if (!File.Exists(filePath))
            throw new FileNotFoundException();
    }
}

// GOOD - Maintains base class contract
public class TextFileProcessor : FileProcessor
{
    public override string ProcessFile(string filePath)
    {
        ValidateFile(filePath); // Honors precondition
        var content = File.ReadAllText(filePath);
        return content.ToUpper(); // Always returns non-null (postcondition)
    }
}

// BAD - Violates LSP by weakening postcondition
public class BrokenFileProcessor : FileProcessor
{
    public override string ProcessFile(string filePath)
    {
        ValidateFile(filePath);
        return null; // Violates postcondition!
    }
}
```

---

## 🎭 I - Interface Segregation Principle

### **Definition**

> **"No client should be forced to depend on methods it does not use."** - Robert C. Martin

**Core Concept**: Many specific interfaces are better than one general-purpose interface.

### **❌ ISP Violation Example**

```csharp
// BAD - Fat interface forcing unnecessary dependencies
public interface IWorker
{
    void Work();
    void Eat();
    void Sleep();
}

// Robot forced to implement irrelevant methods
public class Robot : IWorker
{
    public void Work() => Console.WriteLine("Robot working");
    
    // Robots don't eat or sleep - forced to implement anyway!
    public void Eat() => throw new NotImplementedException();
    public void Sleep() => throw new NotImplementedException();
}

public class Human : IWorker
{
    public void Work() => Console.WriteLine("Human working");
    public void Eat() => Console.WriteLine("Human eating");
    public void Sleep() => Console.WriteLine("Human sleeping");
}
```

### **✅ ISP Compliant Solution**

```csharp
// GOOD - Segregated interfaces based on client needs
public interface IWorkable
{
    void Work();
}

public interface IFeedable
{
    void Eat();
}

public interface ISleepable
{
    void Sleep();
}

// Robot only implements what it needs
public class Robot : IWorkable
{
    public void Work() => Console.WriteLine("Robot working");
}

// Human implements all relevant interfaces
public class Human : IWorkable, IFeedable, ISleepable
{
    public void Work() => Console.WriteLine("Human working");
    public void Eat() => Console.WriteLine("Human eating");
    public void Sleep() => Console.WriteLine("Human sleeping");
}

// Clients depend only on what they need
public class WorkManager
{
    public void ManageWork(IWorkable worker) => worker.Work();
}

public class CafeteriaManager
{
    public void ServeMeal(IFeedable creature) => creature.Eat();
}
```

### **Real-World ISP Example: Data Access**

```csharp
// Instead of fat interface
public interface IRepository
{
    Task<T> GetByIdAsync<T>(int id);
    Task<IEnumerable<T>> GetAllAsync<T>();
    Task AddAsync<T>(T entity);
    Task UpdateAsync<T>(T entity);
    Task DeleteAsync<T>(int id);
    Task<int> CountAsync<T>();
    Task BulkInsertAsync<T>(IEnumerable<T> entities);
    Task<IEnumerable<T>> SearchAsync<T>(string query);
}

// Better: Segregated interfaces
public interface IReadOnlyRepository<T>
{
    Task<T> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<int> CountAsync();
}

public interface IWriteRepository<T>
{
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

public interface ISearchableRepository<T>
{
    Task<IEnumerable<T>> SearchAsync(string query);
}

public interface IBulkRepository<T>
{
    Task BulkInsertAsync(IEnumerable<T> entities);
}

// Clients use only what they need
public class ReportService
{
    private readonly IReadOnlyRepository<Order> _orderRepository;

    public ReportService(IReadOnlyRepository<Order> orderRepository)
    {
        _orderRepository = orderRepository; // Only read operations
    }
}
```

---

## 🔗 D - Dependency Inversion Principle

### **Definition**

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

### **DI Container Configuration**

```csharp
// Program.cs - Dependency injection setup
public class Program
{
    public static void Main(string[] args)
    {
        var services = new ServiceCollection();
        
        // Register dependencies
        services.AddScoped<IOrderRepository, SqlOrderRepository>();
        services.AddScoped<IEmailService, SmtpEmailService>();
        services.AddScoped<OrderService>();
        
        // Configuration
        services.AddSingleton<SmtpClient>();
        services.AddSingleton("connectionString");
        
        var serviceProvider = services.BuildServiceProvider();
        
        // Resolve high-level service
        var orderService = serviceProvider.GetService<OrderService>();
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
    public List<OrderItem> Items { get; set; } = new();
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
    Task<Order> GetByIdAsync(int id);
}

public interface IInventoryService
{
    Task<bool> IsAvailableAsync(string productName, int quantity);
    Task ReserveAsync(string productName, int quantity);
}

public interface IPaymentProcessor
{
    Task<bool> ProcessPaymentAsync(decimal amount, string paymentMethod);
}

// D - Dependency Inversion: High-level depends on abstractions
public class OrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IInventoryService _inventoryService;
    private readonly IPaymentProcessor _paymentProcessor;
    private readonly IDiscountCalculator _discountCalculator;
    private readonly NotificationSender _notificationSender;

    public OrderService(
        IOrderRepository orderRepository,
        IInventoryService inventoryService,
        IPaymentProcessor paymentProcessor,
        IDiscountCalculator discountCalculator,
        NotificationSender notificationSender)
    {
        _orderRepository = orderRepository;
        _inventoryService = inventoryService;
        _paymentProcessor = paymentProcessor;
        _discountCalculator = discountCalculator;
        _notificationSender = notificationSender;
    }

    public async Task<bool> ProcessOrderAsync(Order order)
    {
        // Check inventory
        foreach (var item in order.Items)
        {
            if (!await _inventoryService.IsAvailableAsync(item.ProductName, item.Quantity))
                return false;
        }

        // Calculate discount
        var discount = _discountCalculator.CalculateDiscount(order);
        var finalAmount = order.Total - discount;

        // Process payment
        if (!await _paymentProcessor.ProcessPaymentAsync(finalAmount, "CreditCard"))
            return false;

        // Reserve inventory
        foreach (var item in order.Items)
        {
            await _inventoryService.ReserveAsync(item.ProductName, item.Quantity);
        }

        // Save order
        await _orderRepository.SaveAsync(order);

        // Send notification
        await _notificationSender.SendAsync(
            order.CustomerEmail, 
            $"Order confirmed. Total: ${finalAmount:F2}");

        return true;
    }
}
```

---

## 🚀 SOLID Benefits and Testing

### **Benefits of SOLID Design**

```csharp
// Easy to test with mocks
[Test]
public async Task ProcessOrder_ShouldReturnTrue_WhenAllServicesSucceed()
{
    // Arrange
    var mockOrderRepo = new Mock<IOrderRepository>();
    var mockInventory = new Mock<IInventoryService>();
    var mockPayment = new Mock<IPaymentProcessor>();
    var mockDiscount = new Mock<IDiscountCalculator>();
    var mockNotification = new Mock<NotificationSender>();

    mockInventory.Setup(x => x.IsAvailableAsync(It.IsAny<string>(), It.IsAny<int>()))
                .ReturnsAsync(true);
    mockPayment.Setup(x => x.ProcessPaymentAsync(It.IsAny<decimal>(), It.IsAny<string>()))
              .ReturnsAsync(true);
    mockDiscount.Setup(x => x.CalculateDiscount(It.IsAny<Order>()))
               .Returns(10m);

    var orderService = new OrderService(
        mockOrderRepo.Object,
        mockInventory.Object,
        mockPayment.Object,
        mockDiscount.Object,
        mockNotification.Object);

    var order = new Order { Total = 100m, CustomerEmail = "test@example.com" };

    // Act
    var result = await orderService.ProcessOrderAsync(order);

    // Assert
    Assert.IsTrue(result);
    mockOrderRepo.Verify(x => x.SaveAsync(order), Times.Once);
    mockNotification.Verify(x => x.SendAsync(It.IsAny<string>(), It.IsAny<string>()), Times.Once);
}
```

### **SOLID Violations: Common Warning Signs**

```csharp
// Warning signs of SOLID violations:

// ❌ SRP Violation
public class CustomerService
{
    public void CreateCustomer() { }
    public void SendEmail() { }      // Different responsibility
    public void ValidateData() { }   // Different responsibility
    public void LogActivity() { }    // Different responsibility
}

// ❌ OCP Violation
public class ReportGenerator
{
    public void GenerateReport(string type)
    {
        if (type == "PDF") { /* PDF logic */ }
        else if (type == "Excel") { /* Excel logic */ }
        // Adding new format requires modifying this method
    }
}

// ❌ LSP Violation
public class Bird { public virtual void Fly() { } }
public class Penguin : Bird 
{ 
    public override void Fly() => throw new NotSupportedException(); 
}

// ❌ ISP Violation
public interface IAnimal 
{ 
    void Walk(); 
    void Swim(); 
    void Fly(); // Not all animals can do all actions
}

// ❌ DIP Violation
public class OrderProcessor
{
    private SqlDatabase db = new SqlDatabase(); // Direct dependency
}
```

---

## 🎯 Quick Reference Summary

### **SOLID Checklist**

**Single Responsibility:**
- [ ] Each class has one reason to change
- [ ] Class name clearly describes its purpose
- [ ] No mixed concerns (data + business logic + persistence)

**Open/Closed:**
- [ ] New features added through extension, not modification
- [ ] Polymorphism used for varying behavior
- [ ] Abstract base classes or interfaces for extension points

**Liskov Substitution:**
- [ ] Derived classes can replace base classes without breaking code
- [ ] Preconditions not strengthened in derived classes
- [ ] Postconditions not weakened in derived classes

**Interface Segregation:**
- [ ] Interfaces are focused on specific client needs
- [ ] No forced implementation of unused methods
- [ ] Multiple small interfaces over one large interface

**Dependency Inversion:**
- [ ] High-level modules depend on abstractions
- [ ] Dependencies injected rather than created internally
- [ ] Easy to mock dependencies for testing

### **SOLID Quick Questions**

1. **Can I test this class in isolation?** (DIP check)
2. **If requirements change, how many classes need modification?** (SRP/OCP check)
3. **Can I replace this with a subclass without breaking anything?** (LSP check)
4. **Are clients forced to depend on methods they don't use?** (ISP check)

---

## 🔗 Integration with OOP Fundamentals

### **SOLID Enhances OOP Pillars**

- **Encapsulation** + **SRP** = Well-defined class boundaries
- **Abstraction** + **DIP** = Depend on interfaces, not implementations
- **Inheritance** + **LSP** = Proper substitution behavior
- **Polymorphism** + **OCP** = Extensible behavior without modification

### **Next Steps**

- **Apply SOLID to existing code**: Refactor one principle at a time
- **Design new features with SOLID**: Use as design guidelines
- **Practice with examples**: Build small projects applying all principles
- **Advanced topics**: Explore dependency injection frameworks, architectural patterns

---

_📝 **Focus**: Practical application of SOLID principles in modern C# development for maintainable, testable, and extensible code_
