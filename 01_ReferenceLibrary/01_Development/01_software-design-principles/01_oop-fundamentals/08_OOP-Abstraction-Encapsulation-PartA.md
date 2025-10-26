# OOP Abstraction and Encapsulation - Part A\n\n**Learning Level**: Intermediate

**Prerequisites**: OOP fundamentals knowledge
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Part A of 3 - Abstraction & Encapsulation

## 🎯 Learning Objectives\n\nBy the end of this session, you will

- [Add specific learning objectives]

---
By the end of this 27-minute session, you will:

- Understand the fundamental differences between abstraction and encapsulation
- Apply both principles effectively in object-oriented design
- Recognize when and how to use each principle for better code organization\n\n**Abstraction** and **Encapsulation** are two fundamental principles of Object-Oriented Programming (OOP), and while they are closely related, they serve different purposes. Here's a comparison:

---

### Part A of 3

## Next: [08_OOP-Abstraction-Encapsulation-PartB.md](08_OOP-Abstraction-Encapsulation-PartB.md)

## **Abstraction**

### Definition

\n\n\n\n- **Hiding implementation details** and exposing only the essential features of an object

- Focuses on **what an object does**, not **how it does it**.\n\n### Key Points

\n\n\n\n1. **Purpose**: Simplify complex systems by showing only relevant data to the user.

1. **Implementation**: Achieved using **abstract classes** or **interfaces** in languages like C# and Java.
1. **Use Case**: When you want to define behavior without worrying about how it is implemented.
1. **Example**:\n\n   - A `Vehicle` class exposes methods like `Start()` or `Stop()`, but the internal workings of the engine are hidden from the user.\n\n### #### Code Example (C#):**

\n\n\n\n```csharp
abstract class Shape {
```csharp\npublic abstract double GetArea(); // Abstract method: must be implemented in derived classes\n```csharp\n}
class Circle : Shape {
```csharp\nprivate double radius;\n```csharp\n```csharp\npublic Circle(double radius) {\n```csharp\n```csharp\n    this.radius = radius;\n```csharp\n    }
```csharp\npublic override double GetArea() {\n```csharp\n```csharp\n    return Math.PI *radius* radius; // Implementation specific to Circle\n```csharp\n    }
}
class Program {
```csharp\nstatic void Main() {\n```csharp\n```csharp\n    Shape shape = new Circle(5);\n```csharp\n```csharp\n    Console.WriteLine($"Area: {shape.GetArea()}"); // Only GetArea() is exposed\n```csharp\n    }
}\n\n```csharp\n---

## **Encapsulation**

### Definition 2

\n\n\n\n- **Restricting access** to certain components of an object and bundling data with methods that operate on it

- Focuses on **how data is protected** and controlled.\n\n### Key Points

\n\n\n\n1. **Purpose**: Safeguard object data and prevent unauthorized access or modification.

1. **Implementation**: Achieved using **access modifiers** like `private`, `protected`, and `public`.
1. **Use Case**: When you want to control or validate how external entities interact with the internal state of an object.
1. **Example**:\n\n   - A `BankAccount` class restricts direct access to its `balance` field but allows controlled access through methods like `Deposit()` or `Withdraw()`.\n\n### #### Code Example (C#):** 2

\n\n\n\n```csharp
class BankAccount {
```csharp\nprivate double balance; // Encapsulated field\n```csharp\n```csharp\npublic double GetBalance() {\n```csharp\n```csharp\n    return balance; // Controlled access\n```csharp\n    }
```csharp\npublic void Deposit(double amount) {\n```csharp\n```csharp\n    if (amount > 0) {\n```csharp\n```csharp\n        balance += amount; // Validation logic\n```csharp\n```csharp\n    }\n```csharp\n    }
```csharp\npublic void Withdraw(double amount) {\n```csharp\n```csharp\n    if (amount > 0 && amount <= balance) {\n```csharp\n```csharp\n        balance -= amount; // Validation logic\n```csharp\n```csharp\n    }\n```csharp\n    }
}
class Program {
```csharp\nstatic void Main() {\n```csharp\n```csharp\n    BankAccount account = new BankAccount();\n```csharp\n```csharp\n    account.Deposit(100);\n```csharp\n```csharp\n    Console.WriteLine($"Balance: {account.GetBalance()}");\n```csharp\n```csharp\n    account.Withdraw(50);\n```csharp\n```csharp\n    Console.WriteLine($"Balance: {account.GetBalance()}");\n```csharp\n    }
}\n\n```csharp\n---

## **Comparison**\n\n| Aspect             | **Abstraction**                                                           | **Encapsulation**                                                          |

| ------------------ | ------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| **Focus**          | Hiding implementation details and exposing functionality.                 | Hiding data and protecting it from unauthorized access.                    |
| **Purpose**        | Simplify the interface and show only what is necessary.                   | Protect the integrity of the data.                                         |
| **Implementation** | Achieved using **abstract classes**, **interfaces**, or **polymorphism**. | Achieved using **access modifiers** and **getters/setters**.               |
| **Example**        | Only exposing `GetArea()` method in a `Shape` class.                      | Restricting direct access to the `balance` field in a `BankAccount` class. |\n\n---

### **In a Nutshell**

\n\n\n\n- **Abstraction** is about **hiding the complexity** of implementation

- **Encapsulation** is about **hiding the object's data** and controlling access.\n\nBoth principles are complementary and often work together in designing robust and secure applications.

## Here's a detailed explanation of **OOP in C#**, covering its core principles with examples and comparisons

## **Object-Oriented Programming (OOP) in C#**\n\nOOP is a programming paradigm based on the concept of objects, which encapsulate data and behavior. C# is inherently an object-oriented language, and its design supports the following key principles

---

### **1. Class**

\n\n\n\n- **Definition**: A blueprint for creating objects. It defines the structure and behavior (data members and methods) that the objects of the class will have

- **Key Points**:\n\n  - Contains fields, properties, methods, constructors, etc.
- Supports access modifiers like `public`, `private`, and `protected`.

### **Example**

\n\n\n\n```csharp
class Car {
```csharp\npublic string Make { get; set; }\n```csharp\n```csharp\npublic string Model { get; set; }\n```csharp\n```csharp\npublic int Year { get; set; }\n```csharp\n```csharp\npublic void DisplayInfo() {\n```csharp\n```csharp\n    Console.WriteLine($"{Year} {Make} {Model}");\n```csharp\n    }
}
class Program {
```csharp\nstatic void Main() {\n```csharp\n```csharp\n    Car car = new Car { Make = "Toyota", Model = "Camry", Year = 2022 };\n```csharp\n```csharp\n    car.DisplayInfo(); // Output: 2022 Toyota Camry\n```csharp\n
