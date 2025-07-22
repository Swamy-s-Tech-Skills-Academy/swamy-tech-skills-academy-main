# 🎯 OOP Fundamentals Cheat Sheet

**Language-Agnostic Object-Oriented Programming Reference**

> 📖 **5-minute quick reference** | 🎯 **Focus**: Core concepts and principles | 🔄 **Universal**: Works with any OOP language

---

## 🏗️ Class & Object Fundamentals

- **Class**: A blueprint or template for creating objects
- **Object**: An instance of a class with real data

### **Quick Example**

```text
Class: Car (blueprint)
Object: "My Red Toyota" (actual instance with specific data)
```

---

## 📖 Essential OOP Terms

| Term               | Meaning                                                                |
| ------------------ | ---------------------------------------------------------------------- |
| **Attribute**      | Variable or data inside a class (also called field or property)        |
| **Method**         | Function inside a class that defines behavior                          |
| **Constructor**    | Special method to initialize objects when they are created             |
| **Interface**      | A contract that defines what methods a class must implement            |
| **Abstract Class** | Cannot be instantiated; may contain both defined and undefined methods |
| **Instance**       | A specific object created from a class template                        |
| **Overloading**    | Same method name with different parameters (compile-time polymorphism) |
| **Overriding**     | Redefining a parent method in a child class (runtime polymorphism)     |

---

## 💡 OOP in One Sentence

> **"OOP is about modeling real-world entities using classes and objects while leveraging encapsulation, abstraction, inheritance, and polymorphism to build scalable, maintainable software."**

---

## 🔗 Object Relationships

### **Types of Relationships**

| Relationship       | Description                                                      | Example                   |
| ------------------ | ---------------------------------------------------------------- | ------------------------- |
| **Association**    | A "uses-a" relationship between objects                          | Driver uses Car           |
| **Aggregation**    | A "has-a" relationship. Child can exist independently of parent  | Department has Employees  |
| **Composition**    | Stronger "has-a" relationship. Child cannot exist without parent | Car has Engine            |
| **Generalization** | An "is-a" relationship; inheritance                              | Dog is-a Animal           |
| **Dependency**     | A class depends on another if it uses it temporarily             | Calculator uses MathUtils |

---

## 🏛️ The Four Pillars of OOP

### **Quick Overview Table**

| Principle         | Description                                                                   |
| ----------------- | ----------------------------------------------------------------------------- |
| **Encapsulation** | Bundling data and methods together, hiding internal state from outside access |
| **Abstraction**   | Hiding complex details and showing only essential features                    |
| **Inheritance**   | Deriving new classes from existing ones (reusability)                         |
| **Polymorphism**  | Same interface, different implementation (many forms)                         |

---

### **1. 🔒 Encapsulation**

**Concept**: Bundle data and methods together, hide internal details

**Key Principles:**

- **Data Hiding**: Internal state is private
- **Interface Design**: Public methods provide controlled access
- **Cohesion**: Related data and behavior stay together

**Benefits:**

- ✅ **Security**: Prevents unauthorized access
- ✅ **Maintainability**: Changes to internals don't break external code
- ✅ **Modularity**: Self-contained, reusable components

---

### **2. 🎭 Abstraction**

**Concept**: Hide complexity, show only essential features

**Key Principles:**

- **Essential Features**: Focus on what matters
- **Hide Complexity**: Internal details are invisible
- **Common Interface**: Consistent way to interact

**Benefits:**

- ✅ **Simplicity**: Easier to understand and use
- ✅ **Flexibility**: Implementation can change without affecting users
- ✅ **Reusability**: Abstract concepts work across different contexts

---

### **3. 🧬 Inheritance**

**Concept**: Create new classes based on existing ones

**Key Principles:**

- **Code Reuse**: Child classes inherit parent functionality
- **Specialization**: Add or modify behavior in child classes
- **Hierarchy**: Logical organization of related classes

**Benefits:**

- ✅ **DRY Principle**: Don't repeat yourself
- ✅ **Maintainability**: Changes in parent affect all children
- ✅ **Organization**: Clear hierarchical structure

---

