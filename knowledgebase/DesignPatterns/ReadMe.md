# Learning Design Patterns

Here’s a **crisp summary** of the **23 Gang of Four (GoF) Design Patterns** categorized into **Creational**, **Structural**, and **Behavioral**, with a focus on C#:

---

## **1. Creational Patterns**

These patterns deal with object creation to ensure flexibility and reuse.

1. **Singleton**

   - Ensures only one instance of a class.
   - **Example:**
     ```csharp
     public sealed class Singleton {
         private static readonly Singleton instance = new Singleton();
         private Singleton() {}
         public static Singleton Instance => instance;
     }
     ```

2. **Factory Method**

   - Creates objects without specifying the exact class.
   - **Example:**
     ```csharp
     public abstract class Animal {
         public abstract void Speak();
     }
     public class Dog : Animal {
         public override void Speak() => Console.WriteLine("Woof!");
     }
     public class AnimalFactory {
         public static Animal CreateAnimal() => new Dog();
     }
     ```

3. **Abstract Factory**

   - Creates families of related objects.
   - **Example:**
     ```csharp
     public interface IButton { void Render(); }
     public class WindowsButton : IButton { public void Render() => Console.WriteLine("Windows Button"); }
     public class MacButton : IButton { public void Render() => Console.WriteLine("Mac Button"); }
     public interface IFactory { IButton CreateButton(); }
     public class WindowsFactory : IFactory { public IButton CreateButton() => new WindowsButton(); }
     ```

4. **Builder**

   - Builds complex objects step-by-step.
   - **Example:**
     ```csharp
     public class Car {
         public string Engine { get; set; }
         public string Wheels { get; set; }
     }
     public class CarBuilder {
         private readonly Car _car = new();
         public CarBuilder SetEngine(string engine) { _car.Engine = engine; return this; }
         public CarBuilder SetWheels(string wheels) { _car.Wheels = wheels; return this; }
         public Car Build() => _car;
     }
     ```

5. **Prototype**
   - Clones existing objects.
   - **Example:**
     ```csharp
     public abstract class Shape {
         public abstract Shape Clone();
     }
     public class Circle : Shape {
         public int Radius { get; set; }
         public override Shape Clone() => (Shape)MemberwiseClone();
     }
     ```

---

## **2. Structural Patterns**

These patterns deal with the composition of classes and objects.

1. **Adapter**

   - Converts one interface to another.
   - **Example:**
     ```csharp
     public interface ITarget { void Request(); }
     public class Adaptee { public void SpecificRequest() => Console.WriteLine("Specific Request"); }
     public class Adapter : ITarget {
         private readonly Adaptee _adaptee = new();
         public void Request() => _adaptee.SpecificRequest();
     }
     ```

2. **Bridge**

   - Separates abstraction from implementation.
   - **Example:**
     ```csharp
     public interface IRenderer { void RenderShape(string shape); }
     public class VectorRenderer : IRenderer { public void RenderShape(string shape) => Console.WriteLine($"Rendering {shape} as vectors"); }
     public class Shape {
         protected IRenderer renderer;
         public Shape(IRenderer renderer) => this.renderer = renderer;
     }
     public class Circle : Shape {
         public Circle(IRenderer renderer) : base(renderer) {}
         public void Draw() => renderer.RenderShape("Circle");
     }
     ```

3. **Composite**

   - Composes objects into tree structures.
   - **Example:**
     ```csharp
     public interface IComponent { void Display(); }
     public class Leaf : IComponent {
         public void Display() => Console.WriteLine("Leaf");
     }
     public class Composite : IComponent {
         private readonly List<IComponent> _children = new();
         public void Add(IComponent component) => _children.Add(component);
         public void Display() { foreach (var child in _children) child.Display(); }
     }
     ```

