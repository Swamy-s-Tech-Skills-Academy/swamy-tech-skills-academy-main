# 08_Design-Patterns-Part3-Singleton-Pattern

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Builder Pattern (Part 2), Thread safety concepts  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Singleton Pattern and understand when to use (and avoid) it
- Implement thread-safe Singleton variants including lazy initialization
- Apply Singleton alternatives that provide better testability and flexibility
- Design dependency injection patterns that eliminate most Singleton needs

## 📋 Content Sections

### Quick Overview (5 minutes)

**Singleton Pattern**: *"Ensure a class has only one instance and provide a global point of access to it."*

**Core Problem**: Some classes should have exactly one instance (database connection, logger, configuration).

```text
❌ MULTIPLE INSTANCES PROBLEM
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ new Logger()    │    │ new Logger()    │    │ new Logger()    │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ - Different     │    │ - Different     │    │ - Different     │
│   file handles  │    │   file handles  │    │   file handles  │
│ - Memory waste  │    │ - Memory waste  │    │ - Memory waste  │
│ - Config drift  │    │ - Config drift  │    │ - Config drift  │
└─────────────────┘    └─────────────────┘    └─────────────────┘

✅ SINGLETON PATTERN SOLUTION
┌─────────────────────────────────┐
│        Logger (Singleton)       │
├─────────────────────────────────┤
│ - static instance               │
│ - private constructor           │
│ + static GetInstance()          │
│                                 │
│ All calls return same instance  │
└─────────────────────────────────┘
        ↑           ↑           ↑
   Client A    Client B    Client C
```

**⚠️ Singleton Caution**: While useful, Singletons can create tight coupling and testing difficulties. Modern alternatives (DI containers, static classes) often provide better solutions.

**Common Singleton Use Cases**:

- **Configuration managers** - System-wide settings
- **Logging services** - Centralized logging
- **Cache managers** - Application-wide caching
- **Database connection pools** - Resource management

### Core Concepts (15 minutes)

#### Thread-Safe Singleton Implementations

#### Implementation 1: Lazy Initialization with Double-Check Locking

```csharp
public sealed class ConfigurationManager
{
    private static ConfigurationManager _instance;
    private static readonly object _lock = new object();
    
    private readonly Dictionary<string, string> _settings;
    private readonly string _configFilePath;
    
    // Private constructor prevents external instantiation
    private ConfigurationManager()
    {
        _configFilePath = "appsettings.json";
        _settings = new Dictionary<string, string>();
        LoadConfiguration();
    }
    
    // Thread-safe singleton access
    public static ConfigurationManager Instance
    {
        get
        {
            // First check without locking for performance
            if (_instance == null)
            {
                lock (_lock)
                {
                    // Second check inside lock
                    if (_instance == null)
                    {
                        _instance = new ConfigurationManager();
                    }
                }
            }
            return _instance;
        }
    }
    
    public string GetSetting(string key)
    {
        return _settings.TryGetValue(key, out var value) ? value : null;
    }
    
    public void SetSetting(string key, string value)
    {
        lock (_lock)
        {
            _settings[key] = value;
            SaveConfiguration();
        }
    }
    
    public T GetSetting<T>(string key, T defaultValue = default(T))
    {
        if (!_settings.TryGetValue(key, out var stringValue))
            return defaultValue;
            
        try
        {
            return (T)Convert.ChangeType(stringValue, typeof(T));
        }
        catch (Exception)
        {
            return defaultValue;
        }
    }
    
    private void LoadConfiguration()
    {
        try
        {
            if (File.Exists(_configFilePath))
            {
                var json = File.ReadAllText(_configFilePath);
                var config = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(json);
                
                foreach (var kvp in config)
                {
                    _settings[kvp.Key] = kvp.Value?.ToString() ?? "";
                }
            }
        }
        catch (Exception ex)
        {
            // Log error but don't fail construction
            Console.WriteLine($"Warning: Could not load configuration: {ex.Message}");
        }
    }
    
    private void SaveConfiguration()
    {
        try
        {
            var json = System.Text.Json.JsonSerializer.Serialize(_settings, new JsonSerializerOptions
            {
                WriteIndented = true
            });
            File.WriteAllText(_configFilePath, json);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Warning: Could not save configuration: {ex.Message}");
        }
    }
    
    // Method to reset singleton (useful for testing)
    public static void Reset()
    {
        lock (_lock)
        {
            _instance = null;
        }
    }
}

// Usage example
public class ConfigurationExample
{
    public void DemonstrateConfiguration()
    {
        // All instances are the same object
        var config1 = ConfigurationManager.Instance;
        var config2 = ConfigurationManager.Instance;
        
        Console.WriteLine($"Same instance: {ReferenceEquals(config1, config2)}"); // True
        
        // Set and get configuration values
        config1.SetSetting("DatabaseTimeout", "30");
        config1.SetSetting("LogLevel", "Information");
        config1.SetSetting("MaxRetries", "3");
        
        // Read from different reference - same values
        var timeout = config2.GetSetting<int>("DatabaseTimeout");
        var logLevel = config2.GetSetting("LogLevel");
        var maxRetries = config2.GetSetting<int>("MaxRetries", 1);
        
        Console.WriteLine($"Database timeout: {timeout} seconds");
        Console.WriteLine($"Log level: {logLevel}");
        Console.WriteLine($"Max retries: {maxRetries}");
    }
}
```

