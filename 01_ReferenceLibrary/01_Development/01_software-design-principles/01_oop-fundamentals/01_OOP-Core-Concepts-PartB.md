# 01_OOP-Core-Concepts-PartB

**Learning Level**: Beginner
**Prerequisites**: [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)
**Estimated Time**: 12 minutes (27-minute focused session)
**Series**: Part B of 2 - Core OOP Concepts

---
## 🎯 Learning Objectives

By the end of this 12-minute session, you will:

- Master the concept of classes as blueprints
- Understand class structure and components
- Apply real-world analogies to class concepts

---

## 📋 Content Sections (12-Minute Structure)

### Quick Overview (2 minutes)

**Class Definition**: A class is a blueprint or template that defines the structure and behavior of objects.

**Real-World Analogy**: A house blueprint defines structure (rooms, layout), features (windows, doors), and capabilities (electrical, plumbing).

### Core Concepts (8 minutes)

#### **1. Class Components**

**Every class has two main parts**:

```text
CLASS STRUCTURE
┌─────────────────────┐
│     ATTRIBUTES      │  ← Data (what it has)
│   - name: string    │
│   - age: integer    │
│   - email: string   │
├─────────────────────┤
│      METHODS        │  ← Behavior (what it can do)
│   + getName()       │
│   + setAge()        │
│   + sendEmail()     │
└─────────────────────┘
```

### **3. Class Template**

```pseudocode
CLASS ClassName:
    // Attributes (data every instance will have)
    PRIVATE attribute1: DataType
    PRIVATE attribute2: DataType

    // Constructor (how to create instances)
    CONSTRUCTOR(parameters):
        // Initialize attributes
        this.attribute1 = parameter1
        this.attribute2 = parameter2

    // Methods (behavior every instance can perform)
    PUBLIC methodName():
        // Implementation
        RETURN someValue
```

### **4. Real Example: Book Class**

```pseudocode
CLASS Book:
    // Every book has these attributes
    PRIVATE title: string
    PRIVATE author: string
    PRIVATE pages: integer
    PRIVATE isAvailable: boolean

    // Constructor to create a book
    CONSTRUCTOR Book(t: string, a: string, p: integer):
        this.title = t
        this.author = a
        this.pages = p
        this.isAvailable = true

    // What every book can do
    PUBLIC getTitle(): string
        RETURN this.title

    PUBLIC checkOut(): void
        this.isAvailable = false

    PUBLIC checkIn(): void
        this.isAvailable = true
```

---

### Key Takeaways (2 minutes)

#### **Essential Understanding**

1. **Classes are blueprints** that define structure and behavior
2. **Attributes store data** that objects will have
3. **Methods define actions** that objects can perform
4. **Constructors create instances** from the blueprint

#### **What's Next**

**Part B1** will cover:

- Creating actual objects from classes
- Object instantiation process
- Multiple objects from one class

---

## 🔗 Series Navigation

- **Previous**: [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)
- **Current**: Part A2 - Classes as Blueprints ✅
- **Next**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)
- **Series**: Classes & Objects Foundation (Part A2 of 4)

**Last Updated**: October 4, 2025
**Format**: 12-minute focused learning segment
