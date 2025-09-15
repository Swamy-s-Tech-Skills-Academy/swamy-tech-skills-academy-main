# 05B_Microservices-Communication-Patterns

**Learning Level**: Advanced
**Prerequisites**: [05A_Microservices-Architecture-Overview-Decomposition.md](05A_Microservices-Architecture-Overview-Decomposition.md)
**Estimated Time**: 27 minutes
**Series**: Part B of 5 - Microservices Fundamentals
**Next**: [05C_Microservices-Resilience-Patterns.md](05C_Microservices-Resilience-Patterns.md)

---

## 🎯 Learning Objectives (27-Minute Session)

By the end of this session, you will:

- Master synchronous communication patterns for microservices
- Implement asynchronous event-driven communication
- Design effective API contracts between services
- Choose appropriate communication protocols for different scenarios

---

## 📋 Content Sections (27-Minute Structure)

### Quick Overview (5 minutes)

**Communication Patterns**: The foundation of microservices interaction

```text
Communication Pattern Decision Tree
├── Real-time response needed? → Synchronous (HTTP/REST/gRPC)
├── Event-driven processing? → Asynchronous (Message Queue/Event Bus)
├── High throughput required? → gRPC/GraphQL
└── Loose coupling preferred? → Events/Message Bus
```

### Synchronous Communication (11 minutes)

#### HTTP REST API Communication

**Service-to-Service Communication**: Direct HTTP calls between microservices

```csharp
// HTTP REST API Communication
public class OrderController : ControllerBase
{
    private readonly ICustomerServiceClient _customerService;
    private readonly IInventoryServiceClient _inventoryService;

    public OrderController(
        ICustomerServiceClient customerService,
        IInventoryServiceClient inventoryService)
    {
        _customerService = customerService;
        _inventoryService = inventoryService;
    }

    [HttpPost]
    public async Task<ActionResult<OrderDto>> CreateOrderAsync(CreateOrderRequest request)
    {
        try
        {
            // Validate customer exists
            var customer = await _customerService.GetCustomerAsync(request.CustomerId);
            if (customer == null)
                return BadRequest("Customer not found");

            // Check inventory availability
            foreach (var item in request.Items)
            {
                var availability = await _inventoryService.CheckAvailabilityAsync(
                    item.ProductId, item.Quantity);
                if (!availability.IsAvailable)
                    return BadRequest($"Insufficient stock for product {item.ProductId}");
            }

            // Create order
            var order = new Order(request.CustomerId, request.Items);
            await _orderRepository.SaveAsync(order);

            return Ok(OrderDto.FromDomain(order));
        }
        catch (HttpRequestException ex)
        {
            // Handle service communication failures
            _logger.LogError(ex, "Failed to communicate with dependent service");
            return StatusCode(503, "Service temporarily unavailable");
        }
    }
}
```

**API Gateway Pattern**: Single entry point for external clients

```text
API Gateway Benefits
├── Request routing and composition
├── Authentication and authorization
├── Rate limiting and throttling
├── Response transformation
└── Centralized logging and monitoring
```

### Asynchronous Communication (11 minutes)

#### Event-Driven Communication

**Message Bus Pattern**: Decoupled service communication through events

```csharp
// Event-Driven Communication using Message Bus
public class OrderCreatedEvent
{
    public OrderId OrderId { get; set; }
    public CustomerId CustomerId { get; set; }
    public List<OrderItemDto> Items { get; set; }
    public DateTime CreatedAt { get; set; }
}

// Order Service - Publishing Events
public class OrderService
{
    private readonly IMessagePublisher _messagePublisher;

    public async Task CreateOrderAsync(CreateOrderCommand command)
    {
        var order = new Order(command.CustomerId, command.Items);
        await _orderRepository.SaveAsync(order);

        // Publish event for other services to react
        var orderCreatedEvent = new OrderCreatedEvent
        {
            OrderId = order.Id,
            CustomerId = order.CustomerId,
            Items = order.Items.Select(i => new OrderItemDto
            {
                ProductId = i.ProductId,
                Quantity = i.Quantity,
                Price = i.Price
            }).ToList(),
            CreatedAt = DateTime.UtcNow
        };

        await _messagePublisher.PublishAsync("order.created", orderCreatedEvent);
    }
}
```

**Event Consumption Pattern**: Reactive service behavior

```csharp
// Inventory Service - Consuming Events
public class InventoryEventHandler
{
    private readonly IInventoryService _inventoryService;

    [EventHandler("order.created")]
    public async Task HandleOrderCreatedAsync(OrderCreatedEvent orderCreatedEvent)
    {
        // Reserve inventory for the order
        foreach (var item in orderCreatedEvent.Items)
        {
            await _inventoryService.ReserveStockAsync(item.ProductId, item.Quantity);
        }
    }
}
```

**Message Broker Configuration**: Infrastructure setup for reliable messaging

```csharp
// Message Bus Configuration (using RabbitMQ/Azure Service Bus)
public class MessageBusConfiguration
{
    public static void ConfigureMessageBus(IServiceCollection services, IConfiguration configuration)
    {
        services.AddSingleton<IMessagePublisher>(provider =>
        {
            var connectionString = configuration.GetConnectionString("MessageBus");
            return new RabbitMQPublisher(connectionString);
        });

        services.AddSingleton<IMessageConsumer>(provider =>
        {
            var connectionString = configuration.GetConnectionString("MessageBus");
            return new RabbitMQConsumer(connectionString);
        });
    }
}
```

---

## ✅ Key Takeaways (2 minutes)

### **Essential Understanding**

1. **Synchronous communication** provides immediate responses but creates tight coupling
2. **Asynchronous communication** enables loose coupling and better scalability
3. **Event-driven patterns** support complex business workflows and eventual consistency
4. **API design** must consider service boundaries and contract evolution

### **What's Next**

**Part C** will cover:

- Circuit breaker and retry patterns for resilience
- Bulkhead pattern for resource isolation
- Timeout and fallback strategies

---

## 🔗 Series Navigation

- **Previous**: [05A_Microservices-Architecture-Overview-Decomposition.md](05A_Microservices-Architecture-Overview-Decomposition.md)
- **Current**: Part B - Communication Patterns ✅
- **Next**: [05C_Microservices-Resilience-Patterns.md](05C_Microservices-Resilience-Patterns.md)
- **Series**: Microservices Architecture Fundamentals (Part B of 5)

**Last Updated**: September 15, 2025
**Format**: 27-minute focused learning segment
