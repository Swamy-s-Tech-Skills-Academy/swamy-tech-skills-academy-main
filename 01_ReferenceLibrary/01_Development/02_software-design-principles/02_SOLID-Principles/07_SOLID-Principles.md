# 07_SOLID-Principles

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Basic OOP concepts, C# fundamentals, Clean Architecture basics  
**Estimated Time**: 2-3 hours  

## 🎯 Learning Objectives

By the end of this module, you will understand:

- SOLID principles and their practical application in C# development
- How to identify and refactor code violations of each principle
- Real-world scenarios where each principle provides maximum value
- Integration of SOLID principles with Clean Architecture patterns
- Code review techniques using SOLID principles as quality gates

## 📋 Module Contents

### 1. SOLID Principles Foundation

SOLID principles are five fundamental design principles that make software designs more understandable, flexible, and maintainable. They form the foundation of object-oriented design and are essential for building scalable applications.

#### Core Philosophy

```text
┌─────────────────────────────────────────────────────────────┐
│                    SOLID Principles Impact                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Maintainable] ──> [Testable] ──> [Extensible]            │
│       │                 │               │                   │
│       │                 │               │                   │
│   Reduced Tech       Easy Unit       Future-Proof          │
│      Debt           Testing         Architecture            │
│                                                             │
│  Benefits:                                                 │
│  • Lower development costs                                 │
│  • Faster feature delivery                                │
│  • Reduced bug rates                                      │
│  • Improved team productivity                             │
└─────────────────────────────────────────────────────────────┘
```

#### SOLID Principles Overview

| Principle | Focus | Key Question | Memory Aid |
|-----------|-------|--------------|------------|
| **S**RP | Single Responsibility | "What's this class's ONE job?" | One class, one purpose |
| **O**CP | Open/Closed | "Can I extend without editing?" | Open for extension, closed for modification |
| **L**SP | Liskov Substitution | "Can subclasses replace the parent?" | Child must honor parent's contract |
| **I**SP | Interface Segregation | "Do I need all these methods?" | Split fat interfaces into lean ones |
| **D**IP | Dependency Inversion | "Am I depending on abstractions?" | Depend on interfaces, not concrete classes |

### 2. Single Responsibility Principle (SRP)

**Definition**: A class should have only ONE reason to change.

#### Understanding SRP

SRP is about cohesion - ensuring that a class has a single, well-defined purpose. When a class has multiple responsibilities, changes to one responsibility can affect or break the other responsibilities.

#### Identifying SRP Violations

```csharp
// ❌ SRP Violation - UserManager does too much
public class UserManager
{
    private readonly string _connectionString;
    private readonly SmtpClient _smtpClient;

    public UserManager(string connectionString, SmtpClient smtpClient)
    {
        _connectionString = connectionString;
        _smtpClient = smtpClient;
    }

    // Responsibility 1: Data Access
    public User GetUser(int userId)
    {
        using var connection = new SqlConnection(_connectionString);
        var command = new SqlCommand("SELECT * FROM Users WHERE Id = @id", connection);
        command.Parameters.AddWithValue("@id", userId);
        
        connection.Open();
        var reader = command.ExecuteReader();
        
        if (reader.Read())
        {
            return new User
            {
                Id = (int)reader["Id"],
                Email = reader["Email"].ToString(),
                FirstName = reader["FirstName"].ToString(),
                LastName = reader["LastName"].ToString()
            };
        }
        return null;
    }

    // Responsibility 2: Business Logic
    public bool IsUserActive(User user)
    {
        return user.LastLoginDate > DateTime.Now.AddDays(-30) && 
               !user.IsDeactivated;
    }

    // Responsibility 3: Notification
    public void SendWelcomeEmail(User user)
    {
        var message = new MailMessage
        {
            To = { user.Email },
            Subject = "Welcome!",
            Body = $"Welcome {user.FirstName}!"
        };
        
        _smtpClient.Send(message);
    }

    // Responsibility 4: Validation
    public List<string> ValidateUser(User user)
    {
        var errors = new List<string>();
        
        if (string.IsNullOrEmpty(user.Email))
            errors.Add("Email is required");
            
        if (string.IsNullOrEmpty(user.FirstName))
            errors.Add("First name is required");
            
        return errors;
    }
}
```

#### SRP-Compliant Solution

