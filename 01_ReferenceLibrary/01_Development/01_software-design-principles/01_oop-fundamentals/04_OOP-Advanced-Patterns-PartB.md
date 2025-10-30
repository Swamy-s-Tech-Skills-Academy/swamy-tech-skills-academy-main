# 04_OOP-Advanced-Patterns - Part B

**Learning Level**: Intermediate

**Prerequisites**: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Part B of 2 - Advanced Patterns

## 🎯 Learning Objectives

By the end of this session, you will

- Implement advanced behavioral and structural patterns
- Master dependency management in complex systems
- Apply SOLID principles in pattern implementations
- Design flexible, maintainable enterprise architectures

---
By the end of this session, you will:

- Make informed composition vs inheritance decisions
- Design with interfaces and abstract classes effectively
- Implement dependency injection for flexible systems
- Apply OOP best practices for enterprise-grade code

## 📋 Content Sections (27-Minute Structure)

### Quick Review (5 minutes)

**Foundation**: Classes, encapsulation, abstraction, inheritance, polymorphism
**Today's Focus**: Advanced architectural patterns for professional development

### Core Concepts (15 minutes)

### Composition vs Inheritance: Strategic Decision Making

**Golden Rule**: *"Favor composition over inheritance"*

```text
# 🎯 Decision Framework

Inheritance (IS-A):        Composition (HAS-A):
├── Dog IS-A Animal       ├── Car HAS-A Engine
├── Manager IS-A Employee ├── House HAS-A Kitchen
└── Circle IS-A Shape     └── Team HAS-A Members
```csharp

## Composition Implementation Pattern

```pseudocode

// Composition: Building complex objects from simpler ones
class Engine:
```csharp
start(): "Engine started"
```csharp
```csharp
stop(): "Engine stopped"
```csharp
class GPS:
```csharp
navigate(destination): "Route to " + destination
```csharp
class Car:
```csharp
properties:
```csharp
```csharp
    engine: Engine          // HAS-A Engine
```csharp
```csharp
    gps: GPS               // HAS-A GPS
```csharp
```csharp
    brand: string
```csharp
```csharp
methods:
```csharp
```csharp
    startCar():
```csharp
```csharp
        engine.start()      // Delegate to composed object
```csharp
```csharp
        return "Car ready to drive"
```csharp
```csharp
    navigateTo(destination):
```csharp
```csharp        return gps.navigate(destination)  // Delegate behavior
```csharp
```csharp

### Abstract Classes vs Interfaces: Design Contracts





```pseudocode
// Abstract Class: Shared implementation + contracts
abstract class DatabaseService:
```csharp
// Shared implementation
```csharp
```csharp
validateConnection(): boolean
```csharp
```csharp
logQuery(query): void
```csharp
```csharp
// Contract (must implement)
```csharp
```csharp
abstract connect(): Connection
```csharp
```csharp
abstract executeQuery(sql): Results
```csharp
// Interface: Pure contracts
interface Serializable:
```csharp
serialize(): string
```csharp
```csharp
deserialize(data): Object
```csharp
interface Cacheable:
```csharp
getCacheKey(): string
```csharp
```csharp
getExpiration(): number
```csharp
// Implementation
class MySQLService extends DatabaseService implements Serializable:
```csharp
connect(): return mysql_connect()
```csharp
```csharp
executeQuery(sql): return mysql_query(sql)
```csharp
```csharp
serialize(): return JSON.stringify(this.connectionInfo)
```csharp
```csharpdeserialize(data): return JSON.parse(data)
```csharp
```csharp

### Dependency Injection: Loose Coupling Pattern





```pseudocode
// Without DI: Tight coupling (bad)
class EmailService:
```csharp
constructor():
```csharp
```csharp
    this.smtpClient = new SMTPClient()  // Hard dependency
```csharp
// With DI: Loose coupling (good)
class EmailService:
```csharp
constructor(mailClient: IMailClient):   // Inject dependency
```csharp
```csharp
    this.mailClient = mailClient
