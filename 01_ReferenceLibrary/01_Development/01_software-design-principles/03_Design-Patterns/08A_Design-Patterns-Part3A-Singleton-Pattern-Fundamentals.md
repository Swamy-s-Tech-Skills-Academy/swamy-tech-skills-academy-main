# 08A_Design-Patterns-Part3A-Singleton-Pattern-Fundamentals

**Learning Level**: Intermediate  
**Prerequisites**: Builder Pattern, Basic thread safety concepts  
**Estimated Time**: Part A of 3 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master the Singleton Pattern fundamentals and understand when to use it appropriately
- Implement thread-safe Singleton variants with different initialization strategies
- Compare lazy vs eager initialization trade-offs for memory and performance
- Apply double-check locking and static constructor patterns for production code

## 📋 Content Sections (27-Minute Structure)

### Singleton Pattern Overview (5 minutes)

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

**Appropriate Singleton Use Cases**:

- **Configuration managers** - System-wide settings that must be consistent
- **Logging services** - Centralized logging to prevent file handle conflicts
- **Cache managers** - Application-wide caching with unified eviction policies
- **Database connection pools** - Resource management requiring precise control

**When NOT to Use Singleton**:

- **When you need multiple configurations** - Different modules may need different settings
- **In unit testing scenarios** - Makes mocking and isolation difficult
- **When state varies by context** - User sessions, request-specific data
- **For simple utility functions** - Static classes often work better

