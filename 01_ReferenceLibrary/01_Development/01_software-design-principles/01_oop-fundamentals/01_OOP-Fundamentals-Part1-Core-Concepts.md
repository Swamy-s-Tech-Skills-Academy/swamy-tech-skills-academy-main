# 01_OOP-Fundamentals-Part1-Core-Concepts

**Learning Level**: Beginner to Intermediate  
**Prerequisites**: Basic programming knowledge, variables and functions  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the four pillars of Object-Oriented Programming (Encapsulation, Inheritance, Polymorphism, Abstraction)
- Understand classes, objects, and their relationships in practical scenarios
- Implement real-world examples demonstrating core OOP concepts
- Apply OOP principles to solve common programming problems

## 📋 Content Sections

### Quick Overview (5 minutes)

**Object-Oriented Programming**: *"A programming paradigm that organizes code around objects and classes, enabling better code organization, reusability, and maintainability."*

**Core Problem**: As applications grow in complexity, procedural programming becomes difficult to manage, leading to code duplication, tight coupling, and maintenance nightmares.

```text
❌ PROCEDURAL PROGRAMMING PROBLEMS
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ calculatePay()  │    │ validateUser()  │    │ generateReport() │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ - Global data   │    │ - Global data   │    │ - Global data   │
│ - Scattered     │    │ - Scattered     │    │ - Scattered     │
│   validation    │    │   logic         │    │   formatting    │
│ - Hard to test  │    │ - Hard to test  │    │ - Hard to test  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
    ❌ Tight coupling, code duplication, maintenance complexity

✅ OBJECT-ORIENTED PROGRAMMING SOLUTION
                 ┌─────────────────┐
                 │    Employee     │
                 ├─────────────────┤
                 │ - name: string  │
                 │ - salary: money │
                 │ + calculatePay() │
                 │ + validate()    │
                 └─────────────────┘
                          ▲
            ┌─────────────┼─────────────┐
   ┌─────────────────┐    │    ┌─────────────────┐
   │ FullTimeEmp     │    │    │ PartTimeEmp     │
   ├─────────────────┤    │    ├─────────────────┤
   │ + calculatePay() │    │    │ + calculatePay() │
   │ + getBenefits() │    │    │ + getHours()    │
   └─────────────────┘    │    └─────────────────┘
                          │
                 ┌─────────────────┐
                 │ PayrollReport   │
                 ├─────────────────┤
                 │ + generate()    │
                 │ + format()      │
                 └─────────────────┘
    ✅ Encapsulated data, reusable code, maintainable structure
```

**Four Pillars of OOP**:

- **Encapsulation** - Bundling data and methods together, controlling access
- **Inheritance** - Creating new classes based on existing ones
- **Polymorphism** - One interface, multiple implementations
- **Abstraction** - Hiding complex implementation details

### Core Concepts (15 minutes)

#### The Four Pillars in Action

#### Implementation 1: Encapsulation - Employee Management System

