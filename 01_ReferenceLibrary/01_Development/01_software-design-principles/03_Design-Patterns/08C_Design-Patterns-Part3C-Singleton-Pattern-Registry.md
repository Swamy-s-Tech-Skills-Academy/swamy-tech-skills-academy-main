# 08C_Design-Patterns-Part3C-Singleton-Pattern-Registry

**Learning Level**: Advanced  
**Prerequisites**: Parts A & B - Singleton patterns and modern alternatives  
**Estimated Time**: Part C of 3 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master advanced registry patterns as alternatives to multiple singletons
- Evaluate when to use Singleton vs modern alternatives across different scenarios
- Apply enterprise-grade service management patterns for complex applications
- Design comprehensive singleton strategies for large-scale systems

## 📋 Content Sections (27-Minute Structure)

### Advanced Service Registry Patterns (12 minutes)

#### Enterprise Service Registry with Lifecycle Management

```csharp
// Advanced service registry with lifecycle management and scoping
public interface IAdvancedServiceRegistry
{
    void RegisterSingleton<T>(T service) where T : class;
    void RegisterSingleton<T>(Func<T> factory) where T : class;
    void RegisterTransient<T>(Func<T> factory) where T : class;
    void RegisterScoped<T>(Func<T> factory) where T : class;
    T GetService<T>() where T : class;
    void BeginScope();
    void EndScope();
    void Dispose();
}

public enum ServiceLifetime
{
    Singleton,  // One instance for entire application
    Transient,  // New instance every time
    Scoped      // One instance per scope
}

public class ServiceRegistration
{
    public Type ServiceType { get; set; }
    public object Instance { get; set; }
    public Func<object> Factory { get; set; }
    public ServiceLifetime Lifetime { get; set; }
    public DateTime CreatedAt { get; set; }
    public int AccessCount { get; set; }
    
    public void IncrementAccess()
    {
        Interlocked.Increment(ref AccessCount);
    }
}

public class AdvancedServiceRegistry : IAdvancedServiceRegistry, IDisposable
{
    private static readonly Lazy<AdvancedServiceRegistry> _instance = 
        new Lazy<AdvancedServiceRegistry>(() => new AdvancedServiceRegistry());
    
    private readonly Dictionary<Type, ServiceRegistration> _registrations = new();
    private readonly Dictionary<Type, object> _scopedInstances = new();
    private readonly object _lock = new object();
    private bool _isInScope = false;
    private readonly List<IDisposable> _disposables = new();
    
    private AdvancedServiceRegistry() { }
    
    public static AdvancedServiceRegistry Instance => _instance.Value;
    
    public void RegisterSingleton<T>(T service) where T : class
    {
        if (service == null)
            throw new ArgumentNullException(nameof(service));
        
        lock (_lock)
        {
            _registrations[typeof(T)] = new ServiceRegistration
            {
                ServiceType = typeof(T),
                Instance = service,
                Lifetime = ServiceLifetime.Singleton,
                CreatedAt = DateTime.UtcNow
            };
            
            // Track disposables for cleanup
            if (service is IDisposable disposable)
            {
                _disposables.Add(disposable);
            }
        }
    }
    
    public void RegisterSingleton<T>(Func<T> factory) where T : class
    {
        if (factory == null)
            throw new ArgumentNullException(nameof(factory));
        
        lock (_lock)
        {
            _registrations[typeof(T)] = new ServiceRegistration
            {
                ServiceType = typeof(T),
                Factory = () => factory(),
                Lifetime = ServiceLifetime.Singleton,
                CreatedAt = DateTime.UtcNow
            };
        }
    }
    
    public void RegisterTransient<T>(Func<T> factory) where T : class
    {
        if (factory == null)
            throw new ArgumentNullException(nameof(factory));
        
        lock (_lock)
        {
            _registrations[typeof(T)] = new ServiceRegistration
            {
                ServiceType = typeof(T),
                Factory = () => factory(),
                Lifetime = ServiceLifetime.Transient,
                CreatedAt = DateTime.UtcNow
            };
        }
    }
    
    public void RegisterScoped<T>(Func<T> factory) where T : class
    {
        if (factory == null)
            throw new ArgumentNullException(nameof(factory));
        
        lock (_lock)
        {
            _registrations[typeof(T)] = new ServiceRegistration
            {
                ServiceType = typeof(T),
                Factory = () => factory(),
                Lifetime = ServiceLifetime.Scoped,
                CreatedAt = DateTime.UtcNow
            };
        }
    }
    
    public T GetService<T>() where T : class
    {
        lock (_lock)
        {
            if (!_registrations.TryGetValue(typeof(T), out var registration))
            {
                throw new InvalidOperationException($"Service of type {typeof(T).Name} is not registered");
            }
            
            registration.IncrementAccess();
            
            return registration.Lifetime switch
            {
                ServiceLifetime.Singleton => GetSingletonService<T>(registration),
                ServiceLifetime.Transient => GetTransientService<T>(registration),
                ServiceLifetime.Scoped => GetScopedService<T>(registration),
                _ => throw new InvalidOperationException($"Unknown service lifetime: {registration.Lifetime}")
            };
        }
    }
    
    private T GetSingletonService<T>(ServiceRegistration registration) where T : class
    {
        if (registration.Instance != null)
        {
            return (T)registration.Instance;
        }
        
        if (registration.Factory != null)
        {
            var newInstance = (T)registration.Factory();
            registration.Instance = newInstance;
            
            // Track disposables
            if (newInstance is IDisposable disposable)
            {
                _disposables.Add(disposable);
            }
            
            return newInstance;
        }
        
        throw new InvalidOperationException("No instance or factory available for singleton service");
    }
    
    private T GetTransientService<T>(ServiceRegistration registration) where T : class
    {
        if (registration.Factory == null)
        {
            throw new InvalidOperationException("No factory available for transient service");
        }
        
        return (T)registration.Factory();
    }
    
    private T GetScopedService<T>(ServiceRegistration registration) where T : class
    {
        if (!_isInScope)
        {
            throw new InvalidOperationException("Scoped services can only be resolved within a scope. Call BeginScope() first.");
        }
        
        if (_scopedInstances.TryGetValue(typeof(T), out var existingInstance))
        {
            return (T)existingInstance;
        }
        
        if (registration.Factory == null)
        {
            throw new InvalidOperationException("No factory available for scoped service");
        }
        
        var newInstance = (T)registration.Factory();
        _scopedInstances[typeof(T)] = newInstance;
        
        return newInstance;
    }
    
    public void BeginScope()
    {
        lock (_lock)
        {
            if (_isInScope)
            {
                throw new InvalidOperationException("Already in scope. Call EndScope() before beginning a new scope.");
            }
            
            _isInScope = true;
            _scopedInstances.Clear();
        }
    }
    
    public void EndScope()
    {
        lock (_lock)
        {
            if (!_isInScope)
            {
                return; // Already ended or never began
            }
            
            // Dispose scoped services that implement IDisposable
            foreach (var instance in _scopedInstances.Values.OfType<IDisposable>())
            {
                try
                {
                    instance.Dispose();
                }
                catch (Exception ex)
                {
                    // Log disposal errors but don't throw
                    Console.WriteLine($"Error disposing scoped service: {ex.Message}");
                }
            }
            
            _scopedInstances.Clear();
            _isInScope = false;
        }
    }
    
    public ServiceStatistics GetStatistics()
    {
        lock (_lock)
        {
            return new ServiceStatistics
            {
                TotalRegistrations = _registrations.Count,
                SingletonServices = _registrations.Values.Count(r => r.Lifetime == ServiceLifetime.Singleton),
                TransientServices = _registrations.Values.Count(r => r.Lifetime == ServiceLifetime.Transient),
                ScopedServices = _registrations.Values.Count(r => r.Lifetime == ServiceLifetime.Scoped),
                IsInScope = _isInScope,
                ScopedInstanceCount = _scopedInstances.Count,
                MostAccessedService = _registrations.Values
                    .OrderByDescending(r => r.AccessCount)
                    .FirstOrDefault()?.ServiceType?.Name ?? "None"
            };
        }
    }
    
    public void Dispose()
    {
        lock (_lock)
        {
            EndScope(); // Clean up any active scope
            
            // Dispose all tracked disposables
            foreach (var disposable in _disposables)
            {
                try
                {
                    disposable.Dispose();
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error disposing service: {ex.Message}");
                }
            }
            
            _disposables.Clear();
            _registrations.Clear();
        }
    }
}

public class ServiceStatistics
{
    public int TotalRegistrations { get; set; }
    public int SingletonServices { get; set; }
    public int TransientServices { get; set; }
    public int ScopedServices { get; set; }
    public bool IsInScope { get; set; }
    public int ScopedInstanceCount { get; set; }
    public string MostAccessedService { get; set; }
    
    public override string ToString()
    {
        return $"Registrations: {TotalRegistrations} (Singleton: {SingletonServices}, Transient: {TransientServices}, Scoped: {ScopedServices}), " +
               $"InScope: {IsInScope}, ScopedInstances: {ScopedInstanceCount}, MostAccessed: {MostAccessedService}";
    }
}
```

