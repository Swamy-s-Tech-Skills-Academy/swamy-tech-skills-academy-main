# 01_OOP-Classes-and-Objects\n\n**Learning Level**: Beginner

**Prerequisites**: Basic programming knowledge
**Estimated Time**: 15 minutes (condensed overview)
**Series**: Condensed Overview
---

## 🎯 Learning Objectives\n\nBy the end of this session, you will:
  - [Add specific learning objectives]
---
By the end of this session, you will:
  - Understand the difference between classes and objects
  - Master class definition and object instantiation concepts
  - Apply real-world modeling with classes and objects
  - Use pseudocode to design object-oriented solutions
---

## 📋 Quick Overview (5 minutes)\n\n**Object-Oriented Programming**: A programming paradigm that organizes code around objects and classes, enabling better code organization, reusability, and maintainability
### **The Core Problem**

\n\n\n\n```text
❌ PROCEDURAL APPROACH
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ calculatePay()  │    │ validateUser()  │    │ generateReport() │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ - Global data   │    │ - Global data   │    │ - Global data   │
│ - Scattered     │    │ - Scattered     │    │ - Scattered     │
│   logic         │    │   validation    │    │   formatting    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```csharp**Problems**: Code duplication, tight coupling, difficult maintenance, testing challenges.

### **The OOP Solution**

\n\n
```mermaid\n\ngraph TD
```csharp\nA[Employee Class] --> B[Create Objects]\n```csharp\n```csharp\nB --> C["john: Employee"]\n```csharp\n```csharp\nB --> D["sarah: Employee"]\n```csharp\n```csharp\nB --> E["mike: Employee"]\n```csharp\n```csharp\nC --> F["john.calculatePay()"]\n```csharp\n```csharp\nD --> G["sarah.validate()"]\n```csharp\n```csharpE --> H["mike.generateReport()"]
```csharp\n```csharp---

## 🏗️ Core Concepts (15 minutes)
### **1. Classes: The Blueprint**

\n\n\n\n**Definition**: A class is a blueprint that defines structure (data) and behavior (methods) for objects
**Class Template**:

```pseudocode
CLASS ClassName:
```csharp\n// Attributes (data)\n```csharp\n```csharp\nPRIVATE attribute1: DataType\n```csharp\n```csharp\nPRIVATE attribute2: DataType\n```csharp\n```csharp\n// Constructor\n```csharp\n```csharp\nCONSTRUCTOR(parameters):\n```csharp\n```csharp\n    // Initialize attributes\n```csharp\n```csharp\n// Methods (behavior)\n```csharp\n```csharp\nPUBLIC methodName():\n```csharp\n```csharp    // Implementation
```csharp\n```csharp### **2. Objects: The Real Thing**
**Definition**: An object is an instance of a class - the actual "thing" created from the blueprint.
**Key Relationship**: One class → Multiple unique objects with individual data.

### **3. Class vs Object Relationship**

\n\n
```mermaid\n\nclassDiagram
```csharp\nclass BankAccount {\n```csharp\n```csharp\n    -accountNumber: string\n```csharp\n```csharp\n    -balance: decimal\n```csharp\n```csharp\n    -ownerName: string\n```csharp\n```csharp\n    +deposit(amount): void\n```csharp\n```csharp\n    +withdraw(amount): void\n```csharp\n```csharp\n    +getBalance(): decimal\n```csharp\n    }
```csharp\nBankAccount --> johnAccount : creates\n```csharp\n```csharp\nBankAccount --> sarahAccount : creates\n```csharp\n```csharp\nBankAccount --> mikeAccount : creates\n```csharp\n```csharp\nnote for BankAccount "CLASS: Blueprint defining structure and behavior"\n```csharp\n```csharpnote for johnAccount "OBJECT: Specific instance with actual data"
```csharp\n```csharp---

## 💡 Practical Implementation (8 minutes)
### **Real-World Example: Employee Management**

\n\n

### Step 1: Define the Class

\n\n
```pseudocode\n\nCLASS Employee:
```csharp\nPRIVATE employeeId, name, department: string\n```csharp\n```csharp\nPRIVATE salary: decimal\n```csharp\n```csharp\nCONSTRUCTOR Employee(id, name, dept, sal)\n```csharp\n```csharpPUBLIC displayInfo(), calculateAnnualSalary(), updateDepartment()
```csharp\n```csharp#### Step 2: Create & Use Objects

```pseudocode
// Create objects from class
employee1 = NEW Employee("E001", "John Smith", "Engineering", 75000)
employee2 = NEW Employee("E002", "Sarah Johnson", "Marketing", 65000)
// Use objects independently
employee1.displayInfo()              // John's data
employee2.calculateAnnualSalary()    // Sarah's calculation
employee1.updateDepartment("Senior Engineering")
```\n\n**Result**: Each object has **independent data** but **shared methods** from the class blueprint.
---

## ✅ Key Takeaways (2 minutes)
### **Essential Understanding**

\n\n\n\n1. **Class = Blueprint**: Defines structure and behavior template

1. **Object = Instance**: Actual thing created from the class
2. **Multiple Objects**: One class can create many different objects
3. **Independent Data**: Each object has its own copy of attributes
4. **Shared Behavior**: All objects share the same methods\n\n### **Key Benefits**

\n\n\n\n- ✅ **Organization**: Related data and methods grouped together
  - ✅ **Reusability**: One class definition, multiple objects
  - ✅ **Maintainability**: Changes in one place affect all objects\n\n### **Next Steps**

\n\n\n\n- **Continue**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
  - **Practice**: Design 3 real-world entities as classes
---

## 🔗 Series Navigation\n\n- **Current**: 01 - Classes & Objects ✅
  - **Next**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
  - **Then**: [03_OOP-Inheritance-Polymorphism.md](03_OOP-Inheritance-Polymorphism.md)
  - **Advanced**: [04A_OOP-Advanced-Patterns-PartA.md](04_OOP-Advanced-Patterns-PartA.md)
  - **Advanced**: [04B_OOP-Advanced-Patterns-PartB.md](04_OOP-Advanced-Patterns-PartB.md)\n\n**Last Updated**: September 10, 2025

**Format**: 27-minute focused learning segment
