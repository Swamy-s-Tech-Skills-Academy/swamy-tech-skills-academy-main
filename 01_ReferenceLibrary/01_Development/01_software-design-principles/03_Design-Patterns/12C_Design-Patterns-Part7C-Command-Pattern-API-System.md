# 12C_Design-Patterns-Part7C-Command-Pattern-API-System

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Command Pattern Document Editor (Part B), HTTP client concepts  
**Estimated Time**: Part C of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement API request commands with retry logic and error handling
- Design command queuing systems for batch API operations
- Build timeout and circuit breaker patterns within command structure
- Create robust HTTP request command system with undo capabilities

## 📋 Content Sections (27-Minute Structure)

### API Command Foundation (5 minutes)

```csharp
// HTTP Request Command Interface
public interface IHttpCommand : ICommand
{
    HttpMethod Method { get; }
    Uri RequestUri { get; }
    TimeSpan Timeout { get; }
    int MaxRetries { get; }
    HttpResponseMessage Response { get; }
}

// HTTP Command Result
public class HttpCommandResult : CommandResult
{
    public HttpStatusCode? StatusCode { get; }
    public TimeSpan ResponseTime { get; }
    public int AttemptCount { get; }

    public HttpCommandResult(bool isSuccessful, string message, HttpStatusCode? statusCode, 
                           TimeSpan responseTime, int attemptCount, object data = null) 
        : base(isSuccessful, message, data)
    {
        StatusCode = statusCode;
        ResponseTime = responseTime;
        AttemptCount = attemptCount;
    }

    public static HttpCommandResult Success(HttpStatusCode statusCode, TimeSpan responseTime, 
                                          int attemptCount, string message = "Request successful", object data = null)
    {
        return new HttpCommandResult(true, message, statusCode, responseTime, attemptCount, data);
    }

    public static HttpCommandResult Failure(string message, int attemptCount, 
                                          HttpStatusCode? statusCode = null, TimeSpan responseTime = default)
    {
        return new HttpCommandResult(false, message, statusCode, responseTime, attemptCount);
    }
}
```

### Core API Commands (15 minutes)

#### GET Request Command

```csharp
public class GetRequestCommand : IHttpCommand
{
    public string Name { get; }
    public DateTime ExecutedAt { get; private set; }
    public bool CanUndo => false; // GET requests don't have undo semantics
    public bool CanRedo => true;
    public HttpMethod Method => HttpMethod.Get;
    public Uri RequestUri { get; }
    public TimeSpan Timeout { get; }
    public int MaxRetries { get; }
    public HttpResponseMessage Response { get; private set; }

    private readonly HttpClient _httpClient;
    private readonly Dictionary<string, string> _headers;

    public GetRequestCommand(HttpClient httpClient, Uri requestUri, 
                           Dictionary<string, string> headers = null,
                           TimeSpan? timeout = null, int maxRetries = 3)
    {
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
        RequestUri = requestUri ?? throw new ArgumentNullException(nameof(requestUri));
        _headers = headers ?? new Dictionary<string, string>();
        Timeout = timeout ?? TimeSpan.FromSeconds(30);
        MaxRetries = maxRetries;
        Name = $"GET {RequestUri}";
    }

    public CommandResult Execute()
    {
        var stopwatch = Stopwatch.StartNew();
        int attempts = 0;

        for (attempts = 1; attempts <= MaxRetries; attempts++)
        {
            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Get, RequestUri);
                
                // Add headers
                foreach (var header in _headers)
                {
                    request.Headers.Add(header.Key, header.Value);
                }

                using var cts = new CancellationTokenSource(Timeout);
                Response = _httpClient.SendAsync(request, cts.Token).Result;

                ExecutedAt = DateTime.UtcNow;
                stopwatch.Stop();

                if (Response.IsSuccessStatusCode)
                {
                    return HttpCommandResult.Success(Response.StatusCode, stopwatch.Elapsed, attempts,
                        $"GET request successful: {Response.StatusCode}", Response);
                }
                else
                {
                    return HttpCommandResult.Failure($"GET request failed: {Response.StatusCode}", attempts,
                        Response.StatusCode, stopwatch.Elapsed);
                }
            }
            catch (TaskCanceledException)
            {
                if (attempts == MaxRetries)
                {
                    stopwatch.Stop();
                    return HttpCommandResult.Failure($"GET request timed out after {attempts} attempts", attempts, 
                        responseTime: stopwatch.Elapsed);
                }
                // Exponential backoff
                Thread.Sleep(TimeSpan.FromMilliseconds(Math.Pow(2, attempts) * 1000));
            }
            catch (Exception ex)
            {
                if (attempts == MaxRetries)
                {
                    stopwatch.Stop();
                    return HttpCommandResult.Failure($"GET request failed: {ex.Message}", attempts, 
                        responseTime: stopwatch.Elapsed);
                }
                Thread.Sleep(TimeSpan.FromMilliseconds(Math.Pow(2, attempts) * 1000));
            }
        }

        stopwatch.Stop();
        return HttpCommandResult.Failure("Unexpected error in GET request", attempts, responseTime: stopwatch.Elapsed);
    }

    public CommandResult Undo()
    {
        return CommandResult.Failure("GET requests cannot be undone");
    }

    public ICommand CreateInverse()
    {
        return null; // GET requests don't have meaningful inverse operations
    }
}
```

