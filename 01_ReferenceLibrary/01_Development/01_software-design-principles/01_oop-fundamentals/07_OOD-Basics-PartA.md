# **OOD in C# with Class Diagrams** - Part A

**Learning Level**: Intermediate
**Prerequisites**: OOP fundamentals knowledge
**Estimated Time**: 27 minutes (focused learning session)
**Series**: Part A of 3 - OOD Basics

---

## 🎯 Learning Objectives

By the end of this session, you will:

- [Add specific learning objectives]

---

### **1. Class**

- **Definition**: A blueprint for creating objects. It encapsulates fields and methods.
- **C# Example**:

  ```csharp
  public class Car
  {
      public string Make { get; set; }
      public string Model { get; set; }

      public void Drive()
      {
          Console.WriteLine("Driving the car...");
      }
  }
  ```

- **Class Diagram**: [Class Diagram for Car](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuU9BoIhEIImk5D0e5L9Bo2vEpK_oiy9Ep4DiIW_8p4L9Q0dCJ4HMLtLKXL93qD__cCIFPMEx9bUsKc1FpjIFpmIQZJYIMZ3LtA4ZDA3n0000)

---

**Part A of 3**

Next: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)

---

### **2. Generalization**

- **Definition**: Extracting shared characteristics into a generalized superclass.
- **C# Example**:

  ```csharp
  public class Animal
  {
      public string Name { get; set; }
      public void Eat() => Console.WriteLine($"{Name} is eating.");
  }

  public class Dog : Animal { }
  public class Cat : Animal { }
  ```

- **Class Diagram**: [Class Diagram for Generalization](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4bLI0EmS4vAp2DKJZDyLa50bQGMKtXIkYLKJofEqfOeLfBa0000)

---

### **3. Specialization**

- **Definition**: Extending a general class to add specific attributes or behaviors.
- **C# Example**:

  ```csharp
  public class ElectricCar : Car
  {
      public int BatteryCapacity { get; set; }
      public void ChargeBattery() => Console.WriteLine("Charging the battery...");
  }
  ```

- **Class Diagram**: [Class Diagram for Specialization](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuU9BoIhEIImk5D0e5L9Bo2vEpK_oiy9Ep4DiIW_8p4L9Q0dCJ4HMLpLKXL93qD__cCIFPMEx9bUsKc1FpjIFpmIQZJYIMZ3LtA4ZDA3n0000)

---

### **4. Association**

- **Definition**: A "uses" relationship between classes where one interacts with another without ownership.
- **C# Example**:

  ```csharp
  public class Driver
  {
      public string Name { get; set; }
  }

  public class Car
  {
      public Driver Driver { get; set; }
  }
  ```

- **Class Diagram**: [Class Diagram for Association](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4rFIK0fN4vAp2DKJZDyLo50fPKJof0000)

---

### **5. Aggregation (Has-a â€“ Weak Ownership)**

- **Definition**: A "has-a" relationship where contained objects exist independently.
- **C# Example**:

  ```csharp
  public class Team
  {
      public List<Player> Players { get; set; }
  }

  public class Player
  {
      public string Name { get; set; }
  }
  ```

- **Class Diagram**: [Class Diagram for Aggregation](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJYrBIL0jN4vAp2DKJZDyLo50jPKL0000)

---

### **6. Composition (Has-a â€“ Strong Ownership)**

- **Definition**: A "has-a" relationship where contained objects are destroyed with the container.
- **C# Example**:

  ```csharp
  public class Library
  {
      public List<Book> Books { get; private set; } = new List<Book>();

      public void AddBook(Book book) => Books.Add(book);
  }

  public class Book
  {
      public string Title { get; set; }
  }
  ```

- **Class Diagram**: [Class Diagram for Composition](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4rBIC0fN4vAp2DKJZDyLo50jPKKL0000)

---

### **7. Inheritance (Is-a)**

- **Definition**: A "is-a" relationship where a subclass inherits properties and methods from a parent class.
- **C# Example**:

  ```csharp
  public class Vehicle
  {
      public int Speed { get; set; }
      public void Move() => Console.WriteLine("Vehicle is moving...");
  }

  public class Bicycle : Vehicle { }
  ```

- **Class Diagram**: [Class Diagram for Inheritance](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJ4rBIC0bN4vAp2DKJZDyLo50jPKUL0000)

---

### **8. Dependency**

- **Definition**: A class depends on another class, often used in dependency injection.
- **C# Example**:

  ```csharp
  public class Engine
  {
      public void Start() => Console.WriteLine("Engine started.");
  }
