# 11_Design-Patterns-Part6-Decorator-Pattern

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Strategy Pattern (Part 5), Inheritance vs Composition concepts  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Decorator Pattern for dynamic behavior composition
- Implement middleware pipelines and aspect-oriented programming concepts
- Design flexible data processing chains and UI component enhancement systems
- Apply decorator patterns in logging, caching, validation, and security scenarios

## 📋 Content Sections

### Quick Overview (5 minutes)

**Decorator Pattern**: *"Attach additional responsibilities to an object dynamically. Decorators provide a flexible alternative to subclassing for extending functionality."*

**Core Problem**: Need to add behavior to objects without modifying their structure or creating numerous subclass combinations.

```text
❌ INHERITANCE EXPLOSION PROBLEM
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   BasicCoffee   │    │ MilkCoffee      │    │ SugarCoffee     │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + GetCost()     │    │ + GetCost()     │    │ + GetCost()     │
│ + GetDesc()     │    │ + GetDesc()     │    │ + GetDesc()     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐    ┌─────────────────┐
                    │MilkSugarCoffee  │    │WhipMilkCoffee   │
                    ├─────────────────┤    ├─────────────────┤
                    │ + GetCost()     │    │ + GetCost()     │
                    │ + GetDesc()     │    │ + GetDesc()     │
                    └─────────────────┘    └─────────────────┘
    ❌ Exponential class growth: n! combinations

✅ DECORATOR PATTERN SOLUTION
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ICoffee       │    │CoffeeDecorator  │    │   MilkDecorator │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ + GetCost()     │◄───│ - coffee        │◄───│ + GetCost()     │
│ + GetDesc()     │    │ + GetCost()     │    │ + GetDesc()     │
└─────────────────┘    │ + GetDesc()     │    └─────────────────┘
         ▲              └─────────────────┘             │
         │                       ▲                     │
┌─────────────────┐              │              ┌─────────────────┐
│  BasicCoffee    │              └──────────────│ SugarDecorator  │
├─────────────────┤                             ├─────────────────┤
│ + GetCost()     │                             │ + GetCost()     │
│ + GetDesc()     │                             │ + GetDesc()     │
└─────────────────┘                             └─────────────────┘
    ✅ Linear growth: n decorators, unlimited combinations
```

**Real-World Applications**:

- **Middleware Pipelines** - Request processing, authentication, logging
- **Data Processing** - Compression, encryption, validation chains
- **UI Components** - Borders, scrollbars, tooltips, themes
- **Service Enhancement** - Caching, retry logic, circuit breakers

### Core Concepts (15 minutes)

#### Web API Middleware Decorator System

#### Implementation 1: HTTP Request Processing Pipeline

