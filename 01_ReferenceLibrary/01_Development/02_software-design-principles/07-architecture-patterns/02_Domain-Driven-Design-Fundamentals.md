# 02_Domain-Driven-Design-Fundamentals.md

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Understanding of object-oriented programming, basic software architecture concepts  
**Estimated Time**: 60-75 minutes

## 🎯 Learning Objectives

By the end of this content, you will:

- Understand core Domain-Driven Design (DDD) concepts and principles
- Distinguish between entities, value objects, and aggregates
- Design domain models that reflect business requirements accurately
- Implement domain services and repository patterns effectively
- Apply DDD tactical patterns in real-world scenarios

---

## 📋 Domain-Driven Design Overview

### What is Domain-Driven Design?

**Domain-Driven Design (DDD)** is a software development approach that focuses on modeling software to match complex business domains. It emphasizes collaboration between technical and domain experts to create a shared understanding of the business problem being solved.

### Core Philosophy: Business-First Design

```text
Traditional Approach:
[Technical Model] → [Database Schema] → [Business Logic]
       ↑
   Driven by technical constraints

DDD Approach:
[Business Domain] → [Domain Model] → [Technical Implementation]
       ↑
   Driven by business understanding
```

### Why DDD Matters

1. **Shared Language**: Creates common terminology between business and technical teams
2. **Business Alignment**: Software structure mirrors business structure
3. **Complexity Management**: Isolates domain complexity from technical complexity
4. **Maintainability**: Changes to business rules map clearly to code changes

---

## 🏗️ DDD Building Blocks (Tactical Patterns)

### Entities: Objects with Identity

**Entities** are objects that have a **unique identity** that persists over time, even as their attributes change.

```text
Entity Characteristics:
• Unique identifier (ID)
• Identity persists across state changes
• Mutable attributes
• Equality based on identity, not attributes
```

#### Customer Entity Example

```csharp
public class Customer : Entity<Guid>
{
    public string FirstName { get; private set; }
    public string LastName { get; private set; }
    public string Email { get; private set; }
    public CustomerStatus Status { get; private set; }
    public DateTime CreatedDate { get; private set; }

    private Customer() { } // For ORM

    public Customer(string firstName, string lastName, string email)
    {
        Id = Guid.NewGuid();
        FirstName = firstName ?? throw new ArgumentNullException(nameof(firstName));
        LastName = lastName ?? throw new ArgumentNullException(nameof(lastName));
        Email = email ?? throw new ArgumentNullException(nameof(email));
        Status = CustomerStatus.Active;
        CreatedDate = DateTime.UtcNow;
    }

    public void UpdateEmail(string newEmail)
    {
        // Domain logic for email validation
        if (string.IsNullOrWhiteSpace(newEmail))
            throw new DomainException("Email cannot be empty");

        if (!IsValidEmail(newEmail))
            throw new DomainException("Invalid email format");

        Email = newEmail;
    }

    public void Deactivate(string reason)
    {
        if (Status == CustomerStatus.Inactive)
            throw new DomainException("Customer is already inactive");

        Status = CustomerStatus.Inactive;
        // Raise domain event
        RaiseDomainEvent(new CustomerDeactivatedEvent(Id, reason));
    }

    private bool IsValidEmail(string email)
    {
        // Email validation logic
        return email.Contains("@") && email.Contains(".");
    }
}
```

### Value Objects: Descriptive Objects Without Identity

**Value Objects** represent descriptive aspects of the domain that don't require unique identity and are immutable.

```text
Value Object Characteristics:
• No unique identifier
• Immutable (cannot change after creation)
• Equality based on all attributes
• Represents concepts, not things
```

#### Address Value Object Example

```csharp
public class Address : ValueObject
{
    public string Street { get; }
    public string City { get; }
    public string PostalCode { get; }
    public string Country { get; }

    public Address(string street, string city, string postalCode, string country)
    {
        Street = street ?? throw new ArgumentNullException(nameof(street));
        City = city ?? throw new ArgumentNullException(nameof(city));
        PostalCode = postalCode ?? throw new ArgumentNullException(nameof(postalCode));
        Country = country ?? throw new ArgumentNullException(nameof(country));

        ValidateAddress();
    }

    private void ValidateAddress()
    {
        if (string.IsNullOrWhiteSpace(Street))
            throw new DomainException("Street is required");

        if (PostalCode.Length < 3)
            throw new DomainException("Invalid postal code");
    }

    protected override IEnumerable<object> GetAtomicValues()
    {
        yield return Street;
        yield return City;
        yield return PostalCode;
        yield return Country;
    }

    // Value objects can have behavior
    public bool IsInSameCity(Address other)
    {
        return other != null && 
               City.Equals(other.City, StringComparison.OrdinalIgnoreCase) &&
               Country.Equals(other.Country, StringComparison.OrdinalIgnoreCase);
    }
}

// Base class for value objects
public abstract class ValueObject
{
    protected abstract IEnumerable<object> GetAtomicValues();

    public override bool Equals(object obj)
    {
        if (obj == null || obj.GetType() != GetType())
            return false;

        var other = (ValueObject)obj;
        return GetAtomicValues().SequenceEqual(other.GetAtomicValues());
    }

    public override int GetHashCode()
    {
        return GetAtomicValues()
            .Select(x => x?.GetHashCode() ?? 0)
            .Aggregate((x, y) => x ^ y);
    }
}
```

