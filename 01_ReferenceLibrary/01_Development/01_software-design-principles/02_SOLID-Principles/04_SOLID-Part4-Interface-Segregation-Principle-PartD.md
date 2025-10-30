# 04_SOLID-Part4-Interface-Segregation-Principle - Part D

**Learning Level**: Intermediate to Advanced
**Prerequisites**: Liskov Substitution Principle (Part 3), Interface design patterns
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Interface Segregation Principle (ISP) and its client-focused design approach

## Part D of 4

Previous: [04_SOLID-Part4-Interface-Segregation-Principle-PartC.md](04_SOLID-Part4-Interface-Segregation-Principle-PartC.md)

---

// Client chooses appropriate interface level
public class ProductCatalogService
{
    private readonly IReadOnlyRepository`Product``_productRepository;

    public ProductCatalogService(IReadOnlyRepository`Product` productRepository)
    {`_productRepository = productRepository; // Only needs read operations
    }

    public async Task`ProductCatalog` GetCatalogAsync(string category)
    {
        var products = await`_productRepository.SearchAsync($"category:{category}");
        return new ProductCatalog { Products = products.ToList() };
    }
}

    ##### Strategy 2: Capability-Based Interfaces
csharp
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
    IEnumerable`AuditEntry` GetAuditTrail();
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
    public List`OrderItem` Items { get; set; }

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

    public IEnumerable`AuditEntry` GetAuditTrail()
    {
        // Return audit entries
        return new List`AuditEntry`();
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
        var user = System.Text.Json.JsonSerializer.Deserialize`User`(data);
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
    public bool IsValid`T`(T entity) where T : IValidatable
    {
        return entity.Validate().IsValid;
    }
}

public class CacheService
{
    private readonly IMemoryCache`_cache;

    public CacheService(IMemoryCache cache)
    {`_cache = cache;
    }

    public void CacheEntity`T`(T entity) where T : ICacheable
    {`_cache.Set(entity.GetCacheKey(), entity, entity.GetCacheDuration());
    }

    public T GetFromCache`T`(string key) where T : class
    {
        return`_cache.Get`T`(key);
    }
}

    #### Testing with ISP
csharp
// ISP makes testing much simpler
public class OrderServiceTests
{
    [Test]
    public async Task ProcessOrder_ValidOrder_ShouldUpdateStatus()
    {
        // Arrange - only mock what the service actually uses
        var mockOrderQueries = new Mock`IOrderQueries`();
        var mockOrderCommands = new Mock`IOrderCommands`();

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

## 🔗 Related Topics

### **Prerequisites**
- [04_SOLID-Part4-Interface-Segregation-Principle-PartC.md](04_SOLID-Part4-Interface-Segregation-Principle-PartC.md)

### **Builds Upon**
- Complete ISP mastery
- Real-world interface design

### **Enables Next Steps**
- **Next**: [05_SOLID-Part5-Dependency-Inversion-Principle-PartA.md](05_SOLID-Part5-Dependency-Inversion-Principle-PartA.md)
- **Future**: [Design Patterns](../03_Design-Patterns/)

### **Cross-References**
- **Architecture**: API design principles
