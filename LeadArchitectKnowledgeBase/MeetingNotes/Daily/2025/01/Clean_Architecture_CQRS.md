# **Clean Architecture with CQRS, MediatR, and Filtering: A Comprehensive Guide**

This guide provides detailed best practices for implementing queries and filtering in a C# API using **Clean Architecture**, **CQRS** (Command Query Responsibility Segregation), and **MediatR**. It emphasizes maintainability, scalability, and testability.

---

## **1. Clean Architecture Overview**

### **1.1 Key Principles**

1. **Separation of Concerns:**
   - Ensure that each layer (Presentation, Application, Domain, Infrastructure) has distinct responsibilities.
2. **Independence:**
   - Each layer is independent of the others, ensuring easy testing, portability, and adaptability.
3. **Dependency Inversion:**
   - High-level modules (Application, Domain) should not depend on low-level modules (Infrastructure). Both should depend on abstractions.

### **1.2 Layer Responsibilities**

- **Presentation Layer (Controller):**

  - Handles HTTP requests, validates input, and maps requests to queries or commands.
  - Returns HTTP responses with appropriate status codes.

- **Application Layer:**

  - Implements use cases (business-specific logic).
  - Contains CQRS handlers for processing queries and commands.
  - Maps domain entities to DTOs.

- **Domain Layer:**

  - Defines core business rules and logic.
  - Contains entities, value objects, aggregates, and repository interfaces.

- **Infrastructure Layer:**
  - Implements external dependencies (databases, APIs, queues, file systems).
  - Contains concrete implementations of repository interfaces.

---

## **2. Query Handling with MediatR**

### **2.1 Define the Query**

- Create a query object that implements `IRequest<TResponse>`.

**Example Query:**

```csharp
public class GetProductsQuery : IRequest<List<ProductDto>>
{
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public string Category { get; set; }
}
```

### **2.2 Create a Query Handler**

- Implement `IRequestHandler<TRequest, TResponse>` to handle the query.

**Example Handler:**

```csharp
public class GetProductsQueryHandler : IRequestHandler<GetProductsQuery, List<ProductDto>>
{
    private readonly IProductRepository _productRepository;
    private readonly IMapper _mapper;

    public GetProductsQueryHandler(IProductRepository productRepository, IMapper mapper)
    {
        _productRepository = productRepository;
        _mapper = mapper;
    }

    public async Task<List<ProductDto>> Handle(GetProductsQuery request, CancellationToken cancellationToken)
    {
        var filter = new ProductFilter
        {
            MinPrice = request.MinPrice,
            MaxPrice = request.MaxPrice,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            Category = request.Category
        };

        var products = await _productRepository.GetProductsAsync(filter);
        return _mapper.Map<List<ProductDto>>(products);
    }
}
```

---

## **3. Filtering Strategies**

### **3.1 Filter Object Design**

- Filters encapsulate filtering logic and are located in the **Domain Layer**.

**Example Filter Object:**

```csharp
namespace MyProject.Domain.Filters
{
    public class ProductFilter
    {
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string Category { get; set; }
    }
}
```

### **3.2 Repository Filtering**

- Accept filter objects in repository methods.

**Repository Interface:**

```csharp
public interface IProductRepository
{
    Task<List<Product>> GetProductsAsync(ProductFilter filter);
}
```

### **3.3 Using Specification Pattern**

- Use specifications for advanced filtering and composable criteria.

**Specification Example:**

```csharp
public class ProductByPriceSpecification : Specification<Product>
{
    public ProductByPriceSpecification(decimal minPrice, decimal maxPrice)
    {
        Criteria = product => product.Price >= minPrice && product.Price <= maxPrice;
    }
}
```

---

## **4. Refactoring `if/else` in Controllers**

### **4.1 Using Enums for Query Types**

- Add a `FilterType` to encapsulate logic for different query cases.

**Setting `FilterType` Example:**

```csharp
query.FilterType = query.MinPrice.HasValue && query.MaxPrice.HasValue
    ? GetProductsQuery.ProductFilterType.PriceRange
    : query.StartDate.HasValue && query.EndDate.HasValue
        ? GetProductsQuery.ProductFilterType.DateRange
        : !string.IsNullOrEmpty(query.Category)
            ? GetProductsQuery.ProductFilterType.Category
            : GetProductsQuery.ProductFilterType.None;
```

---

## **5. Testing**