```csharp
// ✅ SRP Compliant - Separated responsibilities

// Responsibility 1: Data Access
public interface IUserRepository
{
    User GetUser(int userId);
    void SaveUser(User user);
}

public class UserRepository : IUserRepository
{
    private readonly string _connectionString;

    public UserRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    public User GetUser(int userId)
    {
        using var connection = new SqlConnection(_connectionString);
        var command = new SqlCommand("SELECT * FROM Users WHERE Id = @id", connection);
        command.Parameters.AddWithValue("@id", userId);
        
        connection.Open();
        var reader = command.ExecuteReader();
        
        if (reader.Read())
        {
            return new User
            {
                Id = (int)reader["Id"],
                Email = reader["Email"].ToString(),
                FirstName = reader["FirstName"].ToString(),
                LastName = reader["LastName"].ToString()
            };
        }
        return null;
    }

    public void SaveUser(User user)
    {
        // Implementation for saving user
    }
}

// Responsibility 2: Business Logic
public interface IUserService
{
    bool IsUserActive(User user);
}

public class UserService : IUserService
{
    public bool IsUserActive(User user)
    {
        return user.LastLoginDate > DateTime.Now.AddDays(-30) && 
               !user.IsDeactivated;
    }
}

// Responsibility 3: Notifications
public interface INotificationService
{
    void SendWelcomeEmail(User user);
}

public class EmailNotificationService : INotificationService
{
    private readonly SmtpClient _smtpClient;

    public EmailNotificationService(SmtpClient smtpClient)
    {
        _smtpClient = smtpClient;
    }

    public void SendWelcomeEmail(User user)
    {
        var message = new MailMessage
        {
            To = { user.Email },
            Subject = "Welcome!",
            Body = $"Welcome {user.FirstName}!"
        };
        
        _smtpClient.Send(message);
    }
}

// Responsibility 4: Validation
public interface IUserValidator
{
    List<string> ValidateUser(User user);
}

public class UserValidator : IUserValidator
{
    public List<string> ValidateUser(User user)
    {
        var errors = new List<string>();
        
        if (string.IsNullOrEmpty(user.Email))
            errors.Add("Email is required");
            
        if (string.IsNullOrEmpty(user.FirstName))
            errors.Add("First name is required");
            
        return errors;
    }
}

// Coordinator class that orchestrates the services
public class UserController
{
    private readonly IUserRepository _userRepository;
    private readonly IUserService _userService;
    private readonly INotificationService _notificationService;
    private readonly IUserValidator _userValidator;

    public UserController(
        IUserRepository userRepository,
        IUserService userService,
        INotificationService notificationService,
        IUserValidator userValidator)
    {
        _userRepository = userRepository;
        _userService = userService;
        _notificationService = notificationService;
        _userValidator = userValidator;
    }

    public void RegisterUser(User user)
    {
        var validationErrors = _userValidator.ValidateUser(user);
        if (validationErrors.Any())
        {
            throw new ValidationException(string.Join(", ", validationErrors));
        }

        _userRepository.SaveUser(user);
        _notificationService.SendWelcomeEmail(user);
    }
}
```

### 3. Open/Closed Principle (OCP)

**Definition**: Software entities should be open for extension but closed for modification.

#### Understanding OCP

OCP promotes designing systems that can be extended with new functionality without modifying existing code. This is achieved through abstraction and polymorphism.

#### OCP Violation Example

```csharp
// ❌ OCP Violation - Adding new shapes requires modifying existing code
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
        // Adding a new shape means modifying this method
        else if (shape is Triangle triangle)
        {
            return 0.5 * triangle.Base * triangle.Height;
        }
        
        throw new ArgumentException("Unknown shape type");
    }
}

public class Rectangle
{
    public double Width { get; set; }
    public double Height { get; set; }
}

public class Circle
{
    public double Radius { get; set; }
}
```

#### OCP-Compliant Solution

```csharp
// ✅ OCP Compliant - Extension without modification

public interface IShape
{
    double CalculateArea();
}

public class Rectangle : IShape
{
    public double Width { get; set; }
    public double Height { get; set; }

    public double CalculateArea()
    {
        return Width * Height;
    }
}

public class Circle : IShape
{
    public double Radius { get; set; }

    public double CalculateArea()
    {
        return Math.PI * Radius * Radius;
    }
}

// New shapes can be added without modifying existing code
public class Triangle : IShape
{
    public double Base { get; set; }
    public double Height { get; set; }

    public double CalculateArea()
    {
        return 0.5 * Base * Height;
    }
}

public class Hexagon : IShape
{
    public double SideLength { get; set; }

    public double CalculateArea()
    {
        return (3 * Math.Sqrt(3) / 2) * SideLength * SideLength;
    }
}

public class AreaCalculator
{
    public double CalculateArea(IShape shape)
    {
        return shape.CalculateArea();
    }

    public double CalculateTotalArea(IEnumerable<IShape> shapes)
    {
        return shapes.Sum(shape => shape.CalculateArea());
    }
}
```

#### Advanced OCP Example: Strategy Pattern

