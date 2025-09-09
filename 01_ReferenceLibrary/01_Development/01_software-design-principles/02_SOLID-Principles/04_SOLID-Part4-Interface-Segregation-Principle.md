# 04_SOLID-Part4-Interface-Segregation-Principle

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Liskov Substitution Principle (Part 3), Interface design patterns  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Interface Segregation Principle (ISP) and its client-focused design approach
- Identify "fat interfaces" that violate ISP and create unnecessary dependencies
- Design cohesive, focused interfaces using role-based segregation
- Implement ISP patterns that improve testability and maintainability

## 📋 Content Sections

### Quick Overview (5 minutes)

**Interface Segregation Principle (ISP)**: *"Clients should not be forced to depend on interfaces they do not use."*

```text
❌ ISP VIOLATION: Fat Interface Forces Unnecessary Dependencies
┌─────────────────────────────────────────────────────────────┐
│                    IWorker (Fat Interface)                 │
├─────────────────────────────────────────────────────────────┤
│ + Work()                                                    │
│ + Eat()              ← Human workers need this             │  
│ + Sleep()            ← Human workers need this             │
│ + Recharge()         ← Robot workers need this             │
│ + UpdateFirmware()   ← Robot workers need this             │
└─────────────────────────────────────────────────────────────┘
         ↑                                    ↑
    ┌─────────┐                         ┌─────────┐
    │ Human   │                         │ Robot   │
    │ Worker  │                         │ Worker  │
    └─────────┘                         └─────────┘
   Implements                         Implements
   methods it                         methods it
   doesn't need                       doesn't need

✅ ISP COMPLIANT: Segregated, Role-Based Interfaces
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  IWorker    │  │ IBiological │  │ IMechanical │
├─────────────┤  ├─────────────┤  ├─────────────┤  
│ + Work()    │  │ + Eat()     │  │ + Recharge()│
└─────────────┘  │ + Sleep()   │  │ + Update()  │
                 └─────────────┘  └─────────────┘
       ↑               ↑                ↑
    ┌──┴──┐        ┌───┴───┐      ┌─────┴─────┐
    │Human│        │Human  │      │   Robot   │
    │     │←──────→│Needs  │      │  Worker   │
    └─────┘        └───────┘      └───────────┘
```

**ISP Key Benefits**:

- **Reduced Coupling**: Clients depend only on methods they actually use
- **Easier Testing**: Mock only the interfaces relevant to the test
- **Better Maintainability**: Changes to unused methods don't affect clients
- **Clearer Intent**: Interface purpose is immediately obvious

### Core Concepts (15 minutes)

#### Identifying Fat Interfaces

##### Classic Violation Example: Multi-Function Device

```csharp
// ❌ BAD: Fat interface violates ISP
public interface IMultiFunctionDevice
{
    // Printing functionality
    void Print(Document document);
    void SetPrintQuality(PrintQuality quality);
    
    // Scanning functionality
    byte[] Scan(ScanSettings settings);
    void CalibrateScanner();
    
    // Fax functionality
    void SendFax(string number, Document document);
    void ReceiveFax();
    
    // Copy functionality
    void Copy(int copies);
    void SetCopyOptions(CopyOptions options);
    
    // Internet functionality
    void SendEmail(EmailMessage message);
    void BrowseWeb(string url);
}

// Problems with implementations
public class BasicPrinter : IMultiFunctionDevice
{
    public void Print(Document document)
    {
        // Actual implementation
        Console.WriteLine($"Printing: {document.Title}");
    }
    
    public void SetPrintQuality(PrintQuality quality)
    {
        // Actual implementation
        Console.WriteLine($"Print quality set to: {quality}");
    }
    
    // ❌ Forced to implement methods it doesn't support
    public byte[] Scan(ScanSettings settings)
    {
        throw new NotSupportedException("BasicPrinter doesn't support scanning");
    }
    
    public void CalibrateScanner()
    {
        throw new NotSupportedException("BasicPrinter doesn't have a scanner");
    }
    
    public void SendFax(string number, Document document)
    {
        throw new NotSupportedException("BasicPrinter doesn't support fax");
    }
    
    public void ReceiveFax()
    {
        throw new NotSupportedException("BasicPrinter doesn't support fax");
    }
    
    // ... More NotSupportedException methods
}

// Client forced to handle exceptions for features it doesn't use
public class PrintService
{
    private readonly IMultiFunctionDevice _device;
    
    public PrintService(IMultiFunctionDevice device)
    {
        _device = device;
    }
    
    public void PrintDocument(Document document)
    {
        try
        {
            _device.Print(document); // Only needs printing, but interface includes everything
        }
        catch (NotSupportedException ex)
        {
            // Shouldn't need to handle this if interface was properly designed
            throw new InvalidOperationException("Device doesn't support printing", ex);
        }
    }
}
```