#### Enterprise Usage Example

```csharp
// Comprehensive enterprise service management example
public class EnterpriseServiceDemo
{
    public static void RunDemo()
    {
        Console.WriteLine("=== Advanced Service Registry Demo ===\n");
        
        var registry = AdvancedServiceRegistry.Instance;
        
        // Setup services with different lifetimes
        SetupEnterpriseServices(registry);
        
        // Demonstrate scoped operations
        DemonstrateServerRequestProcessing(registry);
        
        // Show service statistics
        ShowServiceStatistics(registry);
        
        // Cleanup
        registry.Dispose();
    }
    
    private static void SetupEnterpriseServices(AdvancedServiceRegistry registry)
    {
        Console.WriteLine("--- Setting up Enterprise Services ---");
        
        // Singleton services - shared across entire application
        registry.RegisterSingleton<IConfigurationService>(new ConfigurationService());
        registry.RegisterSingleton<IApplicationLogger>(() => 
            ApplicationLogger.CreateWithWriter(new ConsoleLogWriter()));
        
        // Transient services - new instance every time
        registry.RegisterTransient<IEmailService>(() => 
        {
            var logger = registry.GetService<IApplicationLogger>();
            var config = registry.GetService<IConfigurationService>();
            return new EmailService(logger, config);
        });
        
        // Scoped services - one instance per request/scope
        registry.RegisterScoped<IDatabaseService>(() => 
        {
            var config = registry.GetService<IConfigurationService>();
            return new DatabaseService(config);
        });
        
        registry.RegisterScoped<IBusinessService>(() => 
        {
            var config = registry.GetService<IConfigurationService>();
            var database = registry.GetService<IDatabaseService>();
            return new BusinessService(config, database);
        });
        
        Console.WriteLine("Enterprise services registered successfully\n");
    }
    
    private static void DemonstrateServerRequestProcessing(AdvancedServiceRegistry registry)
    {
        Console.WriteLine("--- Simulating Server Request Processing ---");
        
        // Simulate multiple HTTP requests
        for (int requestId = 1; requestId <= 3; requestId++)
        {
            Console.WriteLine($"\n** Processing Request {requestId} **");
            
            // Begin new scope for this request
            registry.BeginScope();
            
            try
            {
                // Singleton services - same instance across all requests
                var logger = registry.GetService<IApplicationLogger>();
                logger.LogInfo($"Request {requestId} started");
                
                // Scoped services - same instance within this request
                var businessService1 = registry.GetService<IBusinessService>();
                var businessService2 = registry.GetService<IBusinessService>();
                
                Console.WriteLine($"BusinessService instances same? {ReferenceEquals(businessService1, businessService2)}");
                
                // Transient services - new instance every time
                var emailService1 = registry.GetService<IEmailService>();
                var emailService2 = registry.GetService<IEmailService>();
                
                Console.WriteLine($"EmailService instances same? {ReferenceEquals(emailService1, emailService2)}");
                
                // Simulate business operations
                _ = businessService1.ProcessDataAsync($"Data from request {requestId}");
                _ = emailService1.SendEmailAsync("user@example.com", "Request Processed", 
                    $"Request {requestId} completed successfully");
                
                logger.LogInfo($"Request {requestId} completed");
            }
            catch (Exception ex)
            {
                var logger = registry.GetService<IApplicationLogger>();
                logger.LogError($"Request {requestId} failed", ex);
            }
            finally
            {
                // End scope - disposes scoped services
                registry.EndScope();
                Console.WriteLine($"Request {requestId} scope ended");
            }
        }
    }
    
    private static void ShowServiceStatistics(AdvancedServiceRegistry registry)
    {
        Console.WriteLine("\n--- Service Registry Statistics ---");
        
        var stats = registry.GetStatistics();
        Console.WriteLine(stats.ToString());
        
        Console.WriteLine("\nService Usage Analysis:");
        Console.WriteLine("- Singleton services maintain state across requests");
        Console.WriteLine("- Scoped services created once per request, disposed at end");
        Console.WriteLine("- Transient services created fresh for each resolution");
        Console.WriteLine("- Registry tracks access patterns for monitoring");
    }
}
```

