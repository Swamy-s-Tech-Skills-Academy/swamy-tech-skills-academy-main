# 13C_Design-Patterns-Part8C-Template-Method-Testing

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Template Method Authentication (Part B), Testing concepts, Setup/Teardown patterns  
**Estimated Time**: Part C of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement test execution frameworks using Template Method Pattern
- Design automated testing pipelines with consistent setup/teardown procedures
- Apply template methods to unit testing, integration testing, and performance testing
- Master test result reporting and error handling with pluggable verification steps

## 📋 Content Sections (27-Minute Structure)

### Testing Framework Architecture (5 minutes)

**Testing Challenge**: Different types of tests (unit, integration, performance) require consistent execution flow while allowing customization of test logic and verification steps.

```text
✅ TEMPLATE METHOD FOR TESTING
              ┌─────────────────────┐
              │ TestRunner<T>       │
              ├─────────────────────┤
              │ + RunTest()         │◄─── Template Method
              │   SetupTest()       │◄─── Hook Method
              │   ExecuteTest()     │◄─── Abstract Method
              │   VerifyResults()   │◄─── Abstract Method
              │   CleanupTest()     │◄─── Hook Method
              │   FinalCleanup()    │◄─── Hook Method
              └─────────────────────┘
                       ▲
         ┌─────────────┼─────────────┐
┌─────────────────┐    │    ┌─────────────────┐
│ UnitTestRunner  │    │    │ IntegrationTest │
├─────────────────┤    │    ├─────────────────┤
│ +ExecuteTest()  │    │    │ +ExecuteTest()  │
│ +VerifyResults()│    │    │ +VerifyResults()│
│ +SetupTest()    │    │    │ +SetupTest()    │
└─────────────────┘    │    │ +CleanupTest()  │
                       │    └─────────────────┘
              ┌─────────────────┐
              │ PerformanceTest │
              ├─────────────────┤
              │ +ExecuteTest()  │
              │ +VerifyResults()│
              │ +SetupTest()    │
              │ +CleanupTest()  │
              └─────────────────┘
```

### Core Testing Framework (15 minutes)

#### Abstract Test Runner Template