```csharp
// Encapsulation: Bundling data with methods that operate on that data
public class Employee
{
    // Private fields - data is hidden from outside access
    private string _name;
    private decimal _salary;
    private DateTime _hireDate;
    private string _employeeId;
    private bool _isActive;

    // Constructor - controlled way to create objects
    public Employee(string name, decimal salary, DateTime hireDate)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Employee name cannot be empty");
        
        if (salary < 0)
            throw new ArgumentException("Salary cannot be negative");

        _name = name.Trim();
        _salary = salary;
        _hireDate = hireDate;
        _employeeId = GenerateEmployeeId();
        _isActive = true;
    }

    // Public properties - controlled access to private data
    public string Name 
    { 
        get => _name; 
        set 
        { 
            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException("Name cannot be empty");
            _name = value.Trim(); 
        } 
    }

    public decimal Salary 
    { 
        get => _salary; 
        private set // Only the class itself can modify salary
        { 
            if (value < 0)
                throw new ArgumentException("Salary cannot be negative");
            _salary = value; 
        } 
    }

    public string EmployeeId => _employeeId; // Read-only property

    public DateTime HireDate => _hireDate; // Read-only property

    public bool IsActive => _isActive; // Read-only property

    public int YearsOfService => DateTime.Now.Year - _hireDate.Year;

    // Public methods - controlled operations on the data
    public void GiveRaise(decimal percentage)
    {
        if (!_isActive)
            throw new InvalidOperationException("Cannot give raise to inactive employee");
        
        if (percentage < 0)
            throw new ArgumentException("Raise percentage cannot be negative");

        var raiseAmount = _salary * (percentage / 100);
        _salary += raiseAmount;
        
        Console.WriteLine($"Gave {_name} a {percentage}% raise. New salary: ${_salary:F2}");
    }

    public void Deactivate(string reason)
    {
        if (!_isActive)
            throw new InvalidOperationException("Employee is already inactive");
        
        _isActive = false;
        Console.WriteLine($"Employee {_name} deactivated. Reason: {reason}");
    }

    public void Activate()
    {
        if (_isActive)
            throw new InvalidOperationException("Employee is already active");
        
        _isActive = true;
        Console.WriteLine($"Employee {_name} reactivated");
    }

    public virtual decimal CalculateAnnualBonus()
    {
        if (!_isActive)
            return 0;

        // Base bonus calculation: 5% of annual salary
        return _salary * 12 * 0.05m;
    }

    public virtual string GetEmployeeType()
    {
        return "Base Employee";
    }

    // Private helper method - internal implementation detail
    private string GenerateEmployeeId()
    {
        var random = new Random();
        return $"EMP{random.Next(1000, 9999)}";
    }

    public override string ToString()
    {
        return $"{_name} (ID: {_employeeId}) - ${_salary:F2}/month - {(_isActive ? "Active" : "Inactive")}";
    }

    // Demonstration of information hiding
    public string GetSalarySummary()
    {
        // Complex business logic hidden from outside callers
        var annualSalary = _salary * 12;
        var taxRate = CalculateTaxRate(annualSalary);
        var netAnnual = annualSalary * (1 - taxRate);
        
        return $"Annual: ${annualSalary:F2}, Tax Rate: {taxRate:P}, Net: ${netAnnual:F2}";
    }

    private decimal CalculateTaxRate(decimal annualSalary)
    {
        // Simplified tax calculation - complex logic hidden
        if (annualSalary < 50000) return 0.15m;
        if (annualSalary < 100000) return 0.22m;
        return 0.28m;
    }
}

// Demonstration of encapsulation benefits
public class EmployeeManager
{
    private readonly List<Employee> _employees;

    public EmployeeManager()
    {
        _employees = new List<Employee>();
    }

    public void AddEmployee(Employee employee)
    {
        if (employee == null)
            throw new ArgumentNullException(nameof(employee));
        
        _employees.Add(employee);
        Console.WriteLine($"Added employee: {employee.Name}");
    }

    public void GiveCompanyWideRaise(decimal percentage)
    {
        Console.WriteLine($"Giving {percentage}% raise to all active employees:");
        
        foreach (var employee in _employees.Where(e => e.IsActive))
        {
            employee.GiveRaise(percentage); // Uses encapsulated method
        }
    }

    public void DisplayAllEmployees()
    {
        Console.WriteLine("\n=== Employee Roster ===");
        foreach (var employee in _employees)
        {
            Console.WriteLine($"• {employee}"); // Uses encapsulated ToString()
            Console.WriteLine($"  Type: {employee.GetEmployeeType()}");
            Console.WriteLine($"  Years of Service: {employee.YearsOfService}");
            Console.WriteLine($"  Annual Bonus: ${employee.CalculateAnnualBonus():F2}");
            Console.WriteLine($"  Salary Summary: {employee.GetSalarySummary()}");
            Console.WriteLine();
        }
    }

    public List<Employee> GetLongTermEmployees(int minimumYears = 5)
    {
        return _employees
            .Where(e => e.IsActive && e.YearsOfService >= minimumYears)
            .ToList();
    }

    public decimal GetTotalPayroll()
    {
        return _employees
            .Where(e => e.IsActive)
            .Sum(e => e.Salary * 12); // Accessing through property, not private field
    }
}

// Usage example demonstrating encapsulation
public class EncapsulationDemo
{
    public void DemonstrateEncapsulation()
    {
        Console.WriteLine("=== Encapsulation Demo ===");

        var manager = new EmployeeManager();

        // Creating employees with controlled construction
        var john = new Employee("John Smith", 5000, new DateTime(2020, 1, 15));
        var jane = new Employee("Jane Doe", 6500, new DateTime(2018, 6, 20));
        var bob = new Employee("Bob Johnson", 4500, new DateTime(2021, 3, 10));

        manager.AddEmployee(john);
        manager.AddEmployee(jane);
        manager.AddEmployee(bob);

        Console.WriteLine("\n--- Initial State ---");
        manager.DisplayAllEmployees();

        // Demonstrate controlled access through methods
        Console.WriteLine("--- Giving Company-wide Raise ---");
        manager.GiveCompanyWideRaise(8);

        // Demonstrate data protection
        Console.WriteLine("\n--- Attempting Direct Access (This would cause compilation error) ---");
        // john._salary = 1000000; // ❌ Compiler error - private field not accessible
        Console.WriteLine("✅ Private fields are protected from direct manipulation");

        // Demonstrate controlled modification through properties
        Console.WriteLine("\n--- Controlled Property Access ---");
        try
        {
            john.Name = "John A. Smith"; // ✅ Allowed through property setter
            Console.WriteLine($"Name updated successfully: {john.Name}");
            
            // john.Salary = 10000; // ❌ Compiler error - private setter
            Console.WriteLine("✅ Salary can only be modified through controlled methods");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error: {ex.Message}");
        }

        // Demonstrate business rule enforcement
        Console.WriteLine("\n--- Business Rule Enforcement ---");
        try
        {
            bob.Deactivate("Resignation");
            Console.WriteLine($"Bob's status: {(bob.IsActive ? "Active" : "Inactive")}");
            
            // Try to give raise to inactive employee
            bob.GiveRaise(10); // Should throw exception
        }
        catch (InvalidOperationException ex)
        {
            Console.WriteLine($"✅ Business rule enforced: {ex.Message}");
        }

        Console.WriteLine("\n--- Final Payroll Summary ---");
        Console.WriteLine($"Total active employees: {manager.GetLongTermEmployees(0).Count(e => e.IsActive)}");
        Console.WriteLine($"Total annual payroll: ${manager.GetTotalPayroll():F2}");
        
        var longTermEmployees = manager.GetLongTermEmployees(3);
        Console.WriteLine($"Long-term employees (3+ years): {longTermEmployees.Count}");
        foreach (var emp in longTermEmployees)
        {
            Console.WriteLine($"  • {emp.Name} - {emp.YearsOfService} years");
        }
    }
}
```