- **Unit Tests:**
  - Test query handlers using mocked repositories.
  - Validate that the correct data is fetched based on filters.
- **Integration Tests:**
  - Test end-to-end functionality of the query, ensuring filters are applied correctly.
- **Pipeline Behavior Tests:**
  - Validate that behaviors like logging, validation, and authorization execute correctly.

**Example Test for Query Handler:**

```csharp
[Fact]
public async Task Handle_ShouldReturnFilteredProducts()
{
    // Arrange
    var filter = new ProductFilter { MinPrice = 10, MaxPrice = 50 };
    var expectedProducts = new List<Product> { new Product { Name = "Test" } };
    _mockRepository.Setup(r => r.GetProductsAsync(filter)).ReturnsAsync(expectedProducts);

    var handler = new GetProductsQueryHandler(_mockRepository.Object, _mapper);

    // Act
    var result = await handler.Handle(new GetProductsQuery { MinPrice = 10, MaxPrice = 50 }, CancellationToken.None);

    // Assert
    result.Should().HaveCount(1);
    result[0].Name.Should().Be("Test");
}
```

---

## **6. Error Handling**

### **6.1 Centralized Exception Handling**

- Use middleware to handle exceptions globally.

**Middleware Example:**

```csharp
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;

    public ExceptionHandlingMiddleware(RequestDelegate next)
    {
        _next = next;
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

    private Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

        return context.Response.WriteAsync(JsonConvert.SerializeObject(new
        {
            StatusCode = context.Response.StatusCode,
            Message = "An unexpected error occurred."
        }));
    }
}
```

---

## **7. Further Improvements**

- **Logging and Observability:**
  - Use logging libraries (e.g., Serilog) and telemetry platforms (e.g., OpenTelemetry, Application Insights) for tracing requests.
- **Advanced Filtering:**
  - Introduce LINQ expression builders or Specification Evaluators for dynamic query generation.
- **Performance Optimization:**
  - Leverage caching (e.g., Redis) for frequently queried results.
  - Use database indexing for common filter fields.
- **Validation:**
  - Add input validation with FluentValidation.
- **Localization:**
  - Support multi-language error messages for global applications.

---

This final version addresses all suggestions and ensures a robust, scalable, and maintainable architecture. Let me know if further refinements are needed!

---

This enhanced and expanded version of the guide is fantastic! It incorporates all the feedback and best practices, resulting in a comprehensive and informative resource. Here are some additional thoughts:

**Strengths:**

- **Clear Structure:** The guide maintains a logical flow, making it easy to follow.
- **Detailed Explanations:** Each section provides comprehensive explanations with relevant examples.
- **Emphasis on Testability:** The guide highlights the importance of testing with relevant test cases.
- **Error Handling:** The inclusion of a centralized exception handling approach adds robustness.
- **Further Improvements:** The guide outlines additional considerations for optimizing performance, filtering, and user experience.

**Possible Refinements:**

- **Example Code Formatting:** Consider using code formatting tools for a more consistent and readable code style.
- **Logging Libraries:** Specify examples of common logging libraries like Serilog or NLog.
- **Caching Strategies:** Briefly touch upon different caching strategies (in-memory, distributed) and their suitability.
- **Validation Integration:** Provide an example of integrating a validation library like FluentValidation.

Overall, this enhanced guide provides a valuable resource for developers looking to implement robust filtering and querying mechanisms in their C# applications using Clean Architecture, CQRS, and MediatR.

Do you have any other questions or topics you'd like to explore further related to Clean Architecture, CQRS, MediatR, or filtering techniques?

---

## Version 2

Okay, I understand. You want the following structure:

- A single `ProductsRequest` object.
- One controller action method.
- Separate, strongly-typed query objects (`ProductsQueryByPrice`, `ProductsQueryByDate`, etc.).
- A pipeline behavior to select the correct _handler_.
- A repository with separate methods for each query type.

This is a good approach that combines the benefits of strong typing with a clean separation of concerns. Here's the implementation:

**1. ProductsRequest (Used by the Controller):**

```csharp
public class ProductsRequest : IRequest<List<ProductDto>>
{
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public string Category { get; set; }
}
```

**2. Separate Query Objects:**