#### Implementation 2: Lazy&lt;T&gt; Pattern (Recommended)

```csharp
public sealed class Logger
{
    // Lazy<T> provides thread-safe lazy initialization
    private static readonly Lazy<Logger> _instance = new Lazy<Logger>(() => new Logger());
    
    private readonly string _logFilePath;
    private readonly object _logLock = new object();
    
    private Logger()
    {
        _logFilePath = Path.Combine("logs", $"app-{DateTime.Now:yyyy-MM-dd}.log");
        EnsureLogDirectoryExists();
    }
    
    public static Logger Instance => _instance.Value;
    
    public void LogInfo(string message)
    {
        WriteLog("INFO", message);
    }
    
    public void LogWarning(string message)
    {
        WriteLog("WARNING", message);
    }
    
    public void LogError(string message, Exception exception = null)
    {
        var errorMessage = exception != null 
            ? $"{message} - Exception: {exception.Message}" 
            : message;
        WriteLog("ERROR", errorMessage);
    }
    
    public void LogDebug(string message)
    {
        #if DEBUG
        WriteLog("DEBUG", message);
        #endif
    }
    
    private void WriteLog(string level, string message)
    {
        var logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [{level}] {message}";
        
        // Thread-safe file writing
        lock (_logLock)
        {
            try
            {
                File.AppendAllText(_logFilePath, logEntry + Environment.NewLine);
                
                // Also log to console in development
                #if DEBUG
                Console.WriteLine(logEntry);
                #endif
            }
            catch (Exception ex)
            {
                // Fallback to console if file writing fails
                Console.WriteLine($"Logging failed: {ex.Message}");
                Console.WriteLine($"Original log: {logEntry}");
            }
        }
    }
    
    private void EnsureLogDirectoryExists()
    {
        var logDirectory = Path.GetDirectoryName(_logFilePath);
        if (!Directory.Exists(logDirectory))
        {
            Directory.CreateDirectory(logDirectory);
        }
    }
}

// Usage across the application
public class BusinessService
{
    public void ProcessOrder(int orderId)
    {
        var logger = Logger.Instance;
        
        logger.LogInfo($"Starting order processing for order {orderId}");
        
        try
        {
            // Business logic here
            Thread.Sleep(100); // Simulate processing
            
            logger.LogInfo($"Order {orderId} processed successfully");
        }
        catch (Exception ex)
        {
            logger.LogError($"Failed to process order {orderId}", ex);
            throw;
        }
    }
}
```

#### Implementation 3: Static Constructor (Eager Initialization)

