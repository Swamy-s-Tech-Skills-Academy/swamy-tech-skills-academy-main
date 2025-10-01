# SOLID Principles Quick## SRP Definition

A class should have only ONE reason to change.Reference 🎯

> **Quick Access**: Essen## OCP Definition

Open for extension, closed for modification.ial principles for clean, maintainable code  

>## LSP Definition

Subclasses must be substitutable for their base classes.**Context**: Code reviews, mentoring, .NET development, interview prep  
> **Last Updated**: Week 2 Implementation

---

## 📋 **At-a-Glance Summary**

| Principle | Focus                 | Key Question                         | Memory Aid                                  |
| --------- | --------------------- | ------------------------------------ | ------------------------------------------- |
| **S**RP   | Single Responsibility | "What's this class's ONE job?"       | One class, one purpose                      |
| **O**CP   | Open/Closed           | "Can I extend without editing?"      | Open for extension, closed for modification |
| **L**SP   | Liskov Substitution   | "Can subclasses replace the parent?" | Child must honor parent's contract          |
| **I**SP   | Interface Segregation | "Do I need all these methods?"       | Split fat interfaces into lean ones         |
| **D**IP   | Dependency Inversion  | "Am I depending on abstractions?"    | Depend on interfaces, not concrete classes  |

---

## 🎯 **1. Single Responsibility Principle (SRP)**

### Definition

**A class should have only ONE reason to change**

### Quick Check

- If you can describe your class with "AND", it's doing too much
- Each class = one business concept or technical concern

### C# Example

```csharp
// ❌ Violates SRP - UserService does too much
public class UserService {
    public User GetUser(int id) { /* database logic */ }
    public void SendWelcomeEmail(User user) { /* email logic */ }
    public string ValidateUser(User user) { /* validation logic */ }
}

// ✅ Follows SRP - Separated concerns
public class UserRepository {
    public User GetUser(int id) { /* database logic */ }
}

public class EmailService {
    public void SendWelcomeEmail(User user) { /* email logic */ }
}

public class UserValidator {
    public string ValidateUser(User user) { /* validation logic */ }
}
```

### 🎯 **ShyvnTech Application**

- Separate AI model logic from Flask API controllers
- Keep Power BI visualization separate from data retrieval

---

## 🔓 **2. Open/Closed Principle (OCP)**

### Definition

**Open for extension, closed for modification**

### Quick Check

- Can you add new features without changing existing code?
- Are you using interfaces and inheritance effectively?

### C# Example

```csharp
// ✅ OCP-compliant payment system
public interface IPaymentProcessor {
    bool ProcessPayment(decimal amount);
}

public class CreditCardProcessor : IPaymentProcessor {
    public bool ProcessPayment(decimal amount) {
        // Credit card logic
        return true;
    }
}

public class PayPalProcessor : IPaymentProcessor {
    public bool ProcessPayment(decimal amount) {
        // PayPal logic
        return true;
    }
}

// Adding Stripe? No changes to existing code!
public class StripeProcessor : IPaymentProcessor {
    public bool ProcessPayment(decimal amount) {
        // Stripe logic
        return true;
    }
}
```

### 🎯 **ShyvnTech Application**

- Plugin architecture for coaching modules
- Extensible AI model providers without changing core logic

---

## 🔄 **3. Liskov Substitution Principle (LSP)**

### Definition

**Subclasses must be substitutable for their parent class**

### Quick Check

- Can you use a subclass wherever the parent is expected?
- Does the subclass honor the parent's contract and behavior?

### C# Example

```csharp
// ✅ LSP-compliant shape hierarchy
public abstract class Shape {
    public abstract double CalculateArea();
}

public class Rectangle : Shape {
    public double Width { get; set; }
    public double Height { get; set; }

    public override double CalculateArea() {
        return Width * Height;
    }
}

public class Circle : Shape {
    public double Radius { get; set; }

    public override double CalculateArea() {
        return Math.PI * Radius * Radius;
    }
}

// Client code works with any Shape
public void PrintArea(Shape shape) {
    Console.WriteLine($"Area: {shape.CalculateArea()}");
}
```

### ❌ **LSP Violation Example**

