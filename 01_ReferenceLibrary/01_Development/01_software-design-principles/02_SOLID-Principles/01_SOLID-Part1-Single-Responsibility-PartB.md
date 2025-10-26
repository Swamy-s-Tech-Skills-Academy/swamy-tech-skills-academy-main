# 01_SOLID-Part1-Single-Responsibility - Part B

**Learning Level**: Intermediate
**Prerequisites**: Basic OOP concepts, understanding of classes and methods
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Understand the Single Responsibility Principle (SRP) and why it matters

## Part B of 3

Previous: [01_SOLID-Part1-Single-Responsibility-PartA.md](01_SOLID-Part1-Single-Responsibility-PartA.md)
Next: [01_SOLID-Part1-Single-Responsibility-PartC.md](01_SOLID-Part1-Single-Responsibility-PartC.md)

---

    private readonly OrderCalculator`_calculator;
    private readonly OrderRepository`_repository;
    private readonly EmailNotificationService`_emailService;
    private readonly ILogger`OrderService``_logger;

    public OrderService(
        OrderValidator validator,
        OrderCalculator calculator,
        OrderRepository repository,
        EmailNotificationService emailService,
        ILogger`OrderService` logger)
    {`_validator = validator;
       `_calculator = calculator;`_repository = repository;
       `_emailService = emailService;`_logger = logger;
    }

    public async Task`ProcessResult` ProcessOrderAsync(Order order)
    {
        try
        {
            // Validate
            var validationResult =`_validator.Validate(order);
            if (!validationResult.IsValid)
                return ProcessResult.Failed(validationResult.Errors);

            // Calculate
            order.Total =`_calculator.CalculateTotal(order);

            // Save
            await`_repository.SaveAsync(order);

            // Notify
            await`_emailService.SendOrderConfirmationAsync(order);

            // Log`_logger.LogInformation("Order {OrderId} processed successfully", order.Id);

            return ProcessResult.Success();
        }
        catch (Exception ex)
        {
           `_logger.LogError(ex, "Failed to process order {OrderId}", order.Id);
            return ProcessResult.Failed($"Processing failed: {ex.Message}");
        }
    }
}

    public class RefactoredDocumentProcessor : IDocumentProcessor
    {
        private readonly IDocumentValidator`_validator;
        private readonly IDocumentConverter`_converter;
        private readonly IDocumentStorage`_storage;

        public RefactoredDocumentProcessor(
            IDocumentValidator validator,
            IDocumentConverter converter,
            IDocumentStorage storage)
        {`_validator = validator;
           `_converter = converter;`_storage = storage;
        }

        public ProcessResult Process(Document document)
        {
            if (!_validator.Validate(document))
                return ProcessResult.Failed("Invalid document");

            var convertedDocument =`_converter.Convert(document);`_storage.Save(convertedDocument);

            return ProcessResult.Success();
        }
    }

### Practical Implementation (8 minutes)

#### SRP Refactoring Checklist

##### Step 1: Identify Responsibilities

    // Analysis technique: Method grouping
    public class CustomerManager
    {
        // Data validation group
        public bool IsValidEmail(string email) { }
        public bool IsValidPhone(string phone) { }

        // Data persistence group
        public void SaveCustomer(Customer customer) { }
        public Customer GetCustomer(int id) { }

        // Business logic group
        public decimal CalculateDiscount(Customer customer) { }
        public bool IsEligibleForPremium(Customer customer) { }

        // Communication group
        public void SendWelcomeEmail(Customer customer) { }
        public void SendPromotionalSms(Customer customer) { }
    }

##### Step 2: Extract Classes

    public class CustomerValidator
    {
        public ValidationResult Validate(Customer customer)
        {
            var result = new ValidationResult();

            if (!IsValidEmail(customer.Email))
                result.AddError("Invalid email format");

            if (!IsValidPhone(customer.Phone))
                result.AddError("Invalid phone format");

            return result;
        }

        private bool IsValidEmail(string email) =>
            !string.IsNullOrEmpty(email) && email.Contains("@");

        private bool IsValidPhone(string phone) =>
            !string.IsNullOrEmpty(phone) && phone.All(char.IsDigit);
    }

    public class CustomerRepository
    {
        private readonly IDbContext`_context;

        public CustomerRepository(IDbContext context)
        {`_context = context;
        }

        public async Task`Customer` GetByIdAsync(int id)
        {
            return await`_context.Customers.FindAsync(id);
        }

        public async Task SaveAsync(Customer customer)
        {`_context.Customers.Add(customer);
            await`_context.SaveChangesAsync();
        }
    }

    public class CustomerBusinessLogic
    {
        public decimal CalculateDiscount(Customer customer)
        {
            if (customer.YearsAsCustomer >= 5)
                return 0.15m; // 15% discount
            if (customer.YearsAsCustomer >= 2)
                return 0.10m; // 10% discount
            return 0.05m; // 5% discount
        }

        public bool IsEligibleForPremium(Customer customer)
        {
            return customer.YearsAsCustomer >= 1 &&
                   customer.TotalPurchases >= 1000m;
        }
    }

    public class CustomerNotificationService
    {
        private readonly IEmailService`_emailService;
        private readonly ISmsService`_smsService;

        public CustomerNotificationService(IEmailService emailService, ISmsService smsService)
        {`_emailService = emailService;
           `_smsService = smsService;
        }

        public async Task SendWelcomeEmailAsync(Customer customer)
        {
            var subject = "Welcome to Our Platform!";
            var body = $"Dear {customer.Name}, welcome to our platform. We're excited to have you!";
            await`_emailService.SendEmailAsync(customer.Email, subject, body);
        }

        public async Task SendPromotionalSmsAsync(Customer customer, string promotion)
        {
            var message = $"Hi {customer.Name}! {promotion}. Reply STOP to opt out.";
            await`_smsService.SendSmsAsync(customer.Phone, message);
        }
    }csharp

##### Step 3: Refactored Service Orchestration

    public class CustomerService
    {
        private readonly CustomerValidator`_validator;
        private readonly CustomerRepository`_repository;
        private readonly CustomerBusinessLogic`_businessLogic;
        private readonly CustomerNotificationService`_notificationService;
        private readonly ILogger`CustomerService``_logger;

        public CustomerService(
            CustomerValidator validator,
            CustomerRepository repository,
            CustomerBusinessLogic businessLogic,
            CustomerNotificationService notificationService,
            ILogger`CustomerService` logger)
        {`_validator = validator;
           `_repository = repository;`_businessLogic = businessLogic;
           `_notificationService = notificationService;`_logger = logger;
        }

        public async Task`ServiceResult<Customer`> CreateCustomerAsync(Customer customer)
        {
            try
            {
                // Validate using dedicated validator
                var validationResult =`_validator.Validate(customer);
                if (!validationResult.IsValid)
                    return ServiceResult`Customer`.Failed(validationResult.Errors);

                // Save using dedicated repository
                await`_repository.SaveAsync(customer);

                // Send notifications using dedicated service
                await`_notificationService.SendWelcomeEmailAsync(customer);

                // Log using injected logger`_logger.LogInformation("Customer {CustomerId} created successfully", customer.Id);

                return ServiceResult`Customer`.Success(customer);
            }
            catch (Exception ex)
            {`_logger.LogError(ex, "Failed to create customer {CustomerId}", customer.Id);
                return ServiceResult`Customer`.Failed($"Customer creation failed: {ex.Message}");
            }
        }

        public async Task`ServiceResult<decimal`> CalculateCustomerDiscountAsync(int customerId)
        {
            try
            {
                var customer = await`_repository.GetByIdAsync(customerId);
                if (customer == null)
                    return ServiceResult`decimal`.Failed("Customer not found");

                var discount =`_businessLogic.CalculateDiscount(customer);
                return ServiceResult`decimal`.Success(discount);
            }
            catch (Exception ex)
            {`_logger.LogError(ex, "Failed to calculate discount for customer {CustomerId}", customerId);
                return ServiceResult`decimal`.Failed($"Discount calculation failed: {ex.Message}");
            }
        }
    }csharp
