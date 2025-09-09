# 12_Design-Patterns-Part7-Command-Pattern

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Decorator Pattern (Part 6), Event handling concepts  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Command Pattern for action encapsulation and execution control
- Implement undo/redo functionality with command history management
- Design macro recording and batch operation systems
- Apply command patterns in UI actions, database transactions, and API operations

## 📋 Content Sections

### Quick Overview (5 minutes)

**Command Pattern**: *"Encapsulate a request as an object, thereby letting you parameterize clients with different requests, queue or log requests, and support undoable operations."*

**Core Problem**: Need to decouple the invoker of an action from the receiver, enabling queuing, logging, undo operations, and macro recording.

```text
❌ TIGHT COUPLING PROBLEM
┌─────────────────┐    ┌─────────────────┐
│   MenuButton    │────│   TextEditor    │
├─────────────────┤    ├─────────────────┤
│ - OnClick()     │────│ + Copy()        │
│   editor.Copy() │    │ + Paste()       │
│                 │    │ + Delete()      │
└─────────────────┘    └─────────────────┘
         │                       ▲
         │              ┌─────────────────┐
         └──────────────│   Toolbar       │
                        ├─────────────────┤
                        │ - OnClick()     │
                        │   editor.Copy() │
                        └─────────────────┘
    ❌ Direct dependencies, no undo, no macro recording

✅ COMMAND PATTERN SOLUTION
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Invoker       │    │   ICommand      │    │  CopyCommand    │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ - command       │◄───│ + Execute()     │◄───│ - receiver      │
│ + SetCommand()  │    │ + Undo()        │    │ + Execute()     │
│ + Execute()     │    │ + CanUndo()     │    │ + Undo()        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       ▲                       │
         │                       │                       ▼
┌─────────────────┐              │              ┌─────────────────┐
│CommandHistory   │              └──────────────│   TextEditor    │
├─────────────────┤                             ├─────────────────┤
│ + Execute()     │                             │ + Copy()        │
│ + Undo()        │                             │ + Paste()       │
│ + Redo()        │                             │ + Delete()      │
└─────────────────┘                             └─────────────────┘
    ✅ Loose coupling, undo/redo, macro support, logging
```

**Real-World Applications**:

- **Text Editors** - Undo/redo operations, macro recording
- **Database Systems** - Transaction management, rollback capabilities
- **GUI Applications** - Menu actions, toolbar commands, keyboard shortcuts
- **API Operations** - Request queuing, batch processing, retry mechanisms

### Core Concepts (15 minutes)

#### Text Editor Command System

#### Implementation 1: Document Editor with Undo/Redo

