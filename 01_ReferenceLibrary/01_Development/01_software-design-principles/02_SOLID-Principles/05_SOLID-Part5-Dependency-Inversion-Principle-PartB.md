# 05_SOLID-Part5-Dependency-Inversion-Principle - Part B

**Learning Level**: Advanced  
**Prerequisites**: Interface Segregation Principle (Part 4), Dependency injection concepts  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Dependency Inversion Principle (DIP) and its architectural implications

## Part B of 4

Previous: [05_SOLID-Part5-Dependency-Inversion-Principle-PartA.md](05_SOLID-Part5-Dependency-Inversion-Principle-PartA.md)
Next: [05_SOLID-Part5-Dependency-Inversion-Principle-PartC.md](05_SOLID-Part5-Dependency-Inversion-Principle-PartC.md)

---

        {
            _logger.Log($"Processing order {order.Id}");
            
            // Validate business rules
            var validationResult = ValidateOrder(order);
            if (!validationResult.IsValid)
            {
                _logger.LogWarning($"Order {order.Id} validation failed: {string.Join(", ", validationResult.Errors)}");
                return ProcessResult.Failed(validationResult.Errors);
            }
            
            // Save order
            await _orderRepository.SaveAsync(order);
            
            // Send confirmation
            await _emailService.SendTemplatedAsync(
                order.CustomerEmail, 
                "OrderConfirmation", 
                new { OrderId = order.Id, Total = order.Total });
            
            _logger.Log($"Order {order.Id} processed successfully");
            return ProcessResult.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError($"Failed to process order {order.Id}", ex);
            throw;
        }
    }
    
    private ValidationResult ValidateOrder(Order order)
    {
        // Pure business logic - no infrastructure dependencies
        var result = new ValidationResult();
        
        if (order.Items == null || order.Items.Count == 0)
            result.AddError("Order must contain at least one item");
            
        if (order.Total `= 0)
            result.AddError("Order total must be greater than zero");
            
        if (string.IsNullOrEmpty(order.CustomerEmail))
            result.AddError("Customer email is required");
            
        return result;
    }
}

```

#### Low-Level Module Implementations

```csharp
// Low-level modules implement the abstractions
public class SqlOrderRepository : IOrderRepository
{
    private readonly string _connectionString;
    
    public SqlOrderRepository(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
    }
    
    public async Task<Order` GetByIdAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        var command = new SqlCommand("SELECT * FROM Orders WHERE Id = @id", connection);
        command.Parameters.AddWithValue("@id", id);
        
        await connection.OpenAsync();
        using var reader = await command.ExecuteReaderAsync();
        
        if (await reader.ReadAsync())
        {
            return new Order
            {
                Id = reader.GetInt32("Id"),
                CustomerEmail = reader.GetString("CustomerEmail"),
                Total = reader.GetDecimal("Total")
            };
        }
        
        return null;
    }
    
    public async Task SaveAsync(Order order)
    {
        using var connection = new SqlConnection(_connectionString);
        var command = new SqlCommand(
            "INSERT INTO Orders (CustomerEmail, Total) VALUES (@email, @total)", 
            connection);
        command.Parameters.AddWithValue("@email", order.CustomerEmail);
        command.Parameters.AddWithValue("@total", order.Total);
        
        await connection.OpenAsync();
        await command.ExecuteNonQueryAsync();
    }
    
    public async Task`IEnumerable<Order`> GetOrdersByCustomerAsync(int customerId)
    {
        // Implementation details...
        return new List`Order`();
    }
}

// Alternative implementation for testing or different environments
public class InMemoryOrderRepository : IOrderRepository
{
    private readonly List`Order` _orders = new();
    private int _nextId = 1;
    
    public Task`Order` GetByIdAsync(int id)
    {
        var order = _orders.FirstOrDefault(o => o.Id == id);
        return Task.FromResult(order);
    }
    
    public Task SaveAsync(Order order)
    {
        if (order.Id == 0)
        {
            order.Id = _nextId++;
            _orders.Add(order);
        }
        else
        {
            var existing = _orders.FirstOrDefault(o => o.Id == order.Id);
            if (existing != null)
            {
                _orders.Remove(existing);
                _orders.Add(order);
            }
        }
        
        return Task.CompletedTask;
    }
    
    public Task`IEnumerable<Order`> GetOrdersByCustomerAsync(int customerId)
    {
        var orders = _orders.Where(o => o.CustomerId == customerId);
        return Task.FromResult(orders);
    }
}

public class ConsoleLogger : ILogger
{
    public void Log(string message)
    {
        Console.WriteLine($"[INFO] {DateTime.Now:yyyy-MM-dd HH:mm:ss} - {message}");
    }
    
    public void LogError(string message, Exception exception = null)
    {
        Console.WriteLine($"[ERROR] {DateTime.Now:yyyy-MM-dd HH:mm:ss} - {message}");
        if (exception != null)

