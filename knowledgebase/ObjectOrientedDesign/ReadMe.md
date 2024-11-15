# Learning Object Oriented Design

## Overview

This four-week plan will help you master OOD principles, understand design patterns, and practice implementing OOD concepts in C#. Each week has specific goals, topics, and exercises to build and test your understanding progressively.

---

## **Week 1: Core OOD Concepts**

### **Goals**

- Understand the fundamentals of Object-Oriented Programming (OOP).
- Explore and implement **interfaces**, **abstraction**, **inheritance**, and **polymorphism** in C#.

### **Topics to Cover**

1. **Introduction to OOP and OOD**
2. **Encapsulation** and **data hiding**
3. **Abstraction**: Abstract classes vs. Interfaces
4. **Interfaces in C#**: Declaring, implementing, and extending interfaces
5. **Polymorphism and Inheritance**: Overriding and virtual methods

### **Exercises**

1. Create classes for a simple inventory management system, with interfaces for **IProduct** (e.g., `AddProduct()`, `RemoveProduct()`) and **ICategory**.
2. Practice creating and implementing an interface for a **PaymentSystem** (e.g., `IPaymentMethod`) with multiple payment methods (`CreditCard`, `PayPal`, etc.).
3. Implement a **Shape** hierarchy, using an `IShape` interface for `Draw()` and `CalculateArea()` methods, and classes like `Circle`, `Rectangle`, etc.

---

## **Week 2: SOLID Principles and Design Patterns**

### **Goals**

- Learn and apply the **SOLID principles** for better OOD.
- Get familiar with design patterns that leverage interfaces and abstraction.

### **Topics to Cover**

1. **SOLID Principles**:
   - **Single Responsibility Principle (SRP)**
   - **Open/Closed Principle (OCP)**
   - **Liskov Substitution Principle (LSP)**
   - **Interface Segregation Principle (ISP)**
   - **Dependency Inversion Principle (DIP)**
2. **Key Design Patterns**:
   - **Factory Method** and **Abstract Factory**
   - **Strategy Pattern**
   - **Decorator Pattern**

### **Exercises**

1. **Refactor Code**: Take any simple system (e.g., inventory or user management) and apply SOLID principles to it.
2. **Implement Patterns**:
   - **Strategy Pattern**: Implement a strategy for `IPaymentMethod` to handle multiple payment options without altering the primary payment processing class.
   - **Decorator Pattern**: Create decorators to add additional responsibilities to a `Notification` class, e.g., `SMSNotification`, `EmailNotification`.
3. **ISP Exercise**: Define a large interface, break it down into smaller, more specific interfaces, and refactor classes to implement only what’s necessary.

---

## **Week 3: Advanced OOD with Real-World Problem-Solving**

### **Goals**

- Practice designing systems with a focus on scalability and maintainability.
- Learn to break down a problem and identify classes, relationships, and interfaces.

### **Topics to Cover**

1. **Abstraction and Modularity**: Identifying abstractions in problem statements.
2. **System Design Principles**: Cohesion, coupling, and modularity.
3. **Common Object-Oriented Design Problems**:
   - Design a Parking Lot system.
   - Design an ATM machine.
   - Design a File System structure.

### **Exercises**

1. **Design a Library System**:
   - Identify key entities (`Book`, `User`, `Library`) and behaviors.
   - Create interfaces for `ILibraryActions` (e.g., `CheckOutBook()`, `ReturnBook()`).
2. **Design a Notification System**:
   - Design interfaces like `INotificationService` for different types of notifications (`Email`, `SMS`, `Push`).
   - Implement classes to use a **Factory pattern** for notification creation.
3. **OOD Case Study**: Pick a problem from a past interview question bank and work through the system design.

---

## **Week 4: Mock Interviews and Review**

### **Goals**

- Review key concepts and practice live coding.
- Focus on real-time problem-solving and communicating design decisions effectively.

### **Topics to Cover**

1. **Mock Interview Questions**:
   - Practice with mock OOD interview questions.
   - Get comfortable explaining your design decisions clearly and concisely.
