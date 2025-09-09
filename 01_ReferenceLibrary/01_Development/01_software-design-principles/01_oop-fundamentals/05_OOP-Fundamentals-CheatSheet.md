# 05_OOP-Fundamentals-CheatSheet

**Learning Level**: Quick Reference  
**Prerequisites**: Basic OOP understanding  
**Estimated Time**: 5-minute lookup reference  

## 🎯 **Quick OOP Reference**

### **Four Pillars of OOP**

| Pillar | Definition | Key Benefit |
|--------|------------|-------------|
| **Encapsulation** | Bundle data + methods, control access | Data protection, modularity |
| **Abstraction** | Hide complexity, show essential features | Simplified interfaces |
| **Inheritance** | Child classes extend parent classes | Code reuse, IS-A relationships |
| **Polymorphism** | Same interface, different behaviors | Flexible, extensible code |

---

## 🏗️ **Core Concepts**

### **Class vs Object**

```text
Class: Blueprint/Template          Object: Actual Instance
├── Car (defines structure)   →   ├── "My Red Toyota Camry"
├── Person (defines behavior) →   ├── "John Smith, age 30"
└── BankAccount (defines rules) → └── "Account #12345, balance $500"
```

### **Method Types**

- **Constructor**: Initializes new objects
- **Instance Method**: Works with specific object data
- **Static Method**: Works without object instances
- **Getter/Setter**: Controls property access

### **Access Levels**

- **Public**: Accessible everywhere (`+`)
- **Private**: Class-only access (`-`)
- **Protected**: Class + subclasses (`#`)

---

## 🔗 **Relationships**

### **Association Types**

```text
Association: "uses-a" (temporary relationship)
├── Driver uses Car
└── Customer uses ShoppingCart

Aggregation: "has-a" (loose ownership)
├── Department has Employees
└── Team has Members

Composition: "part-of" (tight ownership)
├── House has Rooms
└── Car has Engine
```

### **Inheritance Hierarchy**

```text
Generalization (IS-A):
    Animal
    ├── Dog (IS-A Animal)
    ├── Cat (IS-A Animal)
    └── Bird (IS-A Animal)
        └── Eagle (IS-A Bird, IS-A Animal)
```

---

## 🎭 **Polymorphism Patterns**

### **Method Overriding**

```text
Parent: Animal.makeSound() → "Generic sound"
Child:  Dog.makeSound()    → "Woof!"
Child:  Cat.makeSound()    → "Meow!"
```

### **Interface Implementation**

```text
Interface: Drawable
├── Circle.draw()    → "Drawing circle"
├── Rectangle.draw() → "Drawing rectangle"
└── Triangle.draw()  → "Drawing triangle"
```

---

## 🎨 **Design Decisions**

### **Inheritance vs Composition**

| Use Inheritance When: | Use Composition When: |
|----------------------|----------------------|
| Clear IS-A relationship | HAS-A relationship |
| Shared behavior needed | Flexible combinations |
| Stable hierarchy | Dynamic relationships |

**Example Choice:**

- ✅ `Dog extends Animal` (inheritance)
- ✅ `Car has Engine` (composition)

### **Abstract Class vs Interface**

| Abstract Class | Interface |
|----------------|-----------|
| Shared implementation | Pure contracts |
| IS-A relationship | CAN-DO capability |
| Single inheritance | Multiple implementation |

---

## ⚡ **Quick Implementation Checklist**

### **Class Design**

- [ ] Single responsibility (one job per class)
- [ ] Proper encapsulation (private data, public methods)
- [ ] Meaningful names (class = noun, method = verb)
- [ ] Constructor validation

### **Inheritance Design**

- [ ] IS-A relationship verified
- [ ] Avoid deep hierarchies (3 levels max)
- [ ] Override methods appropriately
- [ ] Call parent constructors

### **Interface Design**

- [ ] Small, focused contracts
- [ ] Behavior-based naming (Drawable, Comparable)
- [ ] Consistent method signatures

---

## 🚨 **Common Anti-Patterns**

| Anti-Pattern | Problem | Better Approach |
|-------------|---------|-----------------|
| **God Class** | One class does everything | Split responsibilities |
| **Feature Envy** | Class uses other class data heavily | Move behavior to data owner |
| **Long Parameter List** | Too many method parameters | Use parameter objects |
| **Switch Statements** | Type checking instead of polymorphism | Use polymorphic methods |

---

## 🎯 **Design Principles (Quick)**

### **SOLID Preview**

- **S**: Single Responsibility Principle
- **O**: Open/Closed Principle  
- **L**: Liskov Substitution Principle
- **I**: Interface Segregation Principle
- **D**: Dependency Inversion Principle

### **Best Practices**

- Favor composition over inheritance
- Program to interfaces, not implementations
- Keep classes small and focused
- Use meaningful names everywhere

---

## 🔗 **Related Quick References**

### **Prerequisites Met**

- Basic programming concepts
- Function and variable understanding

### **Enables**

- **SOLID Principles**: Advanced design principles
- **Design Patterns**: Gang of Four implementation patterns
- **Enterprise Architecture**: Large-scale system design

---

**Status**: ✅ **Optimized** (175-line quick reference format)  
**Purpose**: 5-minute lookup for OOP concepts and decisions  
**Next**: Apply concepts in [01_OOP-Classes-and-Objects.md](01_OOP-Classes-and-Objects.md)
