# 13B_Design-Patterns-Part8B-Template-Method-Authentication

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Template Method Fundamentals (Part A), Security concepts, Authentication patterns  
**Estimated Time**: Part B of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement authentication flows using Template Method Pattern for security pipelines
- Design flexible login systems with customizable validation steps
- Apply multi-factor authentication patterns with pluggable security checks
- Master enterprise-grade authentication architecture with proper error handling

## 📋 Content Sections (27-Minute Structure)

### Authentication Template Architecture (5 minutes)

**Authentication Challenge**: Different authentication methods (database, LDAP, OAuth, API) require consistent security flow while allowing customization of validation steps.

```text
✅ TEMPLATE METHOD FOR AUTHENTICATION
              ┌─────────────────────┐
              │ AuthenticationFlow  │
              ├─────────────────────┤
              │ + Authenticate()    │◄─── Template Method
              │   PreChecks()       │◄─── Hook Method
              │   ValidateCredentials() │◄─── Abstract Method
              │   SecurityChecks()  │◄─── Hook Method
              │   CreateSession()   │◄─── Abstract Method
              │   PostActions()     │◄─── Hook Method
              └─────────────────────┘
                       ▲
         ┌─────────────┼─────────────┐
┌─────────────────┐    │    ┌─────────────────┐
│ DatabaseAuth    │    │    │ LdapAuth        │
├─────────────────┤    │    ├─────────────────┤
│ +ValidateCredentials()│   │ +ValidateCredentials()│
│ +CreateSession()│    │    │ +CreateSession()│
│ +SecurityChecks()│   │    │ +SecurityChecks()│
└─────────────────┘    │    └─────────────────┘
                       │
              ┌─────────────────┐
              │ OAuthAuth       │
              ├─────────────────┤
              │ +ValidateCredentials()│
              │ +CreateSession()│
              └─────────────────┘
```

### Core Authentication Framework (15 minutes)

#### Abstract Authentication Flow

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

            // Step 1: Pre-authentication checks (hook method)
            var preCheckResult = PerformPreAuthenticationChecks(request);
            if (!preCheckResult.IsSuccessful)
                return preCheckResult;

            // Step 2: Validate credentials (abstract method - must implement)
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

            // Step 4: Create session (abstract method - must implement)
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

    // Abstract methods - must be implemented by subclasses
    protected abstract AuthResult ValidateCredentials(AuthRequest request);
    protected abstract AuthResult CreateUserSession(User user);

    // Hook methods - can be overridden by subclasses
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

    // Concrete logging methods - same for all implementations
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
```

#### Supporting Authentication Classes

```csharp
// Authentication request container
public class AuthRequest
{
    public string Username { get; set; }
    public string Password { get; set; }
    public string IPAddress { get; set; }
    public string UserAgent { get; set; }
    public string TwoFactorCode { get; set; }
    public Dictionary<string, string> AdditionalData { get; set; }

    public AuthRequest(string username, string password)
    {
        Username = username;
        Password = password;
        AdditionalData = new Dictionary<string, string>();
    }
}

// User model
public class User
{
    public int Id { get; set; }
    public string Username { get; set; }
    public string Email { get; set; }
    public List<string> Roles { get; set; }
    public bool IsTwoFactorEnabled { get; set; }
    public DateTime LastLogin { get; set; }
    public bool IsLocked { get; set; }
    public int FailedLoginAttempts { get; set; }

    public User()
    {
        Roles = new List<string>();
    }
}

// Authentication result
public class AuthResult
{
    public bool IsSuccessful { get; }
    public User User { get; }
    public string SessionToken { get; }
    public DateTime ExpiresAt { get; }
    public List<string> Errors { get; }
    public Dictionary<string, object> Metadata { get; }

    private AuthResult(bool isSuccessful, User user, string sessionToken, DateTime expiresAt, 
                      IEnumerable<string> errors = null)
    {
        IsSuccessful = isSuccessful;
        User = user;
        SessionToken = sessionToken;
        ExpiresAt = expiresAt;
        Errors = new List<string>(errors ?? Enumerable.Empty<string>());
        Metadata = new Dictionary<string, object>();
    }