### Decision Framework: When to Use Each Pattern (8 minutes)

#### Pattern Selection Guide

```csharp
// Pattern selection framework for enterprise applications
public static class SingletonPatternDecisionFramework
{
    public static class DecisionMatrix
    {
        public static PatternRecommendation AnalyzeScenario(ScenarioAnalysis scenario)
        {
            var score = new PatternScores();
            
            // Analyze requirements
            AnalyzeTestability(scenario, score);
            AnalyzePerformance(scenario, score);
            AnalyzeComplexity(scenario, score);
            AnalyzeScalability(scenario, score);
            AnalyzeMaintainability(scenario, score);
            
            return GetRecommendation(score);
        }
        
        private static void AnalyzeTestability(ScenarioAnalysis scenario, PatternScores score)
        {
            if (scenario.RequiresUnitTesting)
            {
                score.DependencyInjection += 3;
                score.TestableSingleton += 2;
                score.ServiceRegistry += 2;
                score.TraditionalSingleton -= 2;
            }
        }
        
        private static void AnalyzePerformance(ScenarioAnalysis scenario, PatternScores score)
        {
            if (scenario.HighPerformanceRequired)
            {
                score.TraditionalSingleton += 2;
                score.TestableSingleton += 2;
                score.ServiceRegistry += 1;
                score.DependencyInjection -= 1; // Slight overhead
            }
        }
        
        private static void AnalyzeComplexity(ScenarioAnalysis scenario, PatternScores score)
        {
            if (scenario.SimpleUseCase)
            {
                score.TraditionalSingleton += 2;
                score.StaticClass += 3;
                score.DependencyInjection -= 1;
                score.ServiceRegistry -= 2;
            }
            else
            {
                score.DependencyInjection += 2;
                score.ServiceRegistry += 1;
            }
        }
        
        private static void AnalyzeScalability(ScenarioAnalysis scenario, PatternScores score)
        {
            if (scenario.MultipleServices)
            {
                score.ServiceRegistry += 3;
                score.DependencyInjection += 2;
                score.TraditionalSingleton -= 1;
            }
            
            if (scenario.EnterpriseScale)
            {
                score.DependencyInjection += 3;
                score.ServiceRegistry += 2;
                score.TraditionalSingleton -= 2;
            }
        }
        
        private static void AnalyzeMaintainability(ScenarioAnalysis scenario, PatternScores score)
        {
            if (scenario.TeamDevelopment)
            {
                score.DependencyInjection += 2;
                score.TestableSingleton += 1;
                score.TraditionalSingleton -= 1;
            }
            
            if (scenario.ConfigurationManagement)
            {
                score.DependencyInjection += 2;
                score.ServiceRegistry += 1;
            }
        }
        
        private static PatternRecommendation GetRecommendation(PatternScores scores)
        {
            var maxScore = Math.Max(Math.Max(scores.TraditionalSingleton, scores.TestableSingleton),
                                  Math.Max(scores.DependencyInjection, Math.Max(scores.ServiceRegistry, scores.StaticClass)));
            
            var recommendations = new List<PatternOption>();
            
            if (scores.DependencyInjection == maxScore)
                recommendations.Add(new PatternOption { Pattern = "Dependency Injection", Score = scores.DependencyInjection, Description = "Best for enterprise applications with complex dependencies" });
            
            if (scores.ServiceRegistry == maxScore)
                recommendations.Add(new PatternOption { Pattern = "Service Registry", Score = scores.ServiceRegistry, Description = "Good for managing multiple singleton-like services" });
            
            if (scores.TestableSingleton == maxScore)
                recommendations.Add(new PatternOption { Pattern = "Testable Singleton", Score = scores.TestableSingleton, Description = "Hybrid approach for gradual migration" });
            
            if (scores.TraditionalSingleton == maxScore)
                recommendations.Add(new PatternOption { Pattern = "Traditional Singleton", Score = scores.TraditionalSingleton, Description = "Simple cases with minimal dependencies" });
            
            if (scores.StaticClass == maxScore)
                recommendations.Add(new PatternOption { Pattern = "Static Class", Score = scores.StaticClass, Description = "Stateless utility functions" });
            
            return new PatternRecommendation
            {
                PrimaryRecommendation = recommendations.OrderByDescending(r => r.Score).First(),
                AlternativeOptions = recommendations.OrderByDescending(r => r.Score).Skip(1).Take(2).ToList(),
                Analysis = $"Based on scenario analysis, scores: DI={scores.DependencyInjection}, Registry={scores.ServiceRegistry}, " +
                          $"Testable={scores.TestableSingleton}, Traditional={scores.TraditionalSingleton}, Static={scores.StaticClass}"
            };
        }
    }
    
    public class ScenarioAnalysis
    {
        public bool RequiresUnitTesting { get; set; } = true;
        public bool HighPerformanceRequired { get; set; } = false;
        public bool SimpleUseCase { get; set; } = false;
        public bool MultipleServices { get; set; } = false;
        public bool EnterpriseScale { get; set; } = false;
        public bool TeamDevelopment { get; set; } = false;
        public bool ConfigurationManagement { get; set; } = false;
    }
    
    private class PatternScores
    {
        public int TraditionalSingleton { get; set; } = 0;
        public int TestableSingleton { get; set; } = 0;
        public int DependencyInjection { get; set; } = 0;
        public int ServiceRegistry { get; set; } = 0;
        public int StaticClass { get; set; } = 0;
    }
    
    public class PatternOption
    {
        public string Pattern { get; set; }
        public int Score { get; set; }
        public string Description { get; set; }
    }
    
    public class PatternRecommendation
    {
        public PatternOption PrimaryRecommendation { get; set; }
        public List<PatternOption> AlternativeOptions { get; set; } = new();
        public string Analysis { get; set; }
    }
    
    // Common scenarios and their recommendations
    public static class CommonScenarios
    {
        public static PatternRecommendation AnalyzeLoggingService()
        {
            return DecisionMatrix.AnalyzeScenario(new ScenarioAnalysis
            {
                RequiresUnitTesting = true,
                HighPerformanceRequired = true,
                SimpleUseCase = false,
                TeamDevelopment = true
            });
        }
        
        public static PatternRecommendation AnalyzeConfigurationManager()
        {
            return DecisionMatrix.AnalyzeScenario(new ScenarioAnalysis
            {
                RequiresUnitTesting = true,
                ConfigurationManagement = true,
                TeamDevelopment = true,
                EnterpriseScale = true
            });
        }
        
        public static PatternRecommendation AnalyzeCacheManager()
        {
            return DecisionMatrix.AnalyzeScenario(new ScenarioAnalysis
            {
                RequiresUnitTesting = true,
                HighPerformanceRequired = true,
                SimpleUseCase = false,
                EnterpriseScale = true
            });
        }
        
        public static PatternRecommendation AnalyzeUtilityClass()
        {
            return DecisionMatrix.AnalyzeScenario(new ScenarioAnalysis
            {
                RequiresUnitTesting = false,
                SimpleUseCase = true,
                HighPerformanceRequired = true
            });
        }
    }
}

// Usage demonstration
public class DecisionFrameworkDemo
{
    public static void RunDecisionAnalysis()
    {
        Console.WriteLine("=== Singleton Pattern Decision Framework ===\n");
        
        AnalyzeCommonScenarios();
        AnalyzeCustomScenario();
    }
    
    private static void AnalyzeCommonScenarios()
    {
        Console.WriteLine("--- Common Scenario Analysis ---\n");
        
        var scenarios = new[]
        {
            ("Logging Service", SingletonPatternDecisionFramework.CommonScenarios.AnalyzeLoggingService()),
            ("Configuration Manager", SingletonPatternDecisionFramework.CommonScenarios.AnalyzeConfigurationManager()),
            ("Cache Manager", SingletonPatternDecisionFramework.CommonScenarios.AnalyzeCacheManager()),
            ("Utility Class", SingletonPatternDecisionFramework.CommonScenarios.AnalyzeUtilityClass())
        };
        
        foreach (var (scenarioName, recommendation) in scenarios)
        {
            Console.WriteLine($"{scenarioName}:");
            Console.WriteLine($"  Primary: {recommendation.PrimaryRecommendation.Pattern} (Score: {recommendation.PrimaryRecommendation.Score})");
            Console.WriteLine($"  Reason: {recommendation.PrimaryRecommendation.Description}");
            
            if (recommendation.AlternativeOptions.Any())
            {
                Console.WriteLine($"  Alternatives: {string.Join(", ", recommendation.AlternativeOptions.Select(a => a.Pattern))}");
            }
            
            Console.WriteLine();
        }
    }
    
    private static void AnalyzeCustomScenario()
    {
        Console.WriteLine("--- Custom Enterprise Application Analysis ---");
        
        var customScenario = new SingletonPatternDecisionFramework.ScenarioAnalysis
        {
            RequiresUnitTesting = true,
            HighPerformanceRequired = false,
            SimpleUseCase = false,
            MultipleServices = true,
            EnterpriseScale = true,
            TeamDevelopment = true,
            ConfigurationManagement = true
        };
        
        var recommendation = SingletonPatternDecisionFramework.DecisionMatrix.AnalyzeScenario(customScenario);
        
        Console.WriteLine("Enterprise Web Application Scenario:");
        Console.WriteLine($"Primary Recommendation: {recommendation.PrimaryRecommendation.Pattern}");
        Console.WriteLine($"Reasoning: {recommendation.PrimaryRecommendation.Description}");
        Console.WriteLine($"Analysis: {recommendation.Analysis}");
    }
}
```

