# 13A_Design-Patterns-Part8A-Template-Method-Fundamentals

**Learning Level**: Intermediate  
**Prerequisites**: Inheritance concepts, SOLID principles understanding  
**Estimated Time**: Part A of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master the Template Method Pattern for algorithm structure with customizable steps
- Understand the difference between abstract methods and hook methods
- Implement a basic data processing pipeline with template method architecture
- Design reusable algorithm skeletons with pluggable implementation steps

## 📋 Content Sections (27-Minute Structure)

### Pattern Overview and Problem (5 minutes)

**Template Method Pattern**: *"Define the skeleton of an algorithm in a base class, letting subclasses override specific steps without changing the algorithm's structure."*

**Core Problem**: Need to define a consistent algorithm structure while allowing variations in specific implementation steps.

```text
❌ DUPLICATED ALGORITHM PROBLEM
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ EmailProcessor  │    │ SmsProcessor    │    │ PushProcessor   │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + Process()     │    │ + Process()     │    │ + Process()     │
│   Validate()    │    │   Validate()    │    │   Validate()    │
│   Transform()   │    │   Transform()   │    │   Transform()   │
│   Send()        │    │   Send()        │    │   Send()        │
│   Log()         │    │   Log()         │    │   Log()         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
    ❌ Repeated algorithm structure, inconsistent implementations

✅ TEMPLATE METHOD PATTERN SOLUTION
              ┌─────────────────┐
              │MessageProcessor │
              ├─────────────────┤
              │ + Process()     │◄─── Template Method
              │   Validate()    │◄─── Abstract Step
              │   Transform()   │◄─── Abstract Step
              │   Send()        │◄─── Abstract Step
              │   Log()         │◄─── Hook Method
              └─────────────────┘
                       ▲
         ┌─────────────┼─────────────┐
┌─────────────────┐    │    ┌─────────────────┐
│ EmailProcessor  │    │    │ SmsProcessor    │
├─────────────────┤    │    ├─────────────────┤
│ + Validate()    │    │    │ + Validate()    │
│ + Transform()   │    │    │ + Transform()   │
│ + Send()        │    │    │ + Send()        │
└─────────────────┘    │    └─────────────────┘
                       │
              ┌─────────────────┐
              │ PushProcessor   │
              ├─────────────────┤
              │ + Validate()    │
              │ + Transform()   │
              │ + Send()        │
              └─────────────────┘
    ✅ Consistent algorithm, customizable steps, reusable structure
```

**Real-World Applications**:

- **Data Processing** - ETL pipelines with pluggable transformation steps
- **Authentication** - Login flows with customizable validation methods
- **Testing Frameworks** - Test execution with setup/teardown hooks
- **Report Generation** - Document creation with flexible formatting steps

### Core Template Method Architecture (15 minutes)

#### Abstract Data Processing Pipeline

