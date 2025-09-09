# 05_SOLID-Part5-Dependency-Inversion-Principle

**Learning Level**: Advanced  
**Prerequisites**: Interface Segregation Principle (Part 4), Dependency injection concepts  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Dependency Inversion Principle (DIP) and its architectural implications
- Distinguish between dependency inversion and dependency injection
- Design loosely coupled systems using abstraction layers
- Implement DIP patterns that enable testability, maintainability, and flexibility

## 📋 Content Sections

### Quick Overview (5 minutes)

**Dependency Inversion Principle (DIP)**: *"High-level modules should not depend on low-level modules. Both should depend on abstractions."*

**Secondary Rule**: *"Abstractions should not depend on details. Details should depend on abstractions."*

```text
❌ DIP VIOLATION: High-Level Depends on Low-Level
┌─────────────────────────────────┐
│     OrderService (High-Level)   │
├─────────────────────────────────┤
│ - SqlOrderRepository            │ ← Concrete dependency
│ - SmtpEmailService              │ ← Concrete dependency  
│ - FileLogger                    │ ← Concrete dependency
└─────────────────────────────────┘
          ↓ (depends on)
┌─────────────────────────────────┐
│   Concrete Implementations     │
│   (Low-Level Modules)          │
└─────────────────────────────────┘

Problems:
• Changes in low-level modules break high-level modules
• Difficult to test (can't mock concrete dependencies)
• Tight coupling prevents substitution
• Violates Open/Closed Principle

✅ DIP COMPLIANT: Both Depend on Abstractions
┌─────────────────────────────────┐
│     OrderService (High-Level)   │
├─────────────────────────────────┤
│ - IOrderRepository              │ ← Abstract dependency
│ - IEmailService                 │ ← Abstract dependency
│ - ILogger                       │ ← Abstract dependency
└─────────────────────────────────┘
          ↓ (depends on)
┌─────────────────────────────────┐
│      Abstractions Layer        │
│    (Interfaces/Contracts)       │
└─────────────────────────────────┘
          ↑ (implemented by)
┌─────────────────────────────────┐
│   Concrete Implementations     │
│   (Low-Level Modules)          │
└─────────────────────────────────┘
```

**DIP vs Dependency Injection**:

- **DIP (Principle)**: Architectural design rule about depending on abstractions
- **DI (Pattern)**: Implementation technique for providing dependencies from outside

### Core Concepts (15 minutes)

#### Understanding Dependency Direction

##### Traditional Layered Architecture Problem

```csharp
// ❌ BAD: Violates DIP - high-level depends on low-level
public class OrderService // High-level business logic
{
    private readonly SqlOrderRepository _orderRepository; // Low-level data access
    private readonly SmtpEmailService _emailService;     // Low-level infrastructure
    private readonly FileLogger _logger;                 // Low-level logging
    
    public OrderService()
    {
        // Hard-coded dependencies - violates DIP
        _orderRepository = new SqlOrderRepository("connectionString");
        _emailService = new SmtpEmailService("smtp.company.com");
        _logger = new FileLogger("orders.log");
    }
    
    public async Task ProcessOrderAsync(Order order)
    {
        try
        {
            // Business logic mixed with infrastructure concerns
            _logger.Log($"Processing order {order.Id}");
            
            await _orderRepository.SaveAsync(order);
            
            var emailBody = $"Order {order.Id} confirmed";
            await _emailService.SendAsync(order.CustomerEmail, "Order Confirmation", emailBody);
            
            _logger.Log($"Order {order.Id} processed successfully");
        }
        catch (Exception ex)
        {
            _logger.Log($"Failed to process order {order.Id}: {ex.Message}");
            throw;
        }
    }
}

// Problems with this approach:
// 1. OrderService breaks when SqlOrderRepository changes
// 2. Cannot test OrderService without real database/email/file system
// 3. Cannot substitute different implementations (e.g., MongoDB, SendGrid)
// 4. Configuration is hard-coded and inflexible
```

#### DIP-Compliant Solution: Inversion of Control

