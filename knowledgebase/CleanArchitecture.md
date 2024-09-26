# Clean Architecture

Here's a detailed sample of a **Clean Architecture** solution for **C#** and **.NET 8**, including a **Shared Kernel**. Clean Architecture emphasizes the separation of concerns, so each layer has a clear purpose. The **Shared Kernel** is a set of common utilities or domain logic shared across multiple projects.

## **Solution Layout**

```text
Solution.sln
├── Solution.Core                // Domain Layer (Entities, Interfaces)
├── Solution.Application         // Application Layer (Services, Use Cases, DTOs)
├── Solution.Infrastructure      // Infrastructure Layer (Data Access, External APIs)
├── Solution.WebAPI              // Presentation Layer (Controllers, API)
└── Solution.SharedKernel        // Shared Kernel (Common utilities, Value Objects, etc.)
```

### **Overview of Layers**

1. **Core**: Contains domain entities and business rules. No dependencies on other layers.
2. **Application**: Use cases, services, and DTOs. This layer depends on the Core layer.
3. **Infrastructure**: Contains implementation details such as database access and external service integrations.
4. **WebAPI**: The presentation layer (e.g., ASP.NET Core Web API).
5. **SharedKernel**: Shared code (like Value Objects or Domain Events) used across multiple layers or projects.

---

## **Solution Structure in Detail**

### 1. **Solution.Core** (Domain Layer)

This is the heart of the system, containing domain entities, domain logic, and repository interfaces.

**Folder Structure**:

```text
Solution.Core/
  ├── Entities/
  ├── Interfaces/
  ├── Specifications/
  └── Common/
```

#### Sample Code

- **Entities/Account.cs**

  ```csharp
  namespace Solution.Core.Entities
  {
      public class Account
      {
          public int Id { get; private set; }
          public string Name { get; private set; }
          public decimal Balance { get; private set; }

          public Account(string name, decimal balance)
          {
              Name = name;
              Balance = balance;
          }

          public void Credit(decimal amount)
          {
              Balance += amount;
          }

          public void Debit(decimal amount)
          {
              if (amount > Balance) throw new InvalidOperationException("Insufficient funds");
              Balance -= amount;
          }
      }
  }
  ```

- **Interfaces/IRepository.cs**

  ```csharp
  namespace Solution.Core.Interfaces
  {
      public interface IRepository<T> where T : class
      {
          Task<T?> GetByIdAsync(int id);
          Task<IEnumerable<T>> ListAllAsync();
          Task AddAsync(T entity);
          Task UpdateAsync(T entity);
          Task DeleteAsync(T entity);
      }
  }
  ```

### 2. **Solution.Application** (Application Layer)

This layer contains the business logic, services, and DTOs. It defines use cases that orchestrate domain logic and interactions.

**Folder Structure**:

```text
Solution.Application/
  ├── Services/
  ├── UseCases/
  ├── DTOs/
  └── Interfaces/
```

#### Sample Code - Application Layer

- **DTOs/AccountDto.cs**

  ```csharp
  namespace Solution.Application.DTOs
  {
      public class AccountDto
      {
          public int Id { get; set; }
          public string Name { get; set; }
          public decimal Balance { get; set; }
      }
  }
  ```

- **Services/IAccountService.cs**

  ```csharp
  namespace Solution.Application.Services
  {
      public interface IAccountService
      {
          Task<AccountDto> GetAccountByIdAsync(int id);
          Task<IEnumerable<AccountDto>> GetAllAccountsAsync();
          Task CreateAccountAsync(AccountDto accountDto);
          Task UpdateAccountAsync(AccountDto accountDto);
      }
  }
  ```

- **UseCases/GetAccountByIdUseCase.cs**

  ```csharp
  namespace Solution.Application.UseCases
  {
      public class GetAccountByIdUseCase
      {
          private readonly IAccountService _accountService;

          public GetAccountByIdUseCase(IAccountService accountService)
          {
              _accountService = accountService;
          }

          public async Task<AccountDto> ExecuteAsync(int id)
          {
              return await _accountService.GetAccountByIdAsync(id);
          }
      }
  }
  ```

