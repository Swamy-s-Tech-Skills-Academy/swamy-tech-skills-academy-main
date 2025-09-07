# 04_Learner-to-Beginner - Object-Oriented Programming

**Learning Level**: Intermediate  
**Prerequisites**: Completed 03_Novice-to-Learner (data structures, CLI tools, modular design)  
**Estimated Time**: 4-6 weeks (15-20 hours per week)

## 🎯 Learning Objectives

By the end of this level, you will:

- **Master OOP fundamentals** (classes, objects, methods, attributes)
- **Implement inheritance and polymorphism** effectively
- **Design class hierarchies** for real-world problems
- **Apply encapsulation and abstraction** principles
- **Create reusable and maintainable code** structures
- **Achieve the milestone**: "I can organize code!" with confidence

---

## 📋 Core Concepts

### Class Design and Implementation

```python
class BankAccount:
    """A simple bank account class demonstrating OOP principles."""
    
    # Class variable (shared by all instances)
    bank_name = "Python Bank"
    account_count = 0
    
    def __init__(self, account_holder, initial_balance=0):
        """Initialize a new bank account."""
        self.account_holder = account_holder
        self._balance = initial_balance  # Protected attribute
        self._account_number = self._generate_account_number()
        BankAccount.account_count += 1
    
    def _generate_account_number(self):
        """Private method to generate account number."""
        import random
        return f"ACC{random.randint(10000, 99999)}"
    
    def deposit(self, amount):
        """Deposit money into the account."""
        if amount > 0:
            self._balance += amount
            return f"Deposited ${amount:.2f}. New balance: ${self._balance:.2f}"
        return "Deposit amount must be positive"
    
    def withdraw(self, amount):
        """Withdraw money from the account."""
        if amount > self._balance:
            return "Insufficient funds"
        if amount > 0:
            self._balance -= amount
            return f"Withdrew ${amount:.2f}. New balance: ${self._balance:.2f}"
        return "Withdrawal amount must be positive"
    
    @property
    def balance(self):
        """Get current balance (read-only property)."""
        return self._balance
    
    @property
    def account_number(self):
        """Get account number (read-only property)."""
        return self._account_number
    
    def __str__(self):
        """String representation of the account."""
        return f"Account {self._account_number}: {self.account_holder} - ${self._balance:.2f}"
    
    def __repr__(self):
        """Developer-friendly representation."""
        return f"BankAccount('{self.account_holder}', {self._balance})"

# Usage example
account = BankAccount("John Doe", 1000)
print(account.deposit(500))
print(account.withdraw(200))
print(f"Current balance: ${account.balance:.2f}")
```

### Inheritance and Polymorphism

```python
class Vehicle:
    """Base class for all vehicles."""
    
    def __init__(self, make, model, year):
        self.make = make
        self.model = model
        self.year = year
        self.is_running = False
    
    def start(self):
        """Start the vehicle."""
        if not self.is_running:
            self.is_running = True
            return f"{self.year} {self.make} {self.model} started"
        return "Vehicle is already running"
    
    def stop(self):
        """Stop the vehicle."""
        if self.is_running:
            self.is_running = False
            return f"{self.year} {self.make} {self.model} stopped"
        return "Vehicle is already stopped"
    
    def get_info(self):
        """Get vehicle information."""
        status = "running" if self.is_running else "stopped"
        return f"{self.year} {self.make} {self.model} ({status})"

class Car(Vehicle):
    """Car class inheriting from Vehicle."""
    
    def __init__(self, make, model, year, fuel_type="gasoline"):
        super().__init__(make, model, year)
        self.fuel_type = fuel_type
        self.doors = 4
    
    def honk(self):
        """Car-specific method."""
        return "Beep beep!"
    
    def get_info(self):
        """Override parent method with additional info."""
        base_info = super().get_info()
        return f"{base_info} - {self.fuel_type}, {self.doors} doors"

class Motorcycle(Vehicle):
    """Motorcycle class inheriting from Vehicle."""
    
    def __init__(self, make, model, year, engine_size):
        super().__init__(make, model, year)
        self.engine_size = engine_size
        self.doors = 0
    
    def wheelie(self):
        """Motorcycle-specific method."""
        if self.is_running:
            return "Performing wheelie!"
        return "Cannot perform wheelie - motorcycle not running"
    
    def get_info(self):
        """Override parent method with additional info."""
        base_info = super().get_info()
        return f"{base_info} - {self.engine_size}cc engine"

# Polymorphism demonstration
vehicles = [
    Car("Toyota", "Camry", 2022, "hybrid"),
    Motorcycle("Honda", "CBR600", 2021, 600),
    Car("Tesla", "Model 3", 2023, "electric")
]

for vehicle in vehicles:
    print(vehicle.start())
    print(vehicle.get_info())
    print("-" * 40)
```

---

## 📝 Practice Projects

### Project 1: Library Management System

Design a complete library system with:

- Book, Author, and Library classes
- Inheritance for different book types (Fiction, NonFiction, Reference)
- Member management with borrowing history
- Late fee calculation and payment tracking

### Project 2: Game Character System

Create a role-playing game character system:

- Base Character class with health, experience, level
- Specialized classes (Warrior, Mage, Archer) with unique abilities
- Equipment system with weapon and armor classes
- Combat system demonstrating polymorphism

### Project 3: Employee Management System

Build an HR management system:

- Employee base class with common attributes
- Specialized employee types (Manager, Developer, Sales)
- Payroll calculation with different salary structures
- Performance tracking and reporting

### Project 4: Shape Calculator

Develop a geometric shape calculator:

- Abstract base Shape class
- Specific shape classes (Circle, Rectangle, Triangle)
- Area and perimeter calculations
- Shape comparison and sorting capabilities

---

## 🎯 Learning Milestones

### Week 1-2: Class Fundamentals

- [ ] Create classes with proper constructors
- [ ] Implement methods and properties
- [ ] Use class and instance variables appropriately
- [ ] Apply encapsulation principles

### Week 3-4: Inheritance and Polymorphism

- [ ] Design inheritance hierarchies
- [ ] Override methods effectively
- [ ] Implement polymorphic behavior
- [ ] Use super() for parent class access

### Week 5-6: Advanced OOP Concepts

- [ ] Create abstract base classes
- [ ] Implement special methods (`__str__`, `__repr__`, etc.)
- [ ] Design composition relationships
- [ ] Complete comprehensive OOP project

---

## 🚀 Next Steps

### Preparation for Level 5 (Beginner-to-Practitioner)

To succeed in the next level, ensure you can:

- [ ] **Design class hierarchies** for complex problems
- [ ] **Apply OOP principles** consistently
- [ ] **Create reusable code** through proper abstraction
- [ ] **Implement polymorphic behavior** effectively

## 🔗 Related Topics

### Prerequisites

- [03_Novice-to-Learner](../03_Novice-to-Learner/) - Data structures and modular design

### Enables

- [05_Beginner-to-Practitioner](../05_Beginner-to-Practitioner/) - Clean code principles

### Cross-References

- **Software Design Principles**: OOP fundamentals and design patterns
- **Professional Practice**: Code organization and testing

---

**Last Updated**: September 7, 2025  
**Maintained By**: STSA Learning System
