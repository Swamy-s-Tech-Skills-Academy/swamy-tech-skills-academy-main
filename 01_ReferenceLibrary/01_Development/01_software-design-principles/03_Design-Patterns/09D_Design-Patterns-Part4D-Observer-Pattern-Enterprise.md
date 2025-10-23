# 09D_Design-Patterns-Part4D-Observer-Pattern-Enterprise

**Learning Level**: Advanced  
**Prerequisites**: Observer Pattern Parts A, B & C, Enterprise architecture concepts  
**Estimated Time**: Part D of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement Observer Pattern for enterprise messaging and event sourcing
- Design scalable publish-subscribe systems with error recovery
- Apply observer patterns for distributed system notifications
- Master advanced subscription patterns and resource management strategies

## 📋 Content Sections (27-Minute Structure)

### Enterprise Messaging Architecture (5 minutes)

**Advanced Observer Applications**:

- **Event Sourcing** - Audit trails and system state reconstruction
- **Message Bus Architecture** - Decoupled enterprise communication
- **Distributed Notifications** - Cross-service observer patterns
- **Error Recovery Systems** - Resilient observer implementations

```text
🏢 ENTERPRISE OBSERVER ARCHITECTURE
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Event Store   │    │   Message Bus   │    │ Notification    │
│   (Aggregate)   │    │  (Mediator)     │    │   Gateway       │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + Events[]      │───►│ + Subscribe()   │───►│ + Send()        │
│ + Append()      │    │ + Publish()     │    │ + SendEmail()   │
│ + GetEvents()   │    │ + Route()       │    │ + SendSMS()     │
└─────────────────┘    └─────────────────┘    │ + SendPush()    │
         │                       │             └─────────────────┘
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│ Business Logic  │    │ Multiple        │
│   Observers     │    │ Subscribers     │
├─────────────────┤    ├─────────────────┤
│ + OrderProcess  │    │ + AuditLogger   │
│ + InventoryMgmt │    │ + ReportingServ │
│ + CustomerServ  │    │ + Analytics     │
└─────────────────┘    └─────────────────┘
```

### Event Sourcing Observer System (10 minutes)

#### Enterprise Event Store Implementation

