# 13D_Design-Patterns-Part8D-Template-Method-Advanced

**Learning Level**: Advanced  
**Prerequisites**: Template Method Testing (Part C), Enterprise patterns, Framework design  
**Estimated Time**: Part D of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master advanced Template Method patterns for enterprise applications
- Implement report generation systems with flexible formatting templates
- Design extensible framework architectures using template method principles
- Apply best practices for maintainable template method implementations

## 📋 Content Sections (27-Minute Structure)

### Advanced Template Applications (5 minutes)

**Enterprise Template Method Uses**:

- **Report Generation** - Document creation with pluggable formatting and data sources
- **Workflow Engines** - Business process execution with customizable steps
- **Framework Design** - Application frameworks with extension points
- **Audit Systems** - Compliance logging with configurable audit trails

```text
🏢 ENTERPRISE TEMPLATE METHOD ARCHITECTURE
              ┌─────────────────────┐
              │ Framework Template  │
              ├─────────────────────┤
              │ + Execute()         │◄─── Template Method
              │   Initialize()      │◄─── Hook Method
              │   LoadConfiguration()│◄─── Abstract Method
              │   ProcessData()     │◄─── Abstract Method
              │   GenerateOutput()  │◄─── Abstract Method
              │   Cleanup()         │◄─── Hook Method
              │   Audit()           │◄─── Hook Method
              └─────────────────────┘
                       ▲
         ┌─────────────┼─────────────┐
┌─────────────────┐    │    ┌─────────────────┐
│ ReportGenerator │    │    │ WorkflowEngine  │
├─────────────────┤    │    ├─────────────────┤
│ +LoadConfiguration()│   │ +LoadConfiguration()│
│ +ProcessData()  │    │    │ +ProcessData()  │
│ +GenerateOutput()│   │    │ +GenerateOutput()│
│ +Audit()        │    │    │ +Audit()        │
└─────────────────┘    │    └─────────────────┘
                       │
              ┌─────────────────┐
              │ ETLProcessor    │
              ├─────────────────┤
              │ +LoadConfiguration()│
              │ +ProcessData()  │
              │ +GenerateOutput()│
              └─────────────────┘
```

### Report Generation Framework (15 minutes)

#### Abstract Report Generator Template