```csharp
// Abstract data processing pipeline
public abstract class DataProcessor<TInput, TOutput>
{
    public string ProcessorName { get; protected set; }
    public DateTime LastExecuted { get; private set; }
    public TimeSpan LastExecutionTime { get; private set; }

    protected DataProcessor(string processorName)
    {
        ProcessorName = processorName ?? throw new ArgumentNullException(nameof(processorName));
    }

    // Template method - defines the algorithm structure
    public ProcessingResult<TOutput> Process(TInput input)
    {
        var stopwatch = Stopwatch.StartNew();
        var result = new ProcessingResult<TOutput>();

        try
        {
            LogStart(input);

            // Step 1: Validate input (abstract method - must override)
            var validationResult = ValidateInput(input);
            if (!validationResult.IsValid)
            {
                result.AddErrors(validationResult.Errors);
                return result;
            }

            // Step 2: Extract data (hook method - optional override)
            var extractedData = ExtractData(input);
            
            // Step 3: Transform data (abstract method - must override)
            var transformedData = TransformData(extractedData);
            
            // Step 4: Validate output (hook method - optional override)
            var outputValidation = ValidateOutput(transformedData);
            if (!outputValidation.IsValid)
            {
                result.AddErrors(outputValidation.Errors);
                return result;
            }

            // Step 5: Load/save data (abstract method - must override)
            var loadResult = LoadData(transformedData);
            
            result.Data = loadResult;
            result.IsSuccessful = true;
            
            // Step 6: Post-processing cleanup (hook method - optional override)
            OnProcessingComplete(input, result);
        }
        catch (Exception ex)
        {
            result.AddError($"Processing failed: {ex.Message}");
            OnProcessingError(input, ex);
        }
        finally
        {
            stopwatch.Stop();
            LastExecuted = DateTime.UtcNow;
            LastExecutionTime = stopwatch.Elapsed;
            LogComplete(result);
        }

        return result;
    }

    // Abstract methods - must be implemented by subclasses
    protected abstract ValidationResult ValidateInput(TInput input);
    protected abstract TOutput TransformData(object extractedData);
    protected abstract TOutput LoadData(TOutput transformedData);

    // Hook methods - can be overridden by subclasses
    protected virtual object ExtractData(TInput input)
    {
        return input; // Default: no extraction needed
    }

    protected virtual ValidationResult ValidateOutput(TOutput output)
    {
        return ValidationResult.Success(); // Default: always valid
    }

    protected virtual void OnProcessingComplete(TInput input, ProcessingResult<TOutput> result)
    {
        // Default: no post-processing
    }

    protected virtual void OnProcessingError(TInput input, Exception error)
    {
        Console.WriteLine($"Error in {ProcessorName}: {error.Message}");
    }

    // Concrete methods - same for all subclasses
    private void LogStart(TInput input)
    {
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] Starting {ProcessorName} processing");
    }

    private void LogComplete(ProcessingResult<TOutput> result)
    {
        var status = result.IsSuccessful ? "SUCCESS" : "FAILED";
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {ProcessorName} completed: {status} ({LastExecutionTime.TotalMilliseconds:F0}ms)");
        
        if (!result.IsSuccessful && result.Errors.Any())
        {
            Console.WriteLine($"  Errors: {string.Join("; ", result.Errors)}");
        }
    }
}
```

#### Supporting Infrastructure Classes

```csharp
// Processing result container
public class ProcessingResult<T>
{
    public T Data { get; set; }
    public bool IsSuccessful { get; set; }
    public List<string> Errors { get; }
    public Dictionary<string, object> Metadata { get; }

    public ProcessingResult()
    {
        Errors = new List<string>();
        Metadata = new Dictionary<string, object>();
        IsSuccessful = false;
    }

    public void AddError(string error)
    {
        Errors.Add(error);
        IsSuccessful = false;
    }

    public void AddErrors(IEnumerable<string> errors)
    {
        Errors.AddRange(errors);
        if (Errors.Any())
            IsSuccessful = false;
    }

    public void AddMetadata(string key, object value)
    {
        Metadata[key] = value;
    }
}

// Validation result container
public class ValidationResult
{
    public bool IsValid { get; }
    public List<string> Errors { get; }

    private ValidationResult(bool isValid, IEnumerable<string> errors = null)
    {
        IsValid = isValid;
        Errors = new List<string>(errors ?? Enumerable.Empty<string>());
    }

    public static ValidationResult Success() => new ValidationResult(true);
    public static ValidationResult Failure(params string[] errors) => new ValidationResult(false, errors);
    public static ValidationResult Failure(IEnumerable<string> errors) => new ValidationResult(false, errors);
}
```

### Practical Implementation Example (5 minutes)

#### CSV to JSON Processor

