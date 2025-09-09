# Microservices Architecture Fundamentals

**Learning Level**: Advanced  
**Prerequisites**: System Design Fundamentals, Clean Architecture, Domain-Driven Design  
**Estimated Time**: 8-10 hours  
**Last Updated**: September 8, 2025

## 🎯 Learning Objectives

By the end of this module, you will:

- **Understand microservices architecture principles** and when to apply them
- **Design service boundaries** using domain-driven decomposition strategies
- **Implement communication patterns** for distributed systems
- **Apply resilience patterns** to build fault-tolerant services
- **Establish monitoring and observability** for microservices ecosystems
- **Make informed technology decisions** for microservices implementation

## 📋 Prerequisites

### Required Knowledge

- **System Design Fundamentals**: Understanding of distributed systems concepts
- **Clean Architecture**: Separation of concerns and dependency inversion
- **Domain-Driven Design**: Bounded contexts and strategic design
- **RESTful APIs**: HTTP protocols and API design principles
- **Database Design**: Both relational and NoSQL database concepts

### Recommended Experience

- Building distributed applications
- Working with containerization technologies
- Understanding of DevOps practices
- Experience with message queuing systems

## 🏗️ Microservices Architecture Overview

### Definition and Core Principles

Microservices architecture is an approach to developing applications as a suite of small, autonomous services that communicate over well-defined APIs. Each service is:

- **Independently deployable**
- **Organized around business capabilities**
- **Owned by a small team**
- **Decentralized in governance and data management**

### When to Choose Microservices

```text
Microservices Decision Matrix

Organizational Readiness:
├── Team Size: Multiple autonomous teams (>20 developers)
├── Conway's Law: Organization structure supports service boundaries
├── DevOps Maturity: CI/CD, monitoring, automation capabilities
└── Cultural Fit: Embrace failure, continuous learning

Technical Requirements:
├── Scalability: Different scaling needs for different components
├── Technology Diversity: Need for different tech stacks
├── Deployment Independence: Different release cycles
└── Fault Isolation: Business-critical reliability requirements

Business Drivers:
├── Speed to Market: Faster feature delivery
├── Innovation: Experimentation with new technologies
├── Compliance: Different regulatory requirements
└── Domain Complexity: Multiple distinct business areas
```

## 🎨 Service Decomposition Strategies

### 1. Domain-Driven Decomposition

```csharp
// E-commerce Domain Decomposition Example

// Customer Service - Customer Management Bounded Context
public class CustomerService
{
    public interface ICustomerRepository
    {
        Task<Customer> GetByIdAsync(CustomerId id);
        Task<Customer> CreateAsync(Customer customer);
        Task UpdateAsync(Customer customer);
    }

    public class Customer
    {
        public CustomerId Id { get; private set; }
        public string Name { get; private set; }
        public Email Email { get; private set; }
        public Address ShippingAddress { get; private set; }
        
        // Customer-specific business logic
        public void UpdateProfile(string name, Email email)
        {
            Name = name;
            Email = email;
            // Domain validation logic
        }
    }
}

// Order Service - Order Management Bounded Context
public class OrderService
{
    public interface IOrderRepository
    {
        Task<Order> GetByIdAsync(OrderId id);
        Task<Order> CreateAsync(Order order);
        Task UpdateStatusAsync(OrderId id, OrderStatus status);
    }

    public class Order
    {
        public OrderId Id { get; private set; }
        public CustomerId CustomerId { get; private set; } // Reference to Customer
        public List<OrderItem> Items { get; private set; }
        public OrderStatus Status { get; private set; }
        public decimal TotalAmount { get; private set; }
        
        // Order-specific business logic
        public void AddItem(ProductId productId, int quantity, decimal price)
        {
            Items.Add(new OrderItem(productId, quantity, price));
            RecalculateTotalAmount();
        }
    }
}

// Inventory Service - Inventory Management Bounded Context
public class InventoryService
{
    public interface IInventoryRepository
    {
        Task<InventoryItem> GetByProductIdAsync(ProductId productId);
        Task ReserveStockAsync(ProductId productId, int quantity);
        Task ReleaseReservationAsync(ProductId productId, int quantity);
    }

    public class InventoryItem
    {
        public ProductId ProductId { get; private set; }
        public int AvailableQuantity { get; private set; }
        public int ReservedQuantity { get; private set; }
        
        // Inventory-specific business logic
        public bool CanReserve(int quantity)
        {
            return AvailableQuantity >= quantity;
        }
        
        public void ReserveStock(int quantity)
        {
            if (!CanReserve(quantity))
                throw new InsufficientStockException();
                
            AvailableQuantity -= quantity;
            ReservedQuantity += quantity;
        }
    }
}
```