```csharp
// Base request/response context
public class HttpContext
{
    public Dictionary<string, object> Items { get; } = new Dictionary<string, object>();
    public HttpRequest Request { get; }
    public HttpResponse Response { get; }
    public CancellationToken CancellationToken { get; }

    public HttpContext(HttpRequest request, HttpResponse response, CancellationToken cancellationToken = default)
    {
        Request = request ?? throw new ArgumentNullException(nameof(request));
        Response = response ?? throw new ArgumentNullException(nameof(response));
        CancellationToken = cancellationToken;
    }
}

public class HttpRequest
{
    public string Method { get; set; } = "GET";
    public string Path { get; set; } = "/";
    public Dictionary<string, string> Headers { get; } = new Dictionary<string, string>();
    public Dictionary<string, string> Query { get; } = new Dictionary<string, string>();
    public string Body { get; set; } = string.Empty;
    public DateTime Timestamp { get; } = DateTime.UtcNow;
    public string ClientIp { get; set; } = "127.0.0.1";
}

public class HttpResponse
{
    public int StatusCode { get; set; } = 200;
    public Dictionary<string, string> Headers { get; } = new Dictionary<string, string>();
    public string Body { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}

// Core middleware interface
public interface IMiddleware
{
    Task InvokeAsync(HttpContext context, Func<Task> next);
}

// Base request handler interface
public interface IRequestHandler
{
    Task<HttpResponse> HandleAsync(HttpRequest request, CancellationToken cancellationToken = default);
}

// Basic request handler implementation
public class BasicRequestHandler : IRequestHandler
{
    public async Task<HttpResponse> HandleAsync(HttpRequest request, CancellationToken cancellationToken = default)
    {
        // Simulate basic request processing
        await Task.Delay(10, cancellationToken);
        
        var response = new HttpResponse
        {
            StatusCode = 200,
            Body = $"{{\"message\": \"Request processed\", \"path\": \"{request.Path}\", \"method\": \"{request.Method}\"}}"
        };
        
        response.Headers["Content-Type"] = "application/json";
        response.Headers["X-Processed-By"] = "BasicRequestHandler";
        
        return response;
    }
}

// Middleware decorator base class
public abstract class MiddlewareDecorator : IRequestHandler
{
    protected readonly IRequestHandler _inner;

    protected MiddlewareDecorator(IRequestHandler inner)
    {
        _inner = inner ?? throw new ArgumentNullException(nameof(inner));
    }

    public abstract Task<HttpResponse> HandleAsync(HttpRequest request, CancellationToken cancellationToken = default);
}

// Concrete decorator: Logging middleware
public class LoggingMiddleware : MiddlewareDecorator
{
    private readonly ILogger _logger;

    public LoggingMiddleware(IRequestHandler inner, ILogger logger) : base(inner)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public override async Task<HttpResponse> HandleAsync(HttpRequest request, CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();
        var requestId = Guid.NewGuid().ToString("N")[..8];

        _logger.LogInformation("Request {RequestId}: {Method} {Path} from {ClientIp}", 
                              requestId, request.Method, request.Path, request.ClientIp);

        try
        {
            var response = await _inner.HandleAsync(request, cancellationToken);
            stopwatch.Stop();

            _logger.LogInformation("Response {RequestId}: {StatusCode} in {ElapsedMs}ms", 
                                  requestId, response.StatusCode, stopwatch.ElapsedMilliseconds);

            // Add request ID to response headers
            response.Headers["X-Request-Id"] = requestId;
            response.Headers["X-Processing-Time"] = $"{stopwatch.ElapsedMilliseconds}ms";

            return response;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, "Request {RequestId} failed after {ElapsedMs}ms", 
                            requestId, stopwatch.ElapsedMilliseconds);
            
            return new HttpResponse
            {
                StatusCode = 500,
                Body = $"{{\"error\": \"Internal server error\", \"requestId\": \"{requestId}\"}}"
            };
        }
    }
}

// Concrete decorator: Authentication middleware
public class AuthenticationMiddleware : MiddlewareDecorator
{
    private readonly IAuthenticationService _authService;

    public AuthenticationMiddleware(IRequestHandler inner, IAuthenticationService authService) : base(inner)
    {
        _authService = authService ?? throw new ArgumentNullException(nameof(authService));
    }

    public override async Task<HttpResponse> HandleAsync(HttpRequest request, CancellationToken cancellationToken = default)
    {
        // Skip authentication for public endpoints
        if (IsPublicEndpoint(request.Path))
        {
            return await _inner.HandleAsync(request, cancellationToken);
        }

        if (!request.Headers.TryGetValue("Authorization", out var authHeader))
        {
            return new HttpResponse
            {
                StatusCode = 401,
                Body = "{\"error\": \"Missing Authorization header\"}"
            };
        }

        try
        {
            var token = ExtractBearerToken(authHeader);
            var user = await _authService.ValidateTokenAsync(token, cancellationToken);
            
            if (user == null)
            {
                return new HttpResponse
                {
                    StatusCode = 401,
                    Body = "{\"error\": \"Invalid or expired token\"}"
                };
            }

            // Add user information to request context (simulate)
            request.Headers["X-User-Id"] = user.Id;
            request.Headers["X-User-Role"] = user.Role;

            return await _inner.HandleAsync(request, cancellationToken);
        }
        catch (Exception ex)
        {
            return new HttpResponse
            {
                StatusCode = 401,
                Body = $"{{\"error\": \"Authentication failed: {ex.Message}\"}}"
            };
        }
    }

    private bool IsPublicEndpoint(string path)
    {
        var publicPaths = new[] { "/health", "/login", "/register", "/docs" };
        return publicPaths.Any(p => path.StartsWith(p, StringComparison.OrdinalIgnoreCase));
    }

    private string ExtractBearerToken(string authHeader)
    {
        const string bearerPrefix = "Bearer ";
        if (authHeader.StartsWith(bearerPrefix, StringComparison.OrdinalIgnoreCase))
        {
            return authHeader.Substring(bearerPrefix.Length);
        }
        throw new ArgumentException("Invalid Authorization header format");
    }
}

// Concrete decorator: Rate limiting middleware
public class RateLimitingMiddleware : MiddlewareDecorator
{
    private readonly IRateLimiter _rateLimiter;

    public RateLimitingMiddleware(IRequestHandler inner, IRateLimiter rateLimiter) : base(inner)
    {
        _rateLimiter = rateLimiter ?? throw new ArgumentNullException(nameof(rateLimiter));
    }

    public override async Task<HttpResponse> HandleAsync(HttpRequest request, CancellationToken cancellationToken = default)
    {
        var clientKey = GetClientKey(request);
        var isAllowed = await _rateLimiter.IsRequestAllowedAsync(clientKey, cancellationToken);

        if (!isAllowed)
        {
            var resetTime = await _rateLimiter.GetResetTimeAsync(clientKey);
            
            var response = new HttpResponse
            {
                StatusCode = 429,
                Body = $"{{\"error\": \"Rate limit exceeded\", \"resetTime\": \"{resetTime:O}\"}}"
            };
            
            response.Headers["Retry-After"] = ((int)(resetTime - DateTime.UtcNow).TotalSeconds).ToString();
            response.Headers["X-RateLimit-Limit"] = _rateLimiter.Limit.ToString();
            response.Headers["X-RateLimit-Remaining"] = "0";
            
            return response;
        }

        var remaining = await _rateLimiter.GetRemainingRequestsAsync(clientKey);
        var response = await _inner.HandleAsync(request, cancellationToken);
        
        // Add rate limiting headers to successful responses
        response.Headers["X-RateLimit-Limit"] = _rateLimiter.Limit.ToString();
        response.Headers["X-RateLimit-Remaining"] = remaining.ToString();
        
        return response;
    }

    private string GetClientKey(HttpRequest request)
    {
        // Use user ID if authenticated, otherwise use IP address
        if (request.Headers.TryGetValue("X-User-Id", out var userId))
        {
            return $"user:{userId}";
        }
        
        return $"ip:{request.ClientIp}";
    }
}

// Concrete decorator: Caching middleware
public class CachingMiddleware : MiddlewareDecorator
{
    private readonly ICacheService _cache;
    private readonly TimeSpan _defaultTtl;

    public CachingMiddleware(IRequestHandler inner, ICacheService cache, TimeSpan? defaultTtl = null) : base(inner)
    {
        _cache = cache ?? throw new ArgumentNullException(nameof(cache));
        _defaultTtl = defaultTtl ?? TimeSpan.FromMinutes(5);
    }

    public override async Task<HttpResponse> HandleAsync(HttpRequest request, CancellationToken cancellationToken = default)
    {
        // Only cache GET requests
        if (request.Method != "GET")
        {
            return await _inner.HandleAsync(request, cancellationToken);
        }

        var cacheKey = GenerateCacheKey(request);
        
        // Try to get cached response
        var cachedResponse = await _cache.GetAsync<HttpResponse>(cacheKey, cancellationToken);
        if (cachedResponse != null)
        {
            cachedResponse.Headers["X-Cache"] = "HIT";
            cachedResponse.Headers["X-Cache-Key"] = cacheKey;
            return cachedResponse;
        }

        // Process request and cache response
        var response = await _inner.HandleAsync(request, cancellationToken);
        
        // Only cache successful responses
        if (response.StatusCode == 200)
        {
            var ttl = GetCacheTtl(request);
            await _cache.SetAsync(cacheKey, response, ttl, cancellationToken);
            
            response.Headers["X-Cache"] = "MISS";
            response.Headers["X-Cache-Key"] = cacheKey;
            response.Headers["X-Cache-TTL"] = ttl.TotalSeconds.ToString();
        }

        return response;
    }

    private string GenerateCacheKey(HttpRequest request)
    {
        var keyParts = new List<string> { request.Method, request.Path };
        
        // Include query parameters in cache key
        if (request.Query.Any())
        {
            var sortedQuery = request.Query
                .OrderBy(kvp => kvp.Key)
                .Select(kvp => $"{kvp.Key}={kvp.Value}");
            keyParts.Add(string.Join("&", sortedQuery));
        }

        // Include user context if authenticated
        if (request.Headers.TryGetValue("X-User-Id", out var userId))
        {
            keyParts.Add($"user:{userId}");
        }

        var combinedKey = string.Join("|", keyParts);
        
        // Hash the key to ensure consistent length
        using var sha256 = SHA256.Create();
        var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(combinedKey));
        return Convert.ToHexString(hashBytes)[..16]; // Use first 16 characters
    }

    private TimeSpan GetCacheTtl(HttpRequest request)
    {
        // Different TTLs for different endpoints
        if (request.Path.StartsWith("/api/static"))
        {
            return TimeSpan.FromHours(1);
        }
        
        if (request.Path.StartsWith("/api/config"))
        {
            return TimeSpan.FromMinutes(30);
        }

        return _defaultTtl;
    }
}

// Request handler builder for fluent decorator composition
public class RequestHandlerBuilder
{
    private IRequestHandler _handler;

    public RequestHandlerBuilder(IRequestHandler baseHandler)
    {
        _handler = baseHandler ?? throw new ArgumentNullException(nameof(baseHandler));
    }

    public RequestHandlerBuilder WithLogging(ILogger logger)
    {
        _handler = new LoggingMiddleware(_handler, logger);
        return this;
    }

    public RequestHandlerBuilder WithAuthentication(IAuthenticationService authService)
    {
        _handler = new AuthenticationMiddleware(_handler, authService);
        return this;
    }

    public RequestHandlerBuilder WithRateLimit(IRateLimiter rateLimiter)
    {
        _handler = new RateLimitingMiddleware(_handler, rateLimiter);
        return this;
    }

    public RequestHandlerBuilder WithCaching(ICacheService cache, TimeSpan? ttl = null)
    {
        _handler = new CachingMiddleware(_handler, cache, ttl);
        return this;
    }

    public RequestHandlerBuilder WithCustomMiddleware<T>(Func<IRequestHandler, T> factory) where T : IRequestHandler
    {
        _handler = factory(_handler);
        return this;
    }

    public IRequestHandler Build()
    {
        return _handler;
    }
}

// Usage example
public class MiddlewarePipelineExample
{
    public async Task DemonstrateMiddlewarePipeline()
    {
        // Setup services (mock implementations)
        var logger = new ConsoleLogger();
        var authService = new MockAuthenticationService();
        var rateLimiter = new MockRateLimiter(100, TimeSpan.FromMinutes(1));
        var cache = new MockCacheService();

        // Build decorated request handler
        var handler = new RequestHandlerBuilder(new BasicRequestHandler())
            .WithLogging(logger)
            .WithAuthentication(authService)
            .WithRateLimit(rateLimiter)
            .WithCaching(cache, TimeSpan.FromMinutes(10))
            .Build();

        Console.WriteLine("=== Middleware Pipeline Demo ===");

        // Test different request scenarios
        var requests = new[]
        {
            new HttpRequest { Method = "GET", Path = "/api/users", ClientIp = "192.168.1.100" },
            new HttpRequest 
            { 
                Method = "GET", 
                Path = "/api/users", 
                ClientIp = "192.168.1.100",
                Headers = { ["Authorization"] = "Bearer valid_token_123" }
            },
            new HttpRequest { Method = "GET", Path = "/health", ClientIp = "192.168.1.101" },
            new HttpRequest 
            { 
                Method = "POST", 
                Path = "/api/users", 
                ClientIp = "192.168.1.100",
                Headers = { ["Authorization"] = "Bearer invalid_token" }
            }
        };

        foreach (var request in requests)
        {
            Console.WriteLine($"\n--- Processing {request.Method} {request.Path} ---");
            
            try
            {
                var response = await handler.HandleAsync(request);
                Console.WriteLine($"Status: {response.StatusCode}");
                Console.WriteLine($"Body: {response.Body}");
                
                if (response.Headers.Any())
                {
                    Console.WriteLine("Headers:");
                    foreach (var header in response.Headers)
                    {
                        Console.WriteLine($"  {header.Key}: {header.Value}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        // Demonstrate caching effect
        Console.WriteLine("\n--- Testing Cache Hit ---");
        var cachedRequest = new HttpRequest 
        { 
            Method = "GET", 
            Path = "/api/users", 
            ClientIp = "192.168.1.100",
            Headers = { ["Authorization"] = "Bearer valid_token_123" }
        };

        var firstResponse = await handler.HandleAsync(cachedRequest);
        var secondResponse = await handler.HandleAsync(cachedRequest);
        
        Console.WriteLine($"First request cache: {firstResponse.Headers.GetValueOrDefault("X-Cache", "N/A")}");
        Console.WriteLine($"Second request cache: {secondResponse.Headers.GetValueOrDefault("X-Cache", "N/A")}");
    }
}
```