    public static AuthResult Success(User user, string sessionToken = null, DateTime? expiresAt = null)
    {
        return new AuthResult(true, user, sessionToken, expiresAt ?? DateTime.UtcNow.AddHours(8));
    }

    public static AuthResult Failure(params string[] errors)
    {
        return new AuthResult(false, null, null, DateTime.MinValue, errors);
    }
}
```

#### Database Authentication Implementation

```csharp
public class DatabaseAuthenticationFlow : AuthenticationFlow
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly ISessionManager _sessionManager;

    public DatabaseAuthenticationFlow(IUserRepository userRepository, 
                                    IPasswordHasher passwordHasher,
                                    ISessionManager sessionManager) 
        : base("Database Authentication", TimeSpan.FromHours(8))
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _passwordHasher = passwordHasher ?? throw new ArgumentNullException(nameof(passwordHasher));
        _sessionManager = sessionManager ?? throw new ArgumentNullException(nameof(sessionManager));
    }

    protected override AuthResult ValidateCredentials(AuthRequest request)
    {
        var user = _userRepository.GetByUsername(request.Username);
        if (user == null)
            return AuthResult.Failure("Invalid username or password");

        if (user.IsLocked)
            return AuthResult.Failure("Account is locked. Please contact administrator.");

        if (!_passwordHasher.VerifyPassword(request.Password, user.PasswordHash))
        {
            user.FailedLoginAttempts++;
            
            if (user.FailedLoginAttempts >= MaxLoginAttempts)
            {
                user.IsLocked = true;
                _userRepository.Update(user);
                return AuthResult.Failure("Account locked due to multiple failed login attempts");
            }
            
            _userRepository.Update(user);
            return AuthResult.Failure("Invalid username or password");
        }

        // Reset failed attempts on successful login
        user.FailedLoginAttempts = 0;
        user.LastLogin = DateTime.UtcNow;
        _userRepository.Update(user);

        return AuthResult.Success(user);
    }

    protected override AuthResult CreateUserSession(User user)
    {
        try
        {
            var sessionToken = _sessionManager.CreateSession(user.Id, SessionTimeout);
            var expiresAt = DateTime.UtcNow.Add(SessionTimeout);
            
            return AuthResult.Success(user, sessionToken, expiresAt);
        }
        catch (Exception ex)
        {
            return AuthResult.Failure($"Failed to create session: {ex.Message}");
        }
    }

    protected override AuthResult PerformSecurityChecks(AuthRequest request, User user)
    {
        // Check for suspicious IP addresses
        if (IsSuspiciousIP(request.IPAddress))
            return AuthResult.Failure("Login from suspicious location detected");

        // Check for too many recent login attempts
        if (HasTooManyRecentAttempts(user.Id, request.IPAddress))
            return AuthResult.Failure("Too many login attempts. Please try again later.");

        return AuthResult.Success(user);
    }

    protected override void OnAuthenticationSuccess(AuthRequest request, AuthResult result)
    {
        // Log successful authentication for audit trail
        _userRepository.LogAuthenticationEvent(result.User.Id, request.IPAddress, 
                                             "SUCCESS", request.UserAgent);
    }

    protected override void OnAuthenticationFailure(AuthRequest request, AuthResult result)
    {
        // Log failed authentication attempts
        _userRepository.LogAuthenticationEvent(null, request.IPAddress, 
                                             "FAILURE", request.UserAgent, string.Join("; ", result.Errors));
    }

    private bool IsSuspiciousIP(string ipAddress)
    {
        // Implement IP reputation checking logic
        var suspiciousRanges = new[] { "192.168.100.", "10.0.0." }; // Example
        return suspiciousRanges.Any(range => ipAddress?.StartsWith(range) == true);
    }

    private bool HasTooManyRecentAttempts(int? userId, string ipAddress)
    {
        // Check authentication logs for recent attempts from same IP
        var recentAttempts = _userRepository.GetRecentAuthenticationAttempts(ipAddress, TimeSpan.FromMinutes(15));
        return recentAttempts.Count(a => a.Result == "FAILURE") > 5;
    }
}
```

### Multi-Factor Authentication Extension (5 minutes)

#### Two-Factor Authentication Flow

```csharp
public class TwoFactorAuthenticationFlow : DatabaseAuthenticationFlow
{
    private readonly ITwoFactorService _twoFactorService;

