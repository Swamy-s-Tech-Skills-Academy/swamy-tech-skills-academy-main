# Shared project

The Shared project (containing your DTOs, interfaces, and other common types) should be referenced by the following layers/projects in your typical layered architecture:

1.  **Presentation Layers:**

    - **`Products.API`:** Your API project _must_ reference the Shared project. It uses DTOs for request and response bodies in its controllers.
    - **`Products.Web` (or other UI projects):** Your Blazor Web App (or any other UI project like a mobile app) _must_ also reference the Shared project. It uses DTOs to display data and send data to the API.

2.  **Infrastructure Layer (Sometimes):**
    - **`Products.Infrastructure`:** In some cases, the Infrastructure layer might need to reference the Shared project, _but only for interfaces or other common types, not for DTOs directly_. For instance, if you have interfaces defining data contracts for external services or message queues, those interfaces could reside in the Shared project and be implemented in the Infrastructure layer. However, _do not use DTOs directly in your data access code (repositories)._ Instead, map from entities to DTOs in the API layer.

**Projects that should _not_ reference the Shared project:**

1.  **Domain Layer:** The Domain layer should be completely independent of any other layer, including the Shared layer. It should only contain core business entities, value objects, and domain logic.
2.  **Application Layer:** The Application layer should also _not_ directly reference the Shared project. As explained previously, it works with Domain entities and relies on the presentation layers to perform the mapping to DTOs.

**Dependency Diagram:**

Here's a visual representation of the dependencies:

```
+-----------------+     +-----------------+     +-----------------+     +-----------------+
|   Products.Web   |---->|   Products.API   |---->| Products.App   |---->| Products.Domain |
+-----------------+     +-----------------+     +-----------------+     +-----------------+
      ^                       ^
      |                       |
      +-----------------------+
              |
              V
      +-----------------+
      | Products.Shared |
      +-----------------+
```

**Explanation of the Diagram:**

- `Products.Web` and `Products.API` both depend on `Products.Shared`.
- `Products.API` depends on `Products.Application`.
- `Products.Application` depends on `Products.Domain`.
- `Products.Domain` has no dependencies.

**In Summary:**

The Shared project acts as a central location for types that need to be shared between different parts of your application, primarily the presentation layers. It helps to decouple the layers and promote reusability. The Application and Domain layers should remain independent of the Shared project to maintain a clean and well-structured architecture. This is a very important principle to follow for maintainable and scalable applications.