```csharp
// Don't do this - Square that breaks Rectangle behavior
public class Square : Rectangle {
    public override double Width {
        set { base.Width = base.Height = value; }
    }
    // This violates expected Rectangle behavior!
}
```

### 🎯 **ShyvnTech Application**

- Consistent behavior across different AI model implementations
- Interchangeable data source adapters

---

## 🔧 **4. Interface Segregation Principle (ISP)**

### Definition

**Clients shouldn't depend on interfaces they don't use**

### Quick Check

- Are your interfaces focused and lean?
- Do implementing classes use ALL interface methods?

### C# Example

```csharp
// ❌ Fat interface - violates ISP
public interface IWorker {
    void Work();
    void Eat();
    void Sleep();
}

// ✅ Segregated interfaces
public interface IWorkable {
    void Work();
}

public interface IFeedable {
    void Eat();
}

public interface IRestable {
    void Sleep();
}

// Implementations use only what they need
public class Human : IWorkable, IFeedable, IRestable {
    public void Work() { /* human work */ }
    public void Eat() { /* human eat */ }
    public void Sleep() { /* human sleep */ }
}

public class Robot : IWorkable {
    public void Work() { /* robot work */ }
    // Robot doesn't need to eat or sleep!
}
```

### 🎯 **ShyvnTech Application**

- Separate interfaces for different AI capabilities (text, image, audio)
- Focused data access interfaces per domain

---

## ⬆️ **5. Dependency Inversion Principle (DIP)**

### Definition

**Depend on abstractions, not concretions**

### Quick Check

- Are you injecting dependencies rather than newing them up?
- Do your classes depend on interfaces rather than concrete classes?

### C# Example

```csharp
// ❌ Violates DIP - depends on concrete class
public class OrderService {
    private EmailService _emailService = new EmailService(); // Tight coupling!

    public void ProcessOrder(Order order) {
        // Process order logic
        _emailService.SendConfirmation(order);
    }
}

// ✅ Follows DIP - depends on abstraction
public class OrderService {
    private readonly INotificationService _notificationService;

    public OrderService(INotificationService notificationService) {
        _notificationService = notificationService; // Dependency injection
    }

    public void ProcessOrder(Order order) {
        // Process order logic
        _notificationService.SendConfirmation(order);
    }
}

public interface INotificationService {
    void SendConfirmation(Order order);
}
```

### 🎯 **ShyvnTech Application**

- Injectable AI model services
- Configurable data storage providers

---

## 🚀 **Quick Decision Tree**

```text
Writing new code? Ask yourself:

1. "What's this class responsible for?"
   → If more than one thing, split it (SRP)

2. "Will I need to modify this to add features?"
   → If yes, extract interfaces (OCP)

3. "Can I substitute any subclass for the parent?"
   → If no, fix the hierarchy (LSP)

4. "Does this interface force unused methods?"
   → If yes, split the interface (ISP)

5. "Am I newing up dependencies in constructors?"
   → If yes, inject them instead (DIP)
```

---

## 🎯 **Mentoring Quick Checks**

### Code Review Checklist

- [ ] Each class has a single, clear purpose
- [ ] New features can be added without modifying existing code
- [ ] Inheritance hierarchies work polymorphically
- [ ] Interfaces are focused and cohesive
- [ ] Dependencies are injected, not instantiated

### Interview Questions You Can Now Answer

1. "Explain SOLID principles with C# examples"
2. "How do you ensure your code is maintainable?"
3. "What's the difference between ISP and SRP?"
4. "How do you design for extensibility?"

---

## 📚 **Related Quick References**

- [Enterprise SOLID Principles](../../07_Enterprise-Architecture/01_Architecture-Principles/01_Enterprise-SOLID-Principles.md) - Architectural governance application
- [Design Patterns Decision Matrix](DESIGN_PATTERNS_QUICK_REF.md)
- [Architecture Patterns Overview](ARCHITECTURE_PATTERNS_MATRIX.md)
- [System Design Checklist](SYSTEM_DESIGN_CHECKLIST.md)
- [Product Delivery Excellence](../../08_Product-Delivery/01_Product-Delivery-Excellence.md) - Business value delivery

---

**💡 Pro Tip**: Print this out and keep it handy during code reviews and mentoring sessions. SOLID principles are the foundation for all other architectural concepts!
