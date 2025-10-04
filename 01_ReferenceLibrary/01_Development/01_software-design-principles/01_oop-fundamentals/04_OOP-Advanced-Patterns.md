# 04_OOP-Advanced-Patterns

**Learning Level**: Intermediate  
**Prerequisites**: [01A1_OOP-Core-Concepts.md](01A1_OOP-Core-Concepts.md), [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md), [03_OOP-Inheritance-Polymorphism.md](03_OOP-Inheritance-Polymorphism.md)  
**Estimated Time**: 27 minutes  

## 🎯 Learning Objectives (27-Minute Session)

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

#### **Composition vs Inheritance: Strategic Decision Making**

**Golden Rule**: *"Favor composition over inheritance"*

```text
🎯 Decision Framework
====================

Inheritance (IS-A):        Composition (HAS-A):
├── Dog IS-A Animal       ├── Car HAS-A Engine  
├── Manager IS-A Employee ├── House HAS-A Kitchen
└── Circle IS-A Shape     └── Team HAS-A Members
```

**Composition Implementation Pattern**

```pseudocode
// Composition: Building complex objects from simpler ones
class Engine:
    start(): "Engine started"
    stop(): "Engine stopped"

class GPS:
    navigate(destination): "Route to " + destination

class Car:
    properties:
        engine: Engine          // HAS-A Engine
        gps: GPS               // HAS-A GPS
        brand: string
    
    methods:
        startCar():
            engine.start()      // Delegate to composed object
            return "Car ready to drive"
        
        navigateTo(destination):
            return gps.navigate(destination)  // Delegate behavior
```

#### **Abstract Classes vs Interfaces: Design Contracts**

```pseudocode
// Abstract Class: Shared implementation + contracts
abstract class DatabaseService:
    // Shared implementation
    validateConnection(): boolean
    logQuery(query): void
    
    // Contract (must implement)
    abstract connect(): Connection
    abstract executeQuery(sql): Results

// Interface: Pure contracts  
interface Serializable:
    serialize(): string
    deserialize(data): Object

interface Cacheable:
    getCacheKey(): string
    getExpiration(): number

// Implementation
class MySQLService extends DatabaseService implements Serializable:
    connect(): return mysql_connect()
    executeQuery(sql): return mysql_query(sql)
    serialize(): return JSON.stringify(this.connectionInfo)
    deserialize(data): return JSON.parse(data)
```

#### **Dependency Injection: Loose Coupling Pattern**

```pseudocode
// Without DI: Tight coupling (bad)
class EmailService:
    constructor():
        this.smtpClient = new SMTPClient()  // Hard dependency

// With DI: Loose coupling (good)
class EmailService:
    constructor(mailClient: IMailClient):   // Inject dependency
        this.mailClient = mailClient

// Interface contract
interface IMailClient:
    sendEmail(to, subject, body): boolean

// Multiple implementations
class SMTPClient implements IMailClient:
    sendEmail(to, subject, body): // SMTP implementation

class SendGridClient implements IMailClient:
    sendEmail(to, subject, body): // SendGrid API implementation

// Usage with DI
emailService = new EmailService(new SMTPClient())      // Production
emailService = new EmailService(new MockMailClient()) // Testing
```

#### **Enterprise Design Patterns**

```pseudocode
// Factory Pattern: Object creation abstraction
class DatabaseFactory:
    static createConnection(type):
        switch type:
            case "mysql": return new MySQLConnection()
            case "postgres": return new PostgreSQLConnection()
            case "mongodb": return new MongoDBConnection()

// Observer Pattern: Event-driven communication
interface Observer:
    update(event): void

class EventPublisher:
    observers: Observer[]
    
    subscribe(observer): observers.add(observer)
    notify(event): 
        for observer in observers:
            observer.update(event)

// Strategy Pattern: Interchangeable algorithms
interface PaymentStrategy:
    processPayment(amount): boolean

class CreditCardStrategy implements PaymentStrategy:
    processPayment(amount): // Credit card processing

class PayPalStrategy implements PaymentStrategy:
    processPayment(amount): // PayPal processing

class PaymentProcessor:
    constructor(strategy: PaymentStrategy):
        this.strategy = strategy
    
    processPayment(amount):
        return strategy.processPayment(amount)
```

### Practical Implementation (5 minutes)

#### **Real-World Enterprise Pattern**

```pseudocode
// Service Layer with DI
class UserService:
    constructor(userRepo, emailService, logger):
        this.userRepo = userRepo
        this.emailService = emailService  
        this.logger = logger
    
    registerUser(userData):
        user = new User(userData)
        savedUser = userRepo.save(user)
        emailService.sendWelcomeEmail(savedUser)
        logger.log("User registered: " + user.email)
        return savedUser

// DI Container (Framework concept)
container.register(UserRepository, DatabaseUserRepository)
userService = container.resolve(UserService)  // Auto-inject dependencies
```

### Key Takeaways & Next Steps (2 minutes)

#### **Essential Design Principles**

✅ **Composition over Inheritance**: Build flexible systems with HAS-A relationships  
✅ **Interface Segregation**: Small, focused contracts over large interfaces  
✅ **Dependency Injection**: Inject dependencies rather than creating them  
✅ **Single Responsibility**: Each class should have one reason to change  

#### **Best Practices**

- Abstract classes: shared implementation + contracts
- Interfaces: pure behavioral contracts  
- DI: testable, maintainable code

#### **Next Steps**

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
- **Enterprise Frameworks**: Spring, .NET, Django patterns

---
**Module Status**: ✅ **Optimized** (176 lines, 27-minute focused learning)  
**Completion**: ✅ **OOP Fundamentals Domain 100% Complete**
