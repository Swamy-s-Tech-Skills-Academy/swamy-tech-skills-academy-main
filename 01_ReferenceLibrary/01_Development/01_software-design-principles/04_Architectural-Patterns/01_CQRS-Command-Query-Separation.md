# 01_CQRS-Command-Query-Separation.md

**Learning Level**: Intermediate  
**Prerequisites**: Understanding of Clean Architecture, basic knowledge of application layers  
**Estimated Time**: 45-60 minutes

## 🎯 Learning Objectives

By the end of this content, you will:

- Understand the fundamental principles of Command Query Responsibility Segregation (CQRS)
- Distinguish between commands and queries in application design
- Implement CQRS patterns with MediatR in .NET applications
- Apply separation of concerns at the architectural level
- Design scalable read and write operations independently

---

## 📋 CQRS Fundamentals

### What is CQRS?

**Command Query Responsibility Segregation (CQRS)** is an architectural pattern that separates the responsibility for reading data (queries) from the responsibility for modifying data (commands). This separation allows each operation type to be optimized independently.

### Core Principle: Separation of Intent

```text
Traditional Approach:
[User Request] → [Single Service] → [Database]
                     ↑
               Handles both reads 
               and writes together

CQRS Approach:
[User Request] → [Command Handler] → [Write Database]
             ↘
               [Query Handler] → [Read Database/View]
```

### Why CQRS Matters

1. **Performance Optimization**: Read and write operations have different optimization requirements
2. **Scalability**: Scale read and write sides independently
3. **Complexity Management**: Different models for different responsibilities
4. **Team Autonomy**: Separate teams can work on read vs write features

---

## 🏗️ CQRS Architecture Components

### Commands: State-Changing Operations

Commands represent **intent to change system state**:

```text
Command Characteristics:
• Express business intent (CreateOrder, UpdateCustomer)
• Contain all necessary data for the operation
• Should not return data (void or simple acknowledgment)
• Trigger business logic and validations
• May publish domain events
```

**Example Command Structure:**

```csharp
// Command Definition
public class CreateCustomerCommand
{
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Email { get; set; }
    public AddressDto Address { get; set; }
}

// Command Handler
public class CreateCustomerHandler
{
    public async Task<Guid> Handle(CreateCustomerCommand command)
    {
        // 1. Validate business rules
        // 2. Create domain entity
        // 3. Persist to write store
        // 4. Publish domain events
        // 5. Return identifier
    }
}
```

### Queries: Data-Retrieval Operations

Queries represent **requests for information**:

```text
Query Characteristics:
• Request specific data views
• No side effects (read-only)
• Optimized for display needs
• May aggregate data from multiple sources
• Return DTOs/View Models
```

**Example Query Structure:**

```csharp
// Query Definition
public class GetCustomerDetailsQuery
{
    public Guid CustomerId { get; set; }
}

// Query Handler
public class GetCustomerDetailsHandler
{
    public async Task<CustomerDetailsDto> Handle(GetCustomerDetailsQuery query)
    {
        // 1. Retrieve from optimized read store
        // 2. Transform to view model
        // 3. Return presentation-ready data
    }
}
```

---

## 🔧 Implementation with MediatR

### MediatR Integration Pattern

**MediatR** is a popular library that implements the mediator pattern, perfect for CQRS implementation:

```text
Application Flow:
[Controller] → [MediatR] → [Command/Query Handler] → [Response]
```

### Command Implementation

```csharp
// 1. Define Command with Response Type
public class UpdateProductPriceCommand : IRequest<bool>
{
    public Guid ProductId { get; set; }
    public decimal NewPrice { get; set; }
    public string Reason { get; set; }
}

// 2. Implement Command Handler
public class UpdateProductPriceHandler : IRequestHandler<UpdateProductPriceCommand, bool>
{
    private readonly IProductRepository _repository;
    private readonly IEventBus _eventBus;

    public UpdateProductPriceHandler(IProductRepository repository, IEventBus eventBus)
    {
        _repository = repository;
        _eventBus = eventBus;
    }

    public async Task<bool> Handle(UpdateProductPriceCommand request, CancellationToken cancellationToken)
    {
        // Retrieve entity
        var product = await _repository.GetByIdAsync(request.ProductId);
        if (product == null) return false;

        // Apply business logic
        product.UpdatePrice(request.NewPrice, request.Reason);

        // Persist changes
        await _repository.UpdateAsync(product);

        // Publish domain event
        await _eventBus.PublishAsync(new ProductPriceUpdatedEvent(product.Id, request.NewPrice));

        return true;
    }
}
```

