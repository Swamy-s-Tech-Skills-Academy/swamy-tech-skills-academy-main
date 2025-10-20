# 04_SOLID-Part4-Interface-Segregation-Principle - Part B

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Liskov Substitution Principle (Part 3), Interface design patterns  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Interface Segregation Principle (ISP) and its client-focused design approach

**Part B of 4**

Previous: [04_SOLID-Part4-Interface-Segregation-Principle-PartA.md](04_SOLID-Part4-Interface-Segregation-Principle-PartA.md)
Next: [04_SOLID-Part4-Interface-Segregation-Principle-PartC.md](04_SOLID-Part4-Interface-Segregation-Principle-PartC.md)

---

}

public interface IScanner
{
    byte[] Scan(ScanSettings settings);
    void CalibrateScanner();
}

public interface IFaxMachine
{
    void SendFax(string number, Document document);
    void ReceiveFax();
}

public interface ICopier
{
    void Copy(int copies);
    void SetCopyOptions(CopyOptions options);
}

public interface INetworkDevice
{
    void SendEmail(EmailMessage message);
    void BrowseWeb(string url);
}

// Implementations only implement what they actually support
public class BasicPrinter : IPrinter
{
    public void Print(Document document)
    {
        Console.WriteLine($"Printing: {document.Title}");
    }

    public void SetPrintQuality(PrintQuality quality)
    {
        Console.WriteLine($"Print quality set to: {quality}");
    }
}

public class MultiFunctionDevice : IPrinter, IScanner, ICopier, IFaxMachine
{
    public void Print(Document document)
    {
        Console.WriteLine($"MFD Printing: {document.Title}");
    }

    public void SetPrintQuality(PrintQuality quality)
    {
        Console.WriteLine($"MFD Print quality: {quality}");
    }
    
    public byte[] Scan(ScanSettings settings)
    {
        Console.WriteLine($"MFD Scanning with settings: {settings}");
        return new byte[0]; // Simulated scan data
    }
    
    public void CalibrateScanner()
    {
        Console.WriteLine("MFD Scanner calibrated");
    }
    
    public void Copy(int copies)
    {
        Console.WriteLine($"MFD Making {copies} copies");
    }
    
    public void SetCopyOptions(CopyOptions options)
    {
        Console.WriteLine($"MFD Copy options set: {options}");
    }
    
    public void SendFax(string number, Document document)
    {
        Console.WriteLine($"MFD Sending fax to {number}: {document.Title}");
    }
    
    public void ReceiveFax()
    {
        Console.WriteLine("MFD Ready to receive fax");
    }
}

// Clean, focused client code
public class PrintService
{
    private readonly IPrinter _printer;

    public PrintService(IPrinter printer) // Only depends on what it needs
    {
        _printer = printer;
    }
    
    public void PrintDocument(Document document)
    {
        _printer.Print(document); // No exception handling needed
    }
    
    public void ConfigurePrinting(PrintQuality quality)
    {
        _printer.SetPrintQuality(quality);
    }
}

public class ScanService
{
    private readonly IScanner _scanner;

    public ScanService(IScanner scanner) // Only depends on scanning capability
    {
        _scanner = scanner;
    }
    
    public byte[] ScanDocument(ScanSettings settings)
    {
        return _scanner.Scan(settings);
    }
}

```

#### Advanced ISP Patterns

##### Role-Based Interface Design

```csharp
// Define interfaces based on roles/responsibilities
public interface IReadOnlyUserRepository
{
    Task<User> GetByIdAsync(int id);
    Task<User> GetByEmailAsync(string email);
    Task<IEnumerable<User>> SearchAsync(string criteria);
}

public interface IUserWriter
{
    Task<User> CreateAsync(User user);
    Task UpdateAsync(User user);
    Task DeleteAsync(int id);
}

public interface IUserRepository : IReadOnlyUserRepository, IUserWriter
{
    // Combines both roles for full-featured repository
}

// Specialized services only depend on what they need
public class UserProfileService
{
    private readonly IReadOnlyUserRepository _userRepository; // Read-only dependency
    
    public UserProfileService(IReadOnlyUserRepository userRepository)
    {
        _userRepository = userRepository;

