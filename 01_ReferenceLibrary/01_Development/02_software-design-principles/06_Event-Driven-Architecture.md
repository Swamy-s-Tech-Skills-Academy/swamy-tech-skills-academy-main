# 06_Event-Driven-Architecture

**Learning Level**: Advanced  
**Prerequisites**: Clean Architecture, DDD fundamentals, System Design, Microservices Architecture  
**Estimated Time**: 3-4 hours  

## 🎯 Learning Objectives

By the end of this module, you will understand:

- Event-driven design principles and architectural patterns
- Event sourcing implementation strategies and trade-offs
- CQRS (Command Query Responsibility Segregation) patterns
- Message routing patterns: choreography vs orchestration
- Domain events vs integration events design
- Practical C# implementation with real-world scenarios

## 📋 Module Contents

### 1. Event-Driven Architecture Foundations

Event-Driven Architecture (EDA) is a software architecture pattern where the flow of the program is determined by events such as user actions, sensor outputs, or messages from other programs or services.

#### Core Principles

```text
┌─────────────────────────────────────────────────────────────┐
│                    Event-Driven Architecture                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Producer] ──event──> [Event Bus] ──event──> [Consumer]    │
│      │                     │                      │        │
│      │                     │                      │        │
│   Domain                Message               Event         │
│   Events                Routing               Handlers      │
│                                                             │
│  Characteristics:                                          │
│  • Loose Coupling                                         │
│  • Async Communication                                    │
│  • Scalable Processing                                    │
│  • Temporal Decoupling                                    │
└─────────────────────────────────────────────────────────────┘
```

#### Key Benefits

- **Loose Coupling**: Components don't need direct knowledge of each other
- **Scalability**: Independent scaling of producers and consumers
- **Resilience**: Failures in one component don't cascade
- **Flexibility**: Easy to add new consumers without changing producers

#### Common Challenges

- **Complexity**: Harder to understand system flow
- **Debugging**: Distributed tracing becomes essential
- **Eventual Consistency**: Data consistency patterns required
- **Message Ordering**: Handling out-of-order events

### 2. Event Sourcing Pattern

Event Sourcing ensures that all changes to application state are stored as a sequence of events, making the event store the single source of truth.

#### Core Concepts

```text
┌─────────────────────────────────────────────────────────────┐
│                     Event Sourcing Flow                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Command] ──> [Aggregate] ──> [Event Store]               │
│                    │                │                       │
│                    │                │                       │
│               Business Logic    Event Stream                │
│                    │                │                       │
│                    ▼                ▼                       │
│              [Event Bus] ──> [Read Models/Projections]      │
│                                      │                      │
│                                 Query Side                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### C# Implementation Example

```csharp
// Base Event Interface
public interface IDomainEvent
{
    Guid Id { get; }
    DateTime Timestamp { get; }
    string EventType { get; }
}

// Domain Event Implementation
public record OrderCreatedEvent(
    Guid Id,
    DateTime Timestamp,
    Guid OrderId,
    string CustomerId,
    decimal TotalAmount,
    List<OrderLineItem> Items
) : IDomainEvent
{
    public string EventType => nameof(OrderCreatedEvent);
}

// Event Store Interface
public interface IEventStore
{
    Task AppendEventsAsync<T>(string streamId, IEnumerable<IDomainEvent> events, int expectedVersion);
    Task<IEnumerable<IDomainEvent>> GetEventsAsync(string streamId);
    Task<IEnumerable<IDomainEvent>> GetEventsAsync(string streamId, int fromVersion);
}

// Aggregate Root with Event Sourcing
public abstract class AggregateRoot
{
    private readonly List<IDomainEvent> _uncommittedEvents = new();
    
    public Guid Id { get; protected set; }
    public int Version { get; private set; } = -1;

    protected void AddEvent(IDomainEvent @event)
    {
        _uncommittedEvents.Add(@event);
    }

    public IEnumerable<IDomainEvent> GetUncommittedEvents()
    {
        return _uncommittedEvents.AsReadOnly();
    }

    public void MarkEventsAsCommitted()
    {
        _uncommittedEvents.Clear();
    }

    public void LoadFromHistory(IEnumerable<IDomainEvent> events)
    {
        foreach (var @event in events)
        {
            ApplyEvent(@event, false);
            Version++;
        }
    }