#### ISP-Compliant Solution: Interface Segregation

```csharp
// ✅ GOOD: Segregated interfaces based on client needs
public interface IPrinter
{
    void Print(Document document);
    void SetPrintQuality(PrintQuality quality);
}

public interface IScanner
{
    byte[] Scan(ScanSettings settings);
    void CalibrateScanner();
}

public interface IFaxMachine
{
    void SendFax(string number, Document document);
    void ReceiveFax();
}

public interface ICopier
{
    void Copy(int copies);
    void SetCopyOptions(CopyOptions options);
}

public interface INetworkDevice
{
    void SendEmail(EmailMessage message);
    void BrowseWeb(string url);
}

// Implementations only implement what they actually support
public class BasicPrinter : IPrinter
{
    public void Print(Document document)
    {
        Console.WriteLine($"Printing: {document.Title}");
    }
    
    public void SetPrintQuality(PrintQuality quality)
    {
        Console.WriteLine($"Print quality set to: {quality}");
    }
}

public class MultiFunctionDevice : IPrinter, IScanner, ICopier, IFaxMachine
{
    public void Print(Document document)
    {
        Console.WriteLine($"MFD Printing: {document.Title}");
    }
    
    public void SetPrintQuality(PrintQuality quality)
    {
        Console.WriteLine($"MFD Print quality: {quality}");
    }
    
    public byte[] Scan(ScanSettings settings)
    {
        Console.WriteLine($"MFD Scanning with settings: {settings}");
        return new byte[0]; // Simulated scan data
    }
    
    public void CalibrateScanner()
    {
        Console.WriteLine("MFD Scanner calibrated");
    }
    
    public void Copy(int copies)
    {
        Console.WriteLine($"MFD Making {copies} copies");
    }
    
    public void SetCopyOptions(CopyOptions options)
    {
        Console.WriteLine($"MFD Copy options set: {options}");
    }
    
    public void SendFax(string number, Document document)
    {
        Console.WriteLine($"MFD Sending fax to {number}: {document.Title}");
    }
    
    public void ReceiveFax()
    {
        Console.WriteLine("MFD Ready to receive fax");
    }
}

// Clean, focused client code
public class PrintService
{
    private readonly IPrinter _printer;
    
    public PrintService(IPrinter printer) // Only depends on what it needs
    {
        _printer = printer;
    }
    
    public void PrintDocument(Document document)
    {
        _printer.Print(document); // No exception handling needed
    }
    
    public void ConfigurePrinting(PrintQuality quality)
    {
        _printer.SetPrintQuality(quality);
    }
}

public class ScanService
{
    private readonly IScanner _scanner;
    
    public ScanService(IScanner scanner) // Only depends on scanning capability
    {
        _scanner = scanner;
    }
    
    public byte[] ScanDocument(ScanSettings settings)
    {
        return _scanner.Scan(settings);
    }
}
```

#### Advanced ISP Patterns

##### Role-Based Interface Design