```csharp
// Abstract test runner template
public abstract class TestRunner<T>
{
    public string TestName { get; protected set; }
    public DateTime LastRun { get; private set; }
    public TimeSpan LastExecutionTime { get; private set; }
    public TestResult LastResult { get; private set; }

    protected TestRunner(string testName)
    {
        TestName = testName ?? throw new ArgumentNullException(nameof(testName));
    }

    // Template method - defines test execution flow
    public TestResult RunTest(T testData)
    {
        var stopwatch = Stopwatch.StartNew();
        var result = new TestResult { TestName = TestName, StartTime = DateTime.UtcNow };

        try
        {
            LogTestStart();

            // Step 1: Setup (hook method - optional override)
            SetupTest();
            result.SetupCompleted = true;

            // Step 2: Execute test (abstract method - must implement)
            var testResult = ExecuteTest(testData);
            result.TestCompleted = true;
            result.IsSuccessful = testResult;

            // Step 3: Verify results (abstract method - must implement)
            var verificationResult = VerifyResults();
            result.VerificationCompleted = true;
            result.IsSuccessful = result.IsSuccessful && verificationResult;

            // Step 4: Cleanup (hook method - optional override)
            CleanupTest();
            result.CleanupCompleted = true;

            if (result.IsSuccessful)
            {
                OnTestSuccess(result);
            }
            else
            {
                OnTestFailure(result);
            }
        }
        catch (Exception ex)
        {
            result.IsSuccessful = false;
            result.ErrorMessage = ex.Message;
            result.Exception = ex;
            OnTestError(result, ex);
        }
        finally
        {
            // Always ensure cleanup, even if test failed
            try
            {
                FinalCleanup();
            }
            catch (Exception cleanupEx)
            {
                result.CleanupErrors.Add(cleanupEx.Message);
            }

            stopwatch.Stop();
            result.EndTime = DateTime.UtcNow;
            result.ExecutionTime = stopwatch.Elapsed;
            
            LastRun = DateTime.UtcNow;
            LastExecutionTime = stopwatch.Elapsed;
            LastResult = result;
            
            LogTestComplete(result);
        }

        return result;
    }

    // Abstract methods - must be implemented by subclasses
    protected abstract bool ExecuteTest(T testData);
    protected abstract bool VerifyResults();

    // Hook methods - can be overridden by subclasses
    protected virtual void SetupTest() { /* Default: no setup needed */ }
    protected virtual void CleanupTest() { /* Default: no cleanup needed */ }
    protected virtual void FinalCleanup() { /* Default: no final cleanup */ }
    protected virtual void OnTestSuccess(TestResult result) { /* Default: no action */ }
    protected virtual void OnTestFailure(TestResult result) { /* Default: no action */ }
    protected virtual void OnTestError(TestResult result, Exception error) { /* Default: no action */ }

    // Concrete logging methods - same for all test types
    private void LogTestStart()
    {
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] 🧪 Starting test: {TestName}");
    }

    private void LogTestComplete(TestResult result)
    {
        var status = result.IsSuccessful ? "✅ PASSED" : "❌ FAILED";
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {status} - {TestName} ({result.ExecutionTime.TotalMilliseconds:F0}ms)");
        
        if (!result.IsSuccessful && !string.IsNullOrEmpty(result.ErrorMessage))
        {
            Console.WriteLine($"  Error: {result.ErrorMessage}");
        }
        
        if (result.CleanupErrors.Any())
        {
            Console.WriteLine($"  Cleanup Issues: {string.Join("; ", result.CleanupErrors)}");
        }
    }
}
```

#### Test Result Container

```csharp
public class TestResult
{
    public string TestName { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public TimeSpan ExecutionTime { get; set; }
    public bool IsSuccessful { get; set; }
    public string ErrorMessage { get; set; }
    public Exception Exception { get; set; }
    
    // Execution phase tracking
    public bool SetupCompleted { get; set; }
    public bool TestCompleted { get; set; }
    public bool VerificationCompleted { get; set; }
    public bool CleanupCompleted { get; set; }
    
    public List<string> CleanupErrors { get; set; }
    public Dictionary<string, object> Metadata { get; set; }

    public TestResult()
    {
        CleanupErrors = new List<string>();
        Metadata = new Dictionary<string, object>();
    }

    public void AddMetadata(string key, object value)
    {
        Metadata[key] = value;
    }

    public string GetSummary()
    {
        var phases = new List<string>();
        if (SetupCompleted) phases.Add("Setup");
        if (TestCompleted) phases.Add("Execution");
        if (VerificationCompleted) phases.Add("Verification");
        if (CleanupCompleted) phases.Add("Cleanup");

        return $"{TestName}: {(IsSuccessful ? "PASSED" : "FAILED")} " +
               $"(Phases: {string.Join(" → ", phases)}, Duration: {ExecutionTime.TotalMilliseconds:F0}ms)";
    }
}
```

#### Unit Test Implementation

