# 04_OOP-Advanced-Patterns - Part B\n\n**Learning Level**: Intermediate

**Prerequisites**: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
**Estimated Time**: 27 minutes (focused learning session)
**Series**: Part B of 2 - Advanced Patterns
---

## 🎯 Learning Objectives\n\nBy the end of this session, you will

- [Add specific learning objectives]

---
By the end of this session, you will:

- Make informed composition vs inheritance decisions
- Design with interfaces and abstract classes effectively
- Implement dependency injection for flexible systems
- Apply OOP best practices for enterprise-grade code\n\n## 📋 Content Sections (27-Minute Structure)\n\n### Quick Review (5 minutes)

\n\n\n\n**Foundation**: Classes, encapsulation, abstraction, inheritance, polymorphism
**Today's Focus**: Advanced architectural patterns for professional development

### Core Concepts (15 minutes)

\n\n

### Composition vs Inheritance: Strategic Decision Making

\n\n\n\n**Golden Rule**: *"Favor composition over inheritance"*

```text
🎯 Decision Framework
====================
Inheritance (IS-A):        Composition (HAS-A):
├── Dog IS-A Animal       ├── Car HAS-A Engine
├── Manager IS-A Employee ├── House HAS-A Kitchen
└── Circle IS-A Shape     └── Team HAS-A Members
```csharp

## Composition Implementation Pattern\n\n```pseudocode

