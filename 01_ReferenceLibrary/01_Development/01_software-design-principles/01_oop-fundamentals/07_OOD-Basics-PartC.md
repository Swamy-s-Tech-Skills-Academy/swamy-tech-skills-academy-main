# **OOD in C# with Class Diagrams** - Part C

**Learning Level**: Intermediate

**Prerequisites**: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Part C of 3 - OOD Basics

## 🎯 Learning Objectives

By the end of this session, you will

- Master complete OOD relationship modeling
- Understand realization and interface-based design
- Apply all OOD relationship types in integrated solutions
- Evaluate relationship selection based on design goals

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

## ```csharp- **Class Diagram**: [Class Diagram for Car](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuU9BoIhEIImk5D0e5L9Bo2vEpK_oiy9Ep4DiIW_8p4L9Q0dCJ4HMLtLKXL93qD__cCIFPMEx9bUsKc1FpjIFpmIQZJYIMZ3LtA4ZDA3n0000)

### Part C of 3

## Previous: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)

### **5. Aggregation**





```plantuml

@startuml
class Team {
```csharp
+Players : List`Player`
```csharp
}
class Player {
```csharp
+Name : String
```csharp
}
Team o-- Player
@enduml
```csharp---

### **6. Composition**




```plantuml

@startuml
class Library {
```csharp
+Books : List`Book`
```csharp
```csharp
+AddBook(Book) : void
```csharp
}
class Book {
```csharp
+Title : String
```csharp
}
Library *-- Book
@enduml
```csharp---

### **7. Inheritance**




```plantuml

@startuml
class Vehicle {
```csharp
+Speed : int
```csharp
```csharp
+Move() : void
```csharp
}
class Bicycle
Vehicle `|-- Bicycle
@enduml
```csharp---

### **8. Dependency**




```plantuml

@startuml
class Engine {
```csharp
+Start() : void
```csharp
}
class Car {
```csharp
+Car(Engine)
```csharp
```csharp
+StartCar() : void
```csharp
}
Car ..` Engine
@enduml
```csharp---

### **9. Realization**




```plantuml

@startuml
interface IVehicle {
```csharp
+Drive() : void
```csharp
}
class Car {
```csharp
+Drive() : void
```csharp
}
IVehicle <|.. Car
@enduml
```

---

### Steps to View

1. Copy one of the PlantUML scripts

1. Paste it into the online editor ([PlantText](https://www.planttext.com/)).
1. Generate the UML diagram.

Let me know if you need help with setup or any specific part of this process!

## 🔗 Related Topics

### **Prerequisites**

- [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)

### **Builds Upon**

- Complete OOD basics series
- Design pattern readiness

### **Enables Next Steps**

- **Next**: [08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**

- **Patterns**: [Design Patterns](../03_Design-Patterns/)
