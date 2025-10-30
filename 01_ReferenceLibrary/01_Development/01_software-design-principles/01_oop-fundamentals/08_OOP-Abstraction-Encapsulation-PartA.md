# OOP Abstraction and Encapsulation - Part A

**Learning Level**: Intermediate

**Prerequisites**: OOP fundamentals knowledge
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Part A of 3 - Abstraction & Encapsulation

## 🎯 Learning Objectives

By the end of this session, you will

- [Add specific learning objectives]

---
By the end of this 27-minute session, you will:

- Understand the fundamental differences between abstraction and encapsulation
- Apply both principles effectively in object-oriented design
- Recognize when and how to use each principle for better code organization

**Abstraction** and **Encapsulation** are two fundamental principles of Object-Oriented Programming (OOP), and while they are closely related, they serve different purposes. Here's a comparison:

---

### Part A of 3

## Next: [08_OOP-Abstraction-Encapsulation-PartB.md](08_OOP-Abstraction-Encapsulation-PartB.md)

## **Abstraction**

### Definition

- **Hiding implementation details** and exposing only the essential features of an object

- Focuses on **what an object does**, not **how it does it**.

### Key Points

1. **Purpose**: Simplify complex systems by showing only relevant data to the user.

1. **Implementation**: Achieved using **abstract classes** or **interfaces** in languages like C# and Java.
1. **Use Case**: When you want to define behavior without worrying about how it is implemented.
1. **Example**:

   - A `Vehicle` class exposes methods like `Start()` or `Stop()`, but the internal workings of the engine are hidden from the user.

### #### Code Example (C#):**

```csharp
abstract class Shape {
```csharp
public abstract double GetArea(); // Abstract method: must be implemented in derived classes
```csharp
}
class Circle : Shape {
```csharp
private double radius;
```csharp
```csharp
public Circle(double radius) {
```csharp
```csharp
    this.radius = radius;
```csharp
    }
```csharp
public override double GetArea() {
```csharp
```csharp
    return Math.PI *radius* radius; // Implementation specific to Circle
```csharp
    }
}
class Program {
```csharp
static void Main() {
```csharp
```csharp
    Shape shape = new Circle(5);
```csharp
```csharp
    Console.WriteLine($"Area: {shape.GetArea()}"); // Only GetArea() is exposed
```csharp
    }
}

```csharp
---

## **Encapsulation**

### Definition 2





- **Restricting access** to certain components of an object and bundling data with methods that operate on it

- Focuses on **how data is protected** and controlled.

### Key Points





1. **Purpose**: Safeguard object data and prevent unauthorized access or modification.

1. **Implementation**: Achieved using **access modifiers** like `private`, `protected`, and `public`.
1. **Use Case**: When you want to control or validate how external entities interact with the internal state of an object.
1. **Example**:

   - A `BankAccount` class restricts direct access to its `balance` field but allows controlled access through methods like `Deposit()` or `Withdraw()`.

### #### Code Example (C#):** 2





```csharp
class BankAccount {
```csharp
private double balance; // Encapsulated field
```csharp
```csharp
public double GetBalance() {
```csharp
```csharp
    return balance; // Controlled access
```csharp
    }
```csharp
public void Deposit(double amount) {
```csharp
```csharp
    if (amount > 0) {
```csharp
```csharp
        balance += amount; // Validation logic
```csharp
```csharp
    }
```csharp
    }
```csharp
public void Withdraw(double amount) {
```csharp
```csharp
    if (amount > 0 && amount <= balance) {
```csharp
```csharp
        balance -= amount; // Validation logic
```csharp
```csharp
    }
```csharp
    }
}
class Program {
```csharp
static void Main() {
```csharp
```csharp
    BankAccount account = new BankAccount();
```csharp
```csharp
    account.Deposit(100);
```csharp
```csharp
    Console.WriteLine($"Balance: {account.GetBalance()}");
```csharp
```csharp
    account.Withdraw(50);
```csharp
```csharp
    Console.WriteLine($"Balance: {account.GetBalance()}");
```csharp
    }
}

```csharp
---

## **Comparison**

| Aspect             | **Abstraction**                                                           | **Encapsulation**                                                          |

| ------------------ | ------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| **Focus**          | Hiding implementation details and exposing functionality.                 | Hiding data and protecting it from unauthorized access.                    |
| **Purpose**        | Simplify the interface and show only what is necessary.                   | Protect the integrity of the data.                                         |
| **Implementation** | Achieved using **abstract classes**, **interfaces**, or **polymorphism**. | Achieved using **access modifiers** and **getters/setters**.               |
| **Example**        | Only exposing `GetArea()` method in a `Shape` class.                      | Restricting direct access to the `balance` field in a `BankAccount` class. |

---

### **In a Nutshell**





- **Abstraction** is about **hiding the complexity** of implementation

- **Encapsulation** is about **hiding the object's data** and controlling access.

Both principles are complementary and often work together in designing robust and secure applications.

## Here's a detailed explanation of **OOP in C#**, covering its core principles with examples and comparisons

## **Object-Oriented Programming (OOP) in C#**

OOP is a programming paradigm based on the concept of objects, which encapsulate data and behavior. C# is inherently an object-oriented language, and its design supports the following key principles

---

### **1. Class**





- **Definition**: A blueprint for creating objects. It defines the structure and behavior (data members and methods) that the objects of the class will have

- **Key Points**:

  - Contains fields, properties, methods, constructors, etc.
- Supports access modifiers like `public`, `private`, and `protected`.

### **Example**





```csharp
class Car {
```csharp
public string Make { get; set; }
```csharp
```csharp
public string Model { get; set; }
```csharp
```csharp
public int Year { get; set; }
```csharp
```csharp
public void DisplayInfo() {
```csharp
```csharp
    Console.WriteLine($"{Year} {Make} {Model}");
```csharp
    }
}
class Program {
```csharp
static void Main() {
```csharp
```csharp
    Car car = new Car { Make = "Toyota", Model = "Camry", Year = 2022 };
```csharp
```csharp
    car.DisplayInfo(); // Output: 2022 Toyota Camry
```csharp

## 🔗 Related Topics

### **Prerequisites**
- [07_OOD-Basics-PartC.md](07_OOD-Basics-PartC.md)
- Understanding of OOP pillars

### **Builds Upon**
- [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
- Design principles

### **Enables Next Steps**
- **Next**: [08_OOP-Abstraction-Encapsulation-PartB.md](08_OOP-Abstraction-Encapsulation-PartB.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **Advanced**: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