```csharp
public class ProductsQueryByPrice : IRequest<List<ProductDto>>
{
    public decimal MinPrice { get; set; } // Non-nullable here
    public decimal MaxPrice { get; set; } // Non-nullable here
}

public class ProductsQueryByDate : IRequest<List<ProductDto>>
{
    public DateTime StartDate { get; set; } // Non-nullable here
    public DateTime EndDate { get; set; } // Non-nullable here
}

public class ProductsQueryByCategory : IRequest<List<ProductDto>>
{
    public string Category { get; set; }
}

public class GetAllProductsQuery : IRequest<List<ProductDto>> { } // For no filters
```

**3. Separate Query Handlers:**

```csharp
public class ProductsQueryByPriceHandler : IRequestHandler<ProductsQueryByPrice, List<ProductDto>>
{
    private readonly IProductRepository _repository;
    private readonly IMapper _mapper;

    public ProductsQueryByPriceHandler(IProductRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper = mapper;
    }

    public async Task<List<ProductDto>> Handle(ProductsQueryByPrice request, CancellationToken cancellationToken)
    {
        var products = await _repository.GetProductsByPrice(request.MinPrice, request.MaxPrice);
        return _mapper.Map<List<ProductDto>>(products);
    }
}

// Similar handlers for ProductsQueryByDate and ProductsQueryByCategory
public class ProductsQueryByDateHandler : IRequestHandler<ProductsQueryByDate, List<ProductDto>>
{
    private readonly IProductRepository _repository;
    private readonly IMapper _mapper;

    public ProductsQueryByDateHandler(IProductRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper = mapper;
    }

    public async Task<List<ProductDto>> Handle(ProductsQueryByDate request, CancellationToken cancellationToken)
    {
        var products = await _repository.GetProductsByDate(request.StartDate, request.EndDate);
        return _mapper.Map<List<ProductDto>>(products);
    }
}
public class ProductsQueryByCategoryHandler : IRequestHandler<ProductsQueryByCategory, List<ProductDto>>
{
    private readonly IProductRepository _repository;
    private readonly IMapper _mapper;

    public ProductsQueryByCategoryHandler(IProductRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper = mapper;
    }

    public async Task<List<ProductDto>> Handle(ProductsQueryByCategory request, CancellationToken cancellationToken)
    {
        var products = await _repository.GetProductsByCategory(request.Category);
        return _mapper.Map<List<ProductDto>>(products);
    }
}

public class GetAllProductsQueryHandler : IRequestHandler<GetAllProductsQuery, List<ProductDto>>
{
    private readonly IProductRepository _repository;
    private readonly IMapper _mapper;

    public GetAllProductsQueryHandler(IProductRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper = mapper;
    }

    public async Task<List<ProductDto>> Handle(GetAllProductsQuery request, CancellationToken cancellationToken)
    {
        var products = await _repository.GetAllProducts();
        return _mapper.Map<List<ProductDto>>(products);
    }
}
```

**4. Repository Interface and Implementation:**

```csharp
public interface IProductRepository
{
    Task<List<Product>> GetProductsByPrice(decimal minPrice, decimal maxPrice);
    Task<List<Product>> GetProductsByDate(DateTime startDate, DateTime endDate);
    Task<List<Product>> GetProductsByCategory(string category);
    Task<List<Product>> GetAllProducts();
}

public class ProductsRepository : IProductRepository
{
    private readonly YourDbContext _context;

    public ProductsRepository(YourDbContext context)
    {
        _context = context;
    }

    public async Task<List<Product>> GetProductsByPrice(decimal minPrice, decimal maxPrice)
    {
        return await _context.Products.Where(p => p.Price >= minPrice && p.Price <= maxPrice).ToListAsync();
    }

    public async Task<List<Product>> GetProductsByDate(DateTime startDate, DateTime endDate)
    {
        // Date filtering logic
        return await _context.Products.Where(p => p.CreatedDate >= startDate && p.CreatedDate <= endDate).ToListAsync();//Example
    }

    public async Task<List<Product>> GetProductsByCategory(string category)
    {
        return await _context.Products.Where(p => p.Category == category).ToListAsync();
    }
    public async Task<List<Product>> GetAllProducts()
    {
        return await _context.Products.ToListAsync();
    }
}
```

**5. Pipeline Behavior (Selects Correct Query):**

