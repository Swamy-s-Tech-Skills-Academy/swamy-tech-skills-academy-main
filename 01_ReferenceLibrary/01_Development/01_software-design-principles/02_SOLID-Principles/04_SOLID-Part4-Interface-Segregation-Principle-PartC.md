# 04_SOLID-Part4-Interface-Segregation-Principle - Part C

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Liskov Substitution Principle (Part 3), Interface design patterns  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Interface Segregation Principle (ISP) and its client-focused design approach

## Part C of 4

Previous: [04_SOLID-Part4-Interface-Segregation-Principle-PartB.md](04_SOLID-Part4-Interface-Segregation-Principle-PartB.md)
Next: [04_SOLID-Part4-Interface-Segregation-Principle-PartD.md](04_SOLID-Part4-Interface-Segregation-Principle-PartD.md)

---

    }
    
    public async Task`UserProfile` GetProfileAsync(int userId)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        return new UserProfile
        {
            Name = user.Name,
            Email = user.Email,
            LastLogin = user.LastLogin
        };
    }
}

public class UserManagementService
{
    private readonly IUserRepository _userRepository; // Full access when needed

    public UserManagementService(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }
    
    public async Task`User` CreateUserAsync(CreateUserRequest request)
    {
        var existingUser = await _userRepository.GetByEmailAsync(request.Email);
        if (existingUser != null)
            throw new InvalidOperationException("User already exists");
            
        var user = new User
        {
            Name = request.Name,
            Email = request.Email,
            CreatedAt = DateTime.UtcNow
        };
        
        return await _userRepository.CreateAsync(user);
    }
}

```text

##### Query vs Command Segregation

```csharp
// Separate query and command interfaces
public interface IOrderQueries
{
    Task`Order` GetByIdAsync(int orderId);
    Task`IEnumerable<Order`> GetByCustomerIdAsync(int customerId);
    Task`OrderSummary` GetSummaryAsync(int orderId);
    Task`IEnumerable<Order`> GetPendingOrdersAsync();
}

public interface IOrderCommands
{
    Task`int` CreateOrderAsync(CreateOrderCommand command);
    Task UpdateOrderStatusAsync(int orderId, OrderStatus status);
    Task CancelOrderAsync(int orderId, string reason);
    Task AddItemAsync(int orderId, OrderItem item);
}

// Reporting service only needs queries
public class OrderReportingService
{
    private readonly IOrderQueries _orderQueries;
    
    public OrderReportingService(IOrderQueries orderQueries)
    {
        _orderQueries = orderQueries;
    }
    
    public async Task`MonthlyReport` GenerateMonthlyReportAsync(int year, int month)
    {
        var orders = await _orderQueries.GetOrdersByMonthAsync(year, month);
        return new MonthlyReport
        {
            TotalOrders = orders.Count(),
            TotalRevenue = orders.Sum(o => o.Total),
            AverageOrderValue = orders.Average(o => o.Total)
        };
    }
}

// Order processing needs both queries and commands
public class OrderProcessingService
{
    private readonly IOrderQueries _orderQueries;
    private readonly IOrderCommands _orderCommands;
    
    public OrderProcessingService(IOrderQueries orderQueries, IOrderCommands orderCommands)
    {
        _orderQueries = orderQueries;
        _orderCommands = orderCommands;
    }
    
    public async Task ProcessOrderAsync(int orderId)
    {
        var order = await _orderQueries.GetByIdAsync(orderId);
        if (order == null)
            throw new InvalidOperationException("Order not found");
            
        if (order.Status != OrderStatus.Pending)
            throw new InvalidOperationException("Order is not in pending status");
            
        // Process payment, inventory, etc.
        await _orderCommands.UpdateOrderStatusAsync(orderId, OrderStatus.Processing);
    }
}
```text

### Practical Implementation (8 minutes)

#### ISP Implementation Strategies

##### Strategy 1: Interface Composition

```csharp
// Build complex interfaces from simple ones
public interface IBasicCrud`T`
{
    Task`T` GetByIdAsync(int id);
}

public interface ICreatable`T`
{
    Task`T` CreateAsync(T entity);
}

public interface IUpdatable`T`
{
    Task UpdateAsync(T entity);
}

public interface IDeletable
{
    Task DeleteAsync(int id);
}

public interface ISearchable`T`
{
    Task`IEnumerable<T`> SearchAsync(string criteria);
}

// Compose interfaces based on actual needs
public interface IReadOnlyRepository`T` : IBasicCrud`T`, ISearchable`T`
{
    // Read-only operations
}

public interface IFullRepository`T` : IReadOnlyRepository`T`, ICreatable`T`, IUpdatable`T`, IDeletable
{
    // Full CRUD operations
}