#### Data Processing Decorator Chain

#### Implementation 2: File Processing Pipeline

```csharp
// Base file processing interface
public interface IFileProcessor
{
    Task<ProcessingResult> ProcessAsync(FileData fileData, CancellationToken cancellationToken = default);
}

// File data container
public class FileData
{
    public string FileName { get; set; }
    public byte[] Content { get; set; }
    public Dictionary<string, object> Metadata { get; }
    public string ContentType { get; set; }
    public long Size => Content?.Length ?? 0;

    public FileData(string fileName, byte[] content, string contentType = null)
    {
        FileName = fileName ?? throw new ArgumentNullException(nameof(fileName));
        Content = content ?? throw new ArgumentNullException(nameof(content));
        ContentType = contentType ?? "application/octet-stream";
        Metadata = new Dictionary<string, object>();
    }

    public FileData Clone()
    {
        var clone = new FileData(FileName, (byte[])Content.Clone(), ContentType);
        foreach (var kvp in Metadata)
        {
            clone.Metadata[kvp.Key] = kvp.Value;
        }
        return clone;
    }
}

// Processing result
public class ProcessingResult
{
    public FileData ProcessedFile { get; }
    public bool IsSuccessful { get; }
    public string Message { get; }
    public TimeSpan ProcessingTime { get; }
    public List<string> AppliedProcessors { get; }

    public ProcessingResult(FileData processedFile, bool isSuccessful, string message, 
                           TimeSpan processingTime, List<string> appliedProcessors = null)
    {
        ProcessedFile = processedFile;
        IsSuccessful = isSuccessful;
        Message = message ?? string.Empty;
        ProcessingTime = processingTime;
        AppliedProcessors = appliedProcessors ?? new List<string>();
    }

    public static ProcessingResult Success(FileData file, TimeSpan time, List<string> processors = null)
    {
        return new ProcessingResult(file, true, "Processing completed successfully", time, processors);
    }

    public static ProcessingResult Failure(string message, FileData originalFile = null, TimeSpan time = default)
    {
        return new ProcessingResult(originalFile, false, message, time);
    }
}

// Base file processor
public class BaseFileProcessor : IFileProcessor
{
    public virtual async Task<ProcessingResult> ProcessAsync(FileData fileData, CancellationToken cancellationToken = default)
    {
        // Basic processing - just pass through
        await Task.Delay(1, cancellationToken);
        return ProcessingResult.Success(fileData.Clone(), TimeSpan.FromMilliseconds(1), new List<string> { "BaseProcessor" });
    }
}

// Abstract decorator base
public abstract class FileProcessorDecorator : IFileProcessor
{
    protected readonly IFileProcessor _inner;
    protected abstract string ProcessorName { get; }

    protected FileProcessorDecorator(IFileProcessor inner)
    {
        _inner = inner ?? throw new ArgumentNullException(nameof(inner));
    }

    public abstract Task<ProcessingResult> ProcessAsync(FileData fileData, CancellationToken cancellationToken = default);

    protected async Task<ProcessingResult> ProcessInnerAsync(FileData fileData, CancellationToken cancellationToken)
    {
        var result = await _inner.ProcessAsync(fileData, cancellationToken);
        if (result.IsSuccessful)
        {
            result.AppliedProcessors.Add(ProcessorName);
        }
        return result;
    }
}

// Concrete decorator: File validation
public class ValidationDecorator : FileProcessorDecorator
{
    private readonly FileValidationOptions _options;
    protected override string ProcessorName => "Validation";

    public ValidationDecorator(IFileProcessor inner, FileValidationOptions options = null) : base(inner)
    {
        _options = options ?? new FileValidationOptions();
    }

    public override async Task<ProcessingResult> ProcessAsync(FileData fileData, CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();

        // Validate file size
        if (fileData.Size > _options.MaxFileSizeBytes)
        {
            return ProcessingResult.Failure(
                $"File size {fileData.Size} bytes exceeds maximum allowed size of {_options.MaxFileSizeBytes} bytes",
                fileData, stopwatch.Elapsed);
        }

        if (fileData.Size < _options.MinFileSizeBytes)
        {
            return ProcessingResult.Failure(
                $"File size {fileData.Size} bytes is below minimum required size of {_options.MinFileSizeBytes} bytes",
                fileData, stopwatch.Elapsed);
        }

        // Validate file extension
        var extension = Path.GetExtension(fileData.FileName)?.ToLowerInvariant();
        if (_options.AllowedExtensions.Any() && !_options.AllowedExtensions.Contains(extension))
        {
            return ProcessingResult.Failure(
                $"File extension '{extension}' is not allowed. Allowed extensions: {string.Join(", ", _options.AllowedExtensions)}",
                fileData, stopwatch.Elapsed);
        }

        // Validate content type
        if (_options.AllowedContentTypes.Any() && !_options.AllowedContentTypes.Contains(fileData.ContentType))
        {
            return ProcessingResult.Failure(
                $"Content type '{fileData.ContentType}' is not allowed",
                fileData, stopwatch.Elapsed);
        }

        // Basic content validation (check for executable signatures)
        if (ContainsExecutableSignature(fileData.Content))
        {
            return ProcessingResult.Failure(
                "File appears to contain executable code and cannot be processed",
                fileData, stopwatch.Elapsed);
        }

        fileData.Metadata["ValidationPassed"] = true;
        fileData.Metadata["ValidatedAt"] = DateTime.UtcNow;

        var result = await ProcessInnerAsync(fileData, cancellationToken);
        stopwatch.Stop();
        
        return new ProcessingResult(result.ProcessedFile, result.IsSuccessful, result.Message, 
                                  stopwatch.Elapsed, result.AppliedProcessors);
    }

    private bool ContainsExecutableSignature(byte[] content)
    {
        if (content.Length < 2) return false;

        // Check for common executable signatures
        var signatures = new byte[][]
        {
            new byte[] { 0x4D, 0x5A }, // PE/COFF executable (Windows .exe)
            new byte[] { 0x7F, 0x45, 0x4C, 0x46 }, // ELF executable (Linux)
            new byte[] { 0xCA, 0xFE, 0xBA, 0xBE }, // Mach-O executable (macOS)
            new byte[] { 0xFE, 0xED, 0xFA, 0xCE } // Mach-O executable (macOS, different endian)
        };

        foreach (var signature in signatures)
        {
            if (content.Length >= signature.Length)
            {
                bool matches = true;
                for (int i = 0; i < signature.Length; i++)
                {
                    if (content[i] != signature[i])
                    {
                        matches = false;
                        break;
                    }
                }
                if (matches) return true;
            }
        }

        return false;
    }
}

// Concrete decorator: File compression
public class CompressionDecorator : FileProcessorDecorator
{
    private readonly CompressionLevel _compressionLevel;
    protected override string ProcessorName => "Compression";

    public CompressionDecorator(IFileProcessor inner, CompressionLevel compressionLevel = CompressionLevel.Optimal) : base(inner)
    {
        _compressionLevel = compressionLevel;
    }

    public override async Task<ProcessingResult> ProcessAsync(FileData fileData, CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();

        try
        {
            // Compress file content
            var originalSize = fileData.Content.Length;
            var compressedContent = await CompressDataAsync(fileData.Content, cancellationToken);
            var compressionRatio = (double)compressedContent.Length / originalSize;

            // Only apply compression if it actually reduces size
            if (compressionRatio < 0.95) // At least 5% reduction
            {
                var processedFile = new FileData(
                    fileData.FileName + ".gz", 
                    compressedContent, 
                    "application/gzip");

                // Copy metadata and add compression info
                foreach (var kvp in fileData.Metadata)
                {
                    processedFile.Metadata[kvp.Key] = kvp.Value;
                }

                processedFile.Metadata["OriginalSize"] = originalSize;
                processedFile.Metadata["CompressedSize"] = compressedContent.Length;
                processedFile.Metadata["CompressionRatio"] = compressionRatio;
                processedFile.Metadata["CompressionLevel"] = _compressionLevel.ToString();

                var result = await ProcessInnerAsync(processedFile, cancellationToken);
                stopwatch.Stop();

                return new ProcessingResult(result.ProcessedFile, result.IsSuccessful, 
                                          $"{result.Message} (Compressed: {originalSize} → {compressedContent.Length} bytes)", 
                                          stopwatch.Elapsed, result.AppliedProcessors);
            }
            else
            {
                // Compression not beneficial, proceed without compression
                fileData.Metadata["CompressionSkipped"] = true;
                fileData.Metadata["CompressionRatio"] = compressionRatio;
                
                var result = await ProcessInnerAsync(fileData, cancellationToken);
                stopwatch.Stop();

                return new ProcessingResult(result.ProcessedFile, result.IsSuccessful, 
                                          $"{result.Message} (Compression skipped - not beneficial)", 
                                          stopwatch.Elapsed, result.AppliedProcessors);
            }
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            return ProcessingResult.Failure($"Compression failed: {ex.Message}", fileData, stopwatch.Elapsed);
        }
    }

    private async Task<byte[]> CompressDataAsync(byte[] data, CancellationToken cancellationToken)
    {
        using var output = new MemoryStream();
        using var gzipStream = new GZipStream(output, _compressionLevel);
        
        await gzipStream.WriteAsync(data, 0, data.Length, cancellationToken);
        await gzipStream.FlushAsync(cancellationToken);
        
        return output.ToArray();
    }
}

// Concrete decorator: File encryption
public class EncryptionDecorator : FileProcessorDecorator
{
    private readonly EncryptionOptions _options;
    protected override string ProcessorName => "Encryption";

    public EncryptionDecorator(IFileProcessor inner, EncryptionOptions options) : base(inner)
    {
        _options = options ?? throw new ArgumentNullException(nameof(options));
    }

    public override async Task<ProcessingResult> ProcessAsync(FileData fileData, CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();

        try
        {
            var encryptedContent = await EncryptDataAsync(fileData.Content, cancellationToken);
            
            var processedFile = new FileData(
                fileData.FileName + ".enc", 
                encryptedContent, 
                "application/encrypted");

            // Copy metadata and add encryption info
            foreach (var kvp in fileData.Metadata)
            {
                processedFile.Metadata[kvp.Key] = kvp.Value;
            }

            processedFile.Metadata["OriginalSize"] = fileData.Content.Length;
            processedFile.Metadata["EncryptedSize"] = encryptedContent.Length;
            processedFile.Metadata["EncryptionAlgorithm"] = _options.Algorithm;
            processedFile.Metadata["EncryptedAt"] = DateTime.UtcNow;

            var result = await ProcessInnerAsync(processedFile, cancellationToken);
            stopwatch.Stop();

            return new ProcessingResult(result.ProcessedFile, result.IsSuccessful, 
                                      $"{result.Message} (Encrypted with {_options.Algorithm})", 
                                      stopwatch.Elapsed, result.AppliedProcessors);
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            return ProcessingResult.Failure($"Encryption failed: {ex.Message}", fileData, stopwatch.Elapsed);
        }
    }

    private async Task<byte[]> EncryptDataAsync(byte[] data, CancellationToken cancellationToken)
    {
        // Simple XOR encryption for demo (use proper encryption in production)
        await Task.CompletedTask; // Async compliance
        
        var key = Encoding.UTF8.GetBytes(_options.Key.PadRight(32).Substring(0, 32));
        var encrypted = new byte[data.Length];

        for (int i = 0; i < data.Length; i++)
        {
            encrypted[i] = (byte)(data[i] ^ key[i % key.Length]);
        }

        return encrypted;
    }
}

// Configuration classes
public class FileValidationOptions
{
    public long MaxFileSizeBytes { get; set; } = 10 * 1024 * 1024; // 10MB
    public long MinFileSizeBytes { get; set; } = 1; // 1 byte
    public HashSet<string> AllowedExtensions { get; set; } = new HashSet<string>();
    public HashSet<string> AllowedContentTypes { get; set; } = new HashSet<string>();
}

public class EncryptionOptions
{
    public string Algorithm { get; set; } = "AES-256";
    public string Key { get; set; } = "DefaultEncryptionKey123!";
}

// File processor builder
public class FileProcessorBuilder
{
    private IFileProcessor _processor;

    public FileProcessorBuilder(IFileProcessor baseProcessor = null)
    {
        _processor = baseProcessor ?? new BaseFileProcessor();
    }

    public FileProcessorBuilder WithValidation(FileValidationOptions options = null)
    {
        _processor = new ValidationDecorator(_processor, options);
        return this;
    }

    public FileProcessorBuilder WithCompression(CompressionLevel level = CompressionLevel.Optimal)
    {
        _processor = new CompressionDecorator(_processor, level);
        return this;
    }

    public FileProcessorBuilder WithEncryption(EncryptionOptions options)
    {
        _processor = new EncryptionDecorator(_processor, options);
        return this;
    }

    public IFileProcessor Build()
    {
        return _processor;
    }
}

// Usage example
public class FileProcessingExample
{
    public async Task DemonstrateFileProcessing()
    {
        // Setup validation options
        var validationOptions = new FileValidationOptions
        {
            MaxFileSizeBytes = 5 * 1024 * 1024, // 5MB
            AllowedExtensions = new HashSet<string> { ".txt", ".pdf", ".docx", ".jpg", ".png" }
        };

        var encryptionOptions = new EncryptionOptions
        {
            Algorithm = "AES-256",
            Key = "MySecretKey123456789012345678901234"
        };

        // Build file processor with decorators
        var processor = new FileProcessorBuilder()
            .WithValidation(validationOptions)
            .WithCompression(CompressionLevel.Optimal)
            .WithEncryption(encryptionOptions)
            .Build();

        Console.WriteLine("=== File Processing Pipeline Demo ===");

        // Test different files
        var testFiles = new[]
        {
            CreateTestFile("document.txt", "This is a sample text document with some content that can be compressed."),
            CreateTestFile("image.jpg", new string('A', 100)), // Small binary-like file
            CreateTestFile("large.txt", new string('X', 1000)), // Larger text file
            CreateTestFile("script.exe", "MZ"), // Executable-like file (should fail validation)
        };

        foreach (var file in testFiles)
        {
            Console.WriteLine($"\n--- Processing {file.FileName} ({file.Size} bytes) ---");
            
            try
            {
                var result = await processor.ProcessAsync(file);
                
                Console.WriteLine($"Success: {result.IsSuccessful}");
                Console.WriteLine($"Message: {result.Message}");
                Console.WriteLine($"Processing time: {result.ProcessingTime.TotalMilliseconds:F1}ms");
                Console.WriteLine($"Applied processors: {string.Join(" → ", result.AppliedProcessors)}");

                if (result.IsSuccessful)
                {
                    Console.WriteLine($"Final file: {result.ProcessedFile.FileName} ({result.ProcessedFile.Size} bytes)");
                    
                    if (result.ProcessedFile.Metadata.Any())
                    {
                        Console.WriteLine("Metadata:");
                        foreach (var kvp in result.ProcessedFile.Metadata)
                        {
                            Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }

    private FileData CreateTestFile(string fileName, string content)
    {
        var bytes = Encoding.UTF8.GetBytes(content);
        return new FileData(fileName, bytes, "text/plain");
    }
}
```

