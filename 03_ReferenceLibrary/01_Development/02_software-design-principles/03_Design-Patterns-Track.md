# 🎨 Design Patterns Track - Multi-Language Implementation

**Learning Level**: Intermediate → Advanced  
**Prerequisites**: OOP fundamentals, SOLID principles  
**Estimated Time**: 4-5 weeks (1 hour daily)  
**Next Steps**: Architectural patterns, Clean Architecture

---

## 🎯 Learning Objectives

By completion, you will:

- Master essential Gang of Four (GoF) design patterns
- Implement patterns effectively in Generic, C#, and Python
- Choose appropriate patterns for specific design problems
- Recognize patterns in existing codebases and frameworks

---

## 🗺️ Learning Progression Map

### **Week 1: Creational Patterns**

- Day 1: Singleton - One instance management
- Day 2: Factory Method - Object creation without specifying classes
- Day 3: Abstract Factory - Families of related objects
- Day 4: Builder - Complex object construction
- Day 5: Prototype - Object cloning and copying

### **Week 2: Structural Patterns**

- Day 1: Adapter - Interface compatibility
- Day 2: Decorator - Dynamic behavior extension
- Day 3: Facade - Simplified interface to complex subsystem
- Day 4: Composite - Tree structures and hierarchies
- Day 5: Proxy - Controlled access to objects

### **Week 3: Behavioral Patterns (Core)**

- Day 1: Observer - Event notification system
- Day 2: Strategy - Interchangeable algorithms
- Day 3: Command - Encapsulated requests
- Day 4: Template Method - Algorithm skeleton
- Day 5: State - Object behavior based on internal state

### **Week 4: Behavioral Patterns (Advanced)**

- Day 1: Chain of Responsibility - Handler chain processing
- Day 2: Mediator - Object interaction coordination
- Day 3: Visitor - Operations on object structures
- Day 4: Iterator - Sequential access patterns
- Day 5: Memento - Object state capture and restore

### **Week 5: Pattern Integration & Real-World Application**

- Day 1-2: Combine multiple patterns in complex scenarios
- Day 3-4: Refactor existing code using appropriate patterns
- Day 5: Design pattern selection guidelines and anti-patterns

---

## 🏗️ Creational Patterns Deep Dive

### **🔒 Singleton Pattern**

**Purpose**: Ensure a class has only one instance and provide global access point.

**Generic Concept**: Control object instantiation to maintain single instance.

**Use Cases**:

- Database connections
- Configuration managers
- Logging services
- Cache managers

**C# Implementation Focus**:

```csharp
public sealed class ConfigManager
{
    private static readonly Lazy<ConfigManager> _instance = 
        new Lazy<ConfigManager>(() => new ConfigManager());
    
    public static ConfigManager Instance => _instance.Value;
    
    private ConfigManager() { }
}
```

**Python Implementation Focus**:

```python
class ConfigManager:
    _instance = None
    _lock = threading.Lock()
    
    def __new__(cls):
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super().__new__(cls)
        return cls._instance
```

**When to Use**: Global state management, expensive object creation, hardware access.

**When to Avoid**: Testing scenarios, when you need multiple instances later.

### **🏭 Factory Method Pattern**

**Purpose**: Create objects without specifying exact classes to create.

**Generic Concept**: Define interface for creating objects, let subclasses decide which class to instantiate.

**C# Implementation Focus**:

```csharp
public abstract class PaymentProcessorFactory
{
    public abstract IPaymentProcessor CreateProcessor();
}

public class CreditCardProcessorFactory : PaymentProcessorFactory
{
    public override IPaymentProcessor CreateProcessor()
    {
        return new CreditCardProcessor();
    }
}
```

**Python Implementation Focus**:

```python
from abc import ABC, abstractmethod

class PaymentProcessorFactory(ABC):
    @abstractmethod
    def create_processor(self):
        pass

class CreditCardProcessorFactory(PaymentProcessorFactory):
    def create_processor(self):
        return CreditCardProcessor()
```

### **🏗️ Builder Pattern**

**Purpose**: Construct complex objects step by step.

**Generic Concept**: Separate construction from representation, allow same construction process to create different representations.

**C# Implementation Focus**:

```csharp
public class SqlQueryBuilder
{
    private StringBuilder _query = new StringBuilder();
    
    public SqlQueryBuilder Select(string fields)
    {
        _query.Append($"SELECT {fields} ");
        return this;
    }
    
    public SqlQueryBuilder From(string table)
    {
        _query.Append($"FROM {table} ");
        return this;
    }
    
    public string Build() => _query.ToString();
}
```

**Python Implementation Focus**:

```python
class SqlQueryBuilder:
    def __init__(self):
        self._query_parts = []
    
    def select(self, fields):
        self._query_parts.append(f"SELECT {fields}")
        return self
    
    def from_table(self, table):
        self._query_parts.append(f"FROM {table}")
        return self
    
    def build(self):
        return " ".join(self._query_parts)
```

---

## 🔧 Structural Patterns Deep Dive

### **🔌 Adapter Pattern**

**Purpose**: Allow incompatible interfaces to work together.

**Generic Concept**: Wrap existing class with new interface without changing its code.

**Real-World Example**: Third-party library integration

**C# Implementation**:

```csharp
// Legacy payment system
public class LegacyPaymentGateway
{
    public void ProcessPayment(decimal amount, string cardNumber)
    {
        // Legacy implementation
    }
}

// Modern interface
public interface IPaymentProcessor
{
    void Process(PaymentRequest request);
}

// Adapter
public class PaymentGatewayAdapter : IPaymentProcessor
{
    private readonly LegacyPaymentGateway _gateway;
    
    public PaymentGatewayAdapter(LegacyPaymentGateway gateway)
    {
        _gateway = gateway;
    }
    
    public void Process(PaymentRequest request)
    {
        _gateway.ProcessPayment(request.Amount, request.CardNumber);
    }
}
```

### **🎨 Decorator Pattern**

**Purpose**: Add new functionality to objects dynamically without altering structure.

**Generic Concept**: Wrap objects in decorator objects that contain the behaviors.

**C# Implementation Focus**:

```csharp
public interface ICoffee
{
    decimal Cost { get; }
    string Description { get; }
}

public class SimpleCoffee : ICoffee
{
    public decimal Cost => 2.00m;
    public string Description => "Simple coffee";
}

public abstract class CoffeeDecorator : ICoffee
{
    protected ICoffee _coffee;
    
    public CoffeeDecorator(ICoffee coffee)
    {
        _coffee = coffee;
    }
    
    public virtual decimal Cost => _coffee.Cost;
    public virtual string Description => _coffee.Description;
}

public class MilkDecorator : CoffeeDecorator
{
    public MilkDecorator(ICoffee coffee) : base(coffee) { }
    
    public override decimal Cost => _coffee.Cost + 0.50m;
    public override string Description => _coffee.Description + ", milk";
}
```

---

## 🎭 Behavioral Patterns Deep Dive

### **👁️ Observer Pattern**

**Purpose**: Define one-to-many dependency between objects so when one changes state, all dependents are notified.

**C# Implementation Focus**:

```csharp
public interface IObserver<T>
{
    void Update(T data);
}

public interface ISubject<T>
{
    void Subscribe(IObserver<T> observer);
    void Unsubscribe(IObserver<T> observer);
    void Notify(T data);
}

public class NewsPublisher : ISubject<string>
{
    private readonly List<IObserver<string>> _observers = new();
    
    public void Subscribe(IObserver<string> observer) => _observers.Add(observer);
    public void Unsubscribe(IObserver<string> observer) => _observers.Remove(observer);
    public void Notify(string news) => _observers.ForEach(o => o.Update(news));
}
```

**Python Implementation Focus**:

```python
from abc import ABC, abstractmethod
from typing import List

class Observer(ABC):
    @abstractmethod
    def update(self, data):
        pass

class Subject:
    def __init__(self):
        self._observers: List[Observer] = []
    
    def subscribe(self, observer: Observer):
        self._observers.append(observer)
    
    def unsubscribe(self, observer: Observer):
        self._observers.remove(observer)
    
    def notify(self, data):
        for observer in self._observers:
            observer.update(data)
```

### **🎯 Strategy Pattern**

**Purpose**: Define family of algorithms, encapsulate each one, and make them interchangeable.

