# 07_Design-Patterns-Part2-Builder-Pattern

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Factory Pattern (Part 1), SOLID Principles understanding  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Builder Pattern for constructing complex objects step by step
- Implement fluent interfaces that make object creation readable and safe
- Apply builder variations including Director pattern and method chaining
- Design immutable objects using builder patterns for thread-safe construction

## 📋 Content Sections

### Quick Overview (5 minutes)

**Builder Pattern**: *"Separate the construction of a complex object from its representation so that the same construction process can create different representations."*

**Core Problem**: Complex objects with many optional parameters lead to telescoping constructors and unclear object creation.

```text
❌ TELESCOPING CONSTRUCTOR PROBLEM
┌─────────────────────────────────────────────────────────────┐
│ EmailMessage(string to, string subject, string body)        │
│ EmailMessage(string to, string subject, string body,        │
│              string cc)                                     │
│ EmailMessage(string to, string subject, string body,        │
│              string cc, string bcc)                         │
│ EmailMessage(string to, string subject, string body,        │
│              string cc, string bcc, Priority priority)      │
│ EmailMessage(string to, string subject, string body,        │
│              string cc, string bcc, Priority priority,      │
│              List<Attachment> attachments)                  │
└─────────────────────────────────────────────────────────────┘

✅ BUILDER PATTERN SOLUTION
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ EmailMessage    │    │ EmailBuilder    │    │ Usage           │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ - to            │←───│ + SetTo()       │    │ var email =     │
│ - subject       │    │ + SetSubject()  │    │   EmailBuilder  │
│ - body          │    │ + SetBody()     │    │     .SetTo(...) │
│ - cc            │    │ + AddCC()       │    │     .SetSubject │
│ - bcc           │    │ + AddBCC()      │    │     .SetBody()  │
│ - attachments   │    │ + AddAttachment │    │     .AddCC()    │
│ - priority      │    │ + SetPriority() │    │     .Build()    │
└─────────────────┘    │ + Build()       │    └─────────────────┘
                       └─────────────────┘
```

**Builder Pattern Benefits**:

- **Readable Construction**: Method chaining creates fluent, self-documenting code
- **Parameter Validation**: Validate during building process, not after construction
- **Immutable Objects**: Build once, then object becomes immutable
- **Flexible Creation**: Same builder can create different object variations

### Core Concepts (15 minutes)

#### Fluent Builder Implementation

**Use Case**: Database query builder