```csharp
// Abstract report generation template
public abstract class ReportGenerator<TData, TOutput>
{
    public string ReportType { get; protected set; }
    public DateTime GeneratedAt { get; private set; }
    public TimeSpan GenerationTime { get; private set; }
    public ReportResult<TOutput> LastResult { get; private set; }

    protected ReportGenerator(string reportType)
    {
        ReportType = reportType ?? throw new ArgumentNullException(nameof(reportType));
    }

    // Template method - defines report generation flow
    public ReportResult<TOutput> GenerateReport(ReportRequest<TData> request)
    {
        var stopwatch = Stopwatch.StartNew();
        var result = new ReportResult<TOutput> 
        { 
            ReportType = ReportType, 
            StartTime = DateTime.UtcNow,
            RequestId = request.RequestId
        };

        try
        {
            LogReportStart(request);

            // Step 1: Initialize report environment (hook method)
            InitializeReport(request);
            result.InitializationCompleted = true;

            // Step 2: Load and validate configuration (abstract method)
            var configResult = LoadReportConfiguration(request);
            if (!configResult.IsSuccessful)
            {
                result.AddErrors(configResult.Errors);
                return result;
            }
            result.ConfigurationLoaded = true;

            // Step 3: Extract and transform data (abstract method)
            var dataResult = ExtractAndTransformData(request.Data, configResult.Configuration);
            if (!dataResult.IsSuccessful)
            {
                result.AddErrors(dataResult.Errors);
                return result;
            }
            result.DataProcessingCompleted = true;

            // Step 4: Apply formatting and styling (abstract method)
            var formattedOutput = ApplyFormatting(dataResult.ProcessedData, configResult.Configuration);
            result.FormattingCompleted = true;
            result.Output = formattedOutput;

            // Step 5: Post-process output (hook method)
            var postProcessResult = PostProcessOutput(formattedOutput, request);
            if (postProcessResult != null)
            {
                result.Output = postProcessResult;
            }
            result.PostProcessingCompleted = true;

            // Step 6: Finalize report (hook method)
            FinalizeReport(request, result);

            result.IsSuccessful = true;
            OnReportSuccess(request, result);
        }
        catch (Exception ex)
        {
            result.IsSuccessful = false;
            result.ErrorMessage = ex.Message;
            result.Exception = ex;
            OnReportError(request, result, ex);
        }
        finally
        {
            stopwatch.Stop();
            result.EndTime = DateTime.UtcNow;
            result.GenerationTime = stopwatch.Elapsed;
            
            GeneratedAt = DateTime.UtcNow;
            GenerationTime = stopwatch.Elapsed;
            LastResult = result;
            
            LogReportComplete(request, result);
        }

        return result;
    }

    // Abstract methods - must be implemented by subclasses
    protected abstract ConfigurationResult LoadReportConfiguration(ReportRequest<TData> request);
    protected abstract DataProcessingResult ExtractAndTransformData(TData data, ReportConfiguration config);
    protected abstract TOutput ApplyFormatting(object processedData, ReportConfiguration config);

    // Hook methods - can be overridden by subclasses
    protected virtual void InitializeReport(ReportRequest<TData> request) { /* Default: no initialization */ }
    protected virtual TOutput PostProcessOutput(TOutput output, ReportRequest<TData> request) { return output; }
    protected virtual void FinalizeReport(ReportRequest<TData> request, ReportResult<TOutput> result) { /* Default: no finalization */ }
    protected virtual void OnReportSuccess(ReportRequest<TData> request, ReportResult<TOutput> result) { /* Default: no action */ }
    protected virtual void OnReportError(ReportRequest<TData> request, ReportResult<TOutput> result, Exception error) { /* Default: no action */ }

    // Concrete logging methods - same for all report types
    private void LogReportStart(ReportRequest<TData> request)
    {
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] 📊 Starting {ReportType} generation (ID: {request.RequestId})");
    }

    private void LogReportComplete(ReportRequest<TData> request, ReportResult<TOutput> result)
    {
        var status = result.IsSuccessful ? "✅ SUCCESS" : "❌ FAILED";
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {status} - {ReportType} ({result.GenerationTime.TotalMilliseconds:F0}ms)");
        
        if (!result.IsSuccessful && !string.IsNullOrEmpty(result.ErrorMessage))
        {
            Console.WriteLine($"  Error: {result.ErrorMessage}");
        }
    }
}
```

#### Supporting Report Classes

```csharp
// Report request container
public class ReportRequest<T>
{
    public string RequestId { get; set; }
    public string UserId { get; set; }
    public T Data { get; set; }
    public Dictionary<string, object> Parameters { get; set; }
    public DateTime RequestedAt { get; set; }
    public ReportFormat OutputFormat { get; set; }

    public ReportRequest()
    {
        RequestId = Guid.NewGuid().ToString();
        Parameters = new Dictionary<string, object>();
        RequestedAt = DateTime.UtcNow;
        OutputFormat = ReportFormat.PDF;
    }
}

// Report result container
public class ReportResult<T>
{
    public string RequestId { get; set; }
    public string ReportType { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public TimeSpan GenerationTime { get; set; }
    public bool IsSuccessful { get; set; }
    public string ErrorMessage { get; set; }
    public Exception Exception { get; set; }
    public T Output { get; set; }
    
    // Generation phase tracking
    public bool InitializationCompleted { get; set; }
    public bool ConfigurationLoaded { get; set; }
    public bool DataProcessingCompleted { get; set; }
    public bool FormattingCompleted { get; set; }
    public bool PostProcessingCompleted { get; set; }
    
    public List<string> Errors { get; set; }
    public Dictionary<string, object> Metadata { get; set; }

    public ReportResult()
    {
        Errors = new List<string>();
        Metadata = new Dictionary<string, object>();
    }

    public void AddErrors(IEnumerable<string> errors)
    {
        Errors.AddRange(errors);
        if (Errors.Any())
            IsSuccessful = false;
    }
}

// Configuration and supporting types
public class ReportConfiguration
{
    public string TemplatePath { get; set; }
    public Dictionary<string, object> FormatSettings { get; set; }
    public List<string> IncludedColumns { get; set; }
    public string Title { get; set; }
    public string Footer { get; set; }

    public ReportConfiguration()
    {
        FormatSettings = new Dictionary<string, object>();
        IncludedColumns = new List<string>();
    }
}

public class ConfigurationResult
{
    public bool IsSuccessful { get; set; }
    public ReportConfiguration Configuration { get; set; }
    public List<string> Errors { get; set; }

    public ConfigurationResult()
    {
        Errors = new List<string>();
    }
}

public class DataProcessingResult
{
    public bool IsSuccessful { get; set; }
    public object ProcessedData { get; set; }
    public List<string> Errors { get; set; }

    public DataProcessingResult()
    {
        Errors = new List<string>();
    }
}

public enum ReportFormat
{
    PDF,
    Excel,
    CSV,
    HTML,
    JSON
}
```

