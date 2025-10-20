# OOP Abstraction and Encapsulation - Part B

**Learning Level**: Intermediate  
**Prerequisites**: Basic OOP concepts, Classes and Objects  
**Estimated Time**: 27 minutes

## ðŸŽ¯ Learning Objectives

By the end of this 27-minute session, you will:

- Understand the fundamental differences between abstraction and encapsulation
- Apply both principles effectively in object-oriented design
- Recognize when and how to use each principle for better code organization

**Abstraction** and **Encapsulation** are two fundamental principles of Object-Oriented Programming (OOP), and while they are closely related, they serve different purposes. Here's a comparison:

---

**Part B of 3**

Previous: [08_OOP-Abstraction-Encapsulation-PartA.md](08_OOP-Abstraction-Encapsulation-PartA.md)
Next: [08_OOP-Abstraction-Encapsulation-PartC.md](08_OOP-Abstraction-Encapsulation-PartC.md)

---

    }
}

```

---

### **2. Generalization**

- **Definition**: The process of extracting shared characteristics from two or more classes to create a generalized parent class.
- **Purpose**: Helps in code reuse and abstraction.

#### **Example**

```csharp
class Vehicle {
    public string Make { get; set; }
    public string Model { get; set; }

    public void Start() {
        Console.WriteLine("Vehicle started.");
    }
}

class Car : Vehicle {
    public int Doors { get; set; }
}

class Motorcycle : Vehicle {
    public bool HasSidecar { get; set; }
}
```

---

### **3. Specialization**

- **Definition**: Adding more specific features to a subclass that are not present in the parent class.
- **Purpose**: Represents the unique properties of a derived class.

#### **Example**

```csharp
class Vehicle {
    public string Make { get; set; }
    public string Model { get; set; }
}

class Car : Vehicle {
    public int Doors { get; set; } // Specialization for cars
}
```

---

### **4. Association**

- **Definition**: A relationship between two classes that allows one object to use another.
- **Types**:
  - One-to-One
  - One-to-Many
  - Many-to-Many

#### **Example**

```csharp
class Driver {
    public string Name { get; set; }
}

class Car {
    public Driver Driver { get; set; } // Association

    public void AssignDriver(Driver driver) {
        this.Driver = driver;
    }
}
```

---

### **5. Aggregation (Has-A Relationship - Weak)**

- **Definition**: A special form of association where one class contains another as part of its attributes, but the contained object can exist independently.

#### **Example**

```csharp
class Engine {
    public string Type { get; set; }
}

class Car {
    public Engine Engine { get; set; } // Aggregation
}
```

---

### **6. Composition (Has-A Relationship - Strong)**

- **Definition**: A form of association where the contained objectâ€™s lifecycle is tied to the lifecycle of the container object.
- **Key Difference from Aggregation**: In composition, if the container object is destroyed, the contained object is also destroyed.

#### **Example**

```csharp
class Engine {
    public string Type { get; set; }
}

class Car {
    private Engine engine = new Engine(); // Composition
}
```

---

### **7. Inheritance (Is-A Relationship)**

- **Definition**: A mechanism by which one class can acquire properties and methods of another class.
- **Purpose**: Enables code reuse and supports polymorphism.

#### **Example**

```csharp
class Animal {
    public void Eat() {
        Console.WriteLine("Eating...");
    }
}

class Dog : Animal {
    public void Bark() {
        Console.WriteLine("Barking...");
    }
}

class Program {
    static void Main() {
        Dog dog = new Dog();
        dog.Eat(); // From Animal class
        dog.Bark(); // From Dog class
    }
}
```

---
