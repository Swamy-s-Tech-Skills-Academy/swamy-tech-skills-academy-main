# 01_OOP-Objects-Creation-PartB

**Learning Level**: Beginner → Intermediate

**Prerequisites**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)
**Estimated Time**: 27 minutes (focused learning session)

## **Series**: Part B of 2 - Objects Creation

## 🎯 Learning Objectives (27-Minute Session)

By the end of this session, you will

- Implement complex object interactions
- Understand object lifecycle management
- Master advanced real-world object scenarios
- Apply enterprise-level object design patterns

---

## 🏗️ Advanced Object Operations (25 minutes)

### **1. Complex Object Interactions**

```pseudocode
CLASS ProjectTeam:
```csharp
PRIVATE members: List`Employee`
```csharp
```csharp
PRIVATE projectName: string
```csharp
```csharp
PRIVATE budget: decimal
```csharp
```csharp
CONSTRUCTOR ProjectTeam(name: string, initialBudget: decimal):
```csharp
```csharp
    this.projectName = name
```csharp
```csharp
    this.budget = initialBudget
```csharp
```csharp
    this.members = NEW List`Employee`()
```csharp
```csharp
PUBLIC addMember(emp: Employee): boolean
```csharp
```csharp
    IF this.budget >= emp.calculateAnnualSalary():
```csharp
```csharp
        this.members.add(emp)
```csharp
```csharp
        this.budget -= emp.calculateAnnualSalary()
```csharp
```csharp
        RETURN true
```csharp
```csharp
    RETURN false
```csharp
```csharp
PUBLIC calculateTeamBudget(): decimal
```csharp
```csharp
    totalCost = 0
```csharp
```csharp
    FOR EACH member IN this.members:
```csharp
```csharp
        totalCost += member.calculateAnnualSalary()
```csharp
```csharp
    RETURN totalCost
```csharp
```csharp
PUBLIC getTeamSize(): integer
```csharp
```csharp    RETURN this.members.size()
```csharp
```csharp### **2. Objects Working Together**

```pseudocode
// Create a project team
devTeam = NEW ProjectTeam("Web Platform", 500000)
// Create employees
john = NEW Employee("E001", "John Smith", "Engineering", 75000)
sarah = NEW Employee("E002", "Sarah Johnson", "Design", 65000)
mike = NEW Employee("E003", "Mike Chen", "QA", 60000)
// Add team members
devTeam.addMember(john)     // Success: budget allows
devTeam.addMember(sarah)    // Success: budget allows
devTeam.addMember(mike)     // Success: budget allows
// Team operations
teamSize = devTeam.getTeamSize()           // Returns: 3
teamCost = devTeam.calculateTeamBudget()   // Returns: 200000
remainingBudget = 500000 - teamCost        // Returns: 300000
```csharp### **3. Object State Management**

```pseudocode
CLASS Employee:
```csharp
PRIVATE employeeId: string
```csharp
```csharp
PRIVATE name: string
```csharp
```csharp
PRIVATE department: string
```csharp
```csharp
PRIVATE salary: decimal
```csharp
```csharp
PRIVATE isActive: boolean
```csharp
```csharp
PRIVATE projects: List`string`
```csharp
```csharp
PUBLIC assignToProject(projectName: string): void
```csharp
```csharp
    IF this.isActive:
```csharp
```csharp
        this.projects.add(projectName)
```csharp
```csharp
PUBLIC removeFromProject(projectName: string): void
```csharp
```csharp
    this.projects.remove(projectName)
```csharp
```csharp
PUBLIC getWorkload(): integer
```csharp
```csharp
    RETURN this.projects.size()
```csharp
```csharp
PUBLIC isOverloaded(): boolean
```csharp
```csharp    RETURN this.getWorkload() > 3
```csharp
```csharp### **4. Enterprise Object Patterns**

```pseudocode
// Factory pattern for creating employees
CLASS EmployeeFactory:
```csharp
PUBLIC STATIC createDeveloper(name: string, salary: decimal): Employee
```csharp
```csharp
    emp = NEW Employee(generateId(), name, "Engineering", salary)
```csharp
```csharp
    emp.assignSkill("Programming")
```csharp
```csharp
    RETURN emp
```csharp
```csharp
PUBLIC STATIC createDesigner(name: string, salary: decimal): Employee
```csharp
```csharp
    emp = NEW Employee(generateId(), name, "Design", salary)
```csharp
```csharp
    emp.assignSkill("UI/UX")
```csharp
```csharp
    RETURN emp
```csharp
// Using the factory
developer1 = EmployeeFactory.createDeveloper("Alice Brown", 80000)
designer1 = EmployeeFactory.createDesigner("Bob Wilson", 70000)
```csharp### **5. Object Lifecycle Example**

```pseudocode
// Complete employee lifecycle
CLASS Company:
```csharp
PRIVATE employees: List`Employee`
```csharp
```csharp
PRIVATE teams: List`ProjectTeam`
```csharp
```csharp
PUBLIC hireEmployee(name: string, dept: string, salary: decimal): Employee
```csharp
```csharp
    newEmployee = NEW Employee(generateId(), name, dept, salary)
```csharp
```csharp
    this.employees.add(newEmployee)
```csharp
```csharp
    PRINT "Hired: " + newEmployee.getName()
```csharp
```csharp
    RETURN newEmployee
```csharp
```csharp
PUBLIC createTeam(name: string, budget: decimal): ProjectTeam
```csharp
```csharp
    team = NEW ProjectTeam(name, budget)
```csharp
```csharp
    this.teams.add(team)
```csharp
```csharp
    RETURN team
```csharp
```csharp
PUBLIC assignEmployeeToTeam(empId: string, teamName: string): boolean
```csharp
```csharp
    employee = findEmployeeById(empId)
```csharp
```csharp
    team = findTeamByName(teamName)
```csharp
```csharp
    IF employee != NULL AND team != NULL:
```csharp
```csharp
        IF NOT employee.isOverloaded():
```csharp
```csharp
            RETURN team.addMember(employee)
```csharp
```csharp    RETURN false
```csharp
```

---

## ✅ Key Takeaways (2 minutes)

### **Advanced Understanding**

1. **Objects can contain other objects** (composition)

1. **Objects collaborate** to accomplish complex tasks
1. **Object state changes** over time through method calls
1. **Enterprise patterns** help manage object creation and lifecycle
1. **Objects model real business processes** effectively

### **Design Principles Achieved**

- ✅ **Encapsulation**: Objects manage their own state
  - ✅ **Collaboration**: Objects work together naturally
  - ✅ **Reusability**: Same classes create many different scenarios
  - ✅ **Maintainability**: Changes isolated within object boundaries

### **What's Next**

Ready for **Module 2: Encapsulation & Abstraction**:

- Protecting object data with access modifiers
- Creating clean public interfaces
- Hiding implementation complexity

## - Advanced data security patterns

## 🔗 Series Navigation

- **Previous**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)

  - **Current**: Part B2 - Advanced Practice ✅
  - **Next**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
  - **Series**: Classes & Objects Foundation (Part B2 of 4)

**Last Updated**: September 10, 2025

**Format**: 27-minute focused learning segment

## 🔗 Related Topics

### **Prerequisites**

- [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)

### **Builds Upon**

- Object instantiation basics
- Class interactions

### **Enables Next Steps**

- **Next**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
- **Future**: [03_OOP-Inheritance-Polymorphism.md](03_OOP-Inheritance-Polymorphism.md)

### **Cross-References**

- **Design Patterns**: [Design Patterns](../03_Design-Patterns/)
