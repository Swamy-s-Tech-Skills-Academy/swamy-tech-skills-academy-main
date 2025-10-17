# 03_OOP-Inheritance-Polymorphism

**Learning Level**: Beginner to Intermediate  
**Prerequisites**: [01A1_OOP-Core-Concepts.md](01A1_OOP-Core-Concepts.md), [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)  
**Estimated Time**: 27 minutes  

## 🎯 Learning Objectives (27-Minute Session)

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

#### **Inheritance: Code Reuse Architecture**

**Definition**: Child classes inherit properties/methods from parent classes while adding specialization.

```text
📊 Inheritance Hierarchy
========================

    Vehicle (Parent)
    ├── properties: brand, model, year
    ├── methods: start(), stop(), getInfo()
    │
    ├── Car (Child)
    │   ├── properties: doors, fuelType
    │   └── methods: openTrunk(), lockDoors()
    │
    └── Motorcycle (Child)
        ├── properties: engineSize, hasWindshield
        └── methods: wheelie(), leanIntoTurn()
```

**Key Principle**: "IS-A" relationship (Car IS-A Vehicle)

#### **Language-Agnostic Implementation Pattern**

```pseudocode
// Parent Class Definition
class Vehicle:
    properties:
        brand: string
        model: string
        year: integer
    
    methods:
        start(): "Engine starting..."
        stop(): "Engine stopping..."
        getInfo(): return brand + model + year

// Child Class Definition  
class Car extends Vehicle:
    properties:
        doors: integer
        fuelType: string
    
    methods:
        // Inherited: start(), stop(), getInfo()
        openTrunk(): "Trunk opened"
        lockDoors(): "Doors locked"
        
        // Override parent method
        start(): "Car engine starting with key..."
```

#### **Polymorphism: One Interface, Multiple Behaviors**

**Definition**: Same method call produces different behaviors based on object type.

```text
🔄 Polymorphic Behavior
======================

vehicles = [Car, Motorcycle, Truck]

for each vehicle in vehicles:
    vehicle.start()  // Same call, different behavior:
    
    Car: "Car engine starting with key..."
    Motorcycle: "Motorcycle engine roaring to life..."
    Truck: "Diesel engine warming up..."
```

#### **Method Overriding vs Method Overloading**

```pseudocode
// Method Overriding (Same signature, different implementation)
class Animal:
    makeSound(): "Some generic sound"

class Dog extends Animal:
    makeSound(): "Woof! Woof!"  // Override

class Cat extends Animal:  
    makeSound(): "Meow! Meow!" // Override

// Method Overloading (Same name, different parameters)
class Calculator:
    add(a, b): return a + b
    add(a, b, c): return a + b + c
    add(numbers[]): return sum of all numbers
```

### Practical Implementation (5 minutes)

#### **Enterprise Design Pattern Example**

```pseudocode
// Abstract base class
abstract class DatabaseConnection:
    abstract connect(): connection
    abstract disconnect(): void
    
    // Shared behavior
    validateCredentials(): boolean
    logActivity(): void

// Concrete implementations
class MySQLConnection extends DatabaseConnection:
    connect(): 
        // MySQL-specific connection logic
        return mysql_connect(host, user, password)
    
    disconnect():
        mysql_close(connection)

class PostgreSQLConnection extends DatabaseConnection:
    connect():
        // PostgreSQL-specific connection logic  
        return pg_connect(connectionString)
    
    disconnect():
        pg_close(connection)

// Polymorphic usage
function connectToDatabase(dbType):
    connection = createConnection(dbType)  // Factory pattern
    connection.connect()                   // Polymorphic call
    return connection
```

#### **Interface-Based Design**

```pseudocode
// Interface contract
interface Drawable:
    draw(): void
    calculateArea(): number

// Multiple inheritance through interfaces
class Circle implements Drawable:
    radius: number
    
    draw(): "Drawing circle with radius " + radius
    calculateArea(): return π * radius²

class Rectangle implements Drawable:
    width: number
    height: number
    
    draw(): "Drawing rectangle " + width + "x" + height  
    calculateArea(): return width * height

// Polymorphic rendering
shapes: Drawable[] = [Circle, Rectangle, Triangle]
for shape in shapes:
    shape.draw()                    // Same interface
    area = shape.calculateArea()    // Different implementations
```

### Key Takeaways & Next Steps (2 minutes)

#### **Essential Principles**

✅ **Inheritance**: Use for "IS-A" relationships and code reuse  
✅ **Polymorphism**: Enable flexible behavior through common interfaces  
✅ **Method Overriding**: Specialize parent behavior in child classes  
✅ **Interface Design**: Define contracts for consistent behavior  

#### **Best Practices**

- Prefer composition over inheritance when possible
- Keep inheritance hierarchies shallow (2-3 levels max)
- Use abstract classes for shared implementation
- Use interfaces for behavioral contracts

#### **Next Steps**

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
- **Framework Understanding**: Spring, .NET, Django inheritance patterns

---

**Module Status**: ✅ **Optimized** (175 lines, 27-minute focused learning)  
**Part of**: OOP Fundamentals Domain - Lead Architect Learning Track  
**Next Module**: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
