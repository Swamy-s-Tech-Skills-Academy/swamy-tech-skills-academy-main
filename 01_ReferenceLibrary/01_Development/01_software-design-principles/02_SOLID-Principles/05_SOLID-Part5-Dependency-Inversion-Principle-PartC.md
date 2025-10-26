# 05_SOLID-Part5-Dependency-Inversion-Principle - Part C

**Learning Level**: Advanced
**Prerequisites**: Interface Segregation Principle (Part 4), Dependency injection concepts
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Dependency Inversion Principle (DIP) and its architectural implications

## Part C of 4

Previous: [05_SOLID-Part5-Dependency-Inversion-Principle-PartB.md](05_SOLID-Part5-Dependency-Inversion-Principle-PartB.md)
Next: [05_SOLID-Part5-Dependency-Inversion-Principle-PartD.md](05_SOLID-Part5-Dependency-Inversion-Principle-PartD.md)

---

            Console.WriteLine($"Exception: {exception}");
    }

    public void LogWarning(string message)
    {
        Console.WriteLine($"[WARNING] {DateTime.Now:yyyy-MM-dd HH:mm:ss} - {message}");
    }
}

    #### Dependency Injection Container Configuration
csharp
// Composition root - where dependencies are wired up
public class ServiceConfiguration
{
    public static ServiceCollection ConfigureServices()
    {
        var services = new ServiceCollection();

        // Register abstractions with concrete implementations
        services.AddScoped`IOrderRepository, SqlOrderRepository`();
        services.AddScoped`IEmailService, SmtpEmailService`();
        services.AddScoped`ILogger, FileLogger`();

        // Register business services
        services.AddScoped`OrderService`();

        // Configuration
        services.AddSingleton`IConfiguration`(provider =>
        {
            return new ConfigurationBuilder()
                .AddJsonFile("appsettings.json")
                .Build();
        });

        // Register repository with configuration
        services.AddScoped`IOrderRepository`(provider =>
        {
            var config = provider.GetRequiredService`IConfiguration`();
            var connectionString = config.GetConnectionString("DefaultConnection");
            return new SqlOrderRepository(connectionString);
        });

        return services;
    }
}

// Different configurations for different environments
public class TestServiceConfiguration
{
    public static ServiceCollection ConfigureTestServices()
    {
        var services = new ServiceCollection();

        // Use in-memory implementations for testing
        services.AddScoped`IOrderRepository, InMemoryOrderRepository`();
        services.AddScoped`IEmailService, MockEmailService`();
        services.AddScoped`ILogger, ConsoleLogger`();

        services.AddScoped`OrderService`();

        return services;
    }
}

    ### Practical Implementation (8 minutes)

    #### Advanced DIP Patterns

    ##### Factory Pattern with DIP
csharp
// Abstract factory follows DIP
public interface IRepositoryFactory
{
    IOrderRepository CreateOrderRepository();
    ICustomerRepository CreateCustomerRepository();
    IProductRepository CreateProductRepository();
}

// Concrete factory for SQL implementations
public class SqlRepositoryFactory : IRepositoryFactory
{
    private readonly string`_connectionString;

    public SqlRepositoryFactory(string connectionString)
    {`_connectionString = connectionString;
    }

    public IOrderRepository CreateOrderRepository()
    {
        return new SqlOrderRepository(_connectionString);
    }

    public ICustomerRepository CreateCustomerRepository()
    {
        return new SqlCustomerRepository(_connectionString);
    }

    public IProductRepository CreateProductRepository()
    {
        return new SqlProductRepository(_connectionString);
    }
}

// Service using factory abstraction
public class ECommerceService
{
    private readonly IRepositoryFactory`_repositoryFactory;

    public ECommerceService(IRepositoryFactory repositoryFactory)
    {`_repositoryFactory = repositoryFactory;
    }

    public async Task ProcessPurchaseAsync(int customerId, int productId, int quantity)
    {
        var customerRepo =`_repositoryFactory.CreateCustomerRepository();
        var productRepo =`_repositoryFactory.CreateProductRepository();
        var orderRepo =`_repositoryFactory.CreateOrderRepository();

        var customer = await customerRepo.GetByIdAsync(customerId);
        var product = await productRepo.GetByIdAsync(productId);

        // Business logic using abstractions
        var order = new Order
        {
            CustomerId = customerId,
            Items = new List`OrderItem`
            {
                new OrderItem { ProductId = productId, Quantity = quantity, Price = product.Price }
            }
        };

        await orderRepo.SaveAsync(order);
    }
}

    ##### Strategy Pattern with DIP
csharp
// Payment processing with DIP
public interface IPaymentProcessor
{
    Task`PaymentResult` ProcessAsync(PaymentRequest request);
    bool CanProcess(PaymentType paymentType);
}

public class PaymentService
{
