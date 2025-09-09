# 03_SOLID-Part3-Liskov-Substitution-Principle

**Learning Level**: Advanced  
**Prerequisites**: Inheritance, polymorphism, Open/Closed Principle (Part 2)  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Liskov Substitution Principle (LSP) and its critical importance
- Identify subtle LSP violations that break polymorphism
- Design inheritance hierarchies that maintain behavioral contracts
- Apply LSP to create robust, substitutable class hierarchies

## 📋 Content Sections

### Quick Overview (5 minutes)

**Liskov Substitution Principle (LSP)**: *"Objects of a superclass should be replaceable with objects of its subclasses without breaking the application."*

```text
❌ LSP VIOLATION: Subclass Changes Expected Behavior
┌─────────────────┐    ┌─────────────────┐
│   Rectangle     │    │   Square        │
├─────────────────┤    ├─────────────────┤
│ + SetWidth()    │    │ + SetWidth()    │ ← Forces height = width
│ + SetHeight()   │ ←──│ + SetHeight()   │ ← Breaks rectangle behavior
│ + GetArea()     │    │ + GetArea()     │
└─────────────────┘    └─────────────────┘

// Client code breaks when using Square instead of Rectangle
Rectangle rect = new Square();
rect.SetWidth(5);
rect.SetHeight(4);
Assert.Equal(20, rect.GetArea()); // FAILS! Returns 16

✅ LSP COMPLIANT: Behavioral Contract Maintained
┌─────────────────┐
│   IShape        │
├─────────────────┤
│ + GetArea()     │
│ + CanResize()   │
└─────────────────┘
        ↑
┌───────┴───────┬─────────────┐
│               │             │
Rectangle    Square      Circle
(resizable)  (fixed)    (scalable)
```

**LSP Core Rules**:

- Preconditions cannot be strengthened in subclasses
- Postconditions cannot be weakened in subclasses  
- Invariants must be maintained across inheritance
- History constraint: subclass shouldn't allow state changes forbidden in parent

### Core Concepts (15 minutes)

#### Understanding Behavioral Contracts

##### The Classic Rectangle-Square Problem

```csharp
// ❌ BAD: Square violates LSP when inheriting from Rectangle
public class Rectangle
{
    public virtual int Width { get; set; }
    public virtual int Height { get; set; }
    
    public virtual int GetArea()
    {
        return Width * Height;
    }
    
    public virtual void SetDimensions(int width, int height)
    {
        Width = width;
        Height = height;
    }
}

public class Square : Rectangle
{
    // LSP Violation: Strengthens the precondition
    // Rectangle allows independent width/height, Square doesn't
    public override int Width
    {
        get => base.Width;
        set
        {
            base.Width = value;
            base.Height = value; // ← Unexpected side effect!
        }
    }
    
    public override int Height
    {
        get => base.Height;
        set
        {
            base.Width = value;  // ← Unexpected side effect!
            base.Height = value;
        }
    }
}

// Client code that works with Rectangle but fails with Square
public class GeometryCalculator
{
    public void DemonstrateViolation()
    {
        Rectangle rect = new Square(); // Polymorphic assignment
        
        rect.Width = 5;
        rect.Height = 4;
        
        // Expected: 20 (5 * 4)
        // Actual: 16 (4 * 4) - Square changed both dimensions!
        Console.WriteLine($"Area: {rect.GetArea()}"); // Violates LSP!
    }
}
```

#### LSP-Compliant Design Solutions

##### Solution 1: Interface Segregation