### Thread-Safe Implementation: Double-Check Locking (8 minutes)

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
    
    // Thread-safe singleton access with double-check locking
    public static ConfigurationManager Instance
    {
        get
        {
            // First check without locking for performance
            if (_instance == null)
            {
                lock (_lock)
                {
                    // Second check inside lock to prevent race conditions
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
    
    public bool HasSetting(string key)
    {
        return _settings.ContainsKey(key);
    }
    
    public void RemoveSetting(string key)
    {
        lock (_lock)
        {
            if (_settings.Remove(key))
            {
                SaveConfiguration();
            }
        }
    }
    
    public IReadOnlyDictionary<string, string> GetAllSettings()
    {
        return new Dictionary<string, string>(_settings);
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
            else
            {
                // Create default configuration if file doesn't exist
                SetDefaultConfiguration();
                SaveConfiguration();
            }
        }
        catch (Exception ex)
        {
            // Log error but don't fail construction
            Console.WriteLine($"Warning: Could not load configuration: {ex.Message}");
            SetDefaultConfiguration();
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
    
    private void SetDefaultConfiguration()
    {
        _settings["Environment"] = "Development";
        _settings["LogLevel"] = "Information";
        _settings["ConnectionTimeout"] = "30";
        _settings["MaxRetries"] = "3";
    }
}
```

**Double-Check Locking Benefits**:

- **Performance** - Avoids locking after first initialization
- **Thread Safety** - Prevents multiple instance creation in concurrent scenarios
- **Lazy Loading** - Instance created only when first accessed
- **Memory Efficient** - No unnecessary object creation

**Usage Example**:

```csharp
// Thread-safe usage across multiple threads
var config = ConfigurationManager.Instance;
config.SetSetting("DatabaseUrl", "server=localhost;database=myapp");

// Different thread can safely access the same instance
var dbUrl = ConfigurationManager.Instance.GetSetting("DatabaseUrl");
var timeout = ConfigurationManager.Instance.GetSetting<int>("ConnectionTimeout", 30);
```

### Modern Lazy&lt;T&gt; Implementation (7 minutes)

#### Implementation 2: Lazy&lt;T&gt; Pattern (Recommended)

```csharp
public sealed class LoggingService
{
    // Lazy<T> handles thread safety automatically
    private static readonly Lazy<LoggingService> _lazyInstance = 
        new Lazy<LoggingService>(() => new LoggingService());
    
    private readonly string _logFilePath;
    private readonly object _fileLock = new object();
    
    private LoggingService()
    {
        _logFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "application.log");
        
        // Ensure log directory exists
        var directory = Path.GetDirectoryName(_logFilePath);
        if (!Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory);
        }
        
        // Write startup message
        WriteToFile("=== Logging Service Initialized ===");
    }
    
    public static LoggingService Instance => _lazyInstance.Value;
    
    public enum LogLevel
    {
        Debug = 0,
        Information = 1,
        Warning = 2,
        Error = 3,
        Critical = 4
    }
    
    public void LogDebug(string message, params object[] args)
    {
        Log(LogLevel.Debug, message, args);
    }
    
    public void LogInformation(string message, params object[] args)
    {
        Log(LogLevel.Information, message, args);
    }
    
    public void LogWarning(string message, params object[] args)
    {
        Log(LogLevel.Warning, message, args);
    }
    
    public void LogError(string message, Exception exception = null, params object[] args)
    {
        var fullMessage = string.Format(message, args);
        if (exception != null)
        {
            fullMessage += $" | Exception: {exception.Message} | StackTrace: {exception.StackTrace}";
        }
        Log(LogLevel.Error, fullMessage);
    }
    
    public void LogCritical(string message, Exception exception = null, params object[] args)
    {
        var fullMessage = string.Format(message, args);
        if (exception != null)
        {
            fullMessage += $" | Exception: {exception.Message} | StackTrace: {exception.StackTrace}";
        }
        Log(LogLevel.Critical, fullMessage);
    }
    
    private void Log(LogLevel level, string message, params object[] args)
    {
        var formattedMessage = args.Length > 0 ? string.Format(message, args) : message;
        var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
        var threadId = Thread.CurrentThread.ManagedThreadId;
        var logEntry = $"[{timestamp}] [{level.ToString().ToUpper()}] [Thread-{threadId}] {formattedMessage}";
        
        // Write to console for immediate feedback
        ConsoleColor originalColor = Console.ForegroundColor;
        Console.ForegroundColor = GetConsoleColor(level);
        Console.WriteLine(logEntry);
        Console.ForegroundColor = originalColor;
        
        // Write to file with thread safety
        WriteToFile(logEntry);
    }
    
    private void WriteToFile(string logEntry)
    {
        lock (_fileLock)
        {
            try
            {
                using (var writer = new StreamWriter(_logFilePath, append: true))
                {
                    writer.WriteLine(logEntry);
                    writer.Flush();
                }
            }
            catch (Exception ex)
            {
                // Fallback to console if file write fails
                Console.WriteLine($"Failed to write to log file: {ex.Message}");
            }
        }
    }
    
    private static ConsoleColor GetConsoleColor(LogLevel level)
    {
        return level switch
        {
            LogLevel.Debug => ConsoleColor.Gray,
            LogLevel.Information => ConsoleColor.White,
            LogLevel.Warning => ConsoleColor.Yellow,
            LogLevel.Error => ConsoleColor.Red,
            LogLevel.Critical => ConsoleColor.Magenta,
            _ => ConsoleColor.White
        };
    }
    
    public void FlushLogs()
    {
        // Force any pending writes to complete
        lock (_fileLock)
        {
            // File is already flushed in WriteToFile, but this provides explicit control
        }
    }
    
    public string GetLogFilePath() => _logFilePath;
    
    public long GetLogFileSize()
    {
        try
        {
            return new FileInfo(_logFilePath).Length;
        }
        catch
        {
            return 0;
        }
    }
}
```

**Lazy&lt;T&gt; Advantages**:

- **Simplified Code** - No manual double-check locking required
- **Built-in Thread Safety** - .NET Framework handles synchronization
- **Exception Safety** - Properly handles exceptions during construction
- **Performance** - Optimized for high-concurrency scenarios

**Usage Example**:

```csharp
// Simple and safe usage
var logger = LoggingService.Instance;
logger.LogInformation("Application started successfully");
logger.LogWarning("Configuration file not found, using defaults");

// Exception logging
try
{
    // Some operation that might fail
    throw new InvalidOperationException("Sample error");
}
catch (Exception ex)
{
    LoggingService.Instance.LogError("Operation failed", ex);
}
```

### Static Constructor Pattern (7 minutes)

#### Implementation 3: Static Constructor (Eager Initialization)

```csharp
public sealed class CacheManager
{
    // Static constructor ensures thread-safe, eager initialization
    private static readonly CacheManager _instance = new CacheManager();
    
    // Static constructor called automatically before first access
    static CacheManager() { }
    
    private readonly ConcurrentDictionary<string, CacheEntry> _cache;
    private readonly Timer _cleanupTimer;
    private readonly TimeSpan _defaultExpiration;
    
    private CacheManager()
    {
        _cache = new ConcurrentDictionary<string, CacheEntry>();
        _defaultExpiration = TimeSpan.FromMinutes(15);
        
        // Setup automatic cleanup timer (every 5 minutes)
        _cleanupTimer = new Timer(CleanupExpiredEntries, null, 
            TimeSpan.FromMinutes(5), TimeSpan.FromMinutes(5));
    }
    
    public static CacheManager Instance => _instance;
    
    public void Set<T>(string key, T value, TimeSpan? expiration = null)
    {
        if (string.IsNullOrEmpty(key))
            throw new ArgumentException("Cache key cannot be null or empty", nameof(key));
        
        var entry = new CacheEntry
        {
            Value = value,
            ExpiresAt = DateTime.UtcNow.Add(expiration ?? _defaultExpiration),
            CreatedAt = DateTime.UtcNow
        };
        
        _cache.AddOrUpdate(key, entry, (k, oldEntry) => entry);
    }
    
    public T Get<T>(string key, T defaultValue = default(T))
    {
        if (string.IsNullOrEmpty(key))
            return defaultValue;
        
        if (_cache.TryGetValue(key, out var entry))
        {
            if (DateTime.UtcNow <= entry.ExpiresAt)
            {
                entry.LastAccessedAt = DateTime.UtcNow;
                return (T)entry.Value;
            }
            else
            {
                // Remove expired entry
                _cache.TryRemove(key, out _);
            }
        }
        
        return defaultValue;
    }
    
    public bool TryGet<T>(string key, out T value)
    {
        value = default(T);
        
        if (string.IsNullOrEmpty(key))
            return false;
        
        if (_cache.TryGetValue(key, out var entry) && DateTime.UtcNow <= entry.ExpiresAt)
        {
            entry.LastAccessedAt = DateTime.UtcNow;
            value = (T)entry.Value;
            return true;
        }
        
        // Remove expired entry if found
        if (entry != null)
        {
            _cache.TryRemove(key, out _);
        }
        
        return false;
    }
    
    public void Remove(string key)
    {
        if (!string.IsNullOrEmpty(key))
        {
            _cache.TryRemove(key, out _);
        }
    }
    
    public void Clear()
    {
        _cache.Clear();
    }
    
    public bool ContainsKey(string key)
    {
        if (string.IsNullOrEmpty(key))
            return false;
        
        if (_cache.TryGetValue(key, out var entry))
        {
            if (DateTime.UtcNow <= entry.ExpiresAt)
            {
                return true;
            }
            else
            {
                // Remove expired entry
                _cache.TryRemove(key, out _);
                return false;
            }
        }
        
        return false;
    }
    
    public CacheStatistics GetStatistics()
    {
        var now = DateTime.UtcNow;
        var entries = _cache.Values.ToList();
        
        var validEntries = entries.Where(e => now <= e.ExpiresAt).ToList();
        var expiredEntries = entries.Count - validEntries.Count;
        
        return new CacheStatistics
        {
            TotalEntries = validEntries.Count,
            ExpiredEntries = expiredEntries,
            OldestEntryAge = validEntries.Any() ? 
                now.Subtract(validEntries.Min(e => e.CreatedAt)) : TimeSpan.Zero,
            LastCleanupTime = _lastCleanupTime
        };
    }
    
    private DateTime _lastCleanupTime = DateTime.UtcNow;
    
    private void CleanupExpiredEntries(object state)
    {
        var now = DateTime.UtcNow;
        var expiredKeys = new List<string>();
        
        foreach (var kvp in _cache)
        {
            if (now > kvp.Value.ExpiresAt)
            {
                expiredKeys.Add(kvp.Key);
            }
        }
        
        foreach (var key in expiredKeys)
        {
            _cache.TryRemove(key, out _);
        }
        
        _lastCleanupTime = now;
    }
    
    private class CacheEntry
    {
        public object Value { get; set; }
        public DateTime ExpiresAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime LastAccessedAt { get; set; }
    }
    
    public class CacheStatistics
    {
        public int TotalEntries { get; set; }
        public int ExpiredEntries { get; set; }
        public TimeSpan OldestEntryAge { get; set; }
        public DateTime LastCleanupTime { get; set; }
    }
}
```

**Static Constructor Benefits**:

- **Simplicity** - No complex locking logic required
- **Guaranteed Thread Safety** - CLR ensures static constructor runs once
- **Eager Initialization** - Instance ready immediately when class is first referenced
- **Exception Handling** - Any construction exceptions are properly managed by CLR

**Trade-offs**:

- **Memory Usage** - Instance created even if never used
- **Startup Time** - Initialization happens at first class access
- **No Lazy Benefits** - Cannot defer expensive operations until needed

**Usage Example**:

```csharp
// Simple and reliable usage
var cache = CacheManager.Instance;

// Store frequently accessed data
cache.Set("user_preferences_123", userPrefs, TimeSpan.FromHours(2));
cache.Set("product_catalog", products);

// Retrieve with fallback
var userPrefs = cache.Get("user_preferences_123", new UserPreferences());

// Check cache statistics
var stats = cache.GetStatistics();
Console.WriteLine($"Cache has {stats.TotalEntries} valid entries");
```

### Implementation Comparison & Next Steps (2 minutes)

**When to Choose Each Implementation**:

| Pattern | Best For | Performance | Complexity |
|---------|----------|-------------|------------|
| **Double-Check Locking** | Heavy initialization, memory-conscious | High | Medium |
| **Lazy&lt;T&gt;** | Most scenarios, .NET 4.0+ | High | Low |
| **Static Constructor** | Simple cases, eager initialization | Medium | Low |

**Performance Characteristics**:

- **Lazy&lt;T&gt;**: Best overall performance and simplicity
- **Double-Check**: Minimal memory overhead, good for resource-constrained environments
- **Static Constructor**: Predictable timing, good for always-needed services

**Next Learning Steps**:

- **[Part B: Modern Alternatives](08B_Design-Patterns-Part3B-Singleton-Pattern-Modern.md)** - Dependency injection and testable patterns
- **[Part C: Registry Patterns](08C_Design-Patterns-Part3C-Singleton-Pattern-Registry.md)** - Service registry alternatives

## 🔗 Related Topics

**Prerequisites**:

- [Builder Pattern Parts A-D](07A_Design-Patterns-Part2A-Builder-Pattern-Fundamentals.md) - Object construction patterns
- Basic multithreading and thread safety concepts

**Builds Upon**:

- Lazy initialization patterns
- Thread safety and locking mechanisms
- Static class design principles

**Enables**:

- [Dependency Injection Patterns](../../patterns/dependency-injection/) for better testability
- [Service Registry Patterns](../../patterns/service-registry/) for multiple instance management  
- [Configuration Management](../../patterns/configuration-management/) for enterprise applications

**Next Patterns**:

- [Abstract Factory Pattern](06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals.md) - Related object family creation
- [Observer Pattern](09A_Design-Patterns-Part4A-Observer-Pattern-Fundamentals.md) - Event notification patterns