4. **Decorator**

   - Adds behavior to objects dynamically.
   - **Example:**
     ```csharp
     public interface INotifier { void Send(string message); }
     public class EmailNotifier : INotifier { public void Send(string message) => Console.WriteLine($"Email: {message}"); }
     public class SmsNotifier : INotifier {
         private readonly INotifier _notifier;
         public SmsNotifier(INotifier notifier) => _notifier = notifier;
         public void Send(string message) {
             _notifier.Send(message);
             Console.WriteLine($"SMS: {message}");
         }
     }
     ```

5. **Facade**

   - Simplifies access to a complex system.
   - **Example:**
     ```csharp
     public class SubsystemA { public void OperationA() => Console.WriteLine("Operation A"); }
     public class SubsystemB { public void OperationB() => Console.WriteLine("Operation B"); }
     public class Facade {
         private readonly SubsystemA _a = new();
         private readonly SubsystemB _b = new();
         public void Operation() {
             _a.OperationA();
             _b.OperationB();
         }
     }
     ```

6. **Flyweight**

   - Reuses shared objects to reduce memory usage.
   - **Example:**
     ```csharp
     public class Flyweight {
         public string State { get; set; }
     }
     public class FlyweightFactory {
         private readonly Dictionary<string, Flyweight> _cache = new();
         public Flyweight GetFlyweight(string key) {
             if (!_cache.ContainsKey(key)) _cache[key] = new Flyweight { State = key };
             return _cache[key];
         }
     }
     ```

7. **Proxy**
   - Controls access to an object.
   - **Example:**
     ```csharp
     public interface IService { void Request(); }
     public class RealService : IService { public void Request() => Console.WriteLine("Real Service Request"); }
     public class Proxy : IService {
         private readonly RealService _service = new();
         public void Request() => _service.Request();
     }
     ```

---

## **3. Behavioral Patterns**

These patterns focus on communication between objects.

1. **Chain of Responsibility**
2. **Command**
3. **Interpreter**
4. **Iterator**
5. **Mediator**
6. **Memento**
7. **Observer**
8. **State**
9. **Strategy**
10. **Template Method**
11. **Visitor**

---

Would you like examples for any specific behavioral pattern? Good luck! 🎉

Here’s the **crisp summary** of **Behavioral Patterns** with **C# examples**:

---

## **Behavioral Patterns**

These patterns deal with communication between objects and responsibilities.

---

### **1. Chain of Responsibility**

Passes requests along a chain of handlers.  
**Example:**

```csharp
public abstract class Handler {
    protected Handler next;
    public void SetNext(Handler nextHandler) => next = nextHandler;
    public abstract void HandleRequest(string request);
}
public class ConcreteHandlerA : Handler {
    public override void HandleRequest(string request) {
        if (request == "A") Console.WriteLine("Handled by A");
        else next?.HandleRequest(request);
    }
}
public class ConcreteHandlerB : Handler {
    public override void HandleRequest(string request) {
        if (request == "B") Console.WriteLine("Handled by B");
        else next?.HandleRequest(request);
    }
}
```

---

### **2. Command**

Encapsulates a request as an object.  
**Example:**

```csharp
public interface ICommand { void Execute(); }
public class Light {
    public void TurnOn() => Console.WriteLine("Light is ON");
    public void TurnOff() => Console.WriteLine("Light is OFF");
}
public class TurnOnCommand : ICommand {
    private readonly Light _light;
    public TurnOnCommand(Light light) => _light = light;
    public void Execute() => _light.TurnOn();
}
public class RemoteControl {
    private ICommand _command;
    public void SetCommand(ICommand command) => _command = command;
    public void PressButton() => _command.Execute();
}
```

---

### **3. Interpreter**

Evaluates expressions in a given language.  
**Example:**

```csharp
public interface IExpression {
    int Interpret(Dictionary<string, int> context);
}
public class Number : IExpression {
    private readonly int _value;
    public Number(int value) => _value = value;
    public int Interpret(Dictionary<string, int> context) => _value;
}
public class Add : IExpression {
    private readonly IExpression _left, _right;
    public Add(IExpression left, IExpression right) {
        _left = left;
        _right = right;
    }
    public int Interpret(Dictionary<string, int> context) => _left.Interpret(context) + _right.Interpret(context);
}
```

---