    public TwoFactorAuthenticationFlow(IUserRepository userRepository, 
                                     IPasswordHasher passwordHasher,
                                     ISessionManager sessionManager,
                                     ITwoFactorService twoFactorService)
        : base(userRepository, passwordHasher, sessionManager)
    {
        _twoFactorService = twoFactorService ?? throw new ArgumentNullException(nameof(twoFactorService));
        FlowName = "Two-Factor Authentication";
    }

    protected override AuthResult PerformSecurityChecks(AuthRequest request, User user)
    {
        // First, perform base security checks
        var baseResult = base.PerformSecurityChecks(request, user);
        if (!baseResult.IsSuccessful)
            return baseResult;

        // If user has 2FA enabled, verify the code
        if (user.IsTwoFactorEnabled)
        {
            if (string.IsNullOrWhiteSpace(request.TwoFactorCode))
                return AuthResult.Failure("Two-factor authentication code is required");

            if (!_twoFactorService.VerifyCode(user.Id, request.TwoFactorCode))
                return AuthResult.Failure("Invalid two-factor authentication code");

            Console.WriteLine($"✅ Two-factor authentication verified for user: {user.Username}");
        }

        return AuthResult.Success(user);
    }

    protected override void OnAuthenticationSuccess(AuthRequest request, AuthResult result)
    {
        base.OnAuthenticationSuccess(request, result);
        
        // Add 2FA success to metadata
        if (result.User.IsTwoFactorEnabled)
        {
            result.Metadata["TwoFactorVerified"] = true;
            result.Metadata["AuthenticationMethod"] = "Username+Password+2FA";
        }
        else
        {
            result.Metadata["AuthenticationMethod"] = "Username+Password";
        }
    }
}

// Two-factor service interface
public interface ITwoFactorService
{
    bool VerifyCode(int userId, string code);
    string GenerateCode(int userId);
    void SendCode(int userId, string method = "sms");
}
```

### Key Takeaways & Authentication Patterns (2 minutes)

**Template Method in Authentication Benefits**:

- **Consistent Security Flow** - All authentication methods follow the same security steps
- **Pluggable Validation** - Different credential stores (DB, LDAP, API) with same structure
- **Extensible Security** - Easy to add 2FA, IP checking, rate limiting without changing core flow
- **Audit Trail Consistency** - Logging and monitoring implemented once, applied everywhere

**Security Hook Points Demonstrated**:

- **Pre-checks** - Username/password validation, request validation
- **Security checks** - IP verification, rate limiting, suspicious activity detection
- **Post-authentication** - Audit logging, session creation, notification sending
- **Error handling** - Consistent error responses, security event logging

**Enterprise Authentication Patterns**:

- **Database Authentication** - Standard username/password with hash verification
- **Multi-Factor Authentication** - Extended flow with additional verification steps
- **Session Management** - Token-based sessions with configurable timeouts
- **Audit Logging** - Complete authentication event tracking for compliance

**Next in Series**:

- **[Part C - Testing Framework Templates](13C_Design-Patterns-Part8C-Template-Method-Testing.md)**
- **[Part D - Advanced Templates & Best Practices](13D_Design-Patterns-Part8D-Template-Method-Advanced.md)**

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Template Method Fundamentals](13A_Design-Patterns-Part8A-Template-Method-Fundamentals.md)**
- Security principles and authentication concepts
- Password hashing and session management

**Builds Upon**:

- Abstract classes and inheritance patterns
- Security architecture principles
- Error handling and logging best practices

**Enables**:

- [Strategy Pattern](10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals.md) for authentication method selection
- [Chain of Responsibility](../behavioral-patterns/chain/) for security filter pipelines
- [Observer Pattern](../behavioral-patterns/observer/) for authentication event notifications

**Next Patterns**:

- [State Pattern](../behavioral-patterns/state/) for user session states
- [Decorator Pattern](11A_Design-Patterns-Part6A-Decorator-Pattern-Fundamentals.md) for authentication middleware