### Query Implementation

```csharp
// 1. Define Query with Response Type
public class GetProductCatalogQuery : IRequest<ProductCatalogDto>
{
    public string Category { get; set; }
    public int PageSize { get; set; } = 20;
    public int PageNumber { get; set; } = 1;
}

// 2. Implement Query Handler
public class GetProductCatalogHandler : IRequestHandler<GetProductCatalogQuery, ProductCatalogDto>
{
    private readonly IReadOnlyRepository _readRepository;

    public GetProductCatalogHandler(IReadOnlyRepository readRepository)
    {
        _readRepository = readRepository;
    }

    public async Task<ProductCatalogDto> Handle(GetProductCatalogQuery request, CancellationToken cancellationToken)
    {
        // Query optimized read store
        var products = await _readRepository.GetProductsAsync(
            request.Category, 
            request.PageSize, 
            request.PageNumber);

        // Transform to view model
        return new ProductCatalogDto
        {
            Products = products.Select(p => new ProductSummaryDto
            {
                Id = p.Id,
                Name = p.Name,
                Price = p.CurrentPrice,
                ImageUrl = p.ThumbnailUrl
            }).ToList(),
            TotalCount = await _readRepository.GetProductCountAsync(request.Category),
            CurrentPage = request.PageNumber
        };
    }
}
```

### Controller Integration

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ProductsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    // Command endpoint
    [HttpPut("{id}/price")]
    public async Task<IActionResult> UpdatePrice(Guid id, UpdateProductPriceRequest request)
    {
        var command = new UpdateProductPriceCommand
        {
            ProductId = id,
            NewPrice = request.NewPrice,
            Reason = request.Reason
        };

        var result = await _mediator.Send(command);
        return result ? Ok() : NotFound();
    }

    // Query endpoint
    [HttpGet]
    public async Task<IActionResult> GetCatalog([FromQuery] GetProductCatalogQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }
}
```

---

## 🎯 Advanced CQRS Patterns

### Event-Driven Updates

```text
Write Side:                    Read Side:
[Command] → [Domain] → [Event] → [Projection Handler] → [Read Model]
```

Commands trigger domain events that update read models asynchronously:

```csharp
// Domain Event
public class CustomerCreatedEvent : IDomainEvent
{
    public Guid CustomerId { get; set; }
    public string FullName { get; set; }
    public string Email { get; set; }
    public DateTime CreatedAt { get; set; }
}

// Projection Handler
public class CustomerProjectionHandler : INotificationHandler<CustomerCreatedEvent>
{
    private readonly ICustomerReadModelRepository _readModelRepo;

    public async Task Handle(CustomerCreatedEvent notification, CancellationToken cancellationToken)
    {
        var readModel = new CustomerReadModel
        {
            Id = notification.CustomerId,
            DisplayName = notification.FullName,
            ContactEmail = notification.Email,
            MemberSince = notification.CreatedAt,
            TotalOrders = 0 // Initialize
        };

        await _readModelRepo.CreateAsync(readModel);
    }
}
```

### Specialized Read Models

Different views require different data structures:

```csharp
// Administrative View
public class CustomerAdminDto
{
    public Guid Id { get; set; }
    public string FullName { get; set; }
    public string Email { get; set; }
    public DateTime LastActivity { get; set; }
    public decimal TotalSpent { get; set; }
    public int OrderCount { get; set; }
    public CustomerStatus Status { get; set; }
}

