# 07B_Design-Patterns-Part2B-Builder-Pattern-Director

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Builder Pattern Fundamentals (Part A), Configuration management concepts  
**Estimated Time**: Part B of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master the Director Pattern for controlling complex builder sequences
- Implement configuration builders for environment-specific application settings
- Apply builder abstraction with interfaces for flexible implementations
- Design reusable construction algorithms that work with different builders

## 📋 Content Sections (27-Minute Structure)

### Director Pattern Overview (5 minutes)

**Director Pattern Purpose**: *"The Director pattern separates the construction algorithm from the specific builder implementation, enabling the same construction process to create different object variations."*

**Key Components**:

- **Director** - Controls the construction sequence and algorithm
- **Builder Interface** - Defines the construction steps contract
- **Concrete Builders** - Implement specific construction logic
- **Product** - The complex object being constructed

```text
📋 DIRECTOR PATTERN ARCHITECTURE
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Director      │    │ Builder Interface│    │ Product         │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + builder       │───►│ + SetDatabase() │    │ + Database      │
│ + Construct()   │    │ + SetLogging()  │    │ + Logging       │
│ + BuildDev()    │    │ + SetSecurity() │    │ + Security      │
│ + BuildProd()   │    │ + SetApi()      │    │ + Api           │
│ + BuildTest()   │    │ + Build()       │    │ + Custom        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       ▲                       ▲
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │ Concrete Builder│
                    ├─────────────────┤
                    │ + SetDatabase() │
                    │ + SetLogging()  │
                    │ + SetSecurity() │
                    │ + SetApi()      │
                    │ + Build()       │
                    └─────────────────┘
```

**Director Pattern Benefits**:

- **Algorithm Reuse** - Same construction steps for different product variations
- **Builder Abstraction** - Directors work with any compatible builder implementation
- **Environment-Specific Construction** - Different algorithms for dev/test/production
- **Construction Expertise** - Directors encode domain knowledge about proper construction sequences

### Application Configuration Builder (10 minutes)

#### Configuration Product and Builder Interface

```csharp
// Complex configuration product being built
public class ApplicationConfig
{
    public DatabaseSettings Database { get; }
    public LoggingSettings Logging { get; }
    public SecuritySettings Security { get; }
    public ApiSettings Api { get; }
    public Dictionary<string, string> CustomSettings { get; }
    
    internal ApplicationConfig(
        DatabaseSettings database,
        LoggingSettings logging,
        SecuritySettings security,
        ApiSettings api,
        Dictionary<string, string> customSettings)
    {
        Database = database ?? throw new ArgumentNullException(nameof(database));
        Logging = logging ?? throw new ArgumentNullException(nameof(logging));
        Security = security ?? throw new ArgumentNullException(nameof(security));
        Api = api ?? throw new ArgumentNullException(nameof(api));
        CustomSettings = customSettings ?? new Dictionary<string, string>();
    }
    
    public string ToJson()
    {
        return System.Text.Json.JsonSerializer.Serialize(this, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = true
        });
    }
    
    public void SaveToFile(string filePath)
    {
        File.WriteAllText(filePath, ToJson());
        Console.WriteLine($"Configuration saved to: {filePath}");
    }
}

// Abstract builder interface defining construction contract
public interface IConfigurationBuilder
{
    IConfigurationBuilder SetDatabaseConnection(string connectionString, string provider = "SqlServer");
    IConfigurationBuilder ConfigureLogging(LogLevel level, string outputPath = null);
    IConfigurationBuilder SetupSecurity(string jwtSecret, int tokenExpiryHours = 24);
    IConfigurationBuilder ConfigureApi(string baseUrl, int timeout = 30);
    IConfigurationBuilder AddCustomSetting(string key, string value);
    ApplicationConfig Build();
}

// Supporting configuration data classes
public class DatabaseSettings
{
    public string ConnectionString { get; set; }
    public string Provider { get; set; }
    public int CommandTimeout { get; set; }
    public bool EnableRetry { get; set; }
    public bool EnableConnectionPooling { get; set; }
    public int MaxConnections { get; set; }
}

public class LoggingSettings
{
    public LogLevel Level { get; set; }
    public string OutputPath { get; set; }
    public bool EnableConsoleOutput { get; set; }
    public bool EnableFileOutput { get; set; }
    public string MaxFileSize { get; set; }
    public int RetentionDays { get; set; }
    public string LogFormat { get; set; }
}

public class SecuritySettings
{
    public string JwtSecret { get; set; }
    public int TokenExpiryHours { get; set; }
    public bool EnableHttps { get; set; }
    public bool RequireAuthentication { get; set; }
    public bool EnableCors { get; set; }
    public List<string> AllowedOrigins { get; set; }
    public string EncryptionAlgorithm { get; set; }
}

public class ApiSettings
{
    public string BaseUrl { get; set; }
    public int TimeoutSeconds { get; set; }
    public bool EnableRateLimiting { get; set; }
    public int RateLimitPerMinute { get; set; }
    public bool EnableRequestLogging { get; set; }
    public bool EnableCompression { get; set; }
    public string ApiVersion { get; set; }
}

public enum LogLevel
{
    Debug,
    Information,
    Warning,
    Error,
    Critical
}
```