#### PDF Report Generator Implementation

```csharp
public class PdfReportGenerator : ReportGenerator<List<Dictionary<string, object>>, byte[]>
{
    private readonly string _templateDirectory;
    private ReportConfiguration _currentConfig;

    public PdfReportGenerator(string templateDirectory = "./templates") 
        : base("PDF Report Generator")
    {
        _templateDirectory = templateDirectory;
    }

    protected override void InitializeReport(ReportRequest<List<Dictionary<string, object>>> request)
    {
        Console.WriteLine($"  📋 Initializing PDF report generation");
        Console.WriteLine($"  📋 Template directory: {_templateDirectory}");
        
        // Ensure template directory exists
        if (!Directory.Exists(_templateDirectory))
        {
            Directory.CreateDirectory(_templateDirectory);
            Console.WriteLine($"  📋 Created template directory: {_templateDirectory}");
        }
    }

    protected override ConfigurationResult LoadReportConfiguration(ReportRequest<List<Dictionary<string, object>>> request)
    {
        Console.WriteLine($"  ⚙️ Loading PDF report configuration");
        
        var config = new ReportConfiguration
        {
            TemplatePath = Path.Combine(_templateDirectory, "default-pdf-template.html"),
            Title = request.Parameters.ContainsKey("title") ? request.Parameters["title"].ToString() : "Generated Report",
            Footer = $"Generated on {DateTime.Now:yyyy-MM-dd HH:mm:ss}"
        };

        // Set PDF-specific formatting
        config.FormatSettings["PageSize"] = "A4";
        config.FormatSettings["Orientation"] = "Portrait";
        config.FormatSettings["MarginTop"] = "20mm";
        config.FormatSettings["MarginBottom"] = "20mm";
        config.FormatSettings["MarginLeft"] = "15mm";
        config.FormatSettings["MarginRight"] = "15mm";

        // Determine columns to include
        if (request.Data?.Any() == true)
        {
            config.IncludedColumns = request.Data.First().Keys.ToList();
            Console.WriteLine($"  ⚙️ Detected {config.IncludedColumns.Count} data columns");
        }

        _currentConfig = config;
        return new ConfigurationResult { IsSuccessful = true, Configuration = config };
    }

    protected override DataProcessingResult ExtractAndTransformData(List<Dictionary<string, object>> data, ReportConfiguration config)
    {
        Console.WriteLine($"  🔄 Processing {data?.Count ?? 0} data records");
        
        if (data == null || !data.Any())
        {
            return new DataProcessingResult 
            { 
                IsSuccessful = false, 
                Errors = { "No data provided for report generation" } 
            };
        }

        // Filter data based on included columns
        var processedData = data.Select(row => 
        {
            var filteredRow = new Dictionary<string, object>();
            foreach (var column in config.IncludedColumns)
            {
                if (row.ContainsKey(column))
                {
                    filteredRow[column] = row[column] ?? "";
                }
                else
                {
                    filteredRow[column] = "";
                }
            }
            return filteredRow;
        }).ToList();

        Console.WriteLine($"  🔄 Processed data with {config.IncludedColumns.Count} columns per record");
        
        return new DataProcessingResult 
        { 
            IsSuccessful = true, 
            ProcessedData = processedData 
        };
    }

    protected override byte[] ApplyFormatting(object processedData, ReportConfiguration config)
    {
        Console.WriteLine($"  🎨 Applying PDF formatting");
        
        var data = (List<Dictionary<string, object>>)processedData;
        
        // Generate HTML content for PDF conversion
        var htmlContent = GenerateHtmlContent(data, config);
        
        // Convert HTML to PDF (simulated)
        var pdfBytes = ConvertHtmlToPdf(htmlContent);
        
        Console.WriteLine($"  🎨 Generated PDF ({pdfBytes.Length} bytes)");
        
        return pdfBytes;
    }

    protected override byte[] PostProcessOutput(byte[] output, ReportRequest<List<Dictionary<string, object>>> request)
    {
        Console.WriteLine($"  ✨ Post-processing PDF output");
        
        // Add watermark, compression, or other post-processing
        // For demo, just return original
        return output;
    }

    protected override void FinalizeReport(ReportRequest<List<Dictionary<string, object>>> request, ReportResult<byte[]> result)
    {
        if (result.IsSuccessful)
        {
            result.Metadata["OutputSize"] = result.Output.Length;
            result.Metadata["PageCount"] = EstimatePageCount(result.Output.Length);
            result.Metadata["Title"] = _currentConfig.Title;
            
            Console.WriteLine($"  📄 Report finalized: {result.Metadata["PageCount"]} pages, {result.Output.Length} bytes");
        }
    }

    protected override void OnReportSuccess(ReportRequest<List<Dictionary<string, object>>> request, ReportResult<byte[]> result)
    {
        Console.WriteLine($"  ✅ PDF report generated successfully");
        Console.WriteLine($"     Title: {_currentConfig.Title}");
        Console.WriteLine($"     Size: {result.Output.Length:N0} bytes");
        Console.WriteLine($"     Records: {request.Data.Count}");
    }

    protected override void OnReportError(ReportRequest<List<Dictionary<string, object>>> request, ReportResult<byte[]> result, Exception error)
    {
        Console.WriteLine($"  ❌ PDF report generation failed: {error.Message}");
        
        // Log detailed error information for debugging
        result.Metadata["ErrorType"] = error.GetType().Name;
        result.Metadata["ErrorSource"] = error.Source;
    }

    private string GenerateHtmlContent(List<Dictionary<string, object>> data, ReportConfiguration config)
    {
        var html = new StringBuilder();
        
        html.AppendLine($"<html><head><title>{config.Title}</title>");
        html.AppendLine("<style>table { border-collapse: collapse; width: 100%; }");
        html.AppendLine("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        html.AppendLine("th { background-color: #f2f2f2; }</style></head><body>");
        
        html.AppendLine($"<h1>{config.Title}</h1>");
        html.AppendLine("<table>");
        
        // Header row
        html.AppendLine("<tr>");
        foreach (var column in config.IncludedColumns)
        {
            html.AppendLine($"<th>{column}</th>");
        }
        html.AppendLine("</tr>");
        
        // Data rows
        foreach (var row in data)
        {
            html.AppendLine("<tr>");
            foreach (var column in config.IncludedColumns)
            {
                html.AppendLine($"<td>{row[column]}</td>");
            }
            html.AppendLine("</tr>");
        }
        
        html.AppendLine("</table>");
        html.AppendLine($"<p><small>{config.Footer}</small></p>");
        html.AppendLine("</body></html>");
        
        return html.ToString();
    }

    private byte[] ConvertHtmlToPdf(string htmlContent)
    {
        // Simulate PDF generation from HTML
        // In real implementation, use libraries like iTextSharp, PuppeteerSharp, etc.
        return Encoding.UTF8.GetBytes($"PDF_CONTENT:{htmlContent}");
    }

    private int EstimatePageCount(int contentSize)
    {
        // Rough estimation: 1 page per 2KB of content
        return Math.Max(1, contentSize / 2048);
    }
}
```