#### Implementation 2: Inheritance - Vehicle Hierarchy

```csharp
// Base class - defines common structure and behavior
public abstract class Vehicle
{
    // Protected fields - accessible by derived classes but not external code
    protected string _make;
    protected string _model;
    protected int _year;
    protected decimal _price;
    protected int _mileage;
    protected bool _isRunning;

    // Constructor for base class
    protected Vehicle(string make, string model, int year, decimal price)
    {
        _make = make ?? throw new ArgumentNullException(nameof(make));
        _model = model ?? throw new ArgumentNullException(nameof(model));
        _year = year;
        _price = price;
        _mileage = 0;
        _isRunning = false;
    }

    // Common properties available to all vehicles
    public string Make => _make;
    public string Model => _model;
    public int Year => _year;
    public decimal Price => _price;
    public int Mileage => _mileage;
    public bool IsRunning => _isRunning;
    public int Age => DateTime.Now.Year - _year;

    // Abstract methods - must be implemented by derived classes
    public abstract void StartEngine();
    public abstract void StopEngine();
    public abstract decimal CalculateFuelEfficiency();
    public abstract string GetVehicleType();

    // Virtual methods - can be overridden by derived classes
    public virtual void Drive(int miles)
    {
        if (!_isRunning)
        {
            Console.WriteLine($"Cannot drive {_make} {_model} - engine is not running");
            return;
        }

        if (miles <= 0)
        {
            Console.WriteLine("Distance must be positive");
            return;
        }

        _mileage += miles;
        Console.WriteLine($"Drove {miles} miles. Total mileage: {_mileage}");
        
        // Simulate some wear and tear
        if (_mileage % 1000 == 0)
        {
            Console.WriteLine($"🔧 Maintenance recommended for {_make} {_model} at {_mileage} miles");
        }
    }

    public virtual decimal CalculateDepreciation()
    {
        // Standard depreciation: 15% per year
        var depreciationRate = 0.15m;
        var yearsOwned = Age;
        var currentValue = _price * (decimal)Math.Pow((double)(1 - depreciationRate), yearsOwned);
        
        return Math.Max(currentValue, _price * 0.1m); // Minimum 10% of original value
    }

    public virtual string GetMaintenanceSchedule()
    {
        var nextOilChange = (((_mileage / 5000) + 1) * 5000);
        var nextMajorService = (((_mileage / 20000) + 1) * 20000);
        
        return $"Next oil change: {nextOilChange} miles, Next major service: {nextMajorService} miles";
    }

    // Concrete method - same for all vehicles
    public void DisplayInfo()
    {
        Console.WriteLine($"\n=== {GetVehicleType()} Information ===");
        Console.WriteLine($"Make/Model: {_make} {_model}");
        Console.WriteLine($"Year: {_year} (Age: {Age} years)");
        Console.WriteLine($"Price: ${_price:F2}");
        Console.WriteLine($"Current Value: ${CalculateDepreciation():F2}");
        Console.WriteLine($"Mileage: {_mileage} miles");
        Console.WriteLine($"Fuel Efficiency: {CalculateFuelEfficiency():F1} MPG");
        Console.WriteLine($"Status: {(IsRunning ? "Running" : "Stopped")}");
        Console.WriteLine($"Maintenance: {GetMaintenanceSchedule()}");
    }

    public override string ToString()
    {
        return $"{_year} {_make} {_model} ({GetVehicleType()})";
    }
}

// Derived class - inherits from Vehicle and adds specific behavior
public class Car : Vehicle
{
    private readonly int _numberOfDoors;
    private readonly string _fuelType;
    private readonly bool _hasAirConditioning;
    private bool _airConditioningOn;

    public Car(string make, string model, int year, decimal price, int numberOfDoors, string fuelType, bool hasAirConditioning)
        : base(make, model, year, price) // Call parent constructor
    {
        _numberOfDoors = numberOfDoors;
        _fuelType = fuelType ?? "Gasoline";
        _hasAirConditioning = hasAirConditioning;
        _airConditioningOn = false;
    }

    public int NumberOfDoors => _numberOfDoors;
    public string FuelType => _fuelType;
    public bool HasAirConditioning => _hasAirConditioning;
    public bool AirConditioningOn => _airConditioningOn;

    // Implementation of abstract methods
    public override void StartEngine()
    {
        if (_isRunning)
        {
            Console.WriteLine($"{_make} {_model} is already running");
            return;
        }

        Console.WriteLine($"🚗 Starting {_make} {_model} car engine...");
        Console.WriteLine("Turn key... Engine started!");
        _isRunning = true;
    }

    public override void StopEngine()
    {
        if (!_isRunning)
        {
            Console.WriteLine($"{_make} {_model} engine is already stopped");
            return;
        }

        if (_airConditioningOn)
        {
            TurnOffAirConditioning();
        }

        Console.WriteLine($"🚗 Stopping {_make} {_model} car engine...");
        _isRunning = false;
    }

    public override decimal CalculateFuelEfficiency()
    {
        // Car-specific fuel efficiency calculation
        var baseMPG = _fuelType.ToLower() switch
        {
            "hybrid" => 45m,
            "electric" => 100m, // MPGe equivalent
            "diesel" => 35m,
            _ => 28m // Gasoline default
        };

        // Age affects efficiency
        var efficiencyLoss = Age * 0.5m;
        var currentMPG = Math.Max(baseMPG - efficiencyLoss, 15m);

        // AC usage affects efficiency
        if (_airConditioningOn && _isRunning)
        {
            currentMPG *= 0.9m; // 10% reduction when AC is on
        }

        return currentMPG;
    }

    public override string GetVehicleType()
    {
        return "Car";
    }

    // Override virtual method to add car-specific behavior
    public override void Drive(int miles)
    {
        if (_hasAirConditioning && !_airConditioningOn && miles > 50)
        {
            Console.WriteLine("Long drive detected - automatically turning on air conditioning");
            TurnOnAirConditioning();
        }

        base.Drive(miles); // Call parent implementation
    }

    // Car-specific methods
    public void TurnOnAirConditioning()
    {
        if (!_hasAirConditioning)
        {
            Console.WriteLine("This car doesn't have air conditioning");
            return;
        }

        if (!_isRunning)
        {
            Console.WriteLine("Cannot turn on AC - engine is not running");
            return;
        }

        if (_airConditioningOn)
        {
            Console.WriteLine("Air conditioning is already on");
            return;
        }

        _airConditioningOn = true;
        Console.WriteLine("❄️ Air conditioning turned ON");
    }

    public void TurnOffAirConditioning()
    {
        if (!_airConditioningOn)
        {
            Console.WriteLine("Air conditioning is already off");
            return;
        }

        _airConditioningOn = false;
        Console.WriteLine("Air conditioning turned OFF");
    }
}

// Another derived class with different characteristics
public class Truck : Vehicle
{
    private readonly decimal _loadCapacity; // in tons
    private decimal _currentLoad;
    private readonly bool _hasFourWheelDrive;

    public Truck(string make, string model, int year, decimal price, decimal loadCapacity, bool hasFourWheelDrive)
        : base(make, model, year, price)
    {
        _loadCapacity = loadCapacity;
        _currentLoad = 0;
        _hasFourWheelDrive = hasFourWheelDrive;
    }

    public decimal LoadCapacity => _loadCapacity;
    public decimal CurrentLoad => _currentLoad;
    public decimal AvailableCapacity => _loadCapacity - _currentLoad;
    public bool HasFourWheelDrive => _hasFourWheelDrive;
    public bool IsLoaded => _currentLoad > 0;

    public override void StartEngine()
    {
        Console.WriteLine($"🚛 Starting {_make} {_model} truck engine...");
        Console.WriteLine("Diesel engine warming up... Ready to haul!");
        _isRunning = true;
    }

    public override void StopEngine()
    {
        if (_isRunning && IsLoaded)
        {
            Console.WriteLine("⚠️  Warning: Stopping engine while loaded - ensure parking brake is engaged");
        }

        Console.WriteLine($"🚛 Stopping {_make} {_model} truck engine...");
        _isRunning = false;
    }

    public override decimal CalculateFuelEfficiency()
    {
        // Truck fuel efficiency - affected by load
        var baseMPG = 18m; // Trucks are less fuel efficient
        var loadFactor = (_currentLoad / _loadCapacity);
        var efficiencyReduction = loadFactor * 0.3m; // 30% reduction at full load
        
        var currentMPG = baseMPG * (1 - efficiencyReduction);
        
        // Age affects efficiency more severely in trucks
        var efficiencyLoss = Age * 0.8m;
        
        return Math.Max(currentMPG - efficiencyLoss, 8m);
    }

    public override string GetVehicleType()
    {
        return "Truck";
    }

    public override void Drive(int miles)
    {
        if (IsLoaded)
        {
            Console.WriteLine($"🚛 Hauling {_currentLoad:F1} tons of cargo");
        }

        base.Drive(miles);
    }

    // Truck-specific methods
    public void LoadCargo(decimal weight)
    {
        if (weight <= 0)
        {
            Console.WriteLine("Cargo weight must be positive");
            return;
        }

        if (_currentLoad + weight > _loadCapacity)
        {
            Console.WriteLine($"❌ Cannot load {weight:F1} tons - exceeds capacity by {(_currentLoad + weight - _loadCapacity):F1} tons");
            return;
        }

        _currentLoad += weight;
        Console.WriteLine($"📦 Loaded {weight:F1} tons. Current load: {_currentLoad:F1}/{_loadCapacity:F1} tons");
    }

    public void UnloadCargo(decimal weight)
    {
        if (weight <= 0)
        {
            Console.WriteLine("Unload weight must be positive");
            return;
        }

        if (weight > _currentLoad)
        {
            Console.WriteLine($"❌ Cannot unload {weight:F1} tons - only {_currentLoad:F1} tons loaded");
            return;
        }

        _currentLoad -= weight;
        Console.WriteLine($"📤 Unloaded {weight:F1} tons. Current load: {_currentLoad:F1}/{_loadCapacity:F1} tons");
    }

    public void UnloadAll()
    {
        if (_currentLoad == 0)
        {
            Console.WriteLine("Truck is already empty");
            return;
        }

        var unloadedAmount = _currentLoad;
        _currentLoad = 0;
        Console.WriteLine($"📤 Unloaded all cargo: {unloadedAmount:F1} tons");
    }
}

// Usage example demonstrating inheritance
public class InheritanceDemo
{
    public void DemonstrateInheritance()
    {
        Console.WriteLine("=== Inheritance Demo ===");

        // Create instances of derived classes
        var car = new Car("Toyota", "Camry", 2020, 25000m, 4, "Hybrid", true);
        var truck = new Truck("Ford", "F-150", 2019, 35000m, 2.5m, true);

        // Polymorphic collection - all vehicles can be treated uniformly
        var vehicles = new List<Vehicle> { car, truck };

        Console.WriteLine("\n--- Vehicle Information ---");
        foreach (var vehicle in vehicles)
        {
            vehicle.DisplayInfo(); // Calls overridden methods appropriately
        }

        Console.WriteLine("\n--- Starting All Vehicles ---");
        foreach (var vehicle in vehicles)
        {
            vehicle.StartEngine(); // Different implementation for each type
        }

        Console.WriteLine("\n--- Car-Specific Operations ---");
        car.TurnOnAirConditioning();
        car.Drive(75); // Triggers auto-AC logic

        Console.WriteLine("\n--- Truck-Specific Operations ---");
        truck.LoadCargo(1.5m);
        truck.Drive(50);
        truck.LoadCargo(1.2m); // Should exceed capacity
        truck.UnloadAll();

        Console.WriteLine("\n--- Fuel Efficiency Comparison ---");
        Console.WriteLine($"Car efficiency: {car.CalculateFuelEfficiency():F1} MPG");
        Console.WriteLine($"Truck efficiency: {truck.CalculateFuelEfficiency():F1} MPG");

        Console.WriteLine("\n--- Stopping All Vehicles ---");
        foreach (var vehicle in vehicles)
        {
            vehicle.StopEngine();
        }

        // Demonstrate that all vehicles share common interface despite different implementations
        Console.WriteLine("\n--- Polymorphic Behavior ---");
        Console.WriteLine("All vehicles implement the same interface but behave differently:");
        foreach (var vehicle in vehicles)
        {
            Console.WriteLine($"• {vehicle} - Type: {vehicle.GetVehicleType()}");
        }
    }
}
```