### 2. Data Decomposition Patterns

```csharp
// Database per Service Pattern Implementation

// Customer Service Database Context
public class CustomerDbContext : DbContext
{
    public DbSet<Customer> Customers { get; set; }
    public DbSet<CustomerProfile> CustomerProfiles { get; set; }
    
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // Customer service has its own database
        optionsBuilder.UseSqlServer("CustomerServiceConnectionString");
    }
}

// Order Service Database Context  
public class OrderDbContext : DbContext
{
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }
    
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // Order service has its own database
        optionsBuilder.UseSqlServer("OrderServiceConnectionString");
    }
}

// Shared Data Pattern (Anti-pattern to avoid)
// DON'T: Multiple services sharing the same database
// This creates tight coupling and defeats the purpose of microservices
```

## 🔗 Communication Patterns

### 1. Synchronous Communication

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

// Service Client Implementation with Circuit Breaker
public class CustomerServiceClient : ICustomerServiceClient
{
    private readonly HttpClient _httpClient;
    private readonly ICircuitBreaker _circuitBreaker;
    
    public CustomerServiceClient(HttpClient httpClient, ICircuitBreaker circuitBreaker)
    {
        _httpClient = httpClient;
        _circuitBreaker = circuitBreaker;
    }
    
    public async Task<CustomerDto> GetCustomerAsync(CustomerId customerId)
    {
        return await _circuitBreaker.ExecuteAsync(async () =>
        {
            var response = await _httpClient.GetAsync($"/customers/{customerId}");
            response.EnsureSuccessStatusCode();
            
            var content = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<CustomerDto>(content);
        });
    }
}
```

### 2. Asynchronous Communication

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

## 🛡️ Resilience Patterns

### 1. Circuit Breaker Pattern

```csharp
public class CircuitBreaker : ICircuitBreaker
{
    private readonly int _failureThreshold;
    private readonly TimeSpan _timeout;
    private readonly TimeSpan _retryInterval;
    
    private int _failureCount;
    private DateTime _lastFailureTime;
    private CircuitBreakerState _state = CircuitBreakerState.Closed;
    
    public CircuitBreaker(int failureThreshold, TimeSpan timeout, TimeSpan retryInterval)
    {
        _failureThreshold = failureThreshold;
        _timeout = timeout;
        _retryInterval = retryInterval;
    }
    
