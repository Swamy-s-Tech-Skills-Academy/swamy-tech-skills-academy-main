# 12_Performance-Optimization

**Learning Level**: Advanced  
**Prerequisites**: System Design Fundamentals, API Design Principles, Microservices Architecture  
**Estimated Time**: 75-90 minutes

## 🎯 Learning Objectives

By the end of this content, you will:

- Master advanced caching strategies and implementation patterns
- Optimize database performance with query optimization and connection pooling
- Implement load balancing and horizontal scaling patterns
- Design comprehensive monitoring and observability systems
- Apply memory management and garbage collection optimization
- Build high-performance async and concurrent systems

## 📋 Table of Contents

1. [Introduction to Performance Optimization](#introduction)
2. [Caching Strategies and Patterns](#caching)
3. [Database Performance Optimization](#database)
4. [Load Balancing and Scaling](#scaling)
5. [Monitoring and Observability](#monitoring)
6. [Memory Management and Optimization](#memory)
7. [Asynchronous and Concurrent Patterns](#async)
8. [Performance Testing and Profiling](#testing)
9. [Common Performance Anti-Patterns](#anti-patterns)

---

## 🚀 Introduction to Performance Optimization {#introduction}

**Performance Optimization** is the systematic approach to improving application speed, throughput, and resource utilization while maintaining functionality and reliability. It encompasses multiple layers from algorithm efficiency to infrastructure scaling.

### Performance Optimization Pyramid

```text
                    ┌─────────────────┐
                    │   User Experience   │  ← Perceived Performance
                    ├─────────────────┤
                    │   Application   │  ← Code & Algorithm Optimization
                    ├─────────────────┤
                    │   Infrastructure │  ← Scaling & Load Balancing
                    ├─────────────────┤
                    │   Database      │  ← Query & Index Optimization
                    ├─────────────────┤
                    │   Network       │  ← CDN & Caching
                    └─────────────────┘
```

### Key Performance Metrics

- **Throughput**: Requests processed per second (RPS/TPS)
- **Latency**: Response time for individual requests
- **Availability**: System uptime and reliability
- **Scalability**: Ability to handle increased load
- **Resource Utilization**: CPU, memory, disk, network efficiency

---

## 🔄 Caching Strategies and Patterns {#caching}

### 1. Multi-Level Caching Architecture

```csharp
// ✅ Comprehensive Caching Strategy
namespace PerformanceOptimization.Caching
{
    public interface ICacheService
    {
        Task<T> GetAsync<T>(string key);
        Task SetAsync<T>(string key, T value, TimeSpan? expiration = null);
        Task RemoveAsync(string key);
        Task RemoveByPatternAsync(string pattern);
    }
    
    public class MultiLevelCacheService : ICacheService
    {
        private readonly IMemoryCache _memoryCache;
        private readonly IDistributedCache _distributedCache;
        private readonly ILogger<MultiLevelCacheService> _logger;
        
        public MultiLevelCacheService(
            IMemoryCache memoryCache,
            IDistributedCache distributedCache,
            ILogger<MultiLevelCacheService> logger)
        {
            _memoryCache = memoryCache;
            _distributedCache = distributedCache;
            _logger = logger;
        }
        
        public async Task<T> GetAsync<T>(string key)
        {
            // L1 Cache: Memory Cache (fastest)
            if (_memoryCache.TryGetValue(key, out T memoryValue))
            {
                _logger.LogDebug("Cache hit: Memory - {Key}", key);
                return memoryValue;
            }
            
            // L2 Cache: Distributed Cache (Redis)
            var distributedValue = await _distributedCache.GetStringAsync(key);
            if (distributedValue != null)
            {
                var deserializedValue = JsonSerializer.Deserialize<T>(distributedValue);
                
                // Populate L1 cache
                _memoryCache.Set(key, deserializedValue, TimeSpan.FromMinutes(5));
                
                _logger.LogDebug("Cache hit: Distributed - {Key}", key);
                return deserializedValue;
            }
            
            _logger.LogDebug("Cache miss - {Key}", key);
            return default(T);
        }
        
        public async Task SetAsync<T>(string key, T value, TimeSpan? expiration = null)
        {
            var expiry = expiration ?? TimeSpan.FromHours(1);
            var serializedValue = JsonSerializer.Serialize(value);
            
            // Set in both caches
            _memoryCache.Set(key, value, TimeSpan.FromMinutes(5));
            await _distributedCache.SetStringAsync(key, serializedValue, new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = expiry
            });
            
            _logger.LogDebug("Cache set - {Key}", key);
        }
        
        public async Task RemoveAsync(string key)
        {
            _memoryCache.Remove(key);
            await _distributedCache.RemoveAsync(key);
            _logger.LogDebug("Cache removed - {Key}", key);
        }
        
        public async Task RemoveByPatternAsync(string pattern)
        {
            // Implementation depends on cache provider
            // For Redis: use SCAN with pattern matching
            _logger.LogDebug("Cache pattern removal - {Pattern}", pattern);
        }
    }
}
```

### 2. Cache-Aside Pattern with Fallback

```csharp
// ✅ Cache-Aside Pattern Implementation
namespace PerformanceOptimization.Patterns
{
    public class ProductService
    {
        private readonly IProductRepository _repository;
        private readonly ICacheService _cache;
        private readonly ILogger<ProductService> _logger;
        
        public ProductService(
            IProductRepository repository,
            ICacheService cache,
            ILogger<ProductService> logger)
        {
            _repository = repository;
            _cache = cache;
            _logger = logger;
        }
        
        public async Task<Product> GetProductAsync(int productId)
        {
            var cacheKey = $"product:{productId}";
            
            try
            {
                // Try cache first
                var cachedProduct = await _cache.GetAsync<Product>(cacheKey);
                if (cachedProduct != null)
                {
                    return cachedProduct;
                }
                
                // Cache miss - get from database
                var product = await _repository.GetByIdAsync(productId);
                if (product != null)
                {
                    // Cache for 1 hour
                    await _cache.SetAsync(cacheKey, product, TimeSpan.FromHours(1));
                }
                
                return product;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Cache error for product {ProductId}", productId);
                
                // Fallback to database on cache failure
                return await _repository.GetByIdAsync(productId);
            }
        }
        
        public async Task UpdateProductAsync(Product product)
        {
            await _repository.UpdateAsync(product);
            
            // Invalidate cache
            var cacheKey = $"product:{product.Id}";
            await _cache.RemoveAsync(cacheKey);
            
            // Optionally warm cache immediately
            await _cache.SetAsync(cacheKey, product, TimeSpan.FromHours(1));
        }
    }
}
```

### 3. Advanced Caching Patterns

```csharp
// ✅ Write-Through and Write-Behind Caching
namespace PerformanceOptimization.AdvancedCaching
{
    public class WriteThroughCacheService<T>
    {
        private readonly ICacheService _cache;
        private readonly IRepository<T> _repository;
        private readonly SemaphoreSlim _semaphore;
        
        public WriteThroughCacheService(ICacheService cache, IRepository<T> repository)
        {
            _cache = cache;
            _repository = repository;
            _semaphore = new SemaphoreSlim(1, 1);
        }
        
        public async Task<T> GetAsync(string key)
        {
            var cached = await _cache.GetAsync<T>(key);
            if (cached != null) return cached;
            
            await _semaphore.WaitAsync();
            try
            {
                // Double-check after acquiring lock
                cached = await _cache.GetAsync<T>(key);
                if (cached != null) return cached;
                
                // Load from repository
                var data = await _repository.GetAsync(key);
                if (data != null)
                {
                    await _cache.SetAsync(key, data);
                }
                
                return data;
            }
            finally
            {
                _semaphore.Release();
            }
        }
        
        public async Task SetAsync(string key, T value)
        {
            // Write-through: Write to both cache and repository
            await Task.WhenAll(
                _cache.SetAsync(key, value),
                _repository.SetAsync(key, value)
            );
        }
    }
    
    public class WriteBehindCacheService<T>
    {
        private readonly ICacheService _cache;
        private readonly IRepository<T> _repository;
        private readonly IBackgroundTaskQueue _backgroundQueue;
        
        public WriteBehindCacheService(
            ICacheService cache,
            IRepository<T> repository,
            IBackgroundTaskQueue backgroundQueue)
        {
            _cache = cache;
            _repository = repository;
            _backgroundQueue = backgroundQueue;
        }
        
        public async Task SetAsync(string key, T value)
        {
            // Write to cache immediately
            await _cache.SetAsync(key, value);
            
            // Queue background write to repository
            _backgroundQueue.QueueBackgroundWorkItem(async token =>
            {
                await _repository.SetAsync(key, value);
            });
        }
    }
}
```

---

## 💾 Database Performance Optimization {#database}

### 1. Query Optimization and Indexing

```csharp
// ✅ Optimized Database Access Patterns
namespace PerformanceOptimization.Database
{
    public class OptimizedProductRepository : IProductRepository
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<OptimizedProductRepository> _logger;
        
        public OptimizedProductRepository(
            ApplicationDbContext context,
            ILogger<OptimizedProductRepository> logger)
        {
            _context = context;
            _logger = logger;
        }
        
        public async Task<Product> GetProductWithDetailsAsync(int productId)
        {
            // ✅ Optimized query with explicit includes and projections
            return await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Reviews.Where(r => r.IsApproved))
                .ThenInclude(r => r.User)
                .Where(p => p.Id == productId && p.IsActive)
                .Select(p => new Product
                {
                    Id = p.Id,
                    Name = p.Name,
                    Price = p.Price,
                    Category = new Category { Id = p.Category.Id, Name = p.Category.Name },
                    Reviews = p.Reviews
                        .Where(r => r.IsApproved)
                        .OrderByDescending(r => r.CreatedAt)
                        .Take(5)
                        .Select(r => new Review
                        {
                            Id = r.Id,
                            Rating = r.Rating,
                            Comment = r.Comment,
                            User = new User { Id = r.User.Id, Name = r.User.Name }
                        }).ToList()
                })
                .AsNoTracking() // Read-only optimization
                .FirstOrDefaultAsync();
        }
        
        public async Task<PagedResult<Product>> GetProductsPagedAsync(
            int page, int pageSize, string searchTerm = null)
        {
            var query = _context.Products
                .Where(p => p.IsActive)
                .AsQueryable();
            
            if (!string.IsNullOrEmpty(searchTerm))
            {
                // Use full-text search if available, otherwise LIKE
                query = query.Where(p => EF.Functions.Contains(p.Name, searchTerm) ||
                                        p.Description.Contains(searchTerm));
            }
            
            var totalCount = await query.CountAsync();
            
            var products = await query
                .OrderBy(p => p.Name)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(p => new Product
                {
                    Id = p.Id,
                    Name = p.Name,
                    Price = p.Price,
                    ImageUrl = p.ImageUrl
                })
                .AsNoTracking()
                .ToListAsync();
            
            return new PagedResult<Product>
            {
                Items = products,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }
        
        public async Task<Dictionary<int, int>> GetProductStockLevelsAsync(IEnumerable<int> productIds)
        {
            // ✅ Efficient bulk lookup
            return await _context.ProductStock
                .Where(ps => productIds.Contains(ps.ProductId))
                .ToDictionaryAsync(ps => ps.ProductId, ps => ps.StockLevel);
        }
    }
}
```

### 2. Connection Pooling and Resource Management

```csharp
// ✅ Advanced Connection Management
namespace PerformanceOptimization.Database
{
    public class DatabaseConnectionManager
    {
        private readonly string _connectionString;
        private readonly ILogger<DatabaseConnectionManager> _logger;
        
        public DatabaseConnectionManager(
            IConfiguration configuration,
            ILogger<DatabaseConnectionManager> logger)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
            _logger = logger;
        }
        
        public async Task<T> ExecuteWithRetryAsync<T>(Func<IDbConnection, Task<T>> operation)
        {
            const int maxRetries = 3;
            var delays = new[] { TimeSpan.FromMilliseconds(100), TimeSpan.FromMilliseconds(500), TimeSpan.FromSeconds(1) };
            
            for (int attempt = 0; attempt < maxRetries; attempt++)
            {
                try
                {
                    using var connection = new SqlConnection(_connectionString);
                    await connection.OpenAsync();
                    return await operation(connection);
                }
                catch (SqlException ex) when (IsTransientError(ex) && attempt < maxRetries - 1)
                {
                    _logger.LogWarning(ex, "Database operation failed, retrying in {Delay}ms", delays[attempt].TotalMilliseconds);
                    await Task.Delay(delays[attempt]);
                }
            }
            
            // Final attempt without retry
            using var finalConnection = new SqlConnection(_connectionString);
            await finalConnection.OpenAsync();
            return await operation(finalConnection);
        }
        
        private static bool IsTransientError(SqlException ex)
        {
            // Common transient error codes
            var transientErrors = new[] { 2, 53, 121, 232, 10053, 10054, 10060, 40197, 40501, 40613 };
            return transientErrors.Contains(ex.Number);
        }
    }
    
    public class BulkOperationService
    {
        private readonly DatabaseConnectionManager _connectionManager;
        
        public BulkOperationService(DatabaseConnectionManager connectionManager)
        {
            _connectionManager = connectionManager;
        }
        
        public async Task BulkInsertProductsAsync(IEnumerable<Product> products)
        {
            await _connectionManager.ExecuteWithRetryAsync(async connection =>
            {
                using var bulkCopy = new SqlBulkCopy((SqlConnection)connection)
                {
                    DestinationTableName = "Products",
                    BatchSize = 1000,
                    BulkCopyTimeout = 300
                };
                
                // Map columns
                bulkCopy.ColumnMappings.Add("Name", "Name");
                bulkCopy.ColumnMappings.Add("Price", "Price");
                bulkCopy.ColumnMappings.Add("CategoryId", "CategoryId");
                
                // Convert to DataTable
                var dataTable = ConvertToDataTable(products);
                await bulkCopy.WriteToServerAsync(dataTable);
                
                return true;
            });
        }
        
        private DataTable ConvertToDataTable(IEnumerable<Product> products)
        {
            var table = new DataTable();
            table.Columns.Add("Name", typeof(string));
            table.Columns.Add("Price", typeof(decimal));
            table.Columns.Add("CategoryId", typeof(int));
            
            foreach (var product in products)
            {
                table.Rows.Add(product.Name, product.Price, product.CategoryId);
            }
            
            return table;
        }
    }
}
```

---

## ⚖️ Load Balancing and Scaling {#scaling}

### 1. Application-Level Load Balancing

```csharp
// ✅ Custom Load Balancer Implementation
namespace PerformanceOptimization.LoadBalancing
{
    public interface ILoadBalancer
    {
        Task<string> GetNextEndpointAsync();
        Task ReportHealthAsync(string endpoint, bool isHealthy);
    }
    
    public class WeightedRoundRobinLoadBalancer : ILoadBalancer
    {
        private readonly List<WeightedEndpoint> _endpoints;
        private readonly SemaphoreSlim _semaphore;
        private int _currentIndex;
        private int _currentWeight;
        
        public WeightedRoundRobinLoadBalancer(IEnumerable<WeightedEndpoint> endpoints)
        {
            _endpoints = endpoints.ToList();
            _semaphore = new SemaphoreSlim(1, 1);
            _currentIndex = -1;
            _currentWeight = 0;
        }
        
        public async Task<string> GetNextEndpointAsync()
        {
            await _semaphore.WaitAsync();
            try
            {
                var healthyEndpoints = _endpoints.Where(e => e.IsHealthy).ToList();
                if (!healthyEndpoints.Any())
                {
                    throw new InvalidOperationException("No healthy endpoints available");
                }
                
                while (true)
                {
                    _currentIndex = (_currentIndex + 1) % healthyEndpoints.Count;
                    
                    if (_currentIndex == 0)
                    {
                        _currentWeight = _currentWeight - GetGcd(healthyEndpoints.Select(e => e.Weight));
                        if (_currentWeight <= 0)
                        {
                            _currentWeight = healthyEndpoints.Max(e => e.Weight);
                        }
                    }
                    
                    if (healthyEndpoints[_currentIndex].Weight >= _currentWeight)
                    {
                        return healthyEndpoints[_currentIndex].Endpoint;
                    }
                }
            }
            finally
            {
                _semaphore.Release();
            }
        }
        
        public async Task ReportHealthAsync(string endpoint, bool isHealthy)
        {
            await _semaphore.WaitAsync();
            try
            {
                var endpointObj = _endpoints.FirstOrDefault(e => e.Endpoint == endpoint);
                if (endpointObj != null)
                {
                    endpointObj.IsHealthy = isHealthy;
                    endpointObj.LastHealthCheck = DateTime.UtcNow;
                }
            }
            finally
            {
                _semaphore.Release();
            }
        }
        
        private int GetGcd(IEnumerable<int> numbers)
        {
            return numbers.Aggregate((a, b) => Gcd(a, b));
        }
        
        private int Gcd(int a, int b)
        {
            while (b != 0)
            {
                int temp = b;
                b = a % b;
                a = temp;
            }
            return a;
        }
    }
    
    public class WeightedEndpoint
    {
        public string Endpoint { get; set; }
        public int Weight { get; set; }
        public bool IsHealthy { get; set; } = true;
        public DateTime LastHealthCheck { get; set; } = DateTime.UtcNow;
    }
}
```

### 2. Circuit Breaker Pattern for Resilience

```csharp
// ✅ Circuit Breaker Implementation
namespace PerformanceOptimization.Resilience
{
    public class CircuitBreaker
    {
        private readonly int _failureThreshold;
        private readonly TimeSpan _timeout;
        private readonly ILogger<CircuitBreaker> _logger;
        
        private int _failureCount;
        private DateTime _lastFailureTime;
        private CircuitBreakerState _state = CircuitBreakerState.Closed;
        private readonly SemaphoreSlim _semaphore = new(1, 1);
        
        public CircuitBreaker(int failureThreshold, TimeSpan timeout, ILogger<CircuitBreaker> logger)
        {
            _failureThreshold = failureThreshold;
            _timeout = timeout;
            _logger = logger;
        }
        
        public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation)
        {
            await _semaphore.WaitAsync();
            try
            {
                if (_state == CircuitBreakerState.Open)
                {
                    if (DateTime.UtcNow - _lastFailureTime > _timeout)
                    {
                        _state = CircuitBreakerState.HalfOpen;
                        _logger.LogInformation("Circuit breaker moving to HalfOpen state");
                    }
                    else
                    {
                        throw new CircuitBreakerOpenException("Circuit breaker is open");
                    }
                }
                
                try
                {
                    var result = await operation();
                    
                    if (_state == CircuitBreakerState.HalfOpen)
                    {
                        _state = CircuitBreakerState.Closed;
                        _failureCount = 0;
                        _logger.LogInformation("Circuit breaker closed after successful operation");
                    }
                    
                    return result;
                }
                catch (Exception ex)
                {
                    _failureCount++;
                    _lastFailureTime = DateTime.UtcNow;
                    
                    if (_failureCount >= _failureThreshold)
                    {
                        _state = CircuitBreakerState.Open;
                        _logger.LogWarning("Circuit breaker opened after {FailureCount} failures", _failureCount);
                    }
                    
                    throw;
                }
            }
            finally
            {
                _semaphore.Release();
            }
        }
    }
    
    public enum CircuitBreakerState
    {
        Closed,
        Open,
        HalfOpen
    }
    
    public class CircuitBreakerOpenException : Exception
    {
        public CircuitBreakerOpenException(string message) : base(message) { }
    }
}
```

---

## 📊 Monitoring and Observability {#monitoring}

### 1. Comprehensive Performance Monitoring

```csharp
// ✅ Advanced Performance Monitoring
namespace PerformanceOptimization.Monitoring
{
    public class PerformanceMonitoringService
    {
        private readonly IMetricsCollector _metrics;
        private readonly ILogger<PerformanceMonitoringService> _logger;
        private readonly Timer _performanceTimer;
        
        public PerformanceMonitoringService(
            IMetricsCollector metrics,
            ILogger<PerformanceMonitoringService> logger)
        {
            _metrics = metrics;
            _logger = logger;
            
            // Collect system metrics every 30 seconds
            _performanceTimer = new Timer(CollectSystemMetrics, null, TimeSpan.Zero, TimeSpan.FromSeconds(30));
        }
        
        public async Task<T> TrackOperationAsync<T>(
            string operationName,
            Func<Task<T>> operation,
            IDictionary<string, object> customTags = null)
        {
            var stopwatch = Stopwatch.StartNew();
            var tags = new Dictionary<string, object>
            {
                ["operation"] = operationName,
                ["timestamp"] = DateTime.UtcNow
            };
            
            if (customTags != null)
            {
                foreach (var tag in customTags)
                {
                    tags[tag.Key] = tag.Value;
                }
            }
            
            try
            {
                var result = await operation();
                
                stopwatch.Stop();
                tags["success"] = true;
                tags["duration_ms"] = stopwatch.ElapsedMilliseconds;
                
                _metrics.RecordValue("operation_duration", stopwatch.ElapsedMilliseconds, tags);
                _metrics.Increment("operation_success", tags);
                
                if (stopwatch.ElapsedMilliseconds > 5000) // Slow operation threshold
                {
                    _logger.LogWarning("Slow operation detected: {Operation} took {Duration}ms", 
                        operationName, stopwatch.ElapsedMilliseconds);
                }
                
                return result;
            }
            catch (Exception ex)
            {
                stopwatch.Stop();
                tags["success"] = false;
                tags["exception_type"] = ex.GetType().Name;
                tags["duration_ms"] = stopwatch.ElapsedMilliseconds;
                
                _metrics.RecordValue("operation_duration", stopwatch.ElapsedMilliseconds, tags);
                _metrics.Increment("operation_failure", tags);
                
                _logger.LogError(ex, "Operation failed: {Operation} after {Duration}ms", 
                    operationName, stopwatch.ElapsedMilliseconds);
                
                throw;
            }
        }
        
        private void CollectSystemMetrics(object state)
        {
            try
            {
                // CPU Usage
                var cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
                var cpuUsage = cpuCounter.NextValue();
                _metrics.RecordValue("system_cpu_usage", cpuUsage);
                
                // Memory Usage
                var memoryCounter = new PerformanceCounter("Memory", "Available MBytes");
                var availableMemory = memoryCounter.NextValue();
                _metrics.RecordValue("system_memory_available_mb", availableMemory);
                
                // Process-specific metrics
                var process = Process.GetCurrentProcess();
                _metrics.RecordValue("process_memory_mb", process.WorkingSet64 / 1024 / 1024);
                _metrics.RecordValue("process_threads", process.Threads.Count);
                
                // Garbage Collection metrics
                _metrics.RecordValue("gc_gen0_collections", GC.CollectionCount(0));
                _metrics.RecordValue("gc_gen1_collections", GC.CollectionCount(1));
                _metrics.RecordValue("gc_gen2_collections", GC.CollectionCount(2));
                _metrics.RecordValue("gc_total_memory", GC.GetTotalMemory(false));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to collect system metrics");
            }
        }
    }
    
    public interface IMetricsCollector
    {
        void RecordValue(string metricName, double value, IDictionary<string, object> tags = null);
        void Increment(string metricName, IDictionary<string, object> tags = null);
        void RecordHistogram(string metricName, double value, IDictionary<string, object> tags = null);
    }
    
    public class ApplicationInsightsMetricsCollector : IMetricsCollector
    {
        private readonly TelemetryClient _telemetryClient;
        
        public ApplicationInsightsMetricsCollector(TelemetryClient telemetryClient)
        {
            _telemetryClient = telemetryClient;
        }
        
        public void RecordValue(string metricName, double value, IDictionary<string, object> tags = null)
        {
            var properties = tags?.ToDictionary(kvp => kvp.Key, kvp => kvp.Value?.ToString()) ?? new Dictionary<string, string>();
            _telemetryClient.TrackMetric(metricName, value, properties);
        }
        
        public void Increment(string metricName, IDictionary<string, object> tags = null)
        {
            RecordValue(metricName, 1, tags);
        }
        
        public void RecordHistogram(string metricName, double value, IDictionary<string, object> tags = null)
        {
            RecordValue($"{metricName}_histogram", value, tags);
        }
    }
}
```

### 2. Health Check Implementation

```csharp
// ✅ Comprehensive Health Check System
namespace PerformanceOptimization.HealthChecks
{
    public class DatabaseHealthCheck : IHealthCheck
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<DatabaseHealthCheck> _logger;
        
        public DatabaseHealthCheck(ApplicationDbContext context, ILogger<DatabaseHealthCheck> logger)
        {
            _context = context;
            _logger = logger;
        }
        
        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var stopwatch = Stopwatch.StartNew();
                
                // Simple connectivity check
                var canConnect = await _context.Database.CanConnectAsync(cancellationToken);
                if (!canConnect)
                {
                    return HealthCheckResult.Unhealthy("Cannot connect to database");
                }
                
                // Performance check - simple query
                var count = await _context.Products.CountAsync(cancellationToken);
                
                stopwatch.Stop();
                
                var data = new Dictionary<string, object>
                {
                    ["response_time_ms"] = stopwatch.ElapsedMilliseconds,
                    ["product_count"] = count
                };
                
                if (stopwatch.ElapsedMilliseconds > 5000)
                {
                    return HealthCheckResult.Degraded(
                        $"Database responding slowly: {stopwatch.ElapsedMilliseconds}ms", 
                        data: data);
                }
                
                return HealthCheckResult.Healthy("Database is healthy", data);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Database health check failed");
                return HealthCheckResult.Unhealthy("Database health check failed", ex);
            }
        }
    }
    
    public class CacheHealthCheck : IHealthCheck
    {
        private readonly ICacheService _cache;
        private readonly ILogger<CacheHealthCheck> _logger;
        
        public CacheHealthCheck(ICacheService cache, ILogger<CacheHealthCheck> logger)
        {
            _cache = cache;
            _logger = logger;
        }
        
        public async Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var stopwatch = Stopwatch.StartNew();
                var testKey = $"health_check_{Guid.NewGuid()}";
                var testValue = "health_check_value";
                
                // Test write
                await _cache.SetAsync(testKey, testValue, TimeSpan.FromMinutes(1));
                
                // Test read
                var retrievedValue = await _cache.GetAsync<string>(testKey);
                
                // Test delete
                await _cache.RemoveAsync(testKey);
                
                stopwatch.Stop();
                
                if (retrievedValue != testValue)
                {
                    return HealthCheckResult.Unhealthy("Cache read/write test failed");
                }
                
                var data = new Dictionary<string, object>
                {
                    ["response_time_ms"] = stopwatch.ElapsedMilliseconds
                };
                
                return HealthCheckResult.Healthy("Cache is healthy", data);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Cache health check failed");
                return HealthCheckResult.Unhealthy("Cache health check failed", ex);
            }
        }
    }
}
```

---

## 🧠 Memory Management and Optimization {#memory}

### 1. Memory-Efficient Data Processing

```csharp
// ✅ Memory-Optimized Data Processing
namespace PerformanceOptimization.Memory
{
    public class MemoryEfficientDataProcessor
    {
        private readonly ILogger<MemoryEfficientDataProcessor> _logger;
        private readonly MemoryPool<byte> _memoryPool;
        
        public MemoryEfficientDataProcessor(ILogger<MemoryEfficientDataProcessor> logger)
        {
            _logger = logger;
            _memoryPool = MemoryPool<byte>.Shared;
        }
        
        public async IAsyncEnumerable<ProcessedRecord> ProcessLargeDatasetAsync(
            IAsyncEnumerable<RawRecord> records)
        {
            var processedCount = 0;
            var batchSize = 1000;
            var currentBatch = new List<RawRecord>(batchSize);
            
            await foreach (var record in records)
            {
                currentBatch.Add(record);
                
                if (currentBatch.Count == batchSize)
                {
                    foreach (var processed in ProcessBatch(currentBatch))
                    {
                        yield return processed;
                    }
                    
                    currentBatch.Clear();
                    processedCount += batchSize;
                    
                    // Force garbage collection every 10K records
                    if (processedCount % 10000 == 0)
                    {
                        GC.Collect();
                        GC.WaitForPendingFinalizers();
                        _logger.LogInformation("Processed {Count} records, forced GC", processedCount);
                    }
                }
            }
            
            // Process remaining records
            if (currentBatch.Any())
            {
                foreach (var processed in ProcessBatch(currentBatch))
                {
                    yield return processed;
                }
            }
        }
        
        private IEnumerable<ProcessedRecord> ProcessBatch(List<RawRecord> batch)
        {
            return batch.Select(record => new ProcessedRecord
            {
                Id = record.Id,
                ProcessedData = ProcessRecord(record),
                ProcessedAt = DateTime.UtcNow
            });
        }
        
        private string ProcessRecord(RawRecord record)
        {
            // Use memory pool for temporary buffers
            using var owner = _memoryPool.Rent(1024);
            var buffer = owner.Memory.Span;
            
            // Process data using stack-allocated buffer
            return $"Processed: {record.Data}";
        }
    }
    
    public struct ProcessedRecord // Struct to reduce heap allocations
    {
        public int Id { get; init; }
        public string ProcessedData { get; init; }
        public DateTime ProcessedAt { get; init; }
    }
    
    public class RawRecord
    {
        public int Id { get; set; }
        public string Data { get; set; }
    }
}
```

### 2. Object Pooling for High-Frequency Objects

```csharp
// ✅ Object Pool Implementation
namespace PerformanceOptimization.ObjectPooling
{
    public class StringBuilderPool
    {
        private readonly ObjectPool<StringBuilder> _pool;
        
        public StringBuilderPool()
        {
            var policy = new StringBuilderPooledObjectPolicy();
            var provider = new DefaultObjectPoolProvider();
            _pool = provider.Create(policy);
        }
        
        public StringBuilder Get() => _pool.Get();
        
        public void Return(StringBuilder sb)
        {
            _pool.Return(sb);
        }
        
        public string Build(Action<StringBuilder> buildAction)
        {
            var sb = Get();
            try
            {
                buildAction(sb);
                return sb.ToString();
            }
            finally
            {
                Return(sb);
            }
        }
    }
    
    public class StringBuilderPooledObjectPolicy : IPooledObjectPolicy<StringBuilder>
    {
        public StringBuilder Create() => new StringBuilder();
        
        public bool Return(StringBuilder obj)
        {
            if (obj.Capacity > 8192) // Don't pool very large builders
            {
                return false;
            }
            
            obj.Clear();
            return true;
        }
    }
    
    public class HttpClientPool
    {
        private readonly ConcurrentQueue<HttpClient> _clients;
        private readonly SemaphoreSlim _semaphore;
        private readonly int _maxSize;
        
        public HttpClientPool(int maxSize = 10)
        {
            _clients = new ConcurrentQueue<HttpClient>();
            _semaphore = new SemaphoreSlim(maxSize, maxSize);
            _maxSize = maxSize;
        }
        
        public async Task<HttpClient> RentAsync()
        {
            await _semaphore.WaitAsync();
            
            if (_clients.TryDequeue(out var client))
            {
                return client;
            }
            
            return new HttpClient();
        }
        
        public void Return(HttpClient client)
        {
            if (client != null && _clients.Count < _maxSize)
            {
                _clients.Enqueue(client);
            }
            
            _semaphore.Release();
        }
    }
}
```

---

## ⚡ Asynchronous and Concurrent Patterns {#async}

### 1. High-Performance Async Patterns

```csharp
// ✅ Advanced Async Patterns
namespace PerformanceOptimization.Async
{
    public class ConcurrentDataProcessor
    {
        private readonly SemaphoreSlim _semaphore;
        private readonly ILogger<ConcurrentDataProcessor> _logger;
        
        public ConcurrentDataProcessor(int maxConcurrency, ILogger<ConcurrentDataProcessor> logger)
        {
            _semaphore = new SemaphoreSlim(maxConcurrency, maxConcurrency);
            _logger = logger;
        }
        
        public async Task<IEnumerable<TResult>> ProcessConcurrentlyAsync<TInput, TResult>(
            IEnumerable<TInput> items,
            Func<TInput, CancellationToken, Task<TResult>> processor,
            CancellationToken cancellationToken = default)
        {
            var tasks = items.Select(async item =>
            {
                await _semaphore.WaitAsync(cancellationToken);
                try
                {
                    return await processor(item, cancellationToken);
                }
                finally
                {
                    _semaphore.Release();
                }
            });
            
            return await Task.WhenAll(tasks);
        }
        
        public async Task<IEnumerable<TResult>> ProcessInBatchesAsync<TInput, TResult>(
            IEnumerable<TInput> items,
            Func<TInput, CancellationToken, Task<TResult>> processor,
            int batchSize = 10,
            CancellationToken cancellationToken = default)
        {
            var results = new List<TResult>();
            var batches = items.Chunk(batchSize);
            
            foreach (var batch in batches)
            {
                var batchTasks = batch.Select(item => processor(item, cancellationToken));
                var batchResults = await Task.WhenAll(batchTasks);
                results.AddRange(batchResults);
                
                _logger.LogDebug("Processed batch of {Count} items", batch.Length);
            }
            
            return results;
        }
    }
    
    public class AsyncRetryPolicy
    {
        private readonly int _maxRetries;
        private readonly TimeSpan _baseDelay;
        private readonly ILogger<AsyncRetryPolicy> _logger;
        
        public AsyncRetryPolicy(int maxRetries, TimeSpan baseDelay, ILogger<AsyncRetryPolicy> logger)
        {
            _maxRetries = maxRetries;
            _baseDelay = baseDelay;
            _logger = logger;
        }
        
        public async Task<TResult> ExecuteAsync<TResult>(
            Func<CancellationToken, Task<TResult>> operation,
            CancellationToken cancellationToken = default)
        {
            for (int attempt = 0; attempt <= _maxRetries; attempt++)
            {
                try
                {
                    return await operation(cancellationToken);
                }
                catch (Exception ex) when (attempt < _maxRetries && IsTransientException(ex))
                {
                    var delay = TimeSpan.FromMilliseconds(_baseDelay.TotalMilliseconds * Math.Pow(2, attempt));
                    
                    _logger.LogWarning(ex, "Operation failed (attempt {Attempt}/{MaxRetries}), retrying in {Delay}ms", 
                        attempt + 1, _maxRetries + 1, delay.TotalMilliseconds);
                    
                    await Task.Delay(delay, cancellationToken);
                }
            }
            
            // Final attempt
            return await operation(cancellationToken);
        }
        
        private static bool IsTransientException(Exception ex)
        {
            return ex is HttpRequestException ||
                   ex is TaskCanceledException ||
                   ex is SocketException;
        }
    }
}
```

### 2. Producer-Consumer Pattern with Channels

```csharp
// ✅ High-Performance Producer-Consumer
namespace PerformanceOptimization.Channels
{
    public class HighPerformanceMessageProcessor<T>
    {
        private readonly Channel<T> _channel;
        private readonly ChannelWriter<T> _writer;
        private readonly ChannelReader<T> _reader;
        private readonly CancellationTokenSource _cancellationTokenSource;
        private readonly Task _processingTask;
        private readonly ILogger<HighPerformanceMessageProcessor<T>> _logger;
        
        public HighPerformanceMessageProcessor(
            int capacity,
            Func<T, CancellationToken, Task> processor,
            ILogger<HighPerformanceMessageProcessor<T>> logger)
        {
            var options = new BoundedChannelOptions(capacity)
            {
                FullMode = BoundedChannelFullMode.Wait,
                SingleReader = true,
                SingleWriter = false
            };
            
            _channel = Channel.CreateBounded<T>(options);
            _writer = _channel.Writer;
            _reader = _channel.Reader;
            _cancellationTokenSource = new CancellationTokenSource();
            _logger = logger;
            
            _processingTask = Task.Run(() => ProcessMessagesAsync(processor, _cancellationTokenSource.Token));
        }
        
        public async ValueTask<bool> TryEnqueueAsync(T item, CancellationToken cancellationToken = default)
        {
            try
            {
                await _writer.WriteAsync(item, cancellationToken);
                return true;
            }
            catch (InvalidOperationException)
            {
                // Channel is closed
                return false;
            }
        }
        
        private async Task ProcessMessagesAsync(Func<T, CancellationToken, Task> processor, CancellationToken cancellationToken)
        {
            var processedCount = 0;
            
            try
            {
                await foreach (var item in _reader.ReadAllAsync(cancellationToken))
                {
                    try
                    {
                        await processor(item, cancellationToken);
                        processedCount++;
                        
                        if (processedCount % 1000 == 0)
                        {
                            _logger.LogInformation("Processed {Count} messages", processedCount);
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Error processing message");
                    }
                }
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Message processing cancelled");
            }
        }
        
        public async Task StopAsync()
        {
            _writer.Complete();
            await _processingTask;
            _cancellationTokenSource.Cancel();
        }
        
        public void Dispose()
        {
            _cancellationTokenSource?.Dispose();
        }
    }
}
```

---

## 🧪 Performance Testing and Profiling {#testing}

### 1. Load Testing Infrastructure

```csharp
// ✅ Integrated Load Testing Framework
namespace PerformanceOptimization.Testing
{
    public class LoadTestScenario
    {
        public string Name { get; set; }
        public int ConcurrentUsers { get; set; }
        public TimeSpan Duration { get; set; }
        public TimeSpan RampUpTime { get; set; }
        public Func<HttpClient, CancellationToken, Task<LoadTestResult>> TestAction { get; set; }
    }
    
    public class LoadTestResult
    {
        public bool Success { get; set; }
        public TimeSpan ResponseTime { get; set; }
        public string ErrorMessage { get; set; }
        public int StatusCode { get; set; }
    }
    
    public class LoadTestRunner
    {
        private readonly ILogger<LoadTestRunner> _logger;
        private readonly HttpClientPool _httpClientPool;
        
        public LoadTestRunner(ILogger<LoadTestRunner> logger)
        {
            _logger = logger;
            _httpClientPool = new HttpClientPool();
        }
        
        public async Task<LoadTestReport> RunLoadTestAsync(LoadTestScenario scenario)
        {
            _logger.LogInformation("Starting load test: {TestName}", scenario.Name);
            
            var results = new ConcurrentBag<LoadTestResult>();
            var cancellationTokenSource = new CancellationTokenSource(scenario.Duration);
            var semaphore = new SemaphoreSlim(scenario.ConcurrentUsers, scenario.ConcurrentUsers);
            
            var startTime = DateTime.UtcNow;
            var tasks = new List<Task>();
            
            // Ramp up users gradually
            var rampUpDelay = scenario.RampUpTime.TotalMilliseconds / scenario.ConcurrentUsers;
            
            for (int i = 0; i < scenario.ConcurrentUsers; i++)
            {
                tasks.Add(Task.Run(async () =>
                {
                    await Task.Delay(TimeSpan.FromMilliseconds(i * rampUpDelay));
                    await RunUserSimulationAsync(scenario, results, semaphore, cancellationTokenSource.Token);
                }));
            }
            
            await Task.WhenAll(tasks);
            
            var endTime = DateTime.UtcNow;
            var duration = endTime - startTime;
            
            return GenerateReport(scenario, results, duration);
        }
        
        private async Task RunUserSimulationAsync(
            LoadTestScenario scenario,
            ConcurrentBag<LoadTestResult> results,
            SemaphoreSlim semaphore,
            CancellationToken cancellationToken)
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                await semaphore.WaitAsync(cancellationToken);
                try
                {
                    var httpClient = await _httpClientPool.RentAsync();
                    try
                    {
                        var result = await scenario.TestAction(httpClient, cancellationToken);
                        results.Add(result);
                    }
                    finally
                    {
                        _httpClientPool.Return(httpClient);
                    }
                }
                catch (OperationCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    results.Add(new LoadTestResult
                    {
                        Success = false,
                        ErrorMessage = ex.Message,
                        ResponseTime = TimeSpan.Zero
                    });
                }
                finally
                {
                    semaphore.Release();
                }
            }
        }
        
        private LoadTestReport GenerateReport(LoadTestScenario scenario, ConcurrentBag<LoadTestResult> results, TimeSpan duration)
        {
            var resultsList = results.ToList();
            var successfulResults = resultsList.Where(r => r.Success).ToList();
            var responseTimes = successfulResults.Select(r => r.ResponseTime.TotalMilliseconds).OrderBy(x => x).ToList();
            
            return new LoadTestReport
            {
                TestName = scenario.Name,
                Duration = duration,
                TotalRequests = resultsList.Count,
                SuccessfulRequests = successfulResults.Count,
                FailedRequests = resultsList.Count - successfulResults.Count,
                RequestsPerSecond = resultsList.Count / duration.TotalSeconds,
                AverageResponseTime = responseTimes.Any() ? TimeSpan.FromMilliseconds(responseTimes.Average()) : TimeSpan.Zero,
                MedianResponseTime = responseTimes.Any() ? TimeSpan.FromMilliseconds(responseTimes[responseTimes.Count / 2]) : TimeSpan.Zero,
                P95ResponseTime = responseTimes.Any() ? TimeSpan.FromMilliseconds(responseTimes[(int)(responseTimes.Count * 0.95)]) : TimeSpan.Zero,
                P99ResponseTime = responseTimes.Any() ? TimeSpan.FromMilliseconds(responseTimes[(int)(responseTimes.Count * 0.99)]) : TimeSpan.Zero,
                MinResponseTime = responseTimes.Any() ? TimeSpan.FromMilliseconds(responseTimes.First()) : TimeSpan.Zero,
                MaxResponseTime = responseTimes.Any() ? TimeSpan.FromMilliseconds(responseTimes.Last()) : TimeSpan.Zero
            };
        }
    }
    
    public class LoadTestReport
    {
        public string TestName { get; set; }
        public TimeSpan Duration { get; set; }
        public int TotalRequests { get; set; }
        public int SuccessfulRequests { get; set; }
        public int FailedRequests { get; set; }
        public double RequestsPerSecond { get; set; }
        public TimeSpan AverageResponseTime { get; set; }
        public TimeSpan MedianResponseTime { get; set; }
        public TimeSpan P95ResponseTime { get; set; }
        public TimeSpan P99ResponseTime { get; set; }
        public TimeSpan MinResponseTime { get; set; }
        public TimeSpan MaxResponseTime { get; set; }
        
        public double SuccessRate => TotalRequests > 0 ? (double)SuccessfulRequests / TotalRequests * 100 : 0;
    }
}
```

---

## ⚠️ Common Performance Anti-Patterns {#anti-patterns}

### ❌ Anti-Patterns to Avoid

#### 1. **Inefficient Database Queries**

```csharp
// ❌ BAD: N+1 Query Problem
public class BadOrderService
{
    public async Task<List<OrderDto>> GetOrdersAsync()
    {
        var orders = await _context.Orders.ToListAsync();
        
        foreach (var order in orders)
        {
            // ❌ N+1 queries - executes one query per order
            order.Customer = await _context.Customers.FindAsync(order.CustomerId);
            order.Items = await _context.OrderItems.Where(i => i.OrderId == order.Id).ToListAsync();
        }
        
        return orders;
    }
}

// ✅ GOOD: Optimized with Include
public class GoodOrderService
{
    public async Task<List<OrderDto>> GetOrdersAsync()
    {
        return await _context.Orders
            .Include(o => o.Customer)
            .Include(o => o.Items)
            .ThenInclude(i => i.Product)
            .Select(o => new OrderDto
            {
                Id = o.Id,
                CustomerName = o.Customer.Name,
                Items = o.Items.Select(i => new OrderItemDto
                {
                    ProductName = i.Product.Name,
                    Quantity = i.Quantity,
                    Price = i.Price
                }).ToList()
            })
            .AsNoTracking()
            .ToListAsync();
    }
}
```

#### 2. **Memory Leaks and Resource Disposal**

```csharp
// ❌ BAD: Resource Leaks
public class BadResourceService
{
    public async Task ProcessDataAsync()
    {
        var httpClient = new HttpClient(); // ❌ Not disposed
        var response = await httpClient.GetAsync("https://api.example.com/data");
        
        var fileStream = File.OpenRead("largefile.txt"); // ❌ Not disposed
        var data = new byte[fileStream.Length];
        await fileStream.ReadAsync(data);
        
        // ❌ Resources not properly disposed
    }
}

// ✅ GOOD: Proper Resource Management
public class GoodResourceService
{
    private readonly HttpClient _httpClient; // ✅ Shared instance
    
    public GoodResourceService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }
    
    public async Task ProcessDataAsync()
    {
        var response = await _httpClient.GetAsync("https://api.example.com/data");
        
        using var fileStream = File.OpenRead("largefile.txt"); // ✅ Properly disposed
        var data = new byte[fileStream.Length];
        await fileStream.ReadAsync(data);
        
        // ✅ Resources automatically disposed
    }
}
```

#### 3. **Blocking Async Operations**

```csharp
// ❌ BAD: Blocking Async Operations
public class BadAsyncService
{
    public string GetDataSync()
    {
        // ❌ Blocks thread and can cause deadlocks
        var data = GetDataAsync().Result;
        return data;
    }
    
    public void ProcessData()
    {
        // ❌ Blocking in async context
        var data = _repository.GetDataAsync().GetAwaiter().GetResult();
        ProcessDataInternal(data);
    }
}

// ✅ GOOD: Proper Async Patterns
public class GoodAsyncService
{
    public async Task<string> GetDataAsync()
    {
        // ✅ Proper async/await usage
        var data = await _repository.GetDataAsync();
        return data;
    }
    
    public async Task ProcessDataAsync()
    {
        // ✅ Async all the way
        var data = await _repository.GetDataAsync();
        await ProcessDataInternalAsync(data);
    }
}
```

---

## 🔗 Related Topics

### Prerequisites

- [System Design Fundamentals](./04_System-Design-Fundamentals.md)
- [API Design Principles](./10_API-Design-Principles.md)
- [Microservices Architecture](./05_Microservices-Architecture.md)

### Builds Upon

- Caching strategies and distributed systems
- Database optimization and indexing
- Concurrent programming and async patterns
- Monitoring and observability practices

### Enables

- High-performance system architecture
- Scalable application design
- Production-ready optimization strategies
- Performance monitoring and alerting

### Cross-References

- **Testing**: [Testing Strategies](./13_Testing-Strategies.md) for performance testing
- **Monitoring**: Application Performance Monitoring (APM) integration
- **Infrastructure**: Load balancing and auto-scaling patterns
- **Security**: Performance vs security trade-offs

---

## 📚 Summary

Performance optimization is a critical discipline that encompasses multiple layers of system design and implementation. Key success factors include:

1. **Measurement-Driven Approach**: Always measure before optimizing and validate improvements
2. **Multi-Layer Strategy**: Optimize at application, database, infrastructure, and network levels
3. **Caching Excellence**: Implement intelligent caching strategies with proper invalidation
4. **Resource Management**: Efficient memory usage and proper resource disposal
5. **Async Mastery**: Non-blocking operations and concurrent processing patterns
6. **Monitoring Integration**: Comprehensive observability and performance tracking

**Performance Optimization Principles**:

- **Profile First**: Identify actual bottlenecks before optimizing
- **Think in Systems**: Consider end-to-end performance impact
- **Cache Intelligently**: Right data, right level, right expiration
- **Scale Horizontally**: Design for distributed scalability
- **Monitor Continuously**: Real-time performance tracking and alerting

**When to Apply Performance Optimization**:

- Applications with high throughput requirements (>1000 RPS)
- Systems with strict latency requirements (<100ms response time)
- Resource-constrained environments
- Growing user bases requiring scalability
- Mission-critical applications requiring 99.9%+ availability

**Next Steps**: Apply these patterns incrementally, starting with measurement and profiling, then implementing optimizations based on actual performance data and business requirements.