    protected abstract void ApplyEvent(IDomainEvent @event, bool isNew = true);
}

// Order Aggregate Example
public class Order : AggregateRoot
{
    public string CustomerId { get; private set; }
    public decimal TotalAmount { get; private set; }
    public OrderStatus Status { get; private set; }
    public List<OrderLineItem> Items { get; private set; } = new();

    // Factory method for new orders
    public static Order CreateNew(string customerId, List<OrderLineItem> items)
    {
        var order = new Order();
        var orderCreatedEvent = new OrderCreatedEvent(
            Guid.NewGuid(),
            DateTime.UtcNow,
            Guid.NewGuid(),
            customerId,
            items.Sum(i => i.Price * i.Quantity),
            items
        );
        
        order.ApplyEvent(orderCreatedEvent);
        return order;
    }

    // Business method that generates events
    public void Ship(string trackingNumber)
    {
        if (Status != OrderStatus.Confirmed)
            throw new InvalidOperationException("Can only ship confirmed orders");

        var shippedEvent = new OrderShippedEvent(
            Guid.NewGuid(),
            DateTime.UtcNow,
            Id,
            trackingNumber
        );
        
        ApplyEvent(shippedEvent);
    }

    protected override void ApplyEvent(IDomainEvent @event, bool isNew = true)
    {
        switch (@event)
        {
            case OrderCreatedEvent orderCreated:
                Id = orderCreated.OrderId;
                CustomerId = orderCreated.CustomerId;
                TotalAmount = orderCreated.TotalAmount;
                Items = orderCreated.Items;
                Status = OrderStatus.Created;
                break;
                
            case OrderShippedEvent orderShipped:
                Status = OrderStatus.Shipped;
                break;
                
            default:
                throw new InvalidOperationException($"Unknown event type: {@event.GetType().Name}");
        }

        if (isNew)
        {
            AddEvent(@event);
        }
    }
}
```

#### Event Store Implementation

```csharp
// In-Memory Event Store (for demonstration)
public class InMemoryEventStore : IEventStore
{
    private readonly Dictionary<string, List<IDomainEvent>> _streams = new();
    private readonly object _lock = new();

    public Task AppendEventsAsync<T>(string streamId, IEnumerable<IDomainEvent> events, int expectedVersion)
    {
        lock (_lock)
        {
            if (!_streams.ContainsKey(streamId))
            {
                _streams[streamId] = new List<IDomainEvent>();
            }

            var stream = _streams[streamId];
            
            // Optimistic concurrency check
            if (stream.Count != expectedVersion)
            {
                throw new ConcurrencyException($"Expected version {expectedVersion}, but was {stream.Count}");
            }

            stream.AddRange(events);
        }
        
        return Task.CompletedTask;
    }

    public Task<IEnumerable<IDomainEvent>> GetEventsAsync(string streamId)
    {
        lock (_lock)
        {
            return Task.FromResult(_streams.ContainsKey(streamId) 
                ? _streams[streamId].AsEnumerable() 
                : Enumerable.Empty<IDomainEvent>());
        }
    }

    public Task<IEnumerable<IDomainEvent>> GetEventsAsync(string streamId, int fromVersion)
    {
        lock (_lock)
        {
            return Task.FromResult(_streams.ContainsKey(streamId) 
                ? _streams[streamId].Skip(fromVersion).AsEnumerable() 
                : Enumerable.Empty<IDomainEvent>());
        }
    }
}
```

### 3. CQRS (Command Query Responsibility Segregation)

CQRS separates read and write operations into different models, allowing for optimized data structures and processing patterns for each concern.

#### CQRS Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                     CQRS Pattern                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Commands (Write Side)          Queries (Read Side)        │
│  ┌───────────────────┐          ┌─────────────────────┐     │
│  │                   │          │                     │     │
│  │ [Command Handler] │          │ [Query Handler]     │     │
│  │        │          │          │        │            │     │
│  │        ▼          │    ───────►        ▼            │     │
│  │ [Write Database]  │ Events   │ [Read Database]     │     │
│  │                   │          │  (Projections)      │     │
│  │                   │          │                     │     │
│  └───────────────────┘          └─────────────────────┘     │
│                                                             │
│  Benefits:                                                 │
│  • Optimized data models for reads vs writes              │
│  • Independent scaling                                    │
│  • Different consistency models                           │
└─────────────────────────────────────────────────────────────┘
```