```csharp
// Payment processing system that's open for extension
public interface IPaymentProcessor
{
    Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request);
    bool CanProcess(PaymentType paymentType);
}

public class CreditCardPaymentProcessor : IPaymentProcessor
{
    public bool CanProcess(PaymentType paymentType)
    {
        return paymentType == PaymentType.CreditCard;
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        // Credit card processing logic
        await Task.Delay(100); // Simulate network call
        return new PaymentResult { Success = true, TransactionId = Guid.NewGuid().ToString() };
    }
}

public class PayPalPaymentProcessor : IPaymentProcessor
{
    public bool CanProcess(PaymentType paymentType)
    {
        return paymentType == PaymentType.PayPal;
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        // PayPal processing logic
        await Task.Delay(200); // Simulate network call
        return new PaymentResult { Success = true, TransactionId = Guid.NewGuid().ToString() };
    }
}

// New payment method - no existing code modification needed
public class CryptocurrencyPaymentProcessor : IPaymentProcessor
{
    public bool CanProcess(PaymentType paymentType)
    {
        return paymentType == PaymentType.Cryptocurrency;
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        // Cryptocurrency processing logic
        await Task.Delay(5000); // Simulate blockchain confirmation
        return new PaymentResult { Success = true, TransactionId = Guid.NewGuid().ToString() };
    }
}

public class PaymentService
{
    private readonly IEnumerable<IPaymentProcessor> _processors;

    public PaymentService(IEnumerable<IPaymentProcessor> processors)
    {
        _processors = processors;
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        var processor = _processors.FirstOrDefault(p => p.CanProcess(request.PaymentType));
        
        if (processor == null)
        {
            throw new NotSupportedException($"Payment type {request.PaymentType} is not supported");
        }

        return await processor.ProcessPaymentAsync(request);
    }
}
```

### 4. Liskov Substitution Principle (LSP)

**Definition**: Objects of a superclass should be replaceable with objects of its subclasses without breaking the application.

#### Understanding LSP

LSP ensures that inheritance hierarchies are designed correctly. Subclasses should enhance, not replace, the behavior of their parent classes.

#### LSP Violation Example

```csharp
// ❌ LSP Violation - Square breaks Rectangle's behavior
public class Rectangle
{
    public virtual double Width { get; set; }
    public virtual double Height { get; set; }

    public double CalculateArea()
    {
        return Width * Height;
    }
}

public class Square : Rectangle
{
    public override double Width
    {
        get => base.Width;
        set
        {
            base.Width = value;
            base.Height = value; // Violates LSP - unexpected side effect
        }
    }

    public override double Height
    {
        get => base.Height;
        set
        {
            base.Width = value; // Violates LSP - unexpected side effect
            base.Height = value;
        }
    }
}

// This code breaks when Square is used
public class RectangleTest
{
    public void TestRectangle(Rectangle rectangle)
    {
        rectangle.Width = 5;
        rectangle.Height = 10;
        
        // Expected: 50, but with Square it will be 100
        Console.WriteLine($"Area: {rectangle.CalculateArea()}");
    }
}
```

#### LSP-Compliant Solution

```csharp
// ✅ LSP Compliant - Proper abstraction hierarchy

public abstract class Shape
{
    public abstract double CalculateArea();
    public abstract double CalculatePerimeter();
}

public class Rectangle : Shape
{
    public double Width { get; set; }
    public double Height { get; set; }

    public Rectangle(double width, double height)
    {
        Width = width;
        Height = height;
    }

    public override double CalculateArea()
    {
        return Width * Height;
    }

    public override double CalculatePerimeter()
    {
        return 2 * (Width + Height);
    }
}

public class Square : Shape
{
    public double SideLength { get; set; }

    public Square(double sideLength)
    {
        SideLength = sideLength;
    }

    public override double CalculateArea()
    {
        return SideLength * SideLength;
    }

    public override double CalculatePerimeter()
    {
        return 4 * SideLength;
    }
}

// Now substitution works correctly
public class ShapeProcessor
{
    public void ProcessShape(Shape shape)
    {
        Console.WriteLine($"Area: {shape.CalculateArea()}");
        Console.WriteLine($"Perimeter: {shape.CalculatePerimeter()}");
    }
}
```

#### Advanced LSP Example: Bird Hierarchy

```csharp
// ❌ LSP Violation - Not all birds can fly
public abstract class Bird
{
    public abstract void Fly();
}

public class Eagle : Bird
{
    public override void Fly()
    {
        Console.WriteLine("Eagle soars high");
    }
}

public class Penguin : Bird
{
    public override void Fly()
    {
        throw new NotSupportedException("Penguins can't fly"); // LSP Violation
    }
}

// ✅ LSP Compliant - Proper hierarchy design
public abstract class Bird
{
    public abstract void Move();
    public abstract void Eat();
}

public abstract class FlyingBird : Bird
{
    public abstract void Fly();
    
    public override void Move()
    {
        Fly();
    }
}

public abstract class FlightlessBird : Bird
{
    public abstract void Walk();
    
    public override void Move()
    {
        Walk();
    }
}

public class Eagle : FlyingBird
{
    public override void Fly()
    {
        Console.WriteLine("Eagle soars high");
    }

    public override void Eat()
    {
        Console.WriteLine("Eagle hunts for prey");
    }
}

public class Penguin : FlightlessBird
{
    public override void Walk()
    {
        Console.WriteLine("Penguin waddles on ice");
    }

    public override void Eat()
    {
        Console.WriteLine("Penguin catches fish");
    }
}

public class BirdSanctuary
{
    public void LetBirdsMove(IEnumerable<Bird> birds)
    {
        foreach (var bird in birds)
        {
            bird.Move(); // Works correctly for all bird types
        }
    }
}
```

