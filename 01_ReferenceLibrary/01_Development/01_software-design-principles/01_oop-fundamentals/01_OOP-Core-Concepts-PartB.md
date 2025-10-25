# 01_OOP-Core-Concepts-PartB\n\n**Learning Level**: Beginner

**Prerequisites**: [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)
**Estimated Time**: 12 minutes (27-minute focused session)
**Series**: Part B of 2 - Core OOP Concepts
---

## 🎯 Learning Objectives\n\nBy the end of this 12-minute session, you will

- Master the concept of classes as blueprints
- Understand class structure and components
- Apply real-world analogies to class concepts

---

## 📋 Content Sections (12-Minute Structure)

### Quick Overview (2 minutes)

\n\n\n\n**Class Definition**: A class is a blueprint or template that defines the structure and behavior of objects
**Real-World Analogy**: A house blueprint defines structure (rooms, layout), features (windows, doors), and capabilities (electrical, plumbing).

### Core Concepts (8 minutes)

\n\n

### **1. Class Components**

\n\n\n\n**Every class has two main parts**:

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
```csharp### **3. Class Template**

```pseudocode
CLASS ClassName:
```csharp\n// Attributes (data every instance will have)\n```csharp\n```csharp\nPRIVATE attribute1: DataType\n```csharp\n```csharp\nPRIVATE attribute2: DataType\n```csharp\n```csharp\n// Constructor (how to create instances)\n```csharp\n```csharp\nCONSTRUCTOR(parameters):\n```csharp\n```csharp\n    // Initialize attributes\n```csharp\n```csharp\n    this.attribute1 = parameter1\n```csharp\n```csharp\n    this.attribute2 = parameter2\n```csharp\n```csharp\n// Methods (behavior every instance can perform)\n```csharp\n```csharp\nPUBLIC methodName():\n```csharp\n```csharp\n    // Implementation\n```csharp\n```csharp    RETURN someValue
```csharp\n```csharp### **4. Real Example: Book Class**

```pseudocode
CLASS Book:
```csharp\n// Every book has these attributes\n```csharp\n```csharp\nPRIVATE title: string\n```csharp\n```csharp\nPRIVATE author: string\n```csharp\n```csharp\nPRIVATE pages: integer\n```csharp\n```csharp\nPRIVATE isAvailable: boolean\n```csharp\n```csharp\n// Constructor to create a book\n```csharp\n```csharp\nCONSTRUCTOR Book(t: string, a: string, p: integer):\n```csharp\n```csharp\n    this.title = t\n```csharp\n```csharp\n    this.author = a\n```csharp\n```csharp\n    this.pages = p\n```csharp\n```csharp\n    this.isAvailable = true\n```csharp\n```csharp\n// What every book can do\n```csharp\n```csharp\nPUBLIC getTitle(): string\n```csharp\n```csharp\n    RETURN this.title\n```csharp\n```csharp\nPUBLIC checkOut(): void\n```csharp\n```csharp\n    this.isAvailable = false\n```csharp\n```csharp\nPUBLIC checkIn(): void\n```csharp\n```csharp    this.isAvailable = true
```csharp\n```\n\n---

### Key Takeaways (2 minutes)

\n\n

### **Essential Understanding**

\n\n\n\n1. **Classes are blueprints** that define structure and behavior

1. **Attributes store data** that objects will have
2. **Methods define actions** that objects can perform
3. **Constructors create instances** from the blueprint\n\n### **What's Next**

\n\n\n\n**Part B1** will cover:
  - Creating actual objects from classes
  - Object instantiation process
  - Multiple objects from one class
---

## 🔗 Series Navigation\n\n- **Previous**: [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)
  - **Current**: Part A2 - Classes as Blueprints ✅
  - **Next**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)
  - **Series**: Classes & Objects Foundation (Part A2 of 4)\n\n**Last Updated**: October 4, 2025

**Format**: 12-minute focused learning segment