### **4. 🔄 Polymorphism**

**Concept**: Same interface, different implementations

**Key Principles:**

- **Common Interface**: Same method names across different classes
- **Different Behavior**: Each class implements methods differently
- **Runtime Decision**: Which implementation to use is decided at runtime

**Benefits:**

- ✅ **Flexibility**: Easy to add new types without changing existing code
- ✅ **Extensibility**: New classes can be treated like existing ones
- ✅ **Maintainability**: Changes to one implementation don't affect others

---

## 📚 Quick Examples

### **Encapsulation Example**

```pseudocode
class BankAccount {
    private balance = 0    // Hidden data

    public deposit(amount) {
        if (amount > 0) balance += amount
    }

    public getBalance() {
        return balance    // Controlled access
    }
}
```

### **Abstraction Example**

```pseudocode
abstract class Shape {
    abstract calculateArea()     // Must be implemented
    displayInfo() { print("This is a shape") }  // Common implementation
}

class Circle implements Shape {
    calculateArea() { return π * radius² }
}

class Rectangle implements Shape {
    calculateArea() { return width * height }
}

// Same interface, different implementations
```

### **Inheritance Example**

```pseudocode
class Animal {
    name, age
    eat() { print("Animal is eating") }
    sleep() { print("Animal is sleeping") }
}

class Dog extends Animal {
    breed
    bark() { print("Woof!") }     // New method
    eat() { print("Dog is eating dog food") }  // Override
}
```

### **Polymorphism Example**

```pseudocode
shapes = [Circle(5), Rectangle(4,6), Triangle(3,4,5)]

for shape in shapes {
    shape.calculateArea()    // Calls different implementations
}
```

---

## 🔄 Inheritance vs Composition

| Aspect           | Inheritance       | Composition            |
| ---------------- | ----------------- | ---------------------- |
| **Relationship** | IS-A              | HAS-A                  |
| **Coupling**     | Tight             | Loose                  |
| **Flexibility**  | Static            | Dynamic                |
| **Code Reuse**   | Automatic         | Manual                 |
| **When to Use**  | Clear hierarchies | Flexible relationships |

### **Composition Example**

```text
Car HAS-A Engine
Car HAS-A Wheels
Car HAS-A Transmission

Benefits: Can swap engines, change wheel types, upgrade transmission
```

### **Inheritance Example (Hierarchies)**

```text
Vehicle -> Car -> SportsCar
Vehicle -> Truck -> DeliveryTruck

Benefits: Automatic inheritance of common vehicle features
```

---

## 🎨 Common Design Patterns

### **Creational Patterns**

- **Factory**: Create objects without specifying exact classes
- **Builder**: Construct complex objects step by step
- **Singleton**: Ensure only one instance exists

### **Structural Patterns**

- **Adapter**: Make incompatible interfaces work together
- **Decorator**: Add behavior without altering structure
- **Facade**: Provide simple interface to complex subsystem

### **Behavioral Patterns**

- **Observer**: Objects notify others of state changes
- **Strategy**: Choose algorithms at runtime
- **Template Method**: Define algorithm skeleton, let subclasses fill details

---

## 🎯 Key Takeaways

### **Core Concepts**

1. **Classes** define structure and behavior
2. **Objects** are instances with actual data
3. **Four Pillars** provide design principles
4. **Relationships** connect objects meaningfully

### **Best Practices**

- ✅ **Favor composition** over inheritance when possible
- ✅ **Keep interfaces simple** and focused
- ✅ **Hide implementation details** through encapsulation
- ✅ **Use abstraction** to manage complexity
- ✅ **Design for extension** through polymorphism

### **Remember**

> **OOP is not about using all features everywhere - it's about choosing the right tool for each problem to create maintainable, scalable software.**

---

## 📚 Related Resources

- **Design Patterns**: Gang of Four patterns
- **Clean Code**: Robert Martin's principles
- **Language-Specific**: C#, Java, Python OOP guides
- **Architecture**: SOLID principles, Clean Architecture

---

_📝 **Next Step**: Check out `02_OOP-CSharp-CheatSheet.md` for language-specific implementation examples_
