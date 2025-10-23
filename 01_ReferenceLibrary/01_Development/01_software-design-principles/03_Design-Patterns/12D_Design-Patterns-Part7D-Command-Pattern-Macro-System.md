# 12D_Design-Patterns-Part7D-Command-Pattern-Macro-System

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Command Pattern API System (Part C), UI event handling  
**Estimated Time**: Part D of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement macro recording and playback systems using Command Pattern
- Design UI action recorders for automated testing and user assistance
- Build command composition and batch execution capabilities
- Create sophisticated undo/redo systems for complex operations

## 📋 Content Sections (27-Minute Structure)

### Macro Recording Foundation (5 minutes)

```csharp
// Macro command that contains multiple commands
public class MacroCommand : ICommand
{
    public string Name { get; }
    public DateTime ExecutedAt { get; private set; }
    public bool CanUndo => _commands.All(c => c.CanUndo);
    public bool CanRedo => true;

    private readonly List<ICommand> _commands;
    private readonly List<ICommand> _executedCommands;

    public MacroCommand(string name, IEnumerable<ICommand> commands)
    {
        Name = name ?? "Macro Command";
        _commands = new List<ICommand>(commands ?? Enumerable.Empty<ICommand>());
        _executedCommands = new List<ICommand>();
    }

    public CommandResult Execute()
    {
        _executedCommands.Clear();
        var results = new List<CommandResult>();

        foreach (var command in _commands)
        {
            var result = command.Execute();
            results.Add(result);
            
            if (result.IsSuccessful)
            {
                _executedCommands.Add(command);
            }
            else
            {
                // Rollback previously executed commands
                UndoExecutedCommands();
                return CommandResult.Failure($"Macro failed at command '{command.Name}': {result.Message}");
            }
        }

        ExecutedAt = DateTime.UtcNow;
        return CommandResult.Success($"Macro '{Name}' executed successfully with {_executedCommands.Count} commands");
    }

    public CommandResult Undo()
    {
        if (!CanUndo)
            return CommandResult.Failure("Macro cannot be undone");

        return UndoExecutedCommands();
    }

    private CommandResult UndoExecutedCommands()
    {
        var failures = new List<string>();

        // Undo in reverse order
        for (int i = _executedCommands.Count - 1; i >= 0; i--)
        {
            var result = _executedCommands[i].Undo();
            if (!result.IsSuccessful)
            {
                failures.Add($"Failed to undo '{_executedCommands[i].Name}': {result.Message}");
            }
        }

        if (failures.Any())
        {
            return CommandResult.Failure($"Macro undo partially failed: {string.Join(", ", failures)}");
        }

        _executedCommands.Clear();
        return CommandResult.Success($"Macro '{Name}' undone successfully");
    }

    public ICommand CreateInverse()
    {
        var inverseCommands = _executedCommands
            .Select(c => c.CreateInverse())
            .Where(c => c != null)
            .Reverse()
            .ToList();

        return new MacroCommand($"Inverse of {Name}", inverseCommands);
    }
}
```

### UI Action Recorder (15 minutes)

#### Action Recorder System

```csharp
public class UIActionRecorder
{
    private readonly List<ICommand> _recordedActions;
    private readonly CommandHistory _history;
    private bool _isRecording;

    public bool IsRecording => _isRecording;
    public int RecordedActionCount => _recordedActions.Count;

    public UIActionRecorder()
    {
        _recordedActions = new List<ICommand>();
        _history = new CommandHistory();
    }

    public void StartRecording()
    {
        _isRecording = true;
        _recordedActions.Clear();
    }

    public MacroCommand StopRecording(string macroName = null)
    {
        _isRecording = false;
        var name = macroName ?? $"Recorded Macro {DateTime.Now:HH:mm:ss}";
        return new MacroCommand(name, _recordedActions.ToList());
    }

    public CommandResult RecordAndExecute(ICommand command)
    {
        if (_isRecording)
        {
            _recordedActions.Add(command);
        }

        return _history.ExecuteCommand(command);
    }

    public CommandResult Undo() => _history.Undo();
    public CommandResult Redo() => _history.Redo();

    public void SaveMacro(MacroCommand macro, string filePath)
    {
        // Serialize macro to file for later playback
        var macroData = new
        {
            Name = macro.Name,
            CreatedAt = DateTime.UtcNow,
            Commands = _recordedActions.Select(c => new
            {
                Type = c.GetType().Name,
                Name = c.Name,
                Parameters = SerializeCommandParameters(c)
            })
        };

        var json = JsonSerializer.Serialize(macroData, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(filePath, json);
    }

    private object SerializeCommandParameters(ICommand command)
    {
        // Simplified serialization - in practice, you'd need more sophisticated logic
        return command switch
        {
            InsertLineCommand insert => new { insert.LineIndex, insert.Content },
            DeleteLineCommand delete => new { delete.LineIndex },
            UpdateLineCommand update => new { update.LineIndex, update.NewContent },
            _ => new { }
        };
    }
}
```

#### UI Command Implementations