```csharp
public class ProductQueryHandlerSelectorBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : ProductsRequest, IRequest<TResponse>
{
    private readonly IMediator _mediator;

    public ProductQueryHandlerSelectorBehavior(IMediator mediator)
    {
        _mediator = mediator;
    }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        IRequest<TResponse> queryToSend = null;

        if (request.MinPrice.HasValue && request.MaxPrice.HasValue)
        {
            queryToSend = new ProductsQueryByPrice
            {
                MinPrice = request.MinPrice.Value,
                MaxPrice = request.MaxPrice.Value
            };
        }
        else if (request.StartDate.HasValue && request.EndDate.HasValue)
        {
            queryToSend = new ProductsQueryByDate
            {
                StartDate = request.StartDate.Value,
                EndDate = request.EndDate.Value
            };
        }
        else if (!string.IsNullOrEmpty(request.Category))
        {
            queryToSend = new ProductsQueryByCategory { Category = request.Category };
        }
        else
        {
            queryToSend = new GetAllProductsQuery();
        }

        return await _mediator.Send(queryToSend, cancellationToken);
    }
}
```

**6. Controller:**

```csharp
[HttpPost]
public async Task<IActionResult> GetProducts([FromBody] ProductsRequest request)
{
    var products = await _mediator.Send<List<ProductDto>>(request);
    return Ok(products);
}
```

**7. Dependency Injection:**

```csharp
builder.Services.AddScoped<IProductRepository, ProductsRepository>();
builder.Services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ProductQueryHandlerSelectorBehavior<,>));
builder.Services.AddTransient<IRequestHandler<ProductsQueryByPrice, List<ProductDto>>, ProductsQueryByPriceHandler>();
builder.Services.AddTransient<IRequestHandler<ProductsQueryByDate, List<ProductDto>>, ProductsQueryByDateHandler>();
builder.Services.AddTransient<IRequestHandler<ProductsQueryByCategory, List<ProductDto>>, ProductsQueryByCategoryHandler>();
builder.Services.AddTransient<IRequestHandler<GetAllProductsQuery, List<ProductDto>>, GetAllProductsQueryHandler>();

builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(typeof(Program).Assembly));
```

**Key Improvements:**

- **Strongly Typed Queries:** You have separate, strongly-typed query objects, which improves type safety and code clarity.
- **Separate Handlers:** Each query type has its own dedicated handler, promoting the Single Responsibility Principle.
- **Separate Repository Methods:** The repository has specific methods for each query, which can lead to more optimized database queries.
- **Pipeline Behavior Orchestrates:** The pipeline behavior is responsible for selecting the correct query and sending it to MediatR, keeping the controller and handlers clean.

This is a very robust and well-structured approach that combines the best of both worlds: strong typing and a

---

## Version 3

Here’s the enhanced implementation with additional improvements for **Clean Architecture with CQRS, MediatR, and Filtering**. This version includes the following refinements:

1. **Validation** using `FluentValidation`.
2. **Pagination** support.
3. **Caching** for frequently requested queries.
4. **Error Handling** integration with a centralized middleware.
5. **Logging and Observability** improvements.

---

## **Enhanced Implementation**

### **1. Enhanced `ProductsRequest`**

Add optional pagination fields to support efficient data retrieval.

```csharp
public class ProductsRequest : IRequest<List<ProductDto>>
{
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public string Category { get; set; }
    public int PageNumber { get; set; } = 1; // Default page
    public int PageSize { get; set; } = 10;  // Default page size
}
```

---

### **2. Pagination Support in Repository**

Update repository methods to support pagination:

```csharp
public interface IProductRepository
{
    Task<List<Product>> GetProductsByPrice(decimal minPrice, decimal maxPrice, int pageNumber, int pageSize);
    Task<List<Product>> GetProductsByDate(DateTime startDate, DateTime endDate, int pageNumber, int pageSize);
    Task<List<Product>> GetProductsByCategory(string category, int pageNumber, int pageSize);
    Task<List<Product>> GetAllProducts(int pageNumber, int pageSize);
}
```

**Example Implementation (for `GetProductsByPrice`)**

```csharp
public async Task<List<Product>> GetProductsByPrice(decimal minPrice, decimal maxPrice, int pageNumber, int pageSize)
{
    return await _context.Products
        .Where(p => p.Price >= minPrice && p.Price <= maxPrice)
        .Skip((pageNumber - 1) * pageSize)
        .Take(pageSize)
        .ToListAsync();
}
```

---

### **3. Validation with FluentValidation**

Validate `ProductsRequest` using FluentValidation to ensure the input is correct.

