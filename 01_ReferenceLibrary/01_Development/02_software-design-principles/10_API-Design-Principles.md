# 10_API-Design-Principles

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Clean Architecture, SOLID Principles, Microservices Architecture  
**Estimated Time**: 75-90 minutes

## 🎯 Learning Objectives

By the end of this content, you will:

- Design RESTful APIs following industry best practices
- Understand GraphQL principles and when to use it over REST
- Implement API security patterns and authentication strategies
- Apply API versioning and evolution strategies
- Create comprehensive API documentation and testing approaches
- Optimize API performance and handle error scenarios effectively

## 📋 Table of Contents

1. [API Design Fundamentals](#fundamentals)
2. [RESTful API Design](#restful-design)
3. [GraphQL Design Patterns](#graphql-design)
4. [API Security and Authentication](#security)
5. [API Versioning Strategies](#versioning)
6. [Error Handling and Status Codes](#error-handling)
7. [API Documentation and Testing](#documentation)
8. [Performance and Optimization](#performance)
9. [API Gateway Patterns](#api-gateway)

---

## 🏗️ API Design Fundamentals {#fundamentals}

### Core Principles

**APIs (Application Programming Interfaces)** serve as contracts between different software components, enabling communication and data exchange. Well-designed APIs are intuitive, consistent, and maintainable.

```text
API Design Pyramid
┌─────────────────────────────────┐
│         User Experience        │ ← Clear, intuitive interface
├─────────────────────────────────┤
│        Documentation          │ ← Comprehensive guides
├─────────────────────────────────┤
│      Error Handling           │ ← Meaningful error responses
├─────────────────────────────────┤
│        Security              │ ← Authentication & authorization
├─────────────────────────────────┤
│       Consistency            │ ← Uniform patterns & naming
├─────────────────────────────────┤
│        Performance           │ ← Efficient data transfer
└─────────────────────────────────┘
```

### Design-First Approach

```csharp
// ✅ API Design-First with OpenAPI Specification
[ApiController]
[Route("api/v1/[controller]")]
[Produces("application/json")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    
    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }
    
    /// <summary>
    /// Retrieves a paginated list of products
    /// </summary>
    /// <param name="page">Page number (default: 1)</param>
    /// <param name="pageSize">Items per page (default: 10, max: 100)</param>
    /// <param name="category">Filter by category</param>
    /// <returns>Paginated product list</returns>
    [HttpGet]
    [ProducesResponseType(typeof(PagedResult<ProductDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<PagedResult<ProductDto>>> GetProducts(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? category = null)
    {
        if (page < 1 || pageSize < 1 || pageSize > 100)
        {
            return BadRequest(new ErrorResponse
            {
                Error = "INVALID_PAGINATION",
                Message = "Page must be >= 1 and pageSize must be between 1-100",
                Details = new { page, pageSize }
            });
        }
        
        var result = await _productService.GetProductsAsync(page, pageSize, category);
        return Ok(result);
    }
}
```

---

## 🌐 RESTful API Design {#restful-design}

### REST Principles Implementation

```csharp
// ✅ Resource-Oriented Design
[ApiController]
[Route("api/v1")]
public class ECommerceApiController : ControllerBase
{
    // Collection Resource
    [HttpGet("products")]
    public async Task<ActionResult<PagedResult<ProductDto>>> GetProducts(
        [FromQuery] ProductQueryParams queryParams)
    {
        var result = await _productService.GetProductsAsync(queryParams);
        return Ok(result);
    }
    
    // Individual Resource
    [HttpGet("products/{id:guid}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ProductDto>> GetProduct(Guid id)
    {
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null)
            return NotFound();
            
        return Ok(product);
    }
    
    // Resource Creation
    [HttpPost("products")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ValidationErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ProductDto>> CreateProduct(
        [FromBody] CreateProductRequest request)
    {
        var validationResult = await _validator.ValidateAsync(request);
        if (!validationResult.IsValid)
        {
            return BadRequest(new ValidationErrorResponse(validationResult.Errors));
        }
        
        var product = await _productService.CreateProductAsync(request);
        
        return CreatedAtAction(
            nameof(GetProduct),
            new { id = product.Id },
            product);
    }
    
    // Resource Update (Full)
    [HttpPut("products/{id:guid}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ProductDto>> UpdateProduct(
        Guid id,
        [FromBody] UpdateProductRequest request)
    {
        var product = await _productService.UpdateProductAsync(id, request);
        if (product == null)
            return NotFound();
            
        return Ok(product);
    }
    
    // Resource Update (Partial)
    [HttpPatch("products/{id:guid}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ProductDto>> PatchProduct(
        Guid id,
        [FromBody] JsonPatchDocument<UpdateProductRequest> patchDoc)
    {
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null)
            return NotFound();
        
        var request = _mapper.Map<UpdateProductRequest>(product);
        patchDoc.ApplyTo(request, ModelState);
        
        if (!ModelState.IsValid)
            return BadRequest(ModelState);
        
        var updatedProduct = await _productService.UpdateProductAsync(id, request);
        return Ok(updatedProduct);
    }
    
    // Resource Deletion
    [HttpDelete("products/{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteProduct(Guid id)
    {
        var deleted = await _productService.DeleteProductAsync(id);
        if (!deleted)
            return NotFound();
            
        return NoContent();
    }
}
```

### Nested Resources and Relationships

```csharp
// ✅ Nested Resource Design
[ApiController]
[Route("api/v1")]
public class OrderResourcesController : ControllerBase
{
    // Nested Collection: Order Items
    [HttpGet("orders/{orderId:guid}/items")]
    public async Task<ActionResult<IEnumerable<OrderItemDto>>> GetOrderItems(Guid orderId)
    {
        var orderExists = await _orderService.OrderExistsAsync(orderId);
        if (!orderExists)
            return NotFound($"Order {orderId} not found");
        
        var items = await _orderService.GetOrderItemsAsync(orderId);
        return Ok(items);
    }
    
    // Add Item to Order
    [HttpPost("orders/{orderId:guid}/items")]
    public async Task<ActionResult<OrderItemDto>> AddOrderItem(
        Guid orderId,
        [FromBody] AddOrderItemRequest request)
    {
        var item = await _orderService.AddItemToOrderAsync(orderId, request);
        if (item == null)
            return NotFound($"Order {orderId} not found");
        
        return CreatedAtAction(
            nameof(GetOrderItem),
            new { orderId, itemId = item.Id },
            item);
    }
    
    // Individual Nested Resource
    [HttpGet("orders/{orderId:guid}/items/{itemId:guid}")]
    public async Task<ActionResult<OrderItemDto>> GetOrderItem(Guid orderId, Guid itemId)
    {
        var item = await _orderService.GetOrderItemAsync(orderId, itemId);
        if (item == null)
            return NotFound();
        
        return Ok(item);
    }
    
    // Resource Actions (Non-CRUD Operations)
    [HttpPost("orders/{orderId:guid}/actions/confirm")]
    public async Task<ActionResult<OrderDto>> ConfirmOrder(Guid orderId)
    {
        try
        {
            var order = await _orderService.ConfirmOrderAsync(orderId);
            return Ok(order);
        }
        catch (OrderNotFoundException)
        {
            return NotFound($"Order {orderId} not found");
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new ErrorResponse
            {
                Error = "INVALID_ORDER_STATE",
                Message = ex.Message
            });
        }
    }
    
    [HttpPost("orders/{orderId:guid}/actions/cancel")]
    public async Task<ActionResult<OrderDto>> CancelOrder(
        Guid orderId,
        [FromBody] CancelOrderRequest request)
    {
        var order = await _orderService.CancelOrderAsync(orderId, request.Reason);
        if (order == null)
            return NotFound($"Order {orderId} not found");
        
        return Ok(order);
    }
}
```

### HATEOAS Implementation

```csharp
// ✅ Hypermedia-Driven API Design
public class OrderDto
{
    public Guid Id { get; set; }
    public string Status { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; }
    public IEnumerable<Link> Links { get; set; } = new List<Link>();
}

public class Link
{
    public string Rel { get; set; }
    public string Href { get; set; }
    public string Method { get; set; }
    public string Type { get; set; }
}

[HttpGet("orders/{id:guid}")]
public async Task<ActionResult<OrderDto>> GetOrder(Guid id)
{
    var order = await _orderService.GetOrderByIdAsync(id);
    if (order == null)
        return NotFound();
    
    // Add hypermedia links based on order state
    var links = new List<Link>
    {
        new Link
        {
            Rel = "self",
            Href = $"/api/v1/orders/{order.Id}",
            Method = "GET",
            Type = "application/json"
        },
        new Link
        {
            Rel = "items",
            Href = $"/api/v1/orders/{order.Id}/items",
            Method = "GET",
            Type = "application/json"
        }
    };
    
    // Conditional links based on order state
    if (order.Status == "Pending")
    {
        links.Add(new Link
        {
            Rel = "confirm",
            Href = $"/api/v1/orders/{order.Id}/actions/confirm",
            Method = "POST",
            Type = "application/json"
        });
        
        links.Add(new Link
        {
            Rel = "cancel",
            Href = $"/api/v1/orders/{order.Id}/actions/cancel",
            Method = "POST",
            Type = "application/json"
        });
    }
    
    if (order.Status == "Confirmed")
    {
        links.Add(new Link
        {
            Rel = "ship",
            Href = $"/api/v1/orders/{order.Id}/actions/ship",
            Method = "POST",
            Type = "application/json"
        });
    }
    
    order.Links = links;
    return Ok(order);
}
```

---

## 🔄 GraphQL Design Patterns {#graphql-design}

### Schema-First Design

```csharp
// ✅ GraphQL Schema Definition
public class Query
{
    [UseProjection]
    [UseFiltering]
    [UseSorting]
    public IQueryable<Product> GetProducts([ScopedService] ApplicationDbContext context)
        => context.Products;
    
    public async Task<Product?> GetProductById(
        Guid id,
        [ScopedService] IProductService productService)
        => await productService.GetProductByIdAsync(id);
    
    public async Task<Order?> GetOrder(
        Guid id,
        [ScopedService] IOrderService orderService)
        => await orderService.GetOrderByIdAsync(id);
}

public class Mutation
{
    public async Task<CreateProductPayload> CreateProductAsync(
        CreateProductInput input,
        [ScopedService] IProductService productService)
    {
        try
        {
            var product = await productService.CreateProductAsync(input);
            return new CreateProductPayload(product);
        }
        catch (ValidationException ex)
        {
            return new CreateProductPayload(ex.Errors);
        }
    }
    
    public async Task<UpdateProductPayload> UpdateProductAsync(
        UpdateProductInput input,
        [ScopedService] IProductService productService)
    {
        try
        {
            var product = await productService.UpdateProductAsync(input.Id, input);
            return new UpdateProductPayload(product);
        }
        catch (ProductNotFoundException)
        {
            return new UpdateProductPayload(new[] { "Product not found" });
        }
    }
}

// GraphQL Types
public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public decimal Price { get; set; }
    public string CategoryId { get; set; }
    
    // Navigation properties with data loaders
    public async Task<Category> GetCategoryAsync(
        [ScopedService] ICategoryDataLoader categoryLoader)
        => await categoryLoader.LoadAsync(CategoryId);
    
    public async Task<IEnumerable<Review>> GetReviewsAsync(
        [ScopedService] IReviewDataLoader reviewLoader)
        => await reviewLoader.LoadAsync(Id);
}

public class Order
{
    public Guid Id { get; set; }
    public string Status { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; }
    
    public async Task<Customer> GetCustomerAsync(
        [ScopedService] ICustomerDataLoader customerLoader)
        => await customerLoader.LoadAsync(CustomerId);
    
    public async Task<IEnumerable<OrderItem>> GetItemsAsync(
        [ScopedService] IOrderItemDataLoader itemLoader)
        => await itemLoader.LoadAsync(Id);
}
```

### Data Loaders for N+1 Problem

```csharp
// ✅ Efficient Data Loading
public class CategoryDataLoader : BatchDataLoader<string, Category>
{
    private readonly IDbContextFactory<ApplicationDbContext> _contextFactory;
    
    public CategoryDataLoader(
        IDbContextFactory<ApplicationDbContext> contextFactory,
        IBatchScheduler batchScheduler,
        DataLoaderOptions? options = null)
        : base(batchScheduler, options)
    {
        _contextFactory = contextFactory;
    }
    
    protected override async Task<IReadOnlyDictionary<string, Category>> LoadBatchAsync(
        IReadOnlyList<string> keys,
        CancellationToken cancellationToken)
    {
        await using var context = _contextFactory.CreateDbContext();
        
        var categories = await context.Categories
            .Where(c => keys.Contains(c.Id))
            .ToListAsync(cancellationToken);
        
        return categories.ToDictionary(c => c.Id);
    }
}

public class ReviewDataLoader : GroupedDataLoader<Guid, Review>
{
    private readonly IDbContextFactory<ApplicationDbContext> _contextFactory;
    
    public ReviewDataLoader(
        IDbContextFactory<ApplicationDbContext> contextFactory,
        IBatchScheduler batchScheduler,
        DataLoaderOptions? options = null)
        : base(batchScheduler, options)
    {
        _contextFactory = contextFactory;
    }
    
    protected override async Task<ILookup<Guid, Review>> LoadGroupedBatchAsync(
        IReadOnlyList<Guid> keys,
        CancellationToken cancellationToken)
    {
        await using var context = _contextFactory.CreateDbContext();
        
        var reviews = await context.Reviews
            .Where(r => keys.Contains(r.ProductId))
            .ToListAsync(cancellationToken);
        
        return reviews.ToLookup(r => r.ProductId);
    }
}
```

### GraphQL vs REST Comparison

```csharp
// REST: Multiple requests needed
/*
GET /api/v1/orders/123
GET /api/v1/customers/456
GET /api/v1/orders/123/items
GET /api/v1/products/789
GET /api/v1/products/101
*/

// GraphQL: Single request
/*
query GetOrderDetails($orderId: ID!) {
  order(id: $orderId) {
    id
    status
    totalAmount
    createdAt
    customer {
      name
      email
    }
    items {
      quantity
      unitPrice
      product {
        name
        description
      }
    }
  }
}
*/

// ✅ GraphQL Query Implementation
public class OrderQueries
{
    public async Task<Order?> GetOrder(
        Guid id,
        [ScopedService] ApplicationDbContext context)
    {
        return await context.Orders
            .FirstOrDefaultAsync(o => o.Id == id);
    }
}

// ✅ Flexible Field Selection
public class OrderType : ObjectType<Order>
{
    protected override void Configure(IObjectTypeDescriptor<Order> descriptor)
    {
        descriptor.Field(o => o.Customer)
            .ResolveWith<Resolvers>(r => r.GetCustomerAsync(default!, default!));
        
        descriptor.Field(o => o.Items)
            .ResolveWith<Resolvers>(r => r.GetOrderItemsAsync(default!, default!));
    }
    
    private class Resolvers
    {
        public async Task<Customer> GetCustomerAsync(
            [Parent] Order order,
            [ScopedService] ICustomerDataLoader customerLoader)
            => await customerLoader.LoadAsync(order.CustomerId);
        
        public async Task<IEnumerable<OrderItem>> GetOrderItemsAsync(
            [Parent] Order order,
            [ScopedService] IOrderItemDataLoader itemLoader)
            => await itemLoader.LoadAsync(order.Id);
    }
}
```

---

## 🔐 API Security and Authentication {#security}

### JWT Authentication Implementation

```csharp
// ✅ JWT Token Service
public class JwtTokenService : ITokenService
{
    private readonly JwtSettings _jwtSettings;
    private readonly ILogger<JwtTokenService> _logger;
    
    public JwtTokenService(IOptions<JwtSettings> jwtSettings, ILogger<JwtTokenService> logger)
    {
        _jwtSettings = jwtSettings.Value;
        _logger = logger;
    }
    
    public string GenerateAccessToken(UserClaims userClaims)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, userClaims.UserId.ToString()),
            new Claim(ClaimTypes.Email, userClaims.Email),
            new Claim(ClaimTypes.Name, userClaims.Username),
            new Claim("tenant_id", userClaims.TenantId.ToString()),
            new Claim(ClaimTypes.Role, string.Join(",", userClaims.Roles))
        };
        
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.SecretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        
        var token = new JwtSecurityToken(
            issuer: _jwtSettings.Issuer,
            audience: _jwtSettings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_jwtSettings.AccessTokenExpiryMinutes),
            signingCredentials: credentials);
        
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
    
    public string GenerateRefreshToken()
    {
        var randomBytes = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomBytes);
        return Convert.ToBase64String(randomBytes);
    }
    
    public ClaimsPrincipal? ValidateToken(string token)
    {
        try
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(_jwtSettings.SecretKey);
            
            var validationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ValidateIssuer = true,
                ValidIssuer = _jwtSettings.Issuer,
                ValidateAudience = true,
                ValidAudience = _jwtSettings.Audience,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero
            };
            
            var principal = tokenHandler.ValidateToken(token, validationParameters, out _);
            return principal;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Token validation failed");
            return null;
        }
    }
}
```

### API Key Authentication

```csharp
// ✅ API Key Authentication Middleware
public class ApiKeyAuthenticationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IApiKeyService _apiKeyService;
    private readonly ILogger<ApiKeyAuthenticationMiddleware> _logger;
    
    public ApiKeyAuthenticationMiddleware(
        RequestDelegate next,
        IApiKeyService apiKeyService,
        ILogger<ApiKeyAuthenticationMiddleware> logger)
    {
        _next = next;
        _apiKeyService = apiKeyService;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Skip authentication for certain paths
        if (ShouldSkipAuthentication(context.Request.Path))
        {
            await _next(context);
            return;
        }
        
        var apiKey = ExtractApiKey(context.Request);
        if (string.IsNullOrEmpty(apiKey))
        {
            await WriteUnauthorizedResponse(context, "API key is required");
            return;
        }
        
        var apiKeyInfo = await _apiKeyService.ValidateApiKeyAsync(apiKey);
        if (apiKeyInfo == null)
        {
            await WriteUnauthorizedResponse(context, "Invalid API key");
            return;
        }
        
        if (!apiKeyInfo.IsActive || apiKeyInfo.ExpiresAt < DateTime.UtcNow)
        {
            await WriteUnauthorizedResponse(context, "API key is expired or inactive");
            return;
        }
        
        // Add API key info to context
        context.Items["ApiKeyInfo"] = apiKeyInfo;
        
        // Track API usage
        await _apiKeyService.TrackUsageAsync(apiKeyInfo.Id);
        
        await _next(context);
    }
    
    private string? ExtractApiKey(HttpRequest request)
    {
        // Try header first
        if (request.Headers.TryGetValue("X-API-Key", out var headerValue))
            return headerValue.FirstOrDefault();
        
        // Try query parameter
        if (request.Query.TryGetValue("api_key", out var queryValue))
            return queryValue.FirstOrDefault();
        
        return null;
    }
    
    private bool ShouldSkipAuthentication(PathString path)
    {
        var skipPaths = new[]
        {
            "/health",
            "/swagger",
            "/api/v1/auth/login",
            "/api/v1/auth/register"
        };
        
        return skipPaths.Any(skipPath => path.StartsWithSegments(skipPath));
    }
    
    private async Task WriteUnauthorizedResponse(HttpContext context, string message)
    {
        context.Response.StatusCode = 401;
        context.Response.ContentType = "application/json";
        
        var response = new ErrorResponse
        {
            Error = "UNAUTHORIZED",
            Message = message,
            Timestamp = DateTime.UtcNow
        };
        
        var json = JsonSerializer.Serialize(response);
        await context.Response.WriteAsync(json);
    }
}
```

### OAuth 2.0 / OpenID Connect

```csharp
// ✅ OAuth 2.0 Configuration
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddJwtBearer(options =>
        {
            options.Authority = Configuration["Auth:Authority"];
            options.Audience = Configuration["Auth:Audience"];
            options.RequireHttpsMetadata = true;
            
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ClockSkew = TimeSpan.FromMinutes(1)
            };
            
            options.Events = new JwtBearerEvents
            {
                OnAuthenticationFailed = context =>
                {
                    var logger = context.HttpContext.RequestServices
                        .GetRequiredService<ILogger<Startup>>();
                    logger.LogError(context.Exception, "Authentication failed");
                    return Task.CompletedTask;
                },
                OnTokenValidated = context =>
                {
                    // Add custom claims or validation
                    var userService = context.HttpContext.RequestServices
                        .GetRequiredService<IUserService>();
                    
                    var userId = context.Principal?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    if (!string.IsNullOrEmpty(userId))
                    {
                        context.HttpContext.Items["UserId"] = userId;
                    }
                    
                    return Task.CompletedTask;
                }
            };
        });
        
        services.AddAuthorization(options =>
        {
            options.AddPolicy("AdminOnly", policy =>
                policy.RequireClaim("role", "admin"));
            
            options.AddPolicy("OwnerOrAdmin", policy =>
                policy.AddRequirements(new OwnerOrAdminRequirement()));
        });
    }
}

// ✅ Custom Authorization Handler
public class OwnerOrAdminRequirement : IAuthorizationRequirement { }

public class OwnerOrAdminHandler : AuthorizationHandler<OwnerOrAdminRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        OwnerOrAdminRequirement requirement)
    {
        var user = context.User;
        
        // Check if user is admin
        if (user.HasClaim("role", "admin"))
        {
            context.Succeed(requirement);
            return Task.CompletedTask;
        }
        
        // Check if user owns the resource
        if (context.Resource is IResourceWithOwner resourceWithOwner)
        {
            var userId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userId == resourceWithOwner.OwnerId)
            {
                context.Succeed(requirement);
            }
        }
        
        return Task.CompletedTask;
    }
}
```

---

## 🔄 API Versioning Strategies {#versioning}

### URL Path Versioning

```csharp
// ✅ URL Path Versioning Implementation
[ApiController]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiVersion("1.0")]
[ApiVersion("2.0")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    [MapToApiVersion("1.0")]
    public async Task<ActionResult<IEnumerable<ProductV1Dto>>> GetProductsV1()
    {
        var products = await _productService.GetProductsAsync();
        return Ok(_mapper.Map<IEnumerable<ProductV1Dto>>(products));
    }
    
    [HttpGet]
    [MapToApiVersion("2.0")]
    public async Task<ActionResult<PagedResult<ProductV2Dto>>> GetProductsV2(
        [FromQuery] ProductQueryParamsV2 queryParams)
    {
        var result = await _productService.GetProductsAsync(queryParams);
        return Ok(_mapper.Map<PagedResult<ProductV2Dto>>(result));
    }
    
    [HttpGet("{id:guid}")]
    [MapToApiVersion("1.0")]
    public async Task<ActionResult<ProductV1Dto>> GetProductV1(Guid id)
    {
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null) return NotFound();
        
        return Ok(_mapper.Map<ProductV1Dto>(product));
    }
    
    [HttpGet("{id:guid}")]
    [MapToApiVersion("2.0")]
    public async Task<ActionResult<ProductV2Dto>> GetProductV2(Guid id)
    {
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null) return NotFound();
        
        return Ok(_mapper.Map<ProductV2Dto>(product));
    }
}

// ✅ Version-Specific DTOs
public class ProductV1Dto
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public string Category { get; set; }
}

public class ProductV2Dto
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public PriceInfo Price { get; set; }
    public CategoryInfo Category { get; set; }
    public IEnumerable<string> Tags { get; set; }
    public ProductAvailability Availability { get; set; }
}

public class PriceInfo
{
    public decimal Amount { get; set; }
    public string Currency { get; set; }
    public decimal? DiscountedAmount { get; set; }
}
```

### Header Versioning

```csharp
// ✅ Header-Based Versioning
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddApiVersioning(options =>
        {
            options.ApiVersionReader = ApiVersionReader.Combine(
                new HeaderApiVersionReader("X-API-Version"),
                new UrlSegmentApiVersionReader(),
                new QueryStringApiVersionReader("version"));
            
            options.DefaultApiVersion = new ApiVersion(1, 0);
            options.AssumeDefaultVersionWhenUnspecified = true;
            options.ApiVersionSelector = new CurrentImplementationApiVersionSelector(options);
        });
        
        services.AddVersionedApiExplorer(options =>
        {
            options.GroupNameFormat = "'v'VVV";
            options.SubstituteApiVersionInUrl = true;
        });
    }
}

[ApiController]
[Route("api/products")]
[ApiVersion("1.0")]
[ApiVersion("2.0")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    [MapToApiVersion("1.0")]
    public async Task<ActionResult> GetProductsV1()
    {
        // V1 implementation - simple list
        var products = await _productService.GetProductsAsync();
        return Ok(products.Select(p => new
        {
            p.Id,
            p.Name,
            p.Price
        }));
    }
    
    [HttpGet]
    [MapToApiVersion("2.0")]
    public async Task<ActionResult> GetProductsV2()
    {
        // V2 implementation - enhanced with pagination and filtering
        var products = await _productService.GetProductsPagedAsync();
        return Ok(new
        {
            Data = products.Items,
            Pagination = new
            {
                products.TotalCount,
                products.PageNumber,
                products.PageSize
            }
        });
    }
}
```

### Backward Compatibility

```csharp
// ✅ Backward Compatibility Service
public class ProductCompatibilityService : IProductService
{
    private readonly IProductServiceV2 _productServiceV2;
    private readonly IMapper _mapper;
    
    // V1 compatibility method
    public async Task<IEnumerable<ProductV1Dto>> GetProductsAsync()
    {
        var productsV2 = await _productServiceV2.GetProductsAsync(new ProductQueryParamsV2
        {
            Page = 1,
            PageSize = 100 // Default for V1
        });
        
        // Map V2 to V1 format
        return productsV2.Items.Select(p => new ProductV1Dto
        {
            Id = p.Id,
            Name = p.Name,
            Price = p.Price.Amount,
            Category = p.Category.Name
        });
    }
    
    // V2 method with enhanced features
    public async Task<PagedResult<ProductV2Dto>> GetProductsAsync(ProductQueryParamsV2 queryParams)
    {
        return await _productServiceV2.GetProductsAsync(queryParams);
    }
}

// ✅ Deprecation Warnings
[ApiController]
[Route("api/v{version:apiVersion}/products")]
public class ProductsController : ControllerBase
{
    [HttpGet]
    [MapToApiVersion("1.0")]
    [Obsolete("This endpoint is deprecated. Please use v2.0")]
    public async Task<ActionResult<IEnumerable<ProductV1Dto>>> GetProductsV1()
    {
        // Add deprecation header
        Response.Headers.Add("X-API-Deprecation-Warning", 
            "This endpoint version is deprecated and will be removed in 2024-12-31");
        Response.Headers.Add("X-API-Migration-Guide", 
            "https://docs.company.com/api/migration/v1-to-v2");
        
        var products = await _productCompatibilityService.GetProductsAsync();
        return Ok(products);
    }
}
```

---

## ⚠️ Error Handling and Status Codes {#error-handling}

### Comprehensive Error Response Design

```csharp
// ✅ Standardized Error Response
public class ErrorResponse
{
    public string Error { get; set; }
    public string Message { get; set; }
    public object? Details { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public string TraceId { get; set; }
    public IEnumerable<ValidationError>? ValidationErrors { get; set; }
}

public class ValidationError
{
    public string Field { get; set; }
    public string Message { get; set; }
    public object? AttemptedValue { get; set; }
}

// ✅ Global Exception Handler
public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;
    
    public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }
    
    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var errorResponse = CreateErrorResponse(exception, context);
        
        _logger.LogError(exception, "Unhandled exception occurred. TraceId: {TraceId}", 
            errorResponse.TraceId);
        
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = GetStatusCode(exception);
        
        var json = JsonSerializer.Serialize(errorResponse, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });
        
        await context.Response.WriteAsync(json);
    }
    
    private ErrorResponse CreateErrorResponse(Exception exception, HttpContext context)
    {
        return exception switch
        {
            ValidationException validationEx => new ErrorResponse
            {
                Error = "VALIDATION_FAILED",
                Message = "One or more validation errors occurred",
                TraceId = Activity.Current?.Id ?? context.TraceIdentifier,
                ValidationErrors = validationEx.Errors.Select(e => new ValidationError
                {
                    Field = e.PropertyName,
                    Message = e.ErrorMessage,
                    AttemptedValue = e.AttemptedValue
                })
            },
            NotFoundException notFoundEx => new ErrorResponse
            {
                Error = "RESOURCE_NOT_FOUND",
                Message = notFoundEx.Message,
                TraceId = Activity.Current?.Id ?? context.TraceIdentifier
            },
            UnauthorizedAccessException => new ErrorResponse
            {
                Error = "UNAUTHORIZED",
                Message = "Access denied",
                TraceId = Activity.Current?.Id ?? context.TraceIdentifier
            },
            BusinessRuleViolationException businessEx => new ErrorResponse
            {
                Error = "BUSINESS_RULE_VIOLATION",
                Message = businessEx.Message,
                Details = businessEx.Details,
                TraceId = Activity.Current?.Id ?? context.TraceIdentifier
            },
            _ => new ErrorResponse
            {
                Error = "INTERNAL_SERVER_ERROR",
                Message = "An unexpected error occurred",
                TraceId = Activity.Current?.Id ?? context.TraceIdentifier
            }
        };
    }
    
    private static int GetStatusCode(Exception exception) => exception switch
    {
        ValidationException => 400,
        NotFoundException => 404,
        UnauthorizedAccessException => 401,
        BusinessRuleViolationException => 422,
        NotImplementedException => 501,
        _ => 500
    };
}
```

### HTTP Status Code Best Practices

```csharp
// ✅ Status Code Usage Examples
[ApiController]
[Route("api/v1/[controller]")]
public class OrdersController : ControllerBase
{
    // 200 OK - Successful GET
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(OrderDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<OrderDto>> GetOrder(Guid id)
    {
        var order = await _orderService.GetOrderByIdAsync(id);
        if (order == null)
            return NotFound(new ErrorResponse
            {
                Error = "ORDER_NOT_FOUND",
                Message = $"Order with ID {id} was not found"
            });
        
        return Ok(order);
    }
    
    // 201 Created - Successful POST
    [HttpPost]
    [ProducesResponseType(typeof(OrderDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<OrderDto>> CreateOrder([FromBody] CreateOrderRequest request)
    {
        var order = await _orderService.CreateOrderAsync(request);
        
        return CreatedAtAction(
            nameof(GetOrder),
            new { id = order.Id },
            order);
    }
    
    // 204 No Content - Successful DELETE
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteOrder(Guid id)
    {
        var deleted = await _orderService.DeleteOrderAsync(id);
        if (!deleted)
            return NotFound();
        
        return NoContent();
    }
    
    // 422 Unprocessable Entity - Business rule violation
    [HttpPost("{id:guid}/actions/confirm")]
    [ProducesResponseType(typeof(OrderDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status422UnprocessableEntity)]
    public async Task<ActionResult<OrderDto>> ConfirmOrder(Guid id)
    {
        try
        {
            var order = await _orderService.ConfirmOrderAsync(id);
            return Ok(order);
        }
        catch (InvalidOrderStateException ex)
        {
            return UnprocessableEntity(new ErrorResponse
            {
                Error = "INVALID_ORDER_STATE",
                Message = ex.Message,
                Details = new { currentState = ex.CurrentState, requiredState = ex.RequiredState }
            });
        }
    }
}
```

---

## 📚 API Documentation and Testing {#documentation}

### OpenAPI/Swagger Configuration

```csharp
// ✅ Comprehensive Swagger Configuration
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddSwaggerGen(options =>
        {
            options.SwaggerDoc("v1", new OpenApiInfo
            {
                Title = "E-Commerce API",
                Version = "v1",
                Description = "Comprehensive e-commerce API with product management, order processing, and customer management",
                Contact = new OpenApiContact
                {
                    Name = "API Support",
                    Email = "api-support@company.com",
                    Url = new Uri("https://company.com/support")
                },
                License = new OpenApiLicense
                {
                    Name = "MIT License",
                    Url = new Uri("https://opensource.org/licenses/MIT")
                }
            });
            
            options.SwaggerDoc("v2", new OpenApiInfo
            {
                Title = "E-Commerce API",
                Version = "v2",
                Description = "Enhanced e-commerce API with advanced features"
            });
            
            // Add JWT authentication
            options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Description = "JWT Authorization header using the Bearer scheme",
                Name = "Authorization",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.ApiKey,
                Scheme = "Bearer"
            });
            
            options.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "Bearer"
                        }
                    },
                    Array.Empty<string>()
                }
            });
            
            // Include XML comments
            var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
            var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
            options.IncludeXmlComments(xmlPath);
            
            // Custom schema mappings
            options.MapType<decimal>(() => new OpenApiSchema
            {
                Type = "number",
                Format = "decimal"
            });
        });
    }
}

// ✅ Rich API Documentation
/// <summary>
/// Creates a new product in the catalog
/// </summary>
/// <param name="request">Product creation details</param>
/// <returns>The created product</returns>
/// <response code="201">Product created successfully</response>
/// <response code="400">Invalid request data</response>
/// <response code="409">Product with same SKU already exists</response>
[HttpPost]
[ProducesResponseType(typeof(ProductDto), StatusCodes.Status201Created)]
[ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
[ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status409Conflict)]
public async Task<ActionResult<ProductDto>> CreateProduct(
    /// <summary>Product details for creation</summary>
    [FromBody] CreateProductRequest request)
{
    // Implementation
}
```

### API Testing Strategies

```csharp
// ✅ Integration Tests
[Collection("WebApplicationFactory")]
public class ProductsControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;
    
    public ProductsControllerTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }
    
    [Fact]
    public async Task GetProducts_ReturnsSuccessAndCorrectContentType()
    {
        // Arrange
        var request = "/api/v1/products";
        
        // Act
        var response = await _client.GetAsync(request);
        
        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal("application/json; charset=utf-8", 
            response.Content.Headers.ContentType?.ToString());
    }
    
    [Fact]
    public async Task CreateProduct_WithValidData_ReturnsCreated()
    {
        // Arrange
        var product = new CreateProductRequest
        {
            Name = "Test Product",
            Description = "Test Description",
            Price = 99.99m,
            CategoryId = "electronics"
        };
        
        var json = JsonSerializer.Serialize(product);
        var content = new StringContent(json, Encoding.UTF8, "application/json");
        
        // Act
        var response = await _client.PostAsync("/api/v1/products", content);
        
        // Assert
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        
        var responseContent = await response.Content.ReadAsStringAsync();
        var createdProduct = JsonSerializer.Deserialize<ProductDto>(responseContent);
        
        Assert.NotNull(createdProduct);
        Assert.Equal(product.Name, createdProduct.Name);
    }
    
    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData(null)]
    public async Task CreateProduct_WithInvalidName_ReturnsBadRequest(string invalidName)
    {
        // Arrange
        var product = new CreateProductRequest
        {
            Name = invalidName,
            Description = "Test Description",
            Price = 99.99m
        };
        
        var json = JsonSerializer.Serialize(product);
        var content = new StringContent(json, Encoding.UTF8, "application/json");
        
        // Act
        var response = await _client.PostAsync("/api/v1/products", content);
        
        // Assert
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}

// ✅ Contract Testing with Pact
public class ProductConsumerPactTests : IClassFixture<PactFixture>
{
    private readonly PactBuilder _pactBuilder;
    
    public ProductConsumerPactTests(PactFixture fixture)
    {
        _pactBuilder = fixture.PactBuilder;
    }
    
    [Fact]
    public async Task GetProduct_WhenProductExists_ReturnsProduct()
    {
        // Arrange
        var productId = Guid.NewGuid();
        
        _pactBuilder
            .UponReceiving("A request for an existing product")
            .Given($"Product {productId} exists")
            .WithRequest(HttpMethod.Get, $"/api/v1/products/{productId}")
            .WithHeaders(new Dictionary<string, object>
            {
                ["Accept"] = "application/json"
            })
            .WillRespondWith()
            .WithStatus(HttpStatusCode.OK)
            .WithHeaders(new Dictionary<string, object>
            {
                ["Content-Type"] = "application/json"
            })
            .WithJsonBody(new
            {
                id = productId,
                name = "Test Product",
                price = 99.99
            });
        
        // Act & Assert
        await _pactBuilder.VerifyAsync(async ctx =>
        {
            var client = new HttpClient { BaseAddress = ctx.MockServerUri };
            var response = await client.GetAsync($"/api/v1/products/{productId}");
            
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        });
    }
}
```

---

## ⚡ Performance and Optimization {#performance}

### Caching Strategies

```csharp
// ✅ Multi-Level Caching Implementation
[ApiController]
[Route("api/v1/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly IMemoryCache _memoryCache;
    private readonly IDistributedCache _distributedCache;
    
    // Memory cache for frequently accessed data
    [HttpGet("{id:guid}")]
    [ResponseCache(Duration = 300, VaryByQueryKeys = new[] { "id" })]
    public async Task<ActionResult<ProductDto>> GetProduct(Guid id)
    {
        var cacheKey = $"product:{id}";
        
        // Try memory cache first
        if (_memoryCache.TryGetValue(cacheKey, out ProductDto? cachedProduct))
        {
            return Ok(cachedProduct);
        }
        
        // Try distributed cache
        var distributedCacheValue = await _distributedCache.GetStringAsync(cacheKey);
        if (!string.IsNullOrEmpty(distributedCacheValue))
        {
            var product = JsonSerializer.Deserialize<ProductDto>(distributedCacheValue);
            
            // Store in memory cache for faster subsequent access
            _memoryCache.Set(cacheKey, product, TimeSpan.FromMinutes(5));
            
            return Ok(product);
        }
        
        // Fetch from database
        var dbProduct = await _productService.GetProductByIdAsync(id);
        if (dbProduct == null)
            return NotFound();
        
        // Cache in both levels
        var json = JsonSerializer.Serialize(dbProduct);
        await _distributedCache.SetStringAsync(cacheKey, json, new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1)
        });
        
        _memoryCache.Set(cacheKey, dbProduct, TimeSpan.FromMinutes(5));
        
        return Ok(dbProduct);
    }
}

// ✅ Cache Invalidation
public class ProductService : IProductService
{
    private readonly IProductRepository _repository;
    private readonly IMemoryCache _memoryCache;
    private readonly IDistributedCache _distributedCache;
    
    public async Task<ProductDto> UpdateProductAsync(Guid id, UpdateProductRequest request)
    {
        var product = await _repository.UpdateAsync(id, request);
        
        // Invalidate caches
        var cacheKey = $"product:{id}";
        _memoryCache.Remove(cacheKey);
        await _distributedCache.RemoveAsync(cacheKey);
        
        // Invalidate related caches
        await InvalidateProductListCaches(product.CategoryId);
        
        return product;
    }
    
    private async Task InvalidateProductListCaches(string categoryId)
    {
        // Invalidate category-specific product lists
        var categoryKey = $"products:category:{categoryId}";
        _memoryCache.Remove(categoryKey);
        await _distributedCache.RemoveAsync(categoryKey);
        
        // Could use cache tagging for more sophisticated invalidation
    }
}
```

### Pagination and Filtering

```csharp
// ✅ Efficient Pagination Implementation
public class PagedResult<T>
{
    public IEnumerable<T> Data { get; set; }
    public PaginationMetadata Pagination { get; set; }
}

public class PaginationMetadata
{
    public int CurrentPage { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
    public int TotalPages { get; set; }
    public bool HasPrevious { get; set; }
    public bool HasNext { get; set; }
    public string? PreviousPageUrl { get; set; }
    public string? NextPageUrl { get; set; }
}

[HttpGet]
public async Task<ActionResult<PagedResult<ProductDto>>> GetProducts(
    [FromQuery] ProductQueryParams queryParams)
{
    // Validate pagination parameters
    if (queryParams.Page < 1)
        queryParams.Page = 1;
    
    if (queryParams.PageSize < 1 || queryParams.PageSize > 100)
        queryParams.PageSize = 10;
    
    var result = await _productService.GetProductsAsync(queryParams);
    
    // Add pagination links
    var baseUrl = $"{Request.Scheme}://{Request.Host}{Request.Path}";
    result.Pagination.PreviousPageUrl = result.Pagination.HasPrevious
        ? $"{baseUrl}?page={queryParams.Page - 1}&pageSize={queryParams.PageSize}"
        : null;
    
    result.Pagination.NextPageUrl = result.Pagination.HasNext
        ? $"{baseUrl}?page={queryParams.Page + 1}&pageSize={queryParams.PageSize}"
        : null;
    
    return Ok(result);
}

// ✅ Repository with efficient querying
public class ProductRepository : IProductRepository
{
    private readonly ApplicationDbContext _context;
    
    public async Task<PagedResult<Product>> GetProductsAsync(ProductQueryParams queryParams)
    {
        var query = _context.Products.AsQueryable();
        
        // Apply filters
        if (!string.IsNullOrEmpty(queryParams.Category))
        {
            query = query.Where(p => p.CategoryId == queryParams.Category);
        }
        
        if (!string.IsNullOrEmpty(queryParams.SearchTerm))
        {
            query = query.Where(p => p.Name.Contains(queryParams.SearchTerm) ||
                                   p.Description.Contains(queryParams.SearchTerm));
        }
        
        if (queryParams.MinPrice.HasValue)
        {
            query = query.Where(p => p.Price >= queryParams.MinPrice.Value);
        }
        
        if (queryParams.MaxPrice.HasValue)
        {
            query = query.Where(p => p.Price <= queryParams.MaxPrice.Value);
        }
        
        // Apply sorting
        query = queryParams.SortBy?.ToLower() switch
        {
            "name" => queryParams.SortDirection == "desc" 
                ? query.OrderByDescending(p => p.Name)
                : query.OrderBy(p => p.Name),
            "price" => queryParams.SortDirection == "desc"
                ? query.OrderByDescending(p => p.Price)
                : query.OrderBy(p => p.Price),
            "createdat" => queryParams.SortDirection == "desc"
                ? query.OrderByDescending(p => p.CreatedAt)
                : query.OrderBy(p => p.CreatedAt),
            _ => query.OrderBy(p => p.Name)
        };
        
        // Get total count before pagination
        var totalCount = await query.CountAsync();
        
        // Apply pagination
        var items = await query
            .Skip((queryParams.Page - 1) * queryParams.PageSize)
            .Take(queryParams.PageSize)
            .ToListAsync();
        
        return new PagedResult<Product>
        {
            Data = items,
            Pagination = new PaginationMetadata
            {
                CurrentPage = queryParams.Page,
                PageSize = queryParams.PageSize,
                TotalCount = totalCount,
                TotalPages = (int)Math.Ceiling(totalCount / (double)queryParams.PageSize),
                HasPrevious = queryParams.Page > 1,
                HasNext = queryParams.Page * queryParams.PageSize < totalCount
            }
        };
    }
}
```

---

## 🌐 API Gateway Patterns {#api-gateway}

### Gateway Implementation

```csharp
// ✅ API Gateway with Ocelot
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddOcelot()
            .AddEureka()
            .AddPolly();
        
        services.AddAuthentication("Bearer")
            .AddJwtBearer("Bearer", options =>
            {
                options.Authority = Configuration["Auth:Authority"];
                options.RequireHttpsMetadata = true;
                options.Audience = "api-gateway";
            });
        
        services.AddAuthorization();
        
        // Rate limiting
        services.Configure<IpRateLimitOptions>(Configuration.GetSection("IpRateLimit"));
        services.AddSingleton<IIpPolicyStore, MemoryCacheIpPolicyStore>();
        services.AddSingleton<IRateLimitCounterStore, MemoryCacheRateLimitCounterStore>();
        services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();
    }
    
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }
        
        app.UseIpRateLimiting();
        app.UseAuthentication();
        app.UseAuthorization();
        
        // Custom middleware for request/response logging
        app.UseMiddleware<ApiGatewayLoggingMiddleware>();
        
        app.UseOcelot().Wait();
    }
}

// ocelot.json configuration
/*
{
  "Routes": [
    {
      "DownstreamPathTemplate": "/api/v1/products/{everything}",
      "DownstreamScheme": "https",
      "DownstreamHostAndPorts": [
        {
          "Host": "product-service",
          "Port": 80
        }
      ],
      "UpstreamPathTemplate": "/api/v1/products/{everything}",
      "UpstreamHttpMethod": [ "GET", "POST", "PUT", "DELETE" ],
      "AuthenticationOptions": {
        "AuthenticationProviderKey": "Bearer"
      },
      "RateLimitOptions": {
        "ClientWhitelist": [],
        "EnableRateLimiting": true,
        "Period": "1m",
        "PeriodTimespan": 60,
        "Limit": 100
      },
      "LoadBalancerOptions": {
        "Type": "RoundRobin"
      },
      "QoSOptions": {
        "ExceptionsAllowedBeforeBreaking": 3,
        "DurationOfBreak": 5000,
        "TimeoutValue": 30000
      }
    }
  ],
  "GlobalConfiguration": {
    "BaseUrl": "https://api-gateway.company.com"
  }
}
*/

// ✅ Custom Gateway Middleware
public class ApiGatewayLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ApiGatewayLoggingMiddleware> _logger;
    
    public ApiGatewayLoggingMiddleware(RequestDelegate next, ILogger<ApiGatewayLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var correlationId = Guid.NewGuid().ToString();
        
        // Add correlation ID to response headers
        context.Response.Headers.Add("X-Correlation-ID", correlationId);
        
        // Log request
        _logger.LogInformation("Gateway Request: {Method} {Path} - CorrelationId: {CorrelationId}",
            context.Request.Method,
            context.Request.Path,
            correlationId);
        
        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            
            _logger.LogInformation("Gateway Response: {StatusCode} in {ElapsedMs}ms - CorrelationId: {CorrelationId}",
                context.Response.StatusCode,
                stopwatch.ElapsedMilliseconds,
                correlationId);
        }
    }
}
```

---

## 🔗 Related Topics

### Prerequisites

- [Clean Architecture Fundamentals](./01_Clean-Architecture-Fundamentals.md)
- [SOLID Principles](./07_SOLID-Principles.md)
- [Microservices Architecture](./05_Microservices-Architecture.md)

### Builds Upon

- HTTP protocol fundamentals
- Authentication and authorization principles
- Database design and querying

### Enables

- API Gateway implementation patterns
- Distributed system communication
- Service mesh architecture
- Event-driven microservices

### Cross-References

- **Security**: Authentication patterns, authorization strategies
- **Performance**: Caching, pagination, rate limiting
- **Testing**: API testing strategies, contract testing
- **Documentation**: OpenAPI specifications, API documentation tools

---

## 📚 Summary

Effective API design is crucial for building maintainable, scalable systems. Key principles include:

1. **Design-First Approach**: Define contracts before implementation
2. **Consistency**: Uniform patterns across all endpoints
3. **Security**: Comprehensive authentication and authorization
4. **Versioning**: Plan for evolution and backward compatibility
5. **Documentation**: Clear, comprehensive, and up-to-date
6. **Performance**: Efficient data transfer and caching strategies

**REST vs GraphQL Decision Matrix**:

- **Choose REST** for: Simple CRUD operations, caching requirements, team familiarity
- **Choose GraphQL** for: Complex queries, multiple clients, real-time requirements

**Next Steps**: Explore advanced topics like API Gateway patterns, rate limiting, and service mesh communication.