```csharp
// Base domain event interface
public interface IDomainEvent
{
    Guid EventId { get; }
    DateTime OccurredAt { get; }
    string EventType { get; }
    int Version { get; }
}

// Base domain event implementation
public abstract class DomainEvent : IDomainEvent
{
    public Guid EventId { get; }
    public DateTime OccurredAt { get; }
    public string EventType { get; }
    public int Version { get; }

    protected DomainEvent(int version = 1)
    {
        EventId = Guid.NewGuid();
        OccurredAt = DateTime.UtcNow;
        EventType = GetType().Name;
        Version = version;
    }
}

// Specific domain events
public class OrderCreatedEvent : DomainEvent
{
    public Guid OrderId { get; }
    public string CustomerId { get; }
    public decimal TotalAmount { get; }
    public List<OrderItem> Items { get; }

    public OrderCreatedEvent(Guid orderId, string customerId, decimal totalAmount, List<OrderItem> items)
    {
        OrderId = orderId;
        CustomerId = customerId ?? throw new ArgumentNullException(nameof(customerId));
        TotalAmount = totalAmount;
        Items = items ?? throw new ArgumentNullException(nameof(items));
    }
}

public class OrderShippedEvent : DomainEvent
{
    public Guid OrderId { get; }
    public string TrackingNumber { get; }
    public string ShippingCarrier { get; }
    public DateTime ShippedAt { get; }

    public OrderShippedEvent(Guid orderId, string trackingNumber, string shippingCarrier)
    {
        OrderId = orderId;
        TrackingNumber = trackingNumber ?? throw new ArgumentNullException(nameof(trackingNumber));
        ShippingCarrier = shippingCarrier ?? throw new ArgumentNullException(nameof(shippingCarrier));
        ShippedAt = DateTime.UtcNow;
    }
}

public class OrderItem
{
    public string ProductId { get; set; }
    public string ProductName { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}

// Event store for enterprise event sourcing
public class EventStore
{
    private readonly List<IDomainEvent> _events;
    private readonly Dictionary<string, List<IEventHandler>> _handlers;
    private readonly object _lock = new object();

    public EventStore()
    {
        _events = new List<IDomainEvent>();
        _handlers = new Dictionary<string, List<IEventHandler>>();
    }

    public void Subscribe<T>(IEventHandler<T> handler) where T : IDomainEvent
    {
        if (handler == null) throw new ArgumentNullException(nameof(handler));

        var eventType = typeof(T).Name;

        lock (_lock)
        {
            if (!_handlers.ContainsKey(eventType))
            {
                _handlers[eventType] = new List<IEventHandler>();
            }

            _handlers[eventType].Add(handler);
        }

        Console.WriteLine($"[EventStore] Subscribed {handler.GetType().Name} to {eventType}");
    }

    public void Unsubscribe<T>(IEventHandler<T> handler) where T : IDomainEvent
    {
        if (handler == null) return;

        var eventType = typeof(T).Name;

        lock (_lock)
        {
            if (_handlers.TryGetValue(eventType, out var handlerList))
            {
                handlerList.Remove(handler);
                if (handlerList.Count == 0)
                {
                    _handlers.Remove(eventType);
                }
            }
        }

        Console.WriteLine($"[EventStore] Unsubscribed {handler.GetType().Name} from {eventType}");
    }

    public async Task AppendEventAsync(IDomainEvent domainEvent)
    {
        if (domainEvent == null) throw new ArgumentNullException(nameof(domainEvent));

        // Append to event store
        lock (_lock)
        {
            _events.Add(domainEvent);
        }

        Console.WriteLine($"[EventStore] Event appended: {domainEvent.EventType} (ID: {domainEvent.EventId})");

        // Notify all handlers asynchronously
        await NotifyHandlersAsync(domainEvent);
    }

    public IEnumerable<IDomainEvent> GetEvents(DateTime? fromDate = null, string eventType = null)
    {
        lock (_lock)
        {
            var query = _events.AsEnumerable();

            if (fromDate.HasValue)
            {
                query = query.Where(e => e.OccurredAt >= fromDate.Value);
            }

            if (!string.IsNullOrEmpty(eventType))
            {
                query = query.Where(e => e.EventType == eventType);
            }

            return query.OrderBy(e => e.OccurredAt).ToList();
        }
    }

    public IEnumerable<T> GetEvents<T>() where T : IDomainEvent
    {
        var eventType = typeof(T).Name;
        return GetEvents(eventType: eventType).OfType<T>();
    }

    private async Task NotifyHandlersAsync(IDomainEvent domainEvent)
    {
        List<IEventHandler> handlersToNotify;

        lock (_lock)
        {
            if (!_handlers.TryGetValue(domainEvent.EventType, out handlersToNotify))
            {
                return; // No handlers for this event type
            }

            // Create copy to avoid lock during notification
            handlersToNotify = new List<IEventHandler>(handlersToNotify);
        }

        // Notify handlers concurrently
        var notificationTasks = handlersToNotify.Select(async handler =>
        {
            try
            {
                await handler.HandleAsync(domainEvent);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[EventStore] Handler error: {handler.GetType().Name} - {ex.Message}");
                // Could implement retry logic or dead letter queue here
            }
        });

        await Task.WhenAll(notificationTasks);
    }

    public int EventCount => _events.Count;
    public int HandlerCount => _handlers.Values.Sum(list => list.Count);
}

// Event handler interfaces
public interface IEventHandler
{
    Task HandleAsync(IDomainEvent domainEvent);
}

public interface IEventHandler<T> : IEventHandler where T : IDomainEvent
{
    Task HandleAsync(T domainEvent);
}

// Base event handler implementation
public abstract class EventHandler<T> : IEventHandler<T> where T : IDomainEvent
{
    public async Task HandleAsync(IDomainEvent domainEvent)
    {
        if (domainEvent is T typedEvent)
        {
            await HandleTypedEventAsync(typedEvent);
        }
    }

    protected abstract Task HandleTypedEventAsync(T domainEvent);
}
```

### Enterprise Event Handlers (8 minutes)

#### Business Logic Event Handlers

