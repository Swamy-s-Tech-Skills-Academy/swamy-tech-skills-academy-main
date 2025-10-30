# 03_OOP-Inheritance-Polymorphism

**Learning Level**: Beginner → Intermediate

**Prerequisites**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Core Pillars - Inheritance & Polymorphism

## 🎯 Learning Objectives

By the end of this session, you will

- Master inheritance hierarchies and code reuse strategies
- Understand polymorphism and dynamic binding concepts
- Apply method overriding and interface implementation
- Distinguish between inheritance and composition patterns

---
By the end of this session, you will:

- Master inheritance for code reuse through parent-child relationships
- Understand polymorphism for flexible behavior implementation
- Implement method overriding and interface contracts
- Design maintainable class hierarchies

## 📋 Content Sections (27-Minute Structure)

### Quick Review (5 minutes)

**Previous Concepts**: Classes, objects, encapsulation, abstraction
**Today's Focus**: Code reuse (inheritance) and flexible behavior (polymorphism)

### Core Concepts (15 minutes)

### **Inheritance: Code Reuse Architecture**

**Definition**: Child classes inherit properties/methods from parent classes while adding specialization

```text
# 📊 Inheritance Hierarchy

```csharp
Vehicle (Parent)
```csharp
```csharp
├── properties: brand, model, year
```csharp
```csharp
├── methods: start(), stop(), getInfo()
```csharp
    │
```csharp
├── Car (Child)
```csharp
```csharp
│   ├── properties: doors, fuelType
```csharp
```csharp
│   └── methods: openTrunk(), lockDoors()
```csharp
    │
```csharp
└── Motorcycle (Child)
```csharp
```csharp
    ├── properties: engineSize, hasWindshield
```csharp
```csharp    └── methods: wheelie(), leanIntoTurn()
```csharp
```csharp**Key Principle**: "IS-A" relationship (Car IS-A Vehicle)

### **Language-Agnostic Implementation Pattern**




```pseudocode

// Parent Class Definition
class Vehicle:
```csharp
properties:
```csharp
```csharp
    brand: string
```csharp
```csharp
    model: string
```csharp
```csharp
    year: integer
```csharp
```csharp
methods:
```csharp
```csharp
    start(): "Engine starting..."
```csharp
```csharp
    stop(): "Engine stopping..."
```csharp
```csharp
    getInfo(): return brand + model + year
```csharp
// Child Class Definition
class Car extends Vehicle:
```csharp
properties:
```csharp
```csharp
    doors: integer
```csharp
```csharp
    fuelType: string
```csharp
```csharp
methods:
```csharp
```csharp
    // Inherited: start(), stop(), getInfo()
```csharp
```csharp
    openTrunk(): "Trunk opened"
```csharp
```csharp
    lockDoors(): "Doors locked"
```csharp
```csharp
    // Override parent method
```csharp
```csharp    start(): "Car engine starting with key..."
```csharp
```csharp#### **Polymorphism: One Interface, Multiple Behaviors**
**Definition**: Same method call produces different behaviors based on object type.

```text
# 🔄 Polymorphic Behavior

vehicles = [Car, Motorcycle, Truck]
for each vehicle in vehicles:
```csharp
vehicle.start()  // Same call, different behavior:
```csharp
```csharp
Car: "Car engine starting with key..."
```csharp
```csharp
Motorcycle: "Motorcycle engine roaring to life..."
```csharp
```csharpTruck: "Diesel engine warming up..."
```csharp
```csharp#### **Method Overriding vs Method Overloading**

```pseudocode
// Method Overriding (Same signature, different implementation)
class Animal:
```csharp
makeSound(): "Some generic sound"
```csharp
class Dog extends Animal:
```csharp
makeSound(): "Woof! Woof!"  // Override
```csharp
class Cat extends Animal:
```csharp
makeSound(): "Meow! Meow!" // Override
```csharp
// Method Overloading (Same name, different parameters)
class Calculator:
```csharp
add(a, b): return a + b
```csharp
```csharp
add(a, b, c): return a + b + c
```csharp
```csharpadd(numbers[]): return sum of all numbers
```csharp
```csharp### Practical Implementation (5 minutes)