```csharp
public sealed class CacheManager
{
    // Static constructor ensures thread-safe initialization
    private static readonly CacheManager _instance = new CacheManager();
    
    private readonly Dictionary<string, CacheEntry> _cache;
    private readonly Timer _cleanupTimer;
    private readonly object _cacheLock = new object();
    
    // Static constructor runs exactly once
    static CacheManager()
    {
        // Static constructor guarantees thread safety
    }
    
    private CacheManager()
    {
        _cache = new Dictionary<string, CacheEntry>();
        
        // Set up cleanup timer to run every 5 minutes
        _cleanupTimer = new Timer(CleanupExpiredEntries, null, TimeSpan.FromMinutes(5), TimeSpan.FromMinutes(5));
    }
    
    public static CacheManager Instance => _instance;
    
    public void Set<T>(string key, T value, TimeSpan? expiration = null)
    {
        if (string.IsNullOrEmpty(key))
            throw new ArgumentException("Cache key cannot be null or empty", nameof(key));
            
        var expirationTime = expiration.HasValue 
            ? DateTime.UtcNow.Add(expiration.Value)
            : DateTime.UtcNow.AddHours(1); // Default 1 hour expiration
        
        var entry = new CacheEntry
        {
            Value = value,
            ExpirationTime = expirationTime,
            LastAccessed = DateTime.UtcNow
        };
        
        lock (_cacheLock)
        {
            _cache[key] = entry;
        }
    }
    
    public T Get<T>(string key, T defaultValue = default(T))
    {
        if (string.IsNullOrEmpty(key))
            return defaultValue;
            
        lock (_cacheLock)
        {
            if (_cache.TryGetValue(key, out var entry))
            {
                if (entry.ExpirationTime > DateTime.UtcNow)
                {
                    entry.LastAccessed = DateTime.UtcNow;
                    return entry.Value is T typedValue ? typedValue : defaultValue;
                }
                else
                {
                    // Entry expired, remove it
                    _cache.Remove(key);
                }
            }
        }
        
        return defaultValue;
    }
    
    public bool TryGet<T>(string key, out T value)
    {
        value = Get<T>(key);
        return !EqualityComparer<T>.Default.Equals(value, default(T));
    }
    
    public void Remove(string key)
    {
        if (!string.IsNullOrEmpty(key))
        {
            lock (_cacheLock)
            {
                _cache.Remove(key);
            }
        }
    }
    
    public void Clear()
    {
        lock (_cacheLock)
        {
            _cache.Clear();
        }
    }
    
    public int Count
    {
        get
        {
            lock (_cacheLock)
            {
                return _cache.Count;
            }
        }
    }
    
    private void CleanupExpiredEntries(object state)
    {
        var expiredKeys = new List<string>();
        var now = DateTime.UtcNow;
        
        lock (_cacheLock)
        {
            foreach (var kvp in _cache)
            {
                if (kvp.Value.ExpirationTime <= now)
                {
                    expiredKeys.Add(kvp.Key);
                }
            }
            
            foreach (var key in expiredKeys)
            {
                _cache.Remove(key);
            }
        }
        
        if (expiredKeys.Count > 0)
        {
            Console.WriteLine($"Cache cleanup: Removed {expiredKeys.Count} expired entries");
        }
    }
    
    private class CacheEntry
    {
        public object Value { get; set; }
        public DateTime ExpirationTime { get; set; }
        public DateTime LastAccessed { get; set; }
    }
}

// Usage example
public class CacheExample
{
    public void DemonstrateCaching()
    {
        var cache = CacheManager.Instance;
        
        // Store various types of data
        cache.Set("user:123", new { Id = 123, Name = "John Doe" }, TimeSpan.FromMinutes(30));
        cache.Set("api:weather", "Sunny, 75°F", TimeSpan.FromMinutes(10));
        cache.Set("config:theme", "dark");
        
        // Retrieve data
        var user = cache.Get<object>("user:123");
        var weather = cache.Get<string>("api:weather");
        var theme = cache.Get<string>("config:theme");
        
        Console.WriteLine($"User: {user}");
        Console.WriteLine($"Weather: {weather}");
        Console.WriteLine($"Theme: {theme}");
        Console.WriteLine($"Cache count: {cache.Count}");
    }
}
```

### Practical Implementation (8 minutes)

#### Singleton Alternatives and Modern Approaches

#### Dependency Injection Alternative