```csharp
// Order processing handler
public class OrderProcessingHandler : EventHandler<OrderCreatedEvent>
{
    private readonly string _serviceName;

    public OrderProcessingHandler(string serviceName = "Order Processing Service")
    {
        _serviceName = serviceName;
    }

    protected override async Task HandleTypedEventAsync(OrderCreatedEvent orderEvent)
    {
        Console.WriteLine($"[{_serviceName}] 📦 Processing new order {orderEvent.OrderId}");

        // Simulate order processing workflow
        await ValidateOrderAsync(orderEvent);
        await ReserveInventoryAsync(orderEvent);
        await ProcessPaymentAsync(orderEvent);
        await InitiateShippingAsync(orderEvent);

        Console.WriteLine($"[{_serviceName}] ✅ Order {orderEvent.OrderId} processing complete");
    }

    private async Task ValidateOrderAsync(OrderCreatedEvent orderEvent)
    {
        // Simulate validation
        await Task.Delay(100);
        Console.WriteLine($"[{_serviceName}]   ✓ Order validation complete");
    }

    private async Task ReserveInventoryAsync(OrderCreatedEvent orderEvent)
    {
        // Simulate inventory reservation
        await Task.Delay(150);
        
        foreach (var item in orderEvent.Items)
        {
            Console.WriteLine($"[{_serviceName}]   ✓ Reserved {item.Quantity}x {item.ProductName}");
        }
    }

    private async Task ProcessPaymentAsync(OrderCreatedEvent orderEvent)
    {
        // Simulate payment processing
        await Task.Delay(200);
        Console.WriteLine($"[{_serviceName}]   ✓ Payment processed: ${orderEvent.TotalAmount:F2}");
    }

    private async Task InitiateShippingAsync(OrderCreatedEvent orderEvent)
    {
        // Simulate shipping initiation
        await Task.Delay(100);
        Console.WriteLine($"[{_serviceName}]   ✓ Shipping initiated");
    }
}

// Audit logging handler
public class AuditLoggingHandler : EventHandler<IDomainEvent>
{
    private readonly List<AuditLogEntry> _auditLog;
    private readonly object _logLock = new object();

    public AuditLoggingHandler()
    {
        _auditLog = new List<AuditLogEntry>();
    }

    protected override async Task HandleTypedEventAsync(IDomainEvent domainEvent)
    {
        var auditEntry = new AuditLogEntry
        {
            EventId = domainEvent.EventId,
            EventType = domainEvent.EventType,
            OccurredAt = domainEvent.OccurredAt,
            Version = domainEvent.Version,
            Data = SerializeEvent(domainEvent)
        };

        lock (_logLock)
        {
            _auditLog.Add(auditEntry);
        }

        // Simulate writing to persistent audit log
        await Task.Delay(50);
        
        Console.WriteLine($"[Audit] 📝 Event logged: {domainEvent.EventType} at {domainEvent.OccurredAt:HH:mm:ss}");
    }

    public IEnumerable<AuditLogEntry> GetAuditLog(DateTime? fromDate = null)
    {
        lock (_logLock)
        {
            var query = _auditLog.AsEnumerable();
            
            if (fromDate.HasValue)
            {
                query = query.Where(entry => entry.OccurredAt >= fromDate.Value);
            }

            return query.OrderBy(entry => entry.OccurredAt).ToList();
        }
    }

    private string SerializeEvent(IDomainEvent domainEvent)
    {
        // Simplified serialization for demo
        return $"{domainEvent.EventType}:{domainEvent.EventId}";
    }

    public int AuditLogCount => _auditLog.Count;

    private class AuditLogEntry
    {
        public Guid EventId { get; set; }
        public string EventType { get; set; }
        public DateTime OccurredAt { get; set; }
        public int Version { get; set; }
        public string Data { get; set; }
    }
}

// Customer notification handler
public class CustomerNotificationHandler : EventHandler<OrderCreatedEvent>, IEventHandler<OrderShippedEvent>
{
    private readonly NotificationGateway _notificationGateway;

    public CustomerNotificationHandler()
    {
        _notificationGateway = new NotificationGateway();
    }

    protected override async Task HandleTypedEventAsync(OrderCreatedEvent orderEvent)
    {
        var message = $"Order confirmation: Your order #{orderEvent.OrderId} " +
                     $"for ${orderEvent.TotalAmount:F2} has been received and is being processed.";

        await _notificationGateway.SendNotificationAsync(orderEvent.CustomerId, "Order Confirmation", message);
    }

    public async Task HandleAsync(OrderShippedEvent shippedEvent)
    {
        var message = $"Order shipped: Your order #{shippedEvent.OrderId} " +
                     $"has been shipped via {shippedEvent.ShippingCarrier}. " +
                     $"Tracking number: {shippedEvent.TrackingNumber}";

        await _notificationGateway.SendNotificationAsync("customer", "Order Shipped", message);
    }

    private class NotificationGateway
    {
        public async Task SendNotificationAsync(string customerId, string subject, string message)
        {
            // Simulate sending notification
            await Task.Delay(100);
            Console.WriteLine($"[Notification] 📧 Sent to {customerId}: {subject}");
            Console.WriteLine($"[Notification]    {message}");
        }
    }
}

// Analytics and reporting handler
public class AnalyticsHandler : EventHandler<OrderCreatedEvent>
{
    private readonly Dictionary<string, decimal> _customerTotals;
    private readonly List<OrderMetrics> _orderMetrics;
    private readonly object _analyticsLock = new object();

    public AnalyticsHandler()
    {
        _customerTotals = new Dictionary<string, decimal>();
        _orderMetrics = new List<OrderMetrics>();
    }

    protected override async Task HandleTypedEventAsync(OrderCreatedEvent orderEvent)
    {
        lock (_analyticsLock)
        {
            // Update customer totals
            if (_customerTotals.ContainsKey(orderEvent.CustomerId))
            {
                _customerTotals[orderEvent.CustomerId] += orderEvent.TotalAmount;
            }
            else
            {
                _customerTotals[orderEvent.CustomerId] = orderEvent.TotalAmount;
            }

            // Track order metrics
            _orderMetrics.Add(new OrderMetrics
            {
                OrderId = orderEvent.OrderId,
                CustomerId = orderEvent.CustomerId,
                TotalAmount = orderEvent.TotalAmount,
                ItemCount = orderEvent.Items.Count,
                CreatedAt = orderEvent.OccurredAt
            });
        }

        // Simulate analytics processing
        await Task.Delay(75);

        Console.WriteLine($"[Analytics] 📊 Order tracked: {orderEvent.OrderId} " +
                         $"(Customer: {orderEvent.CustomerId}, Amount: ${orderEvent.TotalAmount:F2})");

        // Generate insights
        GenerateInsights(orderEvent);
    }

    private void GenerateInsights(OrderCreatedEvent orderEvent)
    {
        lock (_analyticsLock)
        {
            var customerTotal = _customerTotals[orderEvent.CustomerId];
            var orderCount = _orderMetrics.Count(m => m.CustomerId == orderEvent.CustomerId);

            if (customerTotal > 1000m)
            {
                Console.WriteLine($"[Analytics] 🌟 VIP Customer Alert: {orderEvent.CustomerId} " +
                                $"(Total: ${customerTotal:F2}, Orders: {orderCount})");
            }

            if (orderEvent.TotalAmount > 500m)
            {
                Console.WriteLine($"[Analytics] 💰 High-Value Order: ${orderEvent.TotalAmount:F2}");
            }
        }
    }

    public void PrintAnalyticsSummary()
    {
        lock (_analyticsLock)
        {
            Console.WriteLine("\n[Analytics] 📈 Summary Report:");
            Console.WriteLine($"  Total Orders: {_orderMetrics.Count}");
            Console.WriteLine($"  Total Revenue: ${_orderMetrics.Sum(m => m.TotalAmount):F2}");
            Console.WriteLine($"  Average Order: ${(_orderMetrics.Count > 0 ? _orderMetrics.Average(m => m.TotalAmount) : 0):F2}");
            Console.WriteLine($"  Unique Customers: {_customerTotals.Count}");

            if (_customerTotals.Any())
            {
                var topCustomer = _customerTotals.OrderByDescending(kv => kv.Value).First();
                Console.WriteLine($"  Top Customer: {topCustomer.Key} (${topCustomer.Value:F2})");
            }
        }
    }

    private class OrderMetrics
    {
        public Guid OrderId { get; set; }
        public string CustomerId { get; set; }
        public decimal TotalAmount { get; set; }
        public int ItemCount { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
```