### **4. Iterator**

Provides a way to access elements sequentially.  
**Example:**

```csharp
public interface IIterator<T> {
    bool HasNext();
    T Next();
}
public class ListIterator<T> : IIterator<T> {
    private readonly List<T> _collection;
    private int _index = 0;
    public ListIterator(List<T> collection) => _collection = collection;
    public bool HasNext() => _index < _collection.Count;
    public T Next() => _collection[_index++];
}
```

---

### **5. Mediator**

Defines communication between objects via a mediator.  
**Example:**

```csharp
public interface IMediator {
    void Notify(string sender, string eventInfo);
}
public class ConcreteMediator : IMediator {
    public void Notify(string sender, string eventInfo) => Console.WriteLine($"{sender} triggered {eventInfo}");
}
public class Component {
    private readonly IMediator _mediator;
    public Component(IMediator mediator) => _mediator = mediator;
    public void TriggerEvent(string eventInfo) => _mediator.Notify(GetType().Name, eventInfo);
}
```

---

### **6. Memento**

Captures and restores an object's state.  
**Example:**

```csharp
public class Memento {
    public string State { get; }
    public Memento(string state) => State = state;
}
public class Originator {
    public string State { get; set; }
    public Memento SaveState() => new(State);
    public void RestoreState(Memento memento) => State = memento.State;
}
public class Caretaker {
    private readonly Stack<Memento> _history = new();
    public void Save(Memento memento) => _history.Push(memento);
    public Memento Undo() => _history.Pop();
}
```

---

### **7. Observer**

Defines a dependency between objects so that one changes, others get notified.  
**Example:**

```csharp
public interface IObserver { void Update(string message); }
public class Subject {
    private readonly List<IObserver> _observers = new();
    public void Attach(IObserver observer) => _observers.Add(observer);
    public void Notify(string message) => _observers.ForEach(o => o.Update(message));
}
public class ConcreteObserver : IObserver {
    public void Update(string message) => Console.WriteLine($"Received: {message}");
}
```

---

### **8. State**

Allows an object to alter its behavior when its state changes.  
**Example:**

```csharp
public interface IState { void Handle(); }
public class OpenState : IState { public void Handle() => Console.WriteLine("Door is Open"); }
public class ClosedState : IState { public void Handle() => Console.WriteLine("Door is Closed"); }
public class Door {
    private IState _state;
    public Door(IState state) => _state = state;
    public void SetState(IState state) => _state = state;
    public void Request() => _state.Handle();
}
```

---

### **9. Strategy**

Encapsulates interchangeable algorithms.  
**Example:**

```csharp
public interface IStrategy { int Execute(int a, int b); }
public class AddStrategy : IStrategy { public int Execute(int a, int b) => a + b; }
public class MultiplyStrategy : IStrategy { public int Execute(int a, int b) => a * b; }
public class Context {
    private readonly IStrategy _strategy;
    public Context(IStrategy strategy) => _strategy = strategy;
    public int Execute(int a, int b) => _strategy.Execute(a, b);
}
```

---

### **10. Template Method**

Defines the skeleton of an algorithm in a base class.  
**Example:**

```csharp
public abstract class Task {
    public void Execute() {
        Start();
        PerformTask();
        End();
    }
    protected abstract void PerformTask();
    private void Start() => Console.WriteLine("Start Task");
    private void End() => Console.WriteLine("End Task");
}
public class ConcreteTask : Task {
    protected override void PerformTask() => Console.WriteLine("Perform Concrete Task");
}
```

---

### **11. Visitor**

Separates an algorithm from the object structure.  
**Example:**

```csharp
public interface IVisitor { void Visit(Element element); }
public abstract class Element {
    public abstract void Accept(IVisitor visitor);
}
public class ConcreteElement : Element {
    public override void Accept(IVisitor visitor) => visitor.Visit(this);
}
public class ConcreteVisitor : IVisitor {
    public void Visit(Element element) => Console.WriteLine("Visited Element");
}
```

---

Good luck with your interview! 🎉 Let me know if you need further clarification!
