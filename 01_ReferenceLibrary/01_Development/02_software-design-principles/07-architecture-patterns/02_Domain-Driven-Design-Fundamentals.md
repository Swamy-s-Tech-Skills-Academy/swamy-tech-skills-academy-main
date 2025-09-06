# 02_Domain-Driven-Design-Fundamentals.md

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: SOLID Principles, Clean Architecture, C# OOP fundamentals  
**Estimated Time**: 90-120 minutes

## 🎯 Learning Objectives

By the end of this content, you will:

- **Understand DDD Philosophy**: Grasp the strategic importance of aligning software design with business domains
- **Master Strategic DDD**: Create ubiquitous language, identify bounded contexts, and design context maps
- **Apply Event Storming**: Use collaborative workshops to discover domain knowledge and boundaries
- **Implement Tactical Patterns**: Build entities, value objects, aggregates, and domain services effectively
- **Handle Complex Scenarios**: Apply CQRS, Saga patterns, and event sourcing for sophisticated business processes
- **Avoid Common Pitfalls**: Recognize and prevent anemic domain models and other anti-patterns

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

## � Strategic DDD: Domain Architecture

Strategic DDD focuses on high-level organizational decisions that align software architecture with business strategy. This involves understanding the business domain, identifying boundaries, and structuring the system for maximum business value.

### Ubiquitous Language: Building Shared Understanding

**Ubiquitous Language** is the foundation of successful DDD - a shared vocabulary used consistently by both domain experts and developers throughout the project.

```text
🗣️ Ubiquitous Language in Practice

Business Conversation:
"When a customer places an order, we need to reserve inventory 
and calculate shipping costs before confirming the order."

Code Implementation:
public class Order {
    public void PlaceOrder(Customer customer, IInventoryService inventory, 
                          IShippingCalculator shipping) {
        inventory.ReserveItems(this.Items);
        this.ShippingCost = shipping.CalculateCost(this.DeliveryAddress);
        this.ConfirmOrder();
    }
}
```

#### Key Principles of Ubiquitous Language

- **Consistency**: Same terms used in conversations, documentation, and code
- **Precision**: Avoid ambiguous terms that mean different things to different people
- **Evolution**: Language grows and refines as understanding deepens
- **Domain-Specific**: Each bounded context may have its own language variations

### Domains and Subdomains: Understanding Business Complexity

A **Domain** represents the entire business problem space that the software addresses. **Subdomains** break this complexity into manageable, focused areas.

#### Subdomain Types

```text
📊 Subdomain Classification

Core Subdomain (🎯 High Business Value)
├── Primary differentiator for the business
├── Where competitive advantage is built
├── Deserves the most investment and attention
└── Example: Recommendation algorithm for e-commerce

Supporting Subdomain (🔧 Medium Business Value)
├── Important but not core differentiator
├── Custom solution often needed
├── Supports the core domain
└── Example: User authentication and authorization

Generic Subdomain (⚙️ Low Business Value)
├── Solved problems with existing solutions
├── Buy vs. build decision - usually buy
├── Focus on integration, not innovation
└── Example: Payment processing, email sending
```

#### E-Commerce Platform Example

```csharp
// Core Subdomain: Product Recommendations
namespace ECommerce.Recommendations {
    public class RecommendationEngine {
        public async Task<List<Product>> GetPersonalizedRecommendations(
            CustomerId customerId, 
            CustomerBehavior behavior) {
            // Proprietary algorithm - core business value
            var preferences = await _behaviorAnalyzer.AnalyzePreferences(behavior);
            var recommendations = await _mlModel.PredictRecommendations(customerId, preferences);
            return recommendations.Take(10).ToList();
        }
    }
}

// Supporting Subdomain: Inventory Management
namespace ECommerce.Inventory {
    public class InventoryService {
        public async Task<bool> ReserveItems(List<OrderItem> items) {
            // Custom business logic for inventory rules
            foreach (var item in items) {
                if (!await _stockRepository.HasSufficientStock(item.ProductId, item.Quantity))
                    return false;
            }
            await _stockRepository.ReserveItems(items);
            return true;
        }
    }
}

// Generic Subdomain: Payment Processing
namespace ECommerce.Payments {
    public class PaymentService {
        private readonly IStripePaymentGateway _stripe; // External service
        
        public async Task<PaymentResult> ProcessPayment(PaymentRequest request) {
            // Delegate to external payment provider
            return await _stripe.ChargeAsync(request.Amount, request.Token);
        }
    }
}
```

### Bounded Contexts: Creating Clear Boundaries