### **Enterprise Design Pattern Example**




```pseudocode

// Abstract base class
abstract class DatabaseConnection:
```csharp
abstract connect(): connection
```csharp
```csharp
abstract disconnect(): void
```csharp
```csharp
// Shared behavior
```csharp
```csharp
validateCredentials(): boolean
```csharp
```csharp
logActivity(): void
```csharp
// Concrete implementations
class MySQLConnection extends DatabaseConnection:
```csharp
connect():
```csharp
```csharp
    // MySQL-specific connection logic
```csharp
```csharp
    return mysql_connect(host, user, password)
```csharp
```csharp
disconnect():
```csharp
```csharp
    mysql_close(connection)
```csharp
class PostgreSQLConnection extends DatabaseConnection:
```csharp
connect():
```csharp
```csharp
    // PostgreSQL-specific connection logic
```csharp
```csharp
    return pg_connect(connectionString)
```csharp
```csharp
disconnect():
```csharp
```csharp
    pg_close(connection)
```csharp
// Polymorphic usage
function connectToDatabase(dbType):
```csharp
connection = createConnection(dbType)  // Factory pattern
```csharp
```csharp
connection.connect()                   // Polymorphic call
```csharp
```csharpreturn connection
```csharp
```csharp#### **Interface-Based Design**

```pseudocode
// Interface contract
interface Drawable:
```csharp
draw(): void
```csharp
```csharp
calculateArea(): number
```csharp
// Multiple inheritance through interfaces
class Circle implements Drawable:
```csharp
radius: number
```csharp
```csharp
draw(): "Drawing circle with radius " + radius
```csharp
```csharp
calculateArea(): return π * radius²
```csharp
class Rectangle implements Drawable:
```csharp
width: number
```csharp
```csharp
height: number
```csharp
```csharp
draw(): "Drawing rectangle " + width + "x" + height
```csharp
```csharp
calculateArea(): return width * height
```csharp
// Polymorphic rendering
shapes: Drawable[] = [Circle, Rectangle, Triangle]
for shape in shapes:
```csharp
shape.draw()                    // Same interface
```csharp
```csharparea = shape.calculateArea()    // Different implementations
```csharp
```

### Key Takeaways & Next Steps (2 minutes)

### **Essential Principles**

✅ **Inheritance**: Use for "IS-A" relationships and code reuse
✅ **Polymorphism**: Enable flexible behavior through common interfaces
✅ **Method Overriding**: Specialize parent behavior in child classes
✅ **Interface Design**: Define contracts for consistent behavior

### **Best Practices**

- Prefer composition over inheritance when possible
  - Keep inheritance hierarchies shallow (2-3 levels max)
  - Use abstract classes for shared implementation
  - Use interfaces for behavioral contracts

### **Next Steps**

- **Immediate**: Practice implementing inheritance hierarchies
  - **Part 1D**: Advanced patterns (composition, design patterns)
  - **Future**: SOLID principles for robust OOP design

## 🔗 Related Topics

### Prerequisites Met ✅

- **Part 1A**: Classes and Objects fundamentals
  - **Part 1B**: Encapsulation and Abstraction

### Builds Upon 🏗️

- Object-oriented design principles
  - Code reuse strategies
  - Interface design patterns

### Enables 🎯

- **Advanced OOP**: Composition and design patterns
  - **SOLID Principles**: Dependency inversion, open-closed principle

## - **Framework Understanding**: Spring, .NET, Django inheritance patterns

**Module Status**: ✅ **Optimized** (175 lines, 27-minute focused learning)
**Part of**: OOP Fundamentals Domain - Lead Architect Learning Track
**Next Module**: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