```csharp
// ✅ GOOD: DIP compliant - depends on abstractions
public interface IOrderRepository
{
    Task<Order> GetByIdAsync(int id);
    Task SaveAsync(Order order);
    Task<IEnumerable<Order>> GetOrdersByCustomerAsync(int customerId);
}

public interface IEmailService
{
    Task SendAsync(string to, string subject, string body);
    Task SendTemplatedAsync(string to, string templateId, object data);
}

public interface ILogger
{
    void Log(string message);
    void LogError(string message, Exception exception = null);
    void LogWarning(string message);
}

// High-level module depends only on abstractions
public class OrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IEmailService _emailService;
    private readonly ILogger _logger;
    
    // Dependencies injected from outside (Dependency Injection)
    public OrderService(
        IOrderRepository orderRepository,
        IEmailService emailService,
        ILogger logger)
    {
        _orderRepository = orderRepository ?? throw new ArgumentNullException(nameof(orderRepository));
        _emailService = emailService ?? throw new ArgumentNullException(nameof(emailService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }
    
    public async Task<ProcessResult> ProcessOrderAsync(Order order)
    {
        try
        {
            _logger.Log($"Processing order {order.Id}");
            
            // Validate business rules
            var validationResult = ValidateOrder(order);
            if (!validationResult.IsValid)
            {
                _logger.LogWarning($"Order {order.Id} validation failed: {string.Join(", ", validationResult.Errors)}");
                return ProcessResult.Failed(validationResult.Errors);
            }
            
            // Save order
            await _orderRepository.SaveAsync(order);
            
            // Send confirmation
            await _emailService.SendTemplatedAsync(
                order.CustomerEmail, 
                "OrderConfirmation", 
                new { OrderId = order.Id, Total = order.Total });
            
            _logger.Log($"Order {order.Id} processed successfully");
            return ProcessResult.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError($"Failed to process order {order.Id}", ex);
            throw;
        }
    }
    
    private ValidationResult ValidateOrder(Order order)
    {
        // Pure business logic - no infrastructure dependencies
        var result = new ValidationResult();
        
        if (order.Items == null || order.Items.Count == 0)
            result.AddError("Order must contain at least one item");
            
        if (order.Total <= 0)
            result.AddError("Order total must be greater than zero");
            
        if (string.IsNullOrEmpty(order.CustomerEmail))
            result.AddError("Customer email is required");
            
        return result;
    }
}
```

#### Low-Level Module Implementations

```csharp
// Low-level modules implement the abstractions
public class SqlOrderRepository : IOrderRepository
{
    private readonly string _connectionString;
    
    public SqlOrderRepository(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
    }
    
    public async Task<Order> GetByIdAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        var command = new SqlCommand("SELECT * FROM Orders WHERE Id = @id", connection);
        command.Parameters.AddWithValue("@id", id);
        
        await connection.OpenAsync();
        using var reader = await command.ExecuteReaderAsync();
        
        if (await reader.ReadAsync())
        {
            return new Order
            {
                Id = reader.GetInt32("Id"),
                CustomerEmail = reader.GetString("CustomerEmail"),
                Total = reader.GetDecimal("Total")
            };
        }
        
        return null;
    }
    
    public async Task SaveAsync(Order order)
    {
        using var connection = new SqlConnection(_connectionString);
        var command = new SqlCommand(
            "INSERT INTO Orders (CustomerEmail, Total) VALUES (@email, @total)", 
            connection);
        command.Parameters.AddWithValue("@email", order.CustomerEmail);
        command.Parameters.AddWithValue("@total", order.Total);
        
        await connection.OpenAsync();
        await command.ExecuteNonQueryAsync();
    }
    
    public async Task<IEnumerable<Order>> GetOrdersByCustomerAsync(int customerId)
    {
        // Implementation details...
        return new List<Order>();
    }
}

// Alternative implementation for testing or different environments
public class InMemoryOrderRepository : IOrderRepository
{
    private readonly List<Order> _orders = new();
    private int _nextId = 1;
    
    public Task<Order> GetByIdAsync(int id)
    {
        var order = _orders.FirstOrDefault(o => o.Id == id);
        return Task.FromResult(order);
    }
    
    public Task SaveAsync(Order order)
    {
        if (order.Id == 0)
        {
            order.Id = _nextId++;
            _orders.Add(order);
        }
        else
        {
            var existing = _orders.FirstOrDefault(o => o.Id == order.Id);
            if (existing != null)
            {
                _orders.Remove(existing);
                _orders.Add(order);
            }
        }
        
        return Task.CompletedTask;
    }
    
    public Task<IEnumerable<Order>> GetOrdersByCustomerAsync(int customerId)
    {
        var orders = _orders.Where(o => o.CustomerId == customerId);
        return Task.FromResult(orders);
    }
}

public class ConsoleLogger : ILogger
{
    public void Log(string message)
    {
        Console.WriteLine($"[INFO] {DateTime.Now:yyyy-MM-dd HH:mm:ss} - {message}");
    }
    
    public void LogError(string message, Exception exception = null)
    {
        Console.WriteLine($"[ERROR] {DateTime.Now:yyyy-MM-dd HH:mm:ss} - {message}");
        if (exception != null)
            Console.WriteLine($"Exception: {exception}");
    }
    
    public void LogWarning(string message)
    {
        Console.WriteLine($"[WARNING] {DateTime.Now:yyyy-MM-dd HH:mm:ss} - {message}");
    }
}
```