```csharp
// Define interfaces based on roles/responsibilities
public interface IReadOnlyUserRepository
{
    Task<User> GetByIdAsync(int id);
    Task<User> GetByEmailAsync(string email);
    Task<IEnumerable<User>> SearchAsync(string criteria);
}

public interface IUserWriter
{
    Task<User> CreateAsync(User user);
    Task UpdateAsync(User user);
    Task DeleteAsync(int id);
}

public interface IUserRepository : IReadOnlyUserRepository, IUserWriter
{
    // Combines both roles for full-featured repository
}

// Specialized services only depend on what they need
public class UserProfileService
{
    private readonly IReadOnlyUserRepository _userRepository; // Read-only dependency
    
    public UserProfileService(IReadOnlyUserRepository userRepository)
    {
        _userRepository = userRepository;
    }
    
    public async Task<UserProfile> GetProfileAsync(int userId)
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
    
    public async Task<User> CreateUserAsync(CreateUserRequest request)
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
```

##### Query vs Command Segregation

```csharp
// Separate query and command interfaces
public interface IOrderQueries
{
    Task<Order> GetByIdAsync(int orderId);
    Task<IEnumerable<Order>> GetByCustomerIdAsync(int customerId);
    Task<OrderSummary> GetSummaryAsync(int orderId);
    Task<IEnumerable<Order>> GetPendingOrdersAsync();
}

public interface IOrderCommands
{
    Task<int> CreateOrderAsync(CreateOrderCommand command);
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
    
    public async Task<MonthlyReport> GenerateMonthlyReportAsync(int year, int month)
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
```

### Practical Implementation (8 minutes)

#### ISP Implementation Strategies

##### Strategy 1: Interface Composition

```csharp
// Build complex interfaces from simple ones
public interface IBasicCrud<T>
{
    Task<T> GetByIdAsync(int id);
}

public interface ICreatable<T>
{
    Task<T> CreateAsync(T entity);
}

public interface IUpdatable<T>
{
    Task UpdateAsync(T entity);
}

public interface IDeletable
{
    Task DeleteAsync(int id);
}

public interface ISearchable<T>
{
    Task<IEnumerable<T>> SearchAsync(string criteria);
}

// Compose interfaces based on actual needs
public interface IReadOnlyRepository<T> : IBasicCrud<T>, ISearchable<T>
{
    // Read-only operations
}

public interface IFullRepository<T> : IReadOnlyRepository<T>, ICreatable<T>, IUpdatable<T>, IDeletable
{
    // Full CRUD operations
}

// Client chooses appropriate interface level
public class ProductCatalogService
{
    private readonly IReadOnlyRepository<Product> _productRepository;
    
    public ProductCatalogService(IReadOnlyRepository<Product> productRepository)
    {
        _productRepository = productRepository; // Only needs read operations
    }
    
    public async Task<ProductCatalog> GetCatalogAsync(string category)
    {
        var products = await _productRepository.SearchAsync($"category:{category}");
        return new ProductCatalog { Products = products.ToList() };
    }
}
```

##### Strategy 2: Capability-Based Interfaces