```csharp
// Interface contract
interface IMailClient:
```csharp
sendEmail(to, subject, body): boolean
```csharp
// Multiple implementations
class SMTPClient implements IMailClient:
```csharp
sendEmail(to, subject, body): // SMTP implementation
```csharp
class SendGridClient implements IMailClient:
```csharp
sendEmail(to, subject, body): // SendGrid API implementation
```csharp
// Usage with DI
emailService = new EmailService(new SMTPClient())      // Production
emailService = new EmailService(new MockMailClient()) // Testing
```csharp

### Enterprise Design Patterns





```pseudocode
// Factory Pattern: Object creation abstraction
class DatabaseFactory:
```csharp
static createConnection(type):
```csharp
```csharp
    switch type:
```csharp
```csharp
        case "mysql": return new MySQLConnection()
```csharp
```csharp
        case "postgres": return new PostgreSQLConnection()
```csharp
```csharp
        case "mongodb": return new MongoDBConnection()
```csharp
// Observer Pattern: Event-driven communication
interface Observer:
```csharp
update(event): void
```csharp
class EventPublisher:
```csharp
observers: Observer[]
```csharp
```csharp
subscribe(observer): observers.add(observer)
```csharp
```csharp
notify(event):
```csharp
```csharp
    for observer in observers:
```csharp
```csharp
        observer.update(event)
```csharp
// Strategy Pattern: Interchangeable algorithms
interface PaymentStrategy:
```csharp
processPayment(amount): boolean
```csharp
class CreditCardStrategy implements PaymentStrategy:
```csharp
processPayment(amount): // Credit card processing
```csharp
class PayPalStrategy implements PaymentStrategy:
```csharp
processPayment(amount): // PayPal processing
```csharp
class PaymentProcessor:
```csharp
constructor(strategy: PaymentStrategy):
```csharp
```csharp
    this.strategy = strategy
```csharp
```csharp
processPayment(amount):
```csharp
```csharp    return strategy.processPayment(amount)
```csharp
```csharp

### Practical Implementation (5 minutes)





### Real-World Enterprise Pattern





```pseudocode
// Service Layer with DI
class UserService:
```csharp
constructor(userRepo, emailService, logger):
```csharp
```csharp
    this.userRepo = userRepo
```csharp
```csharp
    this.emailService = emailService
```csharp
```csharp
    this.logger = logger
```csharp
```csharp
    user = new User(userData)
```csharp
```csharp
    savedUser = userRepo.save(user)
```csharp
```csharp
    emailService.sendWelcomeEmail(savedUser)
```csharp
```csharp
    logger.log("User registered: " + user.email)
```csharp
```csharp
    return savedUser
```csharp
// DI Container (Framework concept)
container.register(UserRepository, DatabaseUserRepository)
userService = container.resolve(UserService)  // Auto-inject dependencies
```csharp

### Key Takeaways & Next Steps (2 minutes)





### Essential Design Principles





✅ **Composition over Inheritance**: Build flexible systems with HAS-A relationships
✅ **Interface Segregation**: Small, focused contracts over large interfaces
✅ **Dependency Injection**: Inject dependencies rather than creating them
✅ **Single Responsibility**: Each class should have one reason to change

### Best Practices





- Abstract classes: shared implementation + contracts
  - Interfaces: pure behavioral contracts
  - DI: testable, maintainable code

### Next Steps





- **Immediate**: Practice implementing these patterns in your preferred language
  - **Advanced**: Study SOLID principles for robust OOP design
  - **Enterprise**: Learn framework-specific DI containers (Spring, .NET Core, etc.)

## 🔗 Related Topics

### Prerequisites Met ✅





- **Parts 1A-1C**: Complete OOP fundamentals mastery
  - **Design Thinking**: Problem decomposition and abstraction

### Builds Upon 🏗️





- Inheritance and polymorphism concepts
  - Interface and abstract class understanding
  - Enterprise software architecture principles

### Enables 🎯





- **SOLID Principles**: Advanced OOP design principles
  - **Design Patterns**: Gang of Four patterns implementation
##   - **Enterprise Frameworks**: Spring, .NET, Django patterns
## Part B of 2

Previous: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)

---