```csharp
// Concrete processor: CSV to JSON converter
public class CsvToJsonProcessor : DataProcessor<string, string>
{
    private readonly char _delimiter;
    private readonly bool _hasHeader;

    public CsvToJsonProcessor(char delimiter = ',', bool hasHeader = true) 
        : base("CSV to JSON Processor")
    {
        _delimiter = delimiter;
        _hasHeader = hasHeader;
    }

    protected override ValidationResult ValidateInput(string input)
    {
        if (string.IsNullOrWhiteSpace(input))
            return ValidationResult.Failure("Input CSV data cannot be null or empty");

        var lines = input.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0)
            return ValidationResult.Failure("CSV data must contain at least one line");

        if (_hasHeader && lines.Length < 2)
            return ValidationResult.Failure("CSV with header must contain at least two lines (header + data)");

        return ValidationResult.Success();
    }

    protected override string TransformData(object extractedData)
    {
        var csvData = (string)extractedData;
        var lines = csvData.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        
        string[] headers;
        var dataLines = lines;

        if (_hasHeader)
        {
            headers = lines[0].Split(_delimiter);
            dataLines = lines.Skip(1).ToArray();
        }
        else
        {
            // Generate column names: Column1, Column2, etc.
            var firstLine = lines[0].Split(_delimiter);
            headers = Enumerable.Range(1, firstLine.Length)
                               .Select(i => $"Column{i}")
                               .ToArray();
        }

        var jsonObjects = new List<Dictionary<string, string>>();

        foreach (var line in dataLines)
        {
            var values = line.Split(_delimiter);
            var jsonObject = new Dictionary<string, string>();

            for (int i = 0; i < Math.Min(headers.Length, values.Length); i++)
            {
                jsonObject[headers[i].Trim()] = values[i].Trim();
            }

            jsonObjects.Add(jsonObject);
        }

        return System.Text.Json.JsonSerializer.Serialize(jsonObjects, new JsonSerializerOptions
        {
            WriteIndented = true
        });
    }

    protected override string LoadData(string transformedData)
    {
        // In this example, "loading" just returns the JSON string
        // In real scenarios, this might save to file, database, or API
        return transformedData;
    }

    protected override ValidationResult ValidateOutput(string output)
    {
        try
        {
            using var document = JsonDocument.Parse(output);
            return ValidationResult.Success();
        }
        catch (JsonException ex)
        {
            return ValidationResult.Failure($"Generated JSON is invalid: {ex.Message}");
        }
    }

    protected override void OnProcessingComplete(string input, ProcessingResult<string> result)
    {
        if (result.IsSuccessful)
        {
            var inputLines = input.Split('\n', StringSplitOptions.RemoveEmptyEntries).Length;
            result.AddMetadata("InputLineCount", inputLines);
            result.AddMetadata("HasHeader", _hasHeader);
            result.AddMetadata("Delimiter", _delimiter);
        }
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Template Method Pattern Benefits**:

- **Consistent Algorithm Structure** - All implementations follow the same process flow
- **Customizable Steps** - Abstract methods enforce implementation while hooks provide flexibility
- **Code Reuse** - Common functionality (logging, error handling) implemented once
- **Open/Closed Principle** - Easy to add new implementations without modifying existing code

**Method Types in Template Method**:

- **Template Method** (Process) - Defines the algorithm skeleton, never overridden
- **Abstract Methods** (ValidateInput, TransformData, LoadData) - Must be implemented by subclasses
- **Hook Methods** (ExtractData, ValidateOutput, OnProcessingComplete) - Optional overrides with default behavior
- **Concrete Methods** (LogStart, LogComplete) - Fixed implementations shared by all subclasses

**Next in Series**:

- **[Part B - Authentication & Security Pipelines](13B_Design-Patterns-Part8B-Template-Method-Authentication.md)**
- **[Part C - Testing Framework Templates](13C_Design-Patterns-Part8C-Template-Method-Testing.md)**
- **[Part D - Advanced Templates & Best Practices](13D_Design-Patterns-Part8D-Template-Method-Advanced.md)**

## 🔗 Related Topics

**Prerequisites**:

- [Strategy Pattern](10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals.md) for algorithm selection
- [Command Pattern](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md) for action encapsulation

**Builds Upon**:

- Abstract classes and inheritance concepts
- SOLID principles (especially Open/Closed)
- Error handling and logging patterns

**Enables**:

- [Factory Method Pattern](../creational-patterns/factory-method/) for object creation templates
- [Builder Pattern](../creational-patterns/builder/) for construction process templates
- [Chain of Responsibility](../behavioral-patterns/chain/) for processing pipelines

**Next Patterns**:

- [State Pattern](../behavioral-patterns/state/) for state-dependent behavior
- [Observer Pattern](../behavioral-patterns/observer/) for event notification templates