### Aggregates: Consistency Boundaries

**Aggregates** are clusters of entities and value objects that are treated as a single unit for data changes, with clear consistency boundaries.

```text
Aggregate Characteristics:
• One entity serves as the aggregate root
• External access only through the root
• Maintains business invariants
• Transaction boundary
```

#### Order Aggregate Example

```csharp
public class Order : Entity<Guid>, IAggregateRoot
{
    private readonly List<OrderItem> _items = new List<OrderItem>();
    
    public Guid CustomerId { get; private set; }
    public OrderStatus Status { get; private set; }
    public DateTime OrderDate { get; private set; }
    public Address ShippingAddress { get; private set; }
    public Money TotalAmount { get; private set; }

    public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();

    private Order() { } // For ORM

    public Order(Guid customerId, Address shippingAddress)
    {
        Id = Guid.NewGuid();
        CustomerId = customerId;
        ShippingAddress = shippingAddress ?? throw new ArgumentNullException(nameof(shippingAddress));
        Status = OrderStatus.Draft;
        OrderDate = DateTime.UtcNow;
        TotalAmount = Money.Zero();
    }

    public void AddItem(Guid productId, string productName, Money unitPrice, int quantity)
    {
        if (Status != OrderStatus.Draft)
            throw new DomainException("Cannot modify confirmed order");

        if (quantity <= 0)
            throw new DomainException("Quantity must be positive");

        var existingItem = _items.FirstOrDefault(i => i.ProductId == productId);
        if (existingItem != null)
        {
            existingItem.UpdateQuantity(existingItem.Quantity + quantity);
        }
        else
        {
            var newItem = new OrderItem(productId, productName, unitPrice, quantity);
            _items.Add(newItem);
        }

        RecalculateTotal();
    }

    public void RemoveItem(Guid productId)
    {
        if (Status != OrderStatus.Draft)
            throw new DomainException("Cannot modify confirmed order");

        var item = _items.FirstOrDefault(i => i.ProductId == productId);
        if (item != null)
        {
            _items.Remove(item);
            RecalculateTotal();
        }
    }

    public void Confirm()
    {
        if (Status != OrderStatus.Draft)
            throw new DomainException("Order is not in draft status");

        if (!_items.Any())
            throw new DomainException("Cannot confirm empty order");

        Status = OrderStatus.Confirmed;
        RaiseDomainEvent(new OrderConfirmedEvent(Id, CustomerId, TotalAmount));
    }

    private void RecalculateTotal()
    {
        TotalAmount = _items.Sum(item => item.LineTotal);
    }
}

// Order Item (Entity within Order aggregate)
public class OrderItem : Entity<Guid>
{
    public Guid ProductId { get; private set; }
    public string ProductName { get; private set; }
    public Money UnitPrice { get; private set; }
    public int Quantity { get; private set; }
    public Money LineTotal { get; private set; }

    private OrderItem() { } // For ORM

    public OrderItem(Guid productId, string productName, Money unitPrice, int quantity)
    {
        Id = Guid.NewGuid();
        ProductId = productId;
        ProductName = productName ?? throw new ArgumentNullException(nameof(productName));
        UnitPrice = unitPrice ?? throw new ArgumentNullException(nameof(unitPrice));
        UpdateQuantity(quantity);
    }

    public void UpdateQuantity(int newQuantity)
    {
        if (newQuantity <= 0)
            throw new DomainException("Quantity must be positive");

        Quantity = newQuantity;
        LineTotal = UnitPrice.Multiply(newQuantity);
    }
}
```

### Domain Services: Domain Logic That Doesn't Belong in Entities

**Domain Services** encapsulate domain logic that doesn't naturally fit within entities or value objects.

```text
Domain Service Characteristics:
• Stateless operations
• Domain logic that spans multiple aggregates
• Business operations that don't belong to a single entity
• Expressed in terms of domain language
```

#### Pricing Domain Service Example