#### Concrete Configuration Builder Implementation

```csharp
// Concrete builder implementing the configuration interface
public class ConfigurationBuilder : IConfigurationBuilder
{
    private DatabaseSettings _database;
    private LoggingSettings _logging;
    private SecuritySettings _security;
    private ApiSettings _api;
    private readonly Dictionary<string, string> _customSettings = new();
    
    public IConfigurationBuilder SetDatabaseConnection(string connectionString, string provider = "SqlServer")
    {
        if (string.IsNullOrEmpty(connectionString))
            throw new ArgumentException("Connection string cannot be empty", nameof(connectionString));
            
        _database = new DatabaseSettings
        {
            ConnectionString = connectionString,
            Provider = provider,
            CommandTimeout = 30,
            EnableRetry = true,
            EnableConnectionPooling = true,
            MaxConnections = provider == "SqlServer" ? 100 : 50
        };
        
        Console.WriteLine($"Database configured: {provider} provider");
        return this;
    }
    
    public IConfigurationBuilder ConfigureLogging(LogLevel level, string outputPath = null)
    {
        _logging = new LoggingSettings
        {
            Level = level,
            OutputPath = outputPath ?? "./logs",
            EnableConsoleOutput = true,
            EnableFileOutput = !string.IsNullOrEmpty(outputPath),
            MaxFileSize = "10MB",
            RetentionDays = 30,
            LogFormat = "JSON"
        };
        
        Console.WriteLine($"Logging configured: {level} level, Output: {_logging.OutputPath}");
        return this;
    }
    
    public IConfigurationBuilder SetupSecurity(string jwtSecret, int tokenExpiryHours = 24)
    {
        if (string.IsNullOrEmpty(jwtSecret))
            throw new ArgumentException("JWT secret cannot be empty", nameof(jwtSecret));
            
        if (tokenExpiryHours <= 0)
            throw new ArgumentException("Token expiry must be positive", nameof(tokenExpiryHours));
            
        _security = new SecuritySettings
        {
            JwtSecret = jwtSecret,
            TokenExpiryHours = tokenExpiryHours,
            EnableHttps = true,
            RequireAuthentication = true,
            EnableCors = true,
            AllowedOrigins = new List<string> { "https://localhost:3000" },
            EncryptionAlgorithm = "AES256"
        };
        
        Console.WriteLine($"Security configured: JWT expiry {tokenExpiryHours}h, HTTPS enabled");
        return this;
    }
    
    public IConfigurationBuilder ConfigureApi(string baseUrl, int timeout = 30)
    {
        if (string.IsNullOrEmpty(baseUrl))
            throw new ArgumentException("Base URL cannot be empty", nameof(baseUrl));
            
        _api = new ApiSettings
        {
            BaseUrl = baseUrl,
            TimeoutSeconds = timeout,
            EnableRateLimiting = true,
            RateLimitPerMinute = 100,
            EnableRequestLogging = true,
            EnableCompression = true,
            ApiVersion = "v1"
        };
        
        Console.WriteLine($"API configured: {baseUrl}, Timeout: {timeout}s");
        return this;
    }
    
    public IConfigurationBuilder AddCustomSetting(string key, string value)
    {
        if (string.IsNullOrEmpty(key))
            throw new ArgumentException("Key cannot be empty", nameof(key));
            
        _customSettings[key] = value ?? "";
        Console.WriteLine($"Custom setting added: {key} = {value}");
        return this;
    }
    
    public ApplicationConfig Build()
    {
        // Comprehensive validation of required components
        if (_database == null)
            throw new InvalidOperationException("Database configuration is required. Call SetDatabaseConnection().");
        if (_logging == null)
            throw new InvalidOperationException("Logging configuration is required. Call ConfigureLogging().");
        if (_security == null)
            throw new InvalidOperationException("Security configuration is required. Call SetupSecurity().");
        if (_api == null)
            throw new InvalidOperationException("API configuration is required. Call ConfigureApi().");
            
        var config = new ApplicationConfig(_database, _logging, _security, _api, _customSettings);
        
        // Reset builder for next use
        Reset();
        
        Console.WriteLine("Configuration build completed successfully");
        return config;
    }
    
    private void Reset()
    {
        _database = null;
        _logging = null;
        _security = null;
        _api = null;
        _customSettings.Clear();
    }
}
```