### Enterprise Demo Implementation (2 minutes)

```csharp
// Enterprise observer pattern demonstration
public class EnterpriseObserverDemo
{
    public static async Task RunDemo()
    {
        Console.WriteLine("=== Enterprise Observer Pattern Demo ===\n");

        // Create event store
        var eventStore = new EventStore();

        // Create enterprise event handlers
        var orderProcessor = new OrderProcessingHandler();
        var auditLogger = new AuditLoggingHandler();
        var customerNotifier = new CustomerNotificationHandler();
        var analytics = new AnalyticsHandler();

        // Subscribe handlers to events
        Console.WriteLine("--- Setting up enterprise event handlers ---");
        eventStore.Subscribe<OrderCreatedEvent>(orderProcessor);
        eventStore.Subscribe<IDomainEvent>(auditLogger);
        eventStore.Subscribe<OrderCreatedEvent>(customerNotifier);
        eventStore.Subscribe<OrderShippedEvent>(customerNotifier);
        eventStore.Subscribe<OrderCreatedEvent>(analytics);

        Console.WriteLine($"Event Store: {eventStore.EventCount} events, {eventStore.HandlerCount} handlers\n");

        // Simulate business events
        Console.WriteLine("--- Simulating business events ---");

        var order1 = new OrderCreatedEvent(
            Guid.NewGuid(),
            "customer-001",
            750.00m,
            new List<OrderItem>
            {
                new() { ProductId = "P001", ProductName = "Laptop", Quantity = 1, UnitPrice = 699.99m },
                new() { ProductId = "P002", ProductName = "Mouse", Quantity = 1, UnitPrice = 49.99m }
            });

        await eventStore.AppendEventAsync(order1);

        // Small delay to see processing
        await Task.Delay(500);

        var order2 = new OrderCreatedEvent(
            Guid.NewGuid(),
            "customer-002",
            150.00m,
            new List<OrderItem>
            {
                new() { ProductId = "P003", ProductName = "Book", Quantity = 3, UnitPrice = 49.99m }
            });

        await eventStore.AppendEventAsync(order2);

        // Simulate shipping event
        var shippedEvent = new OrderShippedEvent(order1.OrderId, "TRK123456789", "FedEx");
        await eventStore.AppendEventAsync(shippedEvent);

        // Final delay and summary
        await Task.Delay(300);

        Console.WriteLine("\n--- Analytics Summary ---");
        analytics.PrintAnalyticsSummary();

        Console.WriteLine($"\n--- Audit Summary ---");
        Console.WriteLine($"Total audit entries: {auditLogger.AuditLogCount}");

        Console.WriteLine($"\n--- Event Store Summary ---");
        Console.WriteLine($"Total events stored: {eventStore.EventCount}");
        Console.WriteLine($"Order events: {eventStore.GetEvents<OrderCreatedEvent>().Count()}");
        Console.WriteLine($"Shipping events: {eventStore.GetEvents<OrderShippedEvent>().Count()}");
    }
}
```