```csharp
// Instead of Singleton, use DI container registration
public interface IConfigurationService
{
    string GetSetting(string key);
    T GetSetting<T>(string key, T defaultValue = default(T));
    void SetSetting(string key, string value);
}

public class ConfigurationService : IConfigurationService
{
    private readonly Dictionary<string, string> _settings;
    
    // Regular constructor - DI container manages instance lifetime
    public ConfigurationService()
    {
        _settings = new Dictionary<string, string>();
        LoadConfiguration();
    }
    
    public string GetSetting(string key)
    {
        return _settings.TryGetValue(key, out var value) ? value : null;
    }
    
    public T GetSetting<T>(string key, T defaultValue = default(T))
    {
        if (!_settings.TryGetValue(key, out var stringValue))
            return defaultValue;
            
        try
        {
            return (T)Convert.ChangeType(stringValue, typeof(T));
        }
        catch
        {
            return defaultValue;
        }
    }
    
    public void SetSetting(string key, string value)
    {
        _settings[key] = value;
    }
    
    private void LoadConfiguration()
    {
        // Load configuration from file, environment, etc.
        _settings["DatabaseTimeout"] = "30";
        _settings["LogLevel"] = "Information";
    }
}

// Dependency injection setup
public class ServiceConfiguration
{
    public static void ConfigureServices(IServiceCollection services)
    {
        // Register as singleton through DI container
        services.AddSingleton<IConfigurationService, ConfigurationService>();
        
        // Other services can depend on IConfigurationService
        services.AddScoped<DatabaseService>();
        services.AddScoped<BusinessService>();
    }
}

// Services receive configuration through constructor injection
public class DatabaseService
{
    private readonly IConfigurationService _config;
    
    public DatabaseService(IConfigurationService config)
    {
        _config = config;
    }
    
    public void Connect()
    {
        var timeout = _config.GetSetting<int>("DatabaseTimeout", 30);
        Console.WriteLine($"Connecting to database with timeout: {timeout}s");
    }
}
```

#### Testable Singleton Pattern

```csharp
// Singleton that supports dependency injection for testing
public interface IApplicationLogger
{
    void LogInfo(string message);
    void LogError(string message, Exception exception = null);
}

public sealed class ApplicationLogger : IApplicationLogger
{
    private static readonly Lazy<ApplicationLogger> _instance = new Lazy<ApplicationLogger>(() => new ApplicationLogger());
    
    private readonly ILogWriter _logWriter;
    
    private ApplicationLogger() : this(new FileLogWriter())
    {
    }
    
    // Constructor for testing - allows dependency injection
    internal ApplicationLogger(ILogWriter logWriter)
    {
        _logWriter = logWriter ?? throw new ArgumentNullException(nameof(logWriter));
    }
    
    public static IApplicationLogger Instance => _instance.Value;
    
    // Factory method for testing
    public static IApplicationLogger CreateWithWriter(ILogWriter logWriter)
    {
        return new ApplicationLogger(logWriter);
    }
    
    public void LogInfo(string message)
    {
        _logWriter.WriteLog("INFO", message);
    }
    
    public void LogError(string message, Exception exception = null)
    {
        var errorMessage = exception != null 
            ? $"{message} - Exception: {exception.Message}"
            : message;
        _logWriter.WriteLog("ERROR", errorMessage);
    }
}

// Abstraction for log writing
public interface ILogWriter
{
    void WriteLog(string level, string message);
}

public class FileLogWriter : ILogWriter
{
    private readonly string _logFilePath;
    private readonly object _lock = new object();
    
    public FileLogWriter()
    {
        _logFilePath = Path.Combine("logs", $"app-{DateTime.Now:yyyy-MM-dd}.log");
        EnsureLogDirectoryExists();
    }
    
    public void WriteLog(string level, string message)
    {
        var logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [{level}] {message}";
        
        lock (_lock)
        {
            File.AppendAllText(_logFilePath, logEntry + Environment.NewLine);
        }
    }
    
    private void EnsureLogDirectoryExists()
    {
        var logDirectory = Path.GetDirectoryName(_logFilePath);
        if (!Directory.Exists(logDirectory))
        {
            Directory.CreateDirectory(logDirectory);
        }
    }
}

// Mock implementation for testing
public class MockLogWriter : ILogWriter
{
    public List<LogEntry> WrittenLogs { get; } = new List<LogEntry>();
    
    public void WriteLog(string level, string message)
    {
        WrittenLogs.Add(new LogEntry
        {
            Level = level,
            Message = message,
            Timestamp = DateTime.UtcNow
        });
    }
}

public class LogEntry
{
    public string Level { get; set; }
    public string Message { get; set; }
    public DateTime Timestamp { get; set; }
}

// Unit tests using testable singleton
[Test]
public void TestLoggingBehavior()
{
    // Arrange
    var mockWriter = new MockLogWriter();
    var logger = ApplicationLogger.CreateWithWriter(mockWriter);
    
    // Act
    logger.LogInfo("Test info message");
    logger.LogError("Test error message", new InvalidOperationException("Test exception"));
    
    // Assert
    Assert.AreEqual(2, mockWriter.WrittenLogs.Count);
    Assert.AreEqual("INFO", mockWriter.WrittenLogs[0].Level);
    Assert.AreEqual("Test info message", mockWriter.WrittenLogs[0].Message);
    Assert.AreEqual("ERROR", mockWriter.WrittenLogs[1].Level);
    Assert.IsTrue(mockWriter.WrittenLogs[1].Message.Contains("Test error message"));
}
```

