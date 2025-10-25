# 01_OOP-Objects-Creation-PartA\n\n**Learning Level**: Beginner

**Prerequisites**: [01_OOP-Core-Concepts-PartB.md](01_OOP-Core-Concepts-PartB.md)
**Estimated Time**: 15 minutes (27-minute focused session)
## **Series**: Part A of 2 - Objects Creation
## 🎯 Learning Objectives (15-Minute Session)\n\nBy the end of this session, you will

- Understand objects as instances of classes
- Master the object creation process
- See how multiple objects can exist independently

---

## 🏭 Creating Objects from Classes (15 minutes)

### **1. Objects: The Real Thing**

\n\n\n\n**Definition**: An object is an **instance** of a class - the actual "thing" created from the blueprint
**Key Relationship**: **One class** → **Multiple unique objects** with individual data

### **2. Class vs Object Visualization**

\n\n\n\n```mermaid
classDiagram
```csharp\nclass BankAccount {\n```csharp\n```csharp\n    -accountNumber: string\n```csharp\n```csharp\n    -balance: decimal\n```csharp\n```csharp\n    -ownerName: string\n```csharp\n```csharp\n    +deposit(amount): void\n```csharp\n```csharp\n    +withdraw(amount): void\n```csharp\n```csharp\n    +getBalance(): decimal\n```csharp\n    }
```csharp\nBankAccount --> johnAccount : creates\n```csharp\n```csharp\nBankAccount --> sarahAccount : creates\n```csharp\n```csharp\nBankAccount --> mikeAccount : creates\n```csharp\n```csharp\nnote for BankAccount "CLASS: Blueprint defining structure and behavior"\n```csharp\n```csharp\nnote for johnAccount "OBJECT: Specific instance with actual data"\n```csharp\n```csharp\nclass johnAccount {\n```csharp\n```csharp\n    accountNumber: "12345"\n```csharp\n```csharp\n    balance: 1500.00\n```csharp\n```csharp\n    ownerName: "John Smith"\n```csharp\n    }
```csharp\nclass sarahAccount {\n```csharp\n```csharp\n    accountNumber: "67890"\n```csharp\n```csharp\n    balance: 2300.50\n```csharp\n```csharp\n    ownerName: "Sarah Johnson"\n```csharp\n```csharp}
```csharp\n```csharp### **3. Object Creation Process**

```pseudocode
// Step 1: Define the class (blueprint)
CLASS Employee:
```csharp\nPRIVATE employeeId: string\n```csharp\n```csharp\nPRIVATE name: string\n```csharp\n```csharp\nPRIVATE department: string\n```csharp\n```csharp\nPRIVATE salary: decimal\n```csharp\n```csharp\nCONSTRUCTOR Employee(id, name, dept, sal):\n```csharp\n```csharp\n    this.employeeId = id\n```csharp\n```csharp\n    this.name = name\n```csharp\n```csharp\n    this.department = dept\n```csharp\n```csharp\n    this.salary = sal\n```csharp\n// Step 2: Create objects (instances)
employee1 = NEW Employee("E001", "John Smith", "Engineering", 75000)
employee2 = NEW Employee("E002", "Sarah Johnson", "Marketing", 65000)
employee3 = NEW Employee("E003", "Mike Chen", "Sales", 70000)
```csharp### **4. Object Independence**

```text
MEMORY VISUALIZATION
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   employee1     │    │   employee2     │    │   employee3     │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ id: "E001"      │    │ id: "E002"      │    │ id: "E003"      │
│ name: "John"    │    │ name: "Sarah"   │    │ name: "Mike"    │
│ dept: "Eng"     │    │ dept: "Mktg"    │    │ dept: "Sales"   │
│ salary: 75000   │    │ salary: 65000   │    │ salary: 70000   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
Each object has its own INDEPENDENT data storage
```csharp### **5. Using Objects**

```pseudocode
// Each object operates independently
employee1.displayInfo()              // Shows John's data
employee2.displayInfo()              // Shows Sarah's data
// Objects maintain separate state
employee1.giveRaise(5000)            // Only John gets raise
employee2.updateDepartment("Sales")  // Only Sarah changes dept
// Objects can be compared
IF employee1.salary > employee2.salary:
```csharpPRINT "John earns more than Sarah"
```csharp\n```\n\n---

## ✅ Key Takeaways (2 minutes)
### **Essential Understanding**

\n\n\n\n1. **Objects are instances** created from class blueprints

1. **Each object has independent data** but shared methods
1. **Multiple objects can exist** from one class
1. **Objects maintain separate state** and operate independently\n\n### **What's Next**

\n\n\n\n**Part B2** will cover:
  - Advanced object interactions
  - Complex real-world scenarios
##   - Object lifecycle management
## 🔗 Series Navigation\n\n- **Previous**: [01_OOP-Core-Concepts-PartB.md](01_OOP-Core-Concepts-PartB.md)\n\n  - **Current**: Part B1 - Objects Creation ✅
  - **Next**: [01_OOP-Objects-Creation-PartB.md](01_OOP-Objects-Creation-PartB.md)
  - **Series**: Classes & Objects Foundation (Part B1 of 4)\n\n**Last Updated**: September 10, 2025

**Format**: 15-minute focused learning segment
