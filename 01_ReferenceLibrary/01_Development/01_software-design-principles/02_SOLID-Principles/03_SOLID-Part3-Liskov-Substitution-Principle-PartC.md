# 03_SOLID-Part3-Liskov-Substitution-Principle - Part C

**Learning Level**: Advanced
**Prerequisites**: Inheritance, polymorphism, Open/Closed Principle (Part 2)
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Liskov Substitution Principle (LSP) and its critical importance

## Part C of 4

Previous: [03_SOLID-Part3-Liskov-Substitution-Principle-PartB.md](03_SOLID-Part3-Liskov-Substitution-Principle-PartB.md)
Next: [03_SOLID-Part3-Liskov-Substitution-Principle-PartD.md](03_SOLID-Part3-Liskov-Substitution-Principle-PartD.md)

---

        return await File.ReadAllBytesAsync(path);
    }

    public async Task`bool` ExistsAsync(string path)
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
    public async Task`byte[]` ReadAsync(string path)
    {
        return await File.ReadAllBytesAsync(path);
    }

    public Task`bool` ExistsAsync(string path)
    {
        return Task.FromResult(File.Exists(path));
    }
}

// Client can work with appropriate interface
public class DocumentProcessor
{
    private readonly IReadableStorage`_storage;

    public DocumentProcessor(IReadableStorage storage)
    {`_storage = storage; // Works with both LocalFileStorage and ReadOnlyFileStorage
    }

    public async Task`string` ProcessDocumentAsync(string path)
    {
        if (!await`_storage.ExistsAsync(path))
            throw new FileNotFoundException($"Document not found: {path}");

        var data = await`_storage.ReadAsync(path);
        return ProcessBytes(data);
    }

    private string ProcessBytes(byte[] data) => Convert.ToBase64String(data);
}

    ### Practical Implementation (8 minutes)

    #### LSP Validation Techniques

    ##### Contract Testing
csharp
// Base class contract tests
public abstract class FileStorageContractTests`T` where T : IFileStorage
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
        await Assert.ThrowsAsync`FileNotFoundException`(() =>
            storage.ReadAsync("non-existent-file.txt"));
    }
}

// Concrete implementation tests inherit contract
public class LocalFileStorageTests : FileStorageContractTests`LocalFileStorage`
{
    protected override LocalFileStorage CreateStorage()
    {
        return new LocalFileStorage();
    }
}

    ##### Behavioral Invariant Checking
csharp
// Base class with invariant checking
public abstract class BankAccount
{
    private decimal`_balance;

    public decimal Balance
    {
        get =>`_balance;
        protected set
        {
            CheckInvariant(value);`_balance = value;
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
    private readonly decimal`_overdraftLimit;

## 🔗 Related Topics

### **Prerequisites**
- [03_SOLID-Part3-Liskov-Substitution-Principle-PartB.md](03_SOLID-Part3-Liskov-Substitution-Principle-PartB.md)

### **Builds Upon**
- Complete LSP series
- Advanced substitutability patterns

### **Enables Next Steps**
- **Next**: [04_SOLID-Part4-Interface-Segregation-Principle-PartA.md](04_SOLID-Part4-Interface-Segregation-Principle-PartA.md)
- **Future**: [05_SOLID-Part5-Dependency-Inversion-Principle-PartA.md](05_SOLID-Part5-Dependency-Inversion-Principle-PartA.md)

### **Cross-References**
- **Testing**: Contract testing strategies
