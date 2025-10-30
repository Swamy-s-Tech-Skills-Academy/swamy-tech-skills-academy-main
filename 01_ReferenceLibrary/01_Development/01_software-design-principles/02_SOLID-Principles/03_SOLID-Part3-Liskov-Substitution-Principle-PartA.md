# 03_SOLID-Part3-Liskov-Substitution-Principle - Part A

**Learning Level**: Advanced
**Prerequisites**: Inheritance, polymorphism, Open/Closed Principle (Part 2)
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Liskov Substitution Principle (LSP) and its critical importance

## Part A of 4

Next: [03_SOLID-Part3-Liskov-Substitution-Principle-PartB.md](03_SOLID-Part3-Liskov-Substitution-Principle-PartB.md)

---

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
(resizable)  (fixed)    (scalable)```

**LSP Core Rules**:

- Preconditions cannot be strengthened in subclasses
- Postconditions cannot be weakened in subclasses
- Invariants must be maintained across inheritance
- History constraint: subclass shouldn't allow state changes forbidden in parent

### Core Concepts (15 minutes)

#### Understanding Behavioral Contracts

##### The Classic Rectangle-Square Problem```csharp
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
}```

#### LSP-Compliant Design Solutions

##### Solution 1: Interface Segregation```csharp
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

## 🔗 Related Topics

### **Prerequisites**
- [02_SOLID-Part2-Open-Closed-Principle-PartC.md](02_SOLID-Part2-Open-Closed-Principle-PartC.md)
- [OOP Inheritance](../01_OOP-fundamentals/03_OOP-Inheritance-Polymorphism.md)

### **Builds Upon**
- Inheritance and polymorphism
- Contract-based design

### **Enables Next Steps**
- **Next**: [03_SOLID-Part3-Liskov-Substitution-Principle-PartB.md](03_SOLID-Part3-Liskov-Substitution-Principle-PartB.md)
- **Future**: [04_SOLID-Part4-Interface-Segregation-Principle-PartA.md](04_SOLID-Part4-Interface-Segregation-Principle-PartA.md)

### **Cross-References**
- **Design Patterns**: [Template Method Pattern](../03_Design-Patterns/)
