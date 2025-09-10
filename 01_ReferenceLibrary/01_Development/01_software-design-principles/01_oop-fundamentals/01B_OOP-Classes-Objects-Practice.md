# 01B_OOP-Classes-Objects-Practice

**Learning Level**: Beginner  
**Prerequisites**: [01A_OOP-Classes-Objects-Foundation.md](01A_OOP-Classes-Objects-Foundation.md)  
**Estimated Time**: 27 minutes  
**Series**: Part B of 2 - Classes & Objects Practice
**Next**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)

---

## 🎯 Learning Objectives (27-Minute Session)

By the end of this session, you will:

- Implement detailed class definitions with multiple attributes and methods
- Understand object memory allocation and management
- Apply complex real-world modeling scenarios
- Master object interaction patterns

---

## 📋 Quick Review (5 minutes)

**From Part A**: Classes are blueprints, objects are instances, each object has independent data but shared behavior.

### **Today's Focus**

Moving from simple concepts to practical implementation with:

- Complex class structures
- Real-world employee management system
- Memory visualization
- Object lifecycle understanding

---

## 🏗️ Detailed Implementation (15 minutes)

### **Real-World Example: Employee Management System**

#### Step 1: Complete Class Definition

```pseudocode
CLASS Employee:
    // Comprehensive attributes for real employee data
    PRIVATE employeeId: string
    PRIVATE name: string
    PRIVATE department: string
    PRIVATE salary: decimal
    PRIVATE hireDate: date
    PRIVATE isActive: boolean
    
    // Constructor with full initialization
    CONSTRUCTOR Employee(id: string, name: string, dept: string, sal: decimal):
        this.employeeId = id
        this.name = name
        this.department = dept
        this.salary = sal
        this.hireDate = getCurrentDate()
        this.isActive = true
    
    // Complete method set for employee operations
    PUBLIC displayInfo(): string
    PUBLIC calculateAnnualSalary(): decimal
    PUBLIC updateDepartment(newDept: string): void
    PUBLIC giveRaise(percentage: decimal): void
    PUBLIC deactivateEmployee(): void
    PUBLIC getYearsOfService(): integer
```

#### Step 2: Creating Multiple Objects

```pseudocode
// Create diverse employee objects
employee1 = NEW Employee("E001", "John Smith", "Engineering", 75000)
employee2 = NEW Employee("E002", "Sarah Johnson", "Marketing", 65000)
employee3 = NEW Employee("E003", "Mike Chen", "Sales", 70000)
employee4 = NEW Employee("E004", "Lisa Wilson", "HR", 68000)

// Each object is completely independent
PRINT "Total employees created: 4"
```

#### Step 3: Complex Object Operations

```pseudocode
// Individual object operations
john_annual = employee1.calculateAnnualSalary()    // 75000 * 12
employee1.giveRaise(0.10)                          // 10% raise
employee1.updateDepartment("Senior Engineering")

sarah_years = employee2.getYearsOfService()        // Based on hire date
employee2.giveRaise(0.05)                          // 5% raise

// Batch operations on multiple objects
employees = [employee1, employee2, employee3, employee4]
FOR EACH emp IN employees:
    PRINT emp.displayInfo()
    IF emp.calculateAnnualSalary() > 800000:
        emp.giveRaise(0.03)  // Bonus raise for high earners
```

### **Memory Visualization**

```text
MEMORY LAYOUT: Independent Object Storage
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   employee1     │    │   employee2     │    │   employee3     │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ id: "E001"      │    │ id: "E002"      │    │ id: "E003"      │
│ name: "John"    │    │ name: "Sarah"   │    │ name: "Mike"    │
│ dept: "Eng"     │    │ dept: "Mktg"    │    │ dept: "Sales"   │
│ salary: 82500   │    │ salary: 68250   │    │ salary: 70000   │
│ active: true    │    │ active: true    │    │ active: true    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
     ↓ methods           ↓ methods           ↓ methods
 [Shared Behavior]   [Shared Behavior]   [Shared Behavior]

CLASS Employee (Template)
┌─────────────────────────┐
│ METHOD displayInfo()    │
│ METHOD calculateAnnual()│  ← All objects reference
│ METHOD giveRaise()      │    the same method
│ METHOD updateDept()     │    definitions
└─────────────────────────┘
```

---

## 💡 Advanced Concepts (5 minutes)

### **Object Lifecycle Management**

```pseudocode
// Object creation and destruction lifecycle
CLASS ProjectTeam:
    PRIVATE members: List<Employee>
    
    PUBLIC addMember(emp: Employee): void
        members.add(emp)
    
    PUBLIC removeMember(empId: string): void
        FOR EACH member IN members:
            IF member.employeeId == empId:
                member.deactivateEmployee()
                members.remove(member)
                
    PUBLIC calculateTeamBudget(): decimal
        totalBudget = 0
        FOR EACH member IN members:
            totalBudget += member.calculateAnnualSalary()
        RETURN totalBudget
```

### **Object Interaction Patterns**

```pseudocode
// Objects working together
team = NEW ProjectTeam()
team.addMember(employee1)    // John joins the team
team.addMember(employee2)    // Sarah joins the team

teamBudget = team.calculateTeamBudget()  // Combined salaries
PRINT "Team annual budget: " + teamBudget

// Objects can be passed between other objects
employee1.transferToDepartment("Research", team)
```

---

## ✅ Key Takeaways (2 minutes)

### **Advanced Understanding**

1. **Complex Classes**: Real applications have many attributes and methods
2. **Object Independence**: Each object maintains its own state
3. **Shared Behavior**: All objects use the same method implementations
4. **Object Interaction**: Objects can work together and reference each other
5. **Memory Efficiency**: Methods are shared, data is independent

### **Design Principles Learned**

- ✅ **Encapsulation**: Data and methods bundled together
- ✅ **Independence**: Objects maintain separate state
- ✅ **Reusability**: Same class creates many different objects
- ✅ **Scalability**: Easy to add more employees/objects as needed

### **Next Steps**

Ready for **Part 2: Encapsulation & Abstraction**:

- How to protect object data (private/public)
- Creating clean interfaces
- Hiding implementation complexity
- Advanced access control patterns

---

## 🔗 Series Navigation

- **Previous**: [01A_OOP-Classes-Objects-Foundation.md](01A_OOP-Classes-Objects-Foundation.md)
- **Current**: Part B - Practical Implementation ✅
- **Next**: [02_OOP-Encapsulation-Abstraction.md](02_OOP-Encapsulation-Abstraction.md)
- **Series**: Classes & Objects (Part B of 2)

**Last Updated**: September 10, 2025  
**Format**: 27-minute focused learning segment