#### Command Side Implementation

```csharp
// Command Interface
public interface ICommand
{
    Guid CommandId { get; }
}

// Command Handler Interface
public interface ICommandHandler<in TCommand> where TCommand : ICommand
{
    Task HandleAsync(TCommand command);
}

// Create Order Command
public record CreateOrderCommand(
    Guid CommandId,
    string CustomerId,
    List<OrderLineItem> Items
) : ICommand;

// Command Handler Implementation
public class CreateOrderCommandHandler : ICommandHandler<CreateOrderCommand>
{
    private readonly IEventStore _eventStore;
    private readonly IEventBus _eventBus;

    public CreateOrderCommandHandler(IEventStore eventStore, IEventBus eventBus)
    {
        _eventStore = eventStore;
        _eventBus = eventBus;
    }

    public async Task HandleAsync(CreateOrderCommand command)
    {
        // Create the aggregate
        var order = Order.CreateNew(command.CustomerId, command.Items);

        // Get uncommitted events
        var events = order.GetUncommittedEvents();

        // Persist events
        await _eventStore.AppendEventsAsync($"order-{order.Id}", events, -1);

        // Publish events
        foreach (var @event in events)
        {
            await _eventBus.PublishAsync(@event);
        }

        // Mark events as committed
        order.MarkEventsAsCommitted();
    }
}
```

#### Query Side Implementation

```csharp
// Query Interface
public interface IQuery<out TResult>
{
}

// Query Handler Interface
public interface IQueryHandler<in TQuery, TResult> where TQuery : IQuery<TResult>
{
    Task<TResult> HandleAsync(TQuery query);
}

// Read Model
public class OrderReadModel
{
    public Guid OrderId { get; set; }
    public string CustomerId { get; set; }
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ShippedAt { get; set; }
    public List<OrderLineItemReadModel> Items { get; set; } = new();
}

// Query Implementation
public record GetOrderByIdQuery(Guid OrderId) : IQuery<OrderReadModel>;

// Query Handler Implementation
public class GetOrderByIdQueryHandler : IQueryHandler<GetOrderByIdQuery, OrderReadModel>
{
    private readonly IOrderReadModelRepository _repository;

    public GetOrderByIdQueryHandler(IOrderReadModelRepository repository)
    {
        _repository = repository;
    }

    public async Task<OrderReadModel> HandleAsync(GetOrderByIdQuery query)
    {
        return await _repository.GetByIdAsync(query.OrderId);
    }
}

// Projection Handler (Updates Read Models from Events)
public class OrderProjectionHandler :
    IEventHandler<OrderCreatedEvent>,
    IEventHandler<OrderShippedEvent>
{
    private readonly IOrderReadModelRepository _repository;

    public OrderProjectionHandler(IOrderReadModelRepository repository)
    {
        _repository = repository;
    }

    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        var readModel = new OrderReadModel
        {
            OrderId = @event.OrderId,
            CustomerId = @event.CustomerId,
            TotalAmount = @event.TotalAmount,
            Status = OrderStatus.Created,
            CreatedAt = @event.Timestamp,
            Items = @event.Items.Select(i => new OrderLineItemReadModel 
            { 
                ProductId = i.ProductId, 
                Quantity = i.Quantity, 
                Price = i.Price 
            }).ToList()
        };

        await _repository.UpsertAsync(readModel);
    }

    public async Task HandleAsync(OrderShippedEvent @event)
    {
        var readModel = await _repository.GetByIdAsync(@event.OrderId);
        if (readModel != null)
        {
            readModel.Status = OrderStatus.Shipped;
            readModel.ShippedAt = @event.Timestamp;
            await _repository.UpsertAsync(readModel);
        }
    }
}
```

### 4. Message Routing Patterns

#### Choreography vs Orchestration

