# 12B_Design-Patterns-Part7B-Command-Pattern-Document-Editor

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Command Pattern Fundamentals (Part A), Document model concepts  
**Estimated Time**: Part B of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement concrete document editing commands with undo/redo functionality
- Design a robust command history system for state management
- Build insert, delete, and update operations as reversible commands
- Create a practical text editor with full undo/redo capabilities

## 📋 Content Sections (27-Minute Structure)

### Document Command Foundation (5 minutes)

Building on Part A's interfaces, we now implement the concrete document editor commands:

```csharp
// Abstract base command for document operations
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
            return CommandResult.Failure("Command cannot be undone");

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
```

### Core Document Commands (15 minutes)

#### Insert Line Command

```csharp
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
        if (LineIndex < 0 || LineIndex > Document.LineCount)
            return CommandResult.Failure($"Invalid line index: {LineIndex}");

        Document.InsertLine(LineIndex, Content);
        return CommandResult.Success($"Inserted line at index {LineIndex}");
    }

    protected override CommandResult UndoCore()
    {
        if (LineIndex >= Document.LineCount)
            return CommandResult.Failure("Cannot undo: line no longer exists");

        Document.RemoveLine(LineIndex);
        return CommandResult.Success($"Removed line at index {LineIndex}");
    }

    public override ICommand CreateInverse()
    {
        return new DeleteLineCommand(Document, LineIndex);
    }
}
```

#### Delete Line Command

```csharp
public class DeleteLineCommand : DocumentCommand
{
    public int LineIndex { get; }
    private string _deletedContent;

    public DeleteLineCommand(Document document, int lineIndex) 
        : base(document, $"Delete line at {lineIndex}")
    {
        LineIndex = lineIndex;
    }

    protected override CommandResult ExecuteCore()
    {
        if (LineIndex < 0 || LineIndex >= Document.LineCount)
            return CommandResult.Failure($"Invalid line index: {LineIndex}");

        _deletedContent = Document.GetLine(LineIndex);
        Document.RemoveLine(LineIndex);
        return CommandResult.Success($"Deleted line at index {LineIndex}");
    }

    protected override CommandResult UndoCore()
    {
        if (_deletedContent == null)
            return CommandResult.Failure("Cannot undo: no content to restore");

        Document.InsertLine(LineIndex, _deletedContent);
        return CommandResult.Success($"Restored line at index {LineIndex}");
    }

    public override ICommand CreateInverse()
    {
        return new InsertLineCommand(Document, LineIndex, _deletedContent);
    }
}
```

#### Update Line Command

```csharp
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
        if (LineIndex < 0 || LineIndex >= Document.LineCount)
            return CommandResult.Failure($"Invalid line index: {LineIndex}");

        _originalContent = Document.GetLine(LineIndex);
        Document.UpdateLine(LineIndex, NewContent);
        return CommandResult.Success($"Updated line at index {LineIndex}");
    }

    protected override CommandResult UndoCore()
    {
        if (_originalContent == null)
            return CommandResult.Failure("Cannot undo: no original content");

        Document.UpdateLine(LineIndex, _originalContent);
        return CommandResult.Success($"Restored original content at index {LineIndex}");
    }

    public override ICommand CreateInverse()
    {
        return new UpdateLineCommand(Document, LineIndex, _originalContent);
    }
}
```

### Command History Manager (5 minutes)

```csharp
public class CommandHistory
{
    private readonly List<ICommand> _history;
    private int _currentPosition;
    private const int MAX_HISTORY_SIZE = 100;

    public bool CanUndo => _currentPosition > 0;
    public bool CanRedo => _currentPosition < _history.Count;
    public int HistoryCount => _history.Count;

    public CommandHistory()
    {
        _history = new List<ICommand>();
        _currentPosition = 0;
    }

    public CommandResult ExecuteCommand(ICommand command)
    {
        var result = command.Execute();
        if (result.IsSuccessful)
        {
            // Remove any commands after current position (when redoing then executing new command)
            if (_currentPosition < _history.Count)
            {
                _history.RemoveRange(_currentPosition, _history.Count - _currentPosition);
            }

            _history.Add(command);
            _currentPosition = _history.Count;

            // Keep history size manageable
            if (_history.Count > MAX_HISTORY_SIZE)
            {
                _history.RemoveAt(0);
                _currentPosition--;
            }
        }
        return result;
    }

    public CommandResult Undo()
    {
        if (!CanUndo)
            return CommandResult.Failure("Nothing to undo");

        var command = _history[_currentPosition - 1];
        var result = command.Undo();
        if (result.IsSuccessful)
        {
            _currentPosition--;
        }
        return result;
    }

    public CommandResult Redo()
    {
        if (!CanRedo)
            return CommandResult.Failure("Nothing to redo");

        var command = _history[_currentPosition];
        var result = command.Execute();
        if (result.IsSuccessful)
        {
            _currentPosition++;
        }
        return result;
    }

    public void Clear()
    {
        _history.Clear();
        _currentPosition = 0;
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Mastered in Part B**:

- Document command implementation with reversible operations
- Command history management with undo/redo functionality
- Insert, Delete, and Update commands with proper state preservation
- Error handling and validation in command execution

**Next Steps**:

- **Part C**: API Request Command System with retry logic and queuing
- **Part D**: Macro Recording and UI Action Recorder implementation

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Command Pattern Fundamentals](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md)**
- [Object-oriented design principles](../../01_software-design-principles/)

**Builds Upon**:

- Interface design patterns
- State management concepts
- Error handling strategies

**Enables**:

- **[Part C - API Command System](12C_Design-Patterns-Part7C-Command-Pattern-API-System.md)**
- [Text editor applications](../../../applications/text-editors/)
- [Version control systems](../../../applications/version-control/)

**Cross-References**:

- [Memento Pattern](../behavioral-patterns/) for state snapshots
- [Observer Pattern](09_Design-Patterns-Part4-Observer-Pattern.md) for command notifications