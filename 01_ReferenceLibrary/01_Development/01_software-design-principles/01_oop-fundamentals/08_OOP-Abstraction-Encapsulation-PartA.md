# OOP Abstraction and Encapsulation - Part A

**Learning Level**: Intermediate
**Prerequisites**: OOP fundamentals knowledge
**Estimated Time**: 27 minutes (focused learning session)
**Series**: Part A of 3 - Abstraction & Encapsulation

---

## 🎯 Learning Objectives

By the end of this session, you will:

- [Add specific learning objectives]

---
By the end of this 27-minute session, you will:

- Understand the fundamental differences between abstraction and encapsulation
- Apply both principles effectively in object-oriented design
- Recognize when and how to use each principle for better code organization

**Abstraction** and **Encapsulation** are two fundamental principles of Object-Oriented Programming (OOP), and while they are closely related, they serve different purposes. Here's a comparison:

---

**Part A of 3**

Next: [08_OOP-Abstraction-Encapsulation-PartB.md](08_OOP-Abstraction-Encapsulation-PartB.md)

---

## **Abstraction**

### Definition

- **Hiding implementation details** and exposing only the essential features of an object.
- Focuses on **what an object does**, not **how it does it**.

### Key Points

1. **Purpose**: Simplify complex systems by showing only relevant data to the user.
2. **Implementation**: Achieved using **abstract classes** or **interfaces** in languages like C# and Java.

3. **Use Case**: When you want to define behavior without worrying about how it is implemented.
4. **Example**:
   - A `Vehicle` class exposes methods like `Start()` or `Stop()`, but the internal workings of the engine are hidden from the user.

#### **Code Example (C#):**

```csharp
abstract class Shape {
    public abstract double GetArea(); // Abstract method: must be implemented in derived classes
}

class Circle : Shape {
    private double radius;

    public Circle(double radius) {
        this.radius = radius;
    }

    public override double GetArea() {
        return Math.PI * radius * radius; // Implementation specific to Circle
    }
}

class Program {
    static void Main() {
        Shape shape = new Circle(5);
        Console.WriteLine($"Area: {shape.GetArea()}"); // Only GetArea() is exposed
    }
}
```

---

## **Encapsulation**

### Definition

- **Restricting access** to certain components of an object and bundling data with methods that operate on it.
- Focuses on **how data is protected** and controlled.

### Key Points

1. **Purpose**: Safeguard object data and prevent unauthorized access or modification.
2. **Implementation**: Achieved using **access modifiers** like `private`, `protected`, and `public`.
3. **Use Case**: When you want to control or validate how external entities interact with the internal state of an object.
4. **Example**:
   - A `BankAccount` class restricts direct access to its `balance` field but allows controlled access through methods like `Deposit()` or `Withdraw()`.

#### **Code Example (C#):**

```csharp
class BankAccount {
    private double balance; // Encapsulated field

    public double GetBalance() {
        return balance; // Controlled access
    }

    public void Deposit(double amount) {
        if (amount > 0) {
            balance += amount; // Validation logic
        }
    }

    public void Withdraw(double amount) {
        if (amount > 0 && amount <= balance) {
            balance -= amount; // Validation logic
        }
    }
}

class Program {
    static void Main() {
        BankAccount account = new BankAccount();
        account.Deposit(100);
        Console.WriteLine($"Balance: {account.GetBalance()}");
        account.Withdraw(50);
        Console.WriteLine($"Balance: {account.GetBalance()}");
    }
}
```

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

- **Abstraction** is about **hiding the complexity** of implementation.
- **Encapsulation** is about **hiding the object's data** and controlling access.

Both principles are complementary and often work together in designing robust and secure applications.

Hereâ€™s a detailed explanation of **OOP in C#**, covering its core principles with examples and comparisons:

---

## **Object-Oriented Programming (OOP) in C#**

OOP is a programming paradigm based on the concept of objects, which encapsulate data and behavior. C# is inherently an object-oriented language, and its design supports the following key principles:

---

### **1. Class**

- **Definition**: A blueprint for creating objects. It defines the structure and behavior (data members and methods) that the objects of the class will have.
- **Key Points**:
  - Contains fields, properties, methods, constructors, etc.
  - Supports access modifiers like `public`, `private`, and `protected`.

#### **Example**

```csharp
class Car {
    public string Make { get; set; }
    public string Model { get; set; }
    public int Year { get; set; }

    public void DisplayInfo() {
        Console.WriteLine($"{Year} {Make} {Model}");
    }
}

class Program {
    static void Main() {
        Car car = new Car { Make = "Toyota", Model = "Camry", Year = 2022 };
        car.DisplayInfo(); // Output: 2022 Toyota Camry
