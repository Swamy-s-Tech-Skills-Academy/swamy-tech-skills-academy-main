# 🏗️ SOLID Principles Deep Dive - Part C

Advanced OOP Design Principles with C# Implementation

> 📖 **12-minute deep dive** | 🎯 **Focus**: SOLID principles mastery | 🏗️ **Advanced**: Beyond basic OOP concepts

## ✅ **SOLID Coverage Map**

This guide provides **comprehensive understanding and practical application** of SOLID principles in modern C# development:

### 🎯 **Single Responsibility Principle (SRP)**

✅ Class responsibility definition and boundaries  
✅ Refactoring techniques for SRP violations  
✅ Real-world examples and anti-patterns  
✅ Testing implications of good SRP design

### 🔐 **Open/Closed Principle (OCP)**

✅ Extension without modification strategies  
✅ Strategy pattern and polymorphism application  
✅ Plugin architecture examples  
✅ Modern C# features supporting OCP

### 🔄 **Liskov Substitution Principle (LSP)**

✅ Behavioral subtyping rules  
✅ Contract preservation in inheritance  
✅ Common LSP violations and fixes  
✅ Interface design for substitutability

### 🎭 **Interface Segregation Principle (ISP)**

✅ Client-specific interface design  
✅ Fat interface problems and solutions  
✅ Role-based interface modeling  
✅ Dependency injection implications

### 🔗 **Dependency Inversion Principle (DIP)**

✅ Abstraction over concretion  
✅ Dependency injection patterns  
✅ IoC container integration  
✅ Testability and maintainability benefits

---

**Part C of 6**

Previous: [04_SOLID-Principles-Deep-Dive-PartB.md](04_SOLID-Principles-Deep-Dive-PartB.md)
Next: [04_SOLID-Principles-Deep-Dive-PartD.md](04_SOLID-Principles-Deep-Dive-PartD.md)

---

{
    // Violates LSP - changing width affects height unexpectedly
    public override int Width
    {
        get => base.Width;
        set
        {
            base.Width = value;
            base.Height = value; // Side effect!
        }
    }

    public override int Height
    {
        get => base.Height;
        set
        {
            base.Height = value;
            base.Width = value; // Side effect!
        }
    }
}

// This code breaks with Square - violates client expectations
public void TestRectangle(Rectangle rectangle)
{
    rectangle.Width = 5;
    rectangle.Height = 10;

    // Expected: 50, but with Square: 100 (unexpected behavior!)
    Assert.AreEqual(50, rectangle.CalculateArea());
}

```

### **✅ LSP Compliant Solution**

```csharp
// GOOD - Proper abstraction that supports substitution
public abstract class Shape
{
    public abstract int CalculateArea();
}

public class Rectangle : Shape
{
    public int Width { get; set; }
    public int Height { get; set; }

    public override int CalculateArea() => Width * Height;
}

public class Square : Shape
{
    public int Side { get; set; }

    public override int CalculateArea() => Side * Side;
}

// Works correctly with any Shape subclass
public void TestShape(Shape shape)
{
    var area = shape.CalculateArea();
    // No unexpected side effects, behavior is predictable
}
```

### **LSP with Preconditions and Postconditions**

```csharp
// Base class contract
public abstract class FileProcessor
{
    // Precondition: file must exist and be readable
    // Postcondition: returns non-null result
    public abstract string ProcessFile(string filePath);

    protected void ValidateFile(string filePath)
    {
        if (!File.Exists(filePath))
            throw new FileNotFoundException();
    }
}

// GOOD - Maintains base class contract
public class TextFileProcessor : FileProcessor
{
    public override string ProcessFile(string filePath)
    {
        ValidateFile(filePath); // Honors precondition
        var content = File.ReadAllText(filePath);
        return content.ToUpper(); // Always returns non-null (postcondition)
    }
}

// BAD - Violates LSP by weakening postcondition
public class BrokenFileProcessor : FileProcessor
{
    public override string ProcessFile(string filePath)
    {
        ValidateFile(filePath);
        return null; // Violates postcondition!
    }
}
```

---

## 🎭 I - Interface Segregation Principle

### Definition and Goal (ISP)

> **"No client should be forced to depend on methods it does not use."** - Robert C. Martin

**Core Concept**: Many specific interfaces are better than one general-purpose interface.

### **❌ ISP Violation Example**

```csharp
// BAD - Fat interface forcing unnecessary dependencies