```csharp
// Define interfaces based on specific capabilities
public interface IValidatable
{
    ValidationResult Validate();
}

public interface ISerializable
{
    string Serialize();
    void Deserialize(string data);
}

public interface IAuditable
{
    void RecordAccess(string user, DateTime timestamp);
    IEnumerable<AuditEntry> GetAuditTrail();
}

public interface ICacheable
{
    string GetCacheKey();
    TimeSpan GetCacheDuration();
}

// Entities implement only relevant capabilities
public class Order : IValidatable, IAuditable
{
    public int Id { get; set; }
    public DateTime OrderDate { get; set; }
    public List<OrderItem> Items { get; set; }
    
    public ValidationResult Validate()
    {
        var result = new ValidationResult();
        
        if (Items == null || Items.Count == 0)
            result.AddError("Order must have at least one item");
            
        return result;
    }
    
    public void RecordAccess(string user, DateTime timestamp)
    {
        // Record audit information
    }
    
    public IEnumerable<AuditEntry> GetAuditTrail()
    {
        // Return audit entries
        return new List<AuditEntry>();
    }
}

public class User : ISerializable, ICacheable
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
    
    public string Serialize()
    {
        return System.Text.Json.JsonSerializer.Serialize(this);
    }
    
    public void Deserialize(string data)
    {
        var user = System.Text.Json.JsonSerializer.Deserialize<User>(data);
        Id = user.Id;
        Name = user.Name;
        Email = user.Email;
    }
    
    public string GetCacheKey() => $"user:{Id}";
    
    public TimeSpan GetCacheDuration() => TimeSpan.FromMinutes(30);
}

// Services work with specific capabilities
public class ValidationService
{
    public bool IsValid<T>(T entity) where T : IValidatable
    {
        return entity.Validate().IsValid;
    }
}

public class CacheService
{
    private readonly IMemoryCache _cache;
    
    public CacheService(IMemoryCache cache)
    {
        _cache = cache;
    }
    
    public void CacheEntity<T>(T entity) where T : ICacheable
    {
        _cache.Set(entity.GetCacheKey(), entity, entity.GetCacheDuration());
    }
    
    public T GetFromCache<T>(string key) where T : class
    {
        return _cache.Get<T>(key);
    }
}
```

#### Testing with ISP

```csharp
// ISP makes testing much simpler
public class OrderServiceTests
{
    [Test]
    public async Task ProcessOrder_ValidOrder_ShouldUpdateStatus()
    {
        // Arrange - only mock what the service actually uses
        var mockOrderQueries = new Mock<IOrderQueries>();
        var mockOrderCommands = new Mock<IOrderCommands>();
        
        var order = new Order { Id = 1, Status = OrderStatus.Pending };
        mockOrderQueries.Setup(q => q.GetByIdAsync(1))
                       .ReturnsAsync(order);
        
        var service = new OrderProcessingService(mockOrderQueries.Object, mockOrderCommands.Object);
        
        // Act
        await service.ProcessOrderAsync(1);
        
        // Assert - verify only the command we expect
        mockOrderCommands.Verify(c => c.UpdateOrderStatusAsync(1, OrderStatus.Processing), Times.Once);
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**ISP Success Indicators**:

- ✅ Clients depend only on methods they actually use
- ✅ Interface changes don't affect unrelated clients  
- ✅ Easy to create focused unit tests with minimal mocking
- ✅ Clear, single-purpose interfaces that communicate intent

**ISP Violation Warning Signs**:

- ❌ Interfaces with many unrelated methods
- ❌ Clients implementing methods with NotSupportedException
- ❌ Difficulty creating unit tests due to large interface dependencies
- ❌ Frequent interface changes affecting many unrelated clients

**ISP Design Guidelines**:

1. **Design interfaces from client perspective** - what does the client actually need?
2. **Keep interfaces cohesive** - all methods should relate to a single responsibility
3. **Prefer composition over large interfaces** - combine smaller interfaces when needed
4. **Use role-based segregation** - separate read/write, command/query operations
5. **Apply ISP iteratively** - refactor as you discover new usage patterns

### Next Steps

**Immediate Actions**:

- Audit existing interfaces for ISP violations
- Practice role-based interface design
- Continue to Part 5: **Dependency Inversion Principle (DIP)**

**Advanced Applications**:

- CQRS (Command Query Responsibility Segregation) patterns
- Microservice interface design using ISP
- Plugin architectures with ISP

## 🔗 Related Topics

**Prerequisites**: Liskov Substitution Principle, Interface design fundamentals  
**Builds Upon**: Single Responsibility Principle, Dependency injection patterns  
**Enables**: Dependency Inversion Principle (Part 5), CQRS patterns, Microservice design  
**Related**: Clean Architecture, Domain-Driven Design, Testing strategies
