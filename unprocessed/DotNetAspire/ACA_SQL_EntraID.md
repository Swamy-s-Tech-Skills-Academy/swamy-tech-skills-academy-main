# .NET 8 Aspire Azure Container App Connecting to Azure SQL Database with Azure Entra ID

## Overview

This guide details the steps to configure a .NET 8 application deployed on Azure Container Apps to connect securely to an Azure SQL Database using Azure Entra ID for authentication. By leveraging Entra ID, you can improve security by eliminating the need to store database credentials within the application.

## Prerequisites

> 1. Azure Entra ID: Ensure you have an Azure Entra ID instance configured.
> 1. Azure SQL Database: Set up the SQL Database and configure it for Azure AD authentication.
> 1. Azure Container App: Deploy a .NET 8 application in Azure Container Apps.
> 1. .NET 8 SDK: Ensure the application uses .NET 8 SDK.

## Current Architecture

The architecture involves multiple Azure services interacting together to form a secure and scalable solution. The key components include:

> 1. `school-api`: The container app representing the API.
> 1. `acras2wogk3v6wxw`: The Azure Container Registry storing the API’s container images.
> 1. `law-as2wogk3v6wxw`: The Log Analytics workspace used for monitoring and diagnostics.
> 1. `cae-as2wogk3v6wxw`: The Azure Container Apps environment in which the school-api app is deployed.
> 1. `mi-as2wogk3v6wxw`: Managed Identity used to authenticate and pull the container image from ACR.

![.NET 8 Aspire](images/rg-aspire-dev-002.PNG)

## Solution Components

The key components of the .NET 8 Aspire solution include:

> 1. `school-api`: A containerized API built using .NET 8, deployed in Azure Container Apps.
> 1. `Azure Container Registry`: The registry that holds the container images.
> 1. `Azure Managed Identity`: Used to authenticate and manage access to resources like the Azure Container Registry and Azure SQL without needing explicit credentials.
> 1. `Azure Log Analytics Workspace`: Provides centralized logging for monitoring the application.

## Managed Identity Setup

Azure Managed Identity is employed for seamless authentication of services, ensuring a secure and passwordless experience.

### Role Assignments

For this architecture, the managed identity mi-as2wogk3v6wxw is assigned the following role:

> 1. Role: AcrPull
> 1. Resource Name: acras2wogk3v6wxw
> 1. Resource Type: Azure Container Registry
> 1. Assigned To: mi-as2wogk3v6wxw (Managed Identity)
> 1. Condition: None

This setup allows the `school-api` container to securely pull images from the Azure Container Registry without embedding credentials.

### Creating a System-Assigned Managed Identity for Azure SQL

A new `System-Assigned Managed Identity` will be created for school-api to authenticate against `Azure SQL`. This managed identity will handle secure database operations, eliminating the need for credentials in the API.

> 1. Role: SQL permissions (e.g., `db_datareader`, `db_datawriter`, `db_ddladmin`)
> 1. Resource: Azure SQL Database
> 1. Assigned To: `school-api` Managed Identity

This identity will have specific SQL roles assigned in the database, ensuring secure and controlled access to execute SQL queries from the API.

## Container App Deployment

The .NET 8 Aspire solution leverages Azure Container Apps for the deployment of the school-api API. Key configurations include:

Container App Environment: `cae-as2wogk3v6wxw`, hosting the containerized API.
Image Source: Container images are pulled from the Azure Container Registry (`acras2wogk3v6wxw`).

## Monitoring and Logging

All logs from the application, including API requests, database operations, and system metrics, are collected and stored in the Log Analytics Workspace (law-as2wogk3v6wxw). This provides a centralized dashboard for monitoring application health and identifying issues. Logs are automatically forwarded to the Log Analytics Workspace for centralized monitoring.

## Adding Azure Entra ID Users to Azure SQL Database

To allow the application to authenticate with the Azure SQL Database, you need to add Azure Entra ID users. Follow these SQL commands to add users with specific roles.

### SQL Commands to Add Users

```sql
CREATE USER [school-api] FROM EXTERNAL PROVIDER WITH DEFAULT_SCHEMA = dbo;
ALTER ROLE db_datareader ADD MEMBER [school-api];
ALTER ROLE db_datawriter ADD MEMBER [school-api];
ALTER ROLE db_ddladmin ADD MEMBER [school-api];
GO
```

### Explanation

- `CREATE USER FROM EXTERNAL PROVIDER`: Adds an Azure Entra ID user.
- Roles: Assign `db_datareader`, `db_datawriter`, and `db_ddladmin` roles for read, write, and DDL permissions.

## Configure the .NET 8 Application (ACA) to Use Entra ID for SQL Database Access

### Set Up the Connection String