### Configuration Director Implementation (10 minutes)

#### Director with Environment-Specific Algorithms

```csharp
// Director class - encodes knowledge about proper configuration construction
public class ConfigurationDirector
{
    private readonly IConfigurationBuilder _builder;
    
    public ConfigurationDirector(IConfigurationBuilder builder)
    {
        _builder = builder ?? throw new ArgumentNullException(nameof(builder));
    }
    
    // Development environment configuration algorithm
    public ApplicationConfig BuildDevelopmentConfig()
    {
        Console.WriteLine("=== Building Development Configuration ===");
        
        return _builder
            .SetDatabaseConnection(
                "Data Source=localhost;Initial Catalog=DevDB;Integrated Security=true", 
                "SqlServer")
            .ConfigureLogging(LogLevel.Debug, "./logs/dev")
            .SetupSecurity("dev-jwt-secret-key-not-for-production", 8)
            .ConfigureApi("https://localhost:5001", 10)
            .AddCustomSetting("Environment", "Development")
            .AddCustomSetting("EnableSwagger", "true")
            .AddCustomSetting("SeedTestData", "true")
            .AddCustomSetting("EnableDetailedErrors", "true")
            .AddCustomSetting("CacheExpiryMinutes", "5")
            .Build();
    }
    
    // Production environment configuration algorithm
    public ApplicationConfig BuildProductionConfig()
    {
        Console.WriteLine("=== Building Production Configuration ===");
        
        return _builder
            .SetDatabaseConnection(
                "Data Source=prod-server.company.com;Initial Catalog=ProdDB;User Id=app_user;Password=secure_password", 
                "SqlServer")
            .ConfigureLogging(LogLevel.Warning, "/var/log/app")
            .SetupSecurity("production-jwt-secret-from-key-vault", 24)
            .ConfigureApi("https://api.company.com", 30)
            .AddCustomSetting("Environment", "Production")
            .AddCustomSetting("EnableSwagger", "false")
            .AddCustomSetting("EnableMetrics", "true")
            .AddCustomSetting("EnableHealthChecks", "true")
            .AddCustomSetting("CacheExpiryMinutes", "60")
            .AddCustomSetting("MonitoringEndpoint", "https://monitoring.company.com")
            .Build();
    }
    
    // Test environment configuration algorithm
    public ApplicationConfig BuildTestConfig()
    {
        Console.WriteLine("=== Building Test Configuration ===");
        
        return _builder
            .SetDatabaseConnection("Data Source=:memory:", "InMemory")
            .ConfigureLogging(LogLevel.Information)
            .SetupSecurity("test-jwt-secret-for-integration-tests", 1)
            .ConfigureApi("https://localhost:5002", 5)
            .AddCustomSetting("Environment", "Test")
            .AddCustomSetting("UseInMemoryDatabase", "true")
            .AddCustomSetting("EnableSwagger", "true")
            .AddCustomSetting("SeedTestData", "true")
            .AddCustomSetting("CacheExpiryMinutes", "1")
            .Build();
    }
    
    // Staging environment configuration algorithm
    public ApplicationConfig BuildStagingConfig()
    {
        Console.WriteLine("=== Building Staging Configuration ===");
        
        return _builder
            .SetDatabaseConnection(
                "Data Source=staging-server.company.com;Initial Catalog=StagingDB;User Id=staging_user;Password=staging_password", 
                "SqlServer")
            .ConfigureLogging(LogLevel.Information, "/var/log/staging")
            .SetupSecurity("staging-jwt-secret-mirror-of-production", 12)
            .ConfigureApi("https://staging-api.company.com", 20)
            .AddCustomSetting("Environment", "Staging")
            .AddCustomSetting("EnableSwagger", "true")
            .AddCustomSetting("EnableMetrics", "true")
            .AddCustomSetting("MirrorProductionData", "true")
            .AddCustomSetting("CacheExpiryMinutes", "30")
            .Build();
    }
    
    // Custom configuration algorithm with parameters
    public ApplicationConfig BuildCustomConfig(
        string environment,
        string databaseConnectionString,
        LogLevel logLevel,
        string apiBaseUrl,
        Dictionary<string, string> additionalSettings = null)
    {
        Console.WriteLine($"=== Building Custom Configuration for {environment} ===");
        
        var builder = _builder
            .SetDatabaseConnection(databaseConnectionString)
            .ConfigureLogging(logLevel, $"./logs/{environment.ToLower()}")
            .SetupSecurity($"{environment.ToLower()}-jwt-secret", 12)
            .ConfigureApi(apiBaseUrl)
            .AddCustomSetting("Environment", environment);
        
        // Add any additional custom settings
        if (additionalSettings != null)
        {
            foreach (var setting in additionalSettings)
            {
                builder.AddCustomSetting(setting.Key, setting.Value);
            }
        }
        
        return builder.Build();
    }
}

// Alternative director for specialized configurations
public class MicroserviceConfigurationDirector : ConfigurationDirector
{
    public MicroserviceConfigurationDirector(IConfigurationBuilder builder) : base(builder) { }
    
    public ApplicationConfig BuildOrderServiceConfig(string environment)
    {
        Console.WriteLine($"=== Building Order Service Configuration ({environment}) ===");
        
        var connectionString = environment switch
        {
            "Development" => "Data Source=localhost;Initial Catalog=OrderServiceDev;Integrated Security=true",
            "Production" => "Data Source=order-db.company.com;Initial Catalog=OrderService;User Id=order_service;Password=secure_password",
            _ => throw new ArgumentException($"Unknown environment: {environment}")
        };
        
        var logLevel = environment == "Development" ? LogLevel.Debug : LogLevel.Information;
        var tokenExpiry = environment == "Development" ? 8 : 24;
        
        return BuildCustomConfig(
            environment,
            connectionString,
            logLevel,
            $"https://order-service-{environment.ToLower()}.company.com",
            new Dictionary<string, string>
            {
                ["ServiceName"] = "OrderService",
                ["ServiceVersion"] = "1.2.3",
                ["EnableOrderValidation"] = "true",
                ["MaxOrderItems"] = "100",
                ["OrderTimeoutMinutes"] = "15"
            });
    }
}
```

