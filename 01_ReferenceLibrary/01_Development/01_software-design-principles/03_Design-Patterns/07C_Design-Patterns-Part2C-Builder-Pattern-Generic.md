# 07C_Design-Patterns-Part2C-Builder-Pattern-Generic

**Learning Level**: Advanced  
**Prerequisites**: Builder Pattern Parts A & B, Generic programming concepts  
**Estimated Time**: Part C of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Master generic builder base classes for code reuse and consistency
- Implement type-safe builder hierarchies with self-returning methods
- Apply builder reset patterns for efficient builder reuse
- Design email message builders with comprehensive validation and attachment support

## 📋 Content Sections (27-Minute Structure)

### Generic Builder Architecture (5 minutes)

**Generic Builder Purpose**: *"Create a reusable base class that enforces consistent builder behavior while allowing specific implementations to maintain type safety and fluent interfaces."*

**Key Generic Builder Components**:

- **Base Builder Class** - Defines common behavior and abstract methods
- **Self-Returning Pattern** - Maintains type safety in method chaining
- **Generic Constraints** - Ensures type safety for product and builder types
- **Reset Mechanism** - Enables builder reuse for performance optimization

```text
🏗️ GENERIC BUILDER HIERARCHY
┌─────────────────────────────────────────────────────────────┐
│ Builder<TProduct, TBuilder>                                 │
├─────────────────────────────────────────────────────────────┤
│ + protected abstract TProduct BuildInternal()              │
│ + protected abstract TBuilder Self { get; }                │
│ + public TProduct Build()                                  │
│ + protected virtual void Reset()                           │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│ EmailMessageBuilder : Builder<EmailMessage, EmailBuilder>  │
├─────────────────────────────────────────────────────────────┤
│ + EmailMessageBuilder To(string email)                     │
│ + EmailMessageBuilder From(string email)                   │
│ + EmailMessageBuilder Subject(string subject)              │
│ + EmailMessageBuilder Body(string body)                    │
│ + EmailMessageBuilder AttachFile(string path)              │
│ + protected override EmailMessage BuildInternal()          │
│ + protected override EmailMessageBuilder Self { get; }     │
└─────────────────────────────────────────────────────────────┘
```

**Generic Builder Benefits**:

- **Code Reuse** - Common builder functionality shared across implementations
- **Type Safety** - Compile-time verification of method chaining types
- **Consistency** - Standardized builder behavior across all implementations
- **Performance** - Builder reuse through reset mechanism reduces garbage collection

### Generic Builder Base Implementation (10 minutes)

#### Abstract Generic Builder Base Class

```csharp
// Generic builder base class with type constraints
public abstract class Builder<TProduct, TBuilder> 
    where TProduct : class 
    where TBuilder : Builder<TProduct, TBuilder>
{
    // Abstract method for derived classes to implement product creation
    protected abstract TProduct BuildInternal();
    
    // Self-returning property for fluent interface type safety
    protected abstract TBuilder Self { get; }
    
    // Public build method with reset capability
    public TProduct Build()
    {
        try
        {
            var product = BuildInternal();
            return product;
        }
        finally
        {
            // Always reset builder state after building for reuse
            Reset();
        }
    }
    
    // Virtual reset method for derived classes to override
    protected virtual void Reset()
    {
        // Default implementation - override in derived classes for specific cleanup
    }
    
    // Optional validation hook for derived classes
    protected virtual void ValidateBeforeBuild()
    {
        // Override in derived classes for custom validation
    }
    
    // Builder state tracking for debugging
    public bool IsEmpty { get; protected set; } = true;
    
    // Mark builder as having data
    protected void MarkAsUsed()
    {
        IsEmpty = false;
    }
    
    // Static factory method pattern
    public static TBuilder Create<TConcreteBuilder>() 
        where TConcreteBuilder : TBuilder, new()
    {
        return new TConcreteBuilder();
    }
}

// Email message product class
public class EmailMessage
{
    public string To { get; init; }
    public string From { get; init; }
    public string Subject { get; init; }
    public string Body { get; init; }
    public List<string> CC { get; init; }
    public List<string> BCC { get; init; }
    public List<EmailAttachment> Attachments { get; init; }
    public EmailPriority Priority { get; init; }
    public bool IsHtml { get; init; }
    public DateTime CreatedAt { get; init; }
    
    // Convenience methods
    public bool HasAttachments => Attachments?.Count > 0;
    public bool HasCarbonCopies => CC?.Count > 0 || BCC?.Count > 0;
    public int TotalRecipients => 1 + (CC?.Count ?? 0) + (BCC?.Count ?? 0);
    
    public override string ToString()
    {
        return $"Email: {Subject} from {From} to {To} ({TotalRecipients} recipients)";
    }
}

// Email attachment data class
public class EmailAttachment
{
    public string FilePath { get; set; }
    public string FileName { get; set; }
    public string ContentType { get; set; }
    public long FileSize { get; set; }
    
    public string FormattedFileSize
    {
        get
        {
            if (FileSize < 1024) return $"{FileSize} B";
            if (FileSize < 1024 * 1024) return $"{FileSize / 1024:F1} KB";
            return $"{FileSize / (1024 * 1024):F1} MB";
        }
    }
}

// Email priority enumeration
public enum EmailPriority
{
    Low = 1,
    Normal = 2,
    High = 3,
    Urgent = 4
}
```