```csharp
// ✅ GOOD: Separate interfaces for different capabilities
public interface IShape
{
    double GetArea();
    double GetPerimeter();
}

public interface IResizableShape : IShape
{
    void Resize(double widthFactor, double heightFactor);
}

public interface IFixedRatioShape : IShape
{
    void Scale(double factor);
}

public class Rectangle : IResizableShape
{
    public double Width { get; private set; }
    public double Height { get; private set; }
    
    public Rectangle(double width, double height)
    {
        Width = width;
        Height = height;
    }
    
    public double GetArea() => Width * Height;
    public double GetPerimeter() => 2 * (Width + Height);
    
    public void Resize(double widthFactor, double heightFactor)
    {
        Width *= widthFactor;
        Height *= heightFactor;
    }
}

public class Square : IFixedRatioShape
{
    public double Side { get; private set; }
    
    public Square(double side)
    {
        Side = side;
    }
    
    public double GetArea() => Side * Side;
    public double GetPerimeter() => 4 * Side;
    
    public void Scale(double factor)
    {
        Side *= factor;
    }
}
```

##### Solution 2: Immutable Design

```csharp
// ✅ GOOD: Immutable shapes eliminate mutation concerns
public abstract class ImmutableShape
{
    public abstract double GetArea();
    public abstract double GetPerimeter();
    public abstract ImmutableShape WithScale(double factor);
}

public class ImmutableRectangle : ImmutableShape
{
    public double Width { get; }
    public double Height { get; }
    
    public ImmutableRectangle(double width, double height)
    {
        Width = width;
        Height = height;
    }
    
    public override double GetArea() => Width * Height;
    public override double GetPerimeter() => 2 * (Width + Height);
    
    public override ImmutableShape WithScale(double factor)
    {
        return new ImmutableRectangle(Width * factor, Height * factor);
    }
    
    public ImmutableRectangle WithDimensions(double width, double height)
    {
        return new ImmutableRectangle(width, height);
    }
}

public class ImmutableSquare : ImmutableShape
{
    public double Side { get; }
    
    public ImmutableSquare(double side)
    {
        Side = side;
    }
    
    public override double GetArea() => Side * Side;
    public override double GetPerimeter() => 4 * Side;
    
    public override ImmutableShape WithScale(double factor)
    {
        return new ImmutableSquare(Side * factor);
    }
}
```

#### Real-World LSP Scenarios

##### File Storage Example

```csharp
// ❌ BAD: ReadOnlyFileStorage violates LSP
public abstract class FileStorage
{
    public abstract Task WriteAsync(string path, byte[] data);
    public abstract Task<byte[]> ReadAsync(string path);
    public abstract Task DeleteAsync(string path);
}

public class LocalFileStorage : FileStorage
{
    public override async Task WriteAsync(string path, byte[] data)
    {
        await File.WriteAllBytesAsync(path, data);
    }
    
    public override async Task<byte[]> ReadAsync(string path)
    {
        return await File.ReadAllBytesAsync(path);
    }
    
    public override async Task DeleteAsync(string path)
    {
        File.Delete(path);
    }
}

public class ReadOnlyFileStorage : FileStorage
{
    public override Task WriteAsync(string path, byte[] data)
    {
        // LSP Violation: Strengthens precondition
        throw new NotSupportedException("Storage is read-only"); // ← Breaks contract!
    }
    
    public override Task DeleteAsync(string path)
    {
        // LSP Violation: Strengthens precondition  
        throw new NotSupportedException("Storage is read-only"); // ← Breaks contract!
    }
    
    public override async Task<byte[]> ReadAsync(string path)
    {
        return await File.ReadAllBytesAsync(path);
    }
}
```

##### LSP-Compliant Solution