// Public Profile View
public class CustomerProfileDto
{
    public string DisplayName { get; set; }
    public DateTime MemberSince { get; set; }
    public string PreferredLanguage { get; set; }
    public bool IsVerified { get; set; }
}

// Order History View
public class CustomerOrderHistoryDto
{
    public string CustomerName { get; set; }
    public List<OrderSummaryDto> RecentOrders { get; set; }
    public decimal TotalLifetimeValue { get; set; }
}
```

---

## ⚡ Performance and Scalability Benefits

### Independent Scaling

```text
High-Read Scenarios:
[Load Balancer] → [Multiple Query Handlers] → [Read Replicas]
                ↘ [Single Command Handler] → [Write Database]

High-Write Scenarios:
[Queue] → [Multiple Command Handlers] → [Write Database]
        ↘ [Async Event Processing] → [Read Model Updates]
```

### Optimization Strategies

**Write Side Optimizations:**

- Normalized database schemas for data integrity
- Transaction management for consistency
- Validation and business rule enforcement
- Audit logging and change tracking

**Read Side Optimizations:**

- Denormalized views for fast retrieval
- Caching layers for frequently accessed data
- Specialized indexes for query patterns
- Data aggregation and pre-computation

---

## 🚨 Common Pitfalls and Solutions

### Pitfall 1: Eventual Consistency Complexity

**Problem**: Read models may be temporarily out of sync with write models.

**Solution**: Design UI to handle eventual consistency gracefully:

```csharp
public class OrderStatusDto
{
    public Guid OrderId { get; set; }
    public OrderStatus Status { get; set; }
    public DateTime LastUpdated { get; set; }
    public bool IsProcessing { get; set; } // Indicates potential sync lag
}
```

### Pitfall 2: Over-Engineering Simple Scenarios

**Problem**: Applying CQRS to simple CRUD operations adds unnecessary complexity.

**Solution**: Use CQRS selectively:

```text
Apply CQRS When:
✅ Different performance requirements for reads vs writes
✅ Complex business logic on write operations
✅ Multiple views of the same data
✅ High-scale systems requiring independent scaling

Skip CQRS When:
❌ Simple CRUD operations
❌ Small applications with minimal complexity
❌ Tight coupling between read and write operations is acceptable
```

### Pitfall 3: Command Design Anti-patterns

**Problem**: Commands that return large amounts of data or act like queries.

**Solution**: Keep commands focused on state change:

```csharp
// ❌ Anti-pattern: Command returning data
public class CreateOrderCommand : IRequest<OrderDetailsDto> { }

// ✅ Correct: Command returning identifier only
public class CreateOrderCommand : IRequest<Guid> { }

// ✅ If details needed, use separate query
public class GetOrderDetailsQuery : IRequest<OrderDetailsDto> { }
```

---

## 🔗 Related Topics

### Prerequisites

- **Clean Architecture Principles**: Understanding layered architecture
- **Domain-Driven Design**: Entity and aggregate concepts
- **Dependency Injection**: For handler registration

### Builds Upon

- **Repository Pattern**: Data access abstraction
- **Mediator Pattern**: Decoupled communication
- **Domain Events**: Event-driven architecture

### Enables

- **Event Sourcing**: Complete audit trail of state changes
- **Microservices Architecture**: Service boundaries aligned with commands/queries
- **Polyglot Persistence**: Different databases for reads and writes

### Cross-References

- [Domain-Driven Design Fundamentals](02_Domain-Driven-Design.md)
- [Clean Architecture Implementation](03_Clean-Architecture-Patterns.md)
- [Event-Driven Architecture](04_Event-Driven-Patterns.md)

---

## ✅ Next Steps

1. **Practice Implementation**: Create a simple CQRS application with MediatR
2. **Explore Event Sourcing**: Combine CQRS with complete event logs
3. **Study Microservices**: Apply CQRS patterns across service boundaries
4. **Performance Testing**: Measure the impact of read/write separation

---

**Last Updated**: September 7, 2025  
**Next Review**: December 2025  
**Learning Path**: Software Design Principles → Architecture Patterns → Distributed Systems
