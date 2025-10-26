# 03_OOP-Inheritance-Polymorphism\n\n**Learning Level**: Beginner → Intermediate

**Prerequisites**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Core Pillars - Inheritance & Polymorphism

## 🎯 Learning Objectives\n\nBy the end of this session, you will

- [Add specific learning objectives]

---
By the end of this session, you will:

- Master inheritance for code reuse through parent-child relationships
- Understand polymorphism for flexible behavior implementation
- Implement method overriding and interface contracts
- Design maintainable class hierarchies\n\n## 📋 Content Sections (27-Minute Structure)\n\n### Quick Review (5 minutes)

\n\n\n\n**Previous Concepts**: Classes, objects, encapsulation, abstraction
**Today's Focus**: Code reuse (inheritance) and flexible behavior (polymorphism)

### Core Concepts (15 minutes)

\n\n

### **Inheritance: Code Reuse Architecture**

\n\n\n\n**Definition**: Child classes inherit properties/methods from parent classes while adding specialization

```text
# 📊 Inheritance Hierarchy\n\n```csharp\nVehicle (Parent)\n```csharp\n```csharp\n├── properties: brand, model, year\n```csharp\n```csharp\n├── methods: start(), stop(), getInfo()\n```csharp\n    │
```csharp\n├── Car (Child)\n```csharp\n```csharp\n│   ├── properties: doors, fuelType\n```csharp\n```csharp\n│   └── methods: openTrunk(), lockDoors()\n```csharp\n    │
```csharp\n└── Motorcycle (Child)\n```csharp\n```csharp\n    ├── properties: engineSize, hasWindshield\n```csharp\n```csharp    └── methods: wheelie(), leanIntoTurn()
```csharp\n```csharp**Key Principle**: "IS-A" relationship (Car IS-A Vehicle)

### **Language-Agnostic Implementation Pattern**

\n\n
```pseudocode\n\n// Parent Class Definition
class Vehicle:
```csharp\nproperties:\n```csharp\n```csharp\n    brand: string\n```csharp\n```csharp\n    model: string\n```csharp\n```csharp\n    year: integer\n```csharp\n```csharp\nmethods:\n```csharp\n```csharp\n    start(): "Engine starting..."\n```csharp\n```csharp\n    stop(): "Engine stopping..."\n```csharp\n```csharp\n    getInfo(): return brand + model + year\n```csharp\n// Child Class Definition
class Car extends Vehicle:
```csharp\nproperties:\n```csharp\n```csharp\n    doors: integer\n```csharp\n```csharp\n    fuelType: string\n```csharp\n```csharp\nmethods:\n```csharp\n```csharp\n    // Inherited: start(), stop(), getInfo()\n```csharp\n```csharp\n    openTrunk(): "Trunk opened"\n```csharp\n```csharp\n    lockDoors(): "Doors locked"\n```csharp\n```csharp\n    // Override parent method\n```csharp\n```csharp    start(): "Car engine starting with key..."
```csharp\n```csharp#### **Polymorphism: One Interface, Multiple Behaviors**
**Definition**: Same method call produces different behaviors based on object type.

```text
# 🔄 Polymorphic Behavior\n\nvehicles = [Car, Motorcycle, Truck]
for each vehicle in vehicles:
```csharp\nvehicle.start()  // Same call, different behavior:\n```csharp\n```csharp\nCar: "Car engine starting with key..."\n```csharp\n```csharp\nMotorcycle: "Motorcycle engine roaring to life..."\n```csharp\n```csharpTruck: "Diesel engine warming up..."
```csharp\n```csharp#### **Method Overriding vs Method Overloading**