```csharp
// ✅ GOOD: Interface segregation preserves LSP
public interface IReadableStorage
{
    Task<byte[] > ReadAsync(string path);
    Task<bool> ExistsAsync(string path);
}

public interface IWritableStorage
{
    Task WriteAsync(string path, byte[] data);
    Task DeleteAsync(string path);
}

public interface IFileStorage : IReadableStorage, IWritableStorage
{
    // Combines both capabilities
}

public class LocalFileStorage : IFileStorage
{
    public async Task<byte[]> ReadAsync(string path)
    {
        return await File.ReadAllBytesAsync(path);
    }
    
    public async Task<bool> ExistsAsync(string path)
    {
        return File.Exists(path);
    }
    
    public async Task WriteAsync(string path, byte[] data)
    {
        await File.WriteAllBytesAsync(path, data);
    }
    
    public Task DeleteAsync(string path)
    {
        File.Delete(path);
        return Task.CompletedTask;
    }
}

public class ReadOnlyFileStorage : IReadableStorage
{
    // Only implements what it can actually do
    public async Task<byte[]> ReadAsync(string path)
    {
        return await File.ReadAllBytesAsync(path);
    }
    
    public Task<bool> ExistsAsync(string path)
    {
        return Task.FromResult(File.Exists(path));
    }
}

// Client can work with appropriate interface
public class DocumentProcessor
{
    private readonly IReadableStorage _storage;
    
    public DocumentProcessor(IReadableStorage storage)
    {
        _storage = storage; // Works with both LocalFileStorage and ReadOnlyFileStorage
    }
    
    public async Task<string> ProcessDocumentAsync(string path)
    {
        if (!await _storage.ExistsAsync(path))
            throw new FileNotFoundException($"Document not found: {path}");
            
        var data = await _storage.ReadAsync(path);
        return ProcessBytes(data);
    }
    
    private string ProcessBytes(byte[] data) => Convert.ToBase64String(data);
}
```

### Practical Implementation (8 minutes)

#### LSP Validation Techniques

##### Contract Testing

```csharp
// Base class contract tests
public abstract class FileStorageContractTests<T> where T : IFileStorage
{
    protected abstract T CreateStorage();
    
    [Test]
    public virtual async Task WriteAsync_ValidData_ShouldSucceed()
    {
        // Arrange
        var storage = CreateStorage();
        var testData = Encoding.UTF8.GetBytes("Test content");
        var path = "test-file.txt";
        
        // Act & Assert
        await storage.WriteAsync(path, testData);
        
        var retrievedData = await storage.ReadAsync(path);
        Assert.Equal(testData, retrievedData);
    }
    
    [Test]
    public virtual async Task ReadAsync_NonExistentFile_ShouldThrowFileNotFoundException()
    {
        // Arrange
        var storage = CreateStorage();
        
        // Act & Assert
        await Assert.ThrowsAsync<FileNotFoundException>(() => 
            storage.ReadAsync("non-existent-file.txt"));
    }
}

// Concrete implementation tests inherit contract
public class LocalFileStorageTests : FileStorageContractTests<LocalFileStorage>
{
    protected override LocalFileStorage CreateStorage()
    {
        return new LocalFileStorage();
    }
}
```

##### Behavioral Invariant Checking

```csharp
// Base class with invariant checking
public abstract class BankAccount
{
    private decimal _balance;
    
    public decimal Balance 
    { 
        get => _balance;
        protected set
        {
            CheckInvariant(value);
            _balance = value;
        }
    }
    
    protected virtual void CheckInvariant(decimal newBalance)
    {
        // Base invariant: balance should not be negative for regular accounts
        if (newBalance < 0)
            throw new InvalidOperationException("Balance cannot be negative");
    }
    
    public virtual void Withdraw(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentException("Amount must be positive");
            
        var newBalance = Balance - amount;
        CheckInvariant(newBalance); // Verify invariant before changing state
        Balance = newBalance;
    }
    
    public virtual void Deposit(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentException("Amount must be positive");
            
        Balance += amount;
    }
}

public class CheckingAccount : BankAccount
{
    private readonly decimal _overdraftLimit;
    
    public CheckingAccount(decimal overdraftLimit = 0)
    {
        _overdraftLimit = overdraftLimit;
    }
    
    protected override void CheckInvariant(decimal newBalance)
    {
        // Weakens postcondition (allows negative balance up to overdraft limit)
        // This is LSP compliant - subclass is more permissive
        if (newBalance < -_overdraftLimit)
            throw new InvalidOperationException($"Balance cannot be less than overdraft limit: {-_overdraftLimit}");
    }
}

public class SavingsAccount : BankAccount
{
    // Inherits base behavior - maintains same invariant
    // LSP compliant: doesn't strengthen preconditions or weaken postconditions
}
```