### Practical Usage Demonstration (2 minutes)

```csharp
// Director pattern usage examples
public class DirectorPatternDemo
{
    public static void RunDemo()
    {
        Console.WriteLine("=== Director Pattern with Configuration Builder Demo ===\n");

        // Create builder and director
        var builder = new ConfigurationBuilder();
        var director = new ConfigurationDirector(builder);

        // Build different environment configurations
        Console.WriteLine("--- Environment-Specific Configurations ---");
        
        var devConfig = director.BuildDevelopmentConfig();
        Console.WriteLine($"\nDevelopment Config Created:");
        Console.WriteLine($"Database: {devConfig.Database.Provider}");
        Console.WriteLine($"Logging Level: {devConfig.Logging.Level}");
        Console.WriteLine($"Environment: {devConfig.CustomSettings["Environment"]}\n");

        var prodConfig = director.BuildProductionConfig();
        Console.WriteLine($"Production Config Created:");
        Console.WriteLine($"Database: {prodConfig.Database.Provider}");
        Console.WriteLine($"API URL: {prodConfig.Api.BaseUrl}");
        Console.WriteLine($"Security: {prodConfig.Security.TokenExpiryHours}h tokens\n");

        // Demonstrate microservice-specific director
        Console.WriteLine("--- Microservice-Specific Configuration ---");
        var microserviceDirector = new MicroserviceConfigurationDirector(builder);
        var orderServiceConfig = microserviceDirector.BuildOrderServiceConfig("Production");
        
        Console.WriteLine($"Order Service Config:");
        Console.WriteLine($"Service Name: {orderServiceConfig.CustomSettings["ServiceName"]}");
        Console.WriteLine($"Max Order Items: {orderServiceConfig.CustomSettings["MaxOrderItems"]}");

        // Save configurations to files
        Console.WriteLine("\n--- Saving Configurations ---");
        devConfig.SaveToFile("./config/development.json");
        prodConfig.SaveToFile("./config/production.json");
        orderServiceConfig.SaveToFile("./config/order-service-prod.json");
    }
}
```