#### Dependency Injection Container Configuration

```csharp
// Composition root - where dependencies are wired up
public class ServiceConfiguration
{
    public static ServiceCollection ConfigureServices()
    {
        var services = new ServiceCollection();
        
        // Register abstractions with concrete implementations
        services.AddScoped<IOrderRepository, SqlOrderRepository>();
        services.AddScoped<IEmailService, SmtpEmailService>();
        services.AddScoped<ILogger, FileLogger>();
        
        // Register business services
        services.AddScoped<OrderService>();
        
        // Configuration
        services.AddSingleton<IConfiguration>(provider =>
        {
            return new ConfigurationBuilder()
                .AddJsonFile("appsettings.json")
                .Build();
        });
        
        // Register repository with configuration
        services.AddScoped<IOrderRepository>(provider =>
        {
            var config = provider.GetRequiredService<IConfiguration>();
            var connectionString = config.GetConnectionString("DefaultConnection");
            return new SqlOrderRepository(connectionString);
        });
        
        return services;
    }
}

// Different configurations for different environments
public class TestServiceConfiguration
{
    public static ServiceCollection ConfigureTestServices()
    {
        var services = new ServiceCollection();
        
        // Use in-memory implementations for testing
        services.AddScoped<IOrderRepository, InMemoryOrderRepository>();
        services.AddScoped<IEmailService, MockEmailService>();
        services.AddScoped<ILogger, ConsoleLogger>();
        
        services.AddScoped<OrderService>();
        
        return services;
    }
}
```

### Practical Implementation (8 minutes)

#### Advanced DIP Patterns

##### Factory Pattern with DIP

```csharp
// Abstract factory follows DIP
public interface IRepositoryFactory
{
    IOrderRepository CreateOrderRepository();
    ICustomerRepository CreateCustomerRepository();
    IProductRepository CreateProductRepository();
}

// Concrete factory for SQL implementations
public class SqlRepositoryFactory : IRepositoryFactory
{
    private readonly string _connectionString;
    
    public SqlRepositoryFactory(string connectionString)
    {
        _connectionString = connectionString;
    }
    
    public IOrderRepository CreateOrderRepository()
    {
        return new SqlOrderRepository(_connectionString);
    }
    
    public ICustomerRepository CreateCustomerRepository()
    {
        return new SqlCustomerRepository(_connectionString);
    }
    
    public IProductRepository CreateProductRepository()
    {
        return new SqlProductRepository(_connectionString);
    }
}

// Service using factory abstraction
public class ECommerceService
{
    private readonly IRepositoryFactory _repositoryFactory;
    
    public ECommerceService(IRepositoryFactory repositoryFactory)
    {
        _repositoryFactory = repositoryFactory;
    }
    
    public async Task ProcessPurchaseAsync(int customerId, int productId, int quantity)
    {
        var customerRepo = _repositoryFactory.CreateCustomerRepository();
        var productRepo = _repositoryFactory.CreateProductRepository();
        var orderRepo = _repositoryFactory.CreateOrderRepository();
        
        var customer = await customerRepo.GetByIdAsync(customerId);
        var product = await productRepo.GetByIdAsync(productId);
        
        // Business logic using abstractions
        var order = new Order
        {
            CustomerId = customerId,
            Items = new List<OrderItem>
            {
                new OrderItem { ProductId = productId, Quantity = quantity, Price = product.Price }
            }
        };
        
        await orderRepo.SaveAsync(order);
    }
}
```

