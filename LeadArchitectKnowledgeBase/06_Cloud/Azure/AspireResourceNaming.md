# .NET Aspire Azure Resource Naming Customization

## Overview

When deploying .NET Aspire applications to Azure, you often need to customize the names of Azure resources instead of using the default auto-generated names. This guide covers two primary approaches for customizing resource names in .NET Aspire.

## Default Behavior

By default, .NET Aspire appends unique strings to resource names to avoid conflicts:
- `myapp-cosmos-abc123` (auto-generated)
- `myapp-redis-def456` (auto-generated)

## Customization Approaches

### **1. Per Resource Customization**

For specific resources, use `.ConfigureInfrastructure()` to set custom names:

```csharp
var cosmos = builder.AddAzureCosmosDB("ecoDriverCosmosDb")
    .ConfigureInfrastructure(infrastructure =>
    {
        var cosmosAccount = infrastructure.GetProvisionableResources()
            .OfType<CosmosDBAccount>()
            .Single();
        cosmosAccount.Name = "MyCustomCosmosDb";
    });
```

**Use Cases:**
- When you need specific names for compliance
- Integration with existing Azure resources
- Consistent naming across environments

### **2. Global Customization Across All Resources**

For organization-wide naming conventions, modify **AzureProvisioningOptions**:

```csharp
var builder = DistributedApplication.CreateBuilder(args);

builder.Services.Configure<AzureProvisioningOptions>(options =>
{
    options.ProvisioningBuildOptions.InfrastructureResolvers.Insert(0, new FixedNameInfrastructureResolver());
});

internal sealed class FixedNameInfrastructureResolver : InfrastructureResolver
{
    public override void ResolveProperties(ProvisionableConstruct construct, ProvisioningBuildOptions options)
    {
        if (construct is CosmosDBAccount account)
        {
            account.Name = "MyCustomCosmosDb";
        }
        
        // Add more resource types as needed
        if (construct is RedisCache redis)
        {
            redis.Name = "MyCustomRedis";
        }
        
        if (construct is SqlServer sqlServer)
        {
            sqlServer.Name = "MyCustomSqlServer";
        }
        
        base.ResolveProperties(construct, options);
    }
}
```

## Advanced Naming Patterns

### Environment-Based Naming

```csharp
internal sealed class EnvironmentBasedNameResolver : InfrastructureResolver
{
    public override void ResolveProperties(ProvisionableConstruct construct, ProvisioningBuildOptions options)
    {
        var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production";
        
        if (construct is CosmosDBAccount account)
        {
            account.Name = $"ecodriver-cosmos-{environment.ToLower()}";
        }
        
        base.ResolveProperties(construct, options);
    }
}
```

### Company Naming Convention

```csharp
internal sealed class CompanyNamingResolver : InfrastructureResolver
{
    private readonly string _companyPrefix = "contoso";
    private readonly string _projectName = "ecodriver";
    
    public override void ResolveProperties(ProvisionableConstruct construct, ProvisioningBuildOptions options)
    {
        var resourceType = GetResourceType(construct);
        var name = $"{_companyPrefix}-{_projectName}-{resourceType}";
        
        switch (construct)
        {
            case CosmosDBAccount account:
                account.Name = name;
                break;
            case RedisCache redis:
                redis.Name = name;
                break;
            case SqlServer sqlServer:
                sqlServer.Name = name;
                break;
        }
        
        base.ResolveProperties(construct, options);
    }
    
    private string GetResourceType(ProvisionableConstruct construct) =>
        construct switch
        {
            CosmosDBAccount => "cosmos",
            RedisCache => "redis",
            SqlServer => "sql",
            _ => "resource"
        };
}
```

## Best Practices

### 1. **Consistent Naming Conventions**
- Use organization-wide naming standards
- Include environment indicators (dev, test, prod)
- Add project/application identifiers

### 2. **Resource Name Limitations**
- Azure resource names have specific character limits
- Some resources require globally unique names
- Consider DNS compatibility for public endpoints

### 3. **Configuration Management**
```csharp
// Use configuration for dynamic naming
builder.Services.Configure<AzureProvisioningOptions>(options =>
{
    var config = builder.Configuration;
    var prefix = config["Azure:ResourcePrefix"] ?? "myapp";
    
    options.ProvisioningBuildOptions.InfrastructureResolvers.Insert(0, 
        new ConfigurableNameResolver(prefix));
});
```

### 4. **Multi-Environment Support**
```csharp
internal sealed class MultiEnvironmentResolver : InfrastructureResolver
{
    public override void ResolveProperties(ProvisionableConstruct construct, ProvisioningBuildOptions options)
    {
        var env = GetEnvironment();
        var suffix = env == "Production" ? "prod" : env.ToLower();
        
        // Apply naming convention with environment suffix
        // ...
    }
}
```

## Integration with Azure DevOps

When using CI/CD pipelines, configure naming through environment variables:

```yaml
# Azure DevOps Pipeline
variables:
  AZURE_RESOURCE_PREFIX: 'contoso-ecodriver'
  ASPNETCORE_ENVIRONMENT: '$(Build.SourceBranchName)'
```

## Troubleshooting

### Common Issues:
1. **Name conflicts** - Ensure uniqueness across subscriptions
2. **Character limits** - Validate against Azure naming rules
3. **Reserved names** - Avoid Azure reserved keywords

### Validation:
```csharp
private bool IsValidAzureName(string name, string resourceType)
{
    // Implement Azure naming validation logic
    return resourceType switch
    {
        "cosmos" => name.Length <= 44 && Regex.IsMatch(name, "^[a-z0-9-]+$"),
        "storage" => name.Length <= 24 && Regex.IsMatch(name, "^[a-z0-9]+$"),
        _ => true
    };
}
```

## Lead Architect Considerations

As a Lead Architect, consider:

1. **Governance**: Establish naming standards across teams
2. **Automation**: Implement naming validation in CI/CD
3. **Documentation**: Maintain naming convention documentation
4. **Cost Management**: Use naming for cost allocation tracking
5. **Security**: Avoid exposing sensitive information in names

## Related Topics

- [Azure Resource Naming Best Practices](../Patterns/NamingConventions.md)
- [.NET Aspire Deployment Patterns](../Patterns/AspireDeployment.md)
- [Azure DevOps Integration](../../07_DevOps/CI_CD/AzureDevOps.md)
- [Infrastructure as Code](../../07_DevOps/IaC/README.md)

---

*This approach ensures predictable, manageable Azure resource names in your .NET Aspire applications while maintaining flexibility for different environments and organizational requirements.*