```csharp
public interface IPricingService
{
    Money CalculateOrderDiscount(Order order, Customer customer);
    bool IsEligibleForPremiumShipping(Customer customer);
}

public class PricingService : IPricingService
{
    private readonly ICustomerRepository _customerRepository;
    private readonly IPromotionRepository _promotionRepository;

    public PricingService(ICustomerRepository customerRepository, IPromotionRepository promotionRepository)
    {
        _customerRepository = customerRepository;
        _promotionRepository = promotionRepository;
    }

    public Money CalculateOrderDiscount(Order order, Customer customer)
    {
        var discount = Money.Zero();

        // Volume discount
        if (order.TotalAmount.Amount > 1000)
        {
            discount = discount.Add(order.TotalAmount.Multiply(0.05m)); // 5% discount
        }

        // Loyalty discount
        if (customer.Status == CustomerStatus.VIP)
        {
            discount = discount.Add(order.TotalAmount.Multiply(0.10m)); // Additional 10%
        }

        // Active promotions
        var activePromotions = _promotionRepository.GetActivePromotions();
        foreach (var promotion in activePromotions)
        {
            if (promotion.IsApplicable(order, customer))
            {
                discount = discount.Add(promotion.CalculateDiscount(order));
            }
        }

        return discount;
    }

    public bool IsEligibleForPremiumShipping(Customer customer)
    {
        // Business logic spanning multiple concerns
        var orderHistory = _customerRepository.GetOrderHistory(customer.Id);
        var totalSpent = orderHistory.Sum(o => o.TotalAmount.Amount);
        var recentOrderCount = orderHistory.Count(o => o.OrderDate > DateTime.UtcNow.AddMonths(-3));

        return customer.Status == CustomerStatus.VIP || 
               totalSpent > 5000 || 
               recentOrderCount >= 5;
    }
}
```

---

## 📊 Repository Pattern in DDD

### Domain Repository Interface

Repositories provide an abstraction for aggregate persistence, defined in the domain layer:

```csharp
public interface IOrderRepository
{
    Task<Order> GetByIdAsync(Guid id);
    Task<IEnumerable<Order>> GetByCustomerIdAsync(Guid customerId);
    Task<Order> AddAsync(Order order);
    Task UpdateAsync(Order order);
    Task DeleteAsync(Guid id);
    
    // Domain-specific queries
    Task<IEnumerable<Order>> GetPendingOrdersAsync();
    Task<bool> HasCustomerPlacedOrdersAsync(Guid customerId);
}

// Implementation in Infrastructure layer
public class OrderRepository : IOrderRepository
{
    private readonly DbContext _context;

    public OrderRepository(DbContext context)
    {
        _context = context;
    }

    public async Task<Order> GetByIdAsync(Guid id)
    {
        return await _context.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id);
    }

    public async Task<Order> AddAsync(Order order)
    {
        _context.Orders.Add(order);
        await _context.SaveChangesAsync();
        return order;
    }

    // Additional implementations...
}
```

---

## 🎯 Domain Events: Decoupled Communication

Domain events capture important business occurrences and enable loose coupling between bounded contexts:

```csharp
public abstract class DomainEvent
{
    public Guid Id { get; }
    public DateTime OccurredOn { get; }

    protected DomainEvent()
    {
        Id = Guid.NewGuid();
        OccurredOn = DateTime.UtcNow;
    }
}

public class OrderConfirmedEvent : DomainEvent
{
    public Guid OrderId { get; }
    public Guid CustomerId { get; }
    public Money TotalAmount { get; }

    public OrderConfirmedEvent(Guid orderId, Guid customerId, Money totalAmount)
    {
        OrderId = orderId;
        CustomerId = customerId;
        TotalAmount = totalAmount;
    }
}

// Event handlers
public class OrderConfirmedEventHandler : INotificationHandler<OrderConfirmedEvent>
{
    private readonly IEmailService _emailService;
    private readonly IInventoryService _inventoryService;

    public async Task Handle(OrderConfirmedEvent notification, CancellationToken cancellationToken)
    {
        // Send confirmation email
        await _emailService.SendOrderConfirmationAsync(notification.CustomerId, notification.OrderId);
        
        // Reserve inventory
        await _inventoryService.ReserveInventoryAsync(notification.OrderId);
        
        // Update customer statistics
        // ... additional business logic
    }
}
```

---

## 🏛️ Strategic DDD: Bounded Contexts

### Defining Bounded Context Boundaries

```text
E-commerce System Bounded Contexts:

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Sales Context │    │Inventory Context│    │Shipping Context │
│                 │    │                 │    │                 │
│ • Customer      │    │ • Product       │    │ • Shipment      │
│ • Order         │    │ • Stock Level   │    │ • Delivery      │
│ • Payment       │    │ • Warehouse     │    │ • Tracking      │
│ • Promotion     │    │ • Supplier      │    │ • Address       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                         Domain Events &
                         Shared Kernel
```

### Context Integration Patterns

#### Shared Kernel Pattern

