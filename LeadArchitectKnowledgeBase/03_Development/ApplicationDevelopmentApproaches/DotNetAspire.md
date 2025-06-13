# .NET Aspire Development Guide

## Overview

.NET Aspire is Microsoft's opinionated cloud-ready stack for building observable, production-ready, distributed applications. This guide covers development best practices and common patterns.

## Key Features

- **Service Discovery**: Automatic service registration and discovery
- **Configuration**: Centralized configuration management
- **Observability**: Built-in telemetry, logging, and health checks
- **Azure Integration**: Seamless deployment to Azure
- **Local Development**: Consistent dev/prod environments

## Application Structure

### App Host Project
```csharp
var builder = DistributedApplication.CreateBuilder(args);

// Add services
var cache = builder.AddRedis("cache");
var cosmos = builder.AddAzureCosmosDB("cosmos");

// Add applications
builder.AddProject<Projects.WebApi>("api")
    .WithReference(cache)
    .WithReference(cosmos);

builder.AddProject<Projects.WebApp>("frontend")
    .WithReference("api");

builder.Build().Run();
```

## Azure Resource Naming Customization

One common requirement is customizing Azure resource names instead of using auto-generated ones.

### Per Resource Customization
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

### Global Naming Convention
```csharp
builder.Services.Configure<AzureProvisioningOptions>(options =>
{
    options.ProvisioningBuildOptions.InfrastructureResolvers.Insert(0, 
        new CompanyNamingResolver());
});

internal sealed class CompanyNamingResolver : InfrastructureResolver
{
    public override void ResolveProperties(ProvisionableConstruct construct, ProvisioningBuildOptions options)
    {
        if (construct is CosmosDBAccount account)
        {
            account.Name = "MyCustomCosmosDb";
        }
        base.ResolveProperties(construct, options);
    }
}
```

## Development Best Practices

### 1. **Service Configuration**
```csharp
// Use structured configuration
builder.AddProject<Projects.WebApi>("api")
    .WithEnvironment("ConnectionStrings__DefaultConnection", connectionString)
    .WithEnvironment("Features__UseCache", "true");
```

### 2. **Health Checks**
```csharp
// In service projects
builder.Services.AddHealthChecks()
    .AddCosmosDb(connectionString)
    .AddRedis(redisConnectionString);
```

### 3. **Observability**
```csharp
// Built-in telemetry
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing.AddAspNetCoreInstrumentation())
    .WithMetrics(metrics => metrics.AddAspNetCoreInstrumentation());
```

## Project Templates

### API Service Template
```csharp
var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults(); // Aspire defaults

builder.Services.AddControllers();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.MapDefaultEndpoints(); // Health checks, etc.
app.MapControllers();

app.Run();
```

### Worker Service Template
```csharp
var builder = Host.CreateApplicationBuilder(args);

builder.AddServiceDefaults();
builder.Services.AddHostedService<Worker>();

var host = builder.Build();
host.Run();
```

## Testing Strategies

### Integration Testing
```csharp
public class AspireIntegrationTests : IClassFixture<DistributedApplicationTestingBuilder>
{
    [Fact]
    public async Task GetWeatherForecast_ReturnsSuccessAndCorrectContentType()
    {
        // Arrange
        var app = await _appHost.BuildAsync();
        await app.StartAsync();

        // Act & Assert
        var httpClient = app.CreateHttpClient("api");
        var response = await httpClient.GetAsync("/weatherforecast");
        
        response.EnsureSuccessStatusCode();
    }
}
```

## Related Topics

- [Azure Resource Naming Customization](../../06_Cloud/Azure/AspireResourceNaming.md)
- [Microservices Patterns](../../02_Architecture/ArchitecturalPatterns/Microservices/)
- [Testing Strategies](../DevelopmentPractices/Testing/)
- [DevOps Integration](../../07_DevOps/CI_CD/)

---

*.NET Aspire provides a comprehensive platform for building cloud-native applications with built-in best practices for observability, configuration, and deployment.*
