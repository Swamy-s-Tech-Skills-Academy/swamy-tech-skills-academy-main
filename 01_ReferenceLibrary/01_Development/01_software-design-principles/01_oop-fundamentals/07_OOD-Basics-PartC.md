# **OOD in C# with Class Diagrams** - Part C

Object-Oriented Design (OOD) in C# revolves around designing systems by representing real-world entities as objects. Below is an explanation of key OOD concepts, each illustrated with C# examples and accompanied by class diagram links.

---

## Reference

> 1. <https://www.visual-paradigm.com/guide/uml-unified-modeling-language/uml-class-diagram-tutorial/>
> 1. <https://www.plantuml.com/plantuml/uml/SyfFKj2rKt3CoKnELR1Io4ZDoSa700002>

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

**Part C of 3**

Previous: [07_OOD-Basics-PartB.md](07_OOD-Basics-PartB.md)

---

### **5. Aggregation**

```plantuml
@startuml
class Team {
    +Players : List<Player>
}

class Player {
    +Name : String
}

Team o-- Player
@enduml
```

---

### **6. Composition**

```plantuml
@startuml
class Library {
    +Books : List<Book>
    +AddBook(Book) : void
}

class Book {
    +Title : String
}

Library *-- Book
@enduml
```

---

### **7. Inheritance**

```plantuml
@startuml
class Vehicle {
    +Speed : int
    +Move() : void
}

class Bicycle

Vehicle <|-- Bicycle
@enduml
```

---

### **8. Dependency**

```plantuml
@startuml
class Engine {
    +Start() : void
}

class Car {
    +Car(Engine)
    +StartCar() : void
}

Car ..> Engine
@enduml
```

---

### **9. Realization**

```plantuml
@startuml
interface IVehicle {
    +Drive() : void
}

class Car {
    +Drive() : void
}

IVehicle <|.. Car
@enduml
```

---

### Steps to View

1. Copy one of the PlantUML scripts.
2. Paste it into the online editor ([PlantText](https://www.planttext.com/)).
3. Generate the UML diagram.

Let me know if you need help with setup or any specific part of this process!