### Enterprise Implementation Guidelines & Next Steps (7 minutes)

#### Migration Strategy from Traditional Singletons

```csharp
// Step-by-step migration guide
public static class SingletonMigrationGuide
{
    public static void ExecuteMigrationPlan()
    {
        Console.WriteLine("=== Singleton Migration Strategy ===\n");
        
        // Step 1: Assessment
        AssessExistingSingletons();
        
        // Step 2: Extract Interfaces
        ExtractInterfacesExample();
        
        // Step 3: Add Constructor Injection
        AddConstructorInjectionExample();
        
        // Step 4: Register in DI Container
        RegisterInDIContainerExample();
        
        // Step 5: Remove Static Access
        RemoveStaticAccessExample();
    }
    
    private static void AssessExistingSingletons()
    {
        Console.WriteLine("--- Step 1: Assess Existing Singletons ---");
        Console.WriteLine("✓ Identify all singleton patterns in codebase");
        Console.WriteLine("✓ Categorize by usage: configuration, logging, caching, etc.");
        Console.WriteLine("✓ Evaluate testability and coupling issues");
        Console.WriteLine("✓ Prioritize migration based on pain points\n");
    }
    
    private static void ExtractInterfacesExample()
    {
        Console.WriteLine("--- Step 2: Extract Interfaces ---");
        Console.WriteLine("// Before: Tightly coupled singleton");
        Console.WriteLine("public class OldLogger { public static OldLogger Instance { get; } }");
        Console.WriteLine();
        Console.WriteLine("// After: Interface-based design");
        Console.WriteLine("public interface ILogger { void Log(string message); }");
        Console.WriteLine("public class Logger : ILogger { ... }\n");
    }
    
    private static void AddConstructorInjectionExample()
    {
        Console.WriteLine("--- Step 3: Add Constructor Injection ---");
        Console.WriteLine("// Hybrid approach supporting both patterns");
        Console.WriteLine("public class Logger : ILogger");
        Console.WriteLine("{");
        Console.WriteLine("    private static readonly Lazy<Logger> _instance = new();");
        Console.WriteLine("    public static ILogger Instance => _instance.Value;");
        Console.WriteLine("    ");
        Console.WriteLine("    public Logger() { } // For DI");
        Console.WriteLine("    internal Logger(IWriter writer) { } // For testing");
        Console.WriteLine("}\n");
    }
    
    private static void RegisterInDIContainerExample()
    {
        Console.WriteLine("--- Step 4: Register in DI Container ---");
        Console.WriteLine("// ASP.NET Core registration");
        Console.WriteLine("services.AddSingleton<ILogger, Logger>();");
        Console.WriteLine("services.AddScoped<IBusinessService, BusinessService>();");
        Console.WriteLine();
        Console.WriteLine("// Service consumption");
        Console.WriteLine("public class BusinessService");
        Console.WriteLine("{");
        Console.WriteLine("    public BusinessService(ILogger logger) { ... }");
        Console.WriteLine("}\n");
    }
    
    private static void RemoveStaticAccessExample()
    {
        Console.WriteLine("--- Step 5: Remove Static Access (Final Step) ---");
        Console.WriteLine("// Remove static access once DI is fully adopted");
        Console.WriteLine("// Before: MyService.Logger.Instance.Log(...)");
        Console.WriteLine("// After:  _logger.Log(...)  // Injected dependency");
        Console.WriteLine();
        Console.WriteLine("⚠️  Only remove static access after verifying all usage");
        Console.WriteLine("   has been migrated to dependency injection\n");
    }
}
```

