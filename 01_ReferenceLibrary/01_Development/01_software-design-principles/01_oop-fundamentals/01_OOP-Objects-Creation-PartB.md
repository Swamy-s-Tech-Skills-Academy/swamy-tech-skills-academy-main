# 01_OOP-Objects-Creation-PartB\n\n**Learning Level**: Beginner → Intermediate

**Prerequisites**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)
**Estimated Time**: 27 minutes (focused learning session)
**Series**: Part B of 2 - Objects Creation
---

## 🎯 Learning Objectives (27-Minute Session)\n\nBy the end of this session, you will:
  - Implement complex object interactions
  - Understand object lifecycle management
  - Master advanced real-world object scenarios
  - Apply enterprise-level object design patterns
---

## 🏗️ Advanced Object Operations (25 minutes)
### **1. Complex Object Interactions**

\n\n\n\n```pseudocode
CLASS ProjectTeam:
```csharp\nPRIVATE members: List`Employee`\n```csharp\n```csharp\nPRIVATE projectName: string\n```csharp\n```csharp\nPRIVATE budget: decimal\n```csharp\n```csharp\nCONSTRUCTOR ProjectTeam(name: string, initialBudget: decimal):\n```csharp\n```csharp\n    this.projectName = name\n```csharp\n```csharp\n    this.budget = initialBudget\n```csharp\n```csharp\n    this.members = NEW List`Employee`()\n```csharp\n```csharp\nPUBLIC addMember(emp: Employee): boolean\n```csharp\n```csharp\n    IF this.budget >= emp.calculateAnnualSalary():\n```csharp\n```csharp\n        this.members.add(emp)\n```csharp\n```csharp\n        this.budget -= emp.calculateAnnualSalary()\n```csharp\n```csharp\n        RETURN true\n```csharp\n```csharp\n    RETURN false\n```csharp\n```csharp\nPUBLIC calculateTeamBudget(): decimal\n```csharp\n```csharp\n    totalCost = 0\n```csharp\n```csharp\n    FOR EACH member IN this.members:\n```csharp\n```csharp\n        totalCost += member.calculateAnnualSalary()\n```csharp\n```csharp\n    RETURN totalCost\n```csharp\n```csharp\nPUBLIC getTeamSize(): integer\n```csharp\n```csharp    RETURN this.members.size()
```csharp\n```csharp### **2. Objects Working Together**

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
```csharp\nPRIVATE employeeId: string\n```csharp\n```csharp\nPRIVATE name: string\n```csharp\n```csharp\nPRIVATE department: string\n```csharp\n```csharp\nPRIVATE salary: decimal\n```csharp\n```csharp\nPRIVATE isActive: boolean\n```csharp\n```csharp\nPRIVATE projects: List`string`\n```csharp\n```csharp\nPUBLIC assignToProject(projectName: string): void\n```csharp\n```csharp\n    IF this.isActive:\n```csharp\n```csharp\n        this.projects.add(projectName)\n```csharp\n```csharp\nPUBLIC removeFromProject(projectName: string): void\n```csharp\n```csharp\n    this.projects.remove(projectName)\n```csharp\n```csharp\nPUBLIC getWorkload(): integer\n```csharp\n```csharp\n    RETURN this.projects.size()\n```csharp\n```csharp\nPUBLIC isOverloaded(): boolean\n```csharp\n```csharp    RETURN this.getWorkload() > 3
```csharp\n```csharp### **4. Enterprise Object Patterns**

```pseudocode
// Factory pattern for creating employees
CLASS EmployeeFactory:
```csharp\nPUBLIC STATIC createDeveloper(name: string, salary: decimal): Employee\n```csharp\n```csharp\n    emp = NEW Employee(generateId(), name, "Engineering", salary)\n```csharp\n```csharp\n    emp.assignSkill("Programming")\n```csharp\n```csharp\n    RETURN emp\n```csharp\n```csharp\nPUBLIC STATIC createDesigner(name: string, salary: decimal): Employee\n```csharp\n```csharp\n    emp = NEW Employee(generateId(), name, "Design", salary)\n```csharp\n```csharp\n    emp.assignSkill("UI/UX")\n```csharp\n```csharp\n    RETURN emp\n```csharp\n// Using the factory
developer1 = EmployeeFactory.createDeveloper("Alice Brown", 80000)
designer1 = EmployeeFactory.createDesigner("Bob Wilson", 70000)
```csharp### **5. Object Lifecycle Example**

```pseudocode
// Complete employee lifecycle
CLASS Company:
```csharp\nPRIVATE employees: List`Employee`\n```csharp\n```csharp\nPRIVATE teams: List`ProjectTeam`\n```csharp\n```csharp\nPUBLIC hireEmployee(name: string, dept: string, salary: decimal): Employee\n```csharp\n```csharp\n    newEmployee = NEW Employee(generateId(), name, dept, salary)\n```csharp\n```csharp\n    this.employees.add(newEmployee)\n```csharp\n```csharp\n    PRINT "Hired: " + newEmployee.getName()\n```csharp\n```csharp\n    RETURN newEmployee\n```csharp\n```csharp\nPUBLIC createTeam(name: string, budget: decimal): ProjectTeam\n```csharp\n```csharp\n    team = NEW ProjectTeam(name, budget)\n```csharp\n```csharp\n    this.teams.add(team)\n```csharp\n```csharp\n    RETURN team\n```csharp\n```csharp\nPUBLIC assignEmployeeToTeam(empId: string, teamName: string): boolean\n```csharp\n```csharp\n    employee = findEmployeeById(empId)\n```csharp\n```csharp\n    team = findTeamByName(teamName)\n```csharp\n```csharp\n    IF employee != NULL AND team != NULL:\n```csharp\n```csharp\n        IF NOT employee.isOverloaded():\n```csharp\n```csharp\n            RETURN team.addMember(employee)\n```csharp\n```csharp    RETURN false
```csharp\n```\n\n---

## ✅ Key Takeaways (2 minutes)
### **Advanced Understanding**

\n\n\n\n1. **Objects can contain other objects** (composition)

1. **Objects collaborate** to accomplish complex tasks
2. **Object state changes** over time through method calls
3. **Enterprise patterns** help manage object creation and lifecycle
4. **Objects model real business processes** effectively\n\n### **Design Principles Achieved**

\n\n\n\n- ✅ **Encapsulation**: Objects manage their own state
  - ✅ **Collaboration**: Objects work together naturally
  - ✅ **Reusability**: Same classes create many different scenarios
  - ✅ **Maintainability**: Changes isolated within object boundaries\n\n### **What's Next**

\n\n\n\nReady for **Module 2: Encapsulation & Abstraction**:
  - Protecting object data with access modifiers
  - Creating clean public interfaces
  - Hiding implementation complexity
  - Advanced data security patterns
---

## 🔗 Series Navigation\n\n- **Previous**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)
  - **Current**: Part B2 - Advanced Practice ✅
  - **Next**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
  - **Series**: Classes & Objects Foundation (Part B2 of 4)\n\n**Last Updated**: September 10, 2025

**Format**: 27-minute focused learning segment