### 5. Interface Segregation Principle (ISP)

**Definition**: No client should be forced to depend on methods it doesn't use.

#### Understanding ISP

ISP promotes creating specific, focused interfaces rather than large, monolithic ones. This reduces coupling and makes the system more flexible.

#### ISP Violation Example

```csharp
// ❌ ISP Violation - Fat interface forces unnecessary dependencies
public interface IWorker
{
    void Work();
    void Eat();
    void Sleep();
    void ReceiveSalary();
    void TakeMedicalLeave();
    void AttendMeeting();
    void SubmitTimesheet();
}

// Robot worker forced to implement irrelevant methods
public class RobotWorker : IWorker
{
    public void Work()
    {
        Console.WriteLine("Robot working...");
    }

    public void Eat()
    {
        throw new NotSupportedException("Robots don't eat"); // ISP Violation
    }

    public void Sleep()
    {
        throw new NotSupportedException("Robots don't sleep"); // ISP Violation
    }

    public void ReceiveSalary()
    {
        throw new NotSupportedException("Robots don't receive salary"); // ISP Violation
    }

    public void TakeMedicalLeave()
    {
        throw new NotSupportedException("Robots don't take medical leave"); // ISP Violation
    }

    public void AttendMeeting()
    {
        throw new NotSupportedException("Robots don't attend meetings"); // ISP Violation
    }

    public void SubmitTimesheet()
    {
        Console.WriteLine("Robot timesheet auto-generated");
    }
}
```

#### ISP-Compliant Solution

```csharp
// ✅ ISP Compliant - Segregated interfaces

public interface IWorkable
{
    void Work();
}

public interface IEatable
{
    void Eat();
}

public interface ISleepable
{
    void Sleep();
}

public interface IPayrollManageable
{
    void ReceiveSalary();
}

public interface IMedicalLeaveManageable
{
    void TakeMedicalLeave();
}

public interface IMeetingAttendable
{
    void AttendMeeting();
}

public interface ITimesheetSubmittable
{
    void SubmitTimesheet();
}

// Human worker implements relevant interfaces
public class HumanWorker : IWorkable, IEatable, ISleepable, IPayrollManageable, 
                          IMedicalLeaveManageable, IMeetingAttendable, ITimesheetSubmittable
{
    public void Work()
    {
        Console.WriteLine("Human working...");
    }

    public void Eat()
    {
        Console.WriteLine("Human eating lunch...");
    }

    public void Sleep()
    {
        Console.WriteLine("Human sleeping...");
    }

    public void ReceiveSalary()
    {
        Console.WriteLine("Human receiving salary...");
    }

    public void TakeMedicalLeave()
    {
        Console.WriteLine("Human taking medical leave...");
    }

    public void AttendMeeting()
    {
        Console.WriteLine("Human attending meeting...");
    }

    public void SubmitTimesheet()
    {
        Console.WriteLine("Human submitting timesheet...");
    }
}

// Robot worker only implements what it needs
public class RobotWorker : IWorkable, ITimesheetSubmittable
{
    public void Work()
    {
        Console.WriteLine("Robot working...");
    }

    public void SubmitTimesheet()
    {
        Console.WriteLine("Robot timesheet auto-generated");
    }
}

// Freelancer has different needs
public class FreelancerWorker : IWorkable, IEatable, ISleepable, ITimesheetSubmittable
{
    public void Work()
    {
        Console.WriteLine("Freelancer working remotely...");
    }

    public void Eat()
    {
        Console.WriteLine("Freelancer eating at home...");
    }

    public void Sleep()
    {
        Console.WriteLine("Freelancer sleeping...");
    }

    public void SubmitTimesheet()
    {
        Console.WriteLine("Freelancer submitting invoice...");
    }
}

// Management classes only depend on what they need
public class WorkManager
{
    public void ManageWork(IEnumerable<IWorkable> workers)
    {
        foreach (var worker in workers)
        {
            worker.Work();
        }
    }
}

public class PayrollManager
{
    public void ProcessPayroll(IEnumerable<IPayrollManageable> employees)
    {
        foreach (var employee in employees)
        {
            employee.ReceiveSalary();
        }
    }
}
```

### 6. Dependency Inversion Principle (DIP)

**Definition**: High-level modules should not depend on low-level modules. Both should depend on abstractions.

#### Understanding DIP

DIP promotes loose coupling by ensuring that dependencies flow toward abstractions rather than concrete implementations. This makes the system more flexible and testable.

#### DIP Violation Example

