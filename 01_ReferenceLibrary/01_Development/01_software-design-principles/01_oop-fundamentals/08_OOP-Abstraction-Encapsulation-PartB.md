# OOP Abstraction and Encapsulation - Part B\n\n**Learning Level**: Intermediate

**Prerequisites**: [08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Part B of 3 - Abstraction & Encapsulation

## 🎯 Learning Objectives\n\nBy the end of this session, you will

- [Add specific learning objectives]

---
By the end of this 27-minute session, you will:

- Understand the fundamental differences between abstraction and encapsulation
- Apply both principles effectively in object-oriented design
- Recognize when and how to use each principle for better code organization\n\n**Abstraction** and **Encapsulation** are two fundamental principles of Object-Oriented Programming (OOP), and while they are closely related, they serve different purposes. Here's a comparison:

---

### Part B of 3

Previous: [08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)

## Next: [08_OOP-Abstraction-Encapsulation-PartC.md](08_OOP-Abstraction-Encapsulation-PartC.md)\n\n    }

}\n\n```csharp---

### **2. Generalization**

\n\n\n\n- **Definition**: The process of extracting shared characteristics from two or more classes to create a generalized parent class

- **Purpose**: Helps in code reuse and abstraction.\n\n### **Example**

\n\n

```csharp\n\nclass Vehicle {
```csharp\npublic string Make { get; set; }\n```csharp\n```csharp\npublic string Model { get; set; }\n```csharp\n```csharp\npublic void Start() {\n```csharp\n```csharp\n    Console.WriteLine("Vehicle started.");\n```csharp\n    }
}
class Car : Vehicle {
```csharp\npublic int Doors { get; set; }\n```csharp\n}
class Motorcycle : Vehicle {
```csharp\npublic bool HasSidecar { get; set; }\n```csharp\n}\n\n```csharp---

### **3. Specialization**

\n\n\n\n- **Definition**: Adding more specific features to a subclass that are not present in the parent class
  - **Purpose**: Represents the unique properties of a derived class.\n\n### **Example**

\n\n
```csharp\n\nclass Vehicle {
```csharp\npublic string Make { get; set; }\n```csharp\n```csharp\npublic string Model { get; set; }\n```csharp\n}
class Car : Vehicle {
```csharp\npublic int Doors { get; set; } // Specialization for cars\n```csharp\n}\n\n```csharp---

### **4. Association**

\n\n\n\n- **Definition**: A relationship between two classes that allows one object to use another
  - **Types**:\n\n  - One-to-One
  - One-to-Many
  - Many-to-Many

### **Example**

\n\n
```csharp\n\nclass Driver {
```csharp\npublic string Name { get; set; }\n```csharp\n}
class Car {
```csharp\npublic Driver Driver { get; set; } // Association\n```csharp\n```csharp\npublic void AssignDriver(Driver driver) {\n```csharp\n```csharp\n    this.Driver = driver;\n```csharp\n    }
}\n\n```csharp---

### **5. Aggregation (Has-A Relationship - Weak)**

\n\n\n\n- **Definition**: A special form of association where one class contains another as part of its attributes, but the contained object can exist independently

### **Example** 2

\n\n
```csharp\n\nclass Engine {
```csharp\npublic string Type { get; set; }\n```csharp\n}
class Car {
```csharp\npublic Engine Engine { get; set; } // Aggregation\n```csharp\n}\n\n```csharp---

### **6. Composition (Has-A Relationship - Strong)**

\n\n\n\n- **Definition**: A form of association where the contained object's lifecycle is tied to the lifecycle of the container object
  - **Key Difference from Aggregation**: In composition, if the container object is destroyed, the contained object is also destroyed.\n\n### **Example**

\n\n
```csharp\n\nclass Engine {
```csharp\npublic string Type { get; set; }\n```csharp\n}
class Car {
```csharp\nprivate Engine engine = new Engine(); // Composition\n```csharp\n}\n\n```csharp---

### **7. Inheritance (Is-A Relationship)**

\n\n\n\n- **Definition**: A mechanism by which one class can acquire properties and methods of another class
  - **Purpose**: Enables code reuse and supports polymorphism.\n\n### **Example**

\n\n
```csharp\n\nclass Animal {
```csharp\npublic void Eat() {\n```csharp\n```csharp\n    Console.WriteLine("Eating...");\n```csharp\n    }
}
class Dog : Animal {
```csharp\npublic void Bark() {\n```csharp\n```csharp\n    Console.WriteLine("Barking...");\n```csharp\n    }
}
class Program {
```csharp\nstatic void Main() {\n```csharp\n```csharp\n    Dog dog = new Dog();\n```csharp\n```csharp\n    dog.Eat(); // From Animal class\n```csharp\n```csharp\n    dog.Bark(); // From Dog class\n```csharp\n    }
}\n\n```csharp\n---