#### Design Patterns Supporting LSP

##### Template Method with LSP

```csharp
public abstract class DataProcessor<T>
{
    // Template method - defines algorithm structure
    public async Task<ProcessingResult> ProcessAsync(T data)
    {
        try
        {
            var validationResult = await ValidateAsync(data);
            if (!validationResult.IsValid)
                return ProcessingResult.Failed(validationResult.Errors);
                
            var transformedData = await TransformAsync(data);
            var result = await PersistAsync(transformedData);
            
            await NotifyCompletionAsync(result);
            
            return ProcessingResult.Success(result);
        }
        catch (Exception ex)
        {
            await HandleErrorAsync(ex);
            throw;
        }
    }
    
    // Abstract methods that subclasses must implement
    // Contract: must return consistent validation results
    protected abstract Task<ValidationResult> ValidateAsync(T data);
    protected abstract Task<T> TransformAsync(T data);
    protected abstract Task<string> PersistAsync(T data);
    
    // Virtual methods with default implementation
    protected virtual Task NotifyCompletionAsync(string result)
    {
        // Default: no notification
        return Task.CompletedTask;
    }
    
    protected virtual Task HandleErrorAsync(Exception ex)
    {
        // Default: log error
        Console.WriteLine($"Processing failed: {ex.Message}");
        return Task.CompletedTask;
    }
}

// LSP-compliant implementations
public class CustomerDataProcessor : DataProcessor<Customer>
{
    protected override async Task<ValidationResult> ValidateAsync(Customer customer)
    {
        var result = new ValidationResult();
        
        if (string.IsNullOrEmpty(customer.Email))
            result.AddError("Email is required");
            
        return result;
    }
    
    protected override async Task<Customer> TransformAsync(Customer customer)
    {
        // Normalize email to lowercase
        customer.Email = customer.Email?.ToLowerInvariant();
        return customer;
    }
    
    protected override async Task<string> PersistAsync(Customer customer)
    {
        // Save to database and return ID
        return Guid.NewGuid().ToString();
    }
    
    protected override async Task NotifyCompletionAsync(string customerId)
    {
        // Send welcome email
        Console.WriteLine($"Welcome email sent for customer: {customerId}");
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**LSP Success Indicators**:

- ✅ Subclasses can replace parent classes without breaking functionality
- ✅ Client code works correctly with any implementation
- ✅ Behavioral contracts are maintained across inheritance hierarchy
- ✅ Preconditions are not strengthened, postconditions not weakened

**LSP Violation Warning Signs**:

- ❌ Throwing NotSupportedException in overridden methods
- ❌ Checking object types before calling methods
- ❌ Different behavior expectations between parent and child
- ❌ Breaking existing client code when substituting implementations

**LSP Design Guidelines**:

1. **Favor composition over inheritance** when behavior varies significantly
2. **Use interface segregation** to separate different capabilities
3. **Design immutable objects** to eliminate mutation-related LSP violations
4. **Test substitutability** through contract testing
5. **Validate invariants** explicitly in base classes

### Next Steps

**Immediate Actions**:

- Review inheritance hierarchies for LSP violations
- Apply interface segregation to problematic inheritance chains
- Continue to Part 4: **Interface Segregation Principle (ISP)**

**Advanced Topics**:

- Covariance and contravariance in LSP context
- LSP in generic programming
- Design by contract principles

## 🔗 Related Topics

**Prerequisites**: Open/Closed Principle, Inheritance, Polymorphism concepts  
**Builds Upon**: Interface design, Contract testing, Design patterns  
**Enables**: Interface Segregation Principle (Part 4), Robust inheritance hierarchies  
**Related**: Template Method Pattern, Strategy Pattern, Behavioral Design Patterns
