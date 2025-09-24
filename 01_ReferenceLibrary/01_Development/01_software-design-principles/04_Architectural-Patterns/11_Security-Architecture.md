# 11_Security-Architecture

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: API Design Principles, Clean Architecture, Microservices Architecture  
**Estimated Time**: 90-120 minutes  

## 🎯 Learning Objectives

By the end of this content, you will:

- Design comprehensive security architectures for modern applications
- Implement authentication and authorization patterns effectively
- Apply security principles across all architectural layers
- Understand threat modeling and risk assessment methodologies
- Implement secure communication patterns and data protection
- Design security monitoring and incident response strategies
- Apply security best practices in cloud and distributed environments

## 📋 Table of Contents

1. [Security Architecture Fundamentals](#fundamentals)
2. [Authentication and Identity Management](#authentication)
3. [Authorization and Access Control](#authorization)
4. [Secure Communication Patterns](#communication)
5. [Data Protection and Encryption](#data-protection)
6. [Threat Modeling and Risk Assessment](#threat-modeling)
7. [Security Monitoring and Observability](#monitoring)
8. [Cloud Security Architecture](#cloud-security)
9. [Security in Distributed Systems](#distributed-security)

---

## 🏗️ Security Architecture Fundamentals {#fundamentals}

### Security by Design Principles

Security architecture must be built into the system from the ground up, not added as an afterthought. The principle of "Defense in Depth" ensures multiple layers of security controls.

```text
Security Architecture Layers
┌─────────────────────────────────────────┐
│           User Interface                │ ← Input validation, XSS protection
├─────────────────────────────────────────┤
│           API Gateway                   │ ← Rate limiting, authentication
├─────────────────────────────────────────┤
│         Application Layer               │ ← Authorization, business logic security
├─────────────────────────────────────────┤
│          Service Layer                  │ ← Service-to-service authentication
├─────────────────────────────────────────┤
│           Data Layer                    │ ← Encryption, access controls
├─────────────────────────────────────────┤
│        Infrastructure                   │ ← Network security, monitoring
└─────────────────────────────────────────┘
```

### Security Design Patterns

```csharp
// ✅ Security Context Pattern
public interface ISecurityContext
{
    string UserId { get; }
    string TenantId { get; }
    IEnumerable<string> Roles { get; }
    IEnumerable<string> Permissions { get; }
    bool IsAuthenticated { get; }
    bool HasPermission(string permission);
    bool HasRole(string role);
}

public class SecurityContext : ISecurityContext
{
    private readonly ClaimsPrincipal _principal;
    private readonly IPermissionService _permissionService;
    
    public SecurityContext(ClaimsPrincipal principal, IPermissionService permissionService)
    {
        _principal = principal;
        _permissionService = permissionService;
    }
    
    public string UserId => _principal.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? string.Empty;
    public string TenantId => _principal.FindFirst("tenant_id")?.Value ?? string.Empty;
    public bool IsAuthenticated => _principal.Identity?.IsAuthenticated ?? false;
    
    public IEnumerable<string> Roles => 
        _principal.FindAll(ClaimTypes.Role).Select(c => c.Value);
    
    public IEnumerable<string> Permissions => 
        _permissionService.GetUserPermissions(UserId);
    
    public bool HasPermission(string permission)
    {
        if (!IsAuthenticated) return false;
        return Permissions.Contains(permission);
    }
    
    public bool HasRole(string role)
    {
        if (!IsAuthenticated) return false;
        return Roles.Contains(role, StringComparer.OrdinalIgnoreCase);
    }
}

// ✅ Security Guard Pattern
public class SecurityGuard
{
    private readonly ISecurityContext _securityContext;
    private readonly ILogger<SecurityGuard> _logger;
    
    public SecurityGuard(ISecurityContext securityContext, ILogger<SecurityGuard> logger)
    {
        _securityContext = securityContext;
        _logger = logger;
    }
    
    public async Task<bool> CanAccessResourceAsync(string resourceId, string action)
    {
        if (!_securityContext.IsAuthenticated)
        {
            _logger.LogWarning("Unauthenticated access attempt to resource {ResourceId}", resourceId);
            return false;
        }
        
        var requiredPermission = $"{resourceId}:{action}";
        var hasPermission = _securityContext.HasPermission(requiredPermission);
        
        if (!hasPermission)
        {
            _logger.LogWarning("User {UserId} denied access to {ResourceId} for action {Action}", 
                _securityContext.UserId, resourceId, action);
        }
        
        return hasPermission;
    }
    
    public void EnsureAuthenticated()
    {
        if (!_securityContext.IsAuthenticated)
        {
            throw new UnauthorizedAccessException("Authentication required");
        }
    }
    
    public void EnsurePermission(string permission)
    {
        EnsureAuthenticated();
        
        if (!_securityContext.HasPermission(permission))
        {
            _logger.LogWarning("User {UserId} lacks permission {Permission}", 
                _securityContext.UserId, permission);
            throw new ForbiddenException($"Permission '{permission}' required");
        }
    }
    
    public void EnsureRole(string role)
    {
        EnsureAuthenticated();
        
        if (!_securityContext.HasRole(role))
        {
            _logger.LogWarning("User {UserId} lacks role {Role}", 
                _securityContext.UserId, role);
            throw new ForbiddenException($"Role '{role}' required");
        }
    }
}
```

### Secure Architecture Components

```csharp
// ✅ Secure Service Base Class
public abstract class SecureServiceBase
{
    protected readonly ISecurityContext SecurityContext;
    protected readonly SecurityGuard SecurityGuard;
    protected readonly ILogger Logger;
    
    protected SecureServiceBase(
        ISecurityContext securityContext,
        SecurityGuard securityGuard,
        ILogger logger)
    {
        SecurityContext = securityContext;
        SecurityGuard = securityGuard;
        Logger = logger;
    }
    
    protected async Task<T> ExecuteSecureOperationAsync<T>(
        string operation,
        string requiredPermission,
        Func<Task<T>> operationFunc)
    {
        try
        {
            SecurityGuard.EnsurePermission(requiredPermission);
            
            Logger.LogInformation("User {UserId} executing {Operation}", 
                SecurityContext.UserId, operation);
            
            var result = await operationFunc();
            
            Logger.LogInformation("User {UserId} completed {Operation} successfully", 
                SecurityContext.UserId, operation);
            
            return result;
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Security operation {Operation} failed for user {UserId}", 
                operation, SecurityContext.UserId);
            throw;
        }
    }
    
    protected void ValidateInput<T>(T input, string operationName) where T : class
    {
        if (input == null)
        {
            throw new ArgumentNullException(nameof(input), $"Input required for {operationName}");
        }
        
        // Additional validation logic can be added here
        // Consider using FluentValidation or similar frameworks
    }
    
    protected void AuditAction(string action, object? details = null)
    {
        Logger.LogInformation("AUDIT: User {UserId} performed {Action} at {Timestamp}. Details: {@Details}",
            SecurityContext.UserId,
            action,
            DateTime.UtcNow,
            details);
    }
}

// ✅ Example Secure Service Implementation
public class ProductService : SecureServiceBase, IProductService
{
    private readonly IProductRepository _repository;
    
    public ProductService(
        IProductRepository repository,
        ISecurityContext securityContext,
        SecurityGuard securityGuard,
        ILogger<ProductService> logger) 
        : base(securityContext, securityGuard, logger)
    {
        _repository = repository;
    }
    
    public async Task<ProductDto> CreateProductAsync(CreateProductRequest request)
    {
        return await ExecuteSecureOperationAsync(
            "CreateProduct",
            "products:create",
            async () =>
            {
                ValidateInput(request, nameof(CreateProductAsync));
                
                var product = await _repository.CreateAsync(request);
                
                AuditAction("ProductCreated", new { ProductId = product.Id, product.Name });
                
                return product;
            });
    }
    
    public async Task<ProductDto?> GetProductAsync(Guid productId)
    {
        return await ExecuteSecureOperationAsync(
            "GetProduct",
            "products:read",
            async () =>
            {
                var product = await _repository.GetByIdAsync(productId);
                
                if (product != null)
                {
                    AuditAction("ProductAccessed", new { ProductId = productId });
                }
                
                return product;
            });
    }
    
    public async Task<ProductDto> UpdateProductAsync(Guid productId, UpdateProductRequest request)
    {
        return await ExecuteSecureOperationAsync(
            "UpdateProduct",
            "products:update",
            async () =>
            {
                ValidateInput(request, nameof(UpdateProductAsync));
                
                var existingProduct = await _repository.GetByIdAsync(productId);
                if (existingProduct == null)
                {
                    throw new NotFoundException($"Product {productId} not found");
                }
                
                var updatedProduct = await _repository.UpdateAsync(productId, request);
                
                AuditAction("ProductUpdated", new { ProductId = productId, Changes = request });
                
                return updatedProduct;
            });
    }
}
```

---

## 🔐 Authentication and Identity Management {#authentication}

### Multi-Factor Authentication Implementation

```csharp
// ✅ MFA Service Implementation
public interface IMfaService
{
    Task<MfaSetupResult> SetupTotpAsync(string userId);
    Task<bool> VerifyTotpAsync(string userId, string code);
    Task<SmsResult> SendSmsCodeAsync(string userId, string phoneNumber);
    Task<bool> VerifySmsCodeAsync(string userId, string code);
    Task<IEnumerable<string>> GenerateBackupCodesAsync(string userId);
    Task<bool> VerifyBackupCodeAsync(string userId, string code);
}

public class MfaService : IMfaService
{
    private readonly IDistributedCache _cache;
    private readonly ISmsService _smsService;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<MfaService> _logger;
    private readonly MfaSettings _settings;
    
    public MfaService(
        IDistributedCache cache,
        ISmsService smsService,
        IUserRepository userRepository,
        ILogger<MfaService> logger,
        IOptions<MfaSettings> settings)
    {
        _cache = cache;
        _smsService = smsService;
        _userRepository = userRepository;
        _logger = logger;
        _settings = settings.Value;
    }
    
    public async Task<MfaSetupResult> SetupTotpAsync(string userId)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null)
        {
            throw new NotFoundException($"User {userId} not found");
        }
        
        var secretKey = GenerateSecretKey();
        var qrCodeUri = GenerateQrCodeUri(user.Email, secretKey);
        
        // Store temporary secret for verification
        var cacheKey = $"mfa_setup:{userId}";
        await _cache.SetStringAsync(cacheKey, secretKey, new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
        });
        
        _logger.LogInformation("TOTP setup initiated for user {UserId}", userId);
        
        return new MfaSetupResult
        {
            SecretKey = secretKey,
            QrCodeUri = qrCodeUri,
            BackupCodes = await GenerateBackupCodesAsync(userId)
        };
    }
    
    public async Task<bool> VerifyTotpAsync(string userId, string code)
    {
        try
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user?.TotpSecret == null)
            {
                return false;
            }
            
            var isValid = VerifyTotpCode(user.TotpSecret, code);
            
            if (isValid)
            {
                _logger.LogInformation("TOTP verification successful for user {UserId}", userId);
                
                // Update last used timestamp and prevent replay attacks
                await UpdateTotpLastUsedAsync(userId, code);
            }
            else
            {
                _logger.LogWarning("TOTP verification failed for user {UserId}", userId);
            }
            
            return isValid;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error verifying TOTP for user {UserId}", userId);
            return false;
        }
    }
    
    public async Task<SmsResult> SendSmsCodeAsync(string userId, string phoneNumber)
    {
        // Rate limiting check
        var rateLimitKey = $"sms_rate_limit:{userId}";
        var attempts = await GetSmsAttemptsAsync(rateLimitKey);
        
        if (attempts >= _settings.SmsRateLimit)
        {
            _logger.LogWarning("SMS rate limit exceeded for user {UserId}", userId);
            return new SmsResult { Success = false, Message = "Rate limit exceeded" };
        }
        
        var code = GenerateSmsCode();
        var cacheKey = $"sms_code:{userId}";
        
        await _cache.SetStringAsync(cacheKey, code, new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
        });
        
        await IncrementSmsAttemptsAsync(rateLimitKey);
        
        var smsResult = await _smsService.SendAsync(phoneNumber, $"Your verification code is: {code}");
        
        _logger.LogInformation("SMS code sent to user {UserId}", userId);
        
        return smsResult;
    }
    
    public async Task<bool> VerifySmsCodeAsync(string userId, string code)
    {
        var cacheKey = $"sms_code:{userId}";
        var storedCode = await _cache.GetStringAsync(cacheKey);
        
        if (storedCode == null || storedCode != code)
        {
            _logger.LogWarning("SMS verification failed for user {UserId}", userId);
            return false;
        }
        
        // Remove used code
        await _cache.RemoveAsync(cacheKey);
        
        _logger.LogInformation("SMS verification successful for user {UserId}", userId);
        return true;
    }
    
    public async Task<IEnumerable<string>> GenerateBackupCodesAsync(string userId)
    {
        var codes = new List<string>();
        
        for (int i = 0; i < 10; i++)
        {
            codes.Add(GenerateBackupCode());
        }
        
        // Hash and store backup codes
        var hashedCodes = codes.Select(HashBackupCode).ToList();
        await _userRepository.UpdateBackupCodesAsync(userId, hashedCodes);
        
        _logger.LogInformation("Backup codes generated for user {UserId}", userId);
        
        return codes;
    }
    
    public async Task<bool> VerifyBackupCodeAsync(string userId, string code)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user?.BackupCodes == null || !user.BackupCodes.Any())
        {
            return false;
        }
        
        var hashedCode = HashBackupCode(code);
        var isValid = user.BackupCodes.Contains(hashedCode);
        
        if (isValid)
        {
            // Remove used backup code
            await _userRepository.RemoveBackupCodeAsync(userId, hashedCode);
            _logger.LogInformation("Backup code used successfully for user {UserId}", userId);
        }
        else
        {
            _logger.LogWarning("Invalid backup code attempt for user {UserId}", userId);
        }
        
        return isValid;
    }
    
    private string GenerateSecretKey()
    {
        var bytes = new byte[20];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(bytes);
        return Convert.ToBase64String(bytes);
    }
    
    private string GenerateQrCodeUri(string email, string secretKey)
    {
        var issuer = _settings.Issuer;
        return $"otpauth://totp/{issuer}:{email}?secret={secretKey}&issuer={issuer}";
    }
    
    private bool VerifyTotpCode(string secretKey, string code)
    {
        // Implementation would use TOTP algorithm (RFC 6238)
        // This is a simplified version
        var totp = new Totp(Convert.FromBase64String(secretKey));
        return totp.VerifyTotp(code, out _, _settings.TotpValidityWindow);
    }
    
    private string GenerateSmsCode()
    {
        using var rng = RandomNumberGenerator.Create();
        var bytes = new byte[4];
        rng.GetBytes(bytes);
        var code = Math.Abs(BitConverter.ToInt32(bytes, 0)) % 1000000;
        return code.ToString("D6");
    }
    
    private string GenerateBackupCode()
    {
        using var rng = RandomNumberGenerator.Create();
        var bytes = new byte[8];
        rng.GetBytes(bytes);
        return Convert.ToHexString(bytes).ToLower();
    }
    
    private string HashBackupCode(string code)
    {
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(code + _settings.BackupCodeSalt);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }
}
```

### OAuth 2.0 and OpenID Connect Implementation

```csharp
// ✅ OAuth 2.0 Authorization Server
public class AuthorizationController : ControllerBase
{
    private readonly IAuthorizationService _authorizationService;
    private readonly ITokenService _tokenService;
    private readonly IClientService _clientService;
    private readonly IUserService _userService;
    
    [HttpPost("token")]
    public async Task<IActionResult> Token([FromForm] TokenRequest request)
    {
        try
        {
            var validationResult = await ValidateTokenRequestAsync(request);
            if (!validationResult.IsValid)
            {
                return BadRequest(new TokenError
                {
                    Error = "invalid_request",
                    ErrorDescription = validationResult.ErrorDescription
                });
            }
            
            var tokenResponse = request.GrantType switch
            {
                "authorization_code" => await ProcessAuthorizationCodeAsync(request),
                "client_credentials" => await ProcessClientCredentialsAsync(request),
                "refresh_token" => await ProcessRefreshTokenAsync(request),
                "password" => await ProcessPasswordGrantAsync(request),
                _ => throw new InvalidOperationException($"Unsupported grant type: {request.GrantType}")
            };
            
            return Ok(tokenResponse);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Token endpoint error");
            return BadRequest(new TokenError
            {
                Error = "server_error",
                ErrorDescription = "An error occurred processing the request"
            });
        }
    }
    
    private async Task<TokenResponse> ProcessAuthorizationCodeAsync(TokenRequest request)
    {
        var authCode = await _authorizationService.ValidateAuthorizationCodeAsync(
            request.Code, request.ClientId, request.RedirectUri);
        
        if (authCode == null)
        {
            throw new InvalidOperationException("Invalid authorization code");
        }
        
        var user = await _userService.GetByIdAsync(authCode.UserId);
        var client = await _clientService.GetByClientIdAsync(request.ClientId);
        
        var claims = await _userService.GetUserClaimsAsync(user.Id);
        
        var accessToken = _tokenService.GenerateAccessToken(claims, client.Id);
        var refreshToken = _tokenService.GenerateRefreshToken();
        var idToken = _tokenService.GenerateIdToken(claims, client.Id, authCode.Nonce);
        
        // Store refresh token
        await _tokenService.StoreRefreshTokenAsync(refreshToken, user.Id, client.Id);
        
        // Invalidate authorization code
        await _authorizationService.InvalidateAuthorizationCodeAsync(request.Code);
        
        return new TokenResponse
        {
            AccessToken = accessToken,
            TokenType = "Bearer",
            ExpiresIn = 3600,
            RefreshToken = refreshToken,
            IdToken = idToken,
            Scope = string.Join(" ", authCode.Scopes)
        };
    }
    
    private async Task<TokenResponse> ProcessClientCredentialsAsync(TokenRequest request)
    {
        var client = await _clientService.ValidateClientAsync(request.ClientId, request.ClientSecret);
        if (client == null)
        {
            throw new UnauthorizedAccessException("Invalid client credentials");
        }
        
        var scopes = ParseScopes(request.Scope);
        var authorizedScopes = client.AllowedScopes.Intersect(scopes);
        
        var claims = new Dictionary<string, object>
        {
            ["client_id"] = client.Id,
            ["scope"] = string.Join(" ", authorizedScopes)
        };
        
        var accessToken = _tokenService.GenerateAccessToken(claims, client.Id);
        
        return new TokenResponse
        {
            AccessToken = accessToken,
            TokenType = "Bearer",
            ExpiresIn = 3600,
            Scope = string.Join(" ", authorizedScopes)
        };
    }
    
    [HttpGet("authorize")]
    public async Task<IActionResult> Authorize([FromQuery] AuthorizationRequest request)
    {
        var validationResult = await ValidateAuthorizationRequestAsync(request);
        if (!validationResult.IsValid)
        {
            return BadRequest(validationResult.ErrorDescription);
        }
        
        // Check if user is authenticated
        if (!User.Identity.IsAuthenticated)
        {
            var returnUrl = Request.GetEncodedUrl();
            return Challenge(new AuthenticationProperties
            {
                RedirectUri = returnUrl
            });
        }
        
        var client = await _clientService.GetByClientIdAsync(request.ClientId);
        var user = await _userService.GetByIdAsync(User.GetUserId());
        
        // Check if user has already consented
        var consent = await _authorizationService.GetConsentAsync(user.Id, client.Id);
        var requestedScopes = ParseScopes(request.Scope);
        
        if (consent == null || !requestedScopes.All(s => consent.Scopes.Contains(s)))
        {
            // Show consent screen
            var consentModel = new ConsentViewModel
            {
                ClientName = client.Name,
                Scopes = requestedScopes,
                ReturnUrl = Request.GetEncodedUrl()
            };
            
            return View("Consent", consentModel);
        }
        
        // Generate authorization code
        var authCode = await _authorizationService.GenerateAuthorizationCodeAsync(
            user.Id, client.Id, requestedScopes, request.RedirectUri, request.Nonce);
        
        var redirectUri = $"{request.RedirectUri}?code={authCode}&state={request.State}";
        return Redirect(redirectUri);
    }
}

// ✅ JWT Token Service with Enhanced Security
public class EnhancedJwtTokenService : ITokenService
{
    private readonly JwtSettings _jwtSettings;
    private readonly IKeyManagementService _keyService;
    private readonly IDistributedCache _cache;
    private readonly ILogger<EnhancedJwtTokenService> _logger;
    
    public string GenerateAccessToken(Dictionary<string, object> claims, string clientId)
    {
        var tokenClaims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new(JwtRegisteredClaimNames.Iat, DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString()),
            new("client_id", clientId)
        };
        
        foreach (var claim in claims)
        {
            tokenClaims.Add(new Claim(claim.Key, claim.Value.ToString()));
        }
        
        var key = _keyService.GetCurrentSigningKey();
        var credentials = new SigningCredentials(key, SecurityAlgorithms.RsaSha256);
        
        var token = new JwtSecurityToken(
            issuer: _jwtSettings.Issuer,
            audience: _jwtSettings.Audience,
            claims: tokenClaims,
            expires: DateTime.UtcNow.AddMinutes(_jwtSettings.AccessTokenExpiryMinutes),
            signingCredentials: credentials);
        
        var tokenString = new JwtSecurityTokenHandler().WriteToken(token);
        
        // Store token hash for revocation checking
        var tokenHash = ComputeTokenHash(tokenString);
        _ = Task.Run(() => StoreTokenHashAsync(tokenHash, token.ValidTo));
        
        return tokenString;
    }
    
    public async Task<bool> IsTokenRevokedAsync(string token)
    {
        var tokenHash = ComputeTokenHash(token);
        var cacheKey = $"revoked_token:{tokenHash}";
        
        var isRevoked = await _cache.GetStringAsync(cacheKey);
        return !string.IsNullOrEmpty(isRevoked);
    }
    
    public async Task RevokeTokenAsync(string token)
    {
        var tokenHash = ComputeTokenHash(token);
        var handler = new JwtSecurityTokenHandler();
        
        if (handler.ReadJwtToken(token) is JwtSecurityToken jwt)
        {
            var cacheKey = $"revoked_token:{tokenHash}";
            var expiryTime = jwt.ValidTo.Subtract(DateTime.UtcNow);
            
            if (expiryTime > TimeSpan.Zero)
            {
                await _cache.SetStringAsync(cacheKey, "revoked", new DistributedCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = expiryTime
                });
            }
        }
        
        _logger.LogInformation("Token revoked: {TokenHash}", tokenHash);
    }
    
    private string ComputeTokenHash(string token)
    {
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(token);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }
}
```

---

## 🛡️ Authorization and Access Control {#authorization}

### Role-Based Access Control (RBAC)

```csharp
// ✅ RBAC Implementation
public interface IRoleService
{
    Task<IEnumerable<Role>> GetRolesAsync();
    Task<Role?> GetRoleByIdAsync(string roleId);
    Task<Role> CreateRoleAsync(CreateRoleRequest request);
    Task<Role> UpdateRoleAsync(string roleId, UpdateRoleRequest request);
    Task DeleteRoleAsync(string roleId);
    Task<IEnumerable<Permission>> GetRolePermissionsAsync(string roleId);
    Task AssignPermissionToRoleAsync(string roleId, string permissionId);
    Task RemovePermissionFromRoleAsync(string roleId, string permissionId);
}

public class RoleService : IRoleService
{
    private readonly IRoleRepository _roleRepository;
    private readonly IPermissionRepository _permissionRepository;
    private readonly IDistributedCache _cache;
    private readonly ILogger<RoleService> _logger;
    
    public async Task<Role> CreateRoleAsync(CreateRoleRequest request)
    {
        var existingRole = await _roleRepository.GetByNameAsync(request.Name);
        if (existingRole != null)
        {
            throw new ConflictException($"Role '{request.Name}' already exists");
        }
        
        var role = new Role
        {
            Id = Guid.NewGuid().ToString(),
            Name = request.Name,
            Description = request.Description,
            CreatedAt = DateTime.UtcNow,
            IsActive = true
        };
        
        await _roleRepository.CreateAsync(role);
        
        // Invalidate cache
        await InvalidateRoleCacheAsync();
        
        _logger.LogInformation("Role created: {RoleName} ({RoleId})", role.Name, role.Id);
        
        return role;
    }
    
    public async Task<IEnumerable<Permission>> GetRolePermissionsAsync(string roleId)
    {
        var cacheKey = $"role_permissions:{roleId}";
        var cachedPermissions = await _cache.GetStringAsync(cacheKey);
        
        if (cachedPermissions != null)
        {
            return JsonSerializer.Deserialize<IEnumerable<Permission>>(cachedPermissions);
        }
        
        var permissions = await _roleRepository.GetRolePermissionsAsync(roleId);
        
        // Cache for 15 minutes
        await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(permissions),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(15)
            });
        
        return permissions;
    }
    
    public async Task AssignPermissionToRoleAsync(string roleId, string permissionId)
    {
        var role = await _roleRepository.GetByIdAsync(roleId);
        if (role == null)
        {
            throw new NotFoundException($"Role {roleId} not found");
        }
        
        var permission = await _permissionRepository.GetByIdAsync(permissionId);
        if (permission == null)
        {
            throw new NotFoundException($"Permission {permissionId} not found");
        }
        
        await _roleRepository.AssignPermissionAsync(roleId, permissionId);
        
        // Invalidate cache
        await _cache.RemoveAsync($"role_permissions:{roleId}");
        await InvalidateUserPermissionCaches(roleId);
        
        _logger.LogInformation("Permission {PermissionName} assigned to role {RoleName}",
            permission.Name, role.Name);
    }
    
    private async Task InvalidateUserPermissionCaches(string roleId)
    {
        // This would typically involve getting all users with this role
        // and invalidating their permission caches
        var usersWithRole = await _roleRepository.GetUsersWithRoleAsync(roleId);
        
        foreach (var userId in usersWithRole)
        {
            await _cache.RemoveAsync($"user_permissions:{userId}");
        }
    }
}

// ✅ Attribute-Based Access Control (ABAC)
public interface IAbacService
{
    Task<bool> EvaluateAccessAsync(AccessRequest request);
    Task<PolicyResult> EvaluatePolicyAsync(string policyId, AccessContext context);
}

public class AbacService : IAbacService
{
    private readonly IPolicyRepository _policyRepository;
    private readonly IAttributeProvider _attributeProvider;
    private readonly ILogger<AbacService> _logger;
    
    public async Task<bool> EvaluateAccessAsync(AccessRequest request)
    {
        var context = await BuildAccessContextAsync(request);
        var policies = await _policyRepository.GetApplicablePoliciesAsync(
            request.Resource, request.Action);
        
        foreach (var policy in policies)
        {
            var result = await EvaluatePolicyAsync(policy.Id, context);
            
            if (result.Effect == PolicyEffect.Deny)
            {
                _logger.LogWarning("Access denied by policy {PolicyId} for user {UserId}",
                    policy.Id, request.UserId);
                return false;
            }
            
            if (result.Effect == PolicyEffect.Allow && result.Satisfied)
            {
                _logger.LogInformation("Access granted by policy {PolicyId} for user {UserId}",
                    policy.Id, request.UserId);
                return true;
            }
        }
        
        // Default deny
        _logger.LogWarning("No explicit allow policy found for user {UserId} on resource {Resource}",
            request.UserId, request.Resource);
        return false;
    }
    
    public async Task<PolicyResult> EvaluatePolicyAsync(string policyId, AccessContext context)
    {
        var policy = await _policyRepository.GetByIdAsync(policyId);
        if (policy == null)
        {
            return new PolicyResult { Effect = PolicyEffect.NotApplicable };
        }
        
        try
        {
            var satisfied = await EvaluateConditionsAsync(policy.Conditions, context);
            
            return new PolicyResult
            {
                PolicyId = policyId,
                Effect = policy.Effect,
                Satisfied = satisfied,
                EvaluatedAt = DateTime.UtcNow
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error evaluating policy {PolicyId}", policyId);
            return new PolicyResult { Effect = PolicyEffect.Error };
        }
    }
    
    private async Task<AccessContext> BuildAccessContextAsync(AccessRequest request)
    {
        var userAttributes = await _attributeProvider.GetUserAttributesAsync(request.UserId);
        var resourceAttributes = await _attributeProvider.GetResourceAttributesAsync(request.Resource);
        var environmentAttributes = await _attributeProvider.GetEnvironmentAttributesAsync();
        
        return new AccessContext
        {
            User = userAttributes,
            Resource = resourceAttributes,
            Environment = environmentAttributes,
            Action = request.Action,
            Timestamp = DateTime.UtcNow
        };
    }
    
    private async Task<bool> EvaluateConditionsAsync(IEnumerable<PolicyCondition> conditions, AccessContext context)
    {
        foreach (var condition in conditions)
        {
            var result = condition.Operator switch
            {
                "equals" => EvaluateEquals(condition, context),
                "contains" => EvaluateContains(condition, context),
                "greater_than" => EvaluateGreaterThan(condition, context),
                "less_than" => EvaluateLessThan(condition, context),
                "in" => EvaluateIn(condition, context),
                "time_between" => await EvaluateTimeBetweenAsync(condition, context),
                "ip_in_range" => EvaluateIpInRange(condition, context),
                _ => false
            };
            
            if (!result)
            {
                return false; // All conditions must be satisfied
            }
        }
        
        return true;
    }
    
    private bool EvaluateEquals(PolicyCondition condition, AccessContext context)
    {
        var attributeValue = GetAttributeValue(condition.AttributePath, context);
        return attributeValue?.ToString() == condition.Value;
    }
    
    private bool EvaluateIpInRange(PolicyCondition condition, AccessContext context)
    {
        var clientIp = context.Environment.GetValueOrDefault("client_ip")?.ToString();
        if (string.IsNullOrEmpty(clientIp) || !IPAddress.TryParse(clientIp, out var ip))
        {
            return false;
        }
        
        // Parse CIDR range
        var cidrParts = condition.Value.Split('/');
        if (cidrParts.Length != 2 ||
            !IPAddress.TryParse(cidrParts[0], out var networkAddress) ||
            !int.TryParse(cidrParts[1], out var prefixLength))
        {
            return false;
        }
        
        return IsIpInRange(ip, networkAddress, prefixLength);
    }
    
    private object? GetAttributeValue(string attributePath, AccessContext context)
    {
        var parts = attributePath.Split('.');
        var category = parts[0];
        var attribute = parts[1];
        
        return category switch
        {
            "user" => context.User.GetValueOrDefault(attribute),
            "resource" => context.Resource.GetValueOrDefault(attribute),
            "environment" => context.Environment.GetValueOrDefault(attribute),
            "action" => context.Action,
            _ => null
        };
    }
}
```

### Dynamic Permission System

```csharp
// ✅ Dynamic Permission Evaluation
public class DynamicPermissionService : IPermissionService
{
    private readonly IUserRepository _userRepository;
    private readonly IRoleRepository _roleRepository;
    private readonly IResourceRepository _resourceRepository;
    private readonly IDistributedCache _cache;
    private readonly ILogger<DynamicPermissionService> _logger;
    
    public async Task<bool> HasPermissionAsync(string userId, string resource, string action, object? context = null)
    {
        var cacheKey = $"permission:{userId}:{resource}:{action}:{ComputeContextHash(context)}";
        var cachedResult = await _cache.GetStringAsync(cacheKey);
        
        if (cachedResult != null)
        {
            return bool.Parse(cachedResult);
        }
        
        var hasPermission = await EvaluatePermissionAsync(userId, resource, action, context);
        
        // Cache result for 5 minutes
        await _cache.SetStringAsync(cacheKey, hasPermission.ToString(),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
            });
        
        return hasPermission;
    }
    
    private async Task<bool> EvaluatePermissionAsync(string userId, string resource, string action, object? context)
    {
        // 1. Check direct permissions
        var directPermissions = await GetUserDirectPermissionsAsync(userId);
        if (directPermissions.Any(p => MatchesPermission(p, resource, action)))
        {
            _logger.LogDebug("Direct permission granted for user {UserId}", userId);
            return true;
        }
        
        // 2. Check role-based permissions
        var userRoles = await GetUserRolesAsync(userId);
        foreach (var role in userRoles)
        {
            var rolePermissions = await GetRolePermissionsAsync(role.Id);
            if (rolePermissions.Any(p => MatchesPermission(p, resource, action)))
            {
                _logger.LogDebug("Role-based permission granted for user {UserId} via role {RoleName}",
                    userId, role.Name);
                return true;
            }
        }
        
        // 3. Check ownership-based permissions
        if (await CheckOwnershipPermissionAsync(userId, resource, action, context))
        {
            _logger.LogDebug("Ownership-based permission granted for user {UserId}", userId);
            return true;
        }
        
        // 4. Check hierarchical permissions
        if (await CheckHierarchicalPermissionAsync(userId, resource, action, context))
        {
            _logger.LogDebug("Hierarchical permission granted for user {UserId}", userId);
            return true;
        }
        
        // 5. Check conditional permissions
        if (await CheckConditionalPermissionAsync(userId, resource, action, context))
        {
            _logger.LogDebug("Conditional permission granted for user {UserId}", userId);
            return true;
        }
        
        _logger.LogDebug("Permission denied for user {UserId} on resource {Resource} action {Action}",
            userId, resource, action);
        return false;
    }
    
    private async Task<bool> CheckOwnershipPermissionAsync(string userId, string resource, string action, object? context)
    {
        // Extract resource ID from resource string (e.g., "document:123" -> "123")
        var resourceParts = resource.Split(':');
        if (resourceParts.Length != 2)
        {
            return false;
        }
        
        var resourceType = resourceParts[0];
        var resourceId = resourceParts[1];
        
        // Check if user owns the resource
        var resourceEntity = await _resourceRepository.GetByIdAsync(resourceType, resourceId);
        if (resourceEntity?.OwnerId == userId)
        {
            // Check if the action is allowed for owners
            var ownerPermissions = await GetOwnerPermissionsAsync(resourceType);
            return ownerPermissions.Contains(action);
        }
        
        return false;
    }
    
    private async Task<bool> CheckHierarchicalPermissionAsync(string userId, string resource, string action, object? context)
    {
        // Get user's organizational hierarchy
        var userHierarchy = await GetUserHierarchyAsync(userId);
        
        // Extract resource owner
        var resourceParts = resource.Split(':');
        if (resourceParts.Length != 2)
        {
            return false;
        }
        
        var resourceEntity = await _resourceRepository.GetByIdAsync(resourceParts[0], resourceParts[1]);
        if (resourceEntity?.OwnerId == null)
        {
            return false;
        }
        
        // Check if user is superior to resource owner in hierarchy
        var resourceOwnerHierarchy = await GetUserHierarchyAsync(resourceEntity.OwnerId);
        
        if (IsUserSuperior(userHierarchy, resourceOwnerHierarchy))
        {
            var hierarchicalPermissions = await GetHierarchicalPermissionsAsync(action);
            return hierarchicalPermissions.Any();
        }
        
        return false;
    }
    
    private async Task<bool> CheckConditionalPermissionAsync(string userId, string resource, string action, object? context)
    {
        var conditionalPermissions = await GetConditionalPermissionsAsync(userId, resource, action);
        
        foreach (var permission in conditionalPermissions)
        {
            if (await EvaluatePermissionConditionsAsync(permission, userId, resource, action, context))
            {
                return true;
            }
        }
        
        return false;
    }
    
    private async Task<bool> EvaluatePermissionConditionsAsync(
        ConditionalPermission permission, 
        string userId, 
        string resource, 
        string action, 
        object? context)
    {
        foreach (var condition in permission.Conditions)
        {
            var result = condition.Type switch
            {
                "time_range" => EvaluateTimeRangeCondition(condition),
                "location" => await EvaluateLocationConditionAsync(condition, context),
                "resource_state" => await EvaluateResourceStateConditionAsync(condition, resource),
                "user_attribute" => await EvaluateUserAttributeConditionAsync(condition, userId),
                "custom" => await EvaluateCustomConditionAsync(condition, userId, resource, action, context),
                _ => false
            };
            
            if (!result)
            {
                return false; // All conditions must be satisfied
            }
        }
        
        return true;
    }
    
    private bool EvaluateTimeRangeCondition(PermissionCondition condition)
    {
        if (!TimeSpan.TryParse(condition.StartTime, out var startTime) ||
            !TimeSpan.TryParse(condition.EndTime, out var endTime))
        {
            return false;
        }
        
        var currentTime = DateTime.Now.TimeOfDay;
        
        if (startTime <= endTime)
        {
            return currentTime >= startTime && currentTime <= endTime;
        }
        else
        {
            // Overnight range (e.g., 22:00 to 06:00)
            return currentTime >= startTime || currentTime <= endTime;
        }
    }
    
    private string ComputeContextHash(object? context)
    {
        if (context == null)
        {
            return "null";
        }
        
        var json = JsonSerializer.Serialize(context);
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(json);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }
}
```

---

## 🔐 Secure Communication Patterns {#communication}

### TLS/SSL Implementation

```csharp
// ✅ TLS Configuration for ASP.NET Core
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddHttpsRedirection(options =>
        {
            options.RedirectStatusCode = StatusCodes.Status308PermanentRedirect;
            options.HttpsPort = 443;
        });
        
        services.AddHsts(options =>
        {
            options.Preload = true;
            options.IncludeSubdomains = true;
            options.MaxAge = TimeSpan.FromDays(365);
        });
        
        // Configure Kestrel for HTTPS
        services.Configure<KestrelServerOptions>(options =>
        {
            options.ConfigureHttpsDefaults(httpsOptions =>
            {
                httpsOptions.SslProtocols = SslProtocols.Tls12 | SslProtocols.Tls13;
                httpsOptions.ClientCertificateMode = ClientCertificateMode.AllowCertificate;
                httpsOptions.CheckCertificateRevocation = true;
            });
        });
    }
    
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (!env.IsDevelopment())
        {
            app.UseHsts();
        }
        
        app.UseHttpsRedirection();
        
        // Security headers
        app.Use(async (context, next) =>
        {
            context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
            context.Response.Headers.Add("X-Frame-Options", "DENY");
            context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
            context.Response.Headers.Add("Referrer-Policy", "strict-origin-when-cross-origin");
            context.Response.Headers.Add("Content-Security-Policy", 
                "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'");
            
            await next();
        });
    }
}
```

### Message Encryption and Signing

```csharp
// ✅ Message Encryption Service
public interface IMessageEncryptionService
{
    Task<EncryptedMessage> EncryptAsync(string message, string recipientPublicKey);
    Task<string> DecryptAsync(EncryptedMessage encryptedMessage, string privateKey);
    Task<SignedMessage> SignAsync(string message, string privateKey);
    Task<bool> VerifySignatureAsync(SignedMessage signedMessage, string publicKey);
}

public class MessageEncryptionService : IMessageEncryptionService
{
    private readonly ILogger<MessageEncryptionService> _logger;
    
    public async Task<EncryptedMessage> EncryptAsync(string message, string recipientPublicKey)
    {
        using var rsa = RSA.Create();
        rsa.ImportFromPem(recipientPublicKey);
        
        var messageBytes = Encoding.UTF8.GetBytes(message);
        
        // For large messages, use hybrid encryption
        if (messageBytes.Length > 190) // RSA key size limitation
        {
            return await HybridEncryptAsync(messageBytes, rsa);
        }
        
        var encryptedBytes = rsa.Encrypt(messageBytes, RSAEncryptionPadding.OaepSHA256);
        
        return new EncryptedMessage
        {
            Data = Convert.ToBase64String(encryptedBytes),
            Algorithm = "RSA-OAEP-SHA256",
            Timestamp = DateTime.UtcNow
        };
    }
    
    private async Task<EncryptedMessage> HybridEncryptAsync(byte[] messageBytes, RSA recipientRsa)
    {
        // Generate symmetric key for AES encryption
        using var aes = Aes.Create();
        aes.GenerateKey();
        aes.GenerateIV();
        
        // Encrypt message with AES
        byte[] encryptedMessage;
        using (var encryptor = aes.CreateEncryptor())
        using (var msEncrypt = new MemoryStream())
        using (var csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write))
        {
            await csEncrypt.WriteAsync(messageBytes);
            csEncrypt.FlushFinalBlock();
            encryptedMessage = msEncrypt.ToArray();
        }
        
        // Encrypt AES key with RSA
        var keyAndIv = aes.Key.Concat(aes.IV).ToArray();
        var encryptedKey = recipientRsa.Encrypt(keyAndIv, RSAEncryptionPadding.OaepSHA256);
        
        return new EncryptedMessage
        {
            Data = Convert.ToBase64String(encryptedMessage),
            EncryptedKey = Convert.ToBase64String(encryptedKey),
            Algorithm = "AES-256-CBC+RSA-OAEP-SHA256",
            Timestamp = DateTime.UtcNow
        };
    }
    
    public async Task<SignedMessage> SignAsync(string message, string privateKey)
    {
        using var rsa = RSA.Create();
        rsa.ImportFromPem(privateKey);
        
        var messageBytes = Encoding.UTF8.GetBytes(message);
        var signature = rsa.SignData(messageBytes, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        
        return new SignedMessage
        {
            Message = message,
            Signature = Convert.ToBase64String(signature),
            Algorithm = "RSA-SHA256",
            Timestamp = DateTime.UtcNow
        };
    }
    
    public async Task<bool> VerifySignatureAsync(SignedMessage signedMessage, string publicKey)
    {
        try
        {
            using var rsa = RSA.Create();
            rsa.ImportFromPem(publicKey);
            
            var messageBytes = Encoding.UTF8.GetBytes(signedMessage.Message);
            var signatureBytes = Convert.FromBase64String(signedMessage.Signature);
            
            return rsa.VerifyData(messageBytes, signatureBytes, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error verifying signature");
            return false;
        }
    }
}
```

---

## 🛡️ Data Protection and Encryption {#data-protection}

### Data Encryption at Rest

```csharp
// ✅ Database Encryption Configuration
public class EncryptedDbContext : DbContext
{
    private readonly IDataEncryptionService _encryptionService;
    
    public EncryptedDbContext(DbContextOptions<EncryptedDbContext> options, 
        IDataEncryptionService encryptionService) : base(options)
    {
        _encryptionService = encryptionService;
    }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configure encrypted properties
        modelBuilder.Entity<User>(entity =>
        {
            entity.Property(e => e.Email)
                .HasConversion(
                    v => _encryptionService.Encrypt(v),
                    v => _encryptionService.Decrypt(v));
            
            entity.Property(e => e.PhoneNumber)
                .HasConversion(
                    v => string.IsNullOrEmpty(v) ? v : _encryptionService.Encrypt(v),
                    v => string.IsNullOrEmpty(v) ? v : _encryptionService.Decrypt(v));
        });
        
        modelBuilder.Entity<CreditCard>(entity =>
        {
            entity.Property(e => e.Number)
                .HasConversion(
                    v => _encryptionService.EncryptSensitive(v),
                    v => _encryptionService.DecryptSensitive(v));
        });
    }
    
    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // Audit trail for sensitive data changes
        var entries = ChangeTracker.Entries()
            .Where(e => e.Entity is IAuditable && 
                       (e.State == EntityState.Added || e.State == EntityState.Modified));
        
        foreach (var entry in entries)
        {
            var auditable = (IAuditable)entry.Entity;
            
            if (entry.State == EntityState.Added)
            {
                auditable.CreatedAt = DateTime.UtcNow;
                auditable.CreatedBy = GetCurrentUserId();
            }
            
            auditable.UpdatedAt = DateTime.UtcNow;
            auditable.UpdatedBy = GetCurrentUserId();
        }
        
        return await base.SaveChangesAsync(cancellationToken);
    }
}

// ✅ Field-Level Encryption Service
public interface IDataEncryptionService
{
    string Encrypt(string plaintext);
    string Decrypt(string ciphertext);
    string EncryptSensitive(string plaintext);
    string DecryptSensitive(string ciphertext);
    string Hash(string input);
    bool VerifyHash(string input, string hash);
}

public class AesDataEncryptionService : IDataEncryptionService
{
    private readonly byte[] _encryptionKey;
    private readonly byte[] _sensitiveKey;
    private readonly ILogger<AesDataEncryptionService> _logger;
    
    public AesDataEncryptionService(IConfiguration configuration, ILogger<AesDataEncryptionService> logger)
    {
        _encryptionKey = Convert.FromBase64String(configuration["Encryption:DefaultKey"]);
        _sensitiveKey = Convert.FromBase64String(configuration["Encryption:SensitiveKey"]);
        _logger = logger;
    }
    
    public string Encrypt(string plaintext)
    {
        if (string.IsNullOrEmpty(plaintext))
            return plaintext;
        
        return EncryptWithKey(plaintext, _encryptionKey);
    }
    
    public string EncryptSensitive(string plaintext)
    {
        if (string.IsNullOrEmpty(plaintext))
            return plaintext;
        
        return EncryptWithKey(plaintext, _sensitiveKey);
    }
    
    private string EncryptWithKey(string plaintext, byte[] key)
    {
        using var aes = Aes.Create();
        aes.Key = key;
        aes.GenerateIV();
        
        var plaintextBytes = Encoding.UTF8.GetBytes(plaintext);
        
        using var encryptor = aes.CreateEncryptor();
        using var msEncrypt = new MemoryStream();
        using var csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write);
        
        csEncrypt.Write(plaintextBytes);
        csEncrypt.FlushFinalBlock();
        
        var encryptedBytes = msEncrypt.ToArray();
        var result = new byte[aes.IV.Length + encryptedBytes.Length];
        
        Array.Copy(aes.IV, 0, result, 0, aes.IV.Length);
        Array.Copy(encryptedBytes, 0, result, aes.IV.Length, encryptedBytes.Length);
        
        return Convert.ToBase64String(result);
    }
    
    public string Hash(string input)
    {
        if (string.IsNullOrEmpty(input))
            return input;
        
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(input);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }
    
    public bool VerifyHash(string input, string hash)
    {
        var inputHash = Hash(input);
        return string.Equals(inputHash, hash, StringComparison.Ordinal);
    }
}
```

---

## 🎯 Threat Modeling and Risk Assessment {#threat-modeling}

### STRIDE Threat Analysis

```csharp
// ✅ Threat Modeling Framework
public enum ThreatCategory
{
    Spoofing,
    Tampering,
    Repudiation,
    InformationDisclosure,
    DenialOfService,
    ElevationOfPrivilege
}

public class ThreatModel
{
    public string SystemName { get; set; }
    public string Version { get; set; }
    public DateTime CreatedDate { get; set; }
    public List<Component> Components { get; set; } = new();
    public List<DataFlow> DataFlows { get; set; } = new();
    public List<ThreatScenario> Threats { get; set; } = new();
    public List<Mitigation> Mitigations { get; set; } = new();
}

public class ThreatScenario
{
    public string Id { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public ThreatCategory Category { get; set; }
    public RiskLevel RiskLevel { get; set; }
    public string AffectedComponent { get; set; }
    public List<string> AttackVectors { get; set; } = new();
    public List<string> Mitigations { get; set; } = new();
    public ThreatStatus Status { get; set; }
}

public interface IThreatModelingService
{
    Task<ThreatModel> AnalyzeSystemAsync(SystemArchitecture architecture);
    Task<IEnumerable<ThreatScenario>> GenerateThreatsAsync(Component component);
    Task<RiskAssessment> AssessRiskAsync(ThreatScenario threat);
    Task<IEnumerable<Mitigation>> RecommendMitigationsAsync(ThreatScenario threat);
}

public class StrideBasedThreatModelingService : IThreatModelingService
{
    private readonly IThreatDatabase _threatDatabase;
    private readonly IRiskCalculator _riskCalculator;
    private readonly ILogger<StrideBasedThreatModelingService> _logger;
    
    public async Task<ThreatModel> AnalyzeSystemAsync(SystemArchitecture architecture)
    {
        var threatModel = new ThreatModel
        {
            SystemName = architecture.Name,
            Version = architecture.Version,
            CreatedDate = DateTime.UtcNow,
            Components = architecture.Components,
            DataFlows = architecture.DataFlows
        };
        
        // Generate threats for each component
        foreach (var component in architecture.Components)
        {
            var componentThreats = await GenerateThreatsAsync(component);
            threatModel.Threats.AddRange(componentThreats);
        }
        
        // Analyze data flows for additional threats
        foreach (var dataFlow in architecture.DataFlows)
        {
            var dataFlowThreats = await AnalyzeDataFlowThreatsAsync(dataFlow);
            threatModel.Threats.AddRange(dataFlowThreats);
        }
        
        // Generate mitigations
        foreach (var threat in threatModel.Threats)
        {
            var mitigations = await RecommendMitigationsAsync(threat);
            threatModel.Mitigations.AddRange(mitigations);
        }
        
        return threatModel;
    }
    
    public async Task<IEnumerable<ThreatScenario>> GenerateThreatsAsync(Component component)
    {
        var threats = new List<ThreatScenario>();
        
        // STRIDE analysis per component type
        switch (component.Type)
        {
            case ComponentType.WebApplication:
                threats.AddRange(await GenerateWebApplicationThreatsAsync(component));
                break;
            case ComponentType.Database:
                threats.AddRange(await GenerateDatabaseThreatsAsync(component));
                break;
            case ComponentType.ApiService:
                threats.AddRange(await GenerateApiServiceThreatsAsync(component));
                break;
            case ComponentType.ExternalService:
                threats.AddRange(await GenerateExternalServiceThreatsAsync(component));
                break;
        }
        
        return threats;
    }
    
    private async Task<IEnumerable<ThreatScenario>> GenerateWebApplicationThreatsAsync(Component component)
    {
        return new[]
        {
            new ThreatScenario
            {
                Id = Guid.NewGuid().ToString(),
                Title = "Cross-Site Scripting (XSS)",
                Description = "Malicious scripts injected into web pages viewed by users",
                Category = ThreatCategory.Tampering,
                AffectedComponent = component.Name,
                AttackVectors = new List<string> { "Reflected XSS", "Stored XSS", "DOM-based XSS" },
                RiskLevel = await _riskCalculator.CalculateRiskAsync("XSS", component)
            },
            new ThreatScenario
            {
                Id = Guid.NewGuid().ToString(),
                Title = "SQL Injection",
                Description = "Malicious SQL code injection through user inputs",
                Category = ThreatCategory.Tampering,
                AffectedComponent = component.Name,
                AttackVectors = new List<string> { "Form inputs", "URL parameters", "HTTP headers" },
                RiskLevel = await _riskCalculator.CalculateRiskAsync("SQLInjection", component)
            },
            new ThreatScenario
            {
                Id = Guid.NewGuid().ToString(),
                Title = "Session Hijacking",
                Description = "Unauthorized access to user sessions",
                Category = ThreatCategory.Spoofing,
                AffectedComponent = component.Name,
                AttackVectors = new List<string> { "Session fixation", "Session sidejacking", "Cross-site request forgery" },
                RiskLevel = await _riskCalculator.CalculateRiskAsync("SessionHijacking", component)
            }
        };
    }
    
    public async Task<RiskAssessment> AssessRiskAsync(ThreatScenario threat)
    {
        var impact = await CalculateImpactAsync(threat);
        var likelihood = await CalculateLikelihoodAsync(threat);
        
        var riskScore = (impact.Score + likelihood.Score) / 2;
        var riskLevel = riskScore switch
        {
            >= 8 => RiskLevel.Critical,
            >= 6 => RiskLevel.High,
            >= 4 => RiskLevel.Medium,
            >= 2 => RiskLevel.Low,
            _ => RiskLevel.Informational
        };
        
        return new RiskAssessment
        {
            ThreatId = threat.Id,
            Impact = impact,
            Likelihood = likelihood,
            OverallRisk = riskLevel,
            RiskScore = riskScore,
            AssessedAt = DateTime.UtcNow
        };
    }
    
    public async Task<IEnumerable<Mitigation>> RecommendMitigationsAsync(ThreatScenario threat)
    {
        var mitigations = await _threatDatabase.GetMitigationsAsync(threat.Category, threat.AffectedComponent);
        
        return mitigations.Where(m => IsApplicable(m, threat))
                         .OrderByDescending(m => m.Effectiveness)
                         .Take(5);
    }
}
```

---

## 📊 Security Monitoring and Observability {#monitoring}

### Security Event Monitoring

```csharp
// ✅ Security Event Monitoring System
public interface ISecurityEventService
{
    Task LogSecurityEventAsync(SecurityEvent securityEvent);
    Task<IEnumerable<SecurityEvent>> GetEventsAsync(SecurityEventQuery query);
    Task<SecurityAlert> AnalyzeEventAsync(SecurityEvent securityEvent);
    Task<IEnumerable<SecurityAlert>> GetActiveAlertsAsync();
}

public class SecurityEventService : ISecurityEventService
{
    private readonly ISecurityEventRepository _repository;
    private readonly ISecurityAnalyzer _analyzer;
    private readonly IAlertService _alertService;
    private readonly ILogger<SecurityEventService> _logger;
    
    public async Task LogSecurityEventAsync(SecurityEvent securityEvent)
    {
        // Enrich event with additional context
        securityEvent.Timestamp = DateTime.UtcNow;
        securityEvent.Source = Environment.MachineName;
        securityEvent.Id = Guid.NewGuid().ToString();
        
        // Store the event
        await _repository.CreateAsync(securityEvent);
        
        // Analyze for potential threats
        var alert = await AnalyzeEventAsync(securityEvent);
        if (alert != null)
        {
            await _alertService.TriggerAlertAsync(alert);
        }
        
        _logger.LogInformation("Security event logged: {EventType} from {Source}",
            securityEvent.EventType, securityEvent.Source);
    }
    
    public async Task<SecurityAlert> AnalyzeEventAsync(SecurityEvent securityEvent)
    {
        return securityEvent.EventType switch
        {
            SecurityEventType.LoginFailure => await AnalyzeLoginFailureAsync(securityEvent),
            SecurityEventType.UnauthorizedAccess => await AnalyzeUnauthorizedAccessAsync(securityEvent),
            SecurityEventType.SuspiciousActivity => await AnalyzeSuspiciousActivityAsync(securityEvent),
            SecurityEventType.DataAccess => await AnalyzeDataAccessAsync(securityEvent),
            _ => null
        };
    }
    
    private async Task<SecurityAlert> AnalyzeLoginFailureAsync(SecurityEvent securityEvent)
    {
        var recentFailures = await _repository.GetRecentEventsAsync(
            SecurityEventType.LoginFailure,
            securityEvent.UserId,
            TimeSpan.FromMinutes(15));
        
        if (recentFailures.Count() >= 5)
        {
            return new SecurityAlert
            {
                Id = Guid.NewGuid().ToString(),
                Type = SecurityAlertType.BruteForceAttack,
                Severity = AlertSeverity.High,
                Title = "Potential Brute Force Attack",
                Description = $"Multiple login failures detected for user {securityEvent.UserId}",
                TriggeredBy = securityEvent.Id,
                RecommendedActions = new[]
                {
                    "Lock user account temporarily",
                    "Require additional authentication factors",
                    "Investigate source IP address"
                }
            };
        }
        
        return null;
    }
    
    private async Task<SecurityAlert> AnalyzeUnauthorizedAccessAsync(SecurityEvent securityEvent)
    {
        // Check for privilege escalation patterns
        var recentEvents = await _repository.GetUserEventsAsync(
            securityEvent.UserId,
            TimeSpan.FromHours(1));
        
        var privilegeChanges = recentEvents
            .Where(e => e.EventType == SecurityEventType.PrivilegeChange)
            .ToList();
        
        if (privilegeChanges.Any())
        {
            return new SecurityAlert
            {
                Id = Guid.NewGuid().ToString(),
                Type = SecurityAlertType.PrivilegeEscalation,
                Severity = AlertSeverity.Critical,
                Title = "Potential Privilege Escalation",
                Description = "Unauthorized access attempt following privilege changes",
                TriggeredBy = securityEvent.Id,
                RecommendedActions = new[]
                {
                    "Review recent privilege changes",
                    "Audit user permissions",
                    "Consider temporary access suspension"
                }
            };
        }
        
        return new SecurityAlert
        {
            Id = Guid.NewGuid().ToString(),
            Type = SecurityAlertType.UnauthorizedAccess,
            Severity = AlertSeverity.Medium,
            Title = "Unauthorized Access Attempt",
            Description = $"User {securityEvent.UserId} attempted to access {securityEvent.Resource}",
            TriggeredBy = securityEvent.Id
        };
    }
}

// ✅ Security Metrics and Dashboards
public class SecurityMetricsService : ISecurityMetricsService
{
    private readonly ISecurityEventRepository _eventRepository;
    private readonly IVulnerabilityScanner _vulnerabilityScanner;
    private readonly IComplianceChecker _complianceChecker;
    
    public async Task<SecurityDashboard> GetSecurityDashboardAsync(TimeSpan period)
    {
        var endTime = DateTime.UtcNow;
        var startTime = endTime.Subtract(period);
        
        var events = await _eventRepository.GetEventsBetweenAsync(startTime, endTime);
        var vulnerabilities = await _vulnerabilityScanner.GetActiveVulnerabilitiesAsync();
        var complianceStatus = await _complianceChecker.GetComplianceStatusAsync();
        
        return new SecurityDashboard
        {
            Period = period,
            TotalSecurityEvents = events.Count(),
            CriticalAlerts = events.Count(e => e.Severity == AlertSeverity.Critical),
            HighPriorityAlerts = events.Count(e => e.Severity == AlertSeverity.High),
            
            EventsByType = events.GroupBy(e => e.EventType)
                                .ToDictionary(g => g.Key, g => g.Count()),
            
            EventsTrend = GenerateEventsTrend(events, period),
            
            VulnerabilityStatus = new VulnerabilityStatus
            {
                Critical = vulnerabilities.Count(v => v.Severity == VulnerabilitySeverity.Critical),
                High = vulnerabilities.Count(v => v.Severity == VulnerabilitySeverity.High),
                Medium = vulnerabilities.Count(v => v.Severity == VulnerabilitySeverity.Medium),
                Low = vulnerabilities.Count(v => v.Severity == VulnerabilitySeverity.Low)
            },
            
            ComplianceScore = complianceStatus.OverallScore,
            ComplianceDetails = complianceStatus.Details,
            
            TopRisks = await IdentifyTopRisksAsync(events, vulnerabilities),
            
            GeneratedAt = DateTime.UtcNow
        };
    }
    
    private async Task<IEnumerable<SecurityRisk>> IdentifyTopRisksAsync(
        IEnumerable<SecurityEvent> events, 
        IEnumerable<Vulnerability> vulnerabilities)
    {
        var risks = new List<SecurityRisk>();
        
        // Analyze event patterns for risks
        var failedLogins = events.Where(e => e.EventType == SecurityEventType.LoginFailure);
        var unauthorizedAccess = events.Where(e => e.EventType == SecurityEventType.UnauthorizedAccess);
        
        if (failedLogins.Count() > 100)
        {
            risks.Add(new SecurityRisk
            {
                Type = "Authentication Attacks",
                Severity = RiskSeverity.High,
                Description = "High volume of failed login attempts detected",
                RecommendedActions = new[] { "Implement rate limiting", "Enable MFA", "Monitor for patterns" }
            });
        }
        
        // Analyze vulnerabilities for risks
        var criticalVulns = vulnerabilities.Where(v => v.Severity == VulnerabilitySeverity.Critical);
        if (criticalVulns.Any())
        {
            risks.Add(new SecurityRisk
            {
                Type = "Critical Vulnerabilities",
                Severity = RiskSeverity.Critical,
                Description = $"{criticalVulns.Count()} critical vulnerabilities require immediate attention",
                RecommendedActions = new[] { "Apply security patches", "Implement temporary mitigations", "Assess exposure" }
            });
        }
        
        return risks.OrderByDescending(r => r.Severity).Take(10);
    }
}
```

---

## ☁️ Cloud Security Architecture {#cloud-security}

### Azure Security Implementation

```csharp
// ✅ Azure Key Vault Integration
public class AzureKeyVaultService : ISecretManagementService
{
    private readonly SecretClient _secretClient;
    private readonly CertificateClient _certificateClient;
    private readonly KeyClient _keyClient;
    private readonly ILogger<AzureKeyVaultService> _logger;
    
    public AzureKeyVaultService(IConfiguration configuration, ILogger<AzureKeyVaultService> logger)
    {
        var keyVaultUrl = configuration["KeyVault:VaultUrl"];
        var credential = new DefaultAzureCredential();
        
        _secretClient = new SecretClient(new Uri(keyVaultUrl), credential);
        _certificateClient = new CertificateClient(new Uri(keyVaultUrl), credential);
        _keyClient = new KeyClient(new Uri(keyVaultUrl), credential);
        _logger = logger;
    }
    
    public async Task<string> GetSecretAsync(string secretName)
    {
        try
        {
            var response = await _secretClient.GetSecretAsync(secretName);
            _logger.LogInformation("Secret {SecretName} retrieved from Key Vault", secretName);
            return response.Value.Value;
        }
        catch (RequestFailedException ex) when (ex.Status == 404)
        {
            _logger.LogWarning("Secret {SecretName} not found in Key Vault", secretName);
            throw new SecretNotFoundException($"Secret '{secretName}' not found");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving secret {SecretName} from Key Vault", secretName);
            throw;
        }
    }
    
    public async Task SetSecretAsync(string secretName, string secretValue, TimeSpan? expiresIn = null)
    {
        var secret = new KeyVaultSecret(secretName, secretValue);
        
        if (expiresIn.HasValue)
        {
            secret.Properties.ExpiresOn = DateTimeOffset.UtcNow.Add(expiresIn.Value);
        }
        
        // Add metadata
        secret.Properties.Tags["CreatedBy"] = "Application";
        secret.Properties.Tags["CreatedAt"] = DateTimeOffset.UtcNow.ToString();
        
        await _secretClient.SetSecretAsync(secret);
        _logger.LogInformation("Secret {SecretName} stored in Key Vault", secretName);
    }
    
    public async Task<X509Certificate2> GetCertificateAsync(string certificateName)
    {
        try
        {
            var response = await _certificateClient.DownloadCertificateAsync(certificateName);
            _logger.LogInformation("Certificate {CertificateName} retrieved from Key Vault", certificateName);
            return response;
        }
        catch (RequestFailedException ex) when (ex.Status == 404)
        {
            _logger.LogWarning("Certificate {CertificateName} not found in Key Vault", certificateName);
            throw new CertificateNotFoundException($"Certificate '{certificateName}' not found");
        }
    }
}

// ✅ Azure AD Integration
public class AzureAdAuthenticationService : IAuthenticationService
{
    private readonly IConfidentialClientApplication _confidentialClientApp;
    private readonly GraphServiceClient _graphClient;
    private readonly ILogger<AzureAdAuthenticationService> _logger;
    
    public async Task<AuthenticationResult> AuthenticateUserAsync(string username, string password)
    {
        try
        {
            var result = await _confidentialClientApp
                .AcquireTokenByUsernamePassword(new[] { "User.Read" }, username, password.ToSecureString())
                .ExecuteAsync();
            
            var userInfo = await GetUserInfoAsync(result.AccessToken);
            
            return new AuthenticationResult
            {
                Success = true,
                AccessToken = result.AccessToken,
                ExpiresOn = result.ExpiresOn,
                UserInfo = userInfo
            };
        }
        catch (MsalException ex)
        {
            _logger.LogWarning("Authentication failed for user {Username}: {Error}", username, ex.Message);
            return new AuthenticationResult
            {
                Success = false,
                Error = ex.Message
            };
        }
    }
    
    public async Task<UserInfo> GetUserInfoAsync(string accessToken)
    {
        var user = await _graphClient.Me.Request()
            .WithAppOnly()
            .GetAsync();
        
        var groups = await _graphClient.Me.MemberOf.Request()
            .GetAsync();
        
        return new UserInfo
        {
            Id = user.Id,
            DisplayName = user.DisplayName,
            Email = user.Mail ?? user.UserPrincipalName,
            Groups = groups.Select(g => g.Id).ToList()
        };
    }
    
    public async Task<bool> ValidateTokenAsync(string accessToken)
    {
        try
        {
            var validationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = "https://login.microsoftonline.com/{tenantId}/v2.0",
                ValidateAudience = true,
                ValidAudience = "your-application-id",
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                IssuerSigningKeyResolver = (token, securityToken, kid, validationParameters) =>
                {
                    // Implement key resolution from Azure AD
                    return GetSigningKeysFromAzureAd();
                }
            };
            
            var handler = new JwtSecurityTokenHandler();
            var principal = handler.ValidateToken(accessToken, validationParameters, out _);
            
            return principal.Identity.IsAuthenticated;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Token validation failed");
            return false;
        }
    }
}
```

---

## 🌐 Security in Distributed Systems {#distributed-security}

### Zero Trust Architecture

```csharp
// ✅ Zero Trust Security Gateway
public class ZeroTrustSecurityGateway : ISecurityGateway
{
    private readonly IIdentityVerificationService _identityService;
    private readonly IDeviceTrustService _deviceService;
    private readonly IRiskAssessmentService _riskService;
    private readonly IPolicyEvaluationService _policyService;
    private readonly ILogger<ZeroTrustSecurityGateway> _logger;
    
    public async Task<AuthorizationResult> AuthorizeRequestAsync(SecurityContext context)
    {
        var authorizationResult = new AuthorizationResult();
        
        try
        {
            // Step 1: Verify Identity
            var identityResult = await _identityService.VerifyIdentityAsync(context.User);
            if (!identityResult.IsValid)
            {
                authorizationResult.Denied("Identity verification failed");
                return authorizationResult;
            }
            
            // Step 2: Assess Device Trust
            var deviceResult = await _deviceService.AssessDeviceTrustAsync(context.Device);
            if (deviceResult.TrustLevel < TrustLevel.Trusted)
            {
                authorizationResult.RequireAdditionalVerification("Device trust insufficient");
                return authorizationResult;
            }
            
            // Step 3: Evaluate Risk Score
            var riskScore = await _riskService.CalculateRiskScoreAsync(context);
            if (riskScore > RiskThreshold.High)
            {
                authorizationResult.RequireStepUpAuthentication("High risk detected");
                return authorizationResult;
            }
            
            // Step 4: Apply Conditional Access Policies
            var policyResult = await _policyService.EvaluatePoliciesAsync(context);
            if (!policyResult.AllPoliciesSatisfied)
            {
                authorizationResult.Denied($"Policy violation: {policyResult.FailedPolicy}");
                return authorizationResult;
            }
            
            // Step 5: Grant Least Privilege Access
            var permissions = await CalculateLeastPrivilegePermissionsAsync(context);
            authorizationResult.Granted(permissions);
            
            // Log successful authorization
            _logger.LogInformation("Zero Trust authorization granted for user {UserId} to resource {Resource}",
                context.User.Id, context.RequestedResource);
            
            return authorizationResult;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Zero Trust authorization failed");
            authorizationResult.Error("Authorization service error");
            return authorizationResult;
        }
    }
    
    private async Task<IEnumerable<string>> CalculateLeastPrivilegePermissionsAsync(SecurityContext context)
    {
        var requestedPermissions = context.RequestedPermissions;
        var userPermissions = await GetUserPermissionsAsync(context.User.Id);
        var resourcePermissions = await GetResourcePermissionsAsync(context.RequestedResource);
        
        // Calculate intersection of requested, user, and resource permissions
        var grantedPermissions = requestedPermissions
            .Intersect(userPermissions)
            .Intersect(resourcePermissions)
            .ToList();
        
        // Apply time-based restrictions
        var timeRestrictedPermissions = await ApplyTimeRestrictionsAsync(grantedPermissions, context);
        
        return timeRestrictedPermissions;
    }
}

// ✅ Service Mesh Security
public class ServiceMeshSecurityConfiguration
{
    public static void ConfigureIstioSecurity(IServiceCollection services, IConfiguration configuration)
    {
        // mTLS Configuration
        services.Configure<MutualTlsOptions>(options =>
        {
            options.Mode = MutualTlsMode.Strict;
            options.CertificateSource = CertificateSource.Istiod;
            options.MinTlsVersion = TlsVersion.Tls12;
        });
        
        // Authorization Policies
        services.Configure<AuthorizationPolicyOptions>(options =>
        {
            options.DefaultAction = AuthorizationAction.Deny;
            options.Policies = new List<AuthorizationPolicy>
            {
                new AuthorizationPolicy
                {
                    Name = "frontend-to-backend",
                    Selector = new WorkloadSelector { MatchLabels = { ["app"] = "backend" } },
                    Rules = new[]
                    {
                        new AuthorizationRule
                        {
                            From = new[] { new Source { Principals = new[] { "frontend-service-account" } } },
                            To = new[] { new Operation { Methods = new[] { "GET", "POST" } } }
                        }
                    }
                },
                new AuthorizationPolicy
                {
                    Name = "require-jwt",
                    Selector = new WorkloadSelector { MatchLabels = { ["app"] = "api" } },
                    Rules = new[]
                    {
                        new AuthorizationRule
                        {
                            From = new[]
                            {
                                new Source
                                {
                                    RequestPrincipals = new[] { "issuer/subject" }
                                }
                            }
                        }
                    }
                }
            };
        });
        
        // Security Monitoring
        services.Configure<SecurityMonitoringOptions>(options =>
        {
            options.EnableAccessLogging = true;
            options.EnableSecurityAuditing = true;
            options.AlertOnUnauthorizedAccess = true;
            options.MetricsCollection = new SecurityMetricsOptions
            {
                CollectTlsMetrics = true,
                CollectAuthorizationMetrics = true,
                CollectSecurityEventMetrics = true
            };
        });
    }
}
```

---

## 🔐🔗 Related Topics

### Prerequisites

- [API Design Principles](./10_API-Design-Principles.md)
- [Clean Architecture Fundamentals](./01_Clean-Architecture-Fundamentals.md)
- [Microservices Architecture](./05_Microservices-Architecture.md)

### Builds Upon

- Authentication and authorization fundamentals
- Cryptography and encryption principles
- Network security concepts
- Identity management systems

### Enables

- Zero Trust Architecture implementation
- Secure DevOps practices (DevSecOps)
- Compliance and regulatory adherence
- Incident response and security monitoring

### Cross-References

- **Infrastructure**: Security monitoring, logging, alerting
- **Development**: Secure coding practices, vulnerability assessment
- **Operations**: Security automation, compliance reporting
- **Governance**: Security policies, risk management

---

## 📚 Summary

Security Architecture is foundational to modern software systems. Key principles include:

1. **Defense in Depth**: Multiple layers of security controls
2. **Zero Trust**: Never trust, always verify
3. **Principle of Least Privilege**: Minimal access rights
4. **Security by Design**: Built-in, not bolted-on
5. **Continuous Monitoring**: Real-time threat detection
6. **Incident Response**: Prepared response to security events

**Security Decision Matrix**:

- **Authentication**: Choose based on risk level and user experience requirements
- **Authorization**: RBAC for simple scenarios, ABAC for complex attribute-based decisions
- **Encryption**: Always encrypt data in transit and at rest
- **Monitoring**: Implement comprehensive logging and alerting

**Next Steps**: Explore advanced topics like Zero Trust Architecture, DevSecOps practices, and security automation.
