# Learning Object Oriented Design - Part A

**Learning Level**: Intermediate

**Prerequisites**: OOP fundamentals knowledge
**Estimated Time**: 27 minutes (planning session)

## **Series**: Part A of 2 - OOD Learning Plan

## 🎯 Learning Objectives

By the end of this session, you will

- [Add specific learning objectives]

---

### Part A of 2

## Next: [06_OOD-Learning-Plan-PartB.md](06_OOD-Learning-Plan-PartB.md)

## OOD in `C#`

> 1. Class

> 1. Generalization
> 1. Specialization
> 1. Association
> 1. Aggregation (has a - Week)
> 1. Composition (has a - Strong)
> 1. Inheritance (is a)
> 1. Dependency
> 1. Realization

## **Week 1: Core OOD Concepts**

### **Goals**

- Understand the fundamentals of Object-Oriented Programming (OOP)

- Explore and implement **interfaces**, **abstraction**, **inheritance**, and **polymorphism** in C#.

### **Topics to Cover**

1. **Introduction to OOP and OOD**

1. **Encapsulation** and **data hiding**
1. **Abstraction**: Abstract classes vs. Interfaces
1. **Interfaces in C#**: Declaring, implementing, and extending interfaces
1. **Polymorphism and Inheritance**: Overriding and virtual methods

### **Exercises**

1. Create classes for a simple inventory management system, with interfaces for **IProduct** (e.g., `AddProduct()`, `RemoveProduct()`) and **ICategory**.

1. Practice creating and implementing an interface for a **PaymentSystem** (e.g., `IPaymentMethod`) with multiple payment methods (`CreditCard`, `PayPal`, etc.).
1. Implement a **Shape** hierarchy, using an `IShape` interface for `Draw()` and `CalculateArea()` methods, and classes like `Circle`, `Rectangle`, etc.

---

## **Week 2: SOLID Principles and Design Patterns**

### **Goals** 2

- Learn and apply the **SOLID principles** for better OOD

- Get familiar with design patterns that leverage interfaces and abstraction.

### **Topics to Cover**

1. **SOLID Principles**:

- **Single Responsibility Principle (SRP)**
- **Open/Closed Principle (OCP)**
- **Liskov Substitution Principle (LSP)**
- **Interface Segregation Principle (ISP)**
- **Dependency Inversion Principle (DIP)**

1. **Key Design Patterns**:

   - **Factory Method** and **Abstract Factory**

- **Strategy Pattern**
- **Decorator Pattern**

### **Exercises**

1. **Refactor Code**: Take any simple system (e.g., inventory or user management) and apply SOLID principles to it

1. **Implement Patterns**:

   - **Strategy Pattern**: Implement a strategy for `IPaymentMethod` to handle multiple payment options without altering the primary payment processing class.

- **Decorator Pattern**: Create decorators to add additional responsibilities to a `Notification` class, e.g., `SMSNotification`, `EmailNotification`.

1. **ISP Exercise**: Define a large interface, break it down into smaller, more specific interfaces, and refactor classes to implement only what's necessary.

---

## **Week 3: Advanced OOD with Real-World Problem-Solving**

### **Goals** 3

- Practice designing systems with a focus on scalability and maintainability

- Learn to break down a problem and identify classes, relationships, and interfaces.

### **Topics to Cover**

1. **Abstraction and Modularity**: Identifying abstractions in problem statements.

1. **System Design Principles**: Cohesion, coupling, and modularity.
1. **Common Object-Oriented Design Problems**:

   - Design a Parking Lot system.

- Design an ATM machine.
- Design a File System structure.

### **Exercises** 2

1. **Design a Library System**:

- Identify key entities (`Book`, `User`, `Library`) and behaviors.
- Create interfaces for `ILibraryActions` (e.g., `CheckOutBook()`, `ReturnBook()`).

1. **Design a Notification System**:

   - Design interfaces like `INotificationService` for different types of notifications (`Email`, `SMS`, `Push`).

- Implement classes to use a **Factory pattern** for notification creation.

1. **OOD Case Study**: Pick a problem from a past interview question bank and work through the system design.

---

## **Week 4: Mock Interviews and Review**

### **Goals** 4

- Review key concepts and practice live coding

- Focus on real-time problem-solving and communicating design decisions effectively.

### **Topics to Cover**

1. **Mock Interview Questions**:

- Practice with mock OOD interview questions.
- Get comfortable explaining your design decisions clearly and concisely.

1. **Review of SOLID, Design Patterns, and Key Concepts**.
1. **Common Pitfalls and Best Practices in OOD Interviews**:

   - Avoid over-engineering.

- Focus on flexibility, reusability, and clarity.

### **Exercises** 3

1. **Mock Interview Questions**:

- **Design a Movie Booking System**.
- **Design a Hotel Reservation System**.

1. **Peer Review and Feedback**:

   - Work with peers or mentors to review each other's code.

- Focus on code quality, adherence to SOLID, and use of patterns.

1. **Final Review**: Go back over your previous projects, looking for areas to refactor or improve.

---

## **Additional Resources**

1. **Books**:

- _Design Patterns: Elements of Reusable Object-Oriented Software_ by Gamma et al.
- _Head First Design Patterns_ by Eric Freeman

1. **Courses**:

   - [Pluralsight's Object-Oriented Design Fundamentals](https://www.pluralsight.com)

- [Udemy System Design and OOD Courses](https://www.udemy.com)

1. **Coding Practice**:

   - [LeetCode Object-Oriented Design Questions](https://leetcode.com/problemset/all/)

- [InterviewBit Design Questions](https://www.interviewbit.com/courses/system-design/)

---

## Following this plan, you'll develop a strong foundation in OOD and prepare to confidently tackle interview questions on interfaces, abstraction, and complex system designs in C

## Date: 15-Nov-2024

Certainly, Swamy! This is a very effective roadmap to build toward a Principal Software Engineer role with a strong emphasis on OOD in C#. Here's a detailed learning plan tailored to that goal

---

### Phase 2: Object-Oriented Design (OOD) and SOLID Principles in C

### **Objective:**

##

Develop a strong command of OOD principles and techniques in C# that enable you to create modular, maintainable, and extensible software

### **Week 1: Core Object-Oriented Design Principles**

1. #### Focus on the Basics

## 🔗 Related Topics

### **Prerequisites**
- Completed OOP fundamentals
- Basic design thinking

### **Builds Upon**
- All OOP core concepts
- [03_OOP-Inheritance-Polymorphism.md](03_OOP-Inheritance-Polymorphism.md)

### **Enables Next Steps**
- **Next**: [06_OOD-Learning-Plan-PartB.md](06_OOD-Learning-Plan-PartB.md)
- **Future**: [SOLID Principles](../02_SOLID-Principles/)

### **Cross-References**
- **Design Patterns**: [Design Patterns](../03_Design-Patterns/)
- **UML**: [UML Documentation](../23_UML/)
