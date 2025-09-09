# 13_Design-Patterns-Part8-Template-Method-Pattern

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Command Pattern (Part 7), Inheritance concepts  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Template Method Pattern for algorithm structure with customizable steps
- Implement data processing pipelines with pluggable processing stages
- Design authentication flows with customizable validation steps
- Apply template methods in testing frameworks and report generation systems

## 📋 Content Sections

### Quick Overview (5 minutes)

**Template Method Pattern**: *"Define the skeleton of an algorithm in a base class, letting subclasses override specific steps without changing the algorithm's structure."*

**Core Problem**: Need to define a consistent algorithm structure while allowing variations in specific implementation steps.

```text
❌ DUPLICATED ALGORITHM PROBLEM
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ EmailProcessor  │    │ SmsProcessor    │    │ PushProcessor   │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + Process()     │    │ + Process()     │    │ + Process()     │
│   Validate()    │    │   Validate()    │    │   Validate()    │
│   Transform()   │    │   Transform()   │    │   Transform()   │
│   Send()        │    │   Send()        │    │   Send()        │
│   Log()         │    │   Log()         │    │   Log()         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
    ❌ Repeated algorithm structure, inconsistent implementations

✅ TEMPLATE METHOD PATTERN SOLUTION
              ┌─────────────────┐
              │MessageProcessor │
              ├─────────────────┤
              │ + Process()     │◄─── Template Method
              │   Validate()    │◄─── Abstract Step
              │   Transform()   │◄─── Abstract Step
              │   Send()        │◄─── Abstract Step
              │   Log()         │◄─── Hook Method
              └─────────────────┘
                       ▲
         ┌─────────────┼─────────────┐
┌─────────────────┐    │    ┌─────────────────┐
│ EmailProcessor  │    │    │ SmsProcessor    │
├─────────────────┤    │    ├─────────────────┤
│ + Validate()    │    │    │ + Validate()    │
│ + Transform()   │    │    │ + Transform()   │
│ + Send()        │    │    │ + Send()        │
└─────────────────┘    │    └─────────────────┘
                       │
              ┌─────────────────┐
              │ PushProcessor   │
              ├─────────────────┤
              │ + Validate()    │
              │ + Transform()   │
              │ + Send()        │
              └─────────────────┘
    ✅ Consistent algorithm, customizable steps, reusable structure
```

**Real-World Applications**:

- **Data Processing** - ETL pipelines with pluggable transformation steps
- **Authentication** - Login flows with customizable validation methods
- **Testing Frameworks** - Test execution with setup/teardown hooks
- **Report Generation** - Document creation with flexible formatting steps

### Core Concepts (15 minutes)

#### Data Processing Pipeline System

#### Implementation 1: ETL Pipeline with Template Method