#### Key Takeaways & Best Practices

**Singleton Pattern Benefits**:

- ✅ **Controlled instantiation**: Exactly one instance guaranteed
- ✅ **Global access point**: Available throughout application
- ✅ **Resource management**: Shared resources like connections, caches
- ✅ **State consistency**: Single source of truth for configuration

**Singleton Pattern Drawbacks**:

- ❌ **Testing difficulties**: Hard to mock, shared state between tests
- ❌ **Tight coupling**: Global dependencies make code less flexible
- ❌ **Thread safety complexity**: Requires careful synchronization
- ❌ **Violation of Single Responsibility**: Often manages lifetime + functionality

**Modern Alternatives Decision Guide**:

| Use Case | Best Pattern | Reasoning |
|----------|-------------|-----------|
| **ASP.NET Core Applications** | Dependency Injection | Built-in container, excellent testability |
| **Legacy Codebases** | Testable Singleton | Gradual migration path |
| **Multiple Related Services** | Service Registry | Centralized service management |
| **Simple Utility Functions** | Static Class | No state, pure functions |
| **Enterprise Applications** | DI + Service Registry | Scalability and maintainability |

**Implementation Best Practices**:

1. **Use `Lazy<T>`** for thread-safe lazy initialization
2. **Prefer DI container registration** over manual singletons
3. **Design for testability** with constructor injection
4. **Consider lifetime carefully** - not everything needs to be singleton
5. **Plan migration strategy** for existing singleton patterns