In the application configuration file, set up a connection string that specifies Entra ID authentication.

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=tcp:<YOUR_SERVER_NAME>.database.windows.net,1433;Database=<YOUR_DATABASE_NAME>;Authentication=Active Directory Default"
}
```

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=tcp:<YOUR_SERVER_NAME>.database.windows.net,1433;Database=<YOUR_DATABASE_NAME>;Authentication=Active Directory Managed Identity"
}
```

Server=tcp:sql-common-store.database.windows.net,1433;Initial Catalog=sqldb-common-store;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication="Active Directory Managed Identity";

### Conclusion

By following these steps, you can configure a secure connection between your .NET 8 application on Azure Container Apps and Azure SQL Database using Azure Entra ID. This setup enhances security and removes the need for embedded credentials, aligning with best practices for modern cloud-native applications.

---

## 3. Retrieving Users in Azure SQL Database

After adding users, you can use SQL queries to view and manage them within your Azure SQL Database.

### 3.1 View All Database Users

To list all users within the current database, including Azure AD users, use the following query:

```sql
SELECT name, type_desc, principal_id
FROM sys.database_principals
WHERE type IN ('S', 'E', 'X')
ORDER BY name;
```

- S: SQL local users
- E: External (Azure AD) users/groups
- X: External (Azure AD) groups

### 3.2 View Only External Users

Use this query to filter and display only Azure AD users:

```sql
SELECT name, type_desc, principal_id
FROM sys.database_principals
WHERE type_desc = 'EXTERNAL_USER'
ORDER BY name;
```

### 3.3 Check User Roles and Permissions

To view roles assigned to a particular user:

```sql
SELECT dp.name AS user_name,
       r.name AS role_name
FROM sys.database_principals dp
JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
JOIN sys.database_principals r ON r.principal_id = drm.role_principal_id
WHERE dp.type_desc = 'EXTERNAL_USER'
ORDER BY dp.name;
```

### 3.4 List Server-Level Users

For server-level users and Azure AD admins, query `sys.server_principals`:

```sql
SELECT name, type_desc, principal_id
FROM sys.server_principals
WHERE type IN ('S', 'E', 'X')
ORDER BY name;
```

---

## 4. Configure the .NET 8 Application to Use Entra ID for SQL Database Access

### 4.1 Set Up the Connection String

In the application configuration file, set up a connection string that specifies Entra ID authentication.

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=tcp:<YOUR_SERVER_NAME>.database.windows.net,1433;Database=<YOUR_DATABASE_NAME>;Authentication=Active Directory Default"
}
```

### 4.2 Set Up Azure Identity in Application Code

Use the `DefaultAzureCredential` class to allow the application to authenticate to Azure SQL Database.

---

## 5. Testing and Troubleshooting

1. Run the Application: Deploy the container and check if it can connect to the SQL database.
2. Azure Monitor: Use logs and Azure Monitor to track successful connections and troubleshoot errors.
3. Event Logs: Check Azure SQL Database and Entra ID logs for additional troubleshooting.

---

### Conclusion

By following these steps, you can configure a secure connection between your .NET 8 application on Azure Container Apps and Azure SQL Database using Azure Entra ID. This setup enhances security and removes the need for embedded credentials, aligning with best practices for modern cloud-native applications.

The key difference between the two connection strings lies in how **Azure Active Directory (Azure AD)** authentication is performed for connecting to the Azure SQL Database.

### 1. **Active Directory Default Authentication**

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=tcp:<YOUR_SERVER_NAME>.database.windows.net,1433;Database=<YOUR_DATABASE_NAME>;Authentication=Active Directory Default"
}
```

- **Authentication Type**: **Active Directory Default** uses the currently logged-in **Azure AD user** or **service principal** in the local environment.
- **Use Case**: This is typically used during **development** or **testing** phases when you are working locally and have signed in with your Azure AD credentials using the `az login` command or Visual Studio’s connected Azure account.
- **Behavior**: It attempts to authenticate using whatever Azure AD identity is active in the developer's environment. This could be the developer’s own account or an identity tied to a service principal.