#### Concrete Email Message Builder Implementation

```csharp
// Email message builder using generic base class
public class EmailMessageBuilder : Builder<EmailMessage, EmailMessageBuilder>
{
    private string _to;
    private string _from;
    private string _subject;
    private string _body;
    private readonly List<string> _cc = new();
    private readonly List<string> _bcc = new();
    private readonly List<EmailAttachment> _attachments = new();
    private EmailPriority _priority = EmailPriority.Normal;
    private bool _isHtml = false;
    
    // Self-returning property for type safety
    protected override EmailMessageBuilder Self => this;
    
    // Core email configuration methods
    public EmailMessageBuilder To(string email)
    {
        _to = ValidateEmail(email, nameof(email));
        MarkAsUsed();
        return Self;
    }
    
    public EmailMessageBuilder From(string email)
    {
        _from = ValidateEmail(email, nameof(email));
        MarkAsUsed();
        return Self;
    }
    
    public EmailMessageBuilder Subject(string subject)
    {
        if (string.IsNullOrWhiteSpace(subject))
            throw new ArgumentException("Subject cannot be null or empty", nameof(subject));
            
        _subject = subject.Trim();
        MarkAsUsed();
        return Self;
    }
    
    public EmailMessageBuilder Body(string body)
    {
        _body = body ?? throw new ArgumentNullException(nameof(body));
        _isHtml = false;
        MarkAsUsed();
        return Self;
    }
    
    public EmailMessageBuilder HtmlBody(string htmlBody)
    {
        _body = htmlBody ?? throw new ArgumentNullException(nameof(htmlBody));
        _isHtml = true;
        MarkAsUsed();
        return Self;
    }
    
    // Carbon copy methods
    public EmailMessageBuilder AddCC(string email)
    {
        _cc.Add(ValidateEmail(email, nameof(email)));
        MarkAsUsed();
        return Self;
    }
    
    public EmailMessageBuilder AddCC(params string[] emails)
    {
        if (emails == null || emails.Length == 0)
            throw new ArgumentException("At least one email must be provided", nameof(emails));
            
        foreach (var email in emails)
        {
            _cc.Add(ValidateEmail(email, nameof(email)));
        }
        MarkAsUsed();
        return Self;
    }
    
    public EmailMessageBuilder AddBCC(string email)
    {
        _bcc.Add(ValidateEmail(email, nameof(email)));
        MarkAsUsed();
        return Self;
    }
    
    public EmailMessageBuilder AddBCC(params string[] emails)
    {
        if (emails == null || emails.Length == 0)
            throw new ArgumentException("At least one email must be provided", nameof(emails));
            
        foreach (var email in emails)
        {
            _bcc.Add(ValidateEmail(email, nameof(email)));
        }
        MarkAsUsed();
        return Self;
    }
    
    // Priority and formatting methods
    public EmailMessageBuilder WithPriority(EmailPriority priority)
    {
        _priority = priority;
        MarkAsUsed();
        return Self;
    }
    
    public EmailMessageBuilder WithHighPriority()
    {
        return WithPriority(EmailPriority.High);
    }
    
    public EmailMessageBuilder WithUrgentPriority()
    {
        return WithPriority(EmailPriority.Urgent);
    }
    
    // Attachment methods
    public EmailMessageBuilder AttachFile(string filePath, string fileName = null)
    {
        if (string.IsNullOrEmpty(filePath))
            throw new ArgumentException("File path cannot be null or empty", nameof(filePath));
            
        if (!File.Exists(filePath))
            throw new FileNotFoundException($"Attachment file not found: {filePath}");
            
        var fileInfo = new FileInfo(filePath);
        var attachment = new EmailAttachment
        {
            FilePath = filePath,
            FileName = fileName ?? Path.GetFileName(filePath),
            ContentType = GetContentType(filePath),
            FileSize = fileInfo.Length
        };
        
        // Validate file size (10MB limit)
        if (attachment.FileSize > 10 * 1024 * 1024)
            throw new InvalidOperationException($"Attachment too large: {attachment.FormattedFileSize}. Maximum size is 10MB.");
        
        _attachments.Add(attachment);
        MarkAsUsed();
        Console.WriteLine($"Attached: {attachment.FileName} ({attachment.FormattedFileSize})");
        return Self;
    }
    
    public EmailMessageBuilder AttachFiles(params string[] filePaths)
    {
        if (filePaths == null || filePaths.Length == 0)
            throw new ArgumentException("At least one file path must be provided", nameof(filePaths));
            
        foreach (var filePath in filePaths)
        {
            AttachFile(filePath);
        }
        
        return Self;
    }
    
    // Template methods for common email types
    public EmailMessageBuilder AsWelcomeEmail(string recipientEmail, string userName)
    {
        return To(recipientEmail)
            .Subject($"Welcome to our platform, {userName}!")
            .HtmlBody($@"
                <h1>Welcome, {userName}!</h1>
                <p>Thank you for joining our platform. We're excited to have you on board!</p>
                <p>Get started by exploring our features and setting up your profile.</p>
                <p>Best regards,<br>The Team</p>
            ")
            .WithPriority(EmailPriority.High);
    }
    
    public EmailMessageBuilder AsPasswordResetEmail(string recipientEmail, string resetToken)
    {
        return To(recipientEmail)
            .Subject("Password Reset Request")
            .HtmlBody($@"
                <h2>Password Reset</h2>
                <p>You requested a password reset. Click the link below to reset your password:</p>
                <p><a href='https://example.com/reset?token={resetToken}'>Reset Password</a></p>
                <p>This link expires in 24 hours.</p>
                <p>If you didn't request this, please ignore this email.</p>
            ")
            .WithPriority(EmailPriority.Normal);
    }
    
    // Build implementation
    protected override EmailMessage BuildInternal()
    {
        // Comprehensive validation
        ValidateBeforeBuild();
        
        if (string.IsNullOrEmpty(_to))
            throw new InvalidOperationException("Recipient email is required. Call To() method.");
        if (string.IsNullOrEmpty(_from))
            throw new InvalidOperationException("Sender email is required. Call From() method.");
        if (string.IsNullOrEmpty(_subject))
            throw new InvalidOperationException("Email subject is required. Call Subject() method.");
        if (string.IsNullOrEmpty(_body))
            throw new InvalidOperationException("Email body is required. Call Body() or HtmlBody() method.");
        
        // Create immutable email message
        return new EmailMessage
        {
            To = _to,
            From = _from,
            Subject = _subject,
            Body = _body,
            CC = new List<string>(_cc),
            BCC = new List<string>(_bcc),
            Attachments = new List<EmailAttachment>(_attachments),
            Priority = _priority,
            IsHtml = _isHtml,
            CreatedAt = DateTime.UtcNow
        };
    }
    
    // Reset builder state for reuse
    protected override void Reset()
    {
        _to = null;
        _from = null;
        _subject = null;
        _body = null;
        _cc.Clear();
        _bcc.Clear();
        _attachments.Clear();
        _priority = EmailPriority.Normal;
        _isHtml = false;
        IsEmpty = true;
    }
    
    // Validation helper methods
    private static string ValidateEmail(string email, string paramName)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email cannot be null or empty", paramName);
            
        email = email.Trim();
        
        if (!email.Contains("@") || !email.Contains("."))
            throw new ArgumentException($"Invalid email format: {email}", paramName);
            
        if (email.Length > 320) // RFC 5321 limit
            throw new ArgumentException($"Email address too long: {email}", paramName);
            
        return email;
    }
    
    private static string GetContentType(string filePath)
    {
        var extension = Path.GetExtension(filePath).ToLowerInvariant();
        return extension switch
        {
            ".pdf" => "application/pdf",
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".gif" => "image/gif",
            ".txt" => "text/plain",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            ".xls" => "application/vnd.ms-excel",
            ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            ".zip" => "application/zip",
            _ => "application/octet-stream"
        };
    }
    
    // Static factory method
    public static EmailMessageBuilder Create() => new EmailMessageBuilder();
}
```