```pseudocode
// Method Overriding (Same signature, different implementation)
class Animal:
```csharp\nmakeSound(): "Some generic sound"\n```csharp\nclass Dog extends Animal:
```csharp\nmakeSound(): "Woof! Woof!"  // Override\n```csharp\nclass Cat extends Animal:
```csharp\nmakeSound(): "Meow! Meow!" // Override\n```csharp\n// Method Overloading (Same name, different parameters)
class Calculator:
```csharp\nadd(a, b): return a + b\n```csharp\n```csharp\nadd(a, b, c): return a + b + c\n```csharp\n```csharpadd(numbers[]): return sum of all numbers
```csharp\n```csharp### Practical Implementation (5 minutes)

### **Enterprise Design Pattern Example**

\n\n
```pseudocode\n\n// Abstract base class
abstract class DatabaseConnection:
```csharp\nabstract connect(): connection\n```csharp\n```csharp\nabstract disconnect(): void\n```csharp\n```csharp\n// Shared behavior\n```csharp\n```csharp\nvalidateCredentials(): boolean\n```csharp\n```csharp\nlogActivity(): void\n```csharp\n// Concrete implementations
class MySQLConnection extends DatabaseConnection:
```csharp\nconnect():\n```csharp\n```csharp\n    // MySQL-specific connection logic\n```csharp\n```csharp\n    return mysql_connect(host, user, password)\n```csharp\n```csharp\ndisconnect():\n```csharp\n```csharp\n    mysql_close(connection)\n```csharp\nclass PostgreSQLConnection extends DatabaseConnection:
```csharp\nconnect():\n```csharp\n```csharp\n    // PostgreSQL-specific connection logic\n```csharp\n```csharp\n    return pg_connect(connectionString)\n```csharp\n```csharp\ndisconnect():\n```csharp\n```csharp\n    pg_close(connection)\n```csharp\n// Polymorphic usage
function connectToDatabase(dbType):
```csharp\nconnection = createConnection(dbType)  // Factory pattern\n```csharp\n```csharp\nconnection.connect()                   // Polymorphic call\n```csharp\n```csharpreturn connection
```csharp\n```csharp#### **Interface-Based Design**

```pseudocode
// Interface contract
interface Drawable:
```csharp\ndraw(): void\n```csharp\n```csharp\ncalculateArea(): number\n```csharp\n// Multiple inheritance through interfaces
class Circle implements Drawable:
```csharp\nradius: number\n```csharp\n```csharp\ndraw(): "Drawing circle with radius " + radius\n```csharp\n```csharp\ncalculateArea(): return π * radius²\n```csharp\nclass Rectangle implements Drawable:
```csharp\nwidth: number\n```csharp\n```csharp\nheight: number\n```csharp\n```csharp\ndraw(): "Drawing rectangle " + width + "x" + height\n```csharp\n```csharp\ncalculateArea(): return width * height\n```csharp\n// Polymorphic rendering
shapes: Drawable[] = [Circle, Rectangle, Triangle]
for shape in shapes:
```csharp\nshape.draw()                    // Same interface\n```csharp\n```csharparea = shape.calculateArea()    // Different implementations
```csharp\n```\n\n### Key Takeaways & Next Steps (2 minutes)
\n\n

### **Essential Principles**

\n\n\n\n✅ **Inheritance**: Use for "IS-A" relationships and code reuse
✅ **Polymorphism**: Enable flexible behavior through common interfaces
✅ **Method Overriding**: Specialize parent behavior in child classes
✅ **Interface Design**: Define contracts for consistent behavior

### **Best Practices**

\n\n\n\n- Prefer composition over inheritance when possible
  - Keep inheritance hierarchies shallow (2-3 levels max)
  - Use abstract classes for shared implementation
  - Use interfaces for behavioral contracts\n\n### **Next Steps**

\n\n\n\n- **Immediate**: Practice implementing inheritance hierarchies
  - **Part 1D**: Advanced patterns (composition, design patterns)
  - **Future**: SOLID principles for robust OOP design\n\n## 🔗 Related Topics\n\n### Prerequisites Met ✅

\n\n\n\n- **Part 1A**: Classes and Objects fundamentals
  - **Part 1B**: Encapsulation and Abstraction\n\n### Builds Upon 🏗️

\n\n\n\n- Object-oriented design principles
  - Code reuse strategies
  - Interface design patterns\n\n### Enables 🎯

\n\n\n\n- **Advanced OOP**: Composition and design patterns
  - **SOLID Principles**: Dependency inversion, open-closed principle
##   - **Framework Understanding**: Spring, .NET, Django inheritance patterns\n\n**Module Status**: ✅ **Optimized** (175 lines, 27-minute focused learning)
**Part of**: OOP Fundamentals Domain - Lead Architect Learning Track
**Next Module**: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