```csharp
public class ProductsRequestValidator : AbstractValidator<ProductsRequest>
{
    public ProductsRequestValidator()
    {
        RuleFor(x => x.PageNumber).GreaterThanOrEqualTo(1);
        RuleFor(x => x.PageSize).InclusiveBetween(1, 100);
        RuleFor(x => x.MinPrice).GreaterThanOrEqualTo(0).When(x => x.MinPrice.HasValue);
        RuleFor(x => x.MaxPrice).GreaterThanOrEqualTo(0).When(x => x.MaxPrice.HasValue);
        RuleFor(x => x.StartDate).LessThanOrEqualTo(x => x.EndDate).When(x => x.StartDate.HasValue && x.EndDate.HasValue);
    }
}
```

Register FluentValidation in the DI container:

```csharp
builder.Services.AddValidatorsFromAssemblyContaining<ProductsRequestValidator>();
```

---

### **4. Caching with In-Memory Cache**

Use caching to reduce database load for frequently queried results.

#### **Caching Setup**

Add caching in the `ProductsQueryByCategoryHandler` as an example:

```csharp
public class ProductsQueryByCategoryHandler : IRequestHandler<ProductsQueryByCategory, List<ProductDto>>
{
    private readonly IProductRepository _repository;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;

    public ProductsQueryByCategoryHandler(IProductRepository repository, IMapper mapper, IMemoryCache cache)
    {
        _repository = repository;
        _mapper = mapper;
        _cache = cache;
    }

    public async Task<List<ProductDto>> Handle(ProductsQueryByCategory request, CancellationToken cancellationToken)
    {
        string cacheKey = $"ProductsByCategory_{request.Category}_{request.PageNumber}_{request.PageSize}";

        if (_cache.TryGetValue(cacheKey, out List<ProductDto> cachedProducts))
        {
            return cachedProducts;
        }

        var products = await _repository.GetProductsByCategory(request.Category, request.PageNumber, request.PageSize);
        var result = _mapper.Map<List<ProductDto>>(products);

        _cache.Set(cacheKey, result, TimeSpan.FromMinutes(10)); // Cache for 10 minutes

        return result;
    }
}
```

Register `IMemoryCache` in the DI container:

```csharp
builder.Services.AddMemoryCache();
```

---

### **5. Enhanced Error Handling**

Centralize error handling using middleware:

```csharp
public class ErrorHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ErrorHandlingMiddleware> _logger;

    public ErrorHandlingMiddleware(RequestDelegate next, ILogger<ErrorHandlingMiddleware> logger)
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
            _logger.LogError(ex, "An unexpected error occurred.");
            await HandleExceptionAsync(context, ex);
        }
    }

    private Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

        return context.Response.WriteAsync(JsonConvert.SerializeObject(new
        {
            StatusCode = context.Response.StatusCode,
            Message = "An unexpected error occurred. Please try again later."
        }));
    }
}
```

Register the middleware:

```csharp
app.UseMiddleware<ErrorHandlingMiddleware>();
```

---

### **6. Logging with Serilog**

Add structured logging using Serilog for better observability.

#### **Setup**

Install Serilog packages:

```bash
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Settings.Configuration
dotnet add package Serilog.Sinks.Console
```

Configure Serilog in `Program.cs`:

```csharp
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .Enrich.FromLogContext()
    .ReadFrom.Configuration(builder.Configuration)
    .CreateLogger();

builder.Host.UseSerilog();
```

---

### **7. Controller Action**

The controller action remains unchanged but now includes validation.

```csharp
[HttpPost]
public async Task<IActionResult> GetProducts([FromBody] ProductsRequest request)
{
    var validationResult = await _validator.ValidateAsync(request);

    if (!validationResult.IsValid)
    {
        return BadRequest(validationResult.Errors);
    }

    var products = await _mediator.Send<List<ProductDto>>(request);
    return Ok(products);
}
```

---

### **8. Summary of Enhancements**

1. **Validation:**

   - Added FluentValidation to validate `ProductsRequest`.

2. **Pagination:**

   - Integrated `PageNumber` and `PageSize` for efficient data retrieval.

3. **Caching:**

   - Added in-memory caching for frequently queried results.

4. **Error Handling:**

   - Centralized exception handling using middleware.

5. **Logging:**

   - Integrated Serilog for structured logging.

6. **Performance Optimization:**
   - Used database pagination and caching to reduce query overhead.

This enhanced implementation improves maintainability, performance, and reliability while ensuring a seamless developer and end-user experience. Let me know if you'd like further refinements or additional features!