    public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation)
    {
        if (_state == CircuitBreakerState.Open)
        {
            if (DateTime.UtcNow - _lastFailureTime > _retryInterval)
            {
                _state = CircuitBreakerState.HalfOpen;
            }
            else
            {
                throw new CircuitBreakerOpenException("Circuit breaker is open");
            }
        }
        
        try
        {
            var result = await operation();
            OnSuccess();
            return result;
        }
        catch (Exception ex)
        {
            OnFailure();
            throw;
        }
    }
    
    private void OnSuccess()
    {
        _failureCount = 0;
        _state = CircuitBreakerState.Closed;
    }
    
    private void OnFailure()
    {
        _failureCount++;
        _lastFailureTime = DateTime.UtcNow;
        
        if (_failureCount >= _failureThreshold)
        {
            _state = CircuitBreakerState.Open;
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

### 2. Retry Pattern with Exponential Backoff

```csharp
public class RetryPolicy
{
    private readonly int _maxRetries;
    private readonly TimeSpan _initialDelay;
    
    public RetryPolicy(int maxRetries = 3, TimeSpan? initialDelay = null)
    {
        _maxRetries = maxRetries;
        _initialDelay = initialDelay ?? TimeSpan.FromMilliseconds(100);
    }
    
    public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation)
    {
        var attempt = 0;
        
        while (true)
        {
            try
            {
                return await operation();
            }
            catch (Exception ex) when (IsTransientException(ex) && attempt < _maxRetries)
            {
                attempt++;
                var delay = CalculateDelay(attempt);
                
                await Task.Delay(delay);
            }
        }
    }
    
    private bool IsTransientException(Exception ex)
    {
        return ex is HttpRequestException ||
               ex is TaskCanceledException ||
               ex is SocketException;
    }
    
    private TimeSpan CalculateDelay(int attempt)
    {
        // Exponential backoff with jitter
        var exponentialDelay = TimeSpan.FromMilliseconds(
            _initialDelay.TotalMilliseconds * Math.Pow(2, attempt - 1));
        
        var jitter = TimeSpan.FromMilliseconds(
            Random.Shared.Next(0, (int)(exponentialDelay.TotalMilliseconds * 0.1)));
        
        return exponentialDelay + jitter;
    }
}
```

### 3. Bulkhead Pattern

```csharp
// Resource Isolation using separate thread pools
public class BulkheadService
{
    private readonly TaskScheduler _criticalTaskScheduler;
    private readonly TaskScheduler _normalTaskScheduler;
    
    public BulkheadService()
    {
        // Critical operations get dedicated thread pool
        var criticalThreads = new LimitedConcurrencyLevelTaskScheduler(2);
        _criticalTaskScheduler = criticalThreads;
        
        // Normal operations use default thread pool
        _normalTaskScheduler = TaskScheduler.Default;
    }
    
    public Task<T> ExecuteCriticalOperationAsync<T>(Func<Task<T>> operation)
    {
        return Task.Factory.StartNew(
            async () => await operation(),
            CancellationToken.None,
            TaskCreationOptions.None,
            _criticalTaskScheduler).Unwrap();
    }
    
    public Task<T> ExecuteNormalOperationAsync<T>(Func<Task<T>> operation)
    {
        return Task.Factory.StartNew(
            async () => await operation(),
            CancellationToken.None,
            TaskCreationOptions.None,
            _normalTaskScheduler).Unwrap();
    }
}

// Connection Pool Bulkhead
public class DatabaseConnectionManager
{
    private readonly SemaphoreSlim _criticalOperationsSemaphore;
    private readonly SemaphoreSlim _normalOperationsSemaphore;
    
    public DatabaseConnectionManager()
    {
        // Reserve connections for critical operations
        _criticalOperationsSemaphore = new SemaphoreSlim(5, 5);
        // Remaining connections for normal operations
        _normalOperationsSemaphore = new SemaphoreSlim(15, 15);
    }
    
    public async Task<T> ExecuteCriticalQueryAsync<T>(Func<IDbConnection, Task<T>> query)
    {
        await _criticalOperationsSemaphore.WaitAsync();
        try
        {
            using var connection = CreateConnection();
            return await query(connection);
        }
        finally
        {
            _criticalOperationsSemaphore.Release();
        }
    }
}
```

## 📊 Data Management Patterns

### 1. Saga Pattern for Distributed Transactions

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

public class OrderSagaState
{
    public Guid SagaId { get; set; }
    public OrderId OrderId { get; set; }
    public CustomerId CustomerId { get; set; }
    public List<OrderItemDto> Items { get; set; }
    public SagaStatus Status { get; set; }
    
    public bool CustomerValidated { get; set; }
    public bool InventoryReserved { get; set; }
    public Guid? ReservationId { get; set; }
    public bool PaymentProcessed { get; set; }
    public Guid? PaymentId { get; set; }
}

public enum SagaStatus
{
    Started,
    ValidatingCustomer,
    ReservingInventory,
    ProcessingPayment,
    Completed,
    Failed
}
```

### 2. Event Sourcing Pattern

```csharp
// Event Store Implementation
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

// Event Store Repository
public class EventStoreRepository<T> where T : AggregateRoot
{
    private readonly IEventStore _eventStore;
    
    public async Task<T> GetByIdAsync(Guid id)
    {
        var events = await _eventStore.GetEventsAsync(id);
        if (!events.Any())
            return null;
            
        return (T)Activator.CreateInstance(typeof(T), events);
    }
    
    public async Task SaveAsync(T aggregate)
    {
        var uncommittedEvents = aggregate.GetUncommittedEvents();
        if (uncommittedEvents.Any())
        {
            await _eventStore.SaveEventsAsync(aggregate.Id, uncommittedEvents);
            aggregate.MarkEventsAsCommitted();
        }
    }
}
```

## 📈 Monitoring and Observability

### 1. Distributed Tracing

```csharp
// OpenTelemetry Integration
public class OrderController : ControllerBase
{
    private readonly ActivitySource _activitySource;
    private readonly ILogger<OrderController> _logger;
    
    public OrderController(ActivitySource activitySource, ILogger<OrderController> logger)
    {
        _activitySource = activitySource;
        _logger = logger;
    }
    
    [HttpPost]
    public async Task<ActionResult<OrderDto>> CreateOrderAsync(CreateOrderRequest request)
    {
        using var activity = _activitySource.StartActivity("CreateOrder");
        activity?.SetTag("order.customer_id", request.CustomerId.ToString());
        activity?.SetTag("order.item_count", request.Items.Count.ToString());
        
        try
        {
            _logger.LogInformation("Creating order for customer {CustomerId}", request.CustomerId);
            
            // Create correlation ID for request tracking
            var correlationId = Guid.NewGuid();
            using var scope = _logger.BeginScope(new Dictionary<string, object>
            {
                ["CorrelationId"] = correlationId,
                ["Operation"] = "CreateOrder"
            });
            
            var order = await _orderService.CreateOrderAsync(request, correlationId);
            
            activity?.SetTag("order.id", order.Id.ToString());
            activity?.SetStatus(ActivityStatusCode.Ok);
            
            return Ok(OrderDto.FromDomain(order));
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            _logger.LogError(ex, "Failed to create order for customer {CustomerId}", request.CustomerId);
            throw;
        }
    }
}

// Service-to-Service Tracing
public class CustomerServiceClient : ICustomerServiceClient
{
    private readonly HttpClient _httpClient;
    private readonly ActivitySource _activitySource;
    
    public async Task<CustomerDto> GetCustomerAsync(CustomerId customerId)
    {
        using var activity = _activitySource.StartActivity("GetCustomer");
        activity?.SetTag("customer.id", customerId.ToString());
        
        var request = new HttpRequestMessage(HttpMethod.Get, $"/customers/{customerId}");
        
        // Propagate trace context
        var context = Activity.Current?.Context ?? default;
        request.Headers.Add("traceparent", context.ToString());
        
        var response = await _httpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();
        
        return await JsonSerializer.DeserializeAsync<CustomerDto>(
            await response.Content.ReadAsStreamAsync());
    }
}
```

### 2. Health Checks and Metrics

```csharp
// Comprehensive Health Checks
public class OrderServiceHealthCheck : IHealthCheck
{
    private readonly IDbConnection _dbConnection;
    private readonly IMessagePublisher _messagePublisher;
    private readonly ICustomerServiceClient _customerService;
    
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        var healthCheckData = new Dictionary<string, object>();
        
        try
        {
            // Check database connectivity
            await _dbConnection.QueryAsync("SELECT 1");
            healthCheckData["database"] = "healthy";
            
            // Check message bus connectivity
            await _messagePublisher.PublishAsync("health.check", new { timestamp = DateTime.UtcNow });
            healthCheckData["message_bus"] = "healthy";
            
            // Check dependent service connectivity
            var customerHealthy = await CheckCustomerServiceHealthAsync();
            healthCheckData["customer_service"] = customerHealthy ? "healthy" : "unhealthy";
            
            return HealthCheckResult.Healthy("Service is healthy", healthCheckData);
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Service is unhealthy", ex, healthCheckData);
        }
    }
    
    private async Task<bool> CheckCustomerServiceHealthAsync()
    {
        try
        {
            // Attempt to call customer service health endpoint
            using var httpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(5) };
            var response = await httpClient.GetAsync("https://customer-service/health");
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }
}

// Custom Metrics
public class OrderMetrics
{
    private readonly Counter<int> _ordersCreated;
    private readonly Histogram<double> _orderProcessingTime;
    private readonly Gauge<int> _pendingOrders;
    
    public OrderMetrics(IMeterProvider meterProvider)
    {
        var meter = meterProvider.GetMeter("OrderService");
        
        _ordersCreated = meter.CreateCounter<int>(
            "orders_created_total",
            "Total number of orders created");
            
        _orderProcessingTime = meter.CreateHistogram<double>(
            "order_processing_duration_seconds",
            "Time taken to process an order");
            
        _pendingOrders = meter.CreateGauge<int>(
            "pending_orders_count",
            "Current number of pending orders");
    }
    
    public void RecordOrderCreated(string customerType)
    {
        _ordersCreated.Add(1, new KeyValuePair<string, object>("customer_type", customerType));
    }
    
    public void RecordOrderProcessingTime(double seconds, string orderType)
    {
        _orderProcessingTime.Record(seconds, new KeyValuePair<string, object>("order_type", orderType));
    }
    
    public void UpdatePendingOrdersCount(int count)
    {
        _pendingOrders.Record(count);
    }
}
```

## 🚀 Deployment and Infrastructure Patterns

### 1. Service Mesh Configuration

```yaml
# Istio Service Mesh Configuration
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: order-service
spec:
  hosts:
  - order-service
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: order-service
        subset: canary
      weight: 100
  - route:
    - destination:
        host: order-service
        subset: stable
      weight: 100
    fault:
      delay:
        percentage:
          value: 0.1
        fixedDelay: 5s
    retries:
      attempts: 3
      perTryTimeout: 2s

---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: order-service
spec:
  host: order-service
  subsets:
  - name: stable
    labels:
      version: stable
  - name: canary
    labels:
      version: canary
  trafficPolicy:
    circuitBreaker:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
```

### 2. Container Orchestration

```yaml
# Kubernetes Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  labels:
    app: order-service
    version: stable
spec:
  replicas: 3
  selector:
    matchLabels:
      app: order-service
      version: stable
  template:
    metadata:
      labels:
        app: order-service
        version: stable
    spec:
      containers:
      - name: order-service
        image: myregistry/order-service:1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_CONNECTION_STRING
          valueFrom:
            secretKeyRef:
              name: order-service-secrets
              key: database-connection-string
        - name: MESSAGE_BUS_CONNECTION_STRING
          valueFrom:
            secretKeyRef:
              name: order-service-secrets
              key: message-bus-connection-string
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  selector:
    app: order-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: order-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: order-service
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## 🛠️ Technology Selection Matrix

### Message Brokers Comparison

| Technology | Use Case | Pros | Cons | Best For |
|------------|----------|------|------|----------|
| **RabbitMQ** | Complex routing, reliable delivery | Advanced routing, strong consistency | Higher latency, complex setup | Financial systems, order processing |
| **Apache Kafka** | High-throughput event streaming | Excellent performance, event sourcing | Complex operations, storage overhead | Analytics, log aggregation |
| **Azure Service Bus** | Enterprise integration | Managed service, advanced features | Cloud vendor lock-in, cost | Enterprise applications |
| **Redis Pub/Sub** | Simple pub/sub patterns | Extremely fast, simple | No durability, limited features | Real-time notifications |

### API Gateway Solutions

| Technology | Use Case | Pros | Cons | Best For |
|------------|----------|------|------|----------|
| **Kong** | Feature-rich gateway | Extensible, enterprise features | Complex configuration | Large-scale APIs |
| **Envoy Proxy** | Service mesh integration | High performance, observability | Configuration complexity | Cloud-native apps |
| **Azure API Management** | Enterprise API management | Comprehensive management, analytics | Cost, vendor lock-in | Enterprise scenarios |
| **Ocelot** | .NET-based gateway | .NET native, lightweight | Limited ecosystem | .NET microservices |

### Service Discovery Options

| Technology | Use Case | Pros | Cons | Best For |
|------------|----------|------|------|----------|
| **Consul** | Service discovery + configuration | Feature-complete, multi-DC | Operational complexity | Multi-cloud deployments |
| **Eureka** | Spring-based discovery | Java ecosystem integration | Java-centric | Spring Boot applications |
| **Kubernetes DNS** | Container orchestration | Native integration, simple | Kubernetes-only | Cloud-native deployments |
| **Azure Service Fabric** | Microsoft stack | Integrated platform | Platform lock-in | Windows-based services |

## 🚨 Common Anti-Patterns and Solutions

### 1. Distributed Monolith

**Anti-Pattern**: Services that are too tightly coupled and must be deployed together.

```csharp
// DON'T: Tight coupling between services
public class OrderService
{
    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        // Synchronous calls to multiple services create tight coupling
        var customer = await _customerService.GetCustomerAsync(request.CustomerId);
        var inventory = await _inventoryService.CheckStockAsync(request.Items);
        var pricing = await _pricingService.CalculatePriceAsync(request.Items);
        var shipping = await _shippingService.CalculateShippingAsync(customer.Address);
        
        // If any service is down, the entire operation fails
        // Services become coupled and must be deployed together
    }
}

// DO: Loose coupling with eventual consistency
public class OrderService
{
    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        // Create order with available information
        var order = new Order(request.CustomerId, request.Items);
        await _orderRepository.SaveAsync(order);
        
        // Publish event for other services to react asynchronously
        await _eventPublisher.PublishAsync(new OrderCreatedEvent
        {
            OrderId = order.Id,
            CustomerId = request.CustomerId,
            Items = request.Items
        });
        
        // Services can process independently and update order status later
    }
}
```

### 2. Data Inconsistency

**Anti-Pattern**: Shared database or immediate consistency requirements across services.

```csharp
// DON'T: Shared database access
public class OrderService
{
    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        using var transaction = _sharedDbContext.Database.BeginTransaction();
        
        // Multiple services modifying shared database
        var customer = await _sharedDbContext.Customers
            .FindAsync(request.CustomerId);
        
        var inventoryItems = await _sharedDbContext.InventoryItems
            .Where(i => request.Items.Select(ri => ri.ProductId).Contains(i.ProductId))
            .ToListAsync();
        
        // Complex transaction across business domains
        // Creates tight coupling and scalability issues
    }
}

// DO: Eventual consistency with compensation
public class OrderService
{
    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        // Each service owns its data
        var order = new Order(request.CustomerId, request.Items);
        order.SetStatus(OrderStatus.Pending);
        
        await _orderRepository.SaveAsync(order);
        
        // Use saga pattern for cross-service transactions
        await _sagaOrchestrator.StartSagaAsync(new OrderProcessingSaga
        {
            OrderId = order.Id,
            Steps = new List<SagaStep>
            {
                new ValidateCustomerStep(request.CustomerId),
                new ReserveInventoryStep(request.Items),
                new ProcessPaymentStep(request.PaymentInfo)
            }
        });
    }
}
```

### 3. Chatty Interfaces

**Anti-Pattern**: Too many fine-grained service calls.

```csharp
// DON'T: Multiple round trips for single operation
public class OrderController
{
    public async Task<OrderSummaryDto> GetOrderSummaryAsync(OrderId orderId)
    {
        var order = await _orderService.GetOrderAsync(orderId);
        var customer = await _customerService.GetCustomerAsync(order.CustomerId);
        var items = new List<OrderItemDetailDto>();
        
        // N+1 query problem across services
        foreach (var item in order.Items)
        {
            var product = await _productService.GetProductAsync(item.ProductId);
            var inventory = await _inventoryService.GetInventoryAsync(item.ProductId);
            items.Add(new OrderItemDetailDto
            {
                Product = product,
                Inventory = inventory,
                Quantity = item.Quantity
            });
        }
        
        return new OrderSummaryDto
        {
            Order = order,
            Customer = customer,
            Items = items
        };
    }
}

// DO: Coarse-grained interfaces and data aggregation
public class OrderController
{
    public async Task<OrderSummaryDto> GetOrderSummaryAsync(OrderId orderId)
    {
        // Single call to get complete order summary
        // Service internally aggregates data efficiently
        return await _orderQueryService.GetOrderSummaryAsync(orderId);
    }
}

public class OrderQueryService
{
    public async Task<OrderSummaryDto> GetOrderSummaryAsync(OrderId orderId)
    {
        // Use materialized view or read model
        // Pre-aggregated data for efficient querying
        var orderSummary = await _orderSummaryRepository.GetAsync(orderId);
        
        if (orderSummary == null)
        {
            // Fallback to real-time aggregation if needed
            orderSummary = await BuildOrderSummaryAsync(orderId);
        }
        
        return orderSummary;
    }
}
```

## 📚 Learning Path and Next Steps

### Prerequisites Mastery Checklist

- [ ] **Distributed Systems Concepts**: Understand CAP theorem, eventual consistency
- [ ] **API Design**: RESTful principles, HTTP status codes, versioning strategies
- [ ] **Message Queues**: Basic understanding of pub/sub patterns
- [ ] **Container Technology**: Docker basics, image management
- [ ] **Cloud Platforms**: Basic understanding of cloud services (Azure, AWS, GCP)

### Advanced Topics to Explore

1. **Service Mesh Advanced Patterns**
   - Traffic splitting and canary deployments
   - Security policies and mTLS
   - Advanced observability and chaos engineering

2. **Event-Driven Architecture**
   - Event sourcing implementation patterns
   - CQRS with read/write model separation
   - Saga orchestration vs choreography

3. **Performance Optimization**
   - Service communication optimization
   - Caching strategies at scale
   - Database sharding and partitioning

4. **Security Patterns**
   - Zero-trust architecture
   - Service-to-service authentication
   - API security and rate limiting

### Recommended Practices

1. **Start Small**: Begin with a monolith and extract services gradually
2. **Focus on Business Domains**: Use domain boundaries for service boundaries
3. **Automate Everything**: CI/CD, testing, monitoring, deployment
4. **Monitor Extensively**: Distributed tracing, metrics, logging
5. **Plan for Failure**: Circuit breakers, retries, fallback strategies

## 🔗 Related Topics

### Prerequisites

- [System Design Fundamentals](04_System-Design-Fundamentals.md) - Distributed systems concepts
- [Clean Architecture](01_Clean-Architecture-Fundamentals.md) - Architectural principles
- [Domain-Driven Design](02_Domain-Driven-Design-Fundamentals.md) - Strategic design patterns

### Builds Upon

- **API Design Patterns**: RESTful services, GraphQL, gRPC
- **Event-Driven Architecture**: Event sourcing, CQRS, message patterns
- **DevOps Practices**: CI/CD, containerization, infrastructure as code

### Enables

- **Cloud-Native Development**: Kubernetes, service mesh, serverless
- **Enterprise Integration**: API management, ESB, microservices governance
- **Scalable System Design**: High availability, fault tolerance, performance optimization

---

**Last Updated**: September 8, 2025  
**Maintained By**: STSA Learning System