### 3. **Solution.Infrastructure** (Infrastructure Layer)

This layer implements the interfaces defined in the Core. It deals with database access, external APIs, etc.

**Folder Structure**:

```text
Solution.Infrastructure/
  ├── Data/
  ├── Repositories/
  └── ExternalServices/
```

#### Sample Code - Infrastructure Layer

- **Repositories/AccountRepository.cs**

  ```csharp
  using Solution.Core.Entities;
  using Solution.Core.Interfaces;

  namespace Solution.Infrastructure.Repositories
  {
      public class AccountRepository : IRepository<Account>
      {
          private readonly AppDbContext _context;

          public AccountRepository(AppDbContext context)
          {
              _context = context;
          }

          public async Task<Account?> GetByIdAsync(int id)
          {
              return await _context.Accounts.FindAsync(id);
          }

          public async Task<IEnumerable<Account>> ListAllAsync()
          {
              return await _context.Accounts.ToListAsync();
          }

          public async Task AddAsync(Account account)
          {
              await _context.Accounts.AddAsync(account);
              await _context.SaveChangesAsync();
          }

          public async Task UpdateAsync(Account account)
          {
              _context.Accounts.Update(account);
              await _context.SaveChangesAsync();
          }

          public async Task DeleteAsync(Account account)
          {
              _context.Accounts.Remove(account);
              await _context.SaveChangesAsync();
          }
      }
  }
  ```

### 4. **Solution.WebAPI** (Presentation Layer)

This is the entry point for users, exposing the API or UI. It interacts with the application layer and forwards requests to use cases.

**Folder Structure**:

```text
Solution.WebAPI/
  ├── Controllers/
  └── Startup.cs (or Program.cs in .NET 8)
```

#### Sample Code - Presentation Layer

- **Controllers/AccountController.cs**

  ```csharp
  using Microsoft.AspNetCore.Mvc;
  using Solution.Application.UseCases;

  namespace Solution.WebAPI.Controllers
  {
      [ApiController]
      [Route("api/[controller]")]
      public class AccountController : ControllerBase
      {
          private readonly GetAccountByIdUseCase _getAccountByIdUseCase;

          public AccountController(GetAccountByIdUseCase getAccountByIdUseCase)
          {
              _getAccountByIdUseCase = getAccountByIdUseCase;
          }

          [HttpGet("{id}")]
          public async Task<IActionResult> GetById(int id)
          {
              var account = await _getAccountByIdUseCase.ExecuteAsync(id);
              if (account == null) return NotFound();
              return Ok(account);
          }
      }
  }
  ```

### 5. **Solution.SharedKernel** (Shared Kernel)

The Shared Kernel is a set of commonly used utilities, such as value objects, domain events, or common validation logic. This project can be referenced by other projects like `Core` and `Application`.

**Folder Structure**:

```text
Solution.SharedKernel/
  ├── ValueObjects/
  ├── DomainEvents/
  └── Common/
```

#### Sample Code - Shared Kernel

- **ValueObjects/Money.cs** (Example of a Value Object)

  ```csharp
  namespace Solution.SharedKernel.ValueObjects
  {
      public class Money
      {
          public decimal Amount { get; }
          public string Currency { get; }

          public Money(decimal amount, string currency)
          {
              Amount = amount;
              Currency = currency;
          }

          public static Money operator +(Money a, Money b)
          {
              if (a.Currency != b.Currency)
                  throw new InvalidOperationException("Cannot add money in different currencies");

              return new Money(a.Amount + b.Amount, a.Currency);
          }
      }
  }
  ```

---

### **Project References**

To maintain Clean Architecture, ensure the following references:

1. `Solution.Application` references `Solution.Core` and `Solution.SharedKernel`.
2. `Solution.Infrastructure` references `Solution.Core`, `Solution.Application`, and `Solution.SharedKernel`.
3. `Solution.WebAPI` references `Solution.Application` and optionally `Solution.Infrastructure`.
4. `Solution.SharedKernel` should not reference any project but can be referenced by all.

### **Dependency Injection Setup in WebAPI**