**Bounded Contexts** define explicit boundaries within which a domain model applies. Each context has its own ubiquitous language and can evolve independently.

```text
🏛️ Bounded Context Principles

Single Responsibility:
Each context focuses on one specific business capability

Language Boundaries:
Terms may have different meanings across contexts

Model Integrity:
Each context maintains its own consistent domain model

Team Alignment:
Context boundaries often align with team boundaries
```

#### Multi-Context Example: Online Learning Platform

```csharp
// Student Management Context
namespace LearningPlatform.StudentManagement {
    public class Student {
        public StudentId Id { get; private set; }
        public string FullName { get; private set; }
        public Email ContactEmail { get; private set; }
        public EnrollmentStatus Status { get; private set; }
        
        public void EnrollInCourse(CourseId courseId) {
            // Student management business logic
        }
    }
}

// Course Delivery Context
namespace LearningPlatform.CourseDelivery {
    public class Learner {  // Same person, different perspective
        public LearnerId Id { get; private set; }
        public LearningProgress Progress { get; private set; }
        public List<CompletedAssignment> Assignments { get; private set; }
        
        public void CompleteLesson(LessonId lessonId) {
            // Learning progression business logic
        }
    }
}

// Assessment Context
namespace LearningPlatform.Assessment {
    public class Candidate {  // Same person, assessment perspective
        public CandidateId Id { get; private set; }
        public List<ExamResult> ExamHistory { get; private set; }
        public CertificationLevel CurrentLevel { get; private set; }
        
        public void TakeAssessment(AssessmentId assessmentId) {
            // Assessment and certification logic
        }
    }
}
```

### Context Maps: Managing Bounded Context Relationships

**Context Maps** visualize how bounded contexts interact and depend on each other, helping teams coordinate integration strategies.

#### Integration Patterns

```text
🔗 Context Integration Patterns

Shared Kernel (⚠️ Use Cautiously)
├── Common code/models shared between contexts
├── Requires tight coordination between teams
└── Example: Shared user identity across contexts

Anti-Corruption Layer (🛡️ Recommended)
├── Translation layer protecting domain integrity
├── Isolates context from external system changes
└── Example: Legacy system integration wrapper

Published Language (📢 Event-Driven)
├── Well-defined interface for context communication
├── Often implemented as domain events
└── Example: "StudentEnrolled" event published by Student context

Customer-Supplier (🤝 Team Coordination)
├── Upstream context provides services to downstream
├── Requires collaboration on interface changes
└── Example: Course Catalog → Course Delivery relationship
```

#### Context Map Implementation

```csharp
// Anti-Corruption Layer Example
namespace LearningPlatform.StudentManagement.Infrastructure {
    public class LegacyUserSystemAdapter : IUserRepository {
        private readonly ILegacyUserApi _legacyApi;
        
        public async Task<Student> GetStudentAsync(StudentId id) {
            // Translate between legacy format and domain model
            var legacyUser = await _legacyApi.GetUser(id.Value);
            
            return new Student(
                new StudentId(legacyUser.UserId),
                legacyUser.FirstName + " " + legacyUser.LastName,
                new Email(legacyUser.EmailAddress),
                MapToEnrollmentStatus(legacyUser.Status)
            );
        }
        
        private EnrollmentStatus MapToEnrollmentStatus(string legacyStatus) {
            // Protect domain from legacy system's data representation
            return legacyStatus switch {
                "ACTIVE" => EnrollmentStatus.Active,
                "SUSPENDED" => EnrollmentStatus.Suspended,
                "GRADUATED" => EnrollmentStatus.Completed,
                _ => EnrollmentStatus.Inactive
            };
        }
    }
}

// Published Language with Domain Events
namespace LearningPlatform.StudentManagement.Events {
    public class StudentEnrolledEvent : DomainEvent {
        public StudentId StudentId { get; }
        public CourseId CourseId { get; }
        public DateTime EnrollmentDate { get; }
        
        public StudentEnrolledEvent(StudentId studentId, CourseId courseId) {
            StudentId = studentId;
            CourseId = courseId;
            EnrollmentDate = DateTime.UtcNow;
        }
    }
}

// Event Handler in Course Delivery Context
namespace LearningPlatform.CourseDelivery.Handlers {
    public class StudentEnrolledEventHandler : IEventHandler<StudentEnrolledEvent> {
        public async Task HandleAsync(StudentEnrolledEvent @event) {
            // Create learner profile in course delivery context
            var learner = new Learner(@event.StudentId.Value, @event.CourseId);
            await _learnerRepository.SaveAsync(learner);
            
            // Send welcome message
            await _messageService.SendWelcomeMessageAsync(learner.Id);
        }
    }
}
```

