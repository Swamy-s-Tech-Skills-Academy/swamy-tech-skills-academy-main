# OOP Abstraction and Encapsulation - Part B

**Learning Level**: Intermediate

**Prerequisites**: [08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Part B of 3 - Abstraction & Encapsulation

## 🎯 Learning Objectives

By the end of this session, you will

- [Add specific learning objectives]

---
By the end of this 27-minute session, you will:

- Understand the fundamental differences between abstraction and encapsulation
- Apply both principles effectively in object-oriented design
- Recognize when and how to use each principle for better code organization

**Abstraction** and **Encapsulation** are two fundamental principles of Object-Oriented Programming (OOP), and while they are closely related, they serve different purposes. Here's a comparison:

---

### Part B of 3

Previous: [08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)

## Next: [08_OOP-Abstraction-Encapsulation-PartC.md](08_OOP-Abstraction-Encapsulation-PartC.md)

    }

}

```csharp---

### **2. Generalization**





- **Definition**: The process of extracting shared characteristics from two or more classes to create a generalized parent class

- **Purpose**: Helps in code reuse and abstraction.

### **Example**





```csharp

class Vehicle {
```csharp
public string Make { get; set; }
```csharp
```csharp
public string Model { get; set; }
```csharp
```csharp
public void Start() {
```csharp
```csharp
    Console.WriteLine("Vehicle started.");
```csharp
    }
}
class Car : Vehicle {
```csharp
public int Doors { get; set; }
```csharp
}
class Motorcycle : Vehicle {
```csharp
public bool HasSidecar { get; set; }
```csharp
}

```csharp---

### **3. Specialization**





- **Definition**: Adding more specific features to a subclass that are not present in the parent class
  - **Purpose**: Represents the unique properties of a derived class.

### **Example**




```csharp

class Vehicle {
```csharp
public string Make { get; set; }
```csharp
```csharp
public string Model { get; set; }
```csharp
}
class Car : Vehicle {
```csharp
public int Doors { get; set; } // Specialization for cars
```csharp
}

```csharp---

### **4. Association**





- **Definition**: A relationship between two classes that allows one object to use another
  - **Types**:

  - One-to-One
  - One-to-Many
  - Many-to-Many

### **Example**




```csharp

class Driver {
```csharp
public string Name { get; set; }
```csharp
}
class Car {
```csharp
public Driver Driver { get; set; } // Association
```csharp
```csharp
public void AssignDriver(Driver driver) {
```csharp
```csharp
    this.Driver = driver;
```csharp
    }
}

```csharp---

### **5. Aggregation (Has-A Relationship - Weak)**





- **Definition**: A special form of association where one class contains another as part of its attributes, but the contained object can exist independently

### **Example** 2




```csharp

class Engine {
```csharp
public string Type { get; set; }
```csharp
}
class Car {
```csharp
public Engine Engine { get; set; } // Aggregation
```csharp
}

```csharp---

### **6. Composition (Has-A Relationship - Strong)**





- **Definition**: A form of association where the contained object's lifecycle is tied to the lifecycle of the container object
  - **Key Difference from Aggregation**: In composition, if the container object is destroyed, the contained object is also destroyed.

### **Example**




```csharp

class Engine {
```csharp
public string Type { get; set; }
```csharp
}
class Car {
```csharp
private Engine engine = new Engine(); // Composition
```csharp
}

```csharp---

### **7. Inheritance (Is-A Relationship)**





- **Definition**: A mechanism by which one class can acquire properties and methods of another class
  - **Purpose**: Enables code reuse and supports polymorphism.

### **Example**




```csharp

class Animal {
```csharp
public void Eat() {
```csharp
```csharp
    Console.WriteLine("Eating...");
```csharp
    }
}
class Dog : Animal {
```csharp
public void Bark() {
```csharp
```csharp
    Console.WriteLine("Barking...");
```csharp
    }
}
class Program {
```csharp
static void Main() {
```csharp
```csharp
    Dog dog = new Dog();
```csharp
```csharp
    dog.Eat(); // From Animal class
```csharp
```csharp
    dog.Bark(); // From Dog class
```csharp
    }
}

```csharp
---

## 🔗 Related Topics

### **Prerequisites**
- [08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)

### **Builds Upon**
- Abstraction fundamentals Part A
- Encapsulation patterns

### **Enables Next Steps**
- **Next**: [08_OOP-Abstraction-Encapsulation-PartC.md](08_OOP-Abstraction-Encapsulation-PartC.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **Design Patterns**: [Design Patterns](../03_Design-Patterns/)