```text
┌─────────────────────────────────────────────────────────────┐
│                   Choreography Pattern                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Order Service] ──OrderCreated──> [Payment Service]       │
│                                           │                 │
│                                   PaymentCompleted         │
│                                           │                 │
│                                           ▼                 │
│  [Inventory Service] <──────────────────────                │
│           │                                                 │
│    InventoryReserved                                        │
│           │                                                 │
│           ▼                                                 │
│  [Shipping Service]                                         │
│                                                             │
│  Characteristics:                                          │
│  • Decentralized control                                  │
│  • Services react to events                               │
│  • No central coordinator                                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   Orchestration Pattern                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                [Order Orchestrator]                         │
│                        │                                    │
│           ┌────────────┼────────────┐                       │
│           │            │            │                       │
│           ▼            ▼            ▼                       │
│  [Payment Service] [Inventory] [Shipping Service]          │
│                                                             │
│  Characteristics:                                          │
│  • Centralized control                                    │
│  • Explicit workflow definition                           │
│  • Easier to understand and debug                         │
└─────────────────────────────────────────────────────────────┘
```

#### Choreography Implementation

```csharp
// Event Handlers for Choreography
public class OrderCreatedEventHandler : IEventHandler<OrderCreatedEvent>
{
    private readonly IPaymentService _paymentService;

    public OrderCreatedEventHandler(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    public async Task HandleAsync(OrderCreatedEvent @event)
    {
        // Payment service reacts to order creation
        await _paymentService.ProcessPaymentAsync(new PaymentRequest
        {
            OrderId = @event.OrderId,
            Amount = @event.TotalAmount,
            CustomerId = @event.CustomerId
        });
    }
}

public class PaymentCompletedEventHandler : IEventHandler<PaymentCompletedEvent>
{
    private readonly IInventoryService _inventoryService;

    public PaymentCompletedEventHandler(IInventoryService inventoryService)
    {
        _inventoryService = inventoryService;
    }

    public async Task HandleAsync(PaymentCompletedEvent @event)
    {
        // Inventory service reacts to payment completion
        await _inventoryService.ReserveInventoryAsync(@event.OrderId);
    }
}
```

#### Orchestration Implementation

```csharp
// Saga Pattern for Orchestration
public class OrderProcessingSaga : ISaga
{
    public Guid SagaId { get; set; }
    public OrderProcessingState State { get; set; }
    public Guid OrderId { get; set; }
    public string CustomerId { get; set; }
    public decimal Amount { get; set; }

    public async Task HandleAsync(OrderCreatedEvent @event, ISagaContext context)
    {
        OrderId = @event.OrderId;
        CustomerId = @event.CustomerId;
        Amount = @event.TotalAmount;
        State = OrderProcessingState.PaymentPending;

        // Orchestrator explicitly commands payment
        await context.SendAsync(new ProcessPaymentCommand
        {
            OrderId = @event.OrderId,
            Amount = @event.TotalAmount,
            CustomerId = @event.CustomerId
        });
    }

    public async Task HandleAsync(PaymentCompletedEvent @event, ISagaContext context)
    {
        State = OrderProcessingState.InventoryPending;

        // Orchestrator explicitly commands inventory reservation
        await context.SendAsync(new ReserveInventoryCommand
        {
            OrderId = @event.OrderId
        });
    }

    public async Task HandleAsync(InventoryReservedEvent @event, ISagaContext context)
    {
        State = OrderProcessingState.ShippingPending;

        // Orchestrator explicitly commands shipping
        await context.SendAsync(new CreateShipmentCommand
        {
            OrderId = @event.OrderId
        });
    }

    public async Task HandleAsync(PaymentFailedEvent @event, ISagaContext context)
    {
        State = OrderProcessingState.Failed;

        // Orchestrator handles compensation
        await context.SendAsync(new CancelOrderCommand
        {
            OrderId = @event.OrderId,
            Reason = "Payment failed"
        });
    }
}
```

### 5. Domain Events vs Integration Events

#### Domain Events

Domain events represent something significant that happened within a bounded context.

```csharp
// Domain Event - Internal to bounded context
public record CustomerEmailChangedEvent(
    Guid Id,
    DateTime Timestamp,
    Guid CustomerId,
    string OldEmail,
    string NewEmail
) : IDomainEvent
{
    public string EventType => nameof(CustomerEmailChangedEvent);
}

// Domain Event Handler - Same bounded context
public class CustomerEmailChangedHandler : IEventHandler<CustomerEmailChangedEvent>
{
    private readonly IEmailVerificationService _emailService;

    public CustomerEmailChangedHandler(IEmailVerificationService emailService)
    {
        _emailService = emailService;
    }

    public async Task HandleAsync(CustomerEmailChangedEvent @event)
    {
        // Internal domain logic
        await _emailService.SendVerificationEmailAsync(@event.NewEmail);
    }
}
```