```csharp
// Abstract data processing pipeline
public abstract class DataProcessor<TInput, TOutput>
{
    public string ProcessorName { get; protected set; }
    public DateTime LastExecuted { get; private set; }
    public TimeSpan LastExecutionTime { get; private set; }

    protected DataProcessor(string processorName)
    {
        ProcessorName = processorName ?? throw new ArgumentNullException(nameof(processorName));
    }

    // Template method - defines the algorithm structure
    public ProcessingResult<TOutput> Process(TInput input)
    {
        var stopwatch = Stopwatch.StartNew();
        var result = new ProcessingResult<TOutput>();

        try
        {
            LogStart(input);

            // Step 1: Validate input
            var validationResult = ValidateInput(input);
            if (!validationResult.IsValid)
            {
                result.AddErrors(validationResult.Errors);
                return result;
            }

            // Step 2: Extract data (hook method - optional override)
            var extractedData = ExtractData(input);
            
            // Step 3: Transform data (abstract method - must override)
            var transformedData = TransformData(extractedData);
            
            // Step 4: Validate output (hook method - optional override)
            var outputValidation = ValidateOutput(transformedData);
            if (!outputValidation.IsValid)
            {
                result.AddErrors(outputValidation.Errors);
                return result;
            }

            // Step 5: Load/save data (abstract method - must override)
            var loadResult = LoadData(transformedData);
            
            result.Data = loadResult;
            result.IsSuccessful = true;
            
            // Step 6: Post-processing cleanup (hook method - optional override)
            OnProcessingComplete(input, result);
        }
        catch (Exception ex)
        {
            result.AddError($"Processing failed: {ex.Message}");
            OnProcessingError(input, ex);
        }
        finally
        {
            stopwatch.Stop();
            LastExecuted = DateTime.UtcNow;
            LastExecutionTime = stopwatch.Elapsed;
            LogComplete(result);
        }

        return result;
    }

    // Abstract methods - must be implemented by subclasses
    protected abstract ValidationResult ValidateInput(TInput input);
    protected abstract TOutput TransformData(object extractedData);
    protected abstract TOutput LoadData(TOutput transformedData);

    // Hook methods - can be overridden by subclasses
    protected virtual object ExtractData(TInput input)
    {
        return input; // Default: no extraction needed
    }

    protected virtual ValidationResult ValidateOutput(TOutput output)
    {
        return ValidationResult.Success(); // Default: always valid
    }

    protected virtual void OnProcessingComplete(TInput input, ProcessingResult<TOutput> result)
    {
        // Default: no post-processing
    }

    protected virtual void OnProcessingError(TInput input, Exception error)
    {
        Console.WriteLine($"Error in {ProcessorName}: {error.Message}");
    }

    // Concrete methods - same for all subclasses
    private void LogStart(TInput input)
    {
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] Starting {ProcessorName} processing");
    }

    private void LogComplete(ProcessingResult<TOutput> result)
    {
        var status = result.IsSuccessful ? "SUCCESS" : "FAILED";
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {ProcessorName} completed: {status} ({LastExecutionTime.TotalMilliseconds:F0}ms)");
        
        if (!result.IsSuccessful && result.Errors.Any())
        {
            Console.WriteLine($"  Errors: {string.Join("; ", result.Errors)}");
        }
    }
}

// Supporting classes
public class ProcessingResult<T>
{
    public T Data { get; set; }
    public bool IsSuccessful { get; set; }
    public List<string> Errors { get; }
    public Dictionary<string, object> Metadata { get; }

    public ProcessingResult()
    {
        Errors = new List<string>();
        Metadata = new Dictionary<string, object>();
    }

    public void AddError(string error)
    {
        Errors.Add(error);
        IsSuccessful = false;
    }

    public void AddErrors(IEnumerable<string> errors)
    {
        Errors.AddRange(errors);
        if (Errors.Any())
            IsSuccessful = false;
    }
}

public class ValidationResult
{
    public bool IsValid { get; }
    public List<string> Errors { get; }

    private ValidationResult(bool isValid, IEnumerable<string> errors = null)
    {
        IsValid = isValid;
        Errors = new List<string>(errors ?? Enumerable.Empty<string>());
    }

    public static ValidationResult Success() => new ValidationResult(true);
    public static ValidationResult Failure(params string[] errors) => new ValidationResult(false, errors);
    public static ValidationResult Failure(IEnumerable<string> errors) => new ValidationResult(false, errors);
}

// Concrete processor: CSV to JSON converter
public class CsvToJsonProcessor : DataProcessor<string, string>
{
    public CsvToJsonProcessor() : base("CSV to JSON Processor") { }

    protected override ValidationResult ValidateInput(string input)
    {
        if (string.IsNullOrWhiteSpace(input))
            return ValidationResult.Failure("Input CSV data cannot be empty");

        if (!input.Contains(','))
            return ValidationResult.Failure("Input does not appear to be CSV format");

        return ValidationResult.Success();
    }

    protected override object ExtractData(string input)
    {
        // Parse CSV into rows and columns
        var lines = input.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        var headers = lines[0].Split(',').Select(h => h.Trim()).ToArray();
        
        var rows = new List<Dictionary<string, string>>();
        
        for (int i = 1; i < lines.Length; i++)
        {
            var values = lines[i].Split(',');
            var row = new Dictionary<string, string>();
            
            for (int j = 0; j < headers.Length && j < values.Length; j++)
            {
                row[headers[j]] = values[j].Trim();
            }
            rows.Add(row);
        }

        return new { Headers = headers, Rows = rows };
    }

    protected override string TransformData(object extractedData)
    {
        dynamic data = extractedData;
        var jsonObjects = new List<object>();

        foreach (var row in data.Rows)
        {
            jsonObjects.Add(row);
        }

        return System.Text.Json.JsonSerializer.Serialize(jsonObjects, new JsonSerializerOptions 
        { 
            WriteIndented = true 
        });
    }

    protected override string LoadData(string transformedData)
    {
        // In a real scenario, this might save to a file or database
        Console.WriteLine("JSON output preview (first 200 chars):");
        Console.WriteLine(transformedData.Length > 200 
            ? transformedData.Substring(0, 200) + "..." 
            : transformedData);
        
        return transformedData;
    }

    protected override ValidationResult ValidateOutput(string output)
    {
        try
        {
            System.Text.Json.JsonSerializer.Deserialize<object[]>(output);
            return ValidationResult.Success();
        }
        catch (JsonException ex)
        {
            return ValidationResult.Failure($"Output is not valid JSON: {ex.Message}");
        }
    }
}

// Concrete processor: XML to CSV converter
public class XmlToCsvProcessor : DataProcessor<string, string>
{
    public XmlToCsvProcessor() : base("XML to CSV Processor") { }

    protected override ValidationResult ValidateInput(string input)
    {
        if (string.IsNullOrWhiteSpace(input))
            return ValidationResult.Failure("Input XML data cannot be empty");

        if (!input.TrimStart().StartsWith('<'))
            return ValidationResult.Failure("Input does not appear to be XML format");

        return ValidationResult.Success();
    }

    protected override object ExtractData(string input)
    {
        try
        {
            var doc = XElement.Parse(input);
            var records = doc.Descendants().Where(e => !e.HasElements).GroupBy(e => e.Parent).ToList();
            
            var headers = records.FirstOrDefault()?.Select(e => e.Name.LocalName).ToArray() ?? new string[0];
            var rows = records.Select(group => 
                headers.ToDictionary(h => h, h => group.FirstOrDefault(e => e.Name.LocalName == h)?.Value ?? "")
            ).ToList();

            return new { Headers = headers, Rows = rows };
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Failed to parse XML: {ex.Message}");
        }
    }

    protected override string TransformData(object extractedData)
    {
        dynamic data = extractedData;
        var csv = new StringBuilder();
        
        // Add headers
        csv.AppendLine(string.Join(",", data.Headers));
        
        // Add rows
        foreach (var row in data.Rows)
        {
            var values = ((string[])data.Headers).Select(header => 
                row.ContainsKey(header) ? $"\"{row[header]}\"" : "\"\"");
            csv.AppendLine(string.Join(",", values));
        }

        return csv.ToString();
    }

    protected override string LoadData(string transformedData)
    {
        Console.WriteLine("CSV output preview (first 200 chars):");
        Console.WriteLine(transformedData.Length > 200 
            ? transformedData.Substring(0, 200) + "..." 
            : transformedData);
        
        return transformedData;
    }

    protected override void OnProcessingComplete(string input, ProcessingResult<string> result)
    {
        if (result.IsSuccessful)
        {
            var lineCount = result.Data.Split('\n', StringSplitOptions.RemoveEmptyEntries).Length;
            Console.WriteLine($"Successfully converted XML to CSV with {lineCount} lines");
        }
    }
}

// Usage example
public class DataProcessingExample
{
    public void DemonstrateTemplateMethod()
    {
        Console.WriteLine("=== Template Method Pattern - Data Processing Demo ===");

        // Sample CSV data
        var csvData = @"Name,Age,City
John Doe,30,New York
Jane Smith,25,Los Angeles
Bob Johnson,35,Chicago";

        // Sample XML data
        var xmlData = @"<people>
    <person>
        <Name>Alice Wilson</Name>
        <Age>28</Age>
        <City>Seattle</City>
    </person>
    <person>
        <Name>Charlie Brown</Name>
        <Age>32</Age>
        <City>Boston</City>
    </person>
</people>";

        // Process CSV to JSON
        Console.WriteLine("\n--- CSV to JSON Processing ---");
        var csvProcessor = new CsvToJsonProcessor();
        var jsonResult = csvProcessor.Process(csvData);
        
        if (jsonResult.IsSuccessful)
        {
            Console.WriteLine("✅ CSV to JSON conversion successful");
        }
        else
        {
            Console.WriteLine("❌ CSV to JSON conversion failed:");
            jsonResult.Errors.ForEach(Console.WriteLine);
        }

        // Process XML to CSV
        Console.WriteLine("\n--- XML to CSV Processing ---");
        var xmlProcessor = new XmlToCsvProcessor();
        var csvResult = xmlProcessor.Process(xmlData);
        
        if (csvResult.IsSuccessful)
        {
            Console.WriteLine("✅ XML to CSV conversion successful");
        }
        else
        {
            Console.WriteLine("❌ XML to CSV conversion failed:");
            csvResult.Errors.ForEach(Console.WriteLine);
        }

        // Demonstrate error handling
        Console.WriteLine("\n--- Error Handling Demo ---");
        var invalidData = "This is not valid CSV or XML data";
        
        Console.WriteLine("Processing invalid data with CSV processor:");
        var errorResult1 = csvProcessor.Process(invalidData);
        
        Console.WriteLine("Processing invalid data with XML processor:");
        var errorResult2 = xmlProcessor.Process(invalidData);
    }
}
```

