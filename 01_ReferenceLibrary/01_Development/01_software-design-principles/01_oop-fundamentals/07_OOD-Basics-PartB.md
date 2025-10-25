# **OOD in C# with Class Diagrams** - Part B\n\n**Learning Level**: Intermediate

**Prerequisites**: [07_OOD-Basics-PartA.md](07_OOD-Basics-PartA.md)
**Estimated Time**: 27 minutes (focused learning session)
**Series**: Part B of 3 - OOD Basics
---

## 🎯 Learning Objectives\n\nBy the end of this session, you will

- [Add specific learning objectives]

---

### **1. Class**

\n\n\n\n- **Definition**: A blueprint for creating objects. It encapsulates fields and methods

- **C# Example**:\n\n  ```csharp

  public class Car
  {
```csharp\n  public string Make { get; set; }\n```csharp\n```csharp\n  public string Model { get; set; }\n```csharp\n```csharp\n  public void Drive()\n```csharp\n```csharp\n  {\n```csharp\n```csharp\n      Console.WriteLine("Driving the car...");\n```csharp\n```csharp\n  }\n```csharp\n  }

  ```csharp\n- **Class Diagram**: [Class Diagram for Car](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuU9BoIhEIImk5D0e5L9Bo2vEpK_oiy9Ep4DiIW_8p4L9Q0dCJ4HMLtLKXL93qD__cCIFPMEx9bUsKc1FpjIFpmIQZJYIMZ3LtA4ZDA3n0000)
---
### Part B of 3
Previous: [07_OOD-Basics-PartA.md](07_OOD-Basics-PartA.md)
Next: [07_OOD-Basics-PartC.md](07_OOD-Basics-PartC.md)
---
  public class Car
  {
```csharp\n  private Engine _engine;\n```csharp\n```csharp\n  public Car(Engine engine)\n```csharp\n```csharp\n  {\n```csharp\n```csharp\n      _engine = engine;\n```csharp\n```csharp\n  }\n```csharp\n```csharp\n  public void StartCar() => _engine.Start();\n```csharp\n  }
  ```csharp\n- **Class Diagram**: [Class Diagram for Dependency](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJYrBI40fN4vAp2DKJZDyLo50jPKVL0000)
---

### **9. Realization**

\n\n\n\n- **Definition**: When a class implements an interface, it "realizes" the behavior defined by the interface
  - **C# Example**:\n\n  ```csharp

  public interface IVehicle
  {
```csharp\n  void Drive();\n```csharp\n  }
  public class Car : IVehicle
  {
```csharp\n  public void Drive() => Console.WriteLine("Driving the car...");\n```csharp\n  }
  ```csharp- **Class Diagram**: [Class Diagram for Realization](https://www.plantuml.com/plantuml/uml/SoWkIImgAStDuKhEIImk5U9q54dCJYrBI40jN4vAp2DKJZDyLo50jPKXL0000)
---

### **Summary**

\n\n\n\nThese principles, combined with their corresponding diagrams, help design systems that are modular, reusable, and scalable. The class diagrams illustrate relationships, making it easier to visualize complex systems
The links I provided earlier use placeholders for online UML tools like PlantUML, which you can use to visualize class diagrams. Here's how you can generate and view them:

1. **Copy the PlantUML Code**:\n\n   Copy the provided code snippets and paste them into a PlantUML-compatible viewer.
2. **Online Editors**:\n\n   - Use [PlantText](https://www.planttext.com/) or [PlantUML Editor](https://plantuml.com/plantuml-editor).
  - Paste the PlantUML code into the editor, and it will render the diagram.

3. **Local Setup**:\n\n   If you prefer a local setup, install PlantUML:
  - Install [Java Runtime Environment (JRE)](https://www.oracle.com/java/technologies/javase-jre8-downloads.html).
  - Download the [PlantUML jar file](https://plantuml.com/download).
  - Run it locally to generate UML diagrams.
Here are updated PlantUML scripts you can use for each concept.
---

### **1. Class** 2

\n\n
```plantuml\n\n@startuml
class Car {
```csharp\n+Make : String\n```csharp\n```csharp\n+Model : String\n```csharp\n```csharp\n+Drive() : void\n```csharp\n}
@enduml
```csharp---

### **2. Generalization**

\n\n
```plantuml\n\n@startuml
class Animal {
```csharp\n+Name : String\n```csharp\n```csharp\n+Eat() : void\n```csharp\n}
class Dog
class Cat
Animal <|-- Dog
Animal <|-- Cat
@enduml
```csharp---

### **3. Specialization**

\n\n
```plantuml\n\n@startuml
class Car {
```csharp\n+Make : String\n```csharp\n```csharp\n+Model : String\n```csharp\n```csharp\n+Drive() : void\n```csharp\n}
class ElectricCar {
```csharp\n+BatteryCapacity : int\n```csharp\n```csharp\n+ChargeBattery() : void\n```csharp\n}
Car <|-- ElectricCar
@enduml
```csharp---

### **4. Association**

\n\n
```plantuml\n\n@startuml
class Driver {
```csharp\n+Name : String\n```csharp\n}
class Car {
```csharp\n+Driver : Driver\n```csharp\n}
Driver -- Car
@enduml
```\n\n---