// Composition: Building complex objects from simpler ones
class Engine:
```csharp\nstart(): "Engine started"\n```csharp\n```csharp\nstop(): "Engine stopped"\n```csharp\nclass GPS:
```csharp\nnavigate(destination): "Route to " + destination\n```csharp\nclass Car:
```csharp\nproperties:\n```csharp\n```csharp\n    engine: Engine          // HAS-A Engine\n```csharp\n```csharp\n    gps: GPS               // HAS-A GPS\n```csharp\n```csharp\n    brand: string\n```csharp\n```csharp\nmethods:\n```csharp\n```csharp\n    startCar():\n```csharp\n```csharp\n        engine.start()      // Delegate to composed object\n```csharp\n```csharp\n        return "Car ready to drive"\n```csharp\n```csharp\n    navigateTo(destination):\n```csharp\n```csharp        return gps.navigate(destination)  // Delegate behavior
```csharp\n```csharp

### Abstract Classes vs Interfaces: Design Contracts

\n\n\n\n```pseudocode
// Abstract Class: Shared implementation + contracts
abstract class DatabaseService:
```csharp\n// Shared implementation\n```csharp\n```csharp\nvalidateConnection(): boolean\n```csharp\n```csharp\nlogQuery(query): void\n```csharp\n```csharp\n// Contract (must implement)\n```csharp\n```csharp\nabstract connect(): Connection\n```csharp\n```csharp\nabstract executeQuery(sql): Results\n```csharp\n// Interface: Pure contracts
interface Serializable:
```csharp\nserialize(): string\n```csharp\n```csharp\ndeserialize(data): Object\n```csharp\ninterface Cacheable:
```csharp\ngetCacheKey(): string\n```csharp\n```csharp\ngetExpiration(): number\n```csharp\n// Implementation
class MySQLService extends DatabaseService implements Serializable:
```csharp\nconnect(): return mysql_connect()\n```csharp\n```csharp\nexecuteQuery(sql): return mysql_query(sql)\n```csharp\n```csharp\nserialize(): return JSON.stringify(this.connectionInfo)\n```csharp\n```csharpdeserialize(data): return JSON.parse(data)
```csharp\n```csharp

### Dependency Injection: Loose Coupling Pattern

\n\n\n\n```pseudocode
// Without DI: Tight coupling (bad)
class EmailService:
```csharp\nconstructor():\n```csharp\n```csharp\n    this.smtpClient = new SMTPClient()  // Hard dependency\n```csharp\n// With DI: Loose coupling (good)
class EmailService:
```csharp\nconstructor(mailClient: IMailClient):   // Inject dependency\n```csharp\n```csharp\n    this.mailClient = mailClient\n```csharp\n// Interface contract
interface IMailClient:
```csharp\nsendEmail(to, subject, body): boolean\n```csharp\n// Multiple implementations
class SMTPClient implements IMailClient:
```csharp\nsendEmail(to, subject, body): // SMTP implementation\n```csharp\nclass SendGridClient implements IMailClient:
```csharp\nsendEmail(to, subject, body): // SendGrid API implementation\n```csharp\n// Usage with DI
emailService = new EmailService(new SMTPClient())      // Production
emailService = new EmailService(new MockMailClient()) // Testing
```csharp

### Enterprise Design Patterns

\n\n\n\n```pseudocode
// Factory Pattern: Object creation abstraction
class DatabaseFactory:
```csharp\nstatic createConnection(type):\n```csharp\n```csharp\n    switch type:\n```csharp\n```csharp\n        case "mysql": return new MySQLConnection()\n```csharp\n```csharp\n        case "postgres": return new PostgreSQLConnection()\n```csharp\n```csharp\n        case "mongodb": return new MongoDBConnection()\n```csharp\n// Observer Pattern: Event-driven communication
interface Observer:
```csharp\nupdate(event): void\n```csharp\nclass EventPublisher:
```csharp\nobservers: Observer[]\n```csharp\n```csharp\nsubscribe(observer): observers.add(observer)\n```csharp\n```csharp\nnotify(event):\n```csharp\n```csharp\n    for observer in observers:\n```csharp\n```csharp\n        observer.update(event)\n```csharp\n// Strategy Pattern: Interchangeable algorithms
interface PaymentStrategy:
```csharp\nprocessPayment(amount): boolean\n```csharp\nclass CreditCardStrategy implements PaymentStrategy:
```csharp\nprocessPayment(amount): // Credit card processing\n```csharp\nclass PayPalStrategy implements PaymentStrategy:
```csharp\nprocessPayment(amount): // PayPal processing\n```csharp\nclass PaymentProcessor:
```csharp\nconstructor(strategy: PaymentStrategy):\n```csharp\n```csharp\n    this.strategy = strategy\n```csharp\n```csharp\nprocessPayment(amount):\n```csharp\n```csharp    return strategy.processPayment(amount)
```csharp\n```csharp

### Practical Implementation (5 minutes)

\n\n

### Real-World Enterprise Pattern

\n\n\n\n```pseudocode
// Service Layer with DI
class UserService:
```csharp\nconstructor(userRepo, emailService, logger):\n```csharp\n```csharp\n    this.userRepo = userRepo\n```csharp\n```csharp\n    this.emailService = emailService\n```csharp\n```csharp\n    this.logger = logger\n```csharp\n```csharp\n    user = new User(userData)\n```csharp\n```csharp\n    savedUser = userRepo.save(user)\n```csharp\n```csharp\n    emailService.sendWelcomeEmail(savedUser)\n```csharp\n```csharp\n    logger.log("User registered: " + user.email)\n```csharp\n```csharp\n    return savedUser\n```csharp\n// DI Container (Framework concept)
container.register(UserRepository, DatabaseUserRepository)
userService = container.resolve(UserService)  // Auto-inject dependencies
```csharp

### Key Takeaways & Next Steps (2 minutes)

\n\n

### Essential Design Principles

\n\n\n\n✅ **Composition over Inheritance**: Build flexible systems with HAS-A relationships
✅ **Interface Segregation**: Small, focused contracts over large interfaces
✅ **Dependency Injection**: Inject dependencies rather than creating them
✅ **Single Responsibility**: Each class should have one reason to change

### Best Practices

\n\n\n\n- Abstract classes: shared implementation + contracts
  - Interfaces: pure behavioral contracts
  - DI: testable, maintainable code\n\n### Next Steps

\n\n\n\n- **Immediate**: Practice implementing these patterns in your preferred language
  - **Advanced**: Study SOLID principles for robust OOP design
  - **Enterprise**: Learn framework-specific DI containers (Spring, .NET Core, etc.)\n\n## ðŸ”— Related Topics\n\n### Prerequisites Met ✅

\n\n\n\n- **Parts 1A-1C**: Complete OOP fundamentals mastery
  - **Design Thinking**: Problem decomposition and abstraction\n\n### Builds Upon 🏗️

\n\n\n\n- Inheritance and polymorphism concepts
  - Interface and abstract class understanding
  - Enterprise software architecture principles\n\n### Enables 🎯

\n\n\n\n- **SOLID Principles**: Advanced OOP design principles
  - **Design Patterns**: Gang of Four patterns implementation
  - **Enterprise Frameworks**: Spring, .NET, Django patterns
---

## Part B of 2\n\nPrevious: [04_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)

---
