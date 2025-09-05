# Clean Architecture with CQRS and MediatR: A Comprehensive Guide

*Last Updated: May 6, 2025*

This guide provides a comprehensive overview of implementing Clean Architecture with CQRS (Command Query Responsibility Segregation) and MediatR in .NET applications.

## Table of Contents

1. [Clean Architecture Overview](#clean-architecture-overview)
2. [CQRS Principles](#cqrs-principles)
3. [Implementation with MediatR](#implementation-with-mediatr)
4. [Filtering Strategies](#filtering-strategies)
5. [Repository Pattern](#repository-pattern)
6. [Testing Strategies](#testing-strategies)
7. [Best Practices](#best-practices)
8. [Sample Implementation](#sample-implementation)

## Clean Architecture Overview

### Key Principles

1. **Separation of Concerns:**
   - Each layer has distinct responsibilities
   - Presentation, Application, Domain, and Infrastructure layers are clearly defined

2. **Independence:**
   - Layers are independent of each other
   - Enables testing, portability, and adaptability

3. **Dependency Inversion:**
   - High-level modules (Application, Domain) don't depend on low-level modules (Infrastructure)
   - Both depend on abstractions

### Layer Responsibilities

- **Presentation Layer (Controller):**
  - Handles HTTP requests, validates input, maps requests to queries/commands
  - Returns HTTP responses with appropriate status codes
  - Contains no business logic

- **Application Layer:**
  - Implements use cases (business-specific logic)
  - Contains CQRS handlers for processing queries and commands
  - Maps domain entities to DTOs
  - Orchestrates workflow between multiple domain entities

- **Domain Layer:**
  - Defines core business rules and logic
  - Contains entities, value objects, aggregates, domain events, and repository interfaces
  - Is independent of external concerns

- **Infrastructure Layer:**
  - Implements external dependencies (databases, APIs, queues, file systems)
  - Contains concrete implementations of repository interfaces
  - Handles data access and external services

## CQRS Principles

CQRS (Command Query Responsibility Segregation) separates read and write operations:

- **Queries:** Retrieve data and return results without changing state
- **Commands:** Change state but don't return data

### Benefits of CQRS

- Separation of concerns
- Optimized read and write models
- Scalability (read and write sides can scale independently)
- Better handling of complex business logic

## Implementation with MediatR

MediatR is a popular .NET library that implements the mediator pattern, making CQRS implementation cleaner.

### Basic MediatR Setup

```csharp
// 1. Install MediatR packages
// dotnet add package MediatR
// dotnet add package MediatR.Extensions.Microsoft.DependencyInjection

// 2. Register MediatR in Program.cs or Startup.cs
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(typeof(Program).Assembly));
```

### Query Handling with MediatR

1. **Define the Query**

```csharp
// Query (Request)
public class GetProductsQuery : IRequest<List<ProductDto>>
{
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public string Category { get; set; }
    public int PageNumber { get; set; } = 1; // Default page
    public int PageSize { get; set; } = 10;  // Default page size
}

// DTO (Response)
public class ProductDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
}
```

2. **Create a Query Handler**

```csharp
public class GetProductsQueryHandler : IRequestHandler<GetProductsQuery, List<ProductDto>>
{
    private readonly IProductRepository _repository;
    private readonly IMapper _mapper;

    public GetProductsQueryHandler(IProductRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper = mapper;
    }

    public async Task<List<ProductDto>> Handle(GetProductsQuery request, CancellationToken cancellationToken)
    {
        var products = await _repository.GetProductsAsync(new ProductFilter 
        {
            MinPrice = request.MinPrice,
            MaxPrice = request.MaxPrice,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            Category = request.Category,
            PageNumber = request.PageNumber,
            PageSize = request.PageSize
        });
        
        return _mapper.Map<List<ProductDto>>(products);
    }
}
```

3. **Controller Implementation**

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ProductsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetProducts([FromQuery] GetProductsQuery query)
    {
        var products = await _mediator.Send(query);
        return Ok(products);
    }
}
```

## Filtering Strategies

### Filter Objects

Place filter objects in the Domain Layer under a "Filters" or "Criteria" folder:

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
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }
}
```

### Repository Methods

Accept filter objects as parameters in the repository interface:

```csharp
public interface IProductRepository
{
    Task<List<Product>> GetProductsAsync(ProductFilter filter);
    Task<Product> GetByIdAsync(int id);
    Task AddAsync(Product product);
    Task UpdateAsync(Product product);
    Task DeleteAsync(int id);
}
```

### Specification Pattern

For more complex filtering scenarios, consider using the Specification pattern:

```csharp
public abstract class Specification<T>
{
    public abstract Expression<Func<T, bool>> ToExpression();
    
    public bool IsSatisfiedBy(T entity)
    {
        Func<T, bool> predicate = ToExpression().Compile();
        return predicate(entity);
    }
}

public class ProductsByPriceRangeSpecification : Specification<Product>
{
    private readonly decimal _minPrice;
    private readonly decimal _maxPrice;

    public ProductsByPriceRangeSpecification(decimal minPrice, decimal maxPrice)
    {
        _minPrice = minPrice;
        _maxPrice = maxPrice;
    }

    public override Expression<Func<Product, bool>> ToExpression()
    {
        return product => product.Price >= _minPrice && product.Price <= _maxPrice;
    }
}
```

## Repository Pattern

### Mock Repository for Testing

```csharp
public class MockProductRepository : IProductRepository
{
    private readonly List<Product> _products;

    public MockProductRepository()
    {
        _products = new List<Product>
        {
            new Product { Id = 1, Name = "Mock Product 1", Price = 10.00m },
            new Product { Id = 2, Name = "Mock Product 2", Price = 20.00m },
            new Product { Id = 3, Name = "Mock Product 3", Price = 30.00m }
        };
    }

    public async Task<List<Product>> GetProductsAsync(ProductFilter filter)
    {
        IEnumerable<Product> query = _products;

        if (filter.MinPrice.HasValue && filter.MaxPrice.HasValue)
        {
            query = query.Where(p => p.Price >= filter.MinPrice.Value && p.Price <= filter.MaxPrice.Value);
        }

        if (filter.StartDate.HasValue && filter.EndDate.HasValue)
        {
            // Apply date filtering if your Product entity has relevant date properties
        }

        if (!string.IsNullOrEmpty(filter.Category))
        {
            // Apply category filtering if your Product entity has a Category property
        }

        // Apply pagination
        query = query.Skip((filter.PageNumber - 1) * filter.PageSize).Take(filter.PageSize);

        return await Task.FromResult(query.ToList());
    }

    public async Task<Product> GetByIdAsync(int id)
    {
        return await Task.FromResult(_products.FirstOrDefault(p => p.Id == id));
    }

    public async Task AddAsync(Product product)
    {
        product.Id = _products.Any() ? _products.Max(p => p.Id) + 1 : 1;
        _products.Add(product);
        await Task.CompletedTask;
    }

    public async Task UpdateAsync(Product product)
    {
        var existingProductIndex = _products.FindIndex(p => p.Id == product.Id);
        if (existingProductIndex >= 0)
        {
            _products[existingProductIndex] = product;
        }
        await Task.CompletedTask;
    }

    public async Task DeleteAsync(int id)
    {
        _products.RemoveAll(p => p.Id == id);
        await Task.CompletedTask;
    }
}
```

## Advanced Enhancements

### Pipeline Behaviors for Cross-Cutting Concerns

```csharp
public class LoggingBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly ILogger<LoggingBehavior<TRequest, TResponse>> _logger;

    public LoggingBehavior(ILogger<LoggingBehavior<TRequest, TResponse>> logger)
    {
        _logger = logger;
    }

    public async Task<TResponse> Handle(TRequest request, 
        RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        _logger.LogInformation($"Handling {typeof(TRequest).Name}");
        
        var response = await next();
        
        _logger.LogInformation($"Handled {typeof(TRequest).Name}");
        
        return response;
    }
}
```

### Validation with FluentValidation

```csharp
public class GetProductsQueryValidator : AbstractValidator<GetProductsQuery>
{
    public GetProductsQueryValidator()
    {
        RuleFor(q => q.PageNumber).GreaterThan(0);
        RuleFor(q => q.PageSize).GreaterThan(0).LessThanOrEqualTo(100);
        
        When(q => q.MinPrice.HasValue, () => {
            RuleFor(q => q.MinPrice.Value).GreaterThanOrEqualTo(0);
        });
        
        When(q => q.MaxPrice.HasValue, () => {
            RuleFor(q => q.MaxPrice.Value).GreaterThan(0);
        });
        
        When(q => q.MinPrice.HasValue && q.MaxPrice.HasValue, () => {
            RuleFor(q => q.MaxPrice.Value)
                .GreaterThanOrEqualTo(q => q.MinPrice.Value)
                .WithMessage("MaxPrice must be greater than or equal to MinPrice");
        });
    }
}
```

### Caching for Performance

```csharp
public class CachedProductsQueryHandler : IRequestHandler<GetProductsQuery, List<ProductDto>>
{
    private readonly IProductRepository _repository;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;

    public CachedProductsQueryHandler(
        IProductRepository repository, 
        IMapper mapper,
        IMemoryCache cache)
    {
        _repository = repository;
        _mapper = mapper;
        _cache = cache;
    }

    public async Task<List<ProductDto>> Handle(
        GetProductsQuery request, 
        CancellationToken cancellationToken)
    {
        string cacheKey = $"Products_{request.MinPrice}_{request.MaxPrice}_{request.Category}_{request.PageNumber}_{request.PageSize}";
        
        if (_cache.TryGetValue(cacheKey, out List<ProductDto> cachedProducts))
        {
            return cachedProducts;
        }
        
        var products = await _repository.GetProductsAsync(new ProductFilter
        {
            MinPrice = request.MinPrice,
            MaxPrice = request.MaxPrice,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            Category = request.Category,
            PageNumber = request.PageNumber,
            PageSize = request.PageSize
        });
        
        var result = _mapper.Map<List<ProductDto>>(products);
        
        _cache.Set(cacheKey, result, TimeSpan.FromMinutes(10));
        
        return result;
    }
}
```

## Best Practices

1. **Separation of Concerns:**
   - Keep each layer focused on its specific responsibility
   - Don't mix business logic with data access or presentation concerns

2. **Dependency Inversion Principle (DIP):**
   - Depend on abstractions (interfaces), not concretions
   - High-level modules should not depend on low-level modules

3. **DTOs for Data Transfer:**
   - Use DTOs to decouple layers and shape data as needed
   - Keep domain entities clean and focused on domain logic

4. **Testability:**
   - Write unit tests for handlers, behaviors, and repositories
   - Use mocks and stubs for external dependencies

5. **Error Handling:**
   - Implement robust error handling and validation
   - Use middleware for global exception handling

6. **Logging:**
   - Add appropriate logging for debugging and monitoring
   - Consider using structured logging

## Sample Implementation

Sample project repository: *(coming soon – legacy placeholder removed; real example will be linked once curated)*

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [MediatR Documentation](https://github.com/jbogard/MediatR/wiki)
- [CQRS Journey by Microsoft](https://learn.microsoft.com/en-us/previous-versions/msp-n-p/jj554200(v=pandp.10))

---

*This document consolidates various notes and learnings from January 2025 on Clean Architecture and CQRS implementation.*