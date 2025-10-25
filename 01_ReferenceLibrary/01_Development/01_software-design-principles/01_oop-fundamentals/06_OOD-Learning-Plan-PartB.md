# Learning Object Oriented Design - Part B

**Learning Level**: Intermediate
**Prerequisites**: [06_OOD-Learning-Plan-PartA.md](06_OOD-Learning-Plan-PartA.md)
**Estimated Time**: 27 minutes (planning session)
**Series**: Part B of 2 - OOD Learning Plan

---

## 🎯 Learning Objectives

By the end of this session, you will:

- [Add specific learning objectives]

---

**Part B of 2**

Previous: [06_OOD-Learning-Plan-PartA.md](06_OOD-Learning-Plan-PartA.md)

---

- Review and solidify core OOD principles: **Encapsulation**, **Abstraction**, **Inheritance**, and **Polymorphism**.
- **Encapsulation:** Practice defining access modifiers (`public`, `private`, `protected`, and `internal`) and using properties to encapsulate data.
- **Abstraction:** Work on creating base classes and interfaces, abstracting behaviors and properties.

2. **Exercises in C#:**

   - Implement a **Shape hierarchy** where you have base classes like `Shape`, with derived classes such as `Circle`, `Rectangle`, etc. Each class should implement a method like `Draw` or `Area`.
   - Use **interfaces** to define behaviors like `IMovable`, `IDrawable`, etc., to practice polymorphism.

3. **Reading and Resources:**
   - "Design Patterns: Elements of Reusable Object-Oriented Software" - the classic for learning the language of OOD.
   - **C# Documentation on Polymorphism**: Microsoft's documentation to clarify polymorphic behavior in C#.

---

### **Week 2: SOLID Principles in Depth**

1. **Goal:** Master the SOLID principles for writing clean, extensible, and maintainable code:

   - **Single Responsibility Principle (SRP):** Each class should have one reason to change.
   - **Open/Closed Principle (OCP):** Classes should be open for extension but closed for modification.
   - **Liskov Substitution Principle (LSP):** Subtypes must be substitutable for their base types.
   - **Interface Segregation Principle (ISP):** Prefer many small interfaces over one large interface.
   - **Dependency Inversion Principle (DIP):** Depend on abstractions, not on concretions.

2. **Exercises in C#:**

   - Refactor an e-commerce class with SRP, OCP, and DIP principles.
   - Design a **Notification System** where various notification types (e.g., SMS, Email, Push) follow the ISP and DIP.

3. **Reading and Resources:**
   - â€œClean Codeâ€ by Robert C. Martin for SOLID-focused examples.
   - Pluralsight or LinkedIn Learning courses on **SOLID Principles in C#**.

---

### **Week 3: Design Patterns Essentials**

1. **Goal:** Learn foundational design patterns for C# that support modular and reusable code:

   - **Creational Patterns**: Factory, Singleton.
   - **Structural Patterns**: Adapter, Composite.
   - **Behavioral Patterns**: Strategy, Observer.

2. **Exercises in C#:**

   - Implement a **Factory Pattern** to create instances of different shapes (e.g., circle, square).
   - Use the **Singleton Pattern** for a configuration manager or logger.
   - Create a **Strategy Pattern** for payment processing methods, allowing dynamic selection of payment type at runtime.
   - Use the **Observer Pattern** for a real-time notification system, where different modules are notified of changes (e.g., email, SMS, in-app).

3. **Reading and Resources:**
   - â€œHead First Design Patternsâ€ â€“ for a more engaging take on classic patterns.
   - Online videos/tutorials for C#-specific pattern implementations.

---

### **Week 4: Advanced Design Patterns and Practical Application**

1. **Goal:** Apply more advanced patterns and evaluate when they are suitable.

   - **Dependency Injection (DI)**: Use DI for managing dependencies and reducing coupling.
   - **Decorator Pattern**: For adding responsibilities dynamically to objects.
   - **Command Pattern**: Especially useful in scenarios like implementing Undo functionality.
   - **Chain of Responsibility**: For request processing systems (e.g., filtering or logging).

2. **Exercises in C#:**

   - Implement a **DI container** using .NETâ€™s `IServiceCollection` for an MVC application.
   - Create a **Logger** using the **Decorator Pattern** that can add functionality like timestamping, file logging, and console logging dynamically.
   - Design a **Command Pattern** for a remote control system where each command (like `TurnOn`, `TurnOff`, `VolumeUp`, etc.) can be executed and undone.

3. **Reading and Resources:**
   - â€œDependency Injection in .NETâ€ by Mark Seemann.
   - Tutorials for implementing custom DI in .NET applications.

---

### **Week 5: Applied Object-Oriented Design - Real-World Systems**

1. **Project-Based Learning:**

   - Design a **Library Management System**: Focus on core classes like `Library`, `Book`, `Member`, `Loan`, etc., and use inheritance and composition effectively.
   - Implement multiple patterns and SOLID principles where applicable.

2. **Exercises in C#:**

   - Write unit tests for each component to verify SOLID principles and patterns.
   - Add a layer of abstraction by separating data access from business logic using the Repository Pattern.

3. **Reading and Resources:**
   - Practicing by designing small systems like a **To-Do List application** or **Inventory Management System** to apply OOD principles.
   - Explore Pluralsightâ€™s Object-Oriented Design Fundamentals course.

---

### **Week 6: Final Project - Capstone and Real-World Implementation**

1. **Design a Real-World Application:**

   - **Example Project:** Develop an **Event Management System**. Incorporate multiple design patterns, layering, SOLID principles, and a focus on reusability and flexibility.

2. **Project Deliverables:**

   - **Domain Modeling:** Build a class model, defining relationships between entities like `Event`, `Attendee`, `Venue`, and `Ticket`.
   - **Scalability & Extensibility:** Apply SOLID principles and design patterns to make the application extensible for new features (like online payments, notifications).
   - **Documentation:** Document your design decisions, how each design pattern supports extensibility, and provide a justification for each key architectural choice.

3. **Review and Reflection:**
   - Review your code for adherence to OOD and SOLID principles.
   - Reflect on design choices and areas for improvement.

---

### **Additional Resources for C# OOD Mastery**

- **Books:**
  - "Pro C# 9 with .NET Core" by Andrew Troelsen and Philip Japikse, which includes many practical examples.

- **Courses:**
  - Pluralsight: **C# Design Patterns** and **SOLID Principles**.

  - LinkedIn Learning: **C# Object-Oriented Programming**.

---

### Summary Plan Outline

| **Week** | **Objective**                     | **Focus Areas**                                                |
| -------- | --------------------------------- | -------------------------------------------------------------- |
| Week 1   | Core OOD Principles               | Encapsulation, Abstraction, Polymorphism, Inheritance          |
| Week 2   | SOLID Principles in C#            | SRP, OCP, LSP, ISP, DIP                                        |

| Week 3   | Design Patterns Essentials        | Factory, Singleton, Strategy, Observer                         |
| Week 4   | Advanced Design Patterns          | DI, Decorator, Command, Chain of Responsibility                |
| Week 5   | Applied OOD in Real-World Systems | Library Management System, To-Do List Application              |
| Week 6   | Final Project                     | Event Management System, Real-world application, Documentation |

---

This plan will build a comprehensive understanding of OOD, SOLID principles, and C# design patterns, setting you up for success in a Principal Software Engineer role. Let me know if you'd like more examples, specific guidance on any pattern, or help with coding exercises!