2. **Review of SOLID, Design Patterns, and Key Concepts**.
3. **Common Pitfalls and Best Practices in OOD Interviews**:
   - Avoid over-engineering.
   - Focus on flexibility, reusability, and clarity.

### **Exercises**

1. **Mock Interview Questions**:
   - **Design a Movie Booking System**.
   - **Design a Hotel Reservation System**.
2. **Peer Review and Feedback**:
   - Work with peers or mentors to review each other’s code.
   - Focus on code quality, adherence to SOLID, and use of patterns.
3. **Final Review**: Go back over your previous projects, looking for areas to refactor or improve.

---

## **Additional Resources**

1. **Books**:
   - _Design Patterns: Elements of Reusable Object-Oriented Software_ by Gamma et al.
   - _Head First Design Patterns_ by Eric Freeman
2. **Courses**:
   - [Pluralsight’s Object-Oriented Design Fundamentals](https://www.pluralsight.com)
   - [Udemy System Design and OOD Courses](https://www.udemy.com)
3. **Coding Practice**:
   - [LeetCode Object-Oriented Design Questions](https://leetcode.com/problemset/all/)
   - [InterviewBit Design Questions](https://www.interviewbit.com/courses/system-design/)

---

Following this plan, you’ll develop a strong foundation in OOD and prepare to confidently tackle interview questions on interfaces, abstraction, and complex system designs in C#.

---

## Date: 15-Nov-2024

Certainly, Swamy! This is a very effective roadmap to build toward a Principal Software Engineer role with a strong emphasis on OOD in C#. Here’s a detailed learning plan tailored to that goal.

---

### Phase 2: Object-Oriented Design (OOD) and SOLID Principles in C#

#### **Objective:**

Develop a strong command of OOD principles and techniques in C# that enable you to create modular, maintainable, and extensible software.

---

### **Week 1: Core Object-Oriented Design Principles**

1. **Focus on the Basics:**

   - Review and solidify core OOD principles: **Encapsulation**, **Abstraction**, **Inheritance**, and **Polymorphism**.
   - **Encapsulation:** Practice defining access modifiers (`public`, `private`, `protected`, and `internal`) and using properties to encapsulate data.
   - **Abstraction:** Work on creating base classes and interfaces, abstracting behaviors and properties.

2. **Exercises in C#:**

   - Implement a **Shape hierarchy** where you have base classes like `Shape`, with derived classes such as `Circle`, `Rectangle`, etc. Each class should implement a method like `Draw` or `Area`.
   - Use **interfaces** to define behaviors like `IMovable`, `IDrawable`, etc., to practice polymorphism.

3. **Reading and Resources:**
   - "Design Patterns: Elements of Reusable Object-Oriented Software" - the classic for learning the language of OOD.
   - **C# Documentation on Polymorphism**: Microsoft’s documentation to clarify polymorphic behavior in C#.

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
   - “Clean Code” by Robert C. Martin for SOLID-focused examples.
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
   - “Head First Design Patterns” – for a more engaging take on classic patterns.
   - Online videos/tutorials for C#-specific pattern implementations.

---

### **Week 4: Advanced Design Patterns and Practical Application**

1. **Goal:** Apply more advanced patterns and evaluate when they are suitable.

   - **Dependency Injection (DI)**: Use DI for managing dependencies and reducing coupling.
   - **Decorator Pattern**: For adding responsibilities dynamically to objects.
   - **Command Pattern**: Especially useful in scenarios like implementing Undo functionality.
   - **Chain of Responsibility**: For request processing systems (e.g., filtering or logging).

2. **Exercises in C#:**

   - Implement a **DI container** using .NET’s `IServiceCollection` for an MVC application.
   - Create a **Logger** using the **Decorator Pattern** that can add functionality like timestamping, file logging, and console logging dynamically.
   - Design a **Command Pattern** for a remote control system where each command (like `TurnOn`, `TurnOff`, `VolumeUp`, etc.) can be executed and undone.

3. **Reading and Resources:**
   - “Dependency Injection in .NET” by Mark Seemann.
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
   - Explore Pluralsight’s Object-Oriented Design Fundamentals course.

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