```csharp
// Command interface
public interface ICommand
{
    string Name { get; }
    DateTime ExecutedAt { get; }
    bool CanUndo { get; }
    bool CanRedo { get; }
    
    CommandResult Execute();
    CommandResult Undo();
    ICommand CreateInverse();
}

// Command execution result
public class CommandResult
{
    public bool IsSuccessful { get; }
    public string Message { get; }
    public object Data { get; }

    private CommandResult(bool isSuccessful, string message, object data = null)
    {
        IsSuccessful = isSuccessful;
        Message = message ?? string.Empty;
        Data = data;
    }

    public static CommandResult Success(string message = "Command executed successfully", object data = null)
    {
        return new CommandResult(true, message, data);
    }

    public static CommandResult Failure(string message, object data = null)
    {
        return new CommandResult(false, message, data);
    }
}

// Document model for the editor
public class Document
{
    private readonly List<string> _lines;
    public IReadOnlyList<string> Lines => _lines.AsReadOnly();
    public int LineCount => _lines.Count;

    public Document()
    {
        _lines = new List<string>();
    }

    public Document(IEnumerable<string> lines)
    {
        _lines = new List<string>(lines ?? Enumerable.Empty<string>());
    }

    public void InsertLine(int index, string content)
    {
        if (index < 0 || index > _lines.Count)
            throw new ArgumentOutOfRangeException(nameof(index));

        _lines.Insert(index, content ?? string.Empty);
    }

    public void RemoveLine(int index)
    {
        if (index < 0 || index >= _lines.Count)
            throw new ArgumentOutOfRangeException(nameof(index));

        _lines.RemoveAt(index);
    }

    public void UpdateLine(int index, string content)
    {
        if (index < 0 || index >= _lines.Count)
            throw new ArgumentOutOfRangeException(nameof(index));

        _lines[index] = content ?? string.Empty;
    }

    public string GetLine(int index)
    {
        if (index < 0 || index >= _lines.Count)
            return string.Empty;

        return _lines[index];
    }

    public void Clear()
    {
        _lines.Clear();
    }

    public Document Clone()
    {
        return new Document(_lines);
    }

    public override string ToString()
    {
        return string.Join(Environment.NewLine, _lines);
    }
}

// Abstract base command
public abstract class DocumentCommand : ICommand
{
    public string Name { get; protected set; }
    public DateTime ExecutedAt { get; private set; }
    public bool CanUndo { get; protected set; } = true;
    public bool CanRedo { get; protected set; } = true;

    protected Document Document { get; }
    protected bool HasBeenExecuted { get; private set; }

    protected DocumentCommand(Document document, string name)
    {
        Document = document ?? throw new ArgumentNullException(nameof(document));
        Name = name ?? throw new ArgumentNullException(nameof(name));
    }

    public CommandResult Execute()
    {
        try
        {
            var result = ExecuteCore();
            if (result.IsSuccessful)
            {
                ExecutedAt = DateTime.UtcNow;
                HasBeenExecuted = true;
            }
            return result;
        }
        catch (Exception ex)
        {
            return CommandResult.Failure($"Command execution failed: {ex.Message}");
        }
    }

    public CommandResult Undo()
    {
        if (!CanUndo || !HasBeenExecuted)
        {
            return CommandResult.Failure("Command cannot be undone");
        }

        try
        {
            return UndoCore();
        }
        catch (Exception ex)
        {
            return CommandResult.Failure($"Undo failed: {ex.Message}");
        }
    }

    protected abstract CommandResult ExecuteCore();
    protected abstract CommandResult UndoCore();
    public abstract ICommand CreateInverse();
}

// Concrete command: Insert line
public class InsertLineCommand : DocumentCommand
{
    public int LineIndex { get; }
    public string Content { get; }

    public InsertLineCommand(Document document, int lineIndex, string content) 
        : base(document, $"Insert line at {lineIndex}")
    {
        LineIndex = lineIndex;
        Content = content ?? string.Empty;
    }

    protected override CommandResult ExecuteCore()
    {
        Document.InsertLine(LineIndex, Content);
        return CommandResult.Success($"Inserted line at index {LineIndex}: \"{Content}\"");
    }

    protected override CommandResult UndoCore()
    {
        Document.RemoveLine(LineIndex);
        return CommandResult.Success($"Removed line at index {LineIndex}");
    }

    public override ICommand CreateInverse()
    {
        return new RemoveLineCommand(Document, LineIndex);
    }
}

// Concrete command: Remove line
public class RemoveLineCommand : DocumentCommand
{
    public int LineIndex { get; }
    private string _removedContent;

    public RemoveLineCommand(Document document, int lineIndex) 
        : base(document, $"Remove line at {lineIndex}")
    {
        LineIndex = lineIndex;
    }

    protected override CommandResult ExecuteCore()
    {
        if (LineIndex >= Document.LineCount)
        {
            return CommandResult.Failure($"Cannot remove line {LineIndex}: line does not exist");
        }

        _removedContent = Document.GetLine(LineIndex);
        Document.RemoveLine(LineIndex);
        return CommandResult.Success($"Removed line at index {LineIndex}: \"{_removedContent}\"");
    }

    protected override CommandResult UndoCore()
    {
        Document.InsertLine(LineIndex, _removedContent);
        return CommandResult.Success($"Restored line at index {LineIndex}: \"{_removedContent}\"");
    }

    public override ICommand CreateInverse()
    {
        return new InsertLineCommand(Document, LineIndex, _removedContent ?? string.Empty);
    }
}

// Concrete command: Update line
public class UpdateLineCommand : DocumentCommand
{
    public int LineIndex { get; }
    public string NewContent { get; }
    private string _originalContent;

    public UpdateLineCommand(Document document, int lineIndex, string newContent) 
        : base(document, $"Update line at {lineIndex}")
    {
        LineIndex = lineIndex;
        NewContent = newContent ?? string.Empty;
    }

    protected override CommandResult ExecuteCore()
    {
        if (LineIndex >= Document.LineCount)
        {
            return CommandResult.Failure($"Cannot update line {LineIndex}: line does not exist");
        }

        _originalContent = Document.GetLine(LineIndex);
        Document.UpdateLine(LineIndex, NewContent);
        return CommandResult.Success($"Updated line {LineIndex}: \"{_originalContent}\" → \"{NewContent}\"");
    }

    protected override CommandResult UndoCore()
    {
        Document.UpdateLine(LineIndex, _originalContent);
        return CommandResult.Success($"Reverted line {LineIndex}: \"{NewContent}\" → \"{_originalContent}\"");
    }

    public override ICommand CreateInverse()
    {
        return new UpdateLineCommand(Document, LineIndex, _originalContent ?? string.Empty);
    }
}

// Composite command for batch operations
public class CompositeCommand : DocumentCommand
{
    private readonly List<ICommand> _commands;

    public CompositeCommand(Document document, string name, IEnumerable<ICommand> commands) 
        : base(document, name)
    {
        _commands = new List<ICommand>(commands ?? Enumerable.Empty<ICommand>());
    }

    protected override CommandResult ExecuteCore()
    {
        var results = new List<CommandResult>();
        var executedCommands = new List<ICommand>();

        foreach (var command in _commands)
        {
            var result = command.Execute();
            results.Add(result);
            
            if (result.IsSuccessful)
            {
                executedCommands.Add(command);
            }
            else
            {
                // Rollback previously executed commands
                for (int i = executedCommands.Count - 1; i >= 0; i--)
                {
                    executedCommands[i].Undo();
                }
                
                return CommandResult.Failure($"Batch operation failed at command {executedCommands.Count + 1}: {result.Message}");
            }
        }

        var successCount = results.Count(r => r.IsSuccessful);
        return CommandResult.Success($"Executed {successCount} commands successfully", results);
    }

    protected override CommandResult UndoCore()
    {
        var results = new List<CommandResult>();
        
        // Undo commands in reverse order
        for (int i = _commands.Count - 1; i >= 0; i--)
        {
            var result = _commands[i].Undo();
            results.Add(result);
        }

        var successCount = results.Count(r => r.IsSuccessful);
        return CommandResult.Success($"Undid {successCount} commands", results);
    }

    public override ICommand CreateInverse()
    {
        var inverseCommands = _commands.Select(c => c.CreateInverse()).Reverse();
        return new CompositeCommand(Document, $"Inverse of {Name}", inverseCommands);
    }
}

// Command history manager
public class CommandHistory
{
    private readonly Stack<ICommand> _undoStack;
    private readonly Stack<ICommand> _redoStack;
    private readonly int _maxHistorySize;

    public int UndoCount => _undoStack.Count;
    public int RedoCount => _redoStack.Count;
    public bool CanUndo => _undoStack.Count > 0;
    public bool CanRedo => _redoStack.Count > 0;

    public CommandHistory(int maxHistorySize = 100)
    {
        _maxHistorySize = Math.Max(1, maxHistorySize);
        _undoStack = new Stack<ICommand>();
        _redoStack = new Stack<ICommand>();
    }

    public CommandResult ExecuteCommand(ICommand command)
    {
        if (command == null)
            return CommandResult.Failure("Command cannot be null");

        var result = command.Execute();
        
        if (result.IsSuccessful && command.CanUndo)
        {
            _undoStack.Push(command);
            _redoStack.Clear(); // Clear redo stack when new command is executed
            
            // Maintain history size limit
            while (_undoStack.Count > _maxHistorySize)
            {
                var oldestCommand = _undoStack.ToArray().Last();
                var tempStack = new Stack<ICommand>();
                
                // Move all commands except the oldest to temp stack
                for (int i = 0; i < _undoStack.Count - 1; i++)
                {
                    tempStack.Push(_undoStack.Pop());
                }
                
                _undoStack.Pop(); // Remove oldest
                
                // Restore commands in correct order
                while (tempStack.Count > 0)
                {
                    _undoStack.Push(tempStack.Pop());
                }
            }
        }

        return result;
    }

    public CommandResult Undo()
    {
        if (!CanUndo)
            return CommandResult.Failure("No commands to undo");

        var command = _undoStack.Pop();
        var result = command.Undo();
        
        if (result.IsSuccessful)
        {
            _redoStack.Push(command);
        }
        else
        {
            // Put command back on undo stack if undo failed
            _undoStack.Push(command);
        }

        return result;
    }

    public CommandResult Redo()
    {
        if (!CanRedo)
            return CommandResult.Failure("No commands to redo");

        var command = _redoStack.Pop();
        var result = command.Execute();
        
        if (result.IsSuccessful)
        {
            _undoStack.Push(command);
        }
        else
        {
            // Put command back on redo stack if redo failed
            _redoStack.Push(command);
        }

        return result;
    }

    public void Clear()
    {
        _undoStack.Clear();
        _redoStack.Clear();
    }

    public IEnumerable<string> GetUndoHistory()
    {
        return _undoStack.Select(c => $"{c.Name} (executed at {c.ExecutedAt:HH:mm:ss})");
    }

    public IEnumerable<string> GetRedoHistory()
    {
        return _redoStack.Select(c => c.Name);
    }
}

// Document editor with command support
public class DocumentEditor
{
    private readonly Document _document;
    private readonly CommandHistory _history;

    public IReadOnlyList<string> Lines => _document.Lines;
    public int LineCount => _document.LineCount;
    public bool CanUndo => _history.CanUndo;
    public bool CanRedo => _history.CanRedo;

    public DocumentEditor()
    {
        _document = new Document();
        _history = new CommandHistory();
    }

    public CommandResult InsertLine(int index, string content)
    {
        var command = new InsertLineCommand(_document, index, content);
        return _history.ExecuteCommand(command);
    }

    public CommandResult RemoveLine(int index)
    {
        var command = new RemoveLineCommand(_document, index);
        return _history.ExecuteCommand(command);
    }

    public CommandResult UpdateLine(int index, string content)
    {
        var command = new UpdateLineCommand(_document, index, content);
        return _history.ExecuteCommand(command);
    }

    public CommandResult ExecuteBatch(string operationName, params ICommand[] commands)
    {
        var compositeCommand = new CompositeCommand(_document, operationName, commands);
        return _history.ExecuteCommand(compositeCommand);
    }

    public CommandResult Undo()
    {
        return _history.Undo();
    }

    public CommandResult Redo()
    {
        return _history.Redo();
    }

    public void ClearHistory()
    {
        _history.Clear();
    }

    public string GetDocumentContent()
    {
        return _document.ToString();
    }

    public void DisplayStatus()
    {
        Console.WriteLine($"Document: {LineCount} lines");
        Console.WriteLine($"History: {_history.UndoCount} undo, {_history.RedoCount} redo");
        
        if (_history.UndoCount > 0)
        {
            Console.WriteLine("Recent commands:");
            foreach (var command in _history.GetUndoHistory().Take(5))
            {
                Console.WriteLine($"  - {command}");
            }
        }
    }
}

// Usage example
public class DocumentEditorExample
{
    public void DemonstrateCommandPattern()
    {
        var editor = new DocumentEditor();
        
        Console.WriteLine("=== Document Editor Command Pattern Demo ===");

        // Execute some commands
        Console.WriteLine("\n--- Adding content ---");
        editor.InsertLine(0, "Hello, World!");
        editor.InsertLine(1, "This is line 2");
        editor.InsertLine(2, "This is line 3");
        
        Console.WriteLine("Document content:");
        Console.WriteLine(editor.GetDocumentContent());
        editor.DisplayStatus();

        // Modify content
        Console.WriteLine("\n--- Modifying content ---");
        editor.UpdateLine(1, "This is the modified line 2");
        editor.RemoveLine(2);
        
        Console.WriteLine("Document content:");
        Console.WriteLine(editor.GetDocumentContent());
        editor.DisplayStatus();

        // Demonstrate undo/redo
        Console.WriteLine("\n--- Undo operations ---");
        for (int i = 0; i < 3; i++)
        {
            var result = editor.Undo();
            Console.WriteLine($"Undo {i + 1}: {result.Message}");
        }
        
        Console.WriteLine("Document content after undos:");
        Console.WriteLine(editor.GetDocumentContent());
        editor.DisplayStatus();

        Console.WriteLine("\n--- Redo operations ---");
        for (int i = 0; i < 2; i++)
        {
            var result = editor.Redo();
            Console.WriteLine($"Redo {i + 1}: {result.Message}");
        }
        
        Console.WriteLine("Document content after redos:");
        Console.WriteLine(editor.GetDocumentContent());

        // Demonstrate batch operations
        Console.WriteLine("\n--- Batch operation ---");
        var batchCommands = new ICommand[]
        {
            new InsertLineCommand(editor._document, 0, "BATCH: Line 1"),
            new InsertLineCommand(editor._document, 1, "BATCH: Line 2"),
            new InsertLineCommand(editor._document, 2, "BATCH: Line 3")
        };
        
        editor.ExecuteBatch("Add header lines", batchCommands);
        
        Console.WriteLine("Document after batch operation:");
        Console.WriteLine(editor.GetDocumentContent());
        
        // Undo the entire batch as one operation
        Console.WriteLine("\n--- Undoing batch operation ---");
        editor.Undo();
        
        Console.WriteLine("Document after batch undo:");
        Console.WriteLine(editor.GetDocumentContent());
    }
}
```