```csharp
// ❌ DIP Violation - High-level module depends on low-level module
public class EmailService
{
    public void SendEmail(string to, string subject, string body)
    {
        // Direct dependency on SMTP implementation
        var smtpClient = new SmtpClient("smtp.gmail.com", 587);
        smtpClient.Credentials = new NetworkCredential("user@example.com", "password");
        smtpClient.EnableSsl = true;

        var message = new MailMessage("from@example.com", to, subject, body);
        smtpClient.Send(message);
        
        Console.WriteLine("Email sent via SMTP");
    }
}

public class UserService
{
    private readonly EmailService _emailService; // Tight coupling

    public UserService()
    {
        _emailService = new EmailService(); // Direct instantiation
    }

    public void RegisterUser(User user)
    {
        // User registration logic
        SaveUserToDatabase(user);
        
        // Send welcome email
        _emailService.SendEmail(user.Email, "Welcome!", "Welcome to our platform!");
    }

    private void SaveUserToDatabase(User user)
    {
        // Database save logic
    }
}
```

#### DIP-Compliant Solution

```csharp
// ✅ DIP Compliant - Depend on abstractions

// Abstraction for email service
public interface IEmailService
{
    Task SendEmailAsync(string to, string subject, string body);
}

// Low-level module implementing the abstraction
public class SmtpEmailService : IEmailService
{
    private readonly string _smtpServer;
    private readonly int _port;
    private readonly string _username;
    private readonly string _password;

    public SmtpEmailService(string smtpServer, int port, string username, string password)
    {
        _smtpServer = smtpServer;
        _port = port;
        _username = username;
        _password = password;
    }

    public async Task SendEmailAsync(string to, string subject, string body)
    {
        var smtpClient = new SmtpClient(_smtpServer, _port);
        smtpClient.Credentials = new NetworkCredential(_username, _password);
        smtpClient.EnableSsl = true;

        var message = new MailMessage(_username, to, subject, body);
        await smtpClient.SendMailAsync(message);
        
        Console.WriteLine("Email sent via SMTP");
    }
}

// Alternative implementation
public class SendGridEmailService : IEmailService
{
    private readonly string _apiKey;

    public SendGridEmailService(string apiKey)
    {
        _apiKey = apiKey;
    }

    public async Task SendEmailAsync(string to, string subject, string body)
    {
        // SendGrid implementation
        Console.WriteLine("Email sent via SendGrid");
        await Task.Delay(100); // Simulate async operation
    }
}

// High-level module depends on abstraction
public class UserService
{
    private readonly IEmailService _emailService;
    private readonly IUserRepository _userRepository;

    public UserService(IEmailService emailService, IUserRepository userRepository)
    {
        _emailService = emailService; // Dependency injection
        _userRepository = userRepository;
    }

    public async Task RegisterUserAsync(User user)
    {
        // User registration logic
        await _userRepository.SaveUserAsync(user);
        
        // Send welcome email
        await _emailService.SendEmailAsync(user.Email, "Welcome!", "Welcome to our platform!");
    }
}

// Dependency injection configuration
public class ServiceConfiguration
{
    public static void ConfigureServices(IServiceCollection services)
    {
        // Can easily switch between implementations
        services.AddScoped<IEmailService, SmtpEmailService>();
        // or
        // services.AddScoped<IEmailService, SendGridEmailService>();
        
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<UserService>();
    }
}
```

#### Advanced DIP Example: Layered Architecture

```csharp
// Domain layer - high-level policy
public interface IOrderRepository
{
    Task<Order> GetOrderAsync(int orderId);
    Task SaveOrderAsync(Order order);
}

public interface IPaymentGateway
{
    Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request);
}

public interface IInventoryService
{
    Task<bool> IsAvailableAsync(int productId, int quantity);
    Task ReserveInventoryAsync(int productId, int quantity);
}

public class OrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IPaymentGateway _paymentGateway;
    private readonly IInventoryService _inventoryService;

    public OrderService(
        IOrderRepository orderRepository,
        IPaymentGateway paymentGateway,
        IInventoryService inventoryService)
    {
        _orderRepository = orderRepository;
        _paymentGateway = paymentGateway;
        _inventoryService = inventoryService;
    }

    public async Task<OrderResult> ProcessOrderAsync(OrderRequest request)
    {
        // Check inventory
        var isAvailable = await _inventoryService.IsAvailableAsync(request.ProductId, request.Quantity);
        if (!isAvailable)
        {
            return OrderResult.Failed("Insufficient inventory");
        }

        // Process payment
        var paymentResult = await _paymentGateway.ProcessPaymentAsync(new PaymentRequest
        {
            Amount = request.Amount,
            PaymentMethod = request.PaymentMethod
        });

        if (!paymentResult.IsSuccessful)
        {
            return OrderResult.Failed("Payment failed");
        }

        // Reserve inventory
        await _inventoryService.ReserveInventoryAsync(request.ProductId, request.Quantity);

        // Create and save order
        var order = new Order
        {
            ProductId = request.ProductId,
            Quantity = request.Quantity,
            Amount = request.Amount,
            PaymentId = paymentResult.TransactionId,
            Status = OrderStatus.Confirmed
        };

        await _orderRepository.SaveOrderAsync(order);

        return OrderResult.Success(order.Id);
    }
}

// Infrastructure layer - low-level implementations
public class SqlOrderRepository : IOrderRepository
{
    private readonly string _connectionString;

    public SqlOrderRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<Order> GetOrderAsync(int orderId)
    {
        // SQL implementation
        await Task.Delay(50);
        return new Order { Id = orderId };
    }

    public async Task SaveOrderAsync(Order order)
    {
        // SQL implementation
        await Task.Delay(100);
    }
}

public class StripePaymentGateway : IPaymentGateway
{
    private readonly string _apiKey;

    public StripePaymentGateway(string apiKey)
    {
        _apiKey = apiKey;
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        // Stripe implementation
        await Task.Delay(200);
        return new PaymentResult { IsSuccessful = true, TransactionId = Guid.NewGuid().ToString() };
    }
}
```

