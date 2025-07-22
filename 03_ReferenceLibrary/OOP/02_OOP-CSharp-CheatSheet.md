# 🔷 C# OOP Cheat Sheet

**C#-Specific Object-Oriented Programming Reference**

> 📖 **8-minute reference** | 🎯 **Focus**: C# syntax and best practices | 🔷 **Platform**: .NET ecosystem

---

## 🚀 Quick Start: Classes and Objects

### **Basic Class Definition**

```csharp
public class Person
{
    // Fields (private by default)
    private string _name;
    private int _age;

    // Properties (recommended over public fields)
    public string Name
    {
        get => _name;
        set => _name = value ?? throw new ArgumentNullException(nameof(value));
    }

    public int Age
    {
        get => _age;
        set => _age = value >= 0 ? value : throw new ArgumentOutOfRangeException(nameof(value));
    }

    // Auto-implemented property (shorthand)
    public string Email { get; set; }

    // Constructor
    public Person(string name, int age)
    {
        Name = name;
        Age = age;
    }

    // Method
    public string GetInfo() => $"Name: {Name}, Age: {Age}";

    // Override ToString for better debugging
    public override string ToString() => GetInfo();
}
```

### **Object Creation and Usage**

```csharp
// Object creation
var person = new Person("Alice", 30);
person.Email = "alice@example.com";

// Using object initializer (C# 3.0+)
var person2 = new Person("Bob", 25)
{
    Email = "bob@example.com"
};

// Target-typed new (C# 9.0+)
Person person3 = new("Charlie", 35);
```

---

## 🧬 Inheritance in C#

### **Basic Inheritance**

```csharp
// Base class
public class Animal
{
    public string Name { get; protected set; }

    public Animal(string name)
    {
        Name = name;
    }

    public virtual void MakeSound()
    {
        Console.WriteLine($"{Name} makes a sound");
    }

    public virtual void Move()
    {
        Console.WriteLine($"{Name} moves");
    }
}

// Derived class
public class Dog : Animal
{
    public string Breed { get; set; }

    // Constructor chaining with base
    public Dog(string name, string breed) : base(name)
    {
        Breed = breed;
    }

    // Method overriding
    public override void MakeSound()
    {
        Console.WriteLine($"{Name} barks: Woof!");
    }

    // New method specific to Dog
    public void Fetch()
    {
        Console.WriteLine($"{Name} fetches the ball");
    }
}
```

### **Access Modifiers Deep Dive**

| Modifier             | Same Class | Derived Class | Same Assembly | Other Assembly |
| -------------------- | ---------- | ------------- | ------------- | -------------- |
| `private`            | ✅         | ❌            | ❌            | ❌             |
| `protected`          | ✅         | ✅            | ❌            | ❌             |
| `internal`           | ✅         | ❌            | ✅            | ❌             |
| `protected internal` | ✅         | ✅            | ✅            | ❌             |
| `private protected`  | ✅         | ✅\*          | ❌            | ❌             |
| `public`             | ✅         | ✅            | ✅            | ✅             |

\*Only in same assembly

---

## 🎭 Polymorphism in C#

### **Two Types of Polymorphism**

#### **1. Compile-Time Polymorphism (Method Overloading)**

```csharp
public class Printer
{
    public void Print(string message) => Console.WriteLine(message);
    public void Print(int number) => Console.WriteLine(number);
    public void Print(string message, bool addTimestamp)
    {
        var output = addTimestamp ? $"{DateTime.Now}: {message}" : message;
        Console.WriteLine(output);
    }
}

// Usage
var printer = new Printer();
printer.Print("Hello");           // Calls string version
printer.Print(42);               // Calls int version
printer.Print("Hello", true);    // Calls string + bool version
```

#### **2. Runtime Polymorphism (Method Overriding)**

### **Virtual, Override, and New**

```csharp
public class Shape
{
    public virtual double GetArea() => 0;
    public virtual void Draw() => Console.WriteLine("Drawing a shape");
}

public class Rectangle : Shape
{
    public double Width { get; set; }
    public double Height { get; set; }

    // Override - participates in polymorphism
    public override double GetArea() => Width * Height;
    public override void Draw() => Console.WriteLine("Drawing a rectangle");
}

public class SpecialRectangle : Rectangle
{
    // New - hides base method (not polymorphic)
    public new void Draw() => Console.WriteLine("Drawing a special rectangle");
}
```

### **Polymorphism in Action**

```csharp
Shape[] shapes =
{
    new Rectangle { Width = 5, Height = 3 },
    new Circle { Radius = 4 },
    new Triangle { Base = 6, Height = 8 }
};

foreach (Shape shape in shapes)
{
    Console.WriteLine($"Area: {shape.GetArea()}"); // Polymorphic call
    shape.Draw(); // Calls correct override
}
```

