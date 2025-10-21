# 08B_Design-Patterns-Part3B-Singleton-Pattern-Modern

**Learning Level**: Advanced  
**Prerequisites**: Part A - Singleton fundamentals, Dependency injection concepts  
**Estimated Time**: Part B of 3 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master dependency injection alternatives to traditional Singleton patterns
- Implement testable Singleton patterns with constructor injection support
- Apply service registry patterns for managing multiple singleton-like services
- Design enterprise-grade solutions that eliminate most Singleton antipatterns

## 📋 Content Sections (27-Minute Structure)

### Dependency Injection Alternative (8 minutes)

**Why Choose DI Over Traditional Singletons**:

- **Better Testability** - Easy to mock dependencies and isolate units
- **Flexible Lifecycle** - Container manages instance lifetime automatically
- **Reduced Coupling** - Dependencies injected rather than globally accessed
- **Configuration Control** - Lifetime and behavior controlled in one place

#### DI Container Implementation

```csharp
// Interface-based design for better testability
public interface IConfigurationService
{
    string GetSetting(string key);
    T GetSetting<T>(string key, T defaultValue = default(T));
    void SetSetting(string key, string value);
    void SaveConfiguration();
    bool HasSetting(string key);
}

public class ConfigurationService : IConfigurationService
{
    private readonly Dictionary<string, string> _settings;
    private readonly string _configFilePath;
    private readonly object _lock = new object();
    
    // Regular constructor - DI container manages instance lifetime
    public ConfigurationService()
    {
        _configFilePath = "appsettings.json";
        _settings = new Dictionary<string, string>();
        LoadConfiguration();
    }
    
    // Constructor with custom file path for testing
    public ConfigurationService(string configFilePath)
    {
        _configFilePath = configFilePath ?? "appsettings.json";
        _settings = new Dictionary<string, string>();
        LoadConfiguration();
    }
    
    public string GetSetting(string key)
    {
        if (string.IsNullOrEmpty(key))
            return null;
            
        lock (_lock)
        {
            return _settings.TryGetValue(key, out var value) ? value : null;
        }
    }
    
    public T GetSetting<T>(string key, T defaultValue = default(T))
    {
        var stringValue = GetSetting(key);
        
        if (string.IsNullOrEmpty(stringValue))
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
    
    public void SetSetting(string key, string value)
    {
        if (string.IsNullOrEmpty(key))
            throw new ArgumentException("Setting key cannot be null or empty", nameof(key));
        
        lock (_lock)
        {
            _settings[key] = value ?? "";
        }
    }
    
    public void SaveConfiguration()
    {
        lock (_lock)
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
                throw new InvalidOperationException($"Failed to save configuration: {ex.Message}", ex);
            }
        }
    }
    
    public bool HasSetting(string key)
    {
        if (string.IsNullOrEmpty(key))
            return false;
        
        lock (_lock)
        {
            return _settings.ContainsKey(key);
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
                
                lock (_lock)
                {
                    foreach (var kvp in config)
                    {
                        _settings[kvp.Key] = kvp.Value?.ToString() ?? "";
                    }
                }
            }
            else
            {
                SetDefaultConfiguration();
                SaveConfiguration();
            }
        }
        catch (Exception)
        {
            // Fallback to default configuration if loading fails
            SetDefaultConfiguration();
        }
    }
    
    private void SetDefaultConfiguration()
    {
        lock (_lock)
        {
            _settings["Environment"] = "Development";
            _settings["LogLevel"] = "Information";
            _settings["ConnectionTimeout"] = "30";
            _settings["MaxRetries"] = "3";
            _settings["DatabaseProvider"] = "SqlServer";
        }
    }
}

// Dependency injection setup (using Microsoft.Extensions.DependencyInjection)
public class ServiceConfiguration
{
    public static void ConfigureServices(IServiceCollection services)
    {
        // Register as singleton through DI container
        services.AddSingleton<IConfigurationService, ConfigurationService>();
        
        // Other services can depend on IConfigurationService
        services.AddScoped<IDatabaseService, DatabaseService>();
        services.AddScoped<IBusinessService, BusinessService>();
        services.AddScoped<IEmailService, EmailService>();
    }
}

// Services receive configuration through constructor injection
public interface IDatabaseService
{
    Task<bool> ConnectAsync();
    Task<T> QueryAsync<T>(string sql, object parameters = null);
}

public class DatabaseService : IDatabaseService
{
    private readonly IConfigurationService _config;
    private string _connectionString;
    
    public DatabaseService(IConfigurationService config)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        InitializeConnection();
    }
    
    public async Task<bool> ConnectAsync()
    {
        var timeout = _config.GetSetting<int>("ConnectionTimeout", 30);
        var maxRetries = _config.GetSetting<int>("MaxRetries", 3);
        
        Console.WriteLine($"Connecting to database with timeout: {timeout}s, max retries: {maxRetries}");
        
        // Simulate database connection
        await Task.Delay(100);
        return true;
    }
    
    public async Task<T> QueryAsync<T>(string sql, object parameters = null)
    {
        // Database query implementation
        await Task.Delay(50);
        return default(T);
    }
    
    private void InitializeConnection()
    {
        var provider = _config.GetSetting("DatabaseProvider", "SqlServer");
        var server = _config.GetSetting("DatabaseServer", "localhost");
        var database = _config.GetSetting("DatabaseName", "DefaultDb");
        
        _connectionString = $"Server={server};Database={database};Provider={provider}";
    }
}

public interface IBusinessService
{
    Task<string> ProcessDataAsync(string input);
}

public class BusinessService : IBusinessService
{
    private readonly IConfigurationService _config;
    private readonly IDatabaseService _database;
    
    public BusinessService(IConfigurationService config, IDatabaseService database)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _database = database ?? throw new ArgumentNullException(nameof(database));
    }
    
    public async Task<string> ProcessDataAsync(string input)
    {
        var environment = _config.GetSetting("Environment", "Production");
        
        if (environment == "Development")
        {
            Console.WriteLine($"[DEV] Processing: {input}");
        }
        
        await _database.ConnectAsync();
        // Business logic here
        
        return $"Processed: {input}";
    }
}
```