##### Strategy Pattern with DIP

```csharp
// Payment processing with DIP
public interface IPaymentProcessor
{
    Task<PaymentResult> ProcessAsync(PaymentRequest request);
    bool CanProcess(PaymentType paymentType);
}

public class PaymentService
{
    private readonly IEnumerable<IPaymentProcessor> _processors;
    private readonly ILogger _logger;
    
    public PaymentService(IEnumerable<IPaymentProcessor> processors, ILogger logger)
    {
        _processors = processors;
        _logger = logger;
    }
    
    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        var processor = _processors.FirstOrDefault(p => p.CanProcess(request.PaymentType));
        
        if (processor == null)
        {
            var error = $"No processor found for payment type: {request.PaymentType}";
            _logger.LogError(error);
            return PaymentResult.Failed(error);
        }
        
        _logger.Log($"Processing {request.PaymentType} payment for ${request.Amount}");
        
        try
        {
            return await processor.ProcessAsync(request);
        }
        catch (Exception ex)
        {
            _logger.LogError("Payment processing failed", ex);
            return PaymentResult.Failed("Payment processing error");
        }
    }
}

// Concrete processors implement the abstraction
public class CreditCardProcessor : IPaymentProcessor
{
    private readonly ICreditCardGateway _gateway;
    
    public CreditCardProcessor(ICreditCardGateway gateway)
    {
        _gateway = gateway;
    }
    
    public bool CanProcess(PaymentType paymentType)
    {
        return paymentType == PaymentType.CreditCard;
    }
    
    public async Task<PaymentResult> ProcessAsync(PaymentRequest request)
    {
        var result = await _gateway.ChargeCardAsync(request.CardNumber, request.Amount);
        return new PaymentResult
        {
            Success = result.IsSuccess,
            TransactionId = result.TransactionId
        };
    }
}

public class PayPalProcessor : IPaymentProcessor
{
    private readonly IPayPalApi _payPalApi;
    
    public PayPalProcessor(IPayPalApi payPalApi)
    {
        _payPalApi = payPalApi;
    }
    
    public bool CanProcess(PaymentType paymentType)
    {
        return paymentType == PaymentType.PayPal;
    }
    
    public async Task<PaymentResult> ProcessAsync(PaymentRequest request)
    {
        var result = await _payPalApi.ProcessPaymentAsync(request.PayPalToken, request.Amount);
        return new PaymentResult
        {
            Success = result.Status == "SUCCESS",
            TransactionId = result.Id
        };
    }
}
```

#### Testing with DIP