#### Integration Events

Integration events facilitate communication between bounded contexts or services.

```csharp
// Integration Event - Cross-context communication
public record CustomerRegisteredIntegrationEvent(
    Guid Id,
    DateTime Timestamp,
    Guid CustomerId,
    string Email,
    string FirstName,
    string LastName
) : IIntegrationEvent
{
    public string EventType => nameof(CustomerRegisteredIntegrationEvent);
}

// Integration Event Publisher
public class CustomerDomainService
{
    private readonly IIntegrationEventBus _integrationEventBus;

    public CustomerDomainService(IIntegrationEventBus integrationEventBus)
    {
        _integrationEventBus = integrationEventBus;
    }

    public async Task RegisterCustomerAsync(RegisterCustomerCommand command)
    {
        // Domain logic for customer registration
        var customer = new Customer(command.Email, command.FirstName, command.LastName);
        
        // Publish integration event for other contexts
        var integrationEvent = new CustomerRegisteredIntegrationEvent(
            Guid.NewGuid(),
            DateTime.UtcNow,
            customer.Id,
            customer.Email,
            customer.FirstName,
            customer.LastName
        );

        await _integrationEventBus.PublishAsync(integrationEvent);
    }
}

// Integration Event Handler in different bounded context
public class MarketingContextEventHandler : IIntegrationEventHandler<CustomerRegisteredIntegrationEvent>
{
    private readonly IMarketingRepository _repository;

    public MarketingContextEventHandler(IMarketingRepository repository)
    {
        _repository = repository;
    }

    public async Task HandleAsync(CustomerRegisteredIntegrationEvent @event)
    {
        // Marketing context logic
        var marketingProfile = new MarketingProfile
        {
            CustomerId = @event.CustomerId,
            Email = @event.Email,
            FirstName = @event.FirstName,
            LastName = @event.LastName,
            SubscriptionStatus = SubscriptionStatus.OptedIn
        };

        await _repository.CreateProfileAsync(marketingProfile);
    }
}
```

### 6. Event Bus Implementation

#### Simple Event Bus

```csharp
public interface IEventBus
{
    Task PublishAsync<T>(T @event) where T : IDomainEvent;
    void Subscribe<T>(IEventHandler<T> handler) where T : IDomainEvent;
}

public class InMemoryEventBus : IEventBus
{
    private readonly Dictionary<Type, List<object>> _handlers = new();
    private readonly ILogger<InMemoryEventBus> _logger;

    public InMemoryEventBus(ILogger<InMemoryEventBus> logger)
    {
        _logger = logger;
    }

    public async Task PublishAsync<T>(T @event) where T : IDomainEvent
    {
        var eventType = typeof(T);
        
        if (!_handlers.ContainsKey(eventType))
        {
            _logger.LogWarning("No handlers registered for event type {EventType}", eventType.Name);
            return;
        }

        var handlers = _handlers[eventType].Cast<IEventHandler<T>>();
        
        var tasks = handlers.Select(handler => HandleEventSafely(handler, @event));
        await Task.WhenAll(tasks);
    }

    public void Subscribe<T>(IEventHandler<T> handler) where T : IDomainEvent
    {
        var eventType = typeof(T);
        
        if (!_handlers.ContainsKey(eventType))
        {
            _handlers[eventType] = new List<object>();
        }
        
        _handlers[eventType].Add(handler);
    }

    private async Task HandleEventSafely<T>(IEventHandler<T> handler, T @event) where T : IDomainEvent
    {
        try
        {
            await handler.HandleAsync(@event);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error handling event {EventType} with handler {HandlerType}", 
                typeof(T).Name, handler.GetType().Name);
        }
    }
}
```

#### Message Queue Event Bus (Azure Service Bus Example)