### Key Takeaways & Director Benefits (2 minutes)

**Director Pattern Advantages**:

- **Algorithm Separation** - Construction logic separated from builder implementation
- **Reusable Algorithms** - Same director works with different builder implementations
- **Environment Management** - Specialized methods for different deployment environments
- **Domain Knowledge Encapsulation** - Directors encode proper construction sequences
- **Flexibility** - Easy to add new construction algorithms without changing builders

**When to Use Director Pattern**:

- Complex construction sequences that vary by context
- Environment-specific configuration requirements
- Multiple product variations using similar construction steps
- Need to encapsulate construction expertise in specialized classes

**Next in Series**:

- **[Part C - Generic Builder Systems](07C_Design-Patterns-Part2C-Builder-Pattern-Generic.md)**
- **[Part D - Enterprise Builder Applications](07D_Design-Patterns-Part2D-Builder-Pattern-Enterprise.md)**

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Builder Pattern Fundamentals](07A_Design-Patterns-Part2A-Builder-Pattern-Fundamentals.md)**
- Interface design and polymorphism
- Configuration management patterns

**Builds Upon**:

- Abstract factory pattern for family creation
- Strategy pattern for algorithm selection
- Template method pattern for algorithmic structure

**Enables**:

- [Configuration Management](../../patterns/configuration/) for application settings
- [Environment-Specific Deployment](../../devops/deployment-environments/) strategies
- [Microservice Configuration](../../architecture/microservices-config/) patterns

**Next Patterns**:

- [Abstract Factory](06A_Design-Patterns-Part1A-Factory-Pattern-Fundamentals.md) for related object families
- [Strategy Pattern](10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals.md) for algorithm selection