```csharp
// DIP makes unit testing straightforward
public class OrderServiceTests
{
    [Test]
    public async Task ProcessOrder_ValidOrder_ShouldReturnSuccess()
    {
        // Arrange - create mocks for all dependencies
        var mockRepository = new Mock<IOrderRepository>();
        var mockEmailService = new Mock<IEmailService>();
        var mockLogger = new Mock<ILogger>();
        
        var order = new Order
        {
            Id = 1,
            CustomerEmail = "customer@example.com",
            Total = 100.00m,
            Items = new List<OrderItem> { new OrderItem { ProductId = 1, Quantity = 1, Price = 100.00m } }
        };
        
        var orderService = new OrderService(mockRepository.Object, mockEmailService.Object, mockLogger.Object);
        
        // Act
        var result = await orderService.ProcessOrderAsync(order);
        
        // Assert
        Assert.True(result.IsSuccess);
        
        // Verify interactions with dependencies
        mockRepository.Verify(r => r.SaveAsync(It.IsAny<Order>()), Times.Once);
        mockEmailService.Verify(e => e.SendTemplatedAsync(
            "customer@example.com",
            "OrderConfirmation",
            It.IsAny<object>()), Times.Once);
        mockLogger.Verify(l => l.Log(It.IsAny<string>()), Times.AtLeastOnce);
    }
    
    [Test]
    public async Task ProcessOrder_InvalidOrder_ShouldReturnFailure()
    {
        // Arrange
        var mockRepository = new Mock<IOrderRepository>();
        var mockEmailService = new Mock<IEmailService>();
        var mockLogger = new Mock<ILogger>();
        
        var invalidOrder = new Order
        {
            Id = 1,
            CustomerEmail = "", // Invalid - empty email
            Total = 0,          // Invalid - zero total
            Items = new List<OrderItem>() // Invalid - no items
        };
        
        var orderService = new OrderService(mockRepository.Object, mockEmailService.Object, mockLogger.Object);
        
        // Act
        var result = await orderService.ProcessOrderAsync(invalidOrder);
        
        // Assert
        Assert.False(result.IsSuccess);
        Assert.Contains("Customer email is required", result.Errors);
        Assert.Contains("Order total must be greater than zero", result.Errors);
        Assert.Contains("Order must contain at least one item", result.Errors);
        
        // Verify no side effects occurred
        mockRepository.Verify(r => r.SaveAsync(It.IsAny<Order>()), Times.Never);
        mockEmailService.Verify(e => e.SendTemplatedAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<object>()), Times.Never);
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**DIP Success Indicators**:

- ✅ High-level modules are independent of implementation details
- ✅ Easy to substitute different implementations (SQL → NoSQL, SMTP → SendGrid)
- ✅ Comprehensive unit testing with mocked dependencies  
- ✅ Configuration-driven component selection
- ✅ Clear separation between business logic and infrastructure concerns

**DIP Implementation Guidelines**:

1. **Define abstractions first** - design interfaces before implementations
2. **Keep abstractions stable** - avoid frequent interface changes  
3. **Use dependency injection containers** - let the container wire up dependencies
4. **Configure at composition root** - centralize dependency configuration
5. **Test with mocks** - verify behavior through interface contracts

**DIP Architectural Benefits**:

- **Testability**: Easy to test business logic in isolation
- **Flexibility**: Swap implementations without changing business code
- **Maintainability**: Changes isolated to specific layers
- **Scalability**: Different implementations for different environments

### Next Steps

**Immediate Actions**:

- Audit codebase for concrete dependencies in business logic
- Introduce abstractions for external dependencies
- Set up dependency injection container
- **Move to Design Patterns**: Apply SOLID principles through proven patterns

**SOLID Principles Mastery Complete** ✅

You've now mastered all five SOLID principles:

1. ✅ **Single Responsibility** - One reason to change
2. ✅ **Open/Closed** - Open for extension, closed for modification  
3. ✅ **Liskov Substitution** - Subclasses must honor parent contracts
4. ✅ **Interface Segregation** - Clients shouldn't depend on unused methods
5. ✅ **Dependency Inversion** - Depend on abstractions, not concretions

**Advanced Applications**:

- Clean Architecture implementation using SOLID
- Domain-Driven Design with SOLID principles
- Microservices design applying SOLID at service boundaries

## 🔗 Related Topics

**Prerequisites**: Interface Segregation Principle, Dependency injection fundamentals  
**Builds Upon**: All previous SOLID principles, Inversion of Control pattern  
**Enables**: Clean Architecture, Design Patterns implementation, Testable system design  
**Related**: Dependency Injection containers, Factory patterns, Strategy patterns
