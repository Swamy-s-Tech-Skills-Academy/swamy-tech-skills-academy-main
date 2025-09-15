# 05C_Microservices-Resilience-Patterns

**Learning Level**: Advanced
**Prerequisites**: [05B_Microservices-Communication-Patterns.md](05B_Microservices-Communication-Patterns.md)
**Estimated Time**: 27 minutes
**Series**: Part C of 5 - Microservices Fundamentals
**Next**: [05D_Microservices-Data-Management.md](05D_Microservices-Data-Management.md)

---

## 🎯 Learning Objectives (27-Minute Session)

By the end of this session, you will:

- Implement circuit breaker pattern for fault tolerance
- Apply retry patterns with exponential backoff
- Use bulkhead pattern for resource isolation
- Design timeout and fallback strategies

---

## 📋 Content Sections (27-Minute Structure)

### Quick Overview (5 minutes)

**Resilience Patterns**: Essential for building fault-tolerant microservices

```text
Resilience Pattern Decision Tree
├── Service failures expected? → Circuit Breaker
├── Transient failures common? → Retry with Backoff
├── Resource isolation needed? → Bulkhead Pattern
├── Fast failure preferred? → Timeout Pattern
└── Graceful degradation? → Fallback Pattern
```

### Circuit Breaker Concept

**Circuit Breaker**: Prevents cascading failures by temporarily stopping calls to failing services

```text
Circuit Breaker States
├── Closed: Normal operation, requests flow through
├── Open: Service failing, requests fail fast
└── Half-Open: Testing recovery, limited requests allowed
```

#### Circuit Breaker Implementation

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
```

### Retry Pattern Concept

**Retry Pattern**: Automatically retry failed operations with increasing delays

```text
Retry Strategy Benefits
├── Handles transient failures
├── Reduces manual intervention
├── Improves user experience
└── Prevents cascade failures
```

#### Retry Pattern Implementation

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

### Bulkhead Pattern Concept

**Bulkhead**: Isolates resources to prevent failure in one area from affecting others

```text
Bulkhead Isolation Types
├── Thread Pool Isolation: Separate thread pools
├── Connection Pool Isolation: Separate connection pools
├── Resource Limit Isolation: CPU/memory limits per service
└── Queue Isolation: Separate request queues
```

#### Bulkhead Pattern Implementation

```csharp
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

    public async Task<T> ExecuteNormalQueryAsync<T>(Func<IDbConnection, Task<T>> query)
    {
        await _normalOperationsSemaphore.WaitAsync();
        try
        {
            using var connection = CreateConnection();
            return await query(connection);
        }
        finally
        {
            _normalOperationsSemaphore.Release();
        }
    }

    private IDbConnection CreateConnection()
    {
        // Connection creation logic
        return new SqlConnection(_connectionString);
    }
}
```

---

## ✅ Key Takeaways (2 minutes)

### **Essential Understanding**

1. **Circuit breakers prevent cascade failures** by failing fast when services are down
2. **Retry patterns handle transient failures** but need exponential backoff to avoid overload
3. **Bulkhead isolation protects healthy services** when others fail under load
4. **Multiple patterns work together** for comprehensive resilience

### **What's Next**

**Part D** will cover:

- Saga pattern for distributed transactions
- Event sourcing for data consistency
- CQRS for complex domain models

---

## 🔗 Series Navigation

- **Previous**: [05B_Microservices-Communication-Patterns.md](05B_Microservices-Communication-Patterns.md)
- **Current**: Part C - Resilience Patterns ✅
- **Next**: [05D_Microservices-Data-Management.md](05D_Microservices-Data-Management.md)
- **Series**: Microservices Architecture Fundamentals (Part C of 5)

**Last Updated**: September 15, 2025
**Format**: 27-minute focused learning segment

