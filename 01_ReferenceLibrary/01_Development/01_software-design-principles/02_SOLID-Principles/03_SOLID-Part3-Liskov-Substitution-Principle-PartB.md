# 03_SOLID-Part3-Liskov-Substitution-Principle - Part B

**Learning Level**: Advanced
**Prerequisites**: Inheritance, polymorphism, Open/Closed Principle (Part 2)
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Liskov Substitution Principle (LSP) and its critical importance

## Part B of 4

Previous: [03_SOLID-Part3-Liskov-Substitution-Principle-PartA.md](03_SOLID-Part3-Liskov-Substitution-Principle-PartA.md)
Next: [03_SOLID-Part3-Liskov-Substitution-Principle-PartC.md](03_SOLID-Part3-Liskov-Substitution-Principle-PartC.md)

---

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

    ##### Solution 2: Immutable Design
csharp
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

    #### Real-World LSP Scenarios

    ##### File Storage Example
csharp
// ❌ BAD: ReadOnlyFileStorage violates LSP
public abstract class FileStorage
{
    public abstract Task WriteAsync(string path, byte[] data);
    public abstract Task`byte[]` ReadAsync(string path);
    public abstract Task DeleteAsync(string path);
}

public class LocalFileStorage : FileStorage
{
    public override async Task WriteAsync(string path, byte[] data)
    {
        await File.WriteAllBytesAsync(path, data);
    }

    public override async Task`byte[]` ReadAsync(string path)
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

    public override async Task`byte[]` ReadAsync(string path)
    {
        return await File.ReadAllBytesAsync(path);
    }
}

    ##### LSP-Compliant Solution
csharp
// ✅ GOOD: Interface segregation preserves LSP
public interface IReadableStorage
{
    Task`byte[]` ReadAsync(string path);
    Task`bool` ExistsAsync(string path);
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
    public async Task`byte[]` ReadAsync(string path)
    {