In your `Program.cs` (or `Startup.cs`):

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Add application and infrastructure layers
builder.Services.AddScoped<IRepository<Account>, AccountRepository>();
builder.Services.AddScoped<IAccountService, AccountService>();
builder.Services.AddScoped<GetAccountByIdUseCase>();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
```

### **Conclusion**

This Clean Architecture structure is modular, scalable, and adheres to the principles of separation of concerns. The **Shared Kernel** ensures that common logic (like Value Objects, Domain Events) is reusable across projects. This pattern promotes maintainability and flexibility as your project grows.

---

In the **Clean Architecture** solution structure we discussed, the **Strategy Pattern** code fits within the **Application Layer** (Solution.Application) and **Infrastructure Layer** (Solution.Infrastructure). Here’s how it aligns with the architecture:

### **Placement of Strategy Pattern Components**

1. **Strategy Interface**: The interface for the strategy will sit in the **Application Layer** (`Solution.Application`). This is because the **Application Layer** defines business rules, use cases, and interactions that depend on abstractions, not implementations.

2. **Concrete Strategy Implementations**: The concrete implementations of the strategy (e.g., for Azure SQL and Web API) will reside in the **Infrastructure Layer** (`Solution.Infrastructure`), since they are implementation details, such as interacting with a database or external API.

3. **Strategy Context / Service Layer**: The **Service Layer** that orchestrates which strategy to use (based on configuration or other conditions) will reside in the **Application Layer**. This ensures that the business logic is decoupled from how the data is retrieved or stored.

### Updated Solution Layout

```
Solution.sln
├── Solution.Core                // Domain Layer (Entities, Interfaces)
├── Solution.Application         // Application Layer (Services, Use Cases, DTOs, Strategies)
│   ├── Services/                // Application services
│   ├── UseCases/                // Use cases (orchestrates services and business logic)
│   ├── Strategies/              // Strategy interfaces and context (for selecting the strategy)
├── Solution.Infrastructure      // Infrastructure Layer (Concrete Implementations)
│   ├── Data/                    // Database access
│   ├── Repositories/            // Repository implementations
│   └── Strategies/              // Concrete strategies (Azure SQL, Web API)
├── Solution.WebAPI              // Presentation Layer (Controllers, API)
└── Solution.SharedKernel        // Shared Kernel (Common utilities, Value Objects, etc.)
```

### **Code for the Strategy Pattern**

#### 1. **Strategy Interface** (In **Application Layer**)

- **Application/Strategies/IDataRetriever.cs**
  ```csharp
  namespace Solution.Application.Strategies
  {
      public interface IDataRetriever
      {
          Task<AccountDto> GetAccountByIdAsync(int id);
          Task<IEnumerable<AccountDto>> GetAllAccountsAsync();
      }
  }
  ```

#### 2. **Concrete Strategies** (In **Infrastructure Layer**)

- **Infrastructure/Strategies/SqlDataRetriever.cs** (For Azure SQL)
  ```csharp
  using Solution.Application.Strategies;
  using Solution.Core.Entities;

  namespace Solution.Infrastructure.Strategies
  {
      public class SqlDataRetriever : IDataRetriever
      {
          private readonly IRepository<Account> _repository;

          public SqlDataRetriever(IRepository<Account> repository)
          {
              _repository = repository;
          }

          public async Task<AccountDto> GetAccountByIdAsync(int id)
          {
              var account = await _repository.GetByIdAsync(id);
              return account != null ? new AccountDto { Id = account.Id, Name = account.Name, Balance = account.Balance } : null;
          }

          public async Task<IEnumerable<AccountDto>> GetAllAccountsAsync()
          {
              var accounts = await _repository.ListAllAsync();
              return accounts.Select(a => new AccountDto { Id = a.Id, Name = a.Name, Balance = a.Balance });
          }
      }
  }
  ```

- **Infrastructure/Strategies/WebApiDataRetriever.cs** (For Web API)
  ```csharp
  using Solution.Application.Strategies;
  using System.Net.Http;
  using Newtonsoft.Json;

  namespace Solution.Infrastructure.Strategies
  {
      public class WebApiDataRetriever : IDataRetriever
      {
          private readonly HttpClient _httpClient;

          public WebApiDataRetriever(HttpClient httpClient)
          {
              _httpClient = httpClient;
          }

          public async Task<AccountDto> GetAccountByIdAsync(int id)
          {
              var response = await _httpClient.GetStringAsync($"https://api.example.com/accounts/{id}");
              return JsonConvert.DeserializeObject<AccountDto>(response);
          }

          public async Task<IEnumerable<AccountDto>> GetAllAccountsAsync()
          {
              var response = await _httpClient.GetStringAsync($"https://api.example.com/accounts");
              return JsonConvert.DeserializeObject<IEnumerable<AccountDto>>(response);
          }
      }
  }
  ```

#### 3. **Strategy Context or Service Layer** (In **Application Layer**)

- **Application/Services/AccountService.cs**
  ```csharp
  namespace Solution.Application.Services
  {
      public class AccountService : IAccountService
      {
          private readonly IDataRetriever _dataRetriever;

          public AccountService(IDataRetriever dataRetriever)
          {
              _dataRetriever = dataRetriever;
          }

          public async Task<AccountDto> GetAccountByIdAsync(int id)
          {
              return await _dataRetriever.GetAccountByIdAsync(id);
          }

          public async Task<IEnumerable<AccountDto>> GetAllAccountsAsync()
          {
              return await _dataRetriever.GetAllAccountsAsync();
          }
      }
  }
  ```

#### 4. **Selecting the Strategy Based on Configuration** (In **Application Layer**)

In this step, we decide which strategy to inject into the service layer based on configuration or runtime logic.

- **Application/Services/StrategyFactory.cs**
  ```csharp
  using Microsoft.Extensions.Options;

  namespace Solution.Application.Services
  {
      public class StrategyFactory
      {
          private readonly WebApiDataRetriever _webApiDataRetriever;
          private readonly SqlDataRetriever _sqlDataRetriever;
          private readonly DataRetrievalConfig _config;

          public StrategyFactory(WebApiDataRetriever webApiDataRetriever, 
                                 SqlDataRetriever sqlDataRetriever, 
                                 IOptions<DataRetrievalConfig> config)
          {
              _webApiDataRetriever = webApiDataRetriever;
              _sqlDataRetriever = sqlDataRetriever;
              _config = config.Value;
          }

          public IDataRetriever GetDataRetriever()
          {
              return _config.RetrieveDataFromAPI 
                  ? (IDataRetriever)_webApiDataRetriever 
                  : _sqlDataRetriever;
          }
      }
  }
  ```

In this example, we have a `StrategyFactory` that decides whether to use the `WebApiDataRetriever` or `SqlDataRetriever` based on configuration.

#### 5. **Dependency Injection Setup in WebAPI**

In your `Program.cs` (or `Startup.cs`):

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Bind the configuration section to a strongly-typed class
builder.Services.Configure<DataRetrievalConfig>(builder.Configuration.GetSection("DataRetrieval"));

// Register strategies and other services
builder.Services.AddTransient<WebApiDataRetriever>();
builder.Services.AddTransient<SqlDataRetriever>();
builder.Services.AddScoped<StrategyFactory>();

// Use the factory to choose the correct strategy
builder.Services.AddScoped<IDataRetriever>(provider =>
{
    var factory = provider.GetRequiredService<StrategyFactory>();
    return factory.GetDataRetriever();
});

builder.Services.AddScoped<IAccountService, AccountService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
```

### **Conclusion**

In this structure, the **Strategy Pattern** sits across the **Application Layer** (with the `IDataRetriever` interface, the `AccountService`, and the `StrategyFactory`) and the **Infrastructure Layer** (where the concrete strategies like `SqlDataRetriever` and `WebApiDataRetriever` are implemented).

- The **Application Layer** handles the business logic and determines which strategy to use.
- The **Infrastructure Layer** implements the actual data retrieval strategies, including database access or external API calls.
- The **SharedKernel** can also be used for common utilities shared between different strategies if needed.

This approach aligns with Clean Architecture, ensuring separation of concerns and a highly modular, maintainable codebase.