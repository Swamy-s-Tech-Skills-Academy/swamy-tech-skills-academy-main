# 🎯 OOP Fundamentals Cheat Sheet

**Language-Agnostic Object-Oriented Programming Reference**

> 📖 **5-minute quick reference** | 🎯 **Focus**: Core concepts and principles | 🔄 **Universal**: Works with any OOP language

## ✅ **OOP Coverage Map**

This cheat sheet focuses purely on **Object-Oriented Programming (OOP)** — clean, deep, and language-agnostic:

### 🧱 **Foundations & Core Concepts**

✅ Definitions of Class, Object, Method, Attribute  
✅ Four Pillars: Encapsulation, Abstraction, Inheritance, Polymorphism  
✅ Object relationships: Association, Aggregation, Composition, Generalization, Dependency

### 🧩 **Design Modeling**

✅ When to use inheritance vs composition  
✅ Real-world modeling scenarios  
✅ Common decision patterns

### 💡 **Best Practices**

✅ Favor composition over inheritance  
✅ DRY, YAGNI, KISS in OOP context  
✅ Workshop-ready learning prompts

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
| **Cohesion**       | How closely related responsibilities within a class are                |
| **Coupling**       | How dependent classes are on each other (aim for loose coupling)       |
| **Protocol**       | Interface contract (commonly used in Python and Swift)                 |

---

## ✅ OOP in One Sentence

> **"OOP models real-world entities using objects and classes, embracing four key principles—encapsulation, abstraction, inheritance, and polymorphism—to build scalable and reusable systems."**

💡 **Use this as your north star during every discussion or workshop segment!**

---

## 🔗 Object Relationships

### **Types of Relationships (with Real-Life Analogies)**

| Relationship       | Description                                                      | Real-Life Analogy                                   |
| ------------------ | ---------------------------------------------------------------- | --------------------------------------------------- |
| **Association**    | A "uses-a" relationship between objects                          | A student attends a course                          |
| **Aggregation**    | A "has-a" relationship. Child can exist independently of parent  | A library has books (books survive without library) |
| **Composition**    | Stronger "has-a" relationship. Child cannot exist without parent | A heart is part of a human (can't live separately)  |
| **Generalization** | An "is-a" relationship; inheritance                              | A square is a shape                                 |
| **Dependency**     | A class depends on another if it uses it temporarily             | A phone uses Wi-Fi when available                   |

---

## 🏛️ The Four Pillars of OOP

### **Enhanced Four Pillars with Learning Hooks**

| Pillar               | Core Idea                               | Learning Hook                            |
| -------------------- | --------------------------------------- | ---------------------------------------- |
| 🔒 **Encapsulation** | Control access, protect internal state  | "What happens in class, stays in class." |
| 🎭 **Abstraction**   | Hide complexity, show only what matters | "Drive the car, skip the engine tour."   |
| 🧬 **Inheritance**   | Reuse behavior across hierarchies       | "Children inherit traits from parents."  |
| 🔄 **Polymorphism**  | One interface, many behaviors           | "Same button, different reaction."       |

### **🧠 Mnemonic: "A PIE of OOP"**

Remember the pillars as slices of a PIE that make software digestible 🥧:

- **A**bstraction
- **P**olymorphism
- **I**nheritance
- **E**ncapsulation

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

**Types:**

- **Static Polymorphism**: Method overloading (compile-time decision)
- **Dynamic Polymorphism**: Method overriding (runtime decision)

---

## 📚 Quick Examples

### **🎯 Unified Example: Inheritance + Polymorphism**

```pseudocode
Class: Animal
Method: speak()

Dog extends Animal
Override speak() → "Dog barks"

Cat extends Animal
Override speak() → "Cat meows"

// Polymorphism in action:
Animal a = new Dog()
a.speak() → Output: "Dog barks"

Animal b = new Cat()
b.speak() → Output: "Cat meows"
```

**💡 Shows inheritance + polymorphism in one clean example!**

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
// Abstract Class Approach
abstract class Shape {
    abstract calculateArea()     // Must be implemented
    displayInfo() { print("This is a shape") }  // Common implementation
}

// Interface-Based Approach
interface Drawable {
    calculateArea()    // Contract only
    draw()            // Another required method
}

class Circle implements Shape, Drawable {
    calculateArea() { return π * radius² }
    draw() { print("Drawing a circle") }
}

class Rectangle implements Shape, Drawable {
    calculateArea() { return width * height }
    draw() { print("Drawing a rectangle") }
}

// Same interface, different implementations
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

## 🧠 Bonus: Design Thinking in OOP

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
- **Command**: Encapsulate requests as objects
- **State**: Change behavior when internal state changes

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
- ✅ **Avoid deep inheritance chains** (max 2-3 levels recommended)
- ✅ **Aim for high cohesion, low coupling**

### **Remember**

> **OOP is not about using all features everywhere - it's about choosing the right tool for each problem to create maintainable, scalable software.**

---

## 🎯 Workshop-Ready Learning Prompts

### **🤔 Think & Discuss**

- **Which relationship would you use to model a school and student?** (Association, Aggregation, or Composition?)
- **Can you think of a real-world example for each pillar?** Practice with objects around you!
- **When would you choose composition over inheritance?** Think flexibility vs. simplicity.

### **🔁 Quick Decision Flow: Composition vs Inheritance**

```text
Need to share behavior?
    ↓
Is it a clear "IS-A" relationship?
    ↓ YES                    ↓ NO
Use Inheritance         Use Composition
(Dog IS-A Animal)      (Car HAS-A Engine)
```

### **📌 Reflection Notes**

> **Workshop Tip**: Have participants draw their own analogies for each pillar and share with the group!

---

## 📚 Related Resources & Next Steps

### **🔁 What We've Accomplished**

✅ Complete **OOP Fundamentals Cheat Sheet (Language-Agnostic)**  
✅ Covers: definitions, pillars, relationships, patterns, and best practices

### **📄 Available Next Deliverables**

- **OOP Interview Q&A Set** - Common questions with detailed answers
- **Real-world OOP modeling examples** - Library System, Banking, School scenarios
- **OOP exercises with solutions** - Hands-on practice problems
- **Decision trees** - When to use which principle/relationship
- **Quiz deck or flashcards** - Interactive learning tools

### **🎯 Deep-Dive Options**

1. **Each pillar one-by-one** with more examples and edge cases
2. **Language-specific implementations** (C#, Python, Java)
3. **OOP modeling scenarios** with complete walkthroughs
4. **Object relationships in-depth** with complex examples
5. **SOLID principles** in OOP context

### **📖 Current Resources**

- **Language-Specific**: Check out `02_OOP-CSharp-CheatSheet.md`
- **Design Patterns**: Gang of Four patterns
- **Clean Code**: Robert Martin's principles
- **Architecture**: SOLID principles, Clean Architecture

---

_📝 **Focus**: Pure OOP concepts — clean, deep, and language-agnostic_