```csharp
public class ServiceBusEventBus : IEventBus
{
    private readonly ServiceBusClient _client;
    private readonly ServiceBusSender _sender;
    private readonly ILogger<ServiceBusEventBus> _logger;

    public ServiceBusEventBus(ServiceBusClient client, string topicName, ILogger<ServiceBusEventBus> logger)
    {
        _client = client;
        _sender = client.CreateSender(topicName);
        _logger = logger;
    }

    public async Task PublishAsync<T>(T @event) where T : IDomainEvent
    {
        try
        {
            var message = new ServiceBusMessage(JsonSerializer.Serialize(@event))
            {
                Subject = typeof(T).Name,
                MessageId = @event.Id.ToString(),
                ContentType = "application/json"
            };

            await _sender.SendMessageAsync(message);
            _logger.LogInformation("Published event {EventType} with ID {EventId}", typeof(T).Name, @event.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to publish event {EventType} with ID {EventId}", typeof(T).Name, @event.Id);
            throw;
        }
    }

    public void Subscribe<T>(IEventHandler<T> handler) where T : IDomainEvent
    {
        // Subscription logic would typically be handled by the message infrastructure
        // This is a simplified example
        throw new NotImplementedException("Use message processor for subscriptions");
    }
}
```

### 7. Resilience Patterns

#### Retry Pattern for Event Processing

```csharp
public class RetryEventHandler<T> : IEventHandler<T> where T : IDomainEvent
{
    private readonly IEventHandler<T> _innerHandler;
    private readonly ILogger<RetryEventHandler<T>> _logger;
    private readonly int _maxRetries;
    private readonly TimeSpan _baseDelay;

    public RetryEventHandler(IEventHandler<T> innerHandler, ILogger<RetryEventHandler<T>> logger, 
        int maxRetries = 3, TimeSpan? baseDelay = null)
    {
        _innerHandler = innerHandler;
        _logger = logger;
        _maxRetries = maxRetries;
        _baseDelay = baseDelay ?? TimeSpan.FromSeconds(1);
    }

    public async Task HandleAsync(T @event)
    {
        var attempt = 0;
        
        while (attempt <= _maxRetries)
        {
            try
            {
                await _innerHandler.HandleAsync(@event);
                return;
            }
            catch (Exception ex)
            {
                attempt++;
                
                if (attempt > _maxRetries)
                {
                    _logger.LogError(ex, "Failed to handle event {EventType} after {Attempts} attempts", 
                        typeof(T).Name, attempt);
                    throw;
                }

                var delay = TimeSpan.FromMilliseconds(_baseDelay.TotalMilliseconds * Math.Pow(2, attempt - 1));
                _logger.LogWarning(ex, "Attempt {Attempt} failed for event {EventType}, retrying in {Delay}ms", 
                    attempt, typeof(T).Name, delay.TotalMilliseconds);
                
                await Task.Delay(delay);
            }
        }
    }
}
```

#### Circuit Breaker Pattern

```csharp
public class CircuitBreakerEventHandler<T> : IEventHandler<T> where T : IDomainEvent
{
    private readonly IEventHandler<T> _innerHandler;
    private readonly ILogger<CircuitBreakerEventHandler<T>> _logger;
    private readonly int _failureThreshold;
    private readonly TimeSpan _timeout;
    
    private int _failureCount = 0;
    private DateTime _lastFailureTime = DateTime.MinValue;
    private CircuitBreakerState _state = CircuitBreakerState.Closed;

    public CircuitBreakerEventHandler(IEventHandler<T> innerHandler, 
        ILogger<CircuitBreakerEventHandler<T>> logger,
        int failureThreshold = 5, 
        TimeSpan? timeout = null)
    {
        _innerHandler = innerHandler;
        _logger = logger;
        _failureThreshold = failureThreshold;
        _timeout = timeout ?? TimeSpan.FromMinutes(1);
    }

    public async Task HandleAsync(T @event)
    {
        if (_state == CircuitBreakerState.Open)
        {
            if (DateTime.UtcNow - _lastFailureTime < _timeout)
            {
                throw new CircuitBreakerOpenException($"Circuit breaker is open for event handler {typeof(T).Name}");
            }
            
            _state = CircuitBreakerState.HalfOpen;
        }

        try
        {
            await _innerHandler.HandleAsync(@event);
            
            if (_state == CircuitBreakerState.HalfOpen)
            {
                _state = CircuitBreakerState.Closed;
                _failureCount = 0;
                _logger.LogInformation("Circuit breaker closed for event handler {EventType}", typeof(T).Name);
            }
        }
        catch (Exception ex)
        {
            _failureCount++;
            _lastFailureTime = DateTime.UtcNow;

            if (_failureCount >= _failureThreshold)
            {
                _state = CircuitBreakerState.Open;
                _logger.LogError(ex, "Circuit breaker opened for event handler {EventType} after {FailureCount} failures", 
                    typeof(T).Name, _failureCount);
            }

            throw;
        }
    }
}

public enum CircuitBreakerState
{
    Closed,
    Open,
    HalfOpen
}
```