---

## 🔧 Abstract Classes vs Interfaces

### **Abstract Classes**

```csharp
public abstract class Vehicle
{
    // Abstract property
    public abstract string Type { get; }

    // Abstract method
    public abstract void Start();

    // Concrete method (shared implementation)
    public void Stop()
    {
        Console.WriteLine($"{Type} is stopping");
    }

    // Virtual method (can be overridden)
    public virtual void Accelerate()
    {
        Console.WriteLine($"{Type} is accelerating");
    }
}

public class Car : Vehicle
{
    public override string Type => "Car";

    public override void Start()
    {
        Console.WriteLine("Car engine starts");
    }

    public override void Accelerate()
    {
        Console.WriteLine("Car accelerates smoothly");
    }
}
```

### **Interfaces**

```csharp
public interface IFlyable
{
    void TakeOff();
    void Land();
    int MaxAltitude { get; }
}

public interface ISwimmable
{
    void Dive();
    void Surface();
    int MaxDepth { get; }
}

// Multiple interface implementation
public class Duck : Animal, IFlyable, ISwimmable
{
    public Duck(string name) : base(name) { }

    // IFlyable implementation
    public void TakeOff() => Console.WriteLine($"{Name} takes off");
    public void Land() => Console.WriteLine($"{Name} lands");
    public int MaxAltitude => 1000;

    // ISwimmable implementation
    public void Dive() => Console.WriteLine($"{Name} dives");
    public void Surface() => Console.WriteLine($"{Name} surfaces");
    public int MaxDepth => 10;
}
```

### **Default Interface Methods (C# 8.0+)**

```csharp
public interface ILogger
{
    void Log(string message);

    // Default implementation
    void LogError(string message) => Log($"ERROR: {message}");
    void LogWarning(string message) => Log($"WARNING: {message}");
}
```

---

## 🏗️ Properties and Fields

### **Property Patterns**

```csharp
public class BankAccount
{
    private decimal _balance;

    // Full property with validation
    public decimal Balance
    {
        get => _balance;
        private set => _balance = value >= 0 ? value :
            throw new ArgumentException("Balance cannot be negative");
    }

    // Auto-implemented property with private setter
    public string AccountNumber { get; private set; }

    // Init-only property (C# 9.0+)
    public string BankName { get; init; }

    // Required property (C# 11.0+)
    public required string OwnerName { get; set; }

    // Computed property
    public string DisplayName => $"{OwnerName} - {AccountNumber}";

    // Property with expression body
    public bool IsOverdrawn => Balance < 0;
}
```

### **Record Types (C# 9.0+)**

```csharp
// Record with auto-implemented properties
public record Person(string FirstName, string LastName, int Age)
{
    // Additional computed property
    public string FullName => $"{FirstName} {LastName}";

    // Additional validation
    public Person(string firstName, string lastName, int age) : this(firstName, lastName, age)
    {
        if (age < 0) throw new ArgumentOutOfRangeException(nameof(age));
    }
}

// Usage
var person = new Person("John", "Doe", 30);
var person2 = person with { Age = 31 }; // Creates new record with modified age
```

---

## ⚡ Static vs Instance Members

### **Static Members**

```csharp
public class MathHelper
{
    // Static field
    public static readonly double Pi = 3.14159;

    // Static property
    public static DateTime CurrentTime => DateTime.Now;

    // Static method
    public static double CalculateArea(double radius) => Pi * radius * radius;

    // Static constructor (runs once)
    static MathHelper()
    {
        Console.WriteLine("MathHelper static constructor called");
    }
}

// Usage - no instance needed
double area = MathHelper.CalculateArea(5);
```

### **Static Classes**

```csharp
// Static class - cannot be instantiated
public static class StringExtensions
{
    // Extension method
    public static bool IsNullOrWhiteSpace(this string value)
    {
        return string.IsNullOrWhiteSpace(value);
    }

    public static string Truncate(this string value, int maxLength)
    {
        return value?.Length > maxLength ? value[..maxLength] : value;
    }
}

// Usage
string text = "Hello World";
bool isEmpty = text.IsNullOrWhiteSpace(); // Extension method
string truncated = text.Truncate(5); // "Hello"
```

---

## 🔒 Encapsulation Best Practices

### **Proper Field and Property Design**