### Framework Best Practices (5 minutes)

#### Template Method Design Guidelines

```csharp
// Example: Extensible workflow engine
public abstract class WorkflowEngine<TInput, TOutput>
{
    // Template method with clear extension points
    public WorkflowResult<TOutput> ExecuteWorkflow(TInput input)
    {
        // 1. Validate preconditions
        if (!ValidatePreconditions(input))
            return WorkflowResult<TOutput>.Failure("Preconditions not met");

        // 2. Load workflow definition (abstract - must implement)
        var workflowDef = LoadWorkflowDefinition(input);
        
        // 3. Execute steps with error handling
        return ExecuteStepsWithErrorHandling(input, workflowDef);
    }

    // Abstract methods - clear contracts
    protected abstract WorkflowDefinition LoadWorkflowDefinition(TInput input);
    protected abstract TOutput ExecuteStep(WorkflowStep step, TInput input);

    // Hook methods - optional overrides with sensible defaults
    protected virtual bool ValidatePreconditions(TInput input) => true;
    protected virtual void OnStepCompleted(WorkflowStep step, TInput input) { }
    protected virtual void OnWorkflowCompleted(TInput input, TOutput output) { }
}

// Best practices demonstrated:
// ✅ Clear method contracts (abstract vs virtual)
// ✅ Sensible default implementations for hooks
// ✅ Comprehensive error handling
// ✅ Consistent naming conventions
// ✅ Proper exception propagation
// ✅ Extensibility without modification (Open/Closed Principle)
```