### 8. Common Anti-Patterns and Solutions

#### Anti-Pattern: Event Sourcing Everything

```text
❌ WRONG: Using Event Sourcing for all aggregates
✅ RIGHT: Use Event Sourcing selectively

Event Sourcing works best for:
• Business-critical aggregates with complex business rules
• Aggregates requiring full audit trails
• Aggregates with frequent state changes
• Need for temporal queries and replay scenarios

Avoid Event Sourcing for:
• Simple CRUD operations
• Reference data that rarely changes
• Aggregates with minimal business logic
• Performance-critical read scenarios
```

#### Anti-Pattern: Publishing Too Many Events

```csharp
// ❌ WRONG: Publishing low-value events
public class Customer : AggregateRoot
{
    public void UpdateProfile(string firstName, string lastName, string phone)
    {
        // Publishing separate events for each field change
        AddEvent(new CustomerFirstNameChangedEvent(Id, firstName));
        AddEvent(new CustomerLastNameChangedEvent(Id, lastName));
        AddEvent(new CustomerPhoneChangedEvent(Id, phone));
    }
}

// ✅ RIGHT: Publishing meaningful business events
public class Customer : AggregateRoot
{
    public void UpdateProfile(string firstName, string lastName, string phone)
    {
        // Single meaningful business event
        AddEvent(new CustomerProfileUpdatedEvent(Id, firstName, lastName, phone));
    }
}
```

#### Anti-Pattern: Ignoring Event Ordering

```csharp
// ❌ WRONG: Not handling event ordering
public class AccountProjectionHandler : IEventHandler<MoneyDepositedEvent>, IEventHandler<MoneyWithdrawnEvent>
{
    public async Task HandleAsync(MoneyDepositedEvent @event)
    {
        // Risk: This might be processed after a withdrawal event that occurred later
        var account = await _repository.GetAccountAsync(@event.AccountId);
        account.Balance += @event.Amount;
        await _repository.UpdateAccountAsync(account);
    }
}

// ✅ RIGHT: Using event sequencing
public class AccountProjectionHandler : IEventHandler<AccountEvent>
{
    public async Task HandleAsync(AccountEvent @event)
    {
        var account = await _repository.GetAccountAsync(@event.AccountId);
        
        // Check sequence number to ensure ordering
        if (@event.SequenceNumber <= account.LastProcessedSequence)
        {
            _logger.LogWarning("Event {EventId} already processed or out of order", @event.Id);
            return;
        }

        switch (@event)
        {
            case MoneyDepositedEvent deposited:
                account.Balance += deposited.Amount;
                break;
            case MoneyWithdrawnEvent withdrawn:
                account.Balance -= withdrawn.Amount;
                break;
        }

        account.LastProcessedSequence = @event.SequenceNumber;
        await _repository.UpdateAccountAsync(account);
    }
}
```

### 9. Testing Strategies

#### Testing Event-Driven Systems

```csharp
[Test]
public async Task Should_Publish_OrderCreated_Event_When_Order_Is_Created()
{
    // Arrange
    var customerId = "customer-123";
    var items = new List<OrderLineItem>
    {
        new("product-1", 2, 29.99m),
        new("product-2", 1, 19.99m)
    };

    // Act
    var order = Order.CreateNew(customerId, items);
    var events = order.GetUncommittedEvents();

    // Assert
    events.Should().HaveCount(1);
    var orderCreatedEvent = events.First().Should().BeOfType<OrderCreatedEvent>().Subject;
    orderCreatedEvent.CustomerId.Should().Be(customerId);
    orderCreatedEvent.TotalAmount.Should().Be(79.97m);
    orderCreatedEvent.Items.Should().HaveCount(2);
}

[Test]
public async Task Should_Update_Read_Model_When_OrderCreated_Event_Is_Handled()
{
    // Arrange
    var orderCreatedEvent = new OrderCreatedEvent(
        Guid.NewGuid(),
        DateTime.UtcNow,
        Guid.NewGuid(),
        "customer-123",
        100.00m,
        new List<OrderLineItem>()
    );

    var repository = new Mock<IOrderReadModelRepository>();
    var handler = new OrderProjectionHandler(repository.Object);

    // Act
    await handler.HandleAsync(orderCreatedEvent);

    // Assert
    repository.Verify(r => r.UpsertAsync(It.Is<OrderReadModel>(
        model => model.OrderId == orderCreatedEvent.OrderId &&
                model.CustomerId == orderCreatedEvent.CustomerId &&
                model.TotalAmount == orderCreatedEvent.TotalAmount)), 
        Times.Once);
}
```