**DI Container Benefits**:

- **Automatic Lifetime Management** - Container handles creation and disposal
- **Constructor Injection** - Dependencies clearly declared and testable
- **Configuration Centralization** - All service registrations in one place
- **Easy Testing** - Simple to replace implementations with mocks

### Testable Singleton Pattern (10 minutes)

#### Hybrid Approach: Singleton + Dependency Injection

```csharp
// Testable singleton with dependency injection support
public interface IApplicationLogger
{
    void LogInfo(string message);
    void LogWarning(string message);
    void LogError(string message, Exception exception = null);
    void LogDebug(string message);
    LogLevel CurrentLogLevel { get; set; }
}

public enum LogLevel
{
    Debug = 0,
    Information = 1,
    Warning = 2,
    Error = 3
}

public sealed class ApplicationLogger : IApplicationLogger
{
    private static readonly Lazy<ApplicationLogger> _instance = 
        new Lazy<ApplicationLogger>(() => new ApplicationLogger());
    
    private readonly ILogWriter _logWriter;
    public LogLevel CurrentLogLevel { get; set; } = LogLevel.Information;
    
    // Private constructor for singleton pattern
    private ApplicationLogger() : this(new FileLogWriter())
    {
    }
    
    // Constructor for testing - allows dependency injection
    internal ApplicationLogger(ILogWriter logWriter)
    {
        _logWriter = logWriter ?? throw new ArgumentNullException(nameof(logWriter));
    }
    
    public static IApplicationLogger Instance => _instance.Value;
    
    // Factory method for testing and alternative configurations
    public static IApplicationLogger CreateWithWriter(ILogWriter logWriter)
    {
        return new ApplicationLogger(logWriter);
    }
    
    public static IApplicationLogger CreateWithConfiguration(ILogWriter logWriter, LogLevel logLevel)
    {
        var logger = new ApplicationLogger(logWriter);
        logger.CurrentLogLevel = logLevel;
        return logger;
    }
    
    public void LogDebug(string message)
    {
        if (CurrentLogLevel <= LogLevel.Debug)
        {
            _logWriter.WriteLog("DEBUG", message);
        }
    }
    
    public void LogInfo(string message)
    {
        if (CurrentLogLevel <= LogLevel.Information)
        {
            _logWriter.WriteLog("INFO", message);
        }
    }
    
    public void LogWarning(string message)
    {
        if (CurrentLogLevel <= LogLevel.Warning)
        {
            _logWriter.WriteLog("WARNING", message);
        }
    }
    
    public void LogError(string message, Exception exception = null)
    {
        if (CurrentLogLevel <= LogLevel.Error)
        {
            var errorMessage = exception != null 
                ? $"{message} | Exception: {exception.Message} | StackTrace: {exception.StackTrace}"
                : message;
            _logWriter.WriteLog("ERROR", errorMessage);
        }
    }
}

// Abstraction for log writing - enables different implementations
public interface ILogWriter
{
    void WriteLog(string level, string message);
    void Flush();
}

public class FileLogWriter : ILogWriter
{
    private readonly string _logFilePath;
    private readonly object _lock = new object();
    
    public FileLogWriter() : this(null)
    {
    }
    
    public FileLogWriter(string customLogPath)
    {
        _logFilePath = customLogPath ?? Path.Combine("logs", $"app-{DateTime.Now:yyyy-MM-dd}.log");
        EnsureLogDirectoryExists();
    }
    
    public void WriteLog(string level, string message)
    {
        var logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff}] [{level}] [Thread-{Thread.CurrentThread.ManagedThreadId}] {message}";
        
        lock (_lock)
        {
            try
            {
                File.AppendAllText(_logFilePath, logEntry + Environment.NewLine);
            }
            catch (Exception ex)
            {
                // Fallback to console if file writing fails
                Console.WriteLine($"LOG FILE ERROR: {ex.Message}");
                Console.WriteLine(logEntry);
            }
        }
    }
    
    public void Flush()
    {
        // File is automatically flushed with AppendAllText
        // This method is for compatibility with other writers
    }
    
    private void EnsureLogDirectoryExists()
    {
        var logDirectory = Path.GetDirectoryName(_logFilePath);
        if (!string.IsNullOrEmpty(logDirectory) && !Directory.Exists(logDirectory))
        {
            Directory.CreateDirectory(logDirectory);
        }
    }
}

// Console log writer for development/testing
public class ConsoleLogWriter : ILogWriter
{
    public void WriteLog(string level, string message)
    {
        var timestamp = DateTime.Now.ToString("HH:mm:ss.fff");
        var logEntry = $"[{timestamp}] [{level}] {message}";
        
        // Color coding for different log levels
        var originalColor = Console.ForegroundColor;
        Console.ForegroundColor = GetLogColor(level);
        Console.WriteLine(logEntry);
        Console.ForegroundColor = originalColor;
    }
    
    public void Flush()
    {
        // Console is automatically flushed
    }
    
    private static ConsoleColor GetLogColor(string level)
    {
        return level switch
        {
            "DEBUG" => ConsoleColor.Gray,
            "INFO" => ConsoleColor.White,
            "WARNING" => ConsoleColor.Yellow,
            "ERROR" => ConsoleColor.Red,
            _ => ConsoleColor.White
        };
    }
}

// Mock implementation for unit testing
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
    
    public void Flush()
    {
        // Mock doesn't need flushing
    }
    
    public void Clear()
    {
        WrittenLogs.Clear();
    }
    
    public bool ContainsMessage(string message)
    {
        return WrittenLogs.Any(log => log.Message.Contains(message));
    }
    
    public int GetLogCount(string level)
    {
        return WrittenLogs.Count(log => log.Level == level);
    }
}

public class LogEntry
{
    public string Level { get; set; }
    public string Message { get; set; }
    public DateTime Timestamp { get; set; }
    
    public override string ToString()
    {
        return $"[{Timestamp:HH:mm:ss}] [{Level}] {Message}";
    }
}

// Unit tests demonstrating testable singleton
[TestFixture]
public class ApplicationLoggerTests
{
    private MockLogWriter _mockWriter;
    private IApplicationLogger _logger;
    
    [SetUp]
    public void Setup()
    {
        _mockWriter = new MockLogWriter();
        _logger = ApplicationLogger.CreateWithWriter(_mockWriter);
    }
    
    [Test]
    public void LogInfo_Should_WriteInfoMessage()
    {
        // Arrange
        var message = "Test info message";
        
        // Act
        _logger.LogInfo(message);
        
        // Assert
        Assert.AreEqual(1, _mockWriter.WrittenLogs.Count);
        Assert.AreEqual("INFO", _mockWriter.WrittenLogs[0].Level);
        Assert.AreEqual(message, _mockWriter.WrittenLogs[0].Message);
    }
    
    [Test]
    public void LogError_WithException_Should_IncludeExceptionDetails()
    {
        // Arrange
        var message = "Test error message";
        var exception = new InvalidOperationException("Test exception");
        
        // Act
        _logger.LogError(message, exception);
        
        // Assert
        Assert.AreEqual(1, _mockWriter.WrittenLogs.Count);
        Assert.AreEqual("ERROR", _mockWriter.WrittenLogs[0].Level);
        Assert.IsTrue(_mockWriter.WrittenLogs[0].Message.Contains(message));
        Assert.IsTrue(_mockWriter.WrittenLogs[0].Message.Contains("Test exception"));
    }
    
    [Test]
    public void LogLevel_Filtering_Should_OnlyLogAtOrAboveLevel()
    {
        // Arrange
        _logger.CurrentLogLevel = LogLevel.Warning;
        
        // Act
        _logger.LogDebug("Debug message");      // Should be filtered
        _logger.LogInfo("Info message");        // Should be filtered
        _logger.LogWarning("Warning message");  // Should be logged
        _logger.LogError("Error message");      // Should be logged
        
        // Assert
        Assert.AreEqual(2, _mockWriter.WrittenLogs.Count);
        Assert.AreEqual("WARNING", _mockWriter.WrittenLogs[0].Level);
        Assert.AreEqual("ERROR", _mockWriter.WrittenLogs[1].Level);
    }
}
```