### Key Takeaways & Enterprise Benefits (2 minutes)

**Enterprise Observer Pattern Benefits**:

- **Event Sourcing** - Complete audit trail and system state reconstruction
- **Scalable Architecture** - Decoupled services with independent processing
- **Asynchronous Processing** - Non-blocking business workflows
- **Error Isolation** - Handler failures don't affect other subscribers

**Advanced Implementation Patterns**:

- **Message Bus Architecture** - Centralized event routing and distribution
- **Saga Pattern** - Distributed transaction coordination
- **CQRS** - Command Query Responsibility Segregation
- **Event Streaming** - Real-time data processing pipelines

**Production Considerations**:

- **Dead Letter Queues** - Handle failed message processing
- **Idempotent Handlers** - Ensure safe retry operations
- **Event Versioning** - Handle schema evolution gracefully
- **Monitoring & Alerting** - Track event processing health

**Next Learning Path**:

- **[Strategy Pattern](10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals.md)** - Algorithm selection and polymorphism
- **[Command Pattern](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md)** - Encapsulating requests as objects

## 🔗 Related Topics

**Prerequisites**:

- **[Parts A-C](09A_Design-Patterns-Part4A-Observer-Pattern-Fundamentals.md)** - Complete Observer Pattern foundation
- Enterprise architecture patterns
- Asynchronous programming concepts

**Builds Upon**:

- Event-driven architecture
- Domain-driven design
- Microservices patterns

**Enables**:

- [Event Sourcing](../../architectural-patterns/event-sourcing/) - Complete system audit trails
- [CQRS](../../architectural-patterns/cqrs/) - Separated read/write models
- [Saga Pattern](../../integration-patterns/saga/) - Distributed transactions
- [Message Bus](../../integration-patterns/message-bus/) - Enterprise messaging

**Next Patterns**:

- [Strategy Pattern](10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals.md) - Flexible algorithm selection
- [Command Pattern](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md) - Request encapsulation