### Practical Implementation (8 minutes)

#### Polymorphism and Abstraction in Action

#### Implementation 3: Shape Calculation System

```csharp
// Abstract base class demonstrating abstraction
public abstract class Shape
{
    protected string _name;
    protected string _color;
    protected DateTime _createdAt;

    protected Shape(string name, string color = "Black")
    {
        _name = name ?? throw new ArgumentNullException(nameof(name));
        _color = color ?? "Black";
        _createdAt = DateTime.Now;
    }

    public string Name => _name;
    public string Color => _color;
    public DateTime CreatedAt => _createdAt;

    // Abstract methods - must be implemented by derived classes
    public abstract double CalculateArea();
    public abstract double CalculatePerimeter();
    public abstract void Draw();

    // Virtual method - can be overridden
    public virtual string GetShapeInfo()
    {
        return $"{_name} ({_color}) - Area: {CalculateArea():F2}, Perimeter: {CalculatePerimeter():F2}";
    }

    // Concrete method - same for all shapes
    public void DisplayCreationInfo()
    {
        Console.WriteLine($"Shape created: {_name} at {_createdAt:yyyy-MM-dd HH:mm:ss}");
    }
}

// Concrete implementation - Rectangle
public class Rectangle : Shape
{
    private readonly double _width;
    private readonly double _height;

    public Rectangle(double width, double height, string color = "Black") 
        : base("Rectangle", color)
    {
        if (width <= 0 || height <= 0)
            throw new ArgumentException("Width and height must be positive");
        
        _width = width;
        _height = height;
    }

    public double Width => _width;
    public double Height => _height;
    public bool IsSquare => Math.Abs(_width - _height) < 0.001;

    public override double CalculateArea()
    {
        return _width * _height;
    }

    public override double CalculatePerimeter()
    {
        return 2 * (_width + _height);
    }

    public override void Draw()
    {
        Console.WriteLine($"Drawing {_color} Rectangle:");
        for (int i = 0; i < Math.Min(_height, 5); i++)
        {
            for (int j = 0; j < Math.Min(_width, 10); j++)
            {
                Console.Write("█");
            }
            Console.WriteLine();
        }
    }

    public override string GetShapeInfo()
    {
        var baseInfo = base.GetShapeInfo();
        return $"{baseInfo}, Dimensions: {_width}x{_height}" + (IsSquare ? " (Square)" : "");
    }
}

// Concrete implementation - Circle
public class Circle : Shape
{
    private readonly double _radius;

    public Circle(double radius, string color = "Black") 
        : base("Circle", color)
    {
        if (radius <= 0)
            throw new ArgumentException("Radius must be positive");
        
        _radius = radius;
    }

    public double Radius => _radius;
    public double Diameter => _radius * 2;

    public override double CalculateArea()
    {
        return Math.PI * _radius * _radius;
    }

    public override double CalculatePerimeter()
    {
        return 2 * Math.PI * _radius;
    }

    public override void Draw()
    {
        Console.WriteLine($"Drawing {_color} Circle:");
        int size = Math.Min((int)_radius * 2, 10);
        int center = size / 2;
        
        for (int i = 0; i < size; i++)
        {
            for (int j = 0; j < size; j++)
            {
                double distance = Math.Sqrt(Math.Pow(i - center, 2) + Math.Pow(j - center, 2));
                Console.Write(distance <= center ? "●" : " ");
            }
            Console.WriteLine();
        }
    }

    public override string GetShapeInfo()
    {
        var baseInfo = base.GetShapeInfo();
        return $"{baseInfo}, Radius: {_radius:F2}, Diameter: {Diameter:F2}";
    }
}

// Concrete implementation - Triangle
public class Triangle : Shape
{
    private readonly double _sideA;
    private readonly double _sideB;
    private readonly double _sideC;

    public Triangle(double sideA, double sideB, double sideC, string color = "Black") 
        : base("Triangle", color)
    {
        if (sideA <= 0 || sideB <= 0 || sideC <= 0)
            throw new ArgumentException("All sides must be positive");
        
        if (!IsValidTriangle(sideA, sideB, sideC))
            throw new ArgumentException("Invalid triangle - sides don't satisfy triangle inequality");

        _sideA = sideA;
        _sideB = sideB;
        _sideC = sideC;
    }

    public double SideA => _sideA;
    public double SideB => _sideB;
    public double SideC => _sideC;

    public bool IsEquilateral => Math.Abs(_sideA - _sideB) < 0.001 && Math.Abs(_sideB - _sideC) < 0.001;
    public bool IsIsosceles => (Math.Abs(_sideA - _sideB) < 0.001) || 
                              (Math.Abs(_sideB - _sideC) < 0.001) || 
                              (Math.Abs(_sideA - _sideC) < 0.001);

    private static bool IsValidTriangle(double a, double b, double c)
    {
        return (a + b > c) && (a + c > b) && (b + c > a);
    }

    public override double CalculateArea()
    {
        // Using Heron's formula
        double s = CalculatePerimeter() / 2;
        return Math.Sqrt(s * (s - _sideA) * (s - _sideB) * (s - _sideC));
    }

    public override double CalculatePerimeter()
    {
        return _sideA + _sideB + _sideC;
    }

    public override void Draw()
    {
        Console.WriteLine($"Drawing {_color} Triangle:");
        Console.WriteLine("   △   ");
        Console.WriteLine("  △ △  ");
        Console.WriteLine(" △   △ ");
        Console.WriteLine("△△△△△△△");
    }

    public override string GetShapeInfo()
    {
        var baseInfo = base.GetShapeInfo();
        var type = IsEquilateral ? "Equilateral" : (IsIsosceles ? "Isosceles" : "Scalene");
        return $"{baseInfo}, Type: {type}, Sides: {_sideA:F1}, {_sideB:F1}, {_sideC:F1}";
    }
}

// Polymorphism demonstration class
public class ShapeCalculator
{
    private readonly List<Shape> _shapes;

    public ShapeCalculator()
    {
        _shapes = new List<Shape>();
    }

    public void AddShape(Shape shape)
    {
        if (shape == null)
            throw new ArgumentNullException(nameof(shape));
        
        _shapes.Add(shape);
        Console.WriteLine($"Added {shape.Name} to collection");
    }

    // Polymorphic method - works with any Shape
    public void DisplayAllShapes()
    {
        Console.WriteLine("\n=== Shape Collection ===");
        for (int i = 0; i < _shapes.Count; i++)
        {
            Console.WriteLine($"{i + 1}. {_shapes[i].GetShapeInfo()}"); // Polymorphic call
        }
    }

    public void DrawAllShapes()
    {
        Console.WriteLine("\n=== Drawing All Shapes ===");
        foreach (var shape in _shapes)
        {
            shape.Draw(); // Polymorphic call - each shape draws differently
            Console.WriteLine();
        }
    }

    public double CalculateTotalArea()
    {
        return _shapes.Sum(shape => shape.CalculateArea()); // Polymorphic call
    }

    public double CalculateTotalPerimeter()
    {
        return _shapes.Sum(shape => shape.CalculatePerimeter()); // Polymorphic call
    }

    public Shape FindLargestShape()
    {
        return _shapes.OrderByDescending(s => s.CalculateArea()).FirstOrDefault();
    }

    public List<Shape> FindShapesByColor(string color)
    {
        return _shapes.Where(s => s.Color.Equals(color, StringComparison.OrdinalIgnoreCase)).ToList();
    }

    public void GenerateReport()
    {
        Console.WriteLine("\n=== Shape Analysis Report ===");
        Console.WriteLine($"Total shapes: {_shapes.Count}");
        Console.WriteLine($"Total area: {CalculateTotalArea():F2}");
        Console.WriteLine($"Total perimeter: {CalculateTotalPerimeter():F2}");
        Console.WriteLine($"Average area: {(CalculateTotalArea() / _shapes.Count):F2}");

        var largestShape = FindLargestShape();
        if (largestShape != null)
        {
            Console.WriteLine($"Largest shape: {largestShape.Name} with area {largestShape.CalculateArea():F2}");
        }

        var colorGroups = _shapes.GroupBy(s => s.Color).ToList();
        Console.WriteLine($"Colors used: {string.Join(", ", colorGroups.Select(g => $"{g.Key} ({g.Count()})"))}");
    }
}

// Usage example demonstrating all four pillars
public class OOPPillarsDemo
{
    public void DemonstrateAllPillars()
    {
        Console.WriteLine("=== OOP Four Pillars Demo ===");

        var calculator = new ShapeCalculator();

        // Polymorphism - same interface, different implementations
        Console.WriteLine("\n--- Polymorphism in Action ---");
        calculator.AddShape(new Rectangle(5, 3, "Blue"));
        calculator.AddShape(new Circle(4, "Red"));
        calculator.AddShape(new Triangle(3, 4, 5, "Green"));
        calculator.AddShape(new Rectangle(2, 2, "Yellow")); // Square

        // Abstraction - complex calculations hidden behind simple interface
        Console.WriteLine("\n--- Abstraction - Simple Interface, Complex Implementation ---");
        calculator.DisplayAllShapes(); // Each shape calculates area/perimeter differently
        
        // Inheritance - shared behavior, specialized implementation
        Console.WriteLine("\n--- Inheritance - Shared Structure, Specialized Behavior ---");
        calculator.DrawAllShapes(); // Each shape draws differently but uses same method name

        // Encapsulation - data protection and controlled access
        Console.WriteLine("\n--- Encapsulation - Protected Data, Controlled Access ---");
        var shapes = calculator.FindShapesByColor("Blue");
        foreach (var shape in shapes)
        {
            Console.WriteLine($"Blue shape: {shape.Name}");
            shape.DisplayCreationInfo(); // Access through public method
            // shape._color = "Purple"; // ❌ Would be compiler error - protected field
        }

        calculator.GenerateReport();
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**The Four Pillars Recap**:

- ✅ **Encapsulation** - Data hiding and controlled access through properties and methods
- ✅ **Inheritance** - Code reuse and "is-a" relationships between classes
- ✅ **Polymorphism** - One interface, multiple implementations enabling flexible design
- ✅ **Abstraction** - Hiding complex implementation details behind simple interfaces

**Benefits of OOP**:

- **Modularity** - Code organized in logical, maintainable units
- **Reusability** - Base classes and interfaces enable code sharing
- **Flexibility** - Polymorphism allows easy extension and modification
- **Maintainability** - Encapsulation reduces coupling and improves reliability

**Real-World Applications**:

- **Enterprise software** - Complex business logic organization
- **Game development** - Character hierarchies and behavior systems
- **UI frameworks** - Component-based architectures
- **API design** - Service contracts and implementation flexibility

### Next Steps

**Immediate Actions**:

- Practice creating class hierarchies for real-world scenarios
- Continue to **OOP Fundamentals Part 2**: Advanced concepts (interfaces, composition, dependency injection)

**Advanced Topics**:

- Interface design and multiple inheritance
- Composition vs inheritance trade-offs
- SOLID principles application in OOP design

## 🔗 Related Topics

**Prerequisites**: Basic programming concepts, variables, functions  
**Builds Upon**: Procedural programming fundamentals  
**Enables**: SOLID Principles (02_SOLID-Principles), Design Patterns (03_Design-Patterns)  
**Related**: Class design, Software architecture, System modeling