```csharp
public class UnitTestRunner : TestRunner<Func<bool>>
{
    private readonly string _methodName;
    private object _testResult;

    public UnitTestRunner(string testName, string methodName = null) 
        : base(testName)
    {
        _methodName = methodName ?? testName;
    }

    protected override bool ExecuteTest(Func<bool> testLogic)
    {
        if (testLogic == null)
            throw new ArgumentNullException(nameof(testLogic));

        Console.WriteLine($"  Executing unit test logic for: {_methodName}");
        
        try
        {
            _testResult = testLogic();
            return (bool)_testResult;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"  Unit test execution failed: {ex.Message}");
            throw;
        }
    }

    protected override bool VerifyResults()
    {
        if (_testResult == null)
        {
            Console.WriteLine("  ❌ Verification failed: No test result available");
            return false;
        }

        var success = (bool)_testResult;
        Console.WriteLine($"  {(success ? "✅" : "❌")} Unit test verification: {success}");
        return success;
    }

    protected override void OnTestSuccess(TestResult result)
    {
        result.AddMetadata("TestType", "Unit");
        result.AddMetadata("MethodName", _methodName);
        Console.WriteLine($"  ✅ Unit test passed: {_methodName}");
    }

    protected override void OnTestFailure(TestResult result)
    {
        result.AddMetadata("TestType", "Unit");
        result.AddMetadata("MethodName", _methodName);
        Console.WriteLine($"  ❌ Unit test failed: {_methodName}");
    }
}
```

#### Integration Test Implementation

```csharp
public class IntegrationTestRunner : TestRunner<Dictionary<string, object>>
{
    private readonly string _serviceEndpoint;
    private readonly List<string> _tempFiles;
    private readonly List<string> _tempDatabases;
    private Dictionary<string, object> _testOutputs;

    public IntegrationTestRunner(string testName, string serviceEndpoint) 
        : base(testName)
    {
        _serviceEndpoint = serviceEndpoint;
        _tempFiles = new List<string>();
        _tempDatabases = new List<string>();
        _testOutputs = new Dictionary<string, object>();
    }

    protected override void SetupTest()
    {
        Console.WriteLine($"  🔧 Setting up integration test environment");
        
        // Create temporary test database
        var tempDbName = $"test_db_{Guid.NewGuid():N}";
        _tempDatabases.Add(tempDbName);
        Console.WriteLine($"  Created temporary database: {tempDbName}");
        
        // Create temporary test files
        var tempFile = Path.GetTempFileName();
        _tempFiles.Add(tempFile);
        File.WriteAllText(tempFile, "Test data for integration test");
        Console.WriteLine($"  Created temporary file: {tempFile}");
        
        // Initialize service connections
        Console.WriteLine($"  Initializing connection to: {_serviceEndpoint}");
    }

    protected override bool ExecuteTest(Dictionary<string, object> testData)
    {
        Console.WriteLine($"  🏃 Executing integration test with {testData.Count} parameters");
        
        try
        {
            // Simulate integration test steps
            foreach (var kvp in testData)
            {
                Console.WriteLine($"    Processing parameter: {kvp.Key} = {kvp.Value}");
                
                // Simulate API call or database operation
                Thread.Sleep(100); // Simulate processing time
                
                _testOutputs[kvp.Key + "_result"] = $"Processed_{kvp.Value}";
            }
            
            // Simulate service interaction
            Console.WriteLine($"    Calling service endpoint: {_serviceEndpoint}");
            Thread.Sleep(200); // Simulate network call
            
            _testOutputs["service_response"] = "SUCCESS";
            _testOutputs["response_time"] = 200;
            
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"  ❌ Integration test execution failed: {ex.Message}");
            _testOutputs["error"] = ex.Message;
            return false;
        }
    }

    protected override bool VerifyResults()
    {
        Console.WriteLine($"  🔍 Verifying integration test results");
        
        if (!_testOutputs.ContainsKey("service_response"))
        {
            Console.WriteLine("    ❌ Missing service response");
            return false;
        }
        
        if (_testOutputs["service_response"].ToString() != "SUCCESS")
        {
            Console.WriteLine($"    ❌ Service returned: {_testOutputs["service_response"]}");
            return false;
        }
        
        if (_testOutputs.ContainsKey("response_time"))
        {
            var responseTime = (int)_testOutputs["response_time"];
            if (responseTime > 1000) // 1 second threshold
            {
                Console.WriteLine($"    ⚠️ Response time too slow: {responseTime}ms");
                return false;
            }
        }
        
        Console.WriteLine($"    ✅ All integration test verifications passed");
        return true;
    }

    protected override void CleanupTest()
    {
        Console.WriteLine($"  🧹 Cleaning up integration test resources");
        
        // Remove temporary files
        foreach (var file in _tempFiles)
        {
            try
            {
                if (File.Exists(file))
                {
                    File.Delete(file);
                    Console.WriteLine($"    Deleted temporary file: {file}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"    ⚠️ Failed to delete file {file}: {ex.Message}");
            }
        }
    }

    protected override void FinalCleanup()
    {
        // Clean up databases (even if test failed)
        foreach (var db in _tempDatabases)
        {
            try
            {
                Console.WriteLine($"    Dropping temporary database: {db}");
                // Simulate database cleanup
            }
            catch (Exception ex)
            {
                Console.WriteLine($"    ⚠️ Failed to cleanup database {db}: {ex.Message}");
            }
        }
    }

    protected override void OnTestSuccess(TestResult result)
    {
        result.AddMetadata("TestType", "Integration");
        result.AddMetadata("ServiceEndpoint", _serviceEndpoint);
        result.AddMetadata("OutputCount", _testOutputs.Count);
        
        if (_testOutputs.ContainsKey("response_time"))
            result.AddMetadata("ResponseTime", _testOutputs["response_time"]);
    }

    protected override void OnTestFailure(TestResult result)
    {
        result.AddMetadata("TestType", "Integration");
        result.AddMetadata("ServiceEndpoint", _serviceEndpoint);
        
        if (_testOutputs.ContainsKey("error"))
            result.AddMetadata("FailureReason", _testOutputs["error"]);
    }
}
```

