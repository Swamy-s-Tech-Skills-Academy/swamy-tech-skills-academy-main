# Clean Architecture

## Clean Architecture Overview

Clean Architecture is a software design philosophy that promotes a clear separation of concerns, ensuring that each layer of the application has a distinct responsibility. This architecture helps in maintaining a high level of testability, scalability, and maintainability.

### Key Principles:

1. **Separation of Concerns**: Each layer should have a specific responsibility.
2. **Dependency Inversion**: High-level modules should not depend on low-level modules; both should depend on abstractions.
3. **Testability**: Business logic can be tested independently of other concerns like data access and presentation.
4. **Flexibility and Maintainability**: Changes in one part of the system should have minimal impact on other parts.

---

## Solution Layout

Here’s an example solution layout for a Clean Architecture implementation in C# and .NET 8, incorporating a Shared Kernel:

```
Solution.sln
├── Solution.Domain              // Domain Layer (Entities, Interfaces)
├── Solution.Application         // Application Layer (Services, Use Cases, DTOs)
├── Solution.Infrastructure      // Infrastructure Layer (Data Access, External APIs)
├── Solution.WebAPI              // Presentation Layer (Controllers, API)
└── Solution.SharedKernel        // Shared Kernel (Common utilities, Value Objects, etc.)
```

---

### Overview of Layers

#### **Domain Layer** (`Solution.Domain`)

- **Purpose**: Represents the domain model, which includes entities, value objects, domain services, and domain events.
- **Components**:
  - **Entities**: Core business objects that have unique identities.
  - **Value Objects**: Immutable objects that represent descriptive aspects of the domain.
  - **Domain Services**: Contain domain logic that doesn't naturally fit within an entity or value object.
  - **Interfaces**: Abstractions for repositories and other services.
- **Dependencies**: This layer should not depend on any other layer.

#### **Application Layer** (`Solution.Application`)

- **Purpose**: Contains the use cases and application services that drive the business processes.
- **Components**:
  - **Use Cases**: Orchestrate the flow of data to and from entities, and coordinate user actions.
  - **Services**: Application-specific services that implement use cases.
  - **DTOs (Data Transfer Objects)**: Used to transfer data between layers.
- **Dependencies**: Depends only on the Domain layer.

#### **Infrastructure Layer** (`Solution.Infrastructure`)

- **Purpose**: Handles the implementation details such as data access, external service integrations, and messaging.
- **Components**:
  - **Repositories**: Implement data access logic.
  - **External Service Integrations**: API clients, messaging services, etc.
  - **Configurations**: Database configurations, API configurations, etc.
- **Dependencies**: Depends on the Domain and Application layers.

#### **Presentation Layer** (`Solution.WebAPI`)

- **Purpose**: The entry point of the application, typically an ASP.NET Core Web API that exposes endpoints for clients.
- **Components**:
  - **Controllers**: Handle HTTP requests and responses, delegate work to application services.
  - **ViewModels**: Represent data to be presented to the user.
  - **Filters, Middlewares**: Handle cross-cutting concerns like authentication, logging, etc.
- **Dependencies**: Depends on the Application layer.

#### **Shared Kernel** (`Solution.SharedKernel`)

- **Purpose**: Contains shared code that is common across multiple layers or projects.
- **Components**:
  - **Common Utilities**: Helper classes, extensions, etc.
  - **Value Objects**: That are used across different bounded contexts.
  - **Domain Events**: Events that are of interest to


---

## 
To maintain the principles of Clean Architecture and ensure that both the WebAPI and Infrastructure layers can use the `RetrievalConfiguration` class, you should move this class to a layer that is accessible to both. The Shared Kernel is an ideal place for such shared concerns.  
   
Here’s how you can achieve this:  
   
1. **Move `RetrievalConfiguration` to the Shared Kernel**:  
   - Create a new folder or namespace within the `Solution.SharedKernel` project for configurations if it doesn't already exist.  
   - Move the `RetrievalConfiguration` class to this new location.  
   
2. **Update References**:  
   - Update the references in both the `Solution.WebAPI` and `Solution.Infrastructure` projects to point to the new location of `RetrievalConfiguration`.  
   
Here’s a step-by-step outline:  
   
### Step 1: Move `RetrievalConfiguration`  
   
Move `RetrievalConfiguration` from `Solution.WebAPI` to `Solution.SharedKernel`:  
   
```markdown  
Solution.sln  
├── Solution.Domain  
├── Solution.Application  
├── Solution.Infrastructure  
├── Solution.WebAPI  
└── Solution.SharedKernel  
    └── Configurations              // New folder for configuration classes  
        └── RetrievalConfiguration.cs  
```  
   
### Step 2: Update `RetrievalConfiguration` Namespace  
   
Update the namespace of the `RetrievalConfiguration` class to reflect its new location. For example:  
   
```csharp  
namespace Solution.SharedKernel.Configurations  
{  
    public class RetrievalConfiguration  
    {  
        // Configuration properties go here  
    }  
}  
```  
   
### Step 3: Update References in `ServiceCollectionExtension.cs`  
   
In `ServiceCollectionExtension.cs` within the `Solution.Infrastructure` project, update the using statement to reference the new namespace:  
   
```csharp  
using Solution.SharedKernel.Configurations;  
   
public static class ServiceCollectionExtensions  
{  
    public static IServiceCollection AddCustomServices(this IServiceCollection services, RetrievalConfiguration config)  
    {  
        // Use the config to load different strategy implementations  
        // ...  
        return services;  
    }  
}  
```  
   
### Step 4: Update References in `Solution.WebAPI`  
   
In the `Solution.WebAPI` project, update the using statement wherever `RetrievalConfiguration` is used:  
   
```csharp  
using Solution.SharedKernel.Configurations;  
   
public class Startup  
{  
    public void ConfigureServices(IServiceCollection services)  
    {  
        var dataRetrievalConfig = Configuration.GetSection("DataRetrieval").Get<RetrievalConfiguration>();  
        services.AddCustomServices(dataRetrievalConfig);  
    }  
}  
```  
   
### Final Structure  
   
Your final project structure should look like this:  
   
```markdown  
Solution.sln  
├── Solution.Domain  
├── Solution.Application  
├── Solution.Infrastructure  
├── Solution.WebAPI  
└── Solution.SharedKernel  
    └── Configurations  
        └── RetrievalConfiguration.cs  
```  
   
By moving the `RetrievalConfiguration` to the Shared Kernel, you ensure that it is accessible to both the WebAPI and Infrastructure layers while maintaining a clean separation of concerns and adhering to the principles of Clean Architecture.