**Performance Optimization**:

- Service registry adds minimal overhead (~1-2% in most scenarios)
- DI containers optimize for common usage patterns
- Thread-safe patterns using `Lazy<T>` perform better than manual locking

**Next Learning Steps**:

- **Structural Patterns**: Adapter, Decorator, Facade
- **Advanced DI Patterns**: Service locator, factory registration
- **Microservice Patterns**: Service discovery and configuration management

## 🔗 Related Topics

**Prerequisites**:

- [Parts A & B](08A_Design-Patterns-Part3A-Singleton-Pattern-Fundamentals.md) - Complete Singleton pattern foundation
- Advanced dependency injection patterns
- Enterprise service architecture concepts

**Builds Upon**:

- Service lifetime management principles
- Registry and locator patterns
- Enterprise application architecture

**Enables**:

- [Microservice Configuration](../../architecture/microservice-patterns/) patterns
- [Enterprise Service Architecture](../../architecture/service-architecture/) design
- [Advanced Testing Patterns](../../testing/advanced-patterns/) for complex systems

**Next Patterns**:

- [Adapter Pattern](../../structural-patterns/adapter/) - Interface compatibility
- [Decorator Pattern](../../structural-patterns/decorator/) - Behavior enhancement
- [Facade Pattern](../../structural-patterns/facade/) - Interface simplification
