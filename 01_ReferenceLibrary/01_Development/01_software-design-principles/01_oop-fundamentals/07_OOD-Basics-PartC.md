# **OOD in C# with Class Diagrams** - Part C\n\n**Learning Level**: Intermediate

**Prerequisites**: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)
**Estimated Time**: 27 minutes (focused learning session)
## **Series**: Part C of 3 - OOD Basics
## 🎯 Learning Objectives\n\nBy the end of this session, you will

- [Add specific learning objectives]

---

### **1. Class**

\n\n\n\n- **Definition**: A blueprint for creating objects. It encapsulates fields and methods

- **C# Example**:\n\n  ```csharp

  public class Car
  {
```csharp\n  public string Make { get; set; }\n```csharp\n```csharp\n  public string Model { get; set; }\n```csharp\n```csharp\n  public void Drive()\n```csharp\n```csharp\n  {\n```csharp\n```csharp\n      Console.WriteLine("Driving the car...");\n```csharp\n```csharp\n  }\n```csharp\n  }

##   ```csharp- **Class Diagram**: [Class Diagram for Car](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuU9BoIhEIImk5D0e5L9Bo2vEpK_oiy9Ep4DiIW_8p4L9Q0dCJ4HMLtLKXL93qD__cCIFPMEx9bUsKc1FpjIFpmIQZJYIMZ3LtA4ZDA3n0000)
### Part C of 3
## Previous: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)
### **5. Aggregation**

\n\n
```plantuml\n\n@startuml
class Team {
```csharp\n+Players : List`Player`\n```csharp\n}
class Player {
```csharp\n+Name : String\n```csharp\n}
Team o-- Player
@enduml
```csharp---

### **6. Composition**

\n\n
```plantuml\n\n@startuml
class Library {
```csharp\n+Books : List`Book`\n```csharp\n```csharp\n+AddBook(Book) : void\n```csharp\n}
class Book {
```csharp\n+Title : String\n```csharp\n}
Library *-- Book
@enduml
```csharp---

### **7. Inheritance**

\n\n
```plantuml\n\n@startuml
class Vehicle {
```csharp\n+Speed : int\n```csharp\n```csharp\n+Move() : void\n```csharp\n}
class Bicycle
Vehicle `|-- Bicycle
@enduml
```csharp---

### **8. Dependency**

\n\n
```plantuml\n\n@startuml
class Engine {
```csharp\n+Start() : void\n```csharp\n}
class Car {
```csharp\n+Car(Engine)\n```csharp\n```csharp\n+StartCar() : void\n```csharp\n}
Car ..` Engine
@enduml
```csharp---

### **9. Realization**

\n\n
```plantuml\n\n@startuml
interface IVehicle {
```csharp\n+Drive() : void\n```csharp\n}
class Car {
```csharp\n+Drive() : void\n```csharp\n}
IVehicle <|.. Car
@enduml
```\n\n---

### Steps to View

\n\n\n\n1. Copy one of the PlantUML scripts

1. Paste it into the online editor ([PlantText](https://www.planttext.com/)).
1. Generate the UML diagram.\n\nLet me know if you need help with setup or any specific part of this process!
