# 🏗️ SOLID Principles Deep Dive - Part B

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

## Part B of 6

Previous: [04_SOLID-Principles-Deep-Dive-PartA.md](04_SOLID-Principles-Deep-Dive-PartA.md)
Next: [04_SOLID-Principles-Deep-Dive-PartC.md](04_SOLID-Principles-Deep-Dive-PartC.md)

---

        {
            return rectangle.Width * rectangle.Height;
        }
        else if (shape is Circle circle)
        {
            return Math.PI * circle.Radius * circle.Radius;
        }
        // Problem: Adding Triangle requires modifying this method!
        else if (shape is Triangle triangle)
        {
            return 0.5 * triangle.Base * triangle.Height;
        }

        throw new ArgumentException("Unknown shape type");
    }
}

    ### **✅ OCP Compliant Solution**
csharp
// GOOD - Open for extension, closed for modification
public abstract class Shape
{
    public abstract double CalculateArea();
}

public class Rectangle : Shape
{
    public double Width { get; set; }
    public double Height { get; set; }

    public override double CalculateArea() => Width * Height;
}

public class Circle : Shape
{
    public double Radius { get; set; }

    public override double CalculateArea() => Math.PI * Radius * Radius;
}

// NEW shapes can be added without modifying existing code
public class Triangle : Shape
{
    public double Base { get; set; }
    public double Height { get; set; }

    public override double CalculateArea() => 0.5 * Base * Height;
}

// Calculator doesn't need to change when new shapes are added
public class AreaCalculator
{
    public double CalculateArea(Shape shape) => shape.CalculateArea();
}

    ### **Modern C# OCP with Strategy Pattern**
csharp
// Interface for extensible behavior
public interface IDiscountStrategy
{
    decimal CalculateDiscount(decimal amount);
}

// Concrete strategies
public class RegularCustomerDiscount : IDiscountStrategy
{
    public decimal CalculateDiscount(decimal amount) => amount * 0.05m;
}

public class PremiumCustomerDiscount : IDiscountStrategy
{
    public decimal CalculateDiscount(decimal amount) => amount * 0.15m;
}

// Context class - closed for modification, open for extension
public class PriceCalculator
{
    private readonly IDiscountStrategy`_discountStrategy;

    public PriceCalculator(IDiscountStrategy discountStrategy)
    {`_discountStrategy = discountStrategy;
    }

    public decimal CalculatePrice(decimal basePrice)
    {
        var discount =`_discountStrategy.CalculateDiscount(basePrice);
        return basePrice - discount;
    }
}

    ---

    ## 🔄 L - Liskov Substitution Principle

    ### Definition and Goal (LSP)

    > **"Objects of a superclass should be replaceable with objects of a subclass without breaking the application."** - Barbara Liskov

    **Core Concept**: Derived classes must be substitutable for their base classes.

    ### **❌ LSP Violation Example**
csharp
// BAD - Rectangle-Square violation of LSP
public class Rectangle
{
    public virtual int Width { get; set; }
    public virtual int Height { get; set; }

    public int CalculateArea() => Width * Height;
}

public class Square : Rectangle
