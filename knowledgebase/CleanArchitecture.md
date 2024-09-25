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