### 7. SOLID Principles Integration

#### Applying SOLID Together

```csharp
// Real-world example: E-commerce order processing system
// that demonstrates all SOLID principles working together

// SRP: Each interface has a single responsibility
public interface IProductCatalog
{
    Task<Product> GetProductAsync(int productId);
}

public interface IPricingService
{
    decimal CalculatePrice(Product product, int quantity, Customer customer);
}

public interface IInventoryService
{
    Task<bool> CheckAvailabilityAsync(int productId, int quantity);
    Task ReserveAsync(int productId, int quantity);
}

public interface IOrderRepository
{
    Task SaveAsync(Order order);
}

public interface INotificationService
{
    Task NotifyOrderConfirmationAsync(Order order);
}

// DIP: High-level policy depends on abstractions
public class OrderProcessingService
{
    private readonly IProductCatalog _productCatalog;
    private readonly IPricingService _pricingService;
    private readonly IInventoryService _inventoryService;
    private readonly IOrderRepository _orderRepository;
    private readonly INotificationService _notificationService;

    public OrderProcessingService(
        IProductCatalog productCatalog,
        IPricingService pricingService,
        IInventoryService inventoryService,
        IOrderRepository orderRepository,
        INotificationService notificationService)
    {
        _productCatalog = productCatalog;
        _pricingService = pricingService;
        _inventoryService = inventoryService;
        _orderRepository = orderRepository;
        _notificationService = notificationService;
    }

    public async Task<OrderResult> ProcessOrderAsync(OrderRequest request)
    {
        // Get product information
        var product = await _productCatalog.GetProductAsync(request.ProductId);
        if (product == null)
        {
            return OrderResult.Failed("Product not found");
        }

        // Check inventory availability
        var isAvailable = await _inventoryService.CheckAvailabilityAsync(request.ProductId, request.Quantity);
        if (!isAvailable)
        {
            return OrderResult.Failed("Insufficient inventory");
        }

        // Calculate pricing
        var totalPrice = _pricingService.CalculatePrice(product, request.Quantity, request.Customer);

        // Reserve inventory
        await _inventoryService.ReserveAsync(request.ProductId, request.Quantity);

        // Create order
        var order = new Order
        {
            Id = Guid.NewGuid(),
            CustomerId = request.Customer.Id,
            ProductId = request.ProductId,
            Quantity = request.Quantity,
            TotalPrice = totalPrice,
            OrderDate = DateTime.UtcNow,
            Status = OrderStatus.Confirmed
        };

        // Save order
        await _orderRepository.SaveAsync(order);

        // Send notification
        await _notificationService.NotifyOrderConfirmationAsync(order);

        return OrderResult.Success(order.Id);
    }
}

// OCP: Extensible pricing strategies
public interface IPricingStrategy
{
    decimal CalculatePrice(Product product, int quantity);
    bool AppliesTo(Customer customer);
}

public class RegularPricingStrategy : IPricingStrategy
{
    public decimal CalculatePrice(Product product, int quantity)
    {
        return product.Price * quantity;
    }

    public bool AppliesTo(Customer customer)
    {
        return customer.Type == CustomerType.Regular;
    }
}

public class VipPricingStrategy : IPricingStrategy
{
    public decimal CalculatePrice(Product product, int quantity)
    {
        var basePrice = product.Price * quantity;
        return basePrice * 0.9m; // 10% discount
    }

    public bool AppliesTo(Customer customer)
    {
        return customer.Type == CustomerType.VIP;
    }
}

// ISP: Specific interfaces for different concerns
public interface IEmailNotifier
{
    Task SendEmailAsync(string email, string subject, string body);
}

public interface ISmsNotifier
{
    Task SendSmsAsync(string phoneNumber, string message);
}

// LSP: Proper inheritance hierarchy
public abstract class NotificationService : INotificationService
{
    public abstract Task NotifyOrderConfirmationAsync(Order order);
}

public class EmailNotificationService : NotificationService
{
    private readonly IEmailNotifier _emailNotifier;

    public EmailNotificationService(IEmailNotifier emailNotifier)
    {
        _emailNotifier = emailNotifier;
    }

    public override async Task NotifyOrderConfirmationAsync(Order order)
    {
        await _emailNotifier.SendEmailAsync(
            order.Customer.Email,
            "Order Confirmation",
            $"Your order {order.Id} has been confirmed.");
    }
}

public class MultiChannelNotificationService : NotificationService
{
    private readonly IEmailNotifier _emailNotifier;
    private readonly ISmsNotifier _smsNotifier;

    public MultiChannelNotificationService(IEmailNotifier emailNotifier, ISmsNotifier smsNotifier)
    {
        _emailNotifier = emailNotifier;
        _smsNotifier = smsNotifier;
    }

    public override async Task NotifyOrderConfirmationAsync(Order order)
    {
        await _emailNotifier.SendEmailAsync(
            order.Customer.Email,
            "Order Confirmation",
            $"Your order {order.Id} has been confirmed.");

        await _smsNotifier.SendSmsAsync(
            order.Customer.PhoneNumber,
            $"Order {order.Id} confirmed. Total: ${order.TotalPrice}");
    }
}
```