### 2. **Active Directory Managed Identity**

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=tcp:<YOUR_SERVER_NAME>.database.windows.net,1433;Database=<YOUR_DATABASE_NAME>;Authentication=Active Directory Managed Identity"
}
```

- **Authentication Type**: **Active Directory Managed Identity** uses the **managed identity** of the resource (e.g., Azure VM, Azure App Service, or Azure Function) where the application is running.
- **Use Case**: This is used for **production** deployments where the application is running in an Azure resource with a **system-assigned** or **user-assigned managed identity**. Managed identity allows the application to authenticate securely without storing credentials.
- **Behavior**: It uses the identity that has been explicitly assigned to the resource, allowing secure access to the database without the need to manually provide or rotate credentials.

### Summary

- **Active Directory Default**: Ideal for local development where an Azure AD user or service principal's authentication is available through tools like `az login`.
- **Active Directory Managed Identity**: Ideal for production environments where the application runs within Azure services and uses the built-in managed identity of the service for authentication, ensuring security and ease of management.

In short, **Active Directory Default** is useful for **local environments**, while **Managed Identity** is designed for **cloud environments** where the application is hosted within Azure services.

---

**Date:** 30-Oct-2024

Certainly, here’s a consolidated version combining both explanations for your Confluence page.

---

# Connecting to Azure SQL Database using Azure Active Directory (Azure AD)

In .NET applications hosted on Azure, you can leverage Azure Active Directory (Azure AD) for secure database connections without storing credentials. There are two primary ways to authenticate via Azure AD: **Active Directory Default** and **Active Directory Managed Identity**. Each method has its ideal usage depending on the environment, whether it’s for local development or production deployments.

### Azure AD Authentication Methods Overview

| Authentication Type                   | Best for                         | Description                                                                                                                                                                            |
| ------------------------------------- | -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Active Directory Default**          | Local Development & Testing      | Uses the currently logged-in Azure AD user or service principal in the developer's environment to access Azure SQL Database.                                                           |
| **Active Directory Managed Identity** | Production Environments in Azure | Uses the managed identity associated with the Azure resource where the app is running, such as Azure App Service or Azure Function. This eliminates the need for managing credentials. |

---

## Connection String Examples

1. **Active Directory Default Authentication**

   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=tcp:<YOUR_SERVER_NAME>.database.windows.net,1433;Database=<YOUR_DATABASE_NAME>;Authentication=Active Directory Default"
   }
   ```

   - **Purpose**: This configuration leverages the **current Azure AD identity** in the local environment, allowing developers to authenticate using `az login` or a similar tool.
   - **Use Case**: Primarily used in **development and testing phases** where the developer’s own Azure AD credentials or an Azure AD service principal are available.
   - **Behavior**: The application authenticates with Azure SQL using the currently signed-in Azure AD identity or any identity configured in the environment. This can be useful for quick local testing and development setups.

