# **OOD in C# with Class Diagrams** - Part A

**Learning Level**: Intermediate

**Prerequisites**: OOP fundamentals knowledge
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Part A of 3 - OOD Basics

## 🎯 Learning Objectives

By the end of this session, you will

- Master fundamental OOD concepts with UML class diagrams
- Understand relationships: generalization, specialization, association
- Apply C# implementations of OOD principles
- Create class diagrams for real-world scenarios

---

### **1. Class**

- **Definition**: A blueprint for creating objects. It encapsulates fields and methods

- **C# Example**:

  ```csharp

  public class Car
  {

```csharp
  public string Make { get; set; }
```csharp
```csharp
  public string Model { get; set; }
```csharp
```csharp
  public void Drive()
```csharp
```csharp
  {
```csharp
```csharp
      Console.WriteLine("Driving the car...");
```csharp
```csharp
  }
```csharp
  }

## ```csharp
- **Class Diagram**: [Class Diagram for Car](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuU9BoIhEIImk5D0e5L9Bo2vEpK_oiy9Ep4DiIW_8p4L9Q0dCJ4HMLtLKXL93qD__cCIFPMEx9bUsKc1FpjIFpmIQZJYIMZ3LtA4ZDA3n0000)

### Part A of 3

## Next: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)

### **2. Generalization**





- **Definition**: Extracting shared characteristics into a generalized superclass

- **C# Example**:

  ```csharp

  public class Animal
  {
```csharp
  public string Name { get; set; }
```csharp
```csharp
  public void Eat() => Console.WriteLine($"{Name} is eating.");
```csharp
  }
  public class Dog : Animal { }
  public class Cat : Animal { }

## ```csharp
- **Class Diagram**: [Class Diagram for Generalization](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4bLI0EmS4vAp2DKJZDyLa50bQGMKtXIkYLKJofEqfOeLfBa0000)

### **3. Specialization**





- **Definition**: Extending a general class to add specific attributes or behaviors

- **C# Example**:

  ```csharp

  public class ElectricCar : Car
  {
```csharp
  public int BatteryCapacity { get; set; }
```csharp
```csharp
  public void ChargeBattery() => Console.WriteLine("Charging the battery...");
```csharp
  }

## ```csharp
- **Class Diagram**: [Class Diagram for Specialization](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuU9BoIhEIImk5D0e5L9Bo2vEpK_oiy9Ep4DiIW_8p4L9Q0dCJ4HMLpLKXL93qD__cCIFPMEx9bUsKc1FpjIFpmIQZJYIMZ3LtA4ZDA3n0000)

### **4. Association**





- **Definition**: A "uses" relationship between classes where one interacts with another without ownership

- **C# Example**:

  ```csharp

  public class Driver
  {
```csharp
  public string Name { get; set; }
```csharp
  }
  public class Car
  {
```csharp
  public Driver Driver { get; set; }
```csharp
  }

## ```csharp
- **Class Diagram**: [Class Diagram for Association](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4rFIK0fN4vAp2DKJZDyLo50fPKJof0000)

### **5. Aggregation (Has-a — Weak Ownership)**





- **Definition**: A "has-a" relationship where contained objects exist independently

- **C# Example**:

  ```csharp

  public class Team
  {
```csharp
  public List`Player` Players { get; set; }
```csharp
  }
  public class Player
  {
```csharp
  public string Name { get; set; }
```csharp
  }

## ```csharp
- **Class Diagram**: [Class Diagram for Aggregation](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJYrBIL0jN4vAp2DKJZDyLo50jPKL0000)

### **6. Composition (Has-a — Strong Ownership)**





- **Definition**: A "has-a" relationship where contained objects are destroyed with the container

- **C# Example**:

  ```csharp

  public class Library
  {
```csharp
  public List`Book` Books { get; private set; } = new List`Book`();
```csharp
```csharp
  public void AddBook(Book book) => Books.Add(book);
```csharp
  }
  public class Book
  {
```csharp
  public string Title { get; set; }
```csharp
  }

## ```csharp
- **Class Diagram**: [Class Diagram for Composition](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4rBIC0fN4vAp2DKJZDyLo50jPKKL0000)

### **7. Inheritance (Is-a)**





- **Definition**: A "is-a" relationship where a subclass inherits properties and methods from a parent class

- **C# Example**:

  ```csharp

  public class Vehicle
  {
```csharp
  public int Speed { get; set; }
```csharp
```csharp
  public void Move() => Console.WriteLine("Vehicle is moving...");
```csharp
  }
  public class Bicycle : Vehicle { }

## ```csharp
- **Class Diagram**: [Class Diagram for Inheritance](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4rBIC0bN4vAp2DKJZDyLo50jPKUL0000)

### **8. Dependency**





- **Definition**: A class depends on another class, often used in dependency injection

- **C# Example**:

  ```csharp

  public class Engine
  {
```csharp
  public void Start() => Console.WriteLine("Engine started.");
```csharp
  }

## 🔗 Related Topics

### **Prerequisites**

- [06_OOD-Learning-Plan-PartB.md](06_OOD-Learning-Plan-PartB.md)
- Completed OOP fundamentals

### **Builds Upon**

- Object-oriented design principles
- UML basics

### **Enables Next Steps**

- **Next**: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**

- **UML**: [UML Documentation](../23_UML/)
