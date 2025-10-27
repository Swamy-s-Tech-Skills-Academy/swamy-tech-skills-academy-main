# 01_OOP-Core-Concepts-PartB

**Learning Level**: Beginner

**Prerequisites**: [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)
**Estimated Time**: 12 minutes (27-minute focused session)

## **Series**: Part B of 2 - Core OOP Concepts

## 🎯 Learning Objectives

By the end of this 12-minute session, you will

- Master the concept of classes as blueprints
- Understand class structure and components
- Apply real-world analogies to class concepts

---

## 📋 Content Sections (12-Minute Structure)

### Quick Overview (2 minutes)

**Class Definition**: A class is a blueprint or template that defines the structure and behavior of objects
**Real-World Analogy**: A house blueprint defines structure (rooms, layout), features (windows, doors), and capabilities (electrical, plumbing).

### Core Concepts (8 minutes)

### **1. Class Components**

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
```csharp### **3. Class Template**

```pseudocode
CLASS ClassName:
```csharp
// Attributes (data every instance will have)
```csharp
```csharp
PRIVATE attribute1: DataType
```csharp
```csharp
PRIVATE attribute2: DataType
```csharp
```csharp
// Constructor (how to create instances)
```csharp
```csharp
CONSTRUCTOR(parameters):
```csharp
```csharp
    // Initialize attributes
```csharp
```csharp
    this.attribute1 = parameter1
```csharp
```csharp
    this.attribute2 = parameter2
```csharp
```csharp
// Methods (behavior every instance can perform)
```csharp
```csharp
PUBLIC methodName():
```csharp
```csharp
    // Implementation
```csharp
```csharp    RETURN someValue
```csharp
```csharp### **4. Real Example: Book Class**

```pseudocode
CLASS Book:
```csharp
// Every book has these attributes
```csharp
```csharp
PRIVATE title: string
```csharp
```csharp
PRIVATE author: string
```csharp
```csharp
PRIVATE pages: integer
```csharp
```csharp
PRIVATE isAvailable: boolean
```csharp
```csharp
// Constructor to create a book
```csharp
```csharp
CONSTRUCTOR Book(t: string, a: string, p: integer):
```csharp
```csharp
    this.title = t
```csharp
```csharp
    this.author = a
```csharp
```csharp
    this.pages = p
```csharp
```csharp
    this.isAvailable = true
```csharp
```csharp
// What every book can do
```csharp
```csharp
PUBLIC getTitle(): string
```csharp
```csharp
    RETURN this.title
```csharp
```csharp
PUBLIC checkOut(): void
```csharp
```csharp
    this.isAvailable = false
```csharp
```csharp
PUBLIC checkIn(): void
```csharp
```csharp    this.isAvailable = true
```csharp
```

---

### Key Takeaways (2 minutes)

### **Essential Understanding**

1. **Classes are blueprints** that define structure and behavior

1. **Attributes store data** that objects will have
1. **Methods define actions** that objects can perform
1. **Constructors create instances** from the blueprint

### **What's Next**

**Part B1** will cover:

- Creating actual objects from classes
- Object instantiation process

## - Multiple objects from one class

## 🔗 Series Navigation

- **Previous**: [01_OOP-Core-Concepts-PartA.md](01_OOP-Core-Concepts-PartA.md)

  - **Current**: Part A2 - Classes as Blueprints ✅
  - **Next**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)
  - **Series**: Classes & Objects Foundation (Part A2 of 4)

**Last Updated**: October 4, 2025

**Format**: 12-minute focused learning segment