### Key Takeaways & Pattern Mastery (2 minutes)

**Template Method Pattern Mastery Complete (Parts A-D)**:

- **Part A**: Data processing pipelines with CSV/JSON conversion
- **Part B**: Authentication flows with security hooks
- **Part C**: Testing frameworks with setup/teardown procedures
- **Part D**: Report generation and enterprise workflow patterns

**Template Method Benefits Realized**:

- **Consistent Algorithm Structure** - All implementations follow the same flow
- **Flexible Customization** - Abstract methods enforce implementation, hooks provide options
- **Code Reuse** - Common functionality shared across all implementations
- **Maintainable Extensions** - Easy to add new implementations without changing existing code

**Enterprise Pattern Applications**:

- **Data Processing** - ETL pipelines, data transformation workflows
- **Authentication** - Login flows, security validation chains
- **Testing** - Test execution frameworks, automated test suites
- **Reporting** - Document generation, business intelligence reports
- **Workflow Engines** - Business process automation, approval workflows

**Design Principles Applied**:

- **Open/Closed Principle** - Open for extension, closed for modification
- **DRY (Don't Repeat Yourself)** - Algorithm structure defined once, reused everywhere
- **Template Method vs Strategy** - Template Method for algorithm structure, Strategy for algorithm selection
- **Inheritance vs Composition** - Appropriate use of inheritance for behavioral templates

**Next Design Pattern**: Observer Pattern for event-driven architectures

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Template Method Fundamentals](13A_Design-Patterns-Part8A-Template-Method-Fundamentals.md)**
- **[Part B - Authentication Pipelines](13B_Design-Patterns-Part8B-Template-Method-Authentication.md)**
- **[Part C - Testing Framework Templates](13C_Design-Patterns-Part8C-Template-Method-Testing.md)**

**Builds Upon**:

- Framework design principles
- Enterprise architecture patterns
- Report generation systems

**Enables**:

- [Observer Pattern](../behavioral-patterns/observer/) for event notifications
- [Chain of Responsibility](../behavioral-patterns/chain/) for processing pipelines
- [Visitor Pattern](../behavioral-patterns/visitor/) for data structure traversal

**Next Patterns**:

- [Facade Pattern](../structural-patterns/facade/) for subsystem interfaces
- [Proxy Pattern](../structural-patterns/proxy/) for access control