**C# Implementation**:

```csharp
public interface ISortingStrategy<T>
{
    void Sort(T[] array);
}

public class QuickSortStrategy<T> : ISortingStrategy<T> where T : IComparable<T>
{
    public void Sort(T[] array)
    {
        // QuickSort implementation
    }
}

public class SortContext<T>
{
    private ISortingStrategy<T> _strategy;
    
    public void SetStrategy(ISortingStrategy<T> strategy)
    {
        _strategy = strategy;
    }
    
    public void Sort(T[] array)
    {
        _strategy.Sort(array);
    }
}
```

---

## 🛠️ Hands-On Projects

### **Beginner Project: Document Processing System**

Build a document processor using multiple patterns:

- **Factory Method**: Create different document types (PDF, Word, Excel)
- **Decorator**: Add features (encryption, compression, watermarks)
- **Observer**: Notify when processing completes
- **Strategy**: Different processing algorithms

### **Intermediate Project: E-Commerce Platform**

Design an e-commerce system incorporating:

- **Abstract Factory**: Create UI components for different platforms
- **Builder**: Construct complex product configurations
- **Adapter**: Integrate multiple payment gateways
- **Command**: Implement undo/redo for shopping cart operations
- **State**: Manage order states (pending, processing, shipped)

### **Advanced Project: Game Development Framework**

Create a flexible game framework:

- **Singleton**: Game manager and resource manager
- **Factory**: Create different game entities
- **Composite**: Scene graph and UI hierarchies
- **Observer**: Event system for game events
- **State**: Character behavior and game states
- **Command**: Input handling and replay system

---

## 📋 Pattern Selection Guide

### **When to Use Creational Patterns**

- **Singleton**: Need exactly one instance (configuration, logging)
- **Factory Method**: Don't know exact types until runtime
- **Abstract Factory**: Need families of related products
- **Builder**: Complex objects with many optional parameters
- **Prototype**: Object creation is expensive, need clones

### **When to Use Structural Patterns**

- **Adapter**: Need to use incompatible interfaces
- **Decorator**: Want to add responsibilities dynamically
- **Facade**: Need simplified interface to complex subsystem
- **Composite**: Need to treat individual/composite objects uniformly
- **Proxy**: Need controlled access or lazy loading

### **When to Use Behavioral Patterns**

- **Observer**: Need loose coupling with one-to-many notifications
- **Strategy**: Need interchangeable algorithms
- **Command**: Need to parameterize objects with operations
- **Template Method**: Have algorithm steps that vary
- **State**: Object behavior changes based on internal state

---

## 📊 Assessment Framework

### **Week 1 - Creational Patterns ✓**

- [ ] Implements all 5 creational patterns correctly
- [ ] Understands when to use each pattern
- [ ] Can explain trade-offs and alternatives

### **Week 2 - Structural Patterns ✓**

- [ ] Masters adapter and decorator patterns
- [ ] Applies facade for complex system simplification
- [ ] Uses composite for hierarchical structures

### **Week 3-4 - Behavioral Patterns ✓**

- [ ] Implements observer for event systems
- [ ] Uses strategy for algorithm flexibility
- [ ] Applies command for operation encapsulation

### **Week 5 - Integration & Mastery ✓**

- [ ] Combines multiple patterns effectively
- [ ] Recognizes patterns in existing frameworks
- [ ] Makes informed pattern selection decisions

---

## 🔗 Related Topics

**Prerequisites**:

- `01_OOP-Foundation-Track.md` - Object-oriented programming
- `02_SOLID-Principles-Track.md` - Design principles foundation

**Builds Upon**:

- `../01_Python/02_Advanced-Patterns/` - Python advanced features
- `../03_CSharp/02_Advanced-OOP/` - C# advanced concepts

**Enables**:

- `04_Clean-Architecture-Track.md` - Architectural patterns
- `../06-architectural-principles/` - System design patterns
- `../07-architecture-patterns/` - Enterprise patterns

**Cross-References**:

- `05-design-patterns/` - Extended pattern library
- Framework-specific pattern implementations

---

**Last Updated**: August 30, 2025  
**Track Status**: Core patterns for flexible software design  
**Implementation**: Multi-language focus with practical examples