### Service Registry Pattern (6 minutes)

#### Alternative to Multiple Singletons

```csharp
// Service registry pattern - manages multiple singleton-like services
public interface IServiceRegistry
{
    void Register<T>(T service) where T : class;
    void Register<T>(Func<T> factory) where T : class;
    T GetService<T>() where T : class;
    bool IsRegistered<T>() where T : class;
    void Clear();
}

public class ServiceRegistry : IServiceRegistry
{
    private static readonly Lazy<ServiceRegistry> _instance = 
        new Lazy<ServiceRegistry>(() => new ServiceRegistry());
    
    private readonly Dictionary<Type, object> _services = new Dictionary<Type, object>();
    private readonly Dictionary<Type, Func<object>> _factories = new Dictionary<Type, Func<object>>();
    private readonly object _lock = new object();
    
    private ServiceRegistry() { }
    
    public static ServiceRegistry Instance => _instance.Value;
    
    public void Register<T>(T service) where T : class
    {
        if (service == null)
            throw new ArgumentNullException(nameof(service));
        
        lock (_lock)
        {
            _services[typeof(T)] = service;
            // Remove factory if it exists
            _factories.Remove(typeof(T));
        }
    }
    
    public void Register<T>(Func<T> factory) where T : class
    {
        if (factory == null)
            throw new ArgumentNullException(nameof(factory));
        
        lock (_lock)
        {
            _factories[typeof(T)] = () => factory();
            // Remove existing instance if it exists
            _services.Remove(typeof(T));
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
    
    public void Clear()
    {
        lock (_lock)
        {
            _services.Clear();
            _factories.Clear();
        }
    }
    
    // Get all registered service types
    public IEnumerable<Type> GetRegisteredTypes()
    {
        lock (_lock)
        {
            return _services.Keys.Union(_factories.Keys).ToList();
        }
    }
}

// Example services for the registry
public interface IEmailService
{
    Task<bool> SendEmailAsync(string to, string subject, string body);
}

public class EmailService : IEmailService
{
    private readonly IApplicationLogger _logger;
    private readonly IConfigurationService _config;
    
    public EmailService(IApplicationLogger logger, IConfigurationService config)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _config = config ?? throw new ArgumentNullException(nameof(config));
    }
    
    public async Task<bool> SendEmailAsync(string to, string subject, string body)
    {
        var smtpServer = _config.GetSetting("SmtpServer", "localhost");
        var port = _config.GetSetting<int>("SmtpPort", 587);
        
        _logger.LogInfo($"Sending email to {to} via {smtpServer}:{port}");
        
        // Simulate email sending
        await Task.Delay(100);
        
        _logger.LogInfo("Email sent successfully");
        return true;
    }
}

// Registry usage example
public class RegistryExample
{
    public void SetupServices()
    {
        var registry = ServiceRegistry.Instance;
        
        // Register direct instances
        registry.Register<IConfigurationService>(new ConfigurationService());
        registry.Register<IApplicationLogger>(ApplicationLogger.CreateWithWriter(new ConsoleLogWriter()));
        
        // Register with factory for lazy creation
        registry.Register<IEmailService>(() => 
        {
            var logger = registry.GetService<IApplicationLogger>();
            var config = registry.GetService<IConfigurationService>();
            return new EmailService(logger, config);
        });
        
        // Use services
        DemonstrateServiceUsage();
    }
    
    private void DemonstrateServiceUsage()
    {
        var registry = ServiceRegistry.Instance;
        
        var config = registry.GetService<IConfigurationService>();
        config.SetSetting("SmtpServer", "mail.example.com");
        config.SetSetting("SmtpPort", "587");
        
        var logger = registry.GetService<IApplicationLogger>();
        logger.LogInfo("Services initialized successfully");
        
        var emailService = registry.GetService<IEmailService>();
        _ = emailService.SendEmailAsync("user@example.com", "Test", "Hello from registry!");
        
        // Show registered types
        var registeredTypes = registry.GetRegisteredTypes();
        logger.LogInfo($"Registered services: {string.Join(", ", registeredTypes.Select(t => t.Name))}");
    }
}
```