#### Integration Testing with Test Containers

```csharp
[Test]
public async Task Should_Process_Order_End_To_End()
{
    // Arrange - Use TestContainers for real infrastructure
    await using var container = new ContainerBuilder()
        .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
        .WithEnvironment("SA_PASSWORD", "Your_password123")
        .WithEnvironment("ACCEPT_EULA", "Y")
        .WithPortBinding(1433, true)
        .Build();

    await container.StartAsync();

    var connectionString = container.GetConnectionString();
    var services = new ServiceCollection()
        .AddSingleton<IEventStore, SqlEventStore>()
        .AddScoped<ICommandHandler<CreateOrderCommand>, CreateOrderCommandHandler>()
        .Configure<EventStoreOptions>(o => o.ConnectionString = connectionString)
        .BuildServiceProvider();

    // Act
    var command = new CreateOrderCommand(
        Guid.NewGuid(),
        "customer-123",
        new List<OrderLineItem> { new("product-1", 1, 50.00m) }
    );

    var handler = services.GetRequiredService<ICommandHandler<CreateOrderCommand>>();
    await handler.HandleAsync(command);

    // Assert
    var eventStore = services.GetRequiredService<IEventStore>();
    var events = await eventStore.GetEventsAsync($"order-{command.CommandId}");
    
    events.Should().HaveCount(1);
    events.First().Should().BeOfType<OrderCreatedEvent>();
}
```

## 🚀 Common Pitfalls

### 1. **Over-Engineering Simple Scenarios**

Don't use event sourcing for basic CRUD operations. Start simple and evolve when business complexity demands it.

### 2. **Ignoring Eventual Consistency**

Event-driven systems are eventually consistent by nature. Design your UX and business processes accordingly.

### 3. **Poor Event Versioning Strategy**

Events are part of your API contract. Plan for evolution with proper versioning from the start.

### 4. **Inadequate Error Handling**

Failed event processing can lead to inconsistent state. Implement proper retry, dead letter, and compensation patterns.

### 5. **Missing Business Correlation**

Include correlation IDs and business context in events to enable effective monitoring and debugging.

## 🔗 Next Steps

After mastering Event-Driven Architecture:

1. **Explore Saga Patterns** - Learn distributed transaction management
2. **Study CQRS Projections** - Advanced read model optimization techniques
3. **Implement Event Streaming** - Real-time event processing with tools like Apache Kafka
4. **Master Observability** - Distributed tracing and monitoring for event-driven systems
5. **Practice Domain Modeling** - Apply event storming techniques for domain discovery

## 🔗 Related Topics

**Prerequisites:**

- [Clean Architecture](./01_Clean-Architecture.md) - Foundation for organizing code
- [Domain-Driven Design](./02_Domain-Driven-Design.md) - Domain modeling principles
- [System Design Fundamentals](./04_System-Design-Fundamentals.md) - Distributed systems concepts

**Builds Upon:**

- [Microservices Architecture](./05_Microservices-Architecture.md) - Service decomposition patterns

**Enables:**

- Advanced distributed patterns and resilience
- Real-time systems and stream processing
- Complex business process automation
- Audit and compliance requirements

**Cross-References:**

- [Data Management in DevOps](../../04_DevOps/) - Event-driven deployment patterns
- [Data Science Pipeline Architecture](../../03_Data-Science/) - Event-driven data processing

---

**Last Updated**: September 8, 2025  
**Module Version**: 1.0  
**Estimated Completion**: Day 5 of Development Track Migration
