# 03_SOLID-Part3-Liskov-Substitution-Principle - Part D

**Learning Level**: Advanced  
**Prerequisites**: Inheritance, polymorphism, Open/Closed Principle (Part 2)  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Liskov Substitution Principle (LSP) and its critical importance

**Part D of 4**

Previous: [03_SOLID-Part3-Liskov-Substitution-Principle-PartC.md](03_SOLID-Part3-Liskov-Substitution-Principle-PartC.md)

---

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


