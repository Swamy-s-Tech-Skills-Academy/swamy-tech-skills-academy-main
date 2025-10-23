# 01_SOLID-Part1-Single-Responsibility - Part C

**Learning Level**: Intermediate  
**Prerequisites**: Basic OOP concepts, understanding of classes and methods  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Single Responsibility Principle (SRP) and why it matters

## Part C of 3

Previous: [01_SOLID-Part1-Single-Responsibility-PartB.md](01_SOLID-Part1-Single-Responsibility-PartB.md)

---

    public async Task SendWelcomeAsync(Customer customer)
    {
        await _emailService.SendAsync(customer.Email, 
            "Welcome!", "Thank you for joining us!");
    }
    
    public async Task SendPromotionalSmsAsync(Customer customer, string message)
    {
        await _smsService.SendAsync(customer.Phone, message);
    }
}

```csharp
### Key Takeaways & Next Steps (2 minutes)

**SRP Benefits**:

- ✅ **Maintainability**: Changes to validation don't affect data access
- ✅ **Testability**: Each class can be unit tested independently
- ✅ **Reusability**: Components can be used in different contexts
- ✅ **Team Development**: Different developers can work on different responsibilities

**Common SRP Mistakes**:

- ❌ God classes that do everything
- ❌ Utility classes with unrelated methods
- ❌ Controllers that contain business logic
- ❌ Models that validate themselves

**Quick SRP Assessment**:

1. Can you describe the class purpose in one sentence without "and"?
2. How many reasons could cause this class to change?
3. Could you split this class into smaller, focused classes?

### Next Steps

**Immediate Actions**:

- Review your current codebase for SRP violations
- Practice the refactoring techniques shown above
- Continue to Part 2: **Open/Closed Principle (OCP)**

**Advanced Learning**:

- Dependency Injection patterns for SRP
- Testing strategies for single-responsibility classes
- Microservices architecture and SRP

## 🔗 Related Topics

**Prerequisites**: Object-Oriented Programming fundamentals, Basic design patterns  
**Builds Upon**: Clean Code principles, SOLID foundation concepts  
**Enables**: Open/Closed Principle (Part 2), Dependency Injection patterns  
**Related**: Clean Architecture, Domain-Driven Design, Unit Testing strategies