---

## � Event Storming: Discovering Domain Knowledge

**Event Storming** is a workshop technique for rapidly exploring complex business domains and discovering the events, commands, and aggregates that form your domain model.

### Event Storming Process

```text
📝 Event Storming Workshop Flow

1. Domain Events Discovery (🟠 Orange Stickies)
   ├── Past tense verbs: "OrderPlaced", "PaymentProcessed"
   ├── Business-significant occurrences
   └── No technical implementation details

2. Event Ordering & Timing
   ├── Arrange events on timeline
   ├── Identify parallel vs. sequential events
   └── Spot missing events or gaps

3. Commands Discovery (🔵 Blue Stickies)
   ├── Present tense actions: "PlaceOrder", "ProcessPayment"
   ├── User intentions that trigger events
   └── Map command → event relationships

4. Aggregates Identification (🟡 Yellow Stickies)
   ├── Entities that handle commands
   ├── Groups of related events
   └── Transaction boundaries

5. External Systems (🟣 Purple Stickies)
   ├── Integration points
   ├── Third-party services
   └── Data sources

6. Bounded Context Boundaries
   ├── Group related events/aggregates
   ├── Identify handoff points
   └── Define context interfaces
```

### E-Commerce Event Storming Example

```text
🛒 E-Commerce Order Processing Timeline

Commands:        Events:                    Aggregates:       External Systems:
AddToCart  →     ItemAddedToCart           ShoppingCart      ProductCatalog
           →     CartUpdated                                 
           
PlaceOrder →     OrderPlaced               Order             PaymentGateway
           →     InventoryReserved         Inventory         ShippingProvider
           →     PaymentAuthorized                           EmailService
           
ProcessOrder →   OrderConfirmed            Order            
             →   ShippingLabelCreated      Shipment         
             →   CustomerNotified                           
             
ShipOrder →      OrderShipped              Shipment         
          →      TrackingNumberGenerated                    
          →      ShippingNotificationSent                   
```

### From Event Storming to Code

Event Storming discoveries directly inform your tactical DDD implementation:

```csharp
// Domain Events discovered in workshop
namespace ECommerce.Orders.Events {
    public class OrderPlacedEvent : DomainEvent {
        public OrderId OrderId { get; }
        public CustomerId CustomerId { get; }
        public List<OrderLineItem> Items { get; }
        public Money TotalAmount { get; }
        public DateTime PlacedAt { get; }
    }
    
    public class PaymentAuthorizedEvent : DomainEvent {
        public OrderId OrderId { get; }
        public PaymentId PaymentId { get; }
        public Money AuthorizedAmount { get; }
        public string AuthorizationCode { get; }
    }
}

// Aggregates identified in workshop
namespace ECommerce.Orders.Domain {
    public class Order : AggregateRoot {
        private List<OrderLineItem> _items = new();
        private OrderStatus _status;
        
        // Commands discovered in workshop
        public void PlaceOrder(CustomerId customerId, List<OrderLineItem> items) {
            ValidateOrderPlacement(items);
            
            _customerId = customerId;
            _items = items;
            _status = OrderStatus.Placed;
            _totalAmount = CalculateTotal(items);
            
            // Raise event discovered in workshop
            RaiseDomainEvent(new OrderPlacedEvent(Id, customerId, items, _totalAmount, DateTime.UtcNow));
        }
        
        public void AuthorizePayment(PaymentId paymentId, string authorizationCode) {
            if (_status != OrderStatus.Placed)
                throw new InvalidOperationException("Order must be placed before payment authorization");
                
            _paymentId = paymentId;
            _status = OrderStatus.PaymentAuthorized;
            
            RaiseDomainEvent(new PaymentAuthorizedEvent(Id, paymentId, _totalAmount, authorizationCode));
        }
    }
}
```

---

## �🏗️ Tactical DDD: Implementation Patterns

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

## � Advanced DDD Patterns

### CQRS (Command Query Responsibility Segregation)

CQRS separates read and write operations, allowing optimization for each concern independently.