### Performance Test Implementation (5 minutes)

```csharp
public class PerformanceTestRunner : TestRunner<PerformanceTestConfig>
{
    private readonly int _iterationCount;
    private readonly TimeSpan _timeLimit;
    private List<double> _executionTimes;
    private PerformanceMetrics _metrics;

    public PerformanceTestRunner(string testName, int iterationCount = 100, TimeSpan? timeLimit = null) 
        : base(testName)
    {
        _iterationCount = iterationCount;
        _timeLimit = timeLimit ?? TimeSpan.FromMinutes(5);
        _executionTimes = new List<double>();
    }

    protected override void SetupTest()
    {
        Console.WriteLine($"  ⚡ Setting up performance test for {_iterationCount} iterations");
        _executionTimes.Clear();
        
        // Warm up the system
        Console.WriteLine($"  🔥 Warming up system...");
        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();
    }

    protected override bool ExecuteTest(PerformanceTestConfig config)
    {
        Console.WriteLine($"  🏁 Running performance test: {config.Operation}");
        
        var overallStopwatch = Stopwatch.StartNew();
        
        for (int i = 0; i < _iterationCount; i++)
        {
            if (overallStopwatch.Elapsed > _timeLimit)
            {
                Console.WriteLine($"    ⏰ Test exceeded time limit after {i} iterations");
                break;
            }
            
            var iterationStopwatch = Stopwatch.StartNew();
            
            try
            {
                // Execute the performance test operation
                config.TestOperation();
                
                iterationStopwatch.Stop();
                _executionTimes.Add(iterationStopwatch.Elapsed.TotalMilliseconds);
                
                if ((i + 1) % 25 == 0)
                {
                    Console.WriteLine($"    Completed {i + 1}/{_iterationCount} iterations");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"    ❌ Iteration {i + 1} failed: {ex.Message}");
                return false;
            }
        }
        
        overallStopwatch.Stop();
        
        // Calculate performance metrics
        _metrics = new PerformanceMetrics
        {
            TotalIterations = _executionTimes.Count,
            AverageTime = _executionTimes.Average(),
            MinTime = _executionTimes.Min(),
            MaxTime = _executionTimes.Max(),
            TotalTime = overallStopwatch.Elapsed.TotalMilliseconds
        };
        
        Console.WriteLine($"    📊 Performance test completed: {_metrics.TotalIterations} iterations");
        return true;
    }

    protected override bool VerifyResults()
    {
        Console.WriteLine($"  📈 Analyzing performance results");
        
        if (_metrics == null || _metrics.TotalIterations == 0)
        {
            Console.WriteLine($"    ❌ No performance data collected");
            return false;
        }
        
        Console.WriteLine($"    Average: {_metrics.AverageTime:F2}ms");
        Console.WriteLine($"    Min: {_metrics.MinTime:F2}ms");
        Console.WriteLine($"    Max: {_metrics.MaxTime:F2}ms");
        
        // Check performance thresholds
        var averageThreshold = 100.0; // 100ms average threshold
        var maxThreshold = 500.0;     // 500ms max threshold
        
        if (_metrics.AverageTime > averageThreshold)
        {
            Console.WriteLine($"    ❌ Average time ({_metrics.AverageTime:F2}ms) exceeds threshold ({averageThreshold}ms)");
            return false;
        }
        
        if (_metrics.MaxTime > maxThreshold)
        {
            Console.WriteLine($"    ❌ Max time ({_metrics.MaxTime:F2}ms) exceeds threshold ({maxThreshold}ms)");
            return false;
        }
        
        Console.WriteLine($"    ✅ Performance within acceptable limits");
        return true;
    }

    protected override void OnTestSuccess(TestResult result)
    {
        result.AddMetadata("TestType", "Performance");
        result.AddMetadata("Iterations", _metrics.TotalIterations);
        result.AddMetadata("AverageTime", _metrics.AverageTime);
        result.AddMetadata("MinTime", _metrics.MinTime);
        result.AddMetadata("MaxTime", _metrics.MaxTime);
    }
}

// Supporting classes
public class PerformanceTestConfig
{
    public string Operation { get; set; }
    public Action TestOperation { get; set; }

    public PerformanceTestConfig(string operation, Action testOperation)
    {
        Operation = operation;
        TestOperation = testOperation;
    }
}

public class PerformanceMetrics
{
    public int TotalIterations { get; set; }
    public double AverageTime { get; set; }
    public double MinTime { get; set; }
    public double MaxTime { get; set; }
    public double TotalTime { get; set; }
}
```