#### POST Request Command with Undo

```csharp
public class PostRequestCommand : IHttpCommand
{
    public string Name { get; }
    public DateTime ExecutedAt { get; private set; }
    public bool CanUndo { get; private set; } = true;
    public bool CanRedo => true;
    public HttpMethod Method => HttpMethod.Post;
    public Uri RequestUri { get; }
    public TimeSpan Timeout { get; }
    public int MaxRetries { get; }
    public HttpResponseMessage Response { get; private set; }

    private readonly HttpClient _httpClient;
    private readonly HttpContent _content;
    private readonly Uri _deleteUri;
    private object _createdResourceId;

    public PostRequestCommand(HttpClient httpClient, Uri requestUri, HttpContent content,
                            Uri deleteUri = null, TimeSpan? timeout = null, int maxRetries = 3)
    {
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
        RequestUri = requestUri ?? throw new ArgumentNullException(nameof(requestUri));
        _content = content ?? throw new ArgumentNullException(nameof(content));
        _deleteUri = deleteUri;
        Timeout = timeout ?? TimeSpan.FromSeconds(30);
        MaxRetries = maxRetries;
        Name = $"POST {RequestUri}";
        CanUndo = deleteUri != null;
    }

    public CommandResult Execute()
    {
        var stopwatch = Stopwatch.StartNew();
        int attempts = 0;

        for (attempts = 1; attempts <= MaxRetries; attempts++)
        {
            try
            {
                using var cts = new CancellationTokenSource(Timeout);
                Response = _httpClient.PostAsync(RequestUri, _content, cts.Token).Result;

                ExecutedAt = DateTime.UtcNow;
                stopwatch.Stop();

                if (Response.IsSuccessStatusCode)
                {
                    // Extract created resource ID for potential undo
                    if (CanUndo)
                    {
                        var responseContent = Response.Content.ReadAsStringAsync().Result;
                        _createdResourceId = ExtractResourceId(responseContent);
                    }

                    return HttpCommandResult.Success(Response.StatusCode, stopwatch.Elapsed, attempts,
                        $"POST request successful: {Response.StatusCode}", Response);
                }
                else
                {
                    return HttpCommandResult.Failure($"POST request failed: {Response.StatusCode}", attempts,
                        Response.StatusCode, stopwatch.Elapsed);
                }
            }
            catch (TaskCanceledException)
            {
                if (attempts == MaxRetries)
                {
                    stopwatch.Stop();
                    return HttpCommandResult.Failure($"POST request timed out after {attempts} attempts", attempts,
                        responseTime: stopwatch.Elapsed);
                }
                Thread.Sleep(TimeSpan.FromMilliseconds(Math.Pow(2, attempts) * 1000));
            }
            catch (Exception ex)
            {
                if (attempts == MaxRetries)
                {
                    stopwatch.Stop();
                    return HttpCommandResult.Failure($"POST request failed: {ex.Message}", attempts,
                        responseTime: stopwatch.Elapsed);
                }
                Thread.Sleep(TimeSpan.FromMilliseconds(Math.Pow(2, attempts) * 1000));
            }
        }

        stopwatch.Stop();
        return HttpCommandResult.Failure("Unexpected error in POST request", attempts, responseTime: stopwatch.Elapsed);
    }

    public CommandResult Undo()
    {
        if (!CanUndo || _deleteUri == null || _createdResourceId == null)
            return CommandResult.Failure("POST request cannot be undone");

        try
        {
            var deleteUri = new Uri(_deleteUri, _createdResourceId.ToString());
            var deleteResponse = _httpClient.DeleteAsync(deleteUri).Result;

            if (deleteResponse.IsSuccessStatusCode)
            {
                return CommandResult.Success($"POST request undone: deleted resource {_createdResourceId}");
            }
            else
            {
                return CommandResult.Failure($"Failed to undo POST: {deleteResponse.StatusCode}");
            }
        }
        catch (Exception ex)
        {
            return CommandResult.Failure($"Undo failed: {ex.Message}");
        }
    }

    public ICommand CreateInverse()
    {
        if (!CanUndo || _deleteUri == null || _createdResourceId == null)
            return null;

        var deleteUri = new Uri(_deleteUri, _createdResourceId.ToString());
        return new DeleteRequestCommand(_httpClient, deleteUri);
    }

    private object ExtractResourceId(string responseContent)
    {
        // Implementation depends on API response format
        // This is a simplified example
        try
        {
            var json = JsonDocument.Parse(responseContent);
            return json.RootElement.GetProperty("id").GetString();
        }
        catch
        {
            return Guid.NewGuid().ToString(); // Fallback
        }
    }
}
```

