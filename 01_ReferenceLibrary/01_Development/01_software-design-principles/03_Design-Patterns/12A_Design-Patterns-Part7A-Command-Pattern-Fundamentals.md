# 12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Decorator Pattern (Part 6), Event handling concepts  
**Estimated Time**: Part A of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Understand the Command Pattern for action encapsulation and execution control
- Recognize the tight coupling problem that Command Pattern solves
- Master the core components: Command, Invoker, Receiver, and CommandHistory
- Design foundational command interfaces for undo/redo functionality

## 📋 Content Sections (27-Minute Structure)

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

### Core Concepts (15 minutes)

**Real-World Applications**:

- **Text Editors** - Undo/redo operations, macro recording
- **Database Systems** - Transaction management, rollback capabilities
- **GUI Applications** - Menu actions, toolbar commands, keyboard shortcuts
- **API Operations** - Request queuing, batch processing, retry mechanisms

#### Command Interface Foundation

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
```

#### Document Model Foundation

```csharp
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
```

### Pattern Components Deep Dive (5 minutes)

#### Key Components

1. **Command Interface** - Defines execution and undo contracts
2. **Concrete Commands** - Implement specific operations
3. **Invoker** - Triggers command execution without knowing details
4. **Receiver** - Performs the actual work
5. **Command History** - Manages undo/redo stack

#### Benefits Achieved

- **Decoupling** - Invoker doesn't know receiver implementation
- **Undo/Redo** - Commands can reverse their operations
- **Macro Recording** - Commands can be queued and replayed
- **Logging** - All operations are trackable objects
- **Queuing** - Commands can be scheduled or batched

### Key Takeaways & Next Steps (2 minutes)

**Mastered in Part A**:

- Command Pattern solves tight coupling between invokers and receivers
- Command interface enables undo/redo through reversible operations
- Document model provides foundation for text editing operations
- Pattern components work together for flexible action management

**Next Steps**:

- **Part B**: Document Editor Implementation with full undo/redo system
- **Part C**: API Request Command System with retry logic  
- **Part D**: Macro Recording and UI Action Recorder implementation

## 🔗 Related Topics

**Prerequisites**:

- [Decorator Pattern (Part 6)](11_Design-Patterns-Part6-Decorator-Pattern.md)
- [Strategy Pattern](10_Design-Patterns-Part5-Strategy-Pattern.md)

**Builds Upon**:

- Object-oriented design principles
- Interface segregation concepts
- State management patterns

**Enables**:

- **[Part B - Document Editor](12B_Design-Patterns-Part7B-Command-Pattern-Document-Editor.md)**
- [Transaction management patterns](../../database-patterns/)
- [Event sourcing architectures](../../advanced-patterns/)

**Cross-References**:

- [Memento Pattern](../behavioral-patterns/) for state snapshots
- [Observer Pattern](09_Design-Patterns-Part4-Observer-Pattern.md) for command notifications
