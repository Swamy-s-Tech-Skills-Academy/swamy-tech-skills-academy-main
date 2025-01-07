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