```csharp
// Complex query object that needs step-by-step construction
public class DatabaseQuery
{
    public string TableName { get; }
    public List<string> SelectColumns { get; }
    public List<JoinClause> Joins { get; }
    public List<WhereCondition> WhereConditions { get; }
    public List<string> GroupByColumns { get; }
    public List<OrderByClause> OrderBy { get; }
    public int? Limit { get; }
    public int? Offset { get; }
    
    // Private constructor - only builder can create instances
    internal DatabaseQuery(
        string tableName,
        List<string> selectColumns,
        List<JoinClause> joins,
        List<WhereCondition> whereConditions,
        List<string> groupByColumns,
        List<OrderByClause> orderBy,
        int? limit,
        int? offset)
    {
        TableName = tableName ?? throw new ArgumentNullException(nameof(tableName));
        SelectColumns = selectColumns ?? throw new ArgumentNullException(nameof(selectColumns));
        Joins = joins ?? new List<JoinClause>();
        WhereConditions = whereConditions ?? new List<WhereCondition>();
        GroupByColumns = groupByColumns ?? new List<string>();
        OrderBy = orderBy ?? new List<OrderByClause>();
        Limit = limit;
        Offset = offset;
    }
    
    public string ToSql()
    {
        var sql = new StringBuilder();
        
        // SELECT clause
        sql.Append($"SELECT {string.Join(", ", SelectColumns)} FROM {TableName}");
        
        // JOIN clauses
        foreach (var join in Joins)
        {
            sql.Append($" {join.JoinType} JOIN {join.Table} ON {join.Condition}");
        }
        
        // WHERE clause
        if (WhereConditions.Any())
        {
            sql.Append($" WHERE {string.Join(" AND ", WhereConditions.Select(w => w.ToString()))}");
        }
        
        // GROUP BY clause
        if (GroupByColumns.Any())
        {
            sql.Append($" GROUP BY {string.Join(", ", GroupByColumns)}");
        }
        
        // ORDER BY clause
        if (OrderBy.Any())
        {
            sql.Append($" ORDER BY {string.Join(", ", OrderBy.Select(o => $"{o.Column} {o.Direction}"))}");
        }
        
        // LIMIT and OFFSET
        if (Limit.HasValue)
        {
            sql.Append($" LIMIT {Limit}");
        }
        
        if (Offset.HasValue)
        {
            sql.Append($" OFFSET {Offset}");
        }
        
        return sql.ToString();
    }
}

// Fluent builder with method chaining
public class QueryBuilder
{
    private string _tableName;
    private readonly List<string> _selectColumns = new();
    private readonly List<JoinClause> _joins = new();
    private readonly List<WhereCondition> _whereConditions = new();
    private readonly List<string> _groupByColumns = new();
    private readonly List<OrderByClause> _orderBy = new();
    private int? _limit;
    private int? _offset;
    
    // Fluent interface methods return 'this' for chaining
    public QueryBuilder From(string tableName)
    {
        _tableName = tableName ?? throw new ArgumentNullException(nameof(tableName));
        return this;
    }
    
    public QueryBuilder Select(params string[] columns)
    {
        if (columns == null || columns.Length == 0)
            throw new ArgumentException("At least one column must be specified", nameof(columns));
            
        _selectColumns.AddRange(columns);
        return this;
    }
    
    public QueryBuilder SelectAll()
    {
        _selectColumns.Clear();
        _selectColumns.Add("*");
        return this;
    }
    
    public QueryBuilder InnerJoin(string table, string condition)
    {
        _joins.Add(new JoinClause { JoinType = "INNER", Table = table, Condition = condition });
        return this;
    }
    
    public QueryBuilder LeftJoin(string table, string condition)
    {
        _joins.Add(new JoinClause { JoinType = "LEFT", Table = table, Condition = condition });
        return this;
    }
    
    public QueryBuilder Where(string column, string operatorSymbol, object value)
    {
        _whereConditions.Add(new WhereCondition(column, operatorSymbol, value));
        return this;
    }
    
    public QueryBuilder WhereEquals(string column, object value)
    {
        return Where(column, "=", value);
    }
    
    public QueryBuilder WhereIn(string column, params object[] values)
    {
        var inValues = string.Join(", ", values.Select(v => $"'{v}'"));
        _whereConditions.Add(new WhereCondition(column, "IN", $"({inValues})"));
        return this;
    }
    
    public QueryBuilder GroupBy(params string[] columns)
    {
        _groupByColumns.AddRange(columns ?? throw new ArgumentNullException(nameof(columns)));
        return this;
    }
    
    public QueryBuilder OrderBy(string column, SortDirection direction = SortDirection.Ascending)
    {
        _orderBy.Add(new OrderByClause { Column = column, Direction = direction.ToString().ToUpper() });
        return this;
    }
    
    public QueryBuilder OrderByDescending(string column)
    {
        return OrderBy(column, SortDirection.Descending);
    }
    
    public QueryBuilder Take(int limit)
    {
        if (limit <= 0)
            throw new ArgumentException("Limit must be positive", nameof(limit));
            
        _limit = limit;
        return this;
    }
    
    public QueryBuilder Skip(int offset)
    {
        if (offset < 0)
            throw new ArgumentException("Offset cannot be negative", nameof(offset));
            
        _offset = offset;
        return this;
    }
    
    // Build method validates and creates the final object
    public DatabaseQuery Build()
    {
        // Validation during build process
        if (string.IsNullOrEmpty(_tableName))
            throw new InvalidOperationException("Table name is required. Call From() method.");
            
        if (_selectColumns.Count == 0)
            throw new InvalidOperationException("At least one column must be selected. Call Select() or SelectAll().");
            
        if (_offset.HasValue && !_limit.HasValue)
            throw new InvalidOperationException("Cannot specify offset without limit. Call Take() method first.");
        
        return new DatabaseQuery(
            _tableName,
            new List<string>(_selectColumns),
            new List<JoinClause>(_joins),
            new List<WhereCondition>(_whereConditions),
            new List<string>(_groupByColumns),
            new List<OrderByClause>(_orderBy),
            _limit,
            _offset);
    }
    
    // Static factory method for fluent starting
    public static QueryBuilder Create() => new QueryBuilder();
}

// Supporting classes
public class JoinClause
{
    public string JoinType { get; set; }
    public string Table { get; set; }
    public string Condition { get; set; }
}

public class WhereCondition
{
    public string Column { get; }
    public string Operator { get; }
    public object Value { get; }
    
    public WhereCondition(string column, string operatorSymbol, object value)
    {
        Column = column ?? throw new ArgumentNullException(nameof(column));
        Operator = operatorSymbol ?? throw new ArgumentNullException(nameof(operatorSymbol));
        Value = value;
    }
    
    public override string ToString()
    {
        if (Value is string stringValue)
        {
            return $"{Column} {Operator} '{stringValue}'";
        }
        return $"{Column} {Operator} {Value}";
    }
}

public class OrderByClause
{
    public string Column { get; set; }
    public string Direction { get; set; }
}

public enum SortDirection
{
    Ascending,
    Descending
}

// Usage examples
public class QueryBuilderExamples
{
    public void DemonstrateQueryBuilder()
    {
        // Simple query
        var simpleQuery = QueryBuilder.Create()
            .From("Users")
            .SelectAll()
            .WhereEquals("IsActive", true)
            .OrderBy("LastName")
            .Build();
            
        Console.WriteLine("Simple Query:");
        Console.WriteLine(simpleQuery.ToSql());
        // Output: SELECT * FROM Users WHERE IsActive = 'True' ORDER BY LastName ASC
        
        // Complex query with joins and grouping
        var complexQuery = QueryBuilder.Create()
            .From("Orders")
            .Select("o.CustomerId", "COUNT(*) as OrderCount", "SUM(o.Total) as TotalAmount")
            .InnerJoin("Customers c", "o.CustomerId = c.Id")
            .LeftJoin("OrderItems oi", "o.Id = oi.OrderId")
            .Where("o.OrderDate", ">=", "2024-01-01")
            .WhereIn("o.Status", "Completed", "Shipped")
            .GroupBy("o.CustomerId", "c.Name")
            .OrderByDescending("TotalAmount")
            .Take(10)
            .Build();
            
        Console.WriteLine("\nComplex Query:");
        Console.WriteLine(complexQuery.ToSql());
    }
}
```