### 8. Testing with SOLID Principles

#### Unit Testing Benefits

```csharp
[TestFixture]
public class OrderProcessingServiceTests
{
    private Mock<IProductCatalog> _productCatalogMock;
    private Mock<IPricingService> _pricingServiceMock;
    private Mock<IInventoryService> _inventoryServiceMock;
    private Mock<IOrderRepository> _orderRepositoryMock;
    private Mock<INotificationService> _notificationServiceMock;
    private OrderProcessingService _orderProcessingService;

    [SetUp]
    public void Setup()
    {
        _productCatalogMock = new Mock<IProductCatalog>();
        _pricingServiceMock = new Mock<IPricingService>();
        _inventoryServiceMock = new Mock<IInventoryService>();
        _orderRepositoryMock = new Mock<IOrderRepository>();
        _notificationServiceMock = new Mock<INotificationService>();

        _orderProcessingService = new OrderProcessingService(
            _productCatalogMock.Object,
            _pricingServiceMock.Object,
            _inventoryServiceMock.Object,
            _orderRepositoryMock.Object,
            _notificationServiceMock.Object);
    }

    [Test]
    public async Task ProcessOrderAsync_ValidRequest_ReturnsSuccess()
    {
        // Arrange
        var product = new Product { Id = 1, Name = "Test Product", Price = 10.00m };
        var customer = new Customer { Id = 1, Type = CustomerType.Regular };
        var request = new OrderRequest 
        { 
            ProductId = 1, 
            Quantity = 2, 
            Customer = customer 
        };

        _productCatalogMock.Setup(x => x.GetProductAsync(1))
            .ReturnsAsync(product);
        _inventoryServiceMock.Setup(x => x.CheckAvailabilityAsync(1, 2))
            .ReturnsAsync(true);
        _pricingServiceMock.Setup(x => x.CalculatePrice(product, 2, customer))
            .Returns(20.00m);

        // Act
        var result = await _orderProcessingService.ProcessOrderAsync(request);

        // Assert
        Assert.That(result.IsSuccess, Is.True);
        _orderRepositoryMock.Verify(x => x.SaveAsync(It.IsAny<Order>()), Times.Once);
        _notificationServiceMock.Verify(x => x.NotifyOrderConfirmationAsync(It.IsAny<Order>()), Times.Once);
    }

    [Test]
    public async Task ProcessOrderAsync_InsufficientInventory_ReturnsFailure()
    {
        // Arrange
        var product = new Product { Id = 1, Name = "Test Product", Price = 10.00m };
        var customer = new Customer { Id = 1, Type = CustomerType.Regular };
        var request = new OrderRequest 
        { 
            ProductId = 1, 
            Quantity = 2, 
            Customer = customer 
        };

        _productCatalogMock.Setup(x => x.GetProductAsync(1))
            .ReturnsAsync(product);
        _inventoryServiceMock.Setup(x => x.CheckAvailabilityAsync(1, 2))
            .ReturnsAsync(false);

        // Act
        var result = await _orderProcessingService.ProcessOrderAsync(request);

        // Assert
        Assert.That(result.IsSuccess, Is.False);
        Assert.That(result.ErrorMessage, Is.EqualTo("Insufficient inventory"));
        _orderRepositoryMock.Verify(x => x.SaveAsync(It.IsAny<Order>()), Times.Never);
    }
}
```

### 9. Common Anti-Patterns and Solutions

#### Anti-Pattern: Service Locator

```csharp
// ❌ Anti-pattern: Service Locator
public class ServiceLocator
{
    private static Dictionary<Type, object> _services = new();

    public static void Register<T>(T service)
    {
        _services[typeof(T)] = service;
    }

    public static T Get<T>()
    {
        return (T)_services[typeof(T)];
    }
}

public class OrderService
{
    public void ProcessOrder(Order order)
    {
        // Hidden dependencies - hard to test
        var emailService = ServiceLocator.Get<IEmailService>();
        var repository = ServiceLocator.Get<IOrderRepository>();
        
        // Business logic
    }
}

// ✅ Solution: Dependency Injection
public class OrderService
{
    private readonly IEmailService _emailService;
    private readonly IOrderRepository _repository;

    public OrderService(IEmailService emailService, IOrderRepository repository)
    {
        _emailService = emailService; // Explicit dependencies
        _repository = repository;
    }

    public void ProcessOrder(Order order)
    {
        // Business logic with injected dependencies
    }
}
```

