# OOP Abstraction and Encapsulation - Part C\n\n**Learning Level**: Intermediate

**Prerequisites**: [08_OOP-Abstraction-Encapsulation-PartB.md](08_OOP-Abstraction-Encapsulation-PartB.md)
**Estimated Time**: 27 minutes (focused learning session)
**Series**: Part C of 3 - Abstraction & Encapsulation
---

## 🎯 Learning Objectives\n\nBy the end of this session, you will:
  - [Add specific learning objectives]
---
By the end of this 27-minute session, you will:
  - Understand the fundamental differences between abstraction and encapsulation
  - Apply both principles effectively in object-oriented design
  - Recognize when and how to use each principle for better code organization\n\n**Abstraction** and **Encapsulation** are two fundamental principles of Object-Oriented Programming (OOP), and while they are closely related, they serve different purposes. Here's a comparison:
---
### Part C of 3
Previous: [08_OOP-Abstraction-Encapsulation-PartB.md](08_OOP-Abstraction-Encapsulation-PartB.md)
---

### **8. Dependency**

\n\n\n\n- **Definition**: When one class relies on another to perform its operations
  - **Key Points**:\n\n  - Promotes loose coupling with dependency injection.\n\n### **Example**

\n\n\n\n```csharp
class Service {
```csharp\npublic void PerformOperation() {\n```csharp\n```csharp\n    Console.WriteLine("Operation performed.");\n```csharp\n    }
}
class Client {
```csharp\nprivate Service service;\n```csharp\n```csharp\npublic Client(Service service) {\n```csharp\n```csharp\n    this.service = service;\n```csharp\n    }
```csharp\npublic void Start() {\n```csharp\n```csharp\n    service.PerformOperation();\n```csharp\n    }
}\n\n```csharp---

### **9. Realization**

\n\n\n\n- **Definition**: A class implements the behavior defined by an interface
  - **Purpose**: Provides a contract that a class must adhere to.\n\n### **Example**

\n\n
```csharp\n\ninterface IShape {
```csharp\ndouble GetArea();\n```csharp\n}
class Circle : IShape {
```csharp\nprivate double radius;\n```csharp\n```csharp\npublic Circle(double radius) {\n```csharp\n```csharp\n    this.radius = radius;\n```csharp\n    }
```csharp\npublic double GetArea() {\n```csharp\n```csharp\n    return Math.PI * radius * radius;\n```csharp\n    }
}\n\n```csharp\n---

### **OOP Principles:**

\n\n\n\n| Principle         | Definition                                                | C# Implementation                  | Example                            |
| ----------------- | --------------------------------------------------------- | ---------------------------------- | ---------------------------------- |
| **Encapsulation** | Hiding internal state and exposing controlled access.     | Access Modifiers, Properties       | `private`, `public`, `protected`   |
| **Abstraction**   | Hiding implementation details and exposing functionality. | Abstract Classes, Interfaces       | `abstract`, `interface`            |
| **Inheritance**   | Acquiring properties and behavior of another class.       | Derived Classes                    | `class Dog : Animal`               |
| **Polymorphism**  | Using a single interface to represent different types.    | Method Overriding, Virtual Methods | `virtual`, `override`, `interface` |\n\n---

### UML Class Diagram for OOP in C #

\n\n

### **Description**

\n\n\n\n- A simple UML class diagram can represent relationships such as aggregation, composition, inheritance, and realization in the context of OOP in C#
  - Example: A `Vehicle` class (generalization) has subclasses like `Car` and `Motorcycle`, and an `Engine` class (composition) is part of the `Car`.\n\n### **Link to Learn UML**

\n\n\n\n- [Lucidchart UML Basics](https://www.lucidchart.com/pages/uml-class-diagram)
  - [PlantUML Online Tool](https://plantuml.com/class-diagram)\n\nIf you need further UML diagrams or detailed code examples for each principle, let me know!

Hereâ€™s the **PlantUML** text for a class diagram that illustrates the **OOP principles in C#**. It includes relationships like inheritance, composition, and realization:
```plantuml
@startuml
title OOP in C#
class Vehicle {
  - string Make
  - string Model
```csharp\n+ void Start()\n```csharp\n}
class Car {
  - int Doors
}
class Motorcycle {
  - bool HasSidecar
}
Vehicle <|-- Car
Vehicle <|-- Motorcycle
class Engine {
  - string Type
}
Car *-- Engine : Composition
interface IShape {
```csharp\n+ double GetArea()\n```csharp\n}
class Circle {
  - double Radius
```csharp\n+ double GetArea()\n```csharp\n}
IShape <|.. Circle : Realization
@enduml
```\n\n---

### **Explanation of the Diagram**

\n\n\n\n1. **Inheritance**:
  - `Vehicle` is the parent class, and `Car` and `Motorcycle` are child classes.
  - Represented by the `<|--` notation.

1. **Composition**:\n\n   - `Car` contains an `Engine`, indicating a "has-a (strong)" relationship.
  - Represented by the `*--` notation.

2. **Realization**:\n\n   - `Circle` implements the `IShape` interface.
  - Represented by the `<|..` notation.

3. **Class Members**:\n\n   - Fields and methods are specified within classes.
  - `+` denotes public, `-` denotes private.
