# 05D_Microservices-Data-Management

**Learning Level**: Advanced
**Prerequisites**: [05C_Microservices-Resilience-Patterns.md](05C_Microservices-Resilience-Patterns.md)
**Estimated Time**: 27 minutes
**Series**: Part D of 5 - Microservices Fundamentals
**Next**: [05E_Microservices-Monitoring-Observability.md](05E_Microservices-Monitoring-Observability.md)

---

## 🎯 Learning Objectives (27-Minute Session)

By the end of this session, you will:

- Implement saga pattern for distributed transactions
- Apply event sourcing for data consistency
- Design CQRS patterns for complex domains
- Choose appropriate data management strategies

---

## 📋 Content Sections (27-Minute Structure)

### Quick Overview (5 minutes)

**Data Management Patterns**: Ensuring consistency across distributed microservices

```text
Data Pattern Decision Tree
├── ACID transactions needed? → Saga Pattern
├── Audit trail required? → Event Sourcing
├── Complex queries separate? → CQRS Pattern
├── Read optimization needed? → Materialized Views
└── Cache invalidation? → Cache-Aside Pattern
```

#### Saga Pattern Concept

**Saga Pattern**: Manages distributed transactions using local transactions and compensation

```text
Saga Pattern Benefits
├── Maintains data consistency across services
├── Handles partial failures gracefully
├── Enables loose coupling between services
├── Supports long-running business processes
└── Provides audit trail for transactions
```

#### Saga Pattern Implementation

```csharp
// Order Processing Saga
public class OrderProcessingSaga
{
    private readonly ICustomerService _customerService;
    private readonly IInventoryService _inventoryService;
    private readonly IPaymentService _paymentService;
    private readonly ISagaRepository _sagaRepository;

    public async Task ProcessOrderAsync(CreateOrderCommand command)
    {
        var sagaId = Guid.NewGuid();
        var saga = new OrderSagaState
        {
            SagaId = sagaId,
            OrderId = command.OrderId,
            CustomerId = command.CustomerId,
            Items = command.Items,
            Status = SagaStatus.Started
        };

        try
        {
            // Step 1: Validate Customer
            saga.Status = SagaStatus.ValidatingCustomer;
            await _sagaRepository.SaveAsync(saga);

            var customer = await _customerService.ValidateCustomerAsync(command.CustomerId);
            saga.CustomerValidated = true;

            // Step 2: Reserve Inventory
            saga.Status = SagaStatus.ReservingInventory;
            await _sagaRepository.SaveAsync(saga);

            var reservationId = await _inventoryService.ReserveItemsAsync(command.Items);
            saga.ReservationId = reservationId;
            saga.InventoryReserved = true;

            // Step 3: Process Payment
            saga.Status = SagaStatus.ProcessingPayment;
            await _sagaRepository.SaveAsync(saga);

            var paymentId = await _paymentService.ProcessPaymentAsync(
                command.CustomerId, command.TotalAmount);
            saga.PaymentId = paymentId;
            saga.PaymentProcessed = true;

            // Step 4: Confirm Order
            saga.Status = SagaStatus.Completed;
            await _sagaRepository.SaveAsync(saga);

        }
        catch (Exception ex)
        {
            // Compensate for partial completion
            await CompensateAsync(saga);
            saga.Status = SagaStatus.Failed;
            await _sagaRepository.SaveAsync(saga);
            throw;
        }
    }

    private async Task CompensateAsync(OrderSagaState saga)
    {
        // Reverse operations in opposite order
        if (saga.PaymentProcessed)
        {
            await _paymentService.RefundPaymentAsync(saga.PaymentId);
        }

        if (saga.InventoryReserved)
        {
            await _inventoryService.ReleaseReservationAsync(saga.ReservationId);
        }

        // Customer validation doesn't need compensation
    }
}
```

#### Event Sourcing Concept

**Event Sourcing**: Stores state changes as a sequence of events for complete audit trail

```text
Event Sourcing Benefits
├── Complete audit trail of all changes
├── Time travel debugging capabilities
├── Event replay for state reconstruction
├── Natural fit for domain-driven design
└── Enables complex business logic analysis
```

#### Event Sourcing Implementation

```csharp
// Domain Events
public abstract class DomainEvent
{
    public Guid Id { get; } = Guid.NewGuid();
    public DateTime OccurredAt { get; } = DateTime.UtcNow;
    public int Version { get; set; }
}

public class OrderCreatedEvent : DomainEvent
{
    public OrderId OrderId { get; set; }
    public CustomerId CustomerId { get; set; }
    public List<OrderItemDto> Items { get; set; }
}

public class OrderItemAddedEvent : DomainEvent
{
    public OrderId OrderId { get; set; }
    public ProductId ProductId { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
}

// Aggregate Root with Event Sourcing
public class Order : AggregateRoot
{
    public OrderId Id { get; private set; }
    public CustomerId CustomerId { get; private set; }
    private readonly List<OrderItem> _items = new();
    public IReadOnlyList<OrderItem> Items => _items.AsReadOnly();

    // Constructor for creating new orders
    public Order(CustomerId customerId, List<OrderItemDto> items)
    {
        var orderCreatedEvent = new OrderCreatedEvent
        {
            OrderId = OrderId.New(),
            CustomerId = customerId,
            Items = items
        };

        ApplyEvent(orderCreatedEvent);
    }

    // Constructor for rebuilding from events
    public Order(IEnumerable<DomainEvent> events)
    {
        foreach (var domainEvent in events)
        {
            ApplyEvent(domainEvent, isNew: false);
        }
    }

    public void AddItem(ProductId productId, int quantity, decimal price)
    {
        var orderItemAddedEvent = new OrderItemAddedEvent
        {
            OrderId = Id,
            ProductId = productId,
            Quantity = quantity,
            Price = price
        };

        ApplyEvent(orderItemAddedEvent);
    }

    protected override void ApplyEvent(DomainEvent domainEvent, bool isNew = true)
    {
        switch (domainEvent)
        {
            case OrderCreatedEvent e:
                Apply(e);
                break;
            case OrderItemAddedEvent e:
                Apply(e);
                break;
        }

        if (isNew)
        {
            AddUncommittedEvent(domainEvent);
        }
    }

    private void Apply(OrderCreatedEvent e)
    {
        Id = e.OrderId;
        CustomerId = e.CustomerId;
        foreach (var item in e.Items)
        {
            _items.Add(new OrderItem(item.ProductId, item.Quantity, item.Price));
        }
    }

    private void Apply(OrderItemAddedEvent e)
    {
        _items.Add(new OrderItem(e.ProductId, e.Quantity, e.Price));
    }
}
```

---

## ✅ Key Takeaways (2 minutes)

### **Essential Understanding**

1. **Saga pattern manages distributed transactions** through local operations and compensation
2. **Event sourcing provides complete audit trails** and enables complex business analysis
3. **CQRS separates read and write concerns** for better scalability and performance
4. **Data consistency is eventual** in distributed systems - design accordingly

### **What's Next**

**Part E** will cover:

- Distributed tracing and monitoring
- Health checks and metrics collection
- Observability patterns for microservices
- Logging and alerting strategies

---

## 🔗 Series Navigation

- **Previous**: [05C_Microservices-Resilience-Patterns.md](05C_Microservices-Resilience-Patterns.md)
- **Current**: Part D - Data Management Patterns ✅
- **Next**: [05E_Microservices-Monitoring-Observability.md](05E_Microservices-Monitoring-Observability.md)
- **Series**: Microservices Architecture Fundamentals (Part D of 5)

**Last Updated**: September 15, 2025
**Format**: 27-minute focused learning segment
