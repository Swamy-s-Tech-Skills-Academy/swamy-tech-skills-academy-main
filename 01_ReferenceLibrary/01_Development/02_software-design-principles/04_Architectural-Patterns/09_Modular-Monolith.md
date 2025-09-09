# 09_Modular-Monolith

**Learning Level**: Intermediate  
**Prerequisites**: Monolithic Architecture, Domain-Driven Design, Clean Architecture  
**Estimated Time**: 60-75 minutes

## 🎯 Learning Objectives

By the end of this content, you will:

- Understand modular monolith architecture and its advantages over traditional monoliths
- Implement bounded contexts within a single deployable unit
- Design proper inter-module communication patterns
- Apply modular monolith patterns using C#/.NET
- Know when to evolve from modular monolith to microservices
- Implement effective testing strategies for modular systems

## 📋 Table of Contents

1. [Introduction to Modular Monolith](#introduction)
2. [Core Architecture Principles](#principles)
3. [Bounded Context Implementation](#bounded-contexts)
4. [Inter-Module Communication](#communication)
5. [Module Organization Patterns](#organization)
6. [Data Management Strategies](#data-management)
7. [Testing Modular Systems](#testing)
8. [Migration and Evolution](#migration)
9. [Common Patterns and Anti-Patterns](#patterns)

---

## 🏗️ Introduction to Modular Monolith {#introduction}

**Modular Monolith** is an architectural pattern that combines the simplicity of monolithic deployment with the structural benefits of microservices. It organizes code into distinct, loosely-coupled modules with clear boundaries, while maintaining a single deployable unit.

### Architectural Comparison

```text
Traditional Monolith          Modular Monolith              Microservices
┌─────────────────────┐      ┌─────────────────────────┐    ┌─────┐ ┌─────┐ ┌─────┐
│    All Features     │      │  ┌─────┐ ┌─────┐ ┌───┐ │    │ Svc │ │ Svc │ │ Svc │
│    Mixed Together   │      │  │Mod A│ │Mod B│ │Mod│ │    │  A  │ │  B  │ │  C  │
│                     │ →    │  │     │ │     │ │ C │ │ →  │     │ │     │ │     │
│                     │      │  └─────┘ └─────┘ └───┘ │    └─────┘ └─────┘ └─────┘
│                     │      │                        │    
└─────────────────────┘      └─────────────────────────┘    
Single Deployment            Single Deployment              Multiple Deployments
No Boundaries                Clear Module Boundaries        Service Boundaries
```

### Key Benefits

- **🎯 Clear Boundaries**: Well-defined module interfaces and responsibilities
- **🔧 Simplified Operations**: Single deployment unit with monolith-like simplicity
- **⚡ High Performance**: In-process communication with minimal latency
- **🔒 Transaction Consistency**: ACID transactions across modules when needed
- **📈 Gradual Evolution**: Easy path to microservices when complexity justifies it

---

## 🎯 Core Architecture Principles {#principles}

### 1. Module Independence

```csharp
// ✅ Independent Module Structure
namespace ECommerce.Modules.Orders
{
    // Module has its own contracts
    public interface IOrderService
    {
        Task<OrderResult> CreateOrderAsync(CreateOrderCommand command);
        Task<Order> GetOrderAsync(OrderId id);
    }
    
    // Module has its own domain
    public class Order : AggregateRoot
    {
        public OrderId Id { get; private set; }
        public CustomerId CustomerId { get; private set; }
        public DateTime CreatedAt { get; private set; }
        // ... domain logic
    }
    
    // Module has its own data access
    public interface IOrderRepository
    {
        Task<Order> GetByIdAsync(OrderId id);
        Task AddAsync(Order order);
    }
}

namespace ECommerce.Modules.Products
{
    // Separate module with its own contracts
    public interface IProductService
    {
        Task<Product> GetProductAsync(ProductId id);
        Task<bool> IsAvailableAsync(ProductId id, int quantity);
    }
    
    // Independent domain model
    public class Product : AggregateRoot
    {
        public ProductId Id { get; private set; }
        public string Name { get; private set; }
        public Money Price { get; private set; }
        // ... domain logic
    }
}
```

### 2. Explicit Dependencies

```csharp
// ✅ Module-to-Module Dependencies via Contracts
namespace ECommerce.Modules.Orders
{
    public class OrderService : IOrderService
    {
        private readonly IOrderRepository _orderRepository;
        private readonly IProductModule _productModule; // ← External module contract
        private readonly IInventoryModule _inventoryModule; // ← External module contract
        private readonly IModuleEventBus _eventBus;
        
        public OrderService(
            IOrderRepository orderRepository,
            IProductModule productModule,
            IInventoryModule inventoryModule,
            IModuleEventBus eventBus)
        {
            _orderRepository = orderRepository;
            _productModule = productModule;
            _inventoryModule = inventoryModule;
            _eventBus = eventBus;
        }
        
        public async Task<OrderResult> CreateOrderAsync(CreateOrderCommand command)
        {
            // Validate products via module contract
            var productValidation = await _productModule.ValidateProductsAsync(command.ProductIds);
            if (!productValidation.IsValid)
                return OrderResult.Failed(productValidation.Errors);
            
            // Check inventory via module contract
            var inventoryCheck = await _inventoryModule.CheckAvailabilityAsync(command.Items);
            if (!inventoryCheck.IsAvailable)
                return OrderResult.Failed("Insufficient inventory");
            
            // Create order
            var order = new Order(command.CustomerId, command.Items);
            await _orderRepository.AddAsync(order);
            
            // Publish event for other modules
            await _eventBus.PublishAsync(new OrderCreatedEvent(order.Id, order.CustomerId));
            
            return OrderResult.Success(order.Id);
        }
    }
}
```

### 3. Module Contracts

```csharp
// ✅ Well-Defined Module Interfaces
namespace ECommerce.Contracts.Products
{
    // Public contract for Product module
    public interface IProductModule
    {
        Task<ProductInfo> GetProductInfoAsync(ProductId id);
        Task<ProductValidationResult> ValidateProductsAsync(IEnumerable<ProductId> productIds);
        Task<IEnumerable<ProductInfo>> GetProductsAsync(IEnumerable<ProductId> productIds);
    }
    
    // Data transfer objects for inter-module communication
    public class ProductInfo
    {
        public ProductId Id { get; init; }
        public string Name { get; init; }
        public decimal Price { get; init; }
        public bool IsActive { get; init; }
        public int AvailableQuantity { get; init; }
    }
    
    public class ProductValidationResult
    {
        public bool IsValid { get; init; }
        public IEnumerable<string> Errors { get; init; }
        public IEnumerable<ProductId> ValidProductIds { get; init; }
        
        public static ProductValidationResult Success(IEnumerable<ProductId> validIds) =>
            new() { IsValid = true, ValidProductIds = validIds, Errors = Array.Empty<string>() };
            
        public static ProductValidationResult Failed(IEnumerable<string> errors) =>
            new() { IsValid = false, Errors = errors, ValidProductIds = Array.Empty<ProductId>() };
    }
}

namespace ECommerce.Contracts.Inventory
{
    public interface IInventoryModule
    {
        Task<InventoryCheckResult> CheckAvailabilityAsync(IEnumerable<InventoryItem> items);
        Task<ReservationResult> ReserveStockAsync(IEnumerable<InventoryItem> items);
        Task ReleaseReservationAsync(ReservationId reservationId);
    }
    
    public class InventoryItem
    {
        public ProductId ProductId { get; init; }
        public int Quantity { get; init; }
    }
}
```

---

## 🏢 Bounded Context Implementation {#bounded-contexts}

### 1. Module Structure

```csharp
// ✅ Complete Module Implementation
namespace ECommerce.Modules.Orders
{
    // Module entry point and facade
    public class OrderModule : IOrderModule
    {
        private readonly IOrderService _orderService;
        private readonly IOrderQueryService _queryService;
        
        public OrderModule(IOrderService orderService, IOrderQueryService queryService)
        {
            _orderService = orderService;
            _queryService = queryService;
        }
        
        // Public module interface
        public async Task<OrderInfo> GetOrderInfoAsync(OrderId id)
        {
            var order = await _queryService.GetOrderAsync(id);
            return order != null ? new OrderInfo
            {
                Id = order.Id,
                CustomerId = order.CustomerId,
                Status = order.Status.ToString(),
                TotalAmount = order.TotalAmount.Value,
                CreatedAt = order.CreatedAt
            } : null;
        }
        
        public async Task<IEnumerable<OrderInfo>> GetCustomerOrdersAsync(CustomerId customerId)
        {
            var orders = await _queryService.GetCustomerOrdersAsync(customerId);
            return orders.Select(o => new OrderInfo
            {
                Id = o.Id,
                CustomerId = o.CustomerId,
                Status = o.Status.ToString(),
                TotalAmount = o.TotalAmount.Value,
                CreatedAt = o.CreatedAt
            });
        }
    }
    
    // Internal service (not exposed outside module)
    internal class OrderService : IOrderService
    {
        private readonly IOrderRepository _repository;
        private readonly IProductModule _productModule;
        private readonly IModuleEventBus _eventBus;
        
        // Implementation details hidden from other modules
        public async Task<OrderResult> CreateOrderAsync(CreateOrderCommand command)
        {
            // Business logic implementation
            // ...
        }
    }
    
    // Module-specific repository
    internal class OrderRepository : IOrderRepository
    {
        private readonly OrderDbContext _context;
        
        public async Task<Order> GetByIdAsync(OrderId id)
        {
            return await _context.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == id);
        }
        
        public async Task AddAsync(Order order)
        {
            await _context.Orders.AddAsync(order);
            await _context.SaveChangesAsync();
        }
    }
}
```

### 2. Module Configuration

```csharp
// ✅ Module Registration and Configuration
namespace ECommerce.Modules.Orders
{
    public static class OrderModuleExtensions
    {
        public static IServiceCollection AddOrderModule(
            this IServiceCollection services, 
            string connectionString)
        {
            // Register module facade
            services.AddScoped<IOrderModule, OrderModule>();
            
            // Register internal services
            services.AddScoped<IOrderService, OrderService>();
            services.AddScoped<IOrderQueryService, OrderQueryService>();
            services.AddScoped<IOrderRepository, OrderRepository>();
            
            // Register module-specific DbContext
            services.AddDbContext<OrderDbContext>(options =>
                options.UseSqlServer(connectionString));
            
            // Register domain event handlers
            services.AddScoped<INotificationHandler<OrderCreatedEvent>, OrderCreatedEventHandler>();
            services.AddScoped<INotificationHandler<OrderConfirmedEvent>, OrderConfirmedEventHandler>();
            
            return services;
        }
        
        public static void ConfigureOrderModule(this IApplicationBuilder app)
        {
            // Module-specific middleware if needed
            using var scope = app.ApplicationServices.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<OrderDbContext>();
            context.Database.EnsureCreated();
        }
    }
}

// Application startup configuration
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        var connectionString = Configuration.GetConnectionString("DefaultConnection");
        
        // Register all modules
        services.AddOrderModule(connectionString);
        services.AddProductModule(connectionString);
        services.AddInventoryModule(connectionString);
        services.AddCustomerModule(connectionString);
        
        // Register cross-cutting concerns
        services.AddScoped<IModuleEventBus, ModuleEventBus>();
        services.AddMediatR(typeof(Startup));
    }
    
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        // Configure modules
        app.ConfigureOrderModule();
        app.ConfigureProductModule();
        app.ConfigureInventoryModule();
        app.ConfigureCustomerModule();
    }
}
```

---

## 🔄 Inter-Module Communication {#communication}

### 1. Synchronous Communication via Contracts

```csharp
// ✅ Direct Module-to-Module Calls
public class OrderProcessingService
{
    private readonly IProductModule _productModule;
    private readonly IInventoryModule _inventoryModule;
    private readonly ICustomerModule _customerModule;
    
    public async Task<ProcessOrderResult> ProcessOrderAsync(ProcessOrderCommand command)
    {
        // Step 1: Validate customer (synchronous call)
        var customer = await _customerModule.GetCustomerAsync(command.CustomerId);
        if (customer == null)
            return ProcessOrderResult.Failed("Customer not found");
        
        // Step 2: Validate products (synchronous call)
        var productValidation = await _productModule.ValidateProductsAsync(command.ProductIds);
        if (!productValidation.IsValid)
            return ProcessOrderResult.Failed(productValidation.Errors);
        
        // Step 3: Check inventory (synchronous call)
        var inventoryCheck = await _inventoryModule.CheckAvailabilityAsync(command.Items);
        if (!inventoryCheck.IsAvailable)
            return ProcessOrderResult.Failed("Insufficient inventory");
        
        // All validations passed - process order
        return ProcessOrderResult.Success();
    }
}
```

### 2. Asynchronous Communication via Events

```csharp
// ✅ Event-Driven Communication Between Modules
namespace ECommerce.Infrastructure.Events
{
    public interface IModuleEventBus
    {
        Task PublishAsync<T>(T @event) where T : class, IModuleEvent;
        void Subscribe<T>(Func<T, Task> handler) where T : class, IModuleEvent;
    }
    
    public class ModuleEventBus : IModuleEventBus
    {
        private readonly IMediator _mediator;
        
        public ModuleEventBus(IMediator mediator)
        {
            _mediator = mediator;
        }
        
        public async Task PublishAsync<T>(T @event) where T : class, IModuleEvent
        {
            await _mediator.Publish(@event);
        }
        
        public void Subscribe<T>(Func<T, Task> handler) where T : class, IModuleEvent
        {
            // Registration handled by MediatR
        }
    }
}

// Module events
namespace ECommerce.Events.Orders
{
    public class OrderCreatedEvent : IModuleEvent
    {
        public OrderId OrderId { get; }
        public CustomerId CustomerId { get; }
        public DateTime CreatedAt { get; }
        public IEnumerable<OrderItem> Items { get; }
        
        public OrderCreatedEvent(OrderId orderId, CustomerId customerId, IEnumerable<OrderItem> items)
        {
            OrderId = orderId;
            CustomerId = customerId;
            Items = items;
            CreatedAt = DateTime.UtcNow;
        }
    }
    
    public class OrderConfirmedEvent : IModuleEvent
    {
        public OrderId OrderId { get; }
        public CustomerId CustomerId { get; }
        public decimal TotalAmount { get; }
        
        public OrderConfirmedEvent(OrderId orderId, CustomerId customerId, decimal totalAmount)
        {
            OrderId = orderId;
            CustomerId = customerId;
            TotalAmount = totalAmount;
        }
    }
}

// Event handlers in different modules
namespace ECommerce.Modules.Inventory
{
    public class OrderCreatedEventHandler : INotificationHandler<OrderCreatedEvent>
    {
        private readonly IInventoryService _inventoryService;
        
        public async Task Handle(OrderCreatedEvent notification, CancellationToken cancellationToken)
        {
            // Reserve inventory for the order
            var items = notification.Items.Select(i => new InventoryItem
            {
                ProductId = i.ProductId,
                Quantity = i.Quantity
            });
            
            await _inventoryService.ReserveStockAsync(items);
        }
    }
}

namespace ECommerce.Modules.Notifications
{
    public class OrderConfirmedEventHandler : INotificationHandler<OrderConfirmedEvent>
    {
        private readonly IEmailService _emailService;
        private readonly ICustomerModule _customerModule;
        
        public async Task Handle(OrderConfirmedEvent notification, CancellationToken cancellationToken)
        {
            // Send confirmation email to customer
            var customer = await _customerModule.GetCustomerAsync(notification.CustomerId);
            
            await _emailService.SendOrderConfirmationAsync(
                customer.Email,
                notification.OrderId,
                notification.TotalAmount);
        }
    }
}
```

### 3. Query Pattern for Cross-Module Data

```csharp
// ✅ Query Pattern for Read Operations
namespace ECommerce.Contracts.Queries
{
    public interface IOrderQueries
    {
        Task<OrderDetails> GetOrderDetailsAsync(OrderId id);
        Task<CustomerOrderSummary> GetCustomerOrderSummaryAsync(CustomerId customerId);
    }
    
    public class OrderDetails
    {
        public OrderId Id { get; init; }
        public CustomerInfo Customer { get; init; }
        public IEnumerable<OrderItemDetails> Items { get; init; }
        public string Status { get; init; }
        public decimal TotalAmount { get; init; }
    }
    
    public class OrderItemDetails
    {
        public ProductInfo Product { get; init; }
        public int Quantity { get; init; }
        public decimal UnitPrice { get; init; }
        public decimal LineTotal { get; init; }
    }
}

public class OrderQueries : IOrderQueries
{
    private readonly IOrderModule _orderModule;
    private readonly IProductModule _productModule;
    private readonly ICustomerModule _customerModule;
    
    public async Task<OrderDetails> GetOrderDetailsAsync(OrderId id)
    {
        // Get order data
        var order = await _orderModule.GetOrderInfoAsync(id);
        if (order == null) return null;
        
        // Get customer data
        var customer = await _customerModule.GetCustomerAsync(order.CustomerId);
        
        // Get product data for all items
        var productIds = order.Items.Select(i => i.ProductId);
        var products = await _productModule.GetProductsAsync(productIds);
        
        // Compose final result
        return new OrderDetails
        {
            Id = order.Id,
            Customer = customer,
            Items = order.Items.Select(item => new OrderItemDetails
            {
                Product = products.First(p => p.Id == item.ProductId),
                Quantity = item.Quantity,
                UnitPrice = item.UnitPrice,
                LineTotal = item.Quantity * item.UnitPrice
            }),
            Status = order.Status,
            TotalAmount = order.TotalAmount
        };
    }
}
```

---

## 📁 Module Organization Patterns {#organization}

### 1. Vertical Slice Architecture

```text
src/
├── ECommerce.Modules.Orders/
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── Order.cs
│   │   │   └── OrderItem.cs
│   │   ├── ValueObjects/
│   │   │   ├── OrderId.cs
│   │   │   └── Money.cs
│   │   └── Services/
│   │       └── OrderDomainService.cs
│   ├── Application/
│   │   ├── Commands/
│   │   │   ├── CreateOrderCommand.cs
│   │   │   └── ConfirmOrderCommand.cs
│   │   ├── Queries/
│   │   │   └── GetOrderQuery.cs
│   │   └── Services/
│   │       └── OrderService.cs
│   ├── Infrastructure/
│   │   ├── Data/
│   │   │   ├── OrderDbContext.cs
│   │   │   └── OrderRepository.cs
│   │   └── Events/
│   │       └── OrderEventHandlers.cs
│   ├── Contracts/
│   │   ├── IOrderModule.cs
│   │   └── DTOs/
│   │       └── OrderInfo.cs
│   └── OrderModuleExtensions.cs
└── ECommerce.Modules.Products/
    ├── Domain/
    ├── Application/
    ├── Infrastructure/
    ├── Contracts/
    └── ProductModuleExtensions.cs
```

### 2. Feature-Based Organization

```csharp
// ✅ Feature-Complete Module Structure
namespace ECommerce.Modules.Orders.Features.CreateOrder
{
    // Command and handler in the same feature folder
    public class CreateOrderCommand : IRequest<CreateOrderResult>
    {
        public CustomerId CustomerId { get; init; }
        public IEnumerable<CreateOrderItem> Items { get; init; }
    }
    
    public class CreateOrderHandler : IRequestHandler<CreateOrderCommand, CreateOrderResult>
    {
        private readonly IOrderRepository _repository;
        private readonly IProductModule _productModule;
        private readonly IModuleEventBus _eventBus;
        
        public async Task<CreateOrderResult> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
        {
            // Feature implementation
            var order = new Order(request.CustomerId);
            
            foreach (var item in request.Items)
            {
                var product = await _productModule.GetProductInfoAsync(item.ProductId);
                order.AddItem(item.ProductId, item.Quantity, product.Price);
            }
            
            await _repository.AddAsync(order);
            await _eventBus.PublishAsync(new OrderCreatedEvent(order.Id, order.CustomerId, order.Items));
            
            return CreateOrderResult.Success(order.Id);
        }
    }
    
    // Validation in the same feature
    public class CreateOrderValidator : AbstractValidator<CreateOrderCommand>
    {
        public CreateOrderValidator()
        {
            RuleFor(x => x.CustomerId).NotEmpty();
            RuleFor(x => x.Items).NotEmpty();
            RuleForEach(x => x.Items).SetValidator(new CreateOrderItemValidator());
        }
    }
}

namespace ECommerce.Modules.Orders.Features.GetOrder
{
    public class GetOrderQuery : IRequest<OrderDetails>
    {
        public OrderId OrderId { get; init; }
    }
    
    public class GetOrderHandler : IRequestHandler<GetOrderQuery, OrderDetails>
    {
        private readonly IOrderRepository _repository;
        private readonly IProductModule _productModule;
        private readonly ICustomerModule _customerModule;
        
        public async Task<OrderDetails> Handle(GetOrderQuery request, CancellationToken cancellationToken)
        {
            // Query implementation
            var order = await _repository.GetByIdAsync(request.OrderId);
            if (order == null) return null;
            
            // Compose data from multiple modules
            var customer = await _customerModule.GetCustomerAsync(order.CustomerId);
            var productIds = order.Items.Select(i => i.ProductId);
            var products = await _productModule.GetProductsAsync(productIds);
            
            return new OrderDetails
            {
                Id = order.Id,
                Customer = customer,
                Items = order.Items.Select(item => new OrderItemDetails
                {
                    Product = products.First(p => p.Id == item.ProductId),
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice
                })
            };
        }
    }
}
```

---

## 💾 Data Management Strategies {#data-management}

### 1. Module-Specific Databases

```csharp
// ✅ Separate DbContext per Module
namespace ECommerce.Modules.Orders.Infrastructure
{
    public class OrderDbContext : DbContext
    {
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        
        public OrderDbContext(DbContextOptions<OrderDbContext> options) : base(options) { }
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Apply only Order module configurations
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(OrderDbContext).Assembly);
            
            // Schema separation
            modelBuilder.HasDefaultSchema("orders");
        }
    }
}

namespace ECommerce.Modules.Products.Infrastructure
{
    public class ProductDbContext : DbContext
    {
        public DbSet<Product> Products { get; set; }
        public DbSet<Category> Categories { get; set; }
        
        public ProductDbContext(DbContextOptions<ProductDbContext> options) : base(options) { }
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(ProductDbContext).Assembly);
            modelBuilder.HasDefaultSchema("products");
        }
    }
}
```

### 2. Cross-Module Transactions

```csharp
// ✅ Distributed Transaction Pattern
public class OrderProcessingService
{
    private readonly OrderDbContext _orderContext;
    private readonly InventoryDbContext _inventoryContext;
    private readonly IModuleEventBus _eventBus;
    
    public async Task<ProcessOrderResult> ProcessOrderAsync(ProcessOrderCommand command)
    {
        // Use distributed transaction for consistency
        using var transaction = new TransactionScope(
            TransactionScopeOption.Required,
            new TransactionOptions { IsolationLevel = IsolationLevel.ReadCommitted },
            TransactionScopeAsyncFlowOption.Enabled);
        
        try
        {
            // Update order
            var order = await _orderContext.Orders.FindAsync(command.OrderId);
            order.Confirm();
            await _orderContext.SaveChangesAsync();
            
            // Update inventory
            foreach (var item in order.Items)
            {
                var stock = await _inventoryContext.Stock
                    .FirstAsync(s => s.ProductId == item.ProductId);
                stock.Reserve(item.Quantity);
            }
            await _inventoryContext.SaveChangesAsync();
            
            // Commit transaction
            transaction.Complete();
            
            // Publish events after successful transaction
            await _eventBus.PublishAsync(new OrderConfirmedEvent(order.Id, order.CustomerId, order.TotalAmount));
            
            return ProcessOrderResult.Success();
        }
        catch (Exception ex)
        {
            // Transaction will automatically rollback
            return ProcessOrderResult.Failed(ex.Message);
        }
    }
}
```

### 3. Event Sourcing for Module Communication

```csharp
// ✅ Event Store for Module Integration
public class ModuleEventStore
{
    private readonly EventStoreDbContext _context;
    
    public async Task SaveEventAsync<T>(T @event) where T : IModuleEvent
    {
        var eventData = new StoredEvent
        {
            Id = Guid.NewGuid(),
            EventType = typeof(T).Name,
            EventData = JsonSerializer.Serialize(@event),
            OccurredAt = DateTime.UtcNow,
            ModuleName = GetModuleName<T>()
        };
        
        await _context.Events.AddAsync(eventData);
        await _context.SaveChangesAsync();
    }
    
    public async Task<IEnumerable<T>> GetEventsAsync<T>(DateTime from, DateTime to) where T : IModuleEvent
    {
        var events = await _context.Events
            .Where(e => e.EventType == typeof(T).Name && 
                       e.OccurredAt >= from && 
                       e.OccurredAt <= to)
            .OrderBy(e => e.OccurredAt)
            .ToListAsync();
        
        return events.Select(e => JsonSerializer.Deserialize<T>(e.EventData));
    }
}

// Read model projections for cross-module queries
public class OrderProjectionService : INotificationHandler<OrderCreatedEvent>
{
    private readonly ProjectionDbContext _context;
    private readonly IProductModule _productModule;
    private readonly ICustomerModule _customerModule;
    
    public async Task Handle(OrderCreatedEvent notification, CancellationToken cancellationToken)
    {
        // Build read model with data from multiple modules
        var customer = await _customerModule.GetCustomerAsync(notification.CustomerId);
        var productIds = notification.Items.Select(i => i.ProductId);
        var products = await _productModule.GetProductsAsync(productIds);
        
        var projection = new OrderProjection
        {
            OrderId = notification.OrderId,
            CustomerName = customer.Name,
            CustomerEmail = customer.Email,
            Items = notification.Items.Select(item => new OrderItemProjection
            {
                ProductName = products.First(p => p.Id == item.ProductId).Name,
                Quantity = item.Quantity,
                UnitPrice = item.UnitPrice
            }).ToList(),
            CreatedAt = notification.CreatedAt
        };
        
        await _context.OrderProjections.AddAsync(projection);
        await _context.SaveChangesAsync();
    }
}
```

---

## 🧪 Testing Modular Systems {#testing}

### 1. Module Unit Testing

```csharp
// ✅ Test Module in Isolation
public class OrderModuleTests
{
    private readonly Mock<IProductModule> _productModuleMock;
    private readonly Mock<IInventoryModule> _inventoryModuleMock;
    private readonly Mock<IModuleEventBus> _eventBusMock;
    private readonly OrderService _orderService;
    
    public OrderModuleTests()
    {
        _productModuleMock = new Mock<IProductModule>();
        _inventoryModuleMock = new Mock<IInventoryModule>();
        _eventBusMock = new Mock<IModuleEventBus>();
        
        _orderService = new OrderService(
            Mock.Of<IOrderRepository>(),
            _productModuleMock.Object,
            _inventoryModuleMock.Object,
            _eventBusMock.Object);
    }
    
    [Fact]
    public async Task CreateOrder_WithValidProducts_ShouldCreateSuccessfully()
    {
        // Arrange
        var command = new CreateOrderCommand
        {
            CustomerId = new CustomerId(Guid.NewGuid()),
            Items = new[]
            {
                new CreateOrderItem { ProductId = new ProductId(Guid.NewGuid()), Quantity = 2 }
            }
        };
        
        _productModuleMock
            .Setup(x => x.ValidateProductsAsync(It.IsAny<IEnumerable<ProductId>>()))
            .ReturnsAsync(ProductValidationResult.Success(command.Items.Select(i => i.ProductId)));
        
        _inventoryModuleMock
            .Setup(x => x.CheckAvailabilityAsync(It.IsAny<IEnumerable<InventoryItem>>()))
            .ReturnsAsync(InventoryCheckResult.Available());
        
        // Act
        var result = await _orderService.CreateOrderAsync(command);
        
        // Assert
        Assert.True(result.IsSuccess);
        _eventBusMock.Verify(x => x.PublishAsync(It.IsAny<OrderCreatedEvent>()), Times.Once);
    }
    
    [Fact]
    public async Task CreateOrder_WithInvalidProducts_ShouldFail()
    {
        // Arrange
        var command = new CreateOrderCommand
        {
            CustomerId = new CustomerId(Guid.NewGuid()),
            Items = new[]
            {
                new CreateOrderItem { ProductId = new ProductId(Guid.NewGuid()), Quantity = 2 }
            }
        };
        
        _productModuleMock
            .Setup(x => x.ValidateProductsAsync(It.IsAny<IEnumerable<ProductId>>()))
            .ReturnsAsync(ProductValidationResult.Failed(new[] { "Product not found" }));
        
        // Act
        var result = await _orderService.CreateOrderAsync(command);
        
        // Assert
        Assert.False(result.IsSuccess);
        Assert.Contains("Product not found", result.Errors);
        _eventBusMock.Verify(x => x.PublishAsync(It.IsAny<OrderCreatedEvent>()), Times.Never);
    }
}
```

### 2. Module Integration Testing

```csharp
// ✅ Test Module Interactions
public class ModuleIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly IServiceProvider _services;
    
    public ModuleIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _services = _factory.Services;
    }
    
    [Fact]
    public async Task OrderWorkflow_ShouldIntegrateAllModules()
    {
        // Arrange
        using var scope = _services.CreateScope();
        var orderModule = scope.ServiceProvider.GetRequiredService<IOrderModule>();
        var productModule = scope.ServiceProvider.GetRequiredService<IProductModule>();
        var inventoryModule = scope.ServiceProvider.GetRequiredService<IInventoryModule>();
        var customerModule = scope.ServiceProvider.GetRequiredService<ICustomerModule>();
        
        // Create test data
        var customerId = await CreateTestCustomerAsync(customerModule);
        var productId = await CreateTestProductAsync(productModule);
        await SetupInventoryAsync(inventoryModule, productId, 10);
        
        // Act - Create order through module interaction
        var createCommand = new CreateOrderCommand
        {
            CustomerId = customerId,
            Items = new[] { new CreateOrderItem { ProductId = productId, Quantity = 2 } }
        };
        
        var orderResult = await orderModule.CreateOrderAsync(createCommand);
        
        // Assert - Verify all modules were properly integrated
        Assert.True(orderResult.IsSuccess);
        
        var order = await orderModule.GetOrderInfoAsync(orderResult.OrderId);
        Assert.NotNull(order);
        Assert.Equal(customerId, order.CustomerId);
        
        // Verify inventory was reserved
        var inventoryStatus = await inventoryModule.CheckAvailabilityAsync(
            new[] { new InventoryItem { ProductId = productId, Quantity = 8 } });
        Assert.True(inventoryStatus.IsAvailable); // 10 - 2 reserved = 8 available
    }
}
```

### 3. Contract Testing

```csharp
// ✅ Test Module Contracts
public class ProductModuleContractTests
{
    private readonly IProductModule _productModule;
    
    public ProductModuleContractTests()
    {
        // Use real implementation for contract testing
        _productModule = CreateProductModule();
    }
    
    [Fact]
    public async Task GetProductInfo_WithValidId_ShouldReturnProductInfo()
    {
        // Arrange
        var productId = await CreateTestProductAsync("Test Product", 19.99m);
        
        // Act
        var result = await _productModule.GetProductInfoAsync(productId);
        
        // Assert - Verify contract compliance
        Assert.NotNull(result);
        Assert.Equal(productId, result.Id);
        Assert.Equal("Test Product", result.Name);
        Assert.Equal(19.99m, result.Price);
        Assert.True(result.IsActive);
    }
    
    [Fact]
    public async Task ValidateProducts_WithMixedValidAndInvalidIds_ShouldReturnPartialResult()
    {
        // Arrange
        var validProductId = await CreateTestProductAsync("Valid Product", 10.00m);
        var invalidProductId = new ProductId(Guid.NewGuid());
        
        // Act
        var result = await _productModule.ValidateProductsAsync(new[] { validProductId, invalidProductId });
        
        // Assert - Verify contract behavior
        Assert.False(result.IsValid); // Should be invalid due to one invalid product
        Assert.Contains(validProductId, result.ValidProductIds);
        Assert.DoesNotContain(invalidProductId, result.ValidProductIds);
        Assert.NotEmpty(result.Errors);
    }
}
```

---

## 🔄 Migration and Evolution {#migration}

### 1. Traditional Monolith to Modular Monolith

```csharp
// ❌ Before: Tightly Coupled Monolith
public class ECommerceService
{
    private readonly ApplicationDbContext _context;
    
    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        // All logic mixed together
        var customer = await _context.Customers.FindAsync(request.CustomerId);
        var products = await _context.Products.Where(p => request.ProductIds.Contains(p.Id)).ToListAsync();
        
        var order = new Order { CustomerId = request.CustomerId };
        foreach (var product in products)
        {
            var stock = await _context.Stock.FirstAsync(s => s.ProductId == product.Id);
            if (stock.Quantity < request.Quantities[product.Id])
                throw new InvalidOperationException("Insufficient stock");
                
            stock.Quantity -= request.Quantities[product.Id];
            order.Items.Add(new OrderItem { ProductId = product.Id, Quantity = request.Quantities[product.Id] });
        }
        
        await _context.Orders.AddAsync(order);
        await _context.SaveChangesAsync();
    }
}

// ✅ After: Modular Structure
public class OrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICustomerModule _customerModule;
    private readonly IProductModule _productModule;
    private readonly IInventoryModule _inventoryModule;
    
    public async Task<OrderResult> CreateOrderAsync(CreateOrderCommand command)
    {
        // Step 1: Validate customer through module
        var customerExists = await _customerModule.CustomerExistsAsync(command.CustomerId);
        if (!customerExists)
            return OrderResult.Failed("Customer not found");
        
        // Step 2: Validate products through module
        var productValidation = await _productModule.ValidateProductsAsync(command.ProductIds);
        if (!productValidation.IsValid)
            return OrderResult.Failed(productValidation.Errors);
        
        // Step 3: Check and reserve inventory through module
        var inventoryResult = await _inventoryModule.ReserveStockAsync(command.Items);
        if (!inventoryResult.IsSuccess)
            return OrderResult.Failed("Insufficient inventory");
        
        // Step 4: Create order in this module
        var order = new Order(command.CustomerId, command.Items);
        await _orderRepository.AddAsync(order);
        
        return OrderResult.Success(order.Id);
    }
}
```

### 2. Modular Monolith to Microservices

```csharp
// ✅ Extraction Strategy - API Gateway for Transition
public class OrderApiGateway
{
    private readonly IOrderModule _orderModule; // Still in monolith
    private readonly HttpClient _productServiceClient; // Already extracted
    private readonly HttpClient _inventoryServiceClient; // Already extracted
    
    public async Task<CreateOrderResponse> CreateOrderAsync(CreateOrderRequest request)
    {
        // Route to appropriate implementation
        if (await ShouldUseExtractedServicesAsync())
        {
            return await CreateOrderViaDistributedServicesAsync(request);
        }
        else
        {
            return await CreateOrderViaModularMonolithAsync(request);
        }
    }
    
    private async Task<CreateOrderResponse> CreateOrderViaDistributedServicesAsync(CreateOrderRequest request)
    {
        // Coordinate between microservices
        var productValidation = await _productServiceClient.PostAsync("/api/products/validate", 
            JsonContent.Create(request.ProductIds));
        
        if (!productValidation.IsSuccessStatusCode)
            return CreateOrderResponse.Failed("Product validation failed");
        
        var inventoryReservation = await _inventoryServiceClient.PostAsync("/api/inventory/reserve",
            JsonContent.Create(request.Items));
        
        if (!inventoryReservation.IsSuccessStatusCode)
            return CreateOrderResponse.Failed("Inventory reservation failed");
        
        // Create order in Order Service (extracted)
        var orderCreation = await _orderServiceClient.PostAsync("/api/orders",
            JsonContent.Create(request));
        
        return await orderCreation.Content.ReadFromJsonAsync<CreateOrderResponse>();
    }
    
    private async Task<CreateOrderResponse> CreateOrderViaModularMonolithAsync(CreateOrderRequest request)
    {
        // Use existing modular monolith
        var command = new CreateOrderCommand
        {
            CustomerId = request.CustomerId,
            Items = request.Items
        };
        
        var result = await _orderModule.CreateOrderAsync(command);
        return result.IsSuccess 
            ? CreateOrderResponse.Success(result.OrderId)
            : CreateOrderResponse.Failed(result.Errors);
    }
}
```

### 3. Gradual Service Extraction

```csharp
// ✅ Strangler Fig Pattern for Service Extraction
public class ProductServiceExtractor
{
    private readonly IProductModule _productModule;
    private readonly HttpClient _productServiceClient;
    private readonly IFeatureToggle _featureToggle;
    
    public async Task<ProductInfo> GetProductInfoAsync(ProductId id)
    {
        // Feature toggle determines routing
        if (await _featureToggle.IsEnabledAsync("ProductServiceExtracted"))
        {
            // Route to extracted microservice
            var response = await _productServiceClient.GetAsync($"/api/products/{id}");
            return await response.Content.ReadFromJsonAsync<ProductInfo>();
        }
        else
        {
            // Route to modular monolith
            return await _productModule.GetProductInfoAsync(id);
        }
    }
    
    public async Task<ProductValidationResult> ValidateProductsAsync(IEnumerable<ProductId> productIds)
    {
        // Dual write during transition
        var monolithResult = await _productModule.ValidateProductsAsync(productIds);
        
        if (await _featureToggle.IsEnabledAsync("ProductServiceValidation"))
        {
            var serviceResult = await ValidateProductsViaServiceAsync(productIds);
            
            // Compare results for validation
            await _comparisonService.CompareResultsAsync(monolithResult, serviceResult);
            
            return serviceResult;
        }
        
        return monolithResult;
    }
}
```

---

## 🎯 Common Patterns and Anti-Patterns {#patterns}

### ✅ Best Practices

#### 1. **Clear Module Boundaries**

```csharp
// ✅ Well-Defined Module Interface
public interface IOrderModule
{
    // Commands
    Task<CreateOrderResult> CreateOrderAsync(CreateOrderCommand command);
    Task<ConfirmOrderResult> ConfirmOrderAsync(ConfirmOrderCommand command);
    
    // Queries
    Task<OrderInfo> GetOrderInfoAsync(OrderId id);
    Task<IEnumerable<OrderInfo>> GetCustomerOrdersAsync(CustomerId customerId);
    
    // Domain Events (for integration)
    IObservable<OrderCreatedEvent> OrderCreated { get; }
    IObservable<OrderConfirmedEvent> OrderConfirmed { get; }
}
```

#### 2. **Event-Driven Integration**

```csharp
// ✅ Loose Coupling via Events
public class InventoryModule : IInventoryModule
{
    public async Task Handle(OrderCreatedEvent @event)
    {
        // React to order events without tight coupling
        var items = @event.Items.Select(i => new InventoryItem
        {
            ProductId = i.ProductId,
            Quantity = i.Quantity
        });
        
        await ReserveStockAsync(items);
    }
}
```

### ❌ Anti-Patterns

#### 1. **Cross-Module Direct Database Access**

```csharp
// ❌ BAD: Direct database access between modules
public class OrderService
{
    private readonly OrderDbContext _orderContext;
    private readonly ProductDbContext _productContext; // ❌ Wrong!
    
    public async Task CreateOrderAsync(CreateOrderCommand command)
    {
        // ❌ Directly accessing another module's database
        var products = await _productContext.Products
            .Where(p => command.ProductIds.Contains(p.Id))
            .ToListAsync();
        
        // This breaks module boundaries
    }
}

// ✅ GOOD: Use module contracts
public class OrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IProductModule _productModule; // ✅ Correct!
    
    public async Task CreateOrderAsync(CreateOrderCommand command)
    {
        // ✅ Use module interface
        var products = await _productModule.GetProductsAsync(command.ProductIds);
    }
}
```

#### 2. **Shared Domain Models**

```csharp
// ❌ BAD: Shared domain entities between modules
namespace ECommerce.Shared.Entities
{
    public class Product // ❌ Shared across modules
    {
        public ProductId Id { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        // This creates coupling between modules
    }
}

// ✅ GOOD: Module-specific domain models with DTOs for integration
namespace ECommerce.Modules.Products.Domain
{
    public class Product // ✅ Product module's domain model
    {
        public ProductId Id { get; private set; }
        public string Name { get; private set; }
        public Money Price { get; private set; }
        // Product-specific domain logic
    }
}

namespace ECommerce.Contracts.Products
{
    public class ProductInfo // ✅ DTO for inter-module communication
    {
        public ProductId Id { get; init; }
        public string Name { get; init; }
        public decimal Price { get; init; }
    }
}
```

#### 3. **Module God Objects**

```csharp
// ❌ BAD: Module doing too much
public interface IECommerceModule
{
    // ❌ Too many responsibilities
    Task<CustomerResult> CreateCustomerAsync(CreateCustomerCommand command);
    Task<ProductResult> CreateProductAsync(CreateProductCommand command);
    Task<OrderResult> CreateOrderAsync(CreateOrderCommand command);
    Task<InventoryResult> UpdateInventoryAsync(UpdateInventoryCommand command);
    Task<PaymentResult> ProcessPaymentAsync(ProcessPaymentCommand command);
}

// ✅ GOOD: Single-responsibility modules
public interface ICustomerModule
{
    Task<CustomerResult> CreateCustomerAsync(CreateCustomerCommand command);
    Task<CustomerInfo> GetCustomerAsync(CustomerId id);
}

public interface IProductModule
{
    Task<ProductResult> CreateProductAsync(CreateProductCommand command);
    Task<ProductInfo> GetProductAsync(ProductId id);
}

public interface IOrderModule
{
    Task<OrderResult> CreateOrderAsync(CreateOrderCommand command);
    Task<OrderInfo> GetOrderAsync(OrderId id);
}
```

---

## 🔗 Related Topics

### Prerequisites

- [Monolithic Architecture](./08_Monolithic-Architecture.md)
- [Domain-Driven Design Fundamentals](./02_Domain-Driven-Design-Fundamentals.md)
- [Clean Architecture Fundamentals](./01_Clean-Architecture-Fundamentals.md)

### Builds Upon

- Event-Driven Architecture patterns
- SOLID Principles for module design
- Dependency Injection and IoC containers

### Enables

- [Microservices Architecture](./05_Microservices-Architecture.md)
- [Event-Driven Architecture](./06_Event-Driven-Architecture.md)
- [System Design Fundamentals](./04_System-Design-Fundamentals.md)

### Cross-References

- **Design Patterns**: Module, Facade, Observer for inter-module communication
- **Testing**: Integration testing strategies for modular systems
- **Performance**: Module-level caching and optimization
- **DevOps**: Module-based deployment strategies

---

## 📚 Summary

Modular Monolith architecture provides an excellent middle ground between traditional monoliths and microservices, offering:

1. **Structural Benefits**: Clear boundaries and separation of concerns
2. **Operational Simplicity**: Single deployment unit with simplified infrastructure
3. **Performance**: In-process communication with minimal latency
4. **Evolution Path**: Natural progression to microservices when needed
5. **Testing Strategy**: Module isolation with comprehensive integration testing

**Key Success Factors**:

- Define clear module boundaries aligned with business domains
- Use contracts and events for inter-module communication
- Maintain module independence with separate data stores
- Implement comprehensive testing at module and integration levels
- Plan evolution strategy for potential microservices extraction

**When to Use Modular Monolith**:

- Medium-complexity applications with clear domain boundaries
- Teams of 5-20 developers with good communication
- Applications requiring strong consistency with eventual evolution needs
- Organizations building operational maturity before microservices

**Next Steps**: Explore [Microservices Architecture](./05_Microservices-Architecture.md) when scaling and organizational factors justify distributed systems complexity.