```csharp
public class Customer
{
    // Private fields with underscore convention
    private readonly List<Order> _orders = new();
    private string _email;

    // Public property with validation
    public string Email
    {
        get => _email;
        set
        {
            if (string.IsNullOrWhiteSpace(value) || !IsValidEmail(value))
                throw new ArgumentException("Invalid email address");
            _email = value;
        }
    }

    // Read-only collection property
    public IReadOnlyList<Order> Orders => _orders.AsReadOnly();

    // Method to modify internal collection safely
    public void AddOrder(Order order)
    {
        if (order == null) throw new ArgumentNullException(nameof(order));
        _orders.Add(order);
    }

    private static bool IsValidEmail(string email) =>
        email.Contains('@') && email.Contains('.');
}
```

---

## 🎨 Common C# OOP Patterns

### **Singleton Pattern**

```csharp
public sealed class DatabaseConnection
{
    private static readonly Lazy<DatabaseConnection> _instance =
        new(() => new DatabaseConnection());

    public static DatabaseConnection Instance => _instance.Value;

    private DatabaseConnection() { } // Private constructor

    public void Connect() => Console.WriteLine("Connected to database");
}

// Usage
DatabaseConnection.Instance.Connect();
```

### **Factory Pattern**

```csharp
public abstract class Vehicle
{
    public abstract void Start();

    // Factory method
    public static Vehicle Create(string type) => type.ToLower() switch
    {
        "car" => new Car(),
        "truck" => new Truck(),
        "motorcycle" => new Motorcycle(),
        _ => throw new ArgumentException($"Unknown vehicle type: {type}")
    };
}
```

### **Builder Pattern (Fluent Interface)**

```csharp
public class EmailBuilder
{
    private string _to;
    private string _subject;
    private string _body;
    private List<string> _attachments = new();

    public EmailBuilder To(string recipient)
    {
        _to = recipient;
        return this;
    }

    public EmailBuilder Subject(string subject)
    {
        _subject = subject;
        return this;
    }

    public EmailBuilder Body(string body)
    {
        _body = body;
        return this;
    }

    public EmailBuilder Attach(string filePath)
    {
        _attachments.Add(filePath);
        return this;
    }

    public Email Build() => new(_to, _subject, _body, _attachments);
}

// Usage
var email = new EmailBuilder()
    .To("user@example.com")
    .Subject("Welcome!")
    .Body("Thank you for joining us!")
    .Attach("welcome.pdf")
    .Build();
```

---

## 🔥 Modern C# Features

### **Nullable Reference Types (C# 8.0+)**

```csharp
#nullable enable

public class UserService
{
    // Non-nullable reference type
    public string GetUserName(User user) => user.Name;

    // Nullable reference type
    public string? GetUserEmail(User user) => user.Email;

    // Null-conditional operator
    public int GetEmailLength(User user) => user.Email?.Length ?? 0;

    // Null-coalescing assignment (C# 8.0+)
    public void EnsureEmail(User user)
    {
        user.Email ??= "no-email@example.com";
    }
}
```

### **Pattern Matching**

```csharp
public class ShapeCalculator
{
    public double CalculateArea(Shape shape) => shape switch
    {
        Circle { Radius: var r } => Math.PI * r * r,
        Rectangle { Width: var w, Height: var h } => w * h,
        Triangle { Base: var b, Height: var h } => 0.5 * b * h,
        null => throw new ArgumentNullException(nameof(shape)),
        _ => throw new ArgumentException($"Unknown shape: {shape.GetType()}")
    };

    public string DescribeShape(Shape shape) => shape switch
    {
        Circle c when c.Radius > 10 => "Large circle",
        Circle => "Small circle",
        Rectangle r when r.Width == r.Height => "Square",
        Rectangle => "Rectangle",
        _ => "Unknown shape"
    };
}
```

---

## 🔗 Object Relationships in C#

### **Quick Examples**

```csharp
// Association - Driver uses Car
public class Driver
{
    public void Drive(Car car) => car.Start(); // Uses Car temporarily
}

// Aggregation - Department has Employees (employees can exist independently)
public class Department
{
    public List<Employee> Employees { get; set; } = new();
}

// Composition - Car has Engine (engine cannot exist without car)
public class Car
{
    private readonly Engine _engine = new(); // Strong ownership

    public void Start() => _engine.Start();
}

// Inheritance - Dog is-a Animal
public class Dog : Animal
{
    public override void MakeSound() => Console.WriteLine("Woof!");
}
```

---

## ⚠️ Common C# OOP Pitfalls

### **❌ Mistakes to Avoid**

**1. Exposing Mutable Collections**

```csharp
// BAD - exposes internal collection
public List<Item> Items { get; set; } = new();

// GOOD - read-only view
public IReadOnlyList<Item> Items => _items.AsReadOnly();
```

**2. Not Using Properties**