```csharp
// Command Side (Write Model)
namespace ECommerce.Orders.Commands {
    public class PlaceOrderCommand {
        public CustomerId CustomerId { get; set; }
        public List<OrderLineItem> Items { get; set; }
        public ShippingAddress DeliveryAddress { get; set; }
    }
    
    public class PlaceOrderHandler : ICommandHandler<PlaceOrderCommand> {
        private readonly IOrderRepository _orderRepository;
        private readonly IDomainEventPublisher _eventPublisher;
        
        public async Task HandleAsync(PlaceOrderCommand command) {
            var order = new Order(command.CustomerId, command.Items, command.DeliveryAddress);
            await _orderRepository.SaveAsync(order);
            
            // Publish domain events for eventual consistency
            await _eventPublisher.PublishAsync(order.GetDomainEvents());
        }
    }
}

// Query Side (Read Model)
namespace ECommerce.Orders.Queries {
    public class OrderSummaryQuery {
        public CustomerId CustomerId { get; set; }
        public DateRange DateRange { get; set; }
    }
    
    public class OrderSummaryQueryHandler : IQueryHandler<OrderSummaryQuery, List<OrderSummaryView>> {
        private readonly IOrderReadModelRepository _readRepository;
        
        public async Task<List<OrderSummaryView>> HandleAsync(OrderSummaryQuery query) {
            // Optimized for reading - denormalized data
            return await _readRepository.GetOrderSummariesAsync(
                query.CustomerId, 
                query.DateRange
            );
        }
    }
    
    public class OrderSummaryView {
        public OrderId OrderId { get; set; }
        public string OrderNumber { get; set; }
        public DateTime PlacedDate { get; set; }
        public string StatusDisplay { get; set; }
        public decimal TotalAmount { get; set; }
        public string CustomerName { get; set; }  // Denormalized for efficiency
        public List<string> ProductNames { get; set; }  // Denormalized
    }
}
```

### Saga Pattern for Long-Running Processes

Sagas coordinate complex business processes across multiple bounded contexts and aggregates.

```csharp
// Order Processing Saga
namespace ECommerce.Sagas {
    public class OrderProcessingSaga : Saga,
        IHandleEvent<OrderPlacedEvent>,
        IHandleEvent<PaymentAuthorizedEvent>,
        IHandleEvent<PaymentFailedEvent> {
        
        public OrderId OrderId { get; set; }
        public SagaState State { get; set; }
        public List<string> CompletedSteps { get; set; } = new();
        
        public async Task HandleAsync(OrderPlacedEvent @event) {
            OrderId = @event.OrderId;
            State = SagaState.Started;
            
            // Start parallel processes
            await SendCommandAsync(new AuthorizePaymentCommand(@event.OrderId, @event.TotalAmount));
            await SendCommandAsync(new ReserveInventoryCommand(@event.OrderId, @event.Items));
        }
        
        public async Task HandleAsync(PaymentAuthorizedEvent @event) {
            CompletedSteps.Add("PaymentAuthorized");
            
            if (CompletedSteps.Contains("InventoryReserved")) {
                await CompleteOrderProcessingAsync();
            }
        }
        
        public async Task HandleAsync(PaymentFailedEvent @event) {
            // Compensate: Release inventory if already reserved
            if (CompletedSteps.Contains("InventoryReserved")) {
                await SendCommandAsync(new ReleaseInventoryCommand(OrderId));
            }
            
            await SendCommandAsync(new CancelOrderCommand(OrderId, "Payment failed"));
            State = SagaState.Failed;
            MarkAsComplete();
        }
        
        private async Task CompleteOrderProcessingAsync() {
            await SendCommandAsync(new ConfirmOrderCommand(OrderId));
            State = SagaState.Completed;
            MarkAsComplete();
        }
    }
}
```

### Common Pitfalls and Best Practices

#### 🚫 Anti-Patterns to Avoid

```csharp
// ❌ Anemic Domain Model
public class BadOrder {
    public Guid Id { get; set; }
    public decimal Total { get; set; }
    public List<OrderItem> Items { get; set; }
    // No business logic - just data container
}

public class OrderService {  // All logic in service
    public void AddItem(BadOrder order, OrderItem item) {
        order.Items.Add(item);
        order.Total += item.Price * item.Quantity;
    }
}

// ✅ Rich Domain Model
public class GoodOrder {
    private readonly List<OrderItem> _items = new();
    
    public void AddItem(OrderItem item) {
        ValidateItemCanBeAdded(item);  // Business rules in domain
        _items.Add(item);
        RecalculateTotal();
        RaiseDomainEvent(new ItemAddedToOrderEvent(Id, item));
    }
}
```

#### 🎯 Best Practices

1. **Keep Aggregates Small**: Large aggregates lead to performance and concurrency issues
2. **Use Domain Events**: Decouple bounded contexts through eventual consistency
3. **Protect Invariants**: Aggregate roots must ensure business rule consistency
4. **Model Explicit State**: Use enums and value objects instead of primitive obsession

---

## �🔗 Related Topics

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