### Advanced Usage Examples (10 minutes)

#### Builder Reuse and Performance Optimization

```csharp
// Advanced email builder usage examples
public class AdvancedEmailBuilderExamples
{
    private readonly EmailMessageBuilder _reusableBuilder = EmailMessageBuilder.Create();
    
    public void DemonstrateBuilderReuse()
    {
        Console.WriteLine("=== Advanced Email Builder Examples ===\n");

        // Template-based email creation
        Console.WriteLine("--- Template-Based Emails ---");
        
        var welcomeEmail = EmailMessageBuilder.Create()
            .From("noreply@company.com")
            .AsWelcomeEmail("user@example.com", "John Doe")
            .Build();
            
        Console.WriteLine($"Welcome Email: {welcomeEmail}");
        
        var resetEmail = EmailMessageBuilder.Create()
            .From("security@company.com")
            .AsPasswordResetEmail("user@example.com", "abc123token")
            .Build();
            
        Console.WriteLine($"Reset Email: {resetEmail}");

        // Reusable builder for batch operations
        Console.WriteLine("\n--- Batch Email Creation with Reusable Builder ---");
        var batchEmails = CreateBatchEmails();
        
        foreach (var email in batchEmails)
        {
            Console.WriteLine($"Batch Email: {email.Subject} to {email.To}");
        }

        // Complex email with multiple attachments and recipients
        Console.WriteLine("\n--- Complex Email with Attachments ---");
        try
        {
            var complexEmail = CreateComplexEmail();
            Console.WriteLine($"Complex Email: {complexEmail}");
            Console.WriteLine($"  Attachments: {complexEmail.Attachments.Count}");
            Console.WriteLine($"  Total Recipients: {complexEmail.TotalRecipients}");
            Console.WriteLine($"  Priority: {complexEmail.Priority}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error creating complex email: {ex.Message}");
        }
    }
    
    // Efficient batch email creation using builder reuse
    private List<EmailMessage> CreateBatchEmails()
    {
        var emails = new List<EmailMessage>();
        var recipients = new[]
        {
            ("alice@example.com", "Alice"),
            ("bob@example.com", "Bob"),
            ("charlie@example.com", "Charlie")
        };
        
        // Reuse builder for performance - no object allocation overhead
        foreach (var (email, name) in recipients)
        {
            var message = _reusableBuilder
                .From("newsletter@company.com")
                .To(email)
                .Subject($"Monthly Newsletter - Hello {name}!")
                .HtmlBody($@"
                    <h2>Hi {name}!</h2>
                    <p>Here's your monthly newsletter with the latest updates.</p>
                    <ul>
                        <li>New features released</li>
                        <li>Upcoming events</li>
                        <li>Community highlights</li>
                    </ul>
                    <p>Thank you for being part of our community!</p>
                ")
                .WithPriority(EmailPriority.Normal)
                .Build();
                
            emails.Add(message);
            // Builder automatically resets after Build() call
        }
        
        return emails;
    }
    
    // Complex email with validation and error handling
    private EmailMessage CreateComplexEmail()
    {
        var tempFile1 = Path.GetTempFileName();
        var tempFile2 = Path.GetTempFileName();
        
        try
        {
            // Create temporary files for demonstration
            File.WriteAllText(tempFile1, "This is a sample document content.");
            File.WriteAllText(tempFile2, "This is another sample document.");
            
            return EmailMessageBuilder.Create()
                .From("project@company.com")
                .To("manager@company.com")
                .AddCC("team@company.com", "stakeholder@company.com")
                .AddBCC("audit@company.com")
                .Subject("Project Status Report - Q4 2024")
                .HtmlBody(@"
                    <h1>Project Status Report</h1>
                    <h2>Executive Summary</h2>
                    <p>The project is on track for Q4 delivery with the following highlights:</p>
                    <ul>
                        <li>✅ Phase 1 completed successfully</li>
                        <li>🔄 Phase 2 in progress (75% complete)</li>
                        <li>📅 Phase 3 scheduled for next month</li>
                    </ul>
                    <h2>Key Metrics</h2>
                    <p>Budget utilization: 68%<br>Timeline adherence: 95%<br>Quality score: 4.8/5</p>
                    <p>Please find detailed reports in the attachments.</p>
                    <p>Best regards,<br>Project Team</p>
                ")
                .AttachFile(tempFile1, "project-summary.txt")
                .AttachFile(tempFile2, "detailed-metrics.txt")
                .WithUrgentPriority()
                .Build();
        }
        finally
        {
            // Clean up temporary files
            if (File.Exists(tempFile1)) File.Delete(tempFile1);
            if (File.Exists(tempFile2)) File.Delete(tempFile2);
        }
    }
    
    // Demonstration of error handling and validation
    public void DemonstrateValidationAndErrorHandling()
    {
        Console.WriteLine("\n--- Validation and Error Handling ---");
        
        var builder = EmailMessageBuilder.Create();
        
        // Test various validation scenarios
        try
        {
            builder.Build(); // Should fail - missing required fields
        }
        catch (InvalidOperationException ex)
        {
            Console.WriteLine($"Expected validation error: {ex.Message}");
        }
        
        try
        {
            builder.To("invalid-email"); // Should fail - invalid email format
        }
        catch (ArgumentException ex)
        {
            Console.WriteLine($"Expected email validation error: {ex.Message}");
        }
        
        try
        {
            builder.AttachFile("nonexistent-file.txt"); // Should fail - file not found
        }
        catch (FileNotFoundException ex)
        {
            Console.WriteLine($"Expected file error: {ex.Message}");
        }
        
        // Successful email creation
        var validEmail = EmailMessageBuilder.Create()
            .From("valid@company.com")
            .To("recipient@example.com")
            .Subject("Test Email")
            .Body("This is a test email message.")
            .Build();
            
        Console.WriteLine($"Valid email created: {validEmail}");
    }
}
```