### Practical Implementation (8 minutes)

#### UI Component Decorator System

#### Implementation 3: Dynamic UI Enhancement

```csharp
// Base UI component interface
public interface IUIComponent
{
    string Render();
    Dictionary<string, object> GetProperties();
    void SetProperty(string name, object value);
}

// Basic UI components
public class Button : IUIComponent
{
    private readonly Dictionary<string, object> _properties = new Dictionary<string, object>();

    public string Text { get; set; } = "Button";
    public string Id { get; set; } = Guid.NewGuid().ToString("N")[..8];

    public Button(string text = "Button")
    {
        Text = text;
        _properties["type"] = "button";
        _properties["text"] = text;
        _properties["id"] = Id;
    }

    public string Render()
    {
        return $"<button id=\"{Id}\" type=\"button\">{Text}</button>";
    }

    public Dictionary<string, object> GetProperties()
    {
        return new Dictionary<string, object>(_properties);
    }

    public void SetProperty(string name, object value)
    {
        _properties[name] = value;
    }
}

public class TextInput : IUIComponent
{
    private readonly Dictionary<string, object> _properties = new Dictionary<string, object>();

    public string Placeholder { get; set; } = "";
    public string Id { get; set; } = Guid.NewGuid().ToString("N")[..8];

    public TextInput(string placeholder = "")
    {
        Placeholder = placeholder;
        _properties["type"] = "text";
        _properties["placeholder"] = placeholder;
        _properties["id"] = Id;
    }

    public string Render()
    {
        return $"<input id=\"{Id}\" type=\"text\" placeholder=\"{Placeholder}\" />";
    }

    public Dictionary<string, object> GetProperties()
    {
        return new Dictionary<string, object>(_properties);
    }

    public void SetProperty(string name, object value)
    {
        _properties[name] = value;
    }
}

// Abstract decorator base
public abstract class UIComponentDecorator : IUIComponent
{
    protected readonly IUIComponent _component;
    protected abstract string DecoratorName { get; }

    protected UIComponentDecorator(IUIComponent component)
    {
        _component = component ?? throw new ArgumentNullException(nameof(component));
    }

    public virtual string Render()
    {
        return _component.Render();
    }

    public virtual Dictionary<string, object> GetProperties()
    {
        var properties = _component.GetProperties();
        if (!properties.ContainsKey("decorators"))
        {
            properties["decorators"] = new List<string>();
        }
        ((List<string>)properties["decorators"]).Add(DecoratorName);
        return properties;
    }

    public virtual void SetProperty(string name, object value)
    {
        _component.SetProperty(name, value);
    }
}

// Concrete decorators
public class BorderDecorator : UIComponentDecorator
{
    protected override string DecoratorName => "Border";
    
    public string BorderStyle { get; set; } = "solid";
    public string BorderWidth { get; set; } = "1px";
    public string BorderColor { get; set; } = "#ccc";
    public string BorderRadius { get; set; } = "4px";

    public BorderDecorator(IUIComponent component, string style = "solid", string width = "1px", 
                          string color = "#ccc", string radius = "4px") : base(component)
    {
        BorderStyle = style;
        BorderWidth = width;
        BorderColor = color;
        BorderRadius = radius;
    }

    public override string Render()
    {
        var innerContent = _component.Render();
        var borderStyle = $"border: {BorderWidth} {BorderStyle} {BorderColor}; border-radius: {BorderRadius};";
        
        return $"<div style=\"{borderStyle} display: inline-block;\">{innerContent}</div>";
    }

    public override Dictionary<string, object> GetProperties()
    {
        var properties = base.GetProperties();
        properties["borderStyle"] = BorderStyle;
        properties["borderWidth"] = BorderWidth;
        properties["borderColor"] = BorderColor;
        properties["borderRadius"] = BorderRadius;
        return properties;
    }
}

public class TooltipDecorator : UIComponentDecorator
{
    protected override string DecoratorName => "Tooltip";
    
    public string TooltipText { get; set; }
    public string Position { get; set; } = "top";

    public TooltipDecorator(IUIComponent component, string tooltipText, string position = "top") : base(component)
    {
        TooltipText = tooltipText ?? throw new ArgumentNullException(nameof(tooltipText));
        Position = position;
    }

    public override string Render()
    {
        var innerContent = _component.Render();
        return $"<div class=\"tooltip-container\" data-tooltip=\"{TooltipText}\" data-position=\"{Position}\">{innerContent}</div>";
    }

    public override Dictionary<string, object> GetProperties()
    {
        var properties = base.GetProperties();
        properties["tooltipText"] = TooltipText;
        properties["tooltipPosition"] = Position;
        return properties;
    }
}

public class ValidationDecorator : UIComponentDecorator
{
    protected override string DecoratorName => "Validation";
    
    public List<ValidationRule> ValidationRules { get; } = new List<ValidationRule>();
    public string ErrorMessage { get; set; } = "";
    public bool ShowValidationState { get; set; } = true;

    public ValidationDecorator(IUIComponent component, params ValidationRule[] rules) : base(component)
    {
        if (rules != null)
        {
            ValidationRules.AddRange(rules);
        }
    }

    public override string Render()
    {
        var innerContent = _component.Render();
        var validationClass = ShowValidationState ? "validation-enabled" : "";
        var errorDisplay = !string.IsNullOrEmpty(ErrorMessage) ? 
            $"<span class=\"error-message\">{ErrorMessage}</span>" : "";

        return $"<div class=\"validation-wrapper {validationClass}\">{innerContent}{errorDisplay}</div>";
    }

    public override Dictionary<string, object> GetProperties()
    {
        var properties = base.GetProperties();
        properties["validationRules"] = ValidationRules.Select(r => r.ToString()).ToList();
        properties["errorMessage"] = ErrorMessage;
        properties["showValidationState"] = ShowValidationState;
        return properties;
    }

    public ValidationResult Validate(string value)
    {
        foreach (var rule in ValidationRules)
        {
            var result = rule.Validate(value);
            if (!result.IsValid)
            {
                ErrorMessage = result.ErrorMessage;
                return result;
            }
        }

        ErrorMessage = "";
        return ValidationResult.Success();
    }
}

public class ThemeDecorator : UIComponentDecorator
{
    protected override string DecoratorName => "Theme";
    
    public UITheme Theme { get; set; }

    public ThemeDecorator(IUIComponent component, UITheme theme) : base(component)
    {
        Theme = theme ?? throw new ArgumentNullException(nameof(theme));
    }

    public override string Render()
    {
        var innerContent = _component.Render();
        var themeStyles = GenerateThemeStyles();
        
        return $"<div class=\"themed-component {Theme.Name}\" style=\"{themeStyles}\">{innerContent}</div>";
    }

    private string GenerateThemeStyles()
    {
        var styles = new List<string>();
        
        if (!string.IsNullOrEmpty(Theme.BackgroundColor))
            styles.Add($"background-color: {Theme.BackgroundColor}");
        
        if (!string.IsNullOrEmpty(Theme.TextColor))
            styles.Add($"color: {Theme.TextColor}");
        
        if (!string.IsNullOrEmpty(Theme.FontFamily))
            styles.Add($"font-family: {Theme.FontFamily}");
        
        if (!string.IsNullOrEmpty(Theme.FontSize))
            styles.Add($"font-size: {Theme.FontSize}");

        return string.Join("; ", styles);
    }

    public override Dictionary<string, object> GetProperties()
    {
        var properties = base.GetProperties();
        properties["theme"] = Theme.Name;
        properties["themeColors"] = new { Background = Theme.BackgroundColor, Text = Theme.TextColor };
        return properties;
    }
}

// Supporting classes
public class ValidationRule
{
    public string Name { get; }
    public Func<string, ValidationResult> Validator { get; }

    public ValidationRule(string name, Func<string, ValidationResult> validator)
    {
        Name = name ?? throw new ArgumentNullException(nameof(name));
        Validator = validator ?? throw new ArgumentNullException(nameof(validator));
    }

    public ValidationResult Validate(string value)
    {
        return Validator(value);
    }

    public override string ToString() => Name;

    // Common validation rules
    public static ValidationRule Required => new ValidationRule(
        "Required",
        value => string.IsNullOrWhiteSpace(value) 
            ? ValidationResult.Error("This field is required") 
            : ValidationResult.Success()
    );

    public static ValidationRule Email => new ValidationRule(
        "Email",
        value => string.IsNullOrWhiteSpace(value) || IsValidEmail(value)
            ? ValidationResult.Success()
            : ValidationResult.Error("Please enter a valid email address")
    );

    public static ValidationRule MinLength(int minLength) => new ValidationRule(
        $"MinLength({minLength})",
        value => string.IsNullOrEmpty(value) || value.Length >= minLength
            ? ValidationResult.Success()
            : ValidationResult.Error($"Must be at least {minLength} characters long")
    );

    private static bool IsValidEmail(string email)
    {
        try
        {
            var addr = new System.Net.Mail.MailAddress(email);
            return addr.Address == email;
        }
        catch
        {
            return false;
        }
    }
}

public class ValidationResult
{
    public bool IsValid { get; }
    public string ErrorMessage { get; }

    private ValidationResult(bool isValid, string errorMessage = "")
    {
        IsValid = isValid;
        ErrorMessage = errorMessage ?? "";
    }

    public static ValidationResult Success() => new ValidationResult(true);
    public static ValidationResult Error(string message) => new ValidationResult(false, message);
}

public class UITheme
{
    public string Name { get; set; }
    public string BackgroundColor { get; set; }
    public string TextColor { get; set; }
    public string FontFamily { get; set; }
    public string FontSize { get; set; }

    public static UITheme Light => new UITheme
    {
        Name = "light",
        BackgroundColor = "#ffffff",
        TextColor = "#333333",
        FontFamily = "Arial, sans-serif",
        FontSize = "14px"
    };

    public static UITheme Dark => new UITheme
    {
        Name = "dark",
        BackgroundColor = "#2d2d2d",
        TextColor = "#ffffff",
        FontFamily = "Arial, sans-serif",
        FontSize = "14px"
    };

    public static UITheme Material => new UITheme
    {
        Name = "material",
        BackgroundColor = "#f5f5f5",
        TextColor = "#212121",
        FontFamily = "Roboto, sans-serif",
        FontSize = "16px"
    };
}

// Component builder for fluent decoration
public class UIComponentBuilder
{
    private IUIComponent _component;

    public UIComponentBuilder(IUIComponent baseComponent)
    {
        _component = baseComponent ?? throw new ArgumentNullException(nameof(baseComponent));
    }

    public UIComponentBuilder WithBorder(string style = "solid", string width = "1px", 
                                        string color = "#ccc", string radius = "4px")
    {
        _component = new BorderDecorator(_component, style, width, color, radius);
        return this;
    }

    public UIComponentBuilder WithTooltip(string text, string position = "top")
    {
        _component = new TooltipDecorator(_component, text, position);
        return this;
    }

    public UIComponentBuilder WithValidation(params ValidationRule[] rules)
    {
        _component = new ValidationDecorator(_component, rules);
        return this;
    }

    public UIComponentBuilder WithTheme(UITheme theme)
    {
        _component = new ThemeDecorator(_component, theme);
        return this;
    }

    public IUIComponent Build()
    {
        return _component;
    }
}

// Usage example
public class UIDecoratorExample
{
    public void DemonstrateUIDecorators()
    {
        Console.WriteLine("=== UI Component Decorator Demo ===");

        // Create various decorated components
        var components = new Dictionary<string, IUIComponent>
        {
            ["Simple Button"] = new Button("Click Me"),
            
            ["Bordered Button"] = new UIComponentBuilder(new Button("Save"))
                .WithBorder("solid", "2px", "#007bff", "6px")
                .Build(),
            
            ["Button with Tooltip"] = new UIComponentBuilder(new Button("Delete"))
                .WithTooltip("This action cannot be undone", "top")
                .WithBorder("solid", "1px", "#dc3545", "4px")
                .Build(),
            
            ["Themed Input"] = new UIComponentBuilder(new TextInput("Enter your name"))
                .WithTheme(UITheme.Dark)
                .WithBorder("solid", "1px", "#555", "4px")
                .Build(),
            
            ["Validated Email Input"] = new UIComponentBuilder(new TextInput("Enter email address"))
                .WithValidation(ValidationRule.Required, ValidationRule.Email)
                .WithTooltip("We'll never share your email", "bottom")
                .WithTheme(UITheme.Material)
                .WithBorder("solid", "2px", "#4caf50", "8px")
                .Build()
        };

        foreach (var (name, component) in components)
        {
            Console.WriteLine($"\n--- {name} ---");
            Console.WriteLine("HTML:");
            Console.WriteLine(component.Render());
            
            Console.WriteLine("\nProperties:");
            var properties = component.GetProperties();
            foreach (var prop in properties)
            {
                if (prop.Value is List<string> list)
                {
                    Console.WriteLine($"  {prop.Key}: [{string.Join(", ", list)}]");
                }
                else
                {
                    Console.WriteLine($"  {prop.Key}: {prop.Value}");
                }
            }
        }

        // Demonstrate validation
        Console.WriteLine("\n--- Validation Demo ---");
        var emailInput = components["Validated Email Input"];
        if (emailInput is ValidationDecorator validator)
        {
            var testInputs = new[] { "", "invalid-email", "test@example.com" };
            
            foreach (var input in testInputs)
            {
                var result = validator.Validate(input);
                Console.WriteLine($"Input '{input}': {(result.IsValid ? "Valid" : $"Invalid - {result.ErrorMessage}")}");
            }
        }
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Decorator Pattern Benefits**:

- ✅ **Flexible composition**: Add behavior dynamically without inheritance explosion
- ✅ **Single Responsibility**: Each decorator handles one specific concern
- ✅ **Runtime configuration**: Decorators can be applied and removed at runtime
- ✅ **Open/Closed Principle**: New decorators can be added without modifying existing code

**Decorator Pattern Applications**:

- **Middleware pipelines** - Request/response processing chains
- **Data processing** - Validation, transformation, compression, encryption
- **UI enhancement** - Borders, themes, validation, tooltips
- **Cross-cutting concerns** - Logging, caching, security, monitoring

**Implementation Considerations**:

- **Order dependency** - Decorator order can significantly impact behavior
- **Performance overhead** - Multiple layers can impact performance
- **Interface consistency** - All decorators must maintain the same interface
- **Memory usage** - Decorator chains can increase memory footprint

**Best Practices**:

- Use builder patterns for fluent decorator composition
- Keep decorators focused on single responsibilities
- Consider decorator order and dependencies carefully
- Implement proper error handling in decorator chains

### Next Steps

**Immediate Actions**:

- Implement decorator factories for common combinations
- Add decorator removal/unwrapping capabilities
- Continue to **Command Pattern**: Action encapsulation and undo/redo

**Advanced Topics**:

- Decorator pattern with dependency injection
- Performance optimization in decorator chains
- Decorator pattern in distributed systems

## 🔗 Related Topics

**Prerequisites**: Strategy Pattern (Part 5), Inheritance vs Composition, Interface design  
**Builds Upon**: Single Responsibility Principle, Open/Closed Principle, Composition over inheritance  
**Enables**: Command Pattern, Chain of Responsibility Pattern, Middleware architectures  
**Related**: Proxy pattern, Adapter pattern, Composite pattern