### Modern Best Practices & Next Steps (3 minutes)

**Choose the Right Pattern**:

| Scenario | Recommended Approach | Reasoning |
|----------|---------------------|-----------|
| **ASP.NET Core Apps** | DI Container | Built-in container, better testability |
| **Legacy Applications** | Testable Singleton | Gradual migration path |
| **Multiple Services** | Service Registry | Centralized service management |
| **Simple Utilities** | Static Class | No state needed |

**Migration Strategy from Traditional Singletons**:

1. **Extract Interface** - Define contract for singleton behavior
2. **Add Constructor** - Support dependency injection alongside static access
3. **Update Tests** - Use constructor injection for isolated testing
4. **Register in DI** - Move to container-managed lifetime
5. **Remove Static Access** - Final step after full migration

**Performance Considerations**:

- **DI Container**: Slight overhead for resolution, but negligible in most cases
- **Service Registry**: Minimal overhead, good for medium-scale applications
- **Testable Singleton**: Same performance as traditional singleton

**Next Learning Steps**:

- **[Part C: Registry & Advanced](08C_Design-Patterns-Part3C-Singleton-Pattern-Registry.md)** - Advanced registry patterns
- **Structural Patterns** - Adapter, Decorator, Facade patterns

## 🔗 Related Topics

**Prerequisites**:

- [Part A: Singleton Fundamentals](08A_Design-Patterns-Part3A-Singleton-Pattern-Fundamentals.md)
- Dependency injection and IoC container concepts
- Unit testing and mocking frameworks

**Builds Upon**:

- Interface-based design principles
- Constructor injection patterns
- Service lifetime management concepts

**Enables**:

- [Enterprise Service Architecture](../../architecture/service-architecture/) patterns
- [Microservice Configuration](../../architecture/microservice-patterns/) management
- [Advanced Testing Patterns](../../testing/advanced-patterns/) for complex systems

**Next Patterns**:

- [Abstract Factory Pattern](06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals.md) - Related object creation
- [Adapter Pattern](../../structural-patterns/adapter/) - Interface compatibility