#### Director Pattern with Builder

**Use Case**: Configuration file generator

```csharp
// Product being built
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
}

// Abstract builder interface
public interface IConfigurationBuilder
{
    IConfigurationBuilder SetDatabaseConnection(string connectionString, string provider = "SqlServer");
    IConfigurationBuilder ConfigureLogging(LogLevel level, string outputPath = null);
    IConfigurationBuilder SetupSecurity(string jwtSecret, int tokenExpiryHours = 24);
    IConfigurationBuilder ConfigureApi(string baseUrl, int timeout = 30);
    IConfigurationBuilder AddCustomSetting(string key, string value);
    ApplicationConfig Build();
}

// Concrete builder implementation
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
            EnableRetry = true
        };
        
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
            RetentionDays = 30
        };
        
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
            EnableCors = true
        };
        
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
            EnableRequestLogging = true
        };
        
        return this;
    }
    
    public IConfigurationBuilder AddCustomSetting(string key, string value)
    {
        if (string.IsNullOrEmpty(key))
            throw new ArgumentException("Key cannot be empty", nameof(key));
            
        _customSettings[key] = value ?? "";
        return this;
    }
    
    public ApplicationConfig Build()
    {
        // Validate all required components are configured
        if (_database == null)
            throw new InvalidOperationException("Database configuration is required");
        if (_logging == null)
            throw new InvalidOperationException("Logging configuration is required");
        if (_security == null)
            throw new InvalidOperationException("Security configuration is required");
        if (_api == null)
            throw new InvalidOperationException("API configuration is required");
            
        return new ApplicationConfig(_database, _logging, _security, _api, _customSettings);
    }
}

// Director class - knows how to build specific configurations
public class ConfigurationDirector
{
    private readonly IConfigurationBuilder _builder;
    
    public ConfigurationDirector(IConfigurationBuilder builder)
    {
        _builder = builder ?? throw new ArgumentNullException(nameof(builder));
    }
    
    public ApplicationConfig BuildDevelopmentConfig()
    {
        return _builder
            .SetDatabaseConnection("Data Source=localhost;Initial Catalog=DevDB;Integrated Security=true")
            .ConfigureLogging(LogLevel.Debug, "./logs/dev")
            .SetupSecurity("dev-jwt-secret-key-not-for-production", 8)
            .ConfigureApi("https://localhost:5001", 10)
            .AddCustomSetting("Environment", "Development")
            .AddCustomSetting("EnableSwagger", "true")
            .AddCustomSetting("SeedTestData", "true")
            .Build();
    }
    
    public ApplicationConfig BuildProductionConfig()
    {
        return _builder
            .SetDatabaseConnection("Data Source=prod-server;Initial Catalog=ProdDB;User Id=app_user;Password=secure_password")
            .ConfigureLogging(LogLevel.Warning, "/var/log/app")
            .SetupSecurity("production-jwt-secret-from-key-vault", 24)
            .ConfigureApi("https://api.company.com", 30)
            .AddCustomSetting("Environment", "Production")
            .AddCustomSetting("EnableSwagger", "false")
            .AddCustomSetting("EnableMetrics", "true")
            .Build();
    }
    
    public ApplicationConfig BuildTestConfig()
    {
        return _builder
            .SetDatabaseConnection("Data Source=:memory:", "InMemory")
            .ConfigureLogging(LogLevel.Information)
            .SetupSecurity("test-jwt-secret", 1)
            .ConfigureApi("https://localhost:5002", 5)
            .AddCustomSetting("Environment", "Test")
            .AddCustomSetting("UseInMemoryDatabase", "true")
            .Build();
    }
}

// Supporting configuration classes
public class DatabaseSettings
{
    public string ConnectionString { get; set; }
    public string Provider { get; set; }
    public int CommandTimeout { get; set; }
    public bool EnableRetry { get; set; }
}

public class LoggingSettings
{
    public LogLevel Level { get; set; }
    public string OutputPath { get; set; }
    public bool EnableConsoleOutput { get; set; }
    public bool EnableFileOutput { get; set; }
    public string MaxFileSize { get; set; }
    public int RetentionDays { get; set; }
}

public class SecuritySettings
{
    public string JwtSecret { get; set; }
    public int TokenExpiryHours { get; set; }
    public bool EnableHttps { get; set; }
    public bool RequireAuthentication { get; set; }
    public bool EnableCors { get; set; }
}

public class ApiSettings
{
    public string BaseUrl { get; set; }
    public int TimeoutSeconds { get; set; }
    public bool EnableRateLimiting { get; set; }
    public int RateLimitPerMinute { get; set; }
    public bool EnableRequestLogging { get; set; }
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

### Practical Implementation (8 minutes)

#### Generic Builder Pattern

```csharp
// Generic builder base class for reusability
public abstract class Builder<TProduct, TBuilder> 
    where TProduct : class 
    where TBuilder : Builder<TProduct, TBuilder>
{
    protected abstract TProduct BuildInternal();
    
    protected abstract TBuilder Self { get; }
    
    public TProduct Build()
    {
        var product = BuildInternal();
        Reset(); // Prepare builder for next use
        return product;
    }
    
    protected virtual void Reset()
    {
        // Override in derived classes to reset builder state
    }
}

