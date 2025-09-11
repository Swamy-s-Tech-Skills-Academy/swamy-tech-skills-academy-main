# Cloud-Native Application Patterns with .NET Aspire

## Overview

.NET Aspire represents a modern approach to building cloud-native applications, incorporating several key architectural patterns and best practices for distributed systems.

## Key Architectural Patterns

### 1. **Service Discovery Pattern**
.NET Aspire implements automatic service discovery:

```csharp
// App Host automatically registers services
var api = builder.AddProject<Projects.WebApi>("api");
var frontend = builder.AddProject<Projects.WebApp>("frontend")
    .WithReference(api); // Automatic service discovery
```

### 2. **Configuration as Code Pattern**
Centralized configuration management:

```csharp
// Infrastructure configuration in code
var cosmos = builder.AddAzureCosmosDB("cosmos")
    .ConfigureInfrastructure(infrastructure =>
    {
        var account = infrastructure.GetProvisionableResources()
            .OfType<CosmosDBAccount>()
            .Single();
        account.Name = "MyCustomCosmosDb";
    });
```

### 3. **Observable Services Pattern**
Built-in observability across all services:

```csharp
// Automatic telemetry collection
builder.AddServiceDefaults(); // Includes logging, metrics, tracing
```

## Resource Naming Strategy Pattern

A critical pattern for enterprise applications is consistent resource naming across environments.

### Strategy Pattern Implementation
```csharp
public interface IResourceNamingStrategy
{
    string GenerateName(string resourceType, string logicalName);
}

public class EnvironmentBasedNamingStrategy : IResourceNamingStrategy
{
    private readonly string _environment;
    private readonly string _companyPrefix;
    
    public EnvironmentBasedNamingStrategy(string environment, string companyPrefix)
    {
        _environment = environment;
        _companyPrefix = companyPrefix;
    }
    
    public string GenerateName(string resourceType, string logicalName)
    {
        return $"{_companyPrefix}-{logicalName}-{resourceType}-{_environment}".ToLower();
    }
}
```

### Infrastructure Resolver Pattern
```csharp
internal sealed class StrategyBasedNameResolver : InfrastructureResolver
{
    private readonly IResourceNamingStrategy _namingStrategy;
    
    public StrategyBasedNameResolver(IResourceNamingStrategy namingStrategy)
    {
        _namingStrategy = namingStrategy;
    }
    
    public override void ResolveProperties(ProvisionableConstruct construct, ProvisioningBuildOptions options)
    {
        var name = construct switch
        {
            CosmosDBAccount => _namingStrategy.GenerateName("cosmos", "main"),
            RedisCache => _namingStrategy.GenerateName("redis", "cache"),
            SqlServer => _namingStrategy.GenerateName("sql", "primary"),
            _ => null
        };
        
        if (name != null)
        {
            SetResourceName(construct, name);
        }
        
        base.ResolveProperties(construct, options);
    }
}
```

## Enterprise Integration Patterns

### 1. **Environment Promotion Pattern**
```csharp
// Different naming per environment
var builder = DistributedApplication.CreateBuilder(args);

var environment = builder.Environment.EnvironmentName;
var namingStrategy = environment switch
{
    "Development" => new DevNamingStrategy(),
    "Staging" => new StagingNamingStrategy(),
    "Production" => new ProductionNamingStrategy(),
    _ => new DefaultNamingStrategy()
};

builder.Services.Configure<AzureProvisioningOptions>(options =>
{
    options.ProvisioningBuildOptions.InfrastructureResolvers.Insert(0, 
        new StrategyBasedNameResolver(namingStrategy));
});
```

### 2. **Configuration Override Pattern**
```csharp
// Override resource names via configuration
public class ConfigurableNamingStrategy : IResourceNamingStrategy
{
    private readonly IConfiguration _configuration;
    
    public string GenerateName(string resourceType, string logicalName)
    {
        var configKey = $"Azure:Resources:{resourceType}:{logicalName}:Name";
        return _configuration[configKey] ?? 
               $"default-{logicalName}-{resourceType}";
    }
}
```

## Anti-Patterns to Avoid

### 1. **Hardcoded Resource Names**
```csharp
// ❌ Bad - Hardcoded names
account.Name = "MyCosmosDb"; // No environment distinction

// ✅ Good - Environment-aware naming
account.Name = _namingStrategy.GenerateName("cosmos", "main");
```

### 2. **Inconsistent Naming Across Resources**
```csharp
// ❌ Bad - Inconsistent naming
cosmosAccount.Name = "prod-cosmos-db";
redisCache.Name = "ProductionRedisCache";

// ✅ Good - Consistent pattern
cosmosAccount.Name = _namingStrategy.GenerateName("cosmos", "main");
redisCache.Name = _namingStrategy.GenerateName("redis", "cache");
```

## Lead Architect Considerations

### 1. **Governance**
- Establish naming conventions across all teams
- Implement validation rules for resource names
- Create reusable naming strategy components

### 2. **Scalability**
- Design for multi-environment deployments
- Consider resource name global uniqueness requirements
- Plan for disaster recovery naming scenarios

### 3. **Maintainability**
- Use configuration-driven naming when possible
- Document naming conventions clearly
- Implement automated validation in CI/CD

## Implementation Checklist

- [ ] Define company naming standards
- [ ] Implement IResourceNamingStrategy interface
- [ ] Create environment-specific strategies
- [ ] Configure InfrastructureResolver
- [ ] Add validation rules
- [ ] Document naming conventions
- [ ] Test across all environments

## Related Patterns


- Service Discovery (coming soon)
- Resource Management (coming soon)
- Configuration Management (coming soon)
- IaC Patterns (see ../../07_DevOps/IaC/)
---

*Proper resource naming in .NET Aspire applications ensures consistency, maintainability, and enterprise compliance across all environments and deployments.*