### Practical Implementation (5 minutes)

#### API Command Queue

```csharp
public class ApiCommandQueue
{
    private readonly Queue<IHttpCommand> _commands;
    private readonly CommandHistory _history;
    private readonly int _maxConcurrency;

    public ApiCommandQueue(int maxConcurrency = 5)
    {
        _commands = new Queue<IHttpCommand>();
        _history = new CommandHistory();
        _maxConcurrency = maxConcurrency;
    }

    public void Enqueue(IHttpCommand command)
    {
        _commands.Enqueue(command);
    }

    public async Task<List<CommandResult>> ExecuteAllAsync()
    {
        var results = new List<CommandResult>();
        var tasks = new List<Task<CommandResult>>();

        while (_commands.Count > 0 || tasks.Count > 0)
        {
            // Start new tasks up to max concurrency
            while (_commands.Count > 0 && tasks.Count < _maxConcurrency)
            {
                var command = _commands.Dequeue();
                tasks.Add(Task.Run(() => _history.ExecuteCommand(command)));
            }

            // Wait for at least one task to complete
            if (tasks.Count > 0)
            {
                var completedTask = await Task.WhenAny(tasks);
                results.Add(await completedTask);
                tasks.Remove(completedTask);
            }
        }

        return results;
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Mastered in Part C**:

- API request commands with retry logic and timeout handling
- Undoable POST operations with resource cleanup
- Command queuing for batch API operations
- Error handling and exponential backoff strategies

**Next Steps**:

- **Part D**: Macro Recording and UI Action Recorder implementation

## 🔗 Related Topics

**Prerequisites**:

- **[Part B - Document Editor](12B_Design-Patterns-Part7B-Command-Pattern-Document-Editor.md)**
- [HTTP client patterns](../../networking-patterns/)

**Enables**:

- **[Part D - Macro Recording](12D_Design-Patterns-Part7D-Command-Pattern-Macro-System.md)**
- [API integration patterns](../../integration-patterns/)
- [Microservices communication](../../distributed-patterns/)