// Email message builder using generic base
public class EmailMessageBuilder : Builder<EmailMessage, EmailMessageBuilder>
{
    private string _to;
    private string _from;
    private string _subject;
    private string _body;
    private readonly List<string> _cc = new();
    private readonly List<string> _bcc = new();
    private readonly List<EmailAttachment> _attachments = new();
    private EmailPriority _priority = EmailPriority.Normal;
    private bool _isHtml = false;
    
    protected override EmailMessageBuilder Self => this;
    
    public EmailMessageBuilder To(string email)
    {
        _to = ValidateEmail(email, nameof(email));
        return Self;
    }
    
    public EmailMessageBuilder From(string email)
    {
        _from = ValidateEmail(email, nameof(email));
        return Self;
    }
    
    public EmailMessageBuilder Subject(string subject)
    {
        _subject = subject ?? throw new ArgumentNullException(nameof(subject));
        return Self;
    }
    
    public EmailMessageBuilder Body(string body)
    {
        _body = body ?? throw new ArgumentNullException(nameof(body));
        return Self;
    }
    
    public EmailMessageBuilder HtmlBody(string htmlBody)
    {
        _body = htmlBody ?? throw new ArgumentNullException(nameof(htmlBody));
        _isHtml = true;
        return Self;
    }
    
    public EmailMessageBuilder AddCC(string email)
    {
        _cc.Add(ValidateEmail(email, nameof(email)));
        return Self;
    }
    
    public EmailMessageBuilder AddBCC(string email)
    {
        _bcc.Add(ValidateEmail(email, nameof(email)));
        return Self;
    }
    
    public EmailMessageBuilder WithPriority(EmailPriority priority)
    {
        _priority = priority;
        return Self;
    }
    