#### Authentication Framework

#### Implementation 2: Login Flow Template

```csharp
// Abstract authentication template
public abstract class AuthenticationFlow
{
    public string FlowName { get; protected set; }
    public TimeSpan SessionTimeout { get; protected set; }
    public int MaxLoginAttempts { get; protected set; }

    protected AuthenticationFlow(string flowName, TimeSpan sessionTimeout, int maxLoginAttempts = 3)
    {
        FlowName = flowName;
        SessionTimeout = sessionTimeout;
        MaxLoginAttempts = maxLoginAttempts;
    }

    // Template method - defines the authentication algorithm
    public AuthResult Authenticate(AuthRequest request)
    {
        try
        {
            LogAuthenticationStart(request);

            // Step 1: Pre-authentication checks
            var preCheckResult = PerformPreAuthenticationChecks(request);
            if (!preCheckResult.IsSuccessful)
                return preCheckResult;

            // Step 2: Validate credentials (abstract method)
            var credentialResult = ValidateCredentials(request);
            if (!credentialResult.IsSuccessful)
            {
                OnAuthenticationFailure(request, credentialResult);
                return credentialResult;
            }

            // Step 3: Additional security checks (hook method)
            var securityResult = PerformSecurityChecks(request, credentialResult.User);
            if (!securityResult.IsSuccessful)
            {
                OnAuthenticationFailure(request, securityResult);
                return securityResult;
            }

            // Step 4: Create session (abstract method)
            var sessionResult = CreateUserSession(credentialResult.User);
            if (!sessionResult.IsSuccessful)
                return sessionResult;

            // Step 5: Post-authentication actions (hook method)
            OnAuthenticationSuccess(request, sessionResult);

            LogAuthenticationSuccess(request, sessionResult.User);
            return sessionResult;
        }
        catch (Exception ex)
        {
            var errorResult = AuthResult.Failure($"Authentication error: {ex.Message}");
            OnAuthenticationError(request, ex);
            LogAuthenticationError(request, ex);
            return errorResult;
        }
    }

    // Abstract methods - must be implemented
    protected abstract AuthResult ValidateCredentials(AuthRequest request);
    protected abstract AuthResult CreateUserSession(User user);

    // Hook methods - can be overridden
    protected virtual AuthResult PerformPreAuthenticationChecks(AuthRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Username))
            return AuthResult.Failure("Username is required");
        
        if (string.IsNullOrWhiteSpace(request.Password))
            return AuthResult.Failure("Password is required");

        return AuthResult.Success(null);
    }

    protected virtual AuthResult PerformSecurityChecks(AuthRequest request, User user)
    {
        // Default: no additional security checks
        return AuthResult.Success(user);
    }

    protected virtual void OnAuthenticationSuccess(AuthRequest request, AuthResult result)
    {
        // Default: no additional actions
    }

    protected virtual void OnAuthenticationFailure(AuthRequest request, AuthResult result)
    {
        // Default: no additional actions
    }

    protected virtual void OnAuthenticationError(AuthRequest request, Exception error)
    {
        // Default: no additional actions
    }

    // Concrete logging methods
    private void LogAuthenticationStart(AuthRequest request)
    {
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] Starting {FlowName} for user: {request.Username}");
    }

    private void LogAuthenticationSuccess(AuthRequest request, User user)
    {
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] ✅ {FlowName} successful for user: {user.Username}");
    }

    private void LogAuthenticationError(AuthRequest request, Exception error)
    {
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] ❌ {FlowName} error for user: {request.Username} - {error.Message}");
    }
}

// Supporting classes
public class AuthRequest
{
    public string Username { get; set; }
    public string Password { get; set; }
    public string IPAddress { get; set; }
    public string UserAgent { get; set; }
    public Dictionary<string, object> AdditionalData { get; }

    public AuthRequest()
    {
        AdditionalData = new Dictionary<string, object>();
    }
}

public class User
{
    public string Username { get; set; }
    public string Email { get; set; }
    public List<string> Roles { get; set; }
    public DateTime LastLogin { get; set; }
    public bool IsActive { get; set; }
    public Dictionary<string, object> Profile { get; }

    public User()
    {
        Roles = new List<string>();
        Profile = new Dictionary<string, object>();
    }
}

public class AuthResult
{
    public bool IsSuccessful { get; }
    public User User { get; }
    public string SessionToken { get; }
    public DateTime ExpiresAt { get; }
    public string ErrorMessage { get; }
    public Dictionary<string, object> Metadata { get; }

    private AuthResult(bool isSuccessful, User user = null, string sessionToken = null, 
                      DateTime? expiresAt = null, string errorMessage = null)
    {
        IsSuccessful = isSuccessful;
        User = user;
        SessionToken = sessionToken;
        ExpiresAt = expiresAt ?? DateTime.UtcNow.AddHours(1);
        ErrorMessage = errorMessage;
        Metadata = new Dictionary<string, object>();
    }

    public static AuthResult Success(User user, string sessionToken = null, DateTime? expiresAt = null)
    {
        return new AuthResult(true, user, sessionToken ?? Guid.NewGuid().ToString(), expiresAt);
    }

    public static AuthResult Failure(string errorMessage)
    {
        return new AuthResult(false, errorMessage: errorMessage);
    }
}

// Concrete implementation: Database authentication
public class DatabaseAuthFlow : AuthenticationFlow
{
    private readonly Dictionary<string, User> _users; // Simulated database

    public DatabaseAuthFlow() : base("Database Authentication", TimeSpan.FromHours(8))
    {
        // Initialize with sample users
        _users = new Dictionary<string, User>
        {
            ["admin"] = new User { Username = "admin", Email = "admin@example.com", IsActive = true, Roles = { "Admin" } },
            ["user1"] = new User { Username = "user1", Email = "user1@example.com", IsActive = true, Roles = { "User" } },
            ["disabled"] = new User { Username = "disabled", Email = "disabled@example.com", IsActive = false, Roles = { "User" } }
        };
    }

    protected override AuthResult ValidateCredentials(AuthRequest request)
    {
        // Simulate password checking (in real scenarios, use proper hashing)
        if (!_users.ContainsKey(request.Username))
            return AuthResult.Failure("Invalid username or password");

        var user = _users[request.Username];
        
        // Simple password check (in reality, compare hashed passwords)
        if (request.Password != "password123") // Demo password
            return AuthResult.Failure("Invalid username or password");

        if (!user.IsActive)
            return AuthResult.Failure("Account is disabled");

        user.LastLogin = DateTime.UtcNow;
        return AuthResult.Success(user);
    }

    protected override AuthResult CreateUserSession(User user)
    {
        var sessionToken = $"db_session_{Guid.NewGuid():N}";
        var expiresAt = DateTime.UtcNow.Add(SessionTimeout);
        
        Console.WriteLine($"Created database session for {user.Username}, expires at {expiresAt:yyyy-MM-dd HH:mm:ss}");
        
        return AuthResult.Success(user, sessionToken, expiresAt);
    }

    protected override AuthResult PerformSecurityChecks(AuthRequest request, User user)
    {
        // Check for suspicious IP addresses
        var suspiciousIPs = new[] { "192.168.1.100", "10.0.0.50" };
        if (suspiciousIPs.Contains(request.IPAddress))
        {
            return AuthResult.Failure("Access denied from suspicious IP address");
        }

        return AuthResult.Success(user);
    }

    protected override void OnAuthenticationSuccess(AuthRequest request, AuthResult result)
    {
        Console.WriteLine($"Database auth success: User {result.User.Username} logged in from {request.IPAddress}");
    }
}

// Concrete implementation: OAuth authentication
public class OAuthAuthFlow : AuthenticationFlow
{
    public OAuthAuthFlow() : base("OAuth Authentication", TimeSpan.FromHours(2))
    {
    }

    protected override AuthResult ValidateCredentials(AuthRequest request)
    {
        // Simulate OAuth token validation
        var token = request.AdditionalData.ContainsKey("oauth_token") 
            ? request.AdditionalData["oauth_token"]?.ToString() 
            : null;

        if (string.IsNullOrWhiteSpace(token))
            return AuthResult.Failure("OAuth token is required");

        // Simulate token validation (in reality, validate with OAuth provider)
        if (!token.StartsWith("oauth_"))
            return AuthResult.Failure("Invalid OAuth token format");

        var user = new User
        {
            Username = request.Username,
            Email = $"{request.Username}@oauth-provider.com",
            IsActive = true,
            Roles = { "OAuthUser" }
        };

        return AuthResult.Success(user);
    }

    protected override AuthResult CreateUserSession(User user)
    {
        var sessionToken = $"oauth_session_{Guid.NewGuid():N}";
        var expiresAt = DateTime.UtcNow.Add(SessionTimeout);
        
        Console.WriteLine($"Created OAuth session for {user.Username}, expires at {expiresAt:yyyy-MM-dd HH:mm:ss}");
        
        return AuthResult.Success(user, sessionToken, expiresAt);
    }

    protected override void OnAuthenticationSuccess(AuthRequest request, AuthResult result)
    {
        Console.WriteLine($"OAuth auth success: External user {result.User.Username} authenticated");
    }

    protected override void OnAuthenticationFailure(AuthRequest request, AuthResult result)
    {
        Console.WriteLine($"OAuth auth failure for {request.Username}: {result.ErrorMessage}");
    }
}

// Usage example
public class AuthenticationExample
{
    public void DemonstrateAuthenticationFlows()
    {
        Console.WriteLine("=== Authentication Template Method Demo ===");

        var dbAuth = new DatabaseAuthFlow();
        var oauthAuth = new OAuthAuthFlow();

        // Test database authentication
        Console.WriteLine("\n--- Database Authentication ---");
        
        var dbRequest = new AuthRequest
        {
            Username = "admin",
            Password = "password123",
            IPAddress = "192.168.1.10",
            UserAgent = "Mozilla/5.0..."
        };

        var dbResult = dbAuth.Authenticate(dbRequest);
        Console.WriteLine($"Result: {(dbResult.IsSuccessful ? "Success" : "Failed")}");
        if (dbResult.IsSuccessful)
        {
            Console.WriteLine($"Session Token: {dbResult.SessionToken}");
            Console.WriteLine($"Expires: {dbResult.ExpiresAt}");
        }
        else
        {
            Console.WriteLine($"Error: {dbResult.ErrorMessage}");
        }

        // Test OAuth authentication
        Console.WriteLine("\n--- OAuth Authentication ---");
        
        var oauthRequest = new AuthRequest
        {
            Username = "john.doe",
            Password = "", // Not needed for OAuth
            IPAddress = "203.0.113.5"
        };
        oauthRequest.AdditionalData["oauth_token"] = "oauth_abc123xyz789";

        var oauthResult = oauthAuth.Authenticate(oauthRequest);
        Console.WriteLine($"Result: {(oauthResult.IsSuccessful ? "Success" : "Failed")}");
        if (oauthResult.IsSuccessful)
        {
            Console.WriteLine($"Session Token: {oauthResult.SessionToken}");
            Console.WriteLine($"User Email: {oauthResult.User.Email}");
        }
        else
        {
            Console.WriteLine($"Error: {oauthResult.ErrorMessage}");
        }

        // Test authentication failures
        Console.WriteLine("\n--- Authentication Failures ---");
        
        var invalidRequest = new AuthRequest
        {
            Username = "invalid_user",
            Password = "wrong_password",
            IPAddress = "192.168.1.100" // Suspicious IP
        };

        var failResult = dbAuth.Authenticate(invalidRequest);
        Console.WriteLine($"Invalid credentials result: {failResult.ErrorMessage}");
    }
}
```