#### Registry Pattern as Singleton Alternative

```csharp
// Service registry pattern - manages multiple singleton-like services
public class ServiceRegistry
{
    private static readonly Lazy<ServiceRegistry> _instance = new Lazy<ServiceRegistry>(() => new ServiceRegistry());
    
    private readonly Dictionary<Type, object> _services = new Dictionary<Type, object>();
    private readonly Dictionary<Type, Func<object>> _factories = new Dictionary<Type, Func<object>>();
    private readonly object _lock = new object();
    
    private ServiceRegistry() { }
    
    public static ServiceRegistry Instance => _instance.Value;
    
    public void Register<T>(T service) where T : class
    {
        lock (_lock)
        {
            _services[typeof(T)] = service;
        }
    }
    
    public void Register<T>(Func<T> factory) where T : class
    {
        lock (_lock)
        {
            _factories[typeof(T)] = () => factory();
        }
    }
    
    public T GetService<T>() where T : class
    {
        lock (_lock)
        {
            // Check if instance already exists
            if (_services.TryGetValue(typeof(T), out var existingService))
            {
                return (T)existingService;
            }
            
            // Check if factory exists
            if (_factories.TryGetValue(typeof(T), out var factory))
            {
                var newService = (T)factory();
                _services[typeof(T)] = newService; // Cache the instance
                return newService;
            }
            
            throw new InvalidOperationException($"Service of type {typeof(T).Name} is not registered");
        }
    }
    
    public bool IsRegistered<T>() where T : class
    {
        lock (_lock)
        {
            return _services.ContainsKey(typeof(T)) || _factories.ContainsKey(typeof(T));
        }
    }
}

// Usage example
public class RegistryExample
{
    public void SetupServices()
    {
        var registry = ServiceRegistry.Instance;
        
        // Register services
        registry.Register<IConfigurationService>(new ConfigurationService());
        registry.Register<IApplicationLogger>(() => new ApplicationLogger(new FileLogWriter()));
        
        // Use services
        var config = registry.GetService<IConfigurationService>();
        var logger = registry.GetService<IApplicationLogger>();
        
        logger.LogInfo("Services initialized successfully");
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Singleton Pattern Benefits**:

- ✅ **Controlled instantiation**: Exactly one instance guaranteed
- ✅ **Global access point**: Available throughout application
- ✅ **Resource management**: Shared resources like connections, caches
- ✅ **State consistency**: Single source of truth for configuration

**Singleton Pattern Drawbacks**:

- ❌ **Testing difficulties**: Hard to mock, shared state between tests
- ❌ **Tight coupling**: Global dependencies make code less flexible
- ❌ **Thread safety complexity**: Requires careful synchronization
- ❌ **Violation of Single Responsibility**: Often manages lifetime + functionality

**Modern Alternatives to Consider**:

1. **Dependency Injection containers** - Better lifecycle management
2. **Static classes** - For stateless utility functions
3. **Registry patterns** - Multiple singleton-like services
4. **Scoped instances** - Single instance per request/operation

**Best Practices**:

- Use `Lazy<T>` for thread-safe lazy initialization
- Prefer DI container registration over manual singletons
- Design for testability with constructor injection
- Consider if you really need global state

### Next Steps

**Immediate Actions**:

- Evaluate existing Singletons for DI container conversion
- Implement thread-safe patterns using `Lazy<T>`
- Continue to **Structural Patterns**: Adapter, Decorator, Facade

**Advanced Topics**:

- Multiton pattern (registry of singletons)
- Singleton in distributed systems
- Memory-efficient singleton implementations

## 🔗 Related Topics

**Prerequisites**: Builder Pattern (Part 2), Thread safety fundamentals  
**Builds Upon**: Lazy initialization, Object lifecycle management  
**Enables**: Structural Patterns, Dependency injection mastery, Service registry patterns  
**Related**: Factory patterns, Dependency injection, Service locator pattern