    public EmailMessageBuilder AttachFile(string filePath, string fileName = null)
    {
        if (!File.Exists(filePath))
            throw new FileNotFoundException($"Attachment file not found: {filePath}");
            
        var attachment = new EmailAttachment
        {
            FilePath = filePath,
            FileName = fileName ?? Path.GetFileName(filePath),
            ContentType = GetContentType(filePath)
        };
        
        _attachments.Add(attachment);
        return Self;
    }
    
    protected override EmailMessage BuildInternal()
    {
        // Validation
        if (string.IsNullOrEmpty(_to))
            throw new InvalidOperationException("Recipient email is required");
        if (string.IsNullOrEmpty(_from))
            throw new InvalidOperationException("Sender email is required");
        if (string.IsNullOrEmpty(_subject))
            throw new InvalidOperationException("Email subject is required");
        if (string.IsNullOrEmpty(_body))
            throw new InvalidOperationException("Email body is required");
        
        return new EmailMessage
        {
            To = _to,
            From = _from,
            Subject = _subject,
            Body = _body,
            CC = new List<string>(_cc),
            BCC = new List<string>(_bcc),
            Attachments = new List<EmailAttachment>(_attachments),
            Priority = _priority,
            IsHtml = _isHtml,
            CreatedAt = DateTime.UtcNow
        };
    }
    
    protected override void Reset()
    {
        _to = null;
        _from = null;
        _subject = null;
        _body = null;
        _cc.Clear();
        _bcc.Clear();
        _attachments.Clear();
        _priority = EmailPriority.Normal;
        _isHtml = false;
    }
    
    private static string ValidateEmail(string email, string paramName)
    {
        if (string.IsNullOrEmpty(email))
            throw new ArgumentException("Email cannot be null or empty", paramName);
            
        if (!email.Contains("@"))
            throw new ArgumentException($"Invalid email format: {email}", paramName);
            
        return email;
    }
    
    private static string GetContentType(string filePath)
    {
        var extension = Path.GetExtension(filePath).ToLowerInvariant();
        return extension switch
        {
            ".pdf" => "application/pdf",
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".txt" => "text/plain",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            _ => "application/octet-stream"
        };
    }
    
    // Static factory method
    public static EmailMessageBuilder Create() => new EmailMessageBuilder();
}

// Usage example with method chaining
public class EmailBuilderExamples
{
    public void SendWelcomeEmail()
    {
        var email = EmailMessageBuilder.Create()
            .From("noreply@company.com")
            .To("user@example.com")
            .Subject("Welcome to Our Platform!")
            .HtmlBody("<h1>Welcome!</h1><p>Thanks for joining us.</p>")
            .WithPriority(EmailPriority.High)
            .AttachFile("./welcome-guide.pdf", "Welcome Guide.pdf")
            .Build();
            
        // Send email using your preferred email service
        Console.WriteLine($"Email built: {email.Subject} to {email.To}");
        Console.WriteLine($"Attachments: {email.Attachments.Count}");
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Builder Pattern Benefits**:

- ✅ **Readable Construction**: Fluent interface makes complex object creation clear
- ✅ **Validation Control**: Validate during building process, ensuring valid objects
- ✅ **Immutable Results**: Objects are immutable after construction
- ✅ **Flexible Parameters**: Handle optional parameters elegantly without telescoping constructors

**Builder Pattern Variations**:

- **Simple Builder**: Direct method chaining for straightforward cases
- **Director Pattern**: Encapsulates specific construction algorithms
- **Generic Builder**: Reusable base class for consistent builder behavior
- **Step Builder**: Enforces construction order through type-safe interfaces

**When to Use Builder Pattern**:

1. **Complex objects** with many optional parameters
2. **Immutable objects** that need step-by-step construction  
3. **Configuration objects** with validation requirements
4. **Domain objects** where construction logic varies

### Next Steps

**Immediate Actions**:

- Replace telescoping constructors with builders in your codebase
- Implement fluent interfaces for complex object creation
- Continue to Part 3: **Singleton Pattern**

**Advanced Applications**:

- Test data builders for unit testing
- DSL (Domain Specific Language) creation
- Configuration management systems

## 🔗 Related Topics

**Prerequisites**: Factory Pattern (Part 1), Fluent interface design  
**Builds Upon**: Immutable object design, Method chaining patterns  
**Enables**: Singleton Pattern (Part 3), Complex object hierarchies, DSL creation  
**Related**: Fluent APIs, Configuration patterns, Test data builders