### Practical Implementation (8 minutes)

#### Testing Framework with Setup/Teardown

#### Implementation 3: Test Execution Template

```csharp
// Abstract test runner template
public abstract class TestRunner<T>
{
    public string TestName { get; protected set; }
    public DateTime LastRun { get; private set; }
    public TimeSpan LastExecutionTime { get; private set; }
    public TestResult LastResult { get; private set; }

    protected TestRunner(string testName)
    {
        TestName = testName ?? throw new ArgumentNullException(nameof(testName));
    }

    // Template method - defines test execution flow
    public TestResult RunTest(T testData)
    {
        var stopwatch = Stopwatch.StartNew();
        var result = new TestResult { TestName = TestName, StartTime = DateTime.UtcNow };

        try
        {
            LogTestStart();

            // Step 1: Setup (hook method)
            SetupTest();
            result.SetupCompleted = true;

            // Step 2: Execute test (abstract method)
            var testResult = ExecuteTest(testData);
            result.TestCompleted = true;
            result.IsSuccessful = testResult;

            // Step 3: Verify results (abstract method)
            var verificationResult = VerifyResults();
            result.VerificationCompleted = true;
            result.IsSuccessful = result.IsSuccessful && verificationResult;

            // Step 4: Cleanup (hook method)
            CleanupTest();
            result.CleanupCompleted = true;

            if (result.IsSuccessful)
            {
                OnTestSuccess(result);
            }
            else
            {
                OnTestFailure(result);
            }
        }
        catch (Exception ex)
        {
            result.IsSuccessful = false;
            result.ErrorMessage = ex.Message;
            result.Exception = ex;
            OnTestError(result, ex);
        }
        finally
        {
            // Always ensure cleanup, even if test failed
            try
            {
                FinalCleanup();
            }
            catch (Exception cleanupEx)
            {
                result.CleanupErrors.Add(cleanupEx.Message);
            }

            stopwatch.Stop();
            result.EndTime = DateTime.UtcNow;
            result.ExecutionTime = stopwatch.Elapsed;
            
            LastRun = DateTime.UtcNow;
            LastExecutionTime = stopwatch.Elapsed;
            LastResult = result;
            
            LogTestComplete(result);
        }

        return result;
    }

    // Abstract methods - must be implemented
    protected abstract bool ExecuteTest(T testData);
    protected abstract bool VerifyResults();

    // Hook methods - can be overridden
    protected virtual void SetupTest() { }
    protected virtual void CleanupTest() { }
    protected virtual void FinalCleanup() { }
    protected virtual void OnTestSuccess(TestResult result) { }
    protected virtual void OnTestFailure(TestResult result) { }
    protected virtual void OnTestError(TestResult result, Exception error) { }

    // Concrete logging methods
    private void LogTestStart()
    {
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] 🧪 Starting test: {TestName}");
    }

    private void LogTestComplete(TestResult result)
    {
        var status = result.IsSuccessful ? "✅ PASSED" : "❌ FAILED";
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {status} {TestName} ({result.ExecutionTime.TotalMilliseconds:F0}ms)");
        
        if (!result.IsSuccessful && !string.IsNullOrEmpty(result.ErrorMessage))
        {
            Console.WriteLine($"  Error: {result.ErrorMessage}");
        }

        if (result.CleanupErrors.Any())
        {
            Console.WriteLine($"  Cleanup warnings: {string.Join("; ", result.CleanupErrors)}");
        }
    }
}

// Test result class
public class TestResult
{
    public string TestName { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public TimeSpan ExecutionTime { get; set; }
    public bool IsSuccessful { get; set; }
    public string ErrorMessage { get; set; }
    public Exception Exception { get; set; }
    
    public bool SetupCompleted { get; set; }
    public bool TestCompleted { get; set; }
    public bool VerificationCompleted { get; set; }
    public bool CleanupCompleted { get; set; }
    
    public List<string> CleanupErrors { get; }
    public Dictionary<string, object> Metadata { get; }

    public TestResult()
    {
        CleanupErrors = new List<string>();
        Metadata = new Dictionary<string, object>();
    }

    public override string ToString()
    {
        return $"{TestName}: {(IsSuccessful ? "PASSED" : "FAILED")} ({ExecutionTime.TotalMilliseconds:F0}ms)";
    }
}

// Concrete test: Database connection test
public class DatabaseConnectionTest : TestRunner<string>
{
    private IDbConnection _connection;
    private string _testTable = "TestTable_" + Guid.NewGuid().ToString("N")[..8];

    public DatabaseConnectionTest() : base("Database Connection Test") { }

    protected override void SetupTest()
    {
        Console.WriteLine("  📋 Setting up database connection...");
        
        // Simulate database connection setup
        _connection = CreateMockConnection();
        
        // Create test table
        ExecuteCommand($"CREATE TABLE {_testTable} (Id INT, Name VARCHAR(50))");
        
        Console.WriteLine($"  📋 Created test table: {_testTable}");
    }

    protected override bool ExecuteTest(string connectionString)
    {
        Console.WriteLine("  🔄 Testing database operations...");
        
        // Test insert
        var insertResult = ExecuteCommand($"INSERT INTO {_testTable} VALUES (1, 'Test Record')");
        if (!insertResult)
        {
            Console.WriteLine("  ❌ Insert operation failed");
            return false;
        }

        // Test select
        var selectResult = ExecuteQuery($"SELECT COUNT(*) FROM {_testTable}");
        if (selectResult != 1)
        {
            Console.WriteLine($"  ❌ Expected 1 record, found {selectResult}");
            return false;
        }

        Console.WriteLine("  ✅ Database operations successful");
        return true;
    }

    protected override bool VerifyResults()
    {
        Console.WriteLine("  🔍 Verifying test results...");
        
        // Verify data integrity
        var count = ExecuteQuery($"SELECT COUNT(*) FROM {_testTable}");
        var verified = count == 1;
        
        Console.WriteLine($"  🔍 Verification: {(verified ? "PASSED" : "FAILED")} - Record count: {count}");
        return verified;
    }

    protected override void CleanupTest()
    {
        Console.WriteLine("  🧹 Cleaning up test data...");
        
        if (_connection != null && _testTable != null)
        {
            ExecuteCommand($"DROP TABLE {_testTable}");
            Console.WriteLine($"  🧹 Dropped test table: {_testTable}");
        }
    }

    protected override void FinalCleanup()
    {
        if (_connection != null)
        {
            _connection.Dispose();
            _connection = null;
            Console.WriteLine("  🧹 Database connection closed");
        }
    }

    protected override void OnTestSuccess(TestResult result)
    {
        Console.WriteLine("  🎉 Database connectivity verified successfully");
        result.Metadata["TableCreated"] = _testTable;
        result.Metadata["RecordsProcessed"] = 1;
    }

    protected override void OnTestFailure(TestResult result)
    {
        Console.WriteLine("  ⚠️ Database connectivity test failed - check connection settings");
    }

    // Mock database operations
    private IDbConnection CreateMockConnection()
    {
        return new MockDbConnection();
    }

    private bool ExecuteCommand(string sql)
    {
        Console.WriteLine($"    SQL: {sql}");
        // Simulate SQL execution
        return true;
    }

    private int ExecuteQuery(string sql)
    {
        Console.WriteLine($"    SQL: {sql}");
        // Simulate query result
        return 1;
    }
}

// Mock database connection for demo
public class MockDbConnection : IDbConnection
{
    public string ConnectionString { get; set; } = "mock://localhost";
    public int ConnectionTimeout => 30;
    public string Database => "TestDB";
    public ConnectionState State => ConnectionState.Open;

    public IDbTransaction BeginTransaction() => null;
    public IDbTransaction BeginTransaction(IsolationLevel il) => null;
    public void ChangeDatabase(string databaseName) { }
    public void Close() { }
    public IDbCommand CreateCommand() => null;
    public void Dispose() { }
    public void Open() { }
}

// Concrete test: API endpoint test
public class ApiEndpointTest : TestRunner<string>
{
    private HttpClient _httpClient;
    private string _baseUrl;
    private readonly List<string> _createdResources;

    public ApiEndpointTest() : base("API Endpoint Test")
    {
        _createdResources = new List<string>();
    }

    protected override void SetupTest()
    {
        Console.WriteLine("  📋 Setting up HTTP client...");
        _httpClient = new HttpClient();
        _baseUrl = "https://jsonplaceholder.typicode.com"; // Demo API
        _httpClient.BaseAddress = new Uri(_baseUrl);
        Console.WriteLine($"  📋 API Base URL: {_baseUrl}");
    }

    protected override bool ExecuteTest(string endpoint)
    {
        Console.WriteLine($"  🔄 Testing API endpoint: {endpoint}");

        try
        {
            // Test GET request
            var response = _httpClient.GetAsync(endpoint).Result;
            Console.WriteLine($"    GET {endpoint}: {response.StatusCode}");
            
            if (!response.IsSuccessStatusCode)
            {
                Console.WriteLine($"  ❌ GET request failed: {response.StatusCode}");
                return false;
            }

            var content = response.Content.ReadAsStringAsync().Result;
            if (string.IsNullOrEmpty(content))
            {
                Console.WriteLine("  ❌ Response content is empty");
                return false;
            }

            Console.WriteLine($"  ✅ API endpoint responding (content length: {content.Length})");
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"  ❌ API test exception: {ex.Message}");
            return false;
        }
    }

    protected override bool VerifyResults()
    {
        Console.WriteLine("  🔍 Verifying API response format...");
        
        // Test a known endpoint for JSON format
        try
        {
            var response = _httpClient.GetAsync("/posts/1").Result;
            var json = response.Content.ReadAsStringAsync().Result;
            
            // Simple JSON validation
            var isValidJson = json.TrimStart().StartsWith("{") && json.TrimEnd().EndsWith("}");
            
            Console.WriteLine($"  🔍 JSON format validation: {(isValidJson ? "PASSED" : "FAILED")}");
            return isValidJson;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"  🔍 Verification failed: {ex.Message}");
            return false;
        }
    }

    protected override void CleanupTest()
    {
        Console.WriteLine("  🧹 Cleaning up API test resources...");
        
        // In a real scenario, delete any created test resources
        foreach (var resource in _createdResources)
        {
            Console.WriteLine($"  🧹 Would delete: {resource}");
        }
        _createdResources.Clear();
    }

    protected override void FinalCleanup()
    {
        if (_httpClient != null)
        {
            _httpClient.Dispose();
            _httpClient = null;
            Console.WriteLine("  🧹 HTTP client disposed");
        }
    }

    protected override void OnTestSuccess(TestResult result)
    {
        Console.WriteLine("  🎉 API endpoint is healthy and responding correctly");
        result.Metadata["BaseUrl"] = _baseUrl;
        result.Metadata["EndpointTested"] = true;
    }

    protected override void OnTestFailure(TestResult result)
    {
        Console.WriteLine("  ⚠️ API endpoint test failed - check service availability");
    }
}

// Test suite runner
public class TestSuite
{
    private readonly List<TestResult> _results;

    public TestSuite()
    {
        _results = new List<TestResult>();
    }

    public void RunAllTests()
    {
        Console.WriteLine("=== Test Suite Execution (Template Method Pattern) ===");

        // Run database test
        var dbTest = new DatabaseConnectionTest();
        var dbResult = dbTest.RunTest("Server=localhost;Database=TestDB");
        _results.Add(dbResult);

        Console.WriteLine();

        // Run API test
        var apiTest = new ApiEndpointTest();
        var apiResult = apiTest.RunTest("/posts");
        _results.Add(apiResult);

        // Print summary
        Console.WriteLine("\n=== Test Suite Summary ===");
        var passed = _results.Count(r => r.IsSuccessful);
        var total = _results.Count;
        
        Console.WriteLine($"Tests Run: {total}");
        Console.WriteLine($"Passed: {passed}");
        Console.WriteLine($"Failed: {total - passed}");
        Console.WriteLine($"Success Rate: {(double)passed / total * 100:F1}%");
        
        Console.WriteLine("\nDetailed Results:");
        foreach (var result in _results)
        {
            var status = result.IsSuccessful ? "✅" : "❌";
            Console.WriteLine($"  {status} {result}");
        }
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Template Method Pattern Benefits**:

- ✅ **Algorithm Structure**: Defines consistent flow while allowing step customization
- ✅ **Code Reuse**: Common algorithm logic shared across implementations
- ✅ **Extensibility**: Easy to add new implementations with custom steps
- ✅ **Consistency**: Ensures all implementations follow the same structure

**Template Method Applications**:

- **Data Processing** - ETL pipelines with pluggable transformation steps
- **Authentication** - Login flows with customizable validation methods
- **Testing Frameworks** - Test execution with setup/teardown hooks
- **Report Generation** - Document creation with flexible formatting steps

**Design Considerations**:

- Use abstract methods for required customization points
- Use hook methods for optional customization points
- Keep the template method at the right abstraction level
- Document the intended flow and extension points

### Next Steps

**Design Patterns Series**: ✅ **100% COMPLETE** (8/8 modules)

**Software Design Principles Domain**:

- ✅ SOLID Principles (5 modules)
- ✅ Design Patterns (8 modules)
- 🔄 Next: OOP Fundamentals, Architectural Patterns

**Development Domain Progress**: **75% Complete**

- ✅ Python (Advanced Patterns complete)
- ✅ Software Design Principles (SOLID + Design Patterns complete)  
- 🔄 Remaining: C# Development, Git Version Control

## 🔗 Related Topics

**Prerequisites**: Command Pattern (Part 7), Inheritance concepts, Algorithm design  
**Builds Upon**: Strategy Pattern, Factory Pattern, Abstract classes  
**Enables**: Chain of Responsibility, Visitor Pattern, Framework design  
**Related**: Strategy Pattern (different approach to algorithm variation)