2. **Active Directory Managed Identity Authentication**

   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=tcp:<YOUR_SERVER_NAME>.database.windows.net,1433;Database=<YOUR_DATABASE_NAME>;Authentication=Active Directory Managed Identity"
   }
   ```

   - **Purpose**: Managed Identity uses **Azure’s built-in identity** associated with the Azure resource (e.g., Azure App Service, Virtual Machine) running the application.
   - **Use Case**: Recommended for **production environments** where the app runs within an Azure resource and the need for **secure, automatic identity management** is a priority. Managed Identity ensures the app can securely connect to Azure SQL without manually managing credentials.
   - **Security Advantage**: Managed identity is controlled directly by Azure, which handles **credential rotation and security** automatically, reducing maintenance and enhancing security.

---

### Key Differences Between the Two Methods

- **Authentication Identity**: Active Directory Default relies on a manually authenticated Azure AD user, while Managed Identity uses an Azure-assigned identity tied directly to the Azure resource.
- **Environment Suitability**: Default is suited for **development environments** and manual configurations, while Managed Identity is best for **production deployments** due to automatic credential handling.
- **Security and Maintenance**: Managed Identity provides a higher security level with **automatic credential rotation** and eliminates the need for storing or updating credentials manually.

---

### Step-by-Step Setup

1. **For Active Directory Default**:

   - Ensure you are logged in to Azure using `az login` or Visual Studio’s connected Azure account.
   - Use the Default Connection string as shown above in your application settings.

2. **For Active Directory Managed Identity**:
   - Enable a **system-assigned or user-assigned managed identity** for your Azure resource (App Service, VM, etc.).
   - Assign the managed identity the necessary SQL permissions in your Azure SQL Database.

With these options, you can connect securely to Azure SQL, leveraging Azure AD and managed identities for both secure and flexible authentication based on your deployment needs.

---

This document should help guide developers in selecting the correct authentication strategy based on their specific environment, ensuring seamless and secure connectivity to Azure SQL.

---

Certainly! Here is the revised version, integrating the information on **Active Directory Default** and **Active Directory Managed Identity**.

---

# .NET 8 Aspire Azure Container App Connecting to Azure SQL Database with Azure Entra ID

## Overview

This guide details the steps to configure a .NET 8 application deployed on Azure Container Apps to connect securely to an Azure SQL Database using Azure Entra ID for authentication. By leveraging Entra ID, you can improve security by eliminating the need to store database credentials within the application.

## Prerequisites

1. **Azure Entra ID**: Ensure you have an Azure Entra ID instance configured.
2. **Azure SQL Database**: Set up the SQL Database and configure it for Azure AD authentication.
3. **Azure Container App**: Deploy a .NET 8 application in Azure Container Apps.
4. **.NET 8 SDK**: Ensure the application uses the .NET 8 SDK.

---

## Current Architecture

The architecture involves multiple Azure services working together to form a secure and scalable solution:

1. `school-api`: The container app representing the API.
2. `acras2wogk3v6wxw`: The Azure Container Registry storing the API’s container images.
3. `law-as2wogk3v6wxw`: The Log Analytics workspace used for monitoring and diagnostics.
4. `cae-as2wogk3v6wxw`: The Azure Container Apps environment in which the school-api app is deployed.
5. `mi-as2wogk3v6wxw`: Managed Identity used to authenticate and pull the container image from ACR.

![.NET 8 Aspire](images/rg-aspire-dev-002.PNG)

---

## Solution Components

### Key Components

- `school-api`: A containerized API built using .NET 8, deployed in Azure Container Apps.
- `Azure Container Registry`: The registry that holds the container images.
- `Azure Managed Identity`: Authenticates access to resources like Azure Container Registry and Azure SQL without requiring explicit credentials.
- `Azure Log Analytics Workspace`: Provides centralized logging for monitoring the application.

### Managed Identity Setup

Azure Managed Identity ensures seamless authentication, providing secure and passwordless access to Azure SQL.

### Role Assignments

For this setup, the managed identity `mi-as2wogk3v6wxw` has the following role assignments:

- **Role**: AcrPull
- **Resource**: `acras2wogk3v6wxw` (Azure Container Registry)
- **Assigned To**: `mi-as2wogk3v6wxw` (Managed Identity)
- **Condition**: None

This setup allows the `school-api` container to pull images from the Azure Container Registry securely.

---

## Connecting to Azure SQL Database Using Entra ID

### System-Assigned Managed Identity for Azure SQL

A **System-Assigned Managed Identity** is created for the `school-api` to authenticate against **Azure SQL Database**. This identity provides secure database access, removing the need to store credentials in the application.

- **Roles**: SQL permissions (`db_datareader`, `db_datawriter`, `db_ddladmin`)
- **Resource**: Azure SQL Database
- **Assigned To**: `school-api` Managed Identity

### Configuring the Connection String

For connecting to Azure SQL, the .NET 8 application can use two types of connection strings depending on the environment setup: **Active Directory Default** or **Active Directory Managed Identity**.

### Connection String Examples

1. **Active Directory Default Authentication** (for local development):

   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=tcp:<YOUR_SERVER_NAME>.database.windows.net,1433;Database=<YOUR_DATABASE_NAME>;Authentication=Active Directory Default"
   }
   ```

   - **Usage**: Typically for local development, using the currently authenticated Azure AD user or service principal. This method relies on a pre-existing Azure AD login via tools like `az login` or Visual Studio's Azure integration.

2. **Active Directory Managed Identity Authentication** (for production):

   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=tcp:<YOUR_SERVER_NAME>.database.windows.net,1433;Database=<YOUR_DATABASE_NAME>;Authentication=Active Directory Managed Identity"
   }
   ```

   - **Usage**: For production environments, where the app runs in Azure and uses its assigned managed identity to authenticate securely with Azure SQL. This is the recommended setup for Azure-hosted apps, as it leverages the Azure infrastructure for secure and automated credential management.

### SQL Commands to Add Entra ID Users to Azure SQL Database

Use the following SQL commands to add Entra ID users with appropriate roles in the Azure SQL Database:

```sql
CREATE USER [school-api] FROM EXTERNAL PROVIDER WITH DEFAULT_SCHEMA = dbo;
ALTER ROLE db_datareader ADD MEMBER [school-api];
ALTER ROLE db_datawriter ADD MEMBER [school-api];
ALTER ROLE db_ddladmin ADD MEMBER [school-api];
GO
```

- **CREATE USER FROM EXTERNAL PROVIDER**: Adds an Azure Entra ID user.
- **Role Assignments**: Assigns `db_datareader`, `db_datawriter`, and `db_ddladmin` roles to allow reading, writing, and DDL permissions.

---

## Monitoring and Logging

Logs from the application, including API requests and database operations, are collected in the Log Analytics Workspace (`law-as2wogk3v6wxw`). This centralized logging setup provides a complete overview of application health and performance.

---

### Summary

By following these steps, you can securely configure your .NET 8 Azure Container App to connect to Azure SQL Database using Azure Entra ID. This approach eliminates the need for embedded credentials, aligning with security best practices for modern cloud applications.