---

## ✅ Key Takeaways (2 minutes)

### **Single Responsibility Benefits Achieved**

✅ **Maintainability**: Each class has one clear purpose and reason to change
✅ **Testability**: Individual responsibilities can be unit tested in isolation
✅ **Reusability**: Components can be reused across different contexts
✅ **Debugging**: Issues can be traced to specific, focused classes
✅ **Team Development**: Different developers can work on separate responsibilities

### **Refactoring Patterns Applied**

- **Extract Class**: Moving related methods into dedicated classes
- **Dependency Injection**: Loosely coupled dependencies for better testing
- **Interface Segregation**: Focused contracts for each responsibility
- **Service Layer**: Orchestration without business logic mixing

### **What's Next**

**Part C** will cover:

- Advanced SRP scenarios with complex business domains
- Testing strategies for single-responsibility classes
- Performance considerations in highly decomposed systems
- Common SRP violation patterns and how to avoid them

---

## 🔗 Series Navigation

- **Previous**: [01_SOLID-Part1-Single-Responsibility-PartA.md](01_SOLID-Part1-Single-Responsibility-PartA.md)
- **Current**: Part B - Practical Implementation ✅
- **Next**: [01_SOLID-Part1-Single-Responsibility-PartC.md](01_SOLID-Part1-Single-Responsibility-PartC.md)
- **Series**: SOLID Principles Mastery Track

**Last Updated**: October 22, 2025
**Format**: 30-minute focused learning segment
