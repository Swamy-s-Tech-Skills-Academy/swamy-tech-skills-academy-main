# 01_OOP-Objects-Creation-PartB

**Learning Level**: Beginner → Intermediate
**Prerequisites**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)
**Estimated Time**: 27 minutes (focused learning session)
**Series**: Part B of 2 - Objects Creation

---

## 🎯 Learning Objectives (27-Minute Session)

By the end of this session, you will:

- Implement complex object interactions
- Understand object lifecycle management
- Master advanced real-world object scenarios
- Apply enterprise-level object design patterns

---

## 🏗️ Advanced Object Operations (25 minutes)

### **1. Complex Object Interactions**

```pseudocode
CLASS ProjectTeam:
    PRIVATE members: List<Employee>
    PRIVATE projectName: string
    PRIVATE budget: decimal

    CONSTRUCTOR ProjectTeam(name: string, initialBudget: decimal):
        this.projectName = name
        this.budget = initialBudget
        this.members = NEW List<Employee>()

    PUBLIC addMember(emp: Employee): boolean
        IF this.budget >= emp.calculateAnnualSalary():
            this.members.add(emp)
            this.budget -= emp.calculateAnnualSalary()
            RETURN true
        RETURN false

    PUBLIC calculateTeamBudget(): decimal
        totalCost = 0
        FOR EACH member IN this.members:
            totalCost += member.calculateAnnualSalary()
        RETURN totalCost

    PUBLIC getTeamSize(): integer
        RETURN this.members.size()
```

### **2. Objects Working Together**

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
```

### **3. Object State Management**

```pseudocode
CLASS Employee:
    PRIVATE employeeId: string
    PRIVATE name: string
    PRIVATE department: string
    PRIVATE salary: decimal
    PRIVATE isActive: boolean
    PRIVATE projects: List<string>

    PUBLIC assignToProject(projectName: string): void
        IF this.isActive:
            this.projects.add(projectName)

    PUBLIC removeFromProject(projectName: string): void
        this.projects.remove(projectName)

    PUBLIC getWorkload(): integer
        RETURN this.projects.size()

    PUBLIC isOverloaded(): boolean
        RETURN this.getWorkload() > 3
```

### **4. Enterprise Object Patterns**

```pseudocode
// Factory pattern for creating employees
CLASS EmployeeFactory:
    PUBLIC STATIC createDeveloper(name: string, salary: decimal): Employee
        emp = NEW Employee(generateId(), name, "Engineering", salary)
        emp.assignSkill("Programming")
        RETURN emp

    PUBLIC STATIC createDesigner(name: string, salary: decimal): Employee
        emp = NEW Employee(generateId(), name, "Design", salary)
        emp.assignSkill("UI/UX")
        RETURN emp

// Using the factory
developer1 = EmployeeFactory.createDeveloper("Alice Brown", 80000)
designer1 = EmployeeFactory.createDesigner("Bob Wilson", 70000)
```

### **5. Object Lifecycle Example**

```pseudocode
// Complete employee lifecycle
CLASS Company:
    PRIVATE employees: List<Employee>
    PRIVATE teams: List<ProjectTeam>

    PUBLIC hireEmployee(name: string, dept: string, salary: decimal): Employee
        newEmployee = NEW Employee(generateId(), name, dept, salary)
        this.employees.add(newEmployee)
        PRINT "Hired: " + newEmployee.getName()
        RETURN newEmployee

    PUBLIC createTeam(name: string, budget: decimal): ProjectTeam
        team = NEW ProjectTeam(name, budget)
        this.teams.add(team)
        RETURN team

    PUBLIC assignEmployeeToTeam(empId: string, teamName: string): boolean
        employee = findEmployeeById(empId)
        team = findTeamByName(teamName)

        IF employee != NULL AND team != NULL:
            IF NOT employee.isOverloaded():
                RETURN team.addMember(employee)
        RETURN false
```

---

## ✅ Key Takeaways (2 minutes)

### **Advanced Understanding**

1. **Objects can contain other objects** (composition)
2. **Objects collaborate** to accomplish complex tasks
3. **Object state changes** over time through method calls
4. **Enterprise patterns** help manage object creation and lifecycle
5. **Objects model real business processes** effectively

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
- Advanced data security patterns

---

## 🔗 Series Navigation

- **Previous**: [01_OOP-Objects-Creation-PartA.md](01_OOP-Objects-Creation-PartA.md)
- **Current**: Part B2 - Advanced Practice ✅
- **Next**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
- **Series**: Classes & Objects Foundation (Part B2 of 4)

**Last Updated**: September 10, 2025
**Format**: 27-minute focused learning segment
