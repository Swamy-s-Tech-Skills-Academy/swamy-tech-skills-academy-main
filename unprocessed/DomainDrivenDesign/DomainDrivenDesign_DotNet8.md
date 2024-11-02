# Domain-Driven Design (DDD)

## Domain-Driven Design Overview

Domain-Driven Design (DDD) is a software design approach that focuses on modeling software to reflect complex business domains. DDD emphasizes collaboration between domain experts and developers, ensuring that the domain model accurately represents real-world business logic. The core of DDD is creating software that mirrors the behaviors, rules, and entities within a specific business domain.

### Key Principles

1. **Ubiquitous Language**: A shared language used by developers, domain experts, and stakeholders to ensure clarity and consistency.
2. **Bounded Contexts**: Segments of the domain where specific terms and rules apply, providing clear boundaries to the domain model.
3. **Entities**: Objects that have a unique identity throughout their lifecycle.
4. **Value Objects**: Immutable objects that describe characteristics of an entity.
5. **Aggregates**: A group of related entities bound together by a root entity, ensuring consistency within the group.
6. **Repositories**: Abstractions for managing and retrieving domain objects.
7. **Services**: Operations that don't naturally fit into an entity or value object.
8. **Domain Events**: Notifications about changes in the state of the domain that are important to external systems or processes.

---

## Solution Layout

A typical solution layout for Domain-Driven Design in C#/.NET 8:

```text
Solution.sln
├── Solution.Domain              // Domain Layer (Entities, Value Objects, Aggregates, Events)
├── Solution.Application         // Application Layer (Services, Use Cases)
├── Solution.Infrastructure      // Infrastructure Layer (Data Access, Repositories)
├── Solution.WebAPI              // Presentation Layer (Controllers, API)
└── Solution.SharedKernel        // Shared Kernel (Common utilities, Domain Events, etc.)
```

---

### Overview of Layers

#### **Domain Layer** (`Solution.Domain`)

- **Purpose**: This is the core of the business logic, representing the domain model. It should be rich in business rules and agnostic of technical concerns.
- **Components**:
  - **Entities**: Objects with unique identities, such as `Customer`, `Order`.
  - **Value Objects**: Immutable objects such as `Money`, `Address` that describe domain characteristics.
  - **Aggregates**: Groupings of entities under a single root entity. For example, `Order` can be an aggregate root that contains `OrderItems`.
  - **Domain Events**: Events representing important changes or actions in the domain.
  - **Repositories Interfaces**: Abstractions for accessing aggregates from the persistence store (e.g., `ICustomerRepository`).
- **Dependencies**: This layer is independent of other layers. It defines the heart of the business logic.

#### **Application Layer** (`Solution.Application`)

- **Purpose**: Orchestrates the flow of data to and from the domain objects. It contains business logic for application services and use cases but does not implement domain rules.
- **Components**:
  - **Use Cases**: Coordinate the application's workflow and delegate actions to domain objects.
  - **Services**: Application-specific services, often performing cross-cutting concerns (e.g., sending emails or logging).
  - **DTOs**: Data Transfer Objects that pass data between the layers.
- **Dependencies**: It depends on the Domain Layer.

#### **Infrastructure Layer** (`Solution.Infrastructure`)

- **Purpose**: Deals with the technical aspects of data persistence, external service integration, and infrastructure-related configurations.
- **Components**:
  - **Repositories Implementations**: Concrete implementations of the repository interfaces declared in the domain.
  - **External Services**: APIs, external messaging services, and file storage are implemented here.
  - **Persistence**: Database connections and configurations (e.g., Entity Framework).
- **Dependencies**: Depends on the Domain Layer and Application Layer.

#### **Presentation Layer** (`Solution.WebAPI`)

- **Purpose**: Exposes the application’s functionalities via a user interface, typically an ASP.NET Core Web API or MVC application. This layer should only contain presentation logic and leave business logic to the application or domain layer.
- **Components**:
  - **Controllers**: Handle HTTP requests and delegate business logic to the application layer.
  - **ViewModels**: Present data to the user or the API consumers.
- **Dependencies**: Depends on the Application Layer.

#### **Shared Kernel** (`Solution.SharedKernel`)

- **Purpose**: Contains reusable components shared across the domain or other bounded contexts.
- **Components**:
  - **Common Utilities**: Helper functions and utilities used across the solution.
  - **Domain Events**: Events of interest across multiple contexts.
  - **Value Objects**: Shared value objects across contexts (e.g., `Address`).

---

### Bounded Contexts

A key part of DDD is breaking down the domain into **Bounded Contexts**, which encapsulate a part of the domain with its own distinct language, rules, and behavior. For example, in an e-commerce system, separate contexts may include:

- **Ordering** (Handling customer orders)
- **Billing** (Managing payments and invoices)
- **Shipping** (Handling delivery logistics)

Each context operates independently and has its own entities, services, and repositories, allowing changes in one context without affecting the others.

---

### Example: Entity, Value Object, and Aggregate

```csharp
// Value Object
public class Money
{
    public decimal Amount { get; }
    public string Currency { get; }

    public Money(decimal amount, string currency)
    {
        Amount = amount;
        Currency = currency;
    }
}

// Entity
public class Product
{
    public Guid Id { get; private set; }
    public string Name { get; private set; }
    public Money Price { get; private set; }

    public Product(Guid id, string name, Money price)
    {
        Id = id;
        Name = name;
        Price = price;
    }
}

// Aggregate Root
public class Order
{
    public Guid Id { get; private set; }
    public List<OrderItem> Items { get; private set; } = new();

    public void AddItem(Product product, int quantity)
    {
        var orderItem = new OrderItem(product, quantity);
        Items.Add(orderItem);
    }
}
```

---

### Conclusion

Domain-Driven Design fosters a strong relationship between the codebase and the business, promoting clear boundaries, rich models, and business-driven logic. By focusing on the domain and dividing the solution into layers and bounded contexts, DDD helps deliver software that is both maintainable and scalable.