```csharp
// BAD - public fields
public string Name;
public int Age;

// GOOD - properties with validation
public string Name { get; set; }
public int Age { get; set; }
```

**3. Inappropriate Static Usage**

```csharp
// BAD - everything static (procedural programming)
public static class UserManager
{
    public static void CreateUser() { }
    public static void DeleteUser() { }
}

// GOOD - instance-based with dependency injection
public class UserManager
{
    private readonly IUserRepository _repository;

    public UserManager(IUserRepository repository) => _repository = repository;
}
```

**4. Inheritance Abuse**

```csharp
// BAD - inheritance for code reuse only
public class EmailSender : DatabaseConnection { }

// GOOD - composition
public class EmailSender
{
    private readonly IDatabaseConnection _connection;

    public EmailSender(IDatabaseConnection connection) => _connection = connection;
}
```

---

## 🏆 C# OOP Best Practices

### **✅ Recommended Practices**

**1. Use Properties Over Fields**

```csharp
// Properties provide encapsulation and future flexibility
public string Name { get; set; }
public int Age { get; private set; }
```

**2. Follow Naming Conventions**

```csharp
public class UserManager          // PascalCase for public members
{
    private string _userName;     // _camelCase for private fields
    public string UserName { get; set; }  // PascalCase for properties

    public void GetUser() { }     // PascalCase for methods
}
```

**3. Use Expression-Bodied Members**

```csharp
public string FullName => $"{FirstName} {LastName}";
public override string ToString() => FullName;
public void LogInfo() => Console.WriteLine(FullName);
```

**4. Prefer Composition with Interfaces**

```csharp
public class OrderService
{
    private readonly IPaymentProcessor _paymentProcessor;
    private readonly IEmailService _emailService;

    public OrderService(IPaymentProcessor paymentProcessor, IEmailService emailService)
    {
        _paymentProcessor = paymentProcessor;
        _emailService = emailService;
    }
}
```

**5. Use Modern C# Features**

```csharp
// Records for data objects
public record ProductDto(int Id, string Name, decimal Price);

// Pattern matching for type checking
public decimal CalculateDiscount(Customer customer) => customer switch
{
    PremiumCustomer => 0.15m,
    RegularCustomer => 0.05m,
    _ => 0m
};
```

---

## 🎯 Performance Considerations

### **Memory and Performance Tips**

**1. Use Structs for Small, Immutable Data**

```csharp
public readonly struct Point
{
    public int X { get; }
    public int Y { get; }

    public Point(int x, int y) => (X, Y) = (x, y);
}
```

**2. Avoid Boxing with Generics**

```csharp
// BAD - boxing occurs
ArrayList list = new();
list.Add(42); // int boxed to object

// GOOD - no boxing
List<int> list = new();
list.Add(42); // int stays as int
```

**3. Use Object Pooling for Expensive Objects**

```csharp
public class ExpensiveObjectPool
{
    private readonly ConcurrentQueue<ExpensiveObject> _objects = new();

    public ExpensiveObject Rent()
    {
        return _objects.TryDequeue(out var obj) ? obj : new ExpensiveObject();
    }

    public void Return(ExpensiveObject obj)
    {
        obj.Reset();
        _objects.Enqueue(obj);
    }
}
```

---

## 💡 C# OOP in One Sentence

> **"C# OOP combines the four pillars of object-oriented programming with powerful .NET features like properties, generics, LINQ, and modern syntax to create robust, type-safe, and maintainable applications."**

---

## 🎯 Quick Reference Summary

### **Class Definition Checklist**

- [ ] Use properties instead of public fields
- [ ] Add input validation where needed
- [ ] Override `ToString()` for debugging
- [ ] Implement `IEquatable<T>` for value types
- [ ] Use appropriate access modifiers

### **Inheritance Checklist**

- [ ] Use inheritance for IS-A relationships only
- [ ] Call base constructors properly
- [ ] Use `virtual`/`override` for polymorphism
- [ ] Consider composition over inheritance

### **Interface Design Checklist**

- [ ] Keep interfaces focused and cohesive
- [ ] Use descriptive names ending with 'able' (IComparable, IDisposable)
- [ ] Consider default implementations for optional functionality
- [ ] Document interface contracts clearly

### **Performance Checklist**

- [ ] Use generics to avoid boxing
- [ ] Consider using structs for small data
- [ ] Implement `IDisposable` for resource cleanup
- [ ] Use appropriate collection types

---

**🎯 Next Steps**: Practice these concepts with hands-on coding exercises and explore advanced topics like async/await, LINQ, and dependency injection.

_This cheat sheet covers C# versions through C# 11.0 and .NET 6+_