```csharp
// Button click command
public class ButtonClickCommand : ICommand
{
    public string Name { get; }
    public DateTime ExecutedAt { get; private set; }
    public bool CanUndo { get; }
    public bool CanRedo => true;

    private readonly string _buttonId;
    private readonly Action _clickAction;
    private readonly Action _undoAction;

    public ButtonClickCommand(string buttonId, Action clickAction, Action undoAction = null)
    {
        _buttonId = buttonId;
        _clickAction = clickAction ?? throw new ArgumentNullException(nameof(clickAction));
        _undoAction = undoAction;
        Name = $"Click {buttonId}";
        CanUndo = undoAction != null;
    }

    public CommandResult Execute()
    {
        try
        {
            _clickAction();
            ExecutedAt = DateTime.UtcNow;
            return CommandResult.Success($"Button '{_buttonId}' clicked");
        }
        catch (Exception ex)
        {
            return CommandResult.Failure($"Button click failed: {ex.Message}");
        }
    }

    public CommandResult Undo()
    {
        if (!CanUndo)
            return CommandResult.Failure("Button click cannot be undone");

        try
        {
            _undoAction();
            return CommandResult.Success($"Button '{_buttonId}' click undone");
        }
        catch (Exception ex)
        {
            return CommandResult.Failure($"Button click undo failed: {ex.Message}");
        }
    }

    public ICommand CreateInverse()
    {
        return CanUndo ? new ButtonClickCommand($"Undo {_buttonId}", _undoAction, _clickAction) : null;
    }
}

// Text input command
public class TextInputCommand : ICommand
{
    public string Name { get; }
    public DateTime ExecutedAt { get; private set; }
    public bool CanUndo => true;
    public bool CanRedo => true;

    private readonly string _fieldId;
    private readonly string _newValue;
    private readonly Action<string> _setValue;
    private readonly Func<string> _getValue;
    private string _originalValue;

    public TextInputCommand(string fieldId, string newValue, Action<string> setValue, Func<string> getValue)
    {
        _fieldId = fieldId;
        _newValue = newValue;
        _setValue = setValue ?? throw new ArgumentNullException(nameof(setValue));
        _getValue = getValue ?? throw new ArgumentNullException(nameof(getValue));
        Name = $"Set {fieldId} = '{newValue}'";
    }

    public CommandResult Execute()
    {
        try
        {
            _originalValue = _getValue();
            _setValue(_newValue);
            ExecutedAt = DateTime.UtcNow;
            return CommandResult.Success($"Field '{_fieldId}' set to '{_newValue}'");
        }
        catch (Exception ex)
        {
            return CommandResult.Failure($"Text input failed: {ex.Message}");
        }
    }

    public CommandResult Undo()
    {
        try
        {
            _setValue(_originalValue);
            return CommandResult.Success($"Field '{_fieldId}' restored to '{_originalValue}'");
        }
        catch (Exception ex)
        {
            return CommandResult.Failure($"Text input undo failed: {ex.Message}");
        }
    }

    public ICommand CreateInverse()
    {
        return new TextInputCommand(_fieldId, _originalValue, _setValue, _getValue);
    }
}
```

### Practical Implementation (5 minutes)

#### Complete Macro System Usage

```csharp
// Example usage of the macro recording system
public class MacroSystemExample
{
    public static void DemonstrateUsage()
    {
        var document = new Document();
        var recorder = new UIActionRecorder();

        // Start recording
        recorder.StartRecording();

        // Record a series of actions
        recorder.RecordAndExecute(new InsertLineCommand(document, 0, "Hello World"));
        recorder.RecordAndExecute(new InsertLineCommand(document, 1, "This is a test"));
        recorder.RecordAndExecute(new UpdateLineCommand(document, 0, "Hello Command Pattern!"));

        // Stop recording and create macro
        var macro = recorder.StopRecording("Text Setup Macro");

        // Save macro for later use
        recorder.SaveMacro(macro, "text-setup-macro.json");

        // Execute macro on a new document
        var newDocument = new Document();
        var macroResult = macro.Execute();

        if (macroResult.IsSuccessful)
        {
            Console.WriteLine($"Macro executed successfully: {newDocument}");
        }

        // Undo the entire macro
        var undoResult = macro.Undo();
        if (undoResult.IsSuccessful)
        {
            Console.WriteLine("Macro undone successfully");
        }
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Mastered in Command Pattern Series (Parts A-D)**:

- Command Pattern fundamentals and architectural benefits
- Document editor with full undo/redo functionality
- API request commands with retry logic and error handling
- Macro recording and playback systems for automation
- UI action recording for testing and user assistance

**Pattern Benefits Achieved**:

- **Decoupling** - Actions separated from their triggers
- **Undo/Redo** - Full reversibility of operations
- **Macro Recording** - Automated task execution
- **Queuing** - Batch processing and scheduling
- **Logging** - Complete audit trail of actions

**Real-World Applications**:

- Text editors (VS Code, Word, etc.)
- Database transaction systems
- API integration platforms
- Test automation frameworks
- User interface macro systems

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Command Fundamentals](12A_Design-Patterns-Part7A-Command-Pattern-Fundamentals.md)**
- **[Part B - Document Editor](12B_Design-Patterns-Part7B-Command-Pattern-Document-Editor.md)**
- **[Part C - API System](12C_Design-Patterns-Part7C-Command-Pattern-API-System.md)**

**Builds Upon**:

- Composite Pattern for macro commands
- Observer Pattern for command notifications
- Memento Pattern for state management

**Enables**:

- [Event Sourcing Architectures](../../advanced-patterns/event-sourcing/)
- [CQRS Patterns](../../advanced-patterns/cqrs/)
- [Test Automation Frameworks](../../../testing/automation/)

**Next Patterns**:

- [Chain of Responsibility](../behavioral-patterns/chain-of-responsibility/)
- [Mediator Pattern](../behavioral-patterns/mediator/)
- [State Pattern](../behavioral-patterns/state/)