#### API Request Command System

#### Implementation 2: HTTP Request Queue with Retry Logic

```csharp
// HTTP request command interface
public interface IHttpCommand : ICommand
{
    HttpRequestMessage Request { get; }
    HttpResponseMessage Response { get; }
    TimeSpan Timeout { get; }
    int MaxRetries { get; }
    int CurrentRetry { get; }
}

// HTTP command result
public class HttpCommandResult : CommandResult
{
    public HttpResponseMessage Response { get; }
    public TimeSpan ExecutionTime { get; }
    public int RetriesUsed { get; }

    public HttpCommandResult(bool isSuccessful, string message, HttpResponseMessage response = null, 
                           TimeSpan executionTime = default, int retriesUsed = 0, object data = null) 
        : base(isSuccessful, message, data)
    {
        Response = response;
        ExecutionTime = executionTime;
        RetriesUsed = retriesUsed;
    }

    public new static HttpCommandResult Success(string message = "HTTP command executed successfully", 
                                               HttpResponseMessage response = null, 
                                               TimeSpan executionTime = default, 
                                               int retriesUsed = 0, 
                                               object data = null)
    {
        return new HttpCommandResult(true, message, response, executionTime, retriesUsed, data);
    }

    public new static HttpCommandResult Failure(string message, HttpResponseMessage response = null, 
                                               TimeSpan executionTime = default, 
                                               int retriesUsed = 0, 
                                               object data = null)
    {
        return new HttpCommandResult(false, message, response, executionTime, retriesUsed, data);
    }
}

// Abstract HTTP command base
public abstract class HttpCommand : IHttpCommand
{
    private static readonly HttpClient _httpClient = new HttpClient();
    
    public string Name { get; protected set; }
    public DateTime ExecutedAt { get; private set; }
    public bool CanUndo { get; protected set; }
    public bool CanRedo { get; protected set; } = true;
    
    public HttpRequestMessage Request { get; protected set; }
    public HttpResponseMessage Response { get; protected set; }
    public TimeSpan Timeout { get; protected set; } = TimeSpan.FromSeconds(30);
    public int MaxRetries { get; protected set; } = 3;
    public int CurrentRetry { get; private set; }

    protected HttpCommand(HttpRequestMessage request, string name, TimeSpan? timeout = null, int maxRetries = 3)
    {
        Request = request ?? throw new ArgumentNullException(nameof(request));
        Name = name ?? throw new ArgumentNullException(nameof(name));
        Timeout = timeout ?? TimeSpan.FromSeconds(30);
        MaxRetries = Math.Max(0, maxRetries);
    }

    public CommandResult Execute()
    {
        var stopwatch = Stopwatch.StartNew();
        CurrentRetry = 0;

        while (CurrentRetry <= MaxRetries)
        {
            try
            {
                var result = ExecuteWithTimeout();
                if (result.IsSuccessful)
                {
                    ExecutedAt = DateTime.UtcNow;
                    stopwatch.Stop();
                    return HttpCommandResult.Success(result.Message, Response, stopwatch.Elapsed, CurrentRetry);
                }

                CurrentRetry++;
                if (CurrentRetry <= MaxRetries)
                {
                    var delay = CalculateRetryDelay(CurrentRetry);
                    Console.WriteLine($"Retry {CurrentRetry}/{MaxRetries} after {delay.TotalMilliseconds}ms delay: {result.Message}");
                    Thread.Sleep(delay);
                }
            }
            catch (Exception ex)
            {
                CurrentRetry++;
                if (CurrentRetry <= MaxRetries)
                {
                    var delay = CalculateRetryDelay(CurrentRetry);
                    Console.WriteLine($"Exception on retry {CurrentRetry}/{MaxRetries}, waiting {delay.TotalMilliseconds}ms: {ex.Message}");
                    Thread.Sleep(delay);
                }
            }
        }

        stopwatch.Stop();
        return HttpCommandResult.Failure($"Command failed after {MaxRetries} retries", Response, stopwatch.Elapsed, CurrentRetry);
    }

    protected abstract CommandResult ExecuteWithTimeout();

    protected virtual TimeSpan CalculateRetryDelay(int retryCount)
    {
        // Exponential backoff: 1s, 2s, 4s, 8s, ...
        return TimeSpan.FromSeconds(Math.Pow(2, retryCount - 1));
    }

    public virtual CommandResult Undo()
    {
        if (!CanUndo)
            return CommandResult.Failure("This HTTP command cannot be undone");

        return UndoCore();
    }

    protected virtual CommandResult UndoCore()
    {
        return CommandResult.Failure("Undo not implemented for this command type");
    }

    public abstract ICommand CreateInverse();
}

// GET request command
public class GetCommand : HttpCommand
{
    private readonly string _url;

    public GetCommand(string url, string name = null, TimeSpan? timeout = null, int maxRetries = 3) 
        : base(new HttpRequestMessage(HttpMethod.Get, url), name ?? $"GET {url}", timeout, maxRetries)
    {
        _url = url;
        CanUndo = false; // GET requests typically don't need undo
    }

    protected override CommandResult ExecuteWithTimeout()
    {
        using var cts = new CancellationTokenSource(Timeout);
        
        var task = _httpClient.SendAsync(Request, cts.Token);
        task.Wait(Timeout);

        if (task.IsCanceled)
            return CommandResult.Failure("Request timed out");

        Response = task.Result;

        if (Response.IsSuccessStatusCode)
        {
            return CommandResult.Success($"GET {_url} completed with status {Response.StatusCode}");
        }
        else
        {
            return CommandResult.Failure($"GET {_url} failed with status {Response.StatusCode}: {Response.ReasonPhrase}");
        }
    }

    public override ICommand CreateInverse()
    {
        // GET requests don't have a natural inverse
        return new NoOpCommand($"No inverse for GET {_url}");
    }
}

// POST request command
public class PostCommand : HttpCommand
{
    private readonly string _url;
    private readonly string _content;
    private readonly string _contentType;

    public PostCommand(string url, string content, string contentType = "application/json", 
                      string name = null, TimeSpan? timeout = null, int maxRetries = 3) 
        : base(CreatePostRequest(url, content, contentType), name ?? $"POST {url}", timeout, maxRetries)
    {
        _url = url;
        _content = content;
        _contentType = contentType;
        CanUndo = true; // POST requests can potentially be undone
    }

    private static HttpRequestMessage CreatePostRequest(string url, string content, string contentType)
    {
        var request = new HttpRequestMessage(HttpMethod.Post, url);
        if (!string.IsNullOrEmpty(content))
        {
            request.Content = new StringContent(content, Encoding.UTF8, contentType);
        }
        return request;
    }

    protected override CommandResult ExecuteWithTimeout()
    {
        using var cts = new CancellationTokenSource(Timeout);
        
        var task = _httpClient.SendAsync(Request, cts.Token);
        task.Wait(Timeout);

        if (task.IsCanceled)
            return CommandResult.Failure("Request timed out");

        Response = task.Result;

        if (Response.IsSuccessStatusCode)
        {
            return CommandResult.Success($"POST {_url} completed with status {Response.StatusCode}");
        }
        else
        {
            return CommandResult.Failure($"POST {_url} failed with status {Response.StatusCode}: {Response.ReasonPhrase}");
        }
    }

    protected override CommandResult UndoCore()
    {
        // For demo purposes, assume POST creates a resource that can be deleted
        // In real scenarios, you'd need to extract the created resource ID from the response
        if (Response?.IsSuccessStatusCode == true)
        {
            // This would typically be a DELETE request to the created resource
            return CommandResult.Success($"Would delete resource created by POST {_url}");
        }

        return CommandResult.Failure("Cannot undo POST - no successful response to reverse");
    }

    public override ICommand CreateInverse()
    {
        // In a real scenario, this would create a DELETE command for the created resource
        return new NoOpCommand($"Delete resource created by POST {_url}");
    }
}

// DELETE request command
public class DeleteCommand : HttpCommand
{
    private readonly string _url;
    private object _backupData;

    public DeleteCommand(string url, string name = null, TimeSpan? timeout = null, int maxRetries = 3) 
        : base(new HttpRequestMessage(HttpMethod.Delete, url), name ?? $"DELETE {url}", timeout, maxRetries)
    {
        _url = url;
        CanUndo = true; // DELETE requests can potentially be undone if we backup data
    }

    protected override CommandResult ExecuteWithTimeout()
    {
        // In a real scenario, we'd fetch the resource before deleting to enable undo
        _backupData = $"Backup data for {_url}"; // Simulated backup

        using var cts = new CancellationTokenSource(Timeout);
        
        var task = _httpClient.SendAsync(Request, cts.Token);
        task.Wait(Timeout);

        if (task.IsCanceled)
            return CommandResult.Failure("Request timed out");

        Response = task.Result;

        if (Response.IsSuccessStatusCode)
        {
            return CommandResult.Success($"DELETE {_url} completed with status {Response.StatusCode}");
        }
        else
        {
            return CommandResult.Failure($"DELETE {_url} failed with status {Response.StatusCode}: {Response.ReasonPhrase}");
        }
    }

    protected override CommandResult UndoCore()
    {
        if (_backupData != null)
        {
            // In a real scenario, this would recreate the deleted resource using backup data
            return CommandResult.Success($"Restored deleted resource: {_backupData}");
        }

        return CommandResult.Failure("Cannot undo DELETE - no backup data available");
    }

    public override ICommand CreateInverse()
    {
        // This would create a POST command to recreate the deleted resource
        return new NoOpCommand($"Recreate deleted resource at {_url}");
    }
}

// No-operation command for cases where no action is needed
public class NoOpCommand : ICommand
{
    public string Name { get; }
    public DateTime ExecutedAt { get; private set; }
    public bool CanUndo => false;
    public bool CanRedo => false;

    public NoOpCommand(string name)
    {
        Name = name ?? "No Operation";
    }

    public CommandResult Execute()
    {
        ExecutedAt = DateTime.UtcNow;
        return CommandResult.Success($"No-op: {Name}");
    }

    public CommandResult Undo()
    {
        return CommandResult.Success($"No-op undo: {Name}");
    }

    public ICommand CreateInverse()
    {
        return new NoOpCommand($"Inverse of {Name}");
    }
}

// HTTP command queue manager
public class HttpCommandQueue
{
    private readonly Queue<IHttpCommand> _pendingCommands;
    private readonly List<IHttpCommand> _executedCommands;
    private readonly CommandHistory _history;
    private readonly SemaphoreSlim _executionSemaphore;
    private readonly int _maxConcurrency;

    public int PendingCount => _pendingCommands.Count;
    public int ExecutedCount => _executedCommands.Count;
    public bool IsProcessing { get; private set; }

    public HttpCommandQueue(int maxConcurrency = 3)
    {
        _maxConcurrency = Math.Max(1, maxConcurrency);
        _pendingCommands = new Queue<IHttpCommand>();
        _executedCommands = new List<IHttpCommand>();
        _history = new CommandHistory();
        _executionSemaphore = new SemaphoreSlim(_maxConcurrency, _maxConcurrency);
    }

    public void EnqueueCommand(IHttpCommand command)
    {
        if (command == null) throw new ArgumentNullException(nameof(command));
        
        _pendingCommands.Enqueue(command);
        Console.WriteLine($"Enqueued: {command.Name} (Queue size: {_pendingCommands.Count})");
    }

    public async Task<List<CommandResult>> ProcessQueueAsync()
    {
        if (IsProcessing)
            throw new InvalidOperationException("Queue is already being processed");

        IsProcessing = true;
        var results = new List<CommandResult>();

        try
        {
            var tasks = new List<Task<CommandResult>>();

            while (_pendingCommands.Count > 0)
            {
                // Start up to maxConcurrency commands
                while (tasks.Count < _maxConcurrency && _pendingCommands.Count > 0)
                {
                    var command = _pendingCommands.Dequeue();
                    var task = ProcessCommandAsync(command);
                    tasks.Add(task);
                }

                // Wait for at least one to complete
                var completedTask = await Task.WhenAny(tasks);
                tasks.Remove(completedTask);
                
                var result = await completedTask;
                results.Add(result);
            }

            // Wait for remaining tasks to complete
            while (tasks.Count > 0)
            {
                var completedTask = await Task.WhenAny(tasks);
                tasks.Remove(completedTask);
                
                var result = await completedTask;
                results.Add(result);
            }
        }
        finally
        {
            IsProcessing = false;
        }

        return results;
    }

    private async Task<CommandResult> ProcessCommandAsync(IHttpCommand command)
    {
        await _executionSemaphore.WaitAsync();
        
        try
        {
            Console.WriteLine($"Executing: {command.Name}");
            var result = await Task.Run(() => _history.ExecuteCommand(command));
            
            _executedCommands.Add(command);
            
            Console.WriteLine($"Completed: {command.Name} - {(result.IsSuccessful ? "Success" : "Failed")}");
            if (result is HttpCommandResult httpResult && httpResult.RetriesUsed > 0)
            {
                Console.WriteLine($"  Retries used: {httpResult.RetriesUsed}");
            }
            
            return result;
        }
        finally
        {
            _executionSemaphore.Release();
        }
    }

    public CommandResult UndoLastCommand()
    {
        return _history.Undo();
    }

    public CommandResult RedoLastCommand()
    {
        return _history.Redo();
    }

    public void ClearQueue()
    {
        _pendingCommands.Clear();
        Console.WriteLine("Queue cleared");
    }

    public void DisplayStatus()
    {
        Console.WriteLine($"Queue Status: {PendingCount} pending, {ExecutedCount} executed");
        Console.WriteLine($"History: {_history.UndoCount} can undo, {_history.RedoCount} can redo");
        Console.WriteLine($"Processing: {(IsProcessing ? "Active" : "Idle")}");
    }
}

// Usage example
public class HttpCommandExample
{
    public async Task DemonstrateHttpCommands()
    {
        var queue = new HttpCommandQueue(maxConcurrency: 2);
        
        Console.WriteLine("=== HTTP Command Queue Demo ===");

        // Enqueue various HTTP commands
        queue.EnqueueCommand(new GetCommand("https://api.github.com/users/octocat", timeout: TimeSpan.FromSeconds(10)));
        queue.EnqueueCommand(new GetCommand("https://httpbin.org/delay/2", timeout: TimeSpan.FromSeconds(5)));
        queue.EnqueueCommand(new PostCommand("https://httpbin.org/post", "{\"test\": \"data\"}", "application/json"));
        queue.EnqueueCommand(new GetCommand("https://httpbin.org/status/404")); // This will fail
        queue.EnqueueCommand(new DeleteCommand("https://httpbin.org/delete"));

        queue.DisplayStatus();

        Console.WriteLine("\n--- Processing Queue ---");
        var results = await queue.ProcessQueueAsync();

        Console.WriteLine("\n--- Results Summary ---");
        for (int i = 0; i < results.Count; i++)
        {
            var result = results[i];
            Console.WriteLine($"{i + 1}. {(result.IsSuccessful ? "✅" : "❌")} {result.Message}");
            
            if (result is HttpCommandResult httpResult)
            {
                Console.WriteLine($"   Execution time: {httpResult.ExecutionTime.TotalMilliseconds:F0}ms");
                if (httpResult.RetriesUsed > 0)
                {
                    Console.WriteLine($"   Retries: {httpResult.RetriesUsed}");
                }
            }
        }

        queue.DisplayStatus();

        // Demonstrate undo
        Console.WriteLine("\n--- Undo Operations ---");
        for (int i = 0; i < 3; i++)
        {
            var undoResult = queue.UndoLastCommand();
            Console.WriteLine($"Undo {i + 1}: {undoResult.Message}");
        }
    }
}
```