```csharp
// Shared kernel - common concepts across contexts
public class Money : ValueObject
{
    public decimal Amount { get; }
    public string Currency { get; }

    public Money(decimal amount, string currency = "USD")
    {
        Amount = amount;
        Currency = currency;
    }

    // Shared behavior across all contexts
    public Money Add(Money other) => new Money(Amount + other.Amount, Currency);
    public Money Multiply(decimal factor) => new Money(Amount * factor, Currency);
}
```

#### Anti-Corruption Layer Pattern

```csharp
// Protecting our domain from external system complexity
public interface IExternalPaymentService
{
    Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request);
}

public class PaymentAdapter : IExternalPaymentService
{
    private readonly LegacyPaymentSystem _legacySystem;

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        // Translate our domain model to legacy system format
        var legacyRequest = new LegacyPaymentRequest
        {
            CustomerNumber = request.CustomerId.ToString(),
            AmountInCents = (int)(request.Amount.Amount * 100),
            CurrencyCode = request.Amount.Currency
        };

        var legacyResponse = await _legacySystem.SubmitPayment(legacyRequest);

        // Translate legacy response back to our domain
        return new PaymentResult
        {
            IsSuccessful = legacyResponse.Status == "SUCCESS",
            TransactionId = Guid.Parse(legacyResponse.TransactionRef),
            FailureReason = legacyResponse.ErrorMessage
        };
    }
}
```

---

## 🚨 Common DDD Pitfalls and Solutions

### Pitfall 1: Anemic Domain Model

**Problem**: Entities with only properties and no behavior (data containers).

```csharp
// ❌ Anemic model
public class Order
{
    public Guid Id { get; set; }
    public List<OrderItem> Items { get; set; }
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; }
}

// Business logic scattered in services
public class OrderService
{
    public void AddItem(Order order, OrderItem item)
    {
        order.Items.Add(item);
        order.TotalAmount += item.Price * item.Quantity;
    }
}
```

**Solution**: Rich domain model with encapsulated behavior.

```csharp
// ✅ Rich domain model
public class Order : Entity<Guid>
{
    private readonly List<OrderItem> _items = new List<OrderItem>();
    
    public decimal TotalAmount { get; private set; }
    public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();

    public void AddItem(string productName, decimal price, int quantity)
    {
        if (quantity <= 0)
            throw new DomainException("Quantity must be positive");

        var item = new OrderItem(productName, price, quantity);
        _items.Add(item);
        RecalculateTotal();
    }

    private void RecalculateTotal()
    {
        TotalAmount = _items.Sum(i => i.LineTotal);
    }
}
```

### Pitfall 2: Overly Complex Aggregates

**Problem**: Aggregates that are too large and encompass too many responsibilities.

**Solution**: Keep aggregates small and focused on specific business invariants.

```text
Design Guidelines:
✅ One aggregate = one business invariant
✅ Prefer smaller aggregates over large ones
✅ Use domain events for cross-aggregate communication
❌ Don't include entities that don't need transactional consistency
```

### Pitfall 3: Missing Ubiquitous Language

**Problem**: Technical terms used instead of business language.

```csharp
// ❌ Technical language
public class DataRecord
{
    public void UpdateStatus(int statusCode) { }
}

// ✅ Business language  
public class Order
{
    public void Confirm() { }
    public void Cancel(string reason) { }
    public void Ship() { }
}
```

---

## 🔗 Related Topics

### Prerequisites

- **Object-Oriented Programming**: Understanding of classes, inheritance, and encapsulation
- **SOLID Principles**: Foundation for well-designed domain objects
- **Repository Pattern**: Data access abstraction concepts

### Builds Upon

- **Clean Architecture**: Separating domain from infrastructure concerns
- **Command Query Responsibility Segregation (CQRS)**: Aligns well with DDD aggregates
- **Event-Driven Architecture**: Domain events enable reactive systems

### Enables

- **Microservices Architecture**: Bounded contexts map to service boundaries
- **Event Sourcing**: Complete audit trail of domain changes
- **Complex Business Logic**: Sophisticated domain modeling capabilities

### Cross-References

- [CQRS Command Query Separation](01_CQRS-Command-Query-Separation.md)
- [Clean Architecture Implementation](03_Clean-Architecture-Patterns.md)
- [Microservices Patterns](05_Microservices-Fundamentals.md)

---

## ✅ Next Steps

1. **Practice Modeling**: Take a business domain you know and model it using DDD concepts
2. **Study Bounded Contexts**: Learn to identify natural boundaries in complex systems
3. **Explore Event Sourcing**: Combine DDD with complete event-driven persistence
4. **Apply in Projects**: Implement DDD patterns in real applications

---

**Last Updated**: September 7, 2025  
**Next Review**: December 2025  
**Learning Path**: Software Design Principles → Domain-Driven Design → Event-Driven Architecture
