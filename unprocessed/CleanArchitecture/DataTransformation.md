# Data Transformation - Application Layer

In Clean Architecture, transforming a `SqlDataReader` into a DTO (Data Transfer Object) is typically considered a responsibility of the **Application Layer**, not the **Infrastructure Layer**. Here's a breakdown of why:

## Clean Architecture Overview

Clean Architecture separates concerns into multiple layers:

1. **Domain Layer** (Core business logic)
2. **Application Layer** (Use cases, DTOs, service orchestration)
3. **Infrastructure Layer** (Persistence, external APIs, file systems, etc.)
4. **Presentation Layer** (UI, API controllers)

In Clean Architecture, each layer should be responsible for specific tasks, and the **Application Layer** should not be tightly coupled to any particular technology or implementation details from the **Infrastructure Layer**.

### Separation of Concerns

- **Infrastructure Layer**: This layer is responsible for interacting with external systems, such as databases, file systems, APIs, etc. When you query a database using `SqlDataReader` in the Infrastructure Layer, you're dealing with low-level database concerns, such as connections, queries, and data fetching.

  The primary responsibility of the Infrastructure Layer is to provide persistence or data-fetching capabilities, but not to shape the data into specific application-level structures (like DTOs).

- **Application Layer**: This layer is responsible for the application's business logic and coordinating the flow of data between the different parts of the system. It defines the use cases and how data should be processed. DTOs (Data Transfer Objects) are a concern of the Application Layer because they represent the data structures the application uses to communicate between layers.

  When the Infrastructure Layer fetches raw data (e.g., through a `SqlDataReader`), the Application Layer should transform this data into the proper DTOs or domain entities.

### Best Practice: Transform in the Application Layer

Here’s why transforming a `SqlDataReader` into a DTO should be done in the Application Layer:

1. **Decoupling**: By keeping the data transformation in the Application Layer, you ensure that the Infrastructure Layer is decoupled from the specific DTOs. This makes the Infrastructure Layer more reusable and focused on raw data access, without being tightly bound to application-specific models.
2. **Single Responsibility Principle (SRP)**: The Repository or Data Access classes in the Infrastructure Layer should have the sole responsibility of interacting with the database. Transforming the raw data into DTOs or other representations falls under a different concern—the concern of preparing the data for the application to use.
3. **Testability**: If the transformation logic is in the Application Layer, it’s easier to unit test the transformation separately from the Infrastructure Layer. This allows you to mock the data access layer for testing purposes.

### Workflow Example in Clean Architecture:

1. **Infrastructure Layer**: Fetch data using `SqlDataReader`.

   ```csharp
   public IEnumerable<IDataRecord> GetOrders()
   {
       using var command = new SqlCommand("SELECT * FROM Orders", _connection);
       using var reader = command.ExecuteReader();
       while (reader.Read())
       {
           yield return reader;
       }
   }
   ```

   Here, you return the raw `IDataRecord` or similar object from the Infrastructure Layer.

2. **Application Layer**: Convert the raw data into DTOs or domain entities.

   ```csharp
   public IEnumerable<OrderDto> GetOrderDtos()
   {
       var orders = _orderRepository.GetOrders();  // Call to the Infrastructure layer

       return orders.Select(order => new OrderDto
       {
           Id = (int)order["Id"],
           OrderDate = (DateTime)order["OrderDate"],
           Total = (decimal)order["Total"]
       });
   }
   ```

   The transformation logic from raw data to `OrderDto` happens here in the Application Layer, ensuring separation of concerns.

---

### Summary

In Clean Architecture:

- **Infrastructure Layer**: Only fetches raw data (e.g., `SqlDataReader`).
- **Application Layer**: Responsible for transforming raw data into DTOs or domain entities.

By following this approach, you ensure that your layers are properly decoupled and respect the principles of Clean Architecture.