### Key Takeaways & Testing Benefits (2 minutes)

**Template Method in Testing Benefits**:

- **Consistent Test Execution** - All test types follow the same setup/execute/verify/cleanup pattern
- **Reliable Cleanup** - Resources always cleaned up, even when tests fail
- **Extensible Framework** - Easy to add new test types without changing core execution logic
- **Comprehensive Reporting** - Consistent result tracking and metadata collection

**Testing Pattern Applications**:

- **Unit Tests** - Simple logic verification with minimal setup
- **Integration Tests** - Complex environment setup with service interactions
- **Performance Tests** - Metrics collection with threshold verification
- **End-to-End Tests** - Full application workflows with comprehensive cleanup

**Next in Series**:

- **[Part D - Advanced Templates & Best Practices](13D_Design-Patterns-Part8D-Template-Method-Advanced.md)**

## 🔗 Related Topics

**Prerequisites**:

- **[Part B - Authentication Pipelines](13B_Design-Patterns-Part8B-Template-Method-Authentication.md)**
- Testing frameworks and methodologies
- Setup/teardown patterns in testing

**Builds Upon**:

- Test automation principles
- Resource management patterns
- Performance measurement techniques

**Enables**:

- [Builder Pattern](../creational-patterns/builder/) for test data construction
- [Factory Pattern](../creational-patterns/factory/) for test runner creation
- [Strategy Pattern](10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals.md) for test execution strategies

**Next Patterns**:

- [Chain of Responsibility](../behavioral-patterns/chain/) for test middleware
- [Observer Pattern](../behavioral-patterns/observer/) for test result notifications