#### Anti-Pattern: God Object

```csharp
// ❌ Anti-pattern: God Object (violates SRP)
public class OrderManager
{
    public void ProcessOrder(Order order) { /* logic */ }
    public void ValidateOrder(Order order) { /* logic */ }
    public void CalculateShipping(Order order) { /* logic */ }
    public void SendEmailConfirmation(Order order) { /* logic */ }
    public void UpdateInventory(Order order) { /* logic */ }
    public void ProcessPayment(Order order) { /* logic */ }
    public void GenerateInvoice(Order order) { /* logic */ }
    public void LogOrder(Order order) { /* logic */ }
    // ... 20 more methods
}

// ✅ Solution: Separate Responsibilities
public class OrderProcessor
{
    private readonly IOrderValidator _validator;
    private readonly IShippingCalculator _shippingCalculator;
    private readonly IEmailService _emailService;
    private readonly IInventoryService _inventoryService;
    private readonly IPaymentProcessor _paymentProcessor;

    public OrderProcessor(/* inject dependencies */) { }

    public async Task ProcessOrderAsync(Order order)
    {
        _validator.ValidateOrder(order);
        await _paymentProcessor.ProcessPaymentAsync(order);
        await _inventoryService.UpdateInventoryAsync(order);
        await _emailService.SendConfirmationAsync(order);
    }
}
```

### 10. SOLID Principles Code Review Checklist

#### SRP Checklist

- [ ] Does this class have only one reason to change?
- [ ] Can I describe the class without using "and" or "or"?
- [ ] Are all methods related to the single responsibility?
- [ ] Would a change in business requirements affect only one part of this class?

#### OCP Checklist

- [ ] Can I add new functionality without modifying existing code?
- [ ] Are there abstractions (interfaces/abstract classes) that allow extension?
- [ ] Am I using switch statements or if-else chains that would require modification for new cases?
- [ ] Can new implementations be added through configuration rather than code changes?

#### LSP Checklist

- [ ] Can I substitute derived classes for base classes without breaking functionality?
- [ ] Do derived classes strengthen (not weaken) preconditions?
- [ ] Do derived classes weaken (not strengthen) postconditions?
- [ ] Are there any NotImplementedException or similar violations in derived classes?

#### ISP Checklist

- [ ] Are interfaces focused and cohesive?
- [ ] Do clients depend only on methods they actually use?
- [ ] Are there any empty implementations or NotImplementedException in interface implementations?
- [ ] Can I split large interfaces into smaller, more focused ones?

#### DIP Checklist

- [ ] Do high-level modules depend on abstractions rather than concrete implementations?
- [ ] Are dependencies injected rather than created internally?
- [ ] Can I easily swap implementations for testing or different environments?
- [ ] Are there any direct instantiations of concrete classes in business logic?

## 🚀 Common Pitfalls

### 1. **Over-Engineering**

Don't apply SOLID principles everywhere immediately. Start with pain points and refactor incrementally.

### 2. **Interface Explosion**

Balance ISP with practical considerations. Not every method needs its own interface.

### 3. **Premature Abstraction**

Wait for actual variation points before introducing abstractions. Follow the rule of three.

### 4. **Testing Complexity**

While SOLID improves testability, don't create interfaces solely for testing. Focus on design benefits first.

### 5. **Performance Considerations**

Abstractions have overhead. Profile performance-critical paths and optimize accordingly.

## 🔗 Next Steps

After mastering SOLID principles:

1. **Design Patterns** - Learn how patterns implement SOLID principles
2. **Clean Code Practices** - Apply SOLID at the method and function level
3. **Architectural Patterns** - Scale SOLID principles to system-level design
4. **Testing Strategies** - Leverage SOLID for comprehensive test coverage
5. **Code Reviews** - Use SOLID principles as quality gates

## 🔗 Related Topics

**Prerequisites:**

- [Clean Architecture](./01_Clean-Architecture.md) - Architectural foundation
- [Domain-Driven Design](./02_Domain-Driven-Design.md) - Domain modeling principles

**Builds Upon:**

- [System Design Fundamentals](./04_System-Design-Fundamentals.md) - System-level design
- [Microservices Architecture](./05_Microservices-Architecture.md) - Service design principles
- [Event-Driven Architecture](./06_Event-Driven-Architecture.md) - Decoupled communication

**Enables:**

- Advanced design pattern implementation
- Comprehensive testing strategies
- Maintainable large-scale systems
- Effective code review processes

**Cross-References:**

- [C# Development Practices](../../03_CSharp/) - Language-specific implementations
- [Testing Strategies](../../../04_DevOps/) - Test-driven development approaches

---

**Last Updated**: September 8, 2025  
**Module Version**: 1.0  
**Estimated Completion**: Day 6 of Development Track Migration