### Practical Implementation (8 minutes)

#### Macro Recording and Playback System

#### Implementation 3: UI Action Recorder

```csharp
// UI action command interface
public interface IUICommand : ICommand
{
    string Target { get; }
    Dictionary<string, object> Parameters { get; }
    TimeSpan Delay { get; }
}

// Base UI command
public abstract class UICommand : IUICommand
{
    public string Name { get; protected set; }
    public DateTime ExecutedAt { get; protected set; }
    public bool CanUndo { get; protected set; } = true;
    public bool CanRedo { get; protected set; } = true;
    
    public string Target { get; protected set; }
    public Dictionary<string, object> Parameters { get; protected set; }
    public TimeSpan Delay { get; protected set; }

    protected UICommand(string name, string target, TimeSpan delay = default)
    {
        Name = name ?? throw new ArgumentNullException(nameof(name));
        Target = target ?? throw new ArgumentNullException(nameof(target));
        Delay = delay;
        Parameters = new Dictionary<string, object>();
    }

    public CommandResult Execute()
    {
        if (Delay > TimeSpan.Zero)
        {
            Thread.Sleep(Delay);
        }

        ExecutedAt = DateTime.UtcNow;
        return ExecuteCore();
    }

    protected abstract CommandResult ExecuteCore();
    public abstract CommandResult Undo();
    public abstract ICommand CreateInverse();
}

// Click command
public class ClickCommand : UICommand
{
    public int X { get; }
    public int Y { get; }

    public ClickCommand(string target, int x, int y, TimeSpan delay = default) 
        : base($"Click {target}", target, delay)
    {
        X = x;
        Y = y;
        Parameters["x"] = x;
        Parameters["y"] = y;
        CanUndo = false; // Clicks generally can't be undone
    }

    protected override CommandResult ExecuteCore()
    {
        // Simulate click action
        Console.WriteLine($"Clicking {Target} at ({X}, {Y})");
        return CommandResult.Success($"Clicked {Target} at ({X}, {Y})");
    }

    public override CommandResult Undo()
    {
        return CommandResult.Failure("Click actions cannot be undone");
    }

    public override ICommand CreateInverse()
    {
        return new NoOpCommand($"No inverse for click on {Target}");
    }
}

// Type text command
public class TypeTextCommand : UICommand
{
    public string Text { get; }
    private string _previousText;

    public TypeTextCommand(string target, string text, TimeSpan delay = default) 
        : base($"Type in {target}", target, delay)
    {
        Text = text ?? string.Empty;
        Parameters["text"] = text;
    }

    protected override CommandResult ExecuteCore()
    {
        // In a real implementation, this would get the current text first
        _previousText = GetCurrentText(Target);
        
        // Simulate typing
        Console.WriteLine($"Typing '{Text}' in {Target}");
        SetText(Target, Text);
        
        return CommandResult.Success($"Typed '{Text}' in {Target}");
    }

    public override CommandResult Undo()
    {
        SetText(Target, _previousText ?? string.Empty);
        return CommandResult.Success($"Restored previous text in {Target}: '{_previousText}'");
    }

    public override ICommand CreateInverse()
    {
        return new TypeTextCommand(Target, _previousText ?? string.Empty);
    }

    private string GetCurrentText(string target)
    {
        // Simulate getting current text from UI element
        return $"PreviousText_{target}";
    }

    private void SetText(string target, string text)
    {
        // Simulate setting text in UI element
        Console.WriteLine($"Setting text in {target}: '{text}'");
    }
}

// Select command
public class SelectCommand : UICommand
{
    public string Value { get; }
    private string _previousValue;

    public SelectCommand(string target, string value, TimeSpan delay = default) 
        : base($"Select {value} in {target}", target, delay)
    {
        Value = value ?? string.Empty;
        Parameters["value"] = value;
    }

    protected override CommandResult ExecuteCore()
    {
        _previousValue = GetCurrentSelection(Target);
        
        Console.WriteLine($"Selecting '{Value}' in {Target}");
        SetSelection(Target, Value);
        
        return CommandResult.Success($"Selected '{Value}' in {Target}");
    }

    public override CommandResult Undo()
    {
        SetSelection(Target, _previousValue ?? string.Empty);
        return CommandResult.Success($"Restored previous selection in {Target}: '{_previousValue}'");
    }

    public override ICommand CreateInverse()
    {
        return new SelectCommand(Target, _previousValue ?? string.Empty);
    }

    private string GetCurrentSelection(string target)
    {
        return $"PreviousSelection_{target}";
    }

    private void SetSelection(string target, string value)
    {
        Console.WriteLine($"Setting selection in {target}: '{value}'");
    }
}

// Wait/delay command
public class WaitCommand : UICommand
{
    public TimeSpan WaitTime { get; }

    public WaitCommand(TimeSpan waitTime) 
        : base($"Wait {waitTime.TotalMilliseconds}ms", "System", waitTime)
    {
        WaitTime = waitTime;
        Parameters["waitTime"] = waitTime;
        CanUndo = false;
    }

    protected override CommandResult ExecuteCore()
    {
        Console.WriteLine($"Waiting for {WaitTime.TotalMilliseconds}ms");
        return CommandResult.Success($"Waited {WaitTime.TotalMilliseconds}ms");
    }

    public override CommandResult Undo()
    {
        return CommandResult.Success("Wait command completed (no undo needed)");
    }

    public override ICommand CreateInverse()
    {
        return new NoOpCommand($"No inverse for wait {WaitTime.TotalMilliseconds}ms");
    }
}

// Macro class for recording and playing back command sequences
public class Macro
{
    public string Name { get; }
    public DateTime CreatedAt { get; }
    public DateTime? LastExecutedAt { get; private set; }
    public int ExecutionCount { get; private set; }
    
    private readonly List<IUICommand> _commands;
    private readonly CommandHistory _history;

    public IReadOnlyList<IUICommand> Commands => _commands.AsReadOnly();
    public int CommandCount => _commands.Count;
    public TimeSpan EstimatedDuration => TimeSpan.FromMilliseconds(_commands.Sum(c => c.Delay.TotalMilliseconds));

    public Macro(string name)
    {
        Name = name ?? throw new ArgumentNullException(nameof(name));
        CreatedAt = DateTime.UtcNow;
        _commands = new List<IUICommand>();
        _history = new CommandHistory();
    }

    public void AddCommand(IUICommand command)
    {
        if (command == null) throw new ArgumentNullException(nameof(command));
        
        _commands.Add(command);
        Console.WriteLine($"Macro '{Name}': Added command '{command.Name}'");
    }

    public void RemoveCommand(int index)
    {
        if (index < 0 || index >= _commands.Count)
            throw new ArgumentOutOfRangeException(nameof(index));

        var command = _commands[index];
        _commands.RemoveAt(index);
        Console.WriteLine($"Macro '{Name}': Removed command '{command.Name}' at index {index}");
    }

    public async Task<List<CommandResult>> ExecuteAsync(bool allowUndo = true)
    {
        var results = new List<CommandResult>();
        var stopwatch = Stopwatch.StartNew();

        Console.WriteLine($"Executing macro '{Name}' ({CommandCount} commands, estimated duration: {EstimatedDuration.TotalSeconds:F1}s)");

        for (int i = 0; i < _commands.Count; i++)
        {
            var command = _commands[i];
            Console.WriteLine($"  Step {i + 1}/{CommandCount}: {command.Name}");

            CommandResult result;
            if (allowUndo)
            {
                result = _history.ExecuteCommand(command);
            }
            else
            {
                result = command.Execute();
            }

            results.Add(result);

            if (!result.IsSuccessful)
            {
                Console.WriteLine($"  ❌ Failed: {result.Message}");
                break;
            }
            else
            {
                Console.WriteLine($"  ✅ Success: {result.Message}");
            }

            // Small delay between commands for demonstration
            await Task.Delay(100);
        }

        stopwatch.Stop();
        ExecutionCount++;
        LastExecutedAt = DateTime.UtcNow;

        var successCount = results.Count(r => r.IsSuccessful);
        Console.WriteLine($"Macro '{Name}' completed: {successCount}/{results.Count} commands successful in {stopwatch.ElapsedMilliseconds}ms");

        return results;
    }

    public CommandResult UndoLastExecution()
    {
        return _history.Undo();
    }

    public CommandResult RedoLastUndo()
    {
        return _history.Redo();
    }

    public Macro Clone(string newName)
    {
        var clone = new Macro(newName);
        foreach (var command in _commands)
        {
            clone.AddCommand(command);
        }
        return clone;
    }

    public void Clear()
    {
        _commands.Clear();
        _history.Clear();
        Console.WriteLine($"Macro '{Name}' cleared");
    }

    public override string ToString()
    {
        return $"Macro '{Name}': {CommandCount} commands, executed {ExecutionCount} times";
    }
}

// Macro recorder for capturing user actions
public class MacroRecorder
{
    private readonly List<Macro> _macros;
    private Macro _currentMacro;
    private bool _isRecording;

    public IReadOnlyList<Macro> Macros => _macros.AsReadOnly();
    public bool IsRecording => _isRecording;
    public string CurrentMacroName => _currentMacro?.Name;

    public MacroRecorder()
    {
        _macros = new List<Macro>();
    }

    public void StartRecording(string macroName)
    {
        if (_isRecording)
            throw new InvalidOperationException("Already recording a macro");

        if (string.IsNullOrWhiteSpace(macroName))
            throw new ArgumentException("Macro name cannot be empty", nameof(macroName));

        _currentMacro = new Macro(macroName);
        _isRecording = true;
        
        Console.WriteLine($"Started recording macro '{macroName}'");
    }

    public Macro StopRecording()
    {
        if (!_isRecording)
            throw new InvalidOperationException("Not currently recording");

        var macro = _currentMacro;
        _macros.Add(macro);
        
        _currentMacro = null;
        _isRecording = false;

        Console.WriteLine($"Stopped recording macro '{macro.Name}' ({macro.CommandCount} commands)");
        return macro;
    }

    public void RecordClick(string target, int x, int y, TimeSpan delay = default)
    {
        if (!_isRecording) return;
        
        var command = new ClickCommand(target, x, y, delay);
        _currentMacro.AddCommand(command);
    }

    public void RecordTypeText(string target, string text, TimeSpan delay = default)
    {
        if (!_isRecording) return;
        
        var command = new TypeTextCommand(target, text, delay);
        _currentMacro.AddCommand(command);
    }

    public void RecordSelect(string target, string value, TimeSpan delay = default)
    {
        if (!_isRecording) return;
        
        var command = new SelectCommand(target, value, delay);
        _currentMacro.AddCommand(command);
    }

    public void RecordWait(TimeSpan waitTime)
    {
        if (!_isRecording) return;
        
        var command = new WaitCommand(waitTime);
        _currentMacro.AddCommand(command);
    }

    public Macro GetMacro(string name)
    {
        return _macros.FirstOrDefault(m => m.Name.Equals(name, StringComparison.OrdinalIgnoreCase));
    }

    public void RemoveMacro(string name)
    {
        var macro = GetMacro(name);
        if (macro != null)
        {
            _macros.Remove(macro);
            Console.WriteLine($"Removed macro '{name}'");
        }
    }

    public void ListMacros()
    {
        Console.WriteLine($"Available macros ({_macros.Count}):");
        foreach (var macro in _macros)
        {
            Console.WriteLine($"  - {macro}");
            Console.WriteLine($"    Created: {macro.CreatedAt:yyyy-MM-dd HH:mm:ss}");
            if (macro.LastExecutedAt.HasValue)
            {
                Console.WriteLine($"    Last executed: {macro.LastExecutedAt:yyyy-MM-dd HH:mm:ss}");
            }
            Console.WriteLine($"    Estimated duration: {macro.EstimatedDuration.TotalSeconds:F1}s");
        }
    }
}

// Usage example
public class MacroRecorderExample
{
    public async Task DemonstrateMacroRecording()
    {
        var recorder = new MacroRecorder();
        
        Console.WriteLine("=== Macro Recorder Demo ===");

        // Record a login macro
        Console.WriteLine("\n--- Recording Login Macro ---");
        recorder.StartRecording("Login Sequence");
        
        recorder.RecordClick("username_field", 100, 200);
        recorder.RecordTypeText("username_field", "john.doe@example.com");
        recorder.RecordWait(TimeSpan.FromMilliseconds(500));
        
        recorder.RecordClick("password_field", 100, 250);
        recorder.RecordTypeText("password_field", "password123");
        recorder.RecordWait(TimeSpan.FromMilliseconds(500));
        
        recorder.RecordClick("login_button", 200, 300);
        recorder.RecordWait(TimeSpan.FromSeconds(2));
        
        var loginMacro = recorder.StopRecording();

        // Record a form filling macro
        Console.WriteLine("\n--- Recording Form Fill Macro ---");
        recorder.StartRecording("Fill User Form");
        
        recorder.RecordClick("first_name", 150, 100);
        recorder.RecordTypeText("first_name", "John");
        
        recorder.RecordClick("last_name", 150, 150);
        recorder.RecordTypeText("last_name", "Doe");
        
        recorder.RecordClick("country_dropdown", 150, 200);
        recorder.RecordSelect("country_dropdown", "United States");
        
        recorder.RecordClick("save_button", 200, 350);
        
        var formMacro = recorder.StopRecording();

        // List recorded macros
        Console.WriteLine("\n--- Recorded Macros ---");
        recorder.ListMacros();

        // Execute macros
        Console.WriteLine("\n--- Executing Login Macro ---");
        await loginMacro.ExecuteAsync();

        Console.WriteLine("\n--- Executing Form Fill Macro ---");
        var results = await formMacro.ExecuteAsync();

        // Demonstrate undo
        Console.WriteLine("\n--- Undoing Form Fill ---");
        for (int i = 0; i < 3; i++)
        {
            var undoResult = formMacro.UndoLastExecution();
            Console.WriteLine($"Undo {i + 1}: {undoResult.Message}");
        }

        // Create a composite macro
        Console.WriteLine("\n--- Creating Composite Macro ---");
        var compositeMacro = new Macro("Complete Registration");
        
        // Add all commands from both macros
        foreach (var command in loginMacro.Commands)
        {
            compositeMacro.AddCommand(command);
        }
        
        compositeMacro.AddCommand(new WaitCommand(TimeSpan.FromSeconds(1)));
        
        foreach (var command in formMacro.Commands)
        {
            compositeMacro.AddCommand(command);
        }

        Console.WriteLine($"Created composite macro with {compositeMacro.CommandCount} commands");
        
        Console.WriteLine("\n--- Executing Composite Macro ---");
        await compositeMacro.ExecuteAsync();
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Command Pattern Benefits**:

- ✅ **Decoupling**: Separates invoker from receiver, enabling flexible command handling
- ✅ **Undo/Redo**: Natural support for reversible operations and history management
- ✅ **Macro recording**: Commands can be composed into sequences and replayed
- ✅ **Queuing and scheduling**: Commands can be stored, prioritized, and executed later

**Command Pattern Applications**:

- **Text editors** - Undo/redo operations, macro recording, batch edits
- **GUI applications** - Menu actions, toolbar commands, keyboard shortcuts
- **Database systems** - Transaction management, rollback capabilities
- **API systems** - Request queuing, batch processing, retry mechanisms

**Implementation Considerations**:

- **Memory usage** - Command history can consume significant memory
- **Undo complexity** - Not all operations can be easily reversed
- **Performance impact** - Command wrapping adds overhead
- **State dependencies** - Commands may depend on external state changes

**Best Practices**:

- Implement proper command validation before execution
- Use composite commands for batch operations
- Consider command serialization for persistence
- Implement proper cleanup for command history limits

### Next Steps

**Immediate Actions**:

- Add command persistence and serialization capabilities
- Implement command scheduling and prioritization
- Continue to **Template Method Pattern**: Algorithm structure with customizable steps

**Advanced Topics**:

- Command pattern in distributed systems
- Event sourcing with command patterns
- Command pattern with dependency injection

## 🔗 Related Topics

**Prerequisites**: Decorator Pattern (Part 6), Event handling, Action encapsulation concepts  
**Builds Upon**: Strategy Pattern, Observer Pattern, State management  
**Enables**: Template Method Pattern, Chain of Responsibility Pattern, Event sourcing  
**Related**: Memento pattern, State pattern, Interpreter pattern