### Key Takeaways & Generic Benefits (2 minutes)

**Generic Builder Pattern Advantages**:

- **Code Reuse** - Common builder functionality centralized in base class
- **Type Safety** - Compile-time verification of method chaining and return types
- **Consistency** - Standardized builder behavior across all implementations
- **Performance** - Builder reuse capability reduces object allocation overhead
- **Maintainability** - Changes to builder behavior propagate automatically

**Generic Builder Best Practices**:

- Use type constraints to ensure compile-time safety
- Implement reset functionality for builder reuse
- Validate comprehensively in BuildInternal method
- Provide static factory methods for convenient instantiation
- Include template methods for common use cases

**When to Use Generic Builders**:

- Multiple similar builders needed across application
- Performance-critical scenarios requiring object reuse
- Complex validation logic that should be standardized
- Type-safe fluent interfaces with inheritance hierarchies

**Next in Series**:

- **[Part D - Enterprise Builder Applications](07D_Design-Patterns-Part2D-Builder-Pattern-Enterprise.md)**

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Builder Fundamentals](07A_Design-Patterns-Part2A-Builder-Pattern-Fundamentals.md)**
- **[Part B - Director Pattern](07B_Design-Patterns-Part2B-Builder-Pattern-Director.md)**
- Generic programming and type constraints

**Builds Upon**:

- Generic class design and constraints
- Method chaining and fluent interfaces
- Object lifecycle management

**Enables**:

- [Fluent API Design](../../patterns/fluent-api/) for domain-specific languages
- [Template Method Pattern](13A_Design-Patterns-Part8A-Template-Method-Fundamentals.md) for algorithmic structure
- [Test Data Builders](../../testing/test-data-builders/) for unit testing

**Next Patterns**:

- [Prototype Pattern](../../creational-patterns/prototype/) for object cloning
- [Composite Pattern](../../structural-patterns/composite/) for hierarchical structures