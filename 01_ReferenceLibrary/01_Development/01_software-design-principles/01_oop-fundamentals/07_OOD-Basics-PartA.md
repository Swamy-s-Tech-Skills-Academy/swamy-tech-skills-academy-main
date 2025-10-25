# **OOD in C# with Class Diagrams** - Part A\n\n**Learning Level**: Intermediate
**Prerequisites**: OOP fundamentals knowledge
**Estimated Time**: 27 minutes (focused learning session)
**Series**: Part A of 3 - OOD Basics
---
## 🎯 Learning Objectives\n\nBy the end of this session, you will:
- [Add specific learning objectives]
---
### **1. Class**\n\n\n\n- **Definition**: A blueprint for creating objects. It encapsulates fields and methods
- **C# Example**:\n\n  ```csharp
  public class Car
  {
```csharp\n  public string Make { get; set; }\n```csharp\n```csharp\n  public string Model { get; set; }\n```csharp\n```csharp\n  public void Drive()\n```csharp\n```csharp\n  {\n```csharp\n```csharp\n      Console.WriteLine("Driving the car...");\n```csharp\n```csharp\n  }\n```csharp\n  }
  ```csharp\n- **Class Diagram**: [Class Diagram for Car](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuU9BoIhEIImk5D0e5L9Bo2vEpK_oiy9Ep4DiIW_8p4L9Q0dCJ4HMLtLKXL93qD__cCIFPMEx9bUsKc1FpjIFpmIQZJYIMZ3LtA4ZDA3n0000)
---
**Part A of 3**
Next: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)
---
### **2. Generalization**\n\n\n\n- **Definition**: Extracting shared characteristics into a generalized superclass
- **C# Example**:\n\n  ```csharp
  public class Animal
  {
```csharp\n  public string Name { get; set; }\n```csharp\n```csharp\n  public void Eat() => Console.WriteLine($"{Name} is eating.");\n```csharp\n  }
  public class Dog : Animal { }
  public class Cat : Animal { }
  ```csharp\n- **Class Diagram**: [Class Diagram for Generalization](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4bLI0EmS4vAp2DKJZDyLa50bQGMKtXIkYLKJofEqfOeLfBa0000)
---
### **3. Specialization**\n\n\n\n- **Definition**: Extending a general class to add specific attributes or behaviors
- **C# Example**:\n\n  ```csharp
  public class ElectricCar : Car
  {
```csharp\n  public int BatteryCapacity { get; set; }\n```csharp\n```csharp\n  public void ChargeBattery() => Console.WriteLine("Charging the battery...");\n```csharp\n  }
  ```csharp\n- **Class Diagram**: [Class Diagram for Specialization](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuU9BoIhEIImk5D0e5L9Bo2vEpK_oiy9Ep4DiIW_8p4L9Q0dCJ4HMLpLKXL93qD__cCIFPMEx9bUsKc1FpjIFpmIQZJYIMZ3LtA4ZDA3n0000)
---
### **4. Association**\n\n\n\n- **Definition**: A "uses" relationship between classes where one interacts with another without ownership
- **C# Example**:\n\n  ```csharp
  public class Driver
  {
```csharp\n  public string Name { get; set; }\n```csharp\n  }
  public class Car
  {
```csharp\n  public Driver Driver { get; set; }\n```csharp\n  }
  ```csharp\n- **Class Diagram**: [Class Diagram for Association](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4rFIK0fN4vAp2DKJZDyLo50fPKJof0000)
---
### **5. Aggregation (Has-a â€“ Weak Ownership)**\n\n\n\n- **Definition**: A "has-a" relationship where contained objects exist independently
- **C# Example**:\n\n  ```csharp
  public class Team
  {
```csharp\n  public List`Player` Players { get; set; }\n```csharp\n  }
  public class Player
  {
```csharp\n  public string Name { get; set; }\n```csharp\n  }
  ```csharp\n- **Class Diagram**: [Class Diagram for Aggregation](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJYrBIL0jN4vAp2DKJZDyLo50jPKL0000)
---
### **6. Composition (Has-a â€“ Strong Ownership)**\n\n\n\n- **Definition**: A "has-a" relationship where contained objects are destroyed with the container
- **C# Example**:\n\n  ```csharp
  public class Library
  {
```csharp\n  public List`Book` Books { get; private set; } = new List`Book`();\n```csharp\n```csharp\n  public void AddBook(Book book) => Books.Add(book);\n```csharp\n  }
  public class Book
  {
```csharp\n  public string Title { get; set; }\n```csharp\n  }
  ```csharp\n- **Class Diagram**: [Class Diagram for Composition](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4rBIC0fN4vAp2DKJZDyLo50jPKKL0000)
---
### **7. Inheritance (Is-a)**\n\n\n\n- **Definition**: A "is-a" relationship where a subclass inherits properties and methods from a parent class
- **C# Example**:\n\n  ```csharp
  public class Vehicle
  {
```csharp\n  public int Speed { get; set; }\n```csharp\n```csharp\n  public void Move() => Console.WriteLine("Vehicle is moving...");\n```csharp\n  }
  public class Bicycle : Vehicle { }
  ```csharp\n- **Class Diagram**: [Class Diagram for Inheritance](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4rBIC0bN4vAp2DKJZDyLo50jPKUL0000)
---
### **8. Dependency**\n\n\n\n- **Definition**: A class depends on another class, often used in dependency injection
- **C# Example**:\n\n  ```csharp
  public class Engine
  {
```csharp\n  public void Start() => Console.WriteLine("Engine started.");\n```csharp\n  }