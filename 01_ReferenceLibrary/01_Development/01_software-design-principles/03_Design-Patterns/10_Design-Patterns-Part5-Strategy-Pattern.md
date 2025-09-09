# 10_Design-Patterns-Part5-Strategy-Pattern

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Observer Pattern (Part 4), Polymorphism concepts  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Strategy Pattern for algorithm selection and policy management
- Implement flexible payment processing, sorting, and validation systems
- Design context-strategy relationships with dependency injection
- Apply strategy patterns in business rules, data processing, and UI rendering

## 📋 Content Sections

### Quick Overview (5 minutes)

**Strategy Pattern**: *"Define a family of algorithms, encapsulate each one, and make them interchangeable. Strategy lets the algorithm vary independently from clients that use it."*

**Core Problem**: Need to select different algorithms or behaviors at runtime without tight coupling to specific implementations.

```text
❌ RIGID ALGORITHM SELECTION
┌─────────────────────────────────────┐
│           PaymentProcessor          │
├─────────────────────────────────────┤
│ + ProcessPayment(type, amount)      │
│                                     │
│ if (type == "CreditCard")           │
│   // Credit card logic             │
│ else if (type == "PayPal")          │
│   // PayPal logic                  │
│ else if (type == "BankTransfer")    │
│   // Bank transfer logic           │
│                                     │
│ ❌ Hard to extend                   │
│ ❌ Violates Open/Closed Principle   │
│ ❌ Complex conditional logic        │
└─────────────────────────────────────┘

✅ STRATEGY PATTERN SOLUTION
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ PaymentContext  │    │ IPaymentStrategy│    │ CreditCardStrategy│
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ - strategy      │◄───│ + Process()     │◄───│ + Process()     │
│ + SetStrategy() │    └─────────────────┘    └─────────────────┘
│ + ProcessPay()  │           ▲                        
└─────────────────┘           │               ┌─────────────────┐
                              └───────────────│ PayPalStrategy  │
                                              ├─────────────────┤
                                              │ + Process()     │
                                              └─────────────────┘
```

**Real-World Applications**:

- **Payment Processing** - Multiple payment methods (card, digital wallet, bank)
- **Data Compression** - Different algorithms (ZIP, GZIP, LZ4)
- **Sorting Algorithms** - Selection based on data size and characteristics
- **Pricing Rules** - Dynamic pricing strategies based on conditions

### Core Concepts (15 minutes)

#### Payment Processing Strategy System

#### Implementation 1: E-Commerce Payment Strategies

```csharp
// Payment result for consistent response handling
public class PaymentResult
{
    public bool IsSuccessful { get; }
    public string TransactionId { get; }
    public string Message { get; }
    public decimal ProcessedAmount { get; }
    public Dictionary<string, object> Metadata { get; }

    public PaymentResult(bool isSuccessful, string transactionId, string message, 
                        decimal processedAmount, Dictionary<string, object> metadata = null)
    {
        IsSuccessful = isSuccessful;
        TransactionId = transactionId ?? string.Empty;
        Message = message ?? string.Empty;
        ProcessedAmount = processedAmount;
        Metadata = metadata ?? new Dictionary<string, object>();
    }

    public static PaymentResult Success(string transactionId, decimal amount, string message = "Payment processed successfully")
    {
        return new PaymentResult(true, transactionId, message, amount);
    }

    public static PaymentResult Failure(string message, decimal amount = 0)
    {
        return new PaymentResult(false, string.Empty, message, amount);
    }
}

// Payment request containing all necessary information
public class PaymentRequest
{
    public decimal Amount { get; }
    public string Currency { get; }
    public string Description { get; }
    public Dictionary<string, object> PaymentDetails { get; }
    public string MerchantId { get; }

    public PaymentRequest(decimal amount, string currency, string description, 
                         string merchantId, Dictionary<string, object> paymentDetails = null)
    {
        if (amount <= 0) throw new ArgumentException("Amount must be positive", nameof(amount));
        
        Amount = amount;
        Currency = currency ?? throw new ArgumentNullException(nameof(currency));
        Description = description ?? throw new ArgumentNullException(nameof(description));
        MerchantId = merchantId ?? throw new ArgumentNullException(nameof(merchantId));
        PaymentDetails = paymentDetails ?? new Dictionary<string, object>();
    }
}

// Strategy interface
public interface IPaymentStrategy
{
    string Name { get; }
    bool SupportsRefunds { get; }
    decimal MinimumAmount { get; }
    decimal MaximumAmount { get; }
    
    Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request);
    Task<PaymentResult> RefundPaymentAsync(string transactionId, decimal amount);
    bool ValidatePaymentDetails(PaymentRequest request);
}

// Concrete strategy: Credit Card processing
public class CreditCardPaymentStrategy : IPaymentStrategy
{
    private readonly ICreditCardProcessor _processor;
    
    public string Name => "Credit Card";
    public bool SupportsRefunds => true;
    public decimal MinimumAmount => 1.00m;
    public decimal MaximumAmount => 10000.00m;

    public CreditCardPaymentStrategy(ICreditCardProcessor processor)
    {
        _processor = processor ?? throw new ArgumentNullException(nameof(processor));
    }

    public bool ValidatePaymentDetails(PaymentRequest request)
    {
        if (!request.PaymentDetails.ContainsKey("CardNumber") ||
            !request.PaymentDetails.ContainsKey("ExpiryDate") ||
            !request.PaymentDetails.ContainsKey("CVV") ||
            !request.PaymentDetails.ContainsKey("CardholderName"))
        {
            return false;
        }

        var cardNumber = request.PaymentDetails["CardNumber"]?.ToString();
        if (string.IsNullOrEmpty(cardNumber) || !IsValidCardNumber(cardNumber))
        {
            return false;
        }

        return request.Amount >= MinimumAmount && request.Amount <= MaximumAmount;
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        if (!ValidatePaymentDetails(request))
        {
            return PaymentResult.Failure("Invalid credit card details");
        }

        try
        {
            var cardNumber = request.PaymentDetails["CardNumber"].ToString();
            var expiryDate = request.PaymentDetails["ExpiryDate"].ToString();
            var cvv = request.PaymentDetails["CVV"].ToString();
            var cardholderName = request.PaymentDetails["CardholderName"].ToString();

            // Simulate credit card processing
            var processingResult = await _processor.ChargeCardAsync(
                cardNumber, expiryDate, cvv, cardholderName, 
                request.Amount, request.Currency, request.Description);

            if (processingResult.IsApproved)
            {
                var metadata = new Dictionary<string, object>
                {
                    ["PaymentMethod"] = "Credit Card",
                    ["Last4Digits"] = cardNumber.Substring(cardNumber.Length - 4),
                    ["AuthorizationCode"] = processingResult.AuthorizationCode
                };

                return new PaymentResult(true, processingResult.TransactionId, 
                                       "Credit card payment successful", request.Amount, metadata);
            }
            else
            {
                return PaymentResult.Failure($"Credit card declined: {processingResult.DeclineReason}");
            }
        }
        catch (Exception ex)
        {
            return PaymentResult.Failure($"Credit card processing error: {ex.Message}");
        }
    }

    public async Task<PaymentResult> RefundPaymentAsync(string transactionId, decimal amount)
    {
        try
        {
            var refundResult = await _processor.RefundTransactionAsync(transactionId, amount);
            
            if (refundResult.IsSuccessful)
            {
                return PaymentResult.Success(refundResult.RefundId, amount, "Refund processed successfully");
            }
            else
            {
                return PaymentResult.Failure($"Refund failed: {refundResult.ErrorMessage}");
            }
        }
        catch (Exception ex)
        {
            return PaymentResult.Failure($"Refund processing error: {ex.Message}");
        }
    }

    private bool IsValidCardNumber(string cardNumber)
    {
        // Simple Luhn algorithm validation
        if (string.IsNullOrEmpty(cardNumber)) return false;
        
        cardNumber = cardNumber.Replace(" ", "").Replace("-", "");
        if (cardNumber.Length < 13 || cardNumber.Length > 19) return false;
        
        return cardNumber.All(char.IsDigit);
    }
}

// Concrete strategy: PayPal processing
public class PayPalPaymentStrategy : IPaymentStrategy
{
    private readonly IPayPalClient _payPalClient;
    
    public string Name => "PayPal";
    public bool SupportsRefunds => true;
    public decimal MinimumAmount => 0.50m;
    public decimal MaximumAmount => 15000.00m;

    public PayPalPaymentStrategy(IPayPalClient payPalClient)
    {
        _payPalClient = payPalClient ?? throw new ArgumentNullException(nameof(payPalClient));
    }

    public bool ValidatePaymentDetails(PaymentRequest request)
    {
        if (!request.PaymentDetails.ContainsKey("PayPalEmail"))
        {
            return false;
        }

        var email = request.PaymentDetails["PayPalEmail"]?.ToString();
        return !string.IsNullOrEmpty(email) && 
               email.Contains("@") && 
               request.Amount >= MinimumAmount && 
               request.Amount <= MaximumAmount;
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        if (!ValidatePaymentDetails(request))
        {
            return PaymentResult.Failure("Invalid PayPal payment details");
        }

        try
        {
            var payPalEmail = request.PaymentDetails["PayPalEmail"].ToString();
            
            var paymentData = new
            {
                Amount = request.Amount,
                Currency = request.Currency,
                Description = request.Description,
                PayerEmail = payPalEmail,
                MerchantId = request.MerchantId
            };

            var result = await _payPalClient.CreatePaymentAsync(paymentData);

            if (result.Status == "COMPLETED")
            {
                var metadata = new Dictionary<string, object>
                {
                    ["PaymentMethod"] = "PayPal",
                    ["PayerEmail"] = payPalEmail,
                    ["PayPalPaymentId"] = result.PaymentId
                };

                return new PaymentResult(true, result.TransactionId, 
                                       "PayPal payment successful", request.Amount, metadata);
            }
            else
            {
                return PaymentResult.Failure($"PayPal payment failed: {result.ErrorMessage}");
            }
        }
        catch (Exception ex)
        {
            return PaymentResult.Failure($"PayPal processing error: {ex.Message}");
        }
    }

    public async Task<PaymentResult> RefundPaymentAsync(string transactionId, decimal amount)
    {
        try
        {
            var refundResult = await _payPalClient.RefundPaymentAsync(transactionId, amount);
            
            return refundResult.IsSuccessful 
                ? PaymentResult.Success(refundResult.RefundId, amount, "PayPal refund processed")
                : PaymentResult.Failure($"PayPal refund failed: {refundResult.ErrorMessage}");
        }
        catch (Exception ex)
        {
            return PaymentResult.Failure($"PayPal refund error: {ex.Message}");
        }
    }
}

// Concrete strategy: Bank Transfer processing
public class BankTransferPaymentStrategy : IPaymentStrategy
{
    private readonly IBankTransferService _bankService;
    
    public string Name => "Bank Transfer";
    public bool SupportsRefunds => false; // Bank transfers typically don't support direct refunds
    public decimal MinimumAmount => 10.00m;
    public decimal MaximumAmount => 50000.00m;

    public BankTransferPaymentStrategy(IBankTransferService bankService)
    {
        _bankService = bankService ?? throw new ArgumentNullException(nameof(bankService));
    }

    public bool ValidatePaymentDetails(PaymentRequest request)
    {
        var requiredFields = new[] { "BankAccountNumber", "RoutingNumber", "AccountHolderName" };
        
        foreach (var field in requiredFields)
        {
            if (!request.PaymentDetails.ContainsKey(field) || 
                string.IsNullOrEmpty(request.PaymentDetails[field]?.ToString()))
            {
                return false;
            }
        }

        return request.Amount >= MinimumAmount && request.Amount <= MaximumAmount;
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request)
    {
        if (!ValidatePaymentDetails(request))
        {
            return PaymentResult.Failure("Invalid bank transfer details");
        }

        try
        {
            var accountNumber = request.PaymentDetails["BankAccountNumber"].ToString();
            var routingNumber = request.PaymentDetails["RoutingNumber"].ToString();
            var accountHolderName = request.PaymentDetails["AccountHolderName"].ToString();

            var transferRequest = new
            {
                FromAccount = accountNumber,
                RoutingNumber = routingNumber,
                AccountHolderName = accountHolderName,
                Amount = request.Amount,
                Currency = request.Currency,
                Description = request.Description,
                MerchantAccount = request.MerchantId
            };

            var result = await _bankService.InitiateTransferAsync(transferRequest);

            if (result.IsInitiated)
            {
                var metadata = new Dictionary<string, object>
                {
                    ["PaymentMethod"] = "Bank Transfer",
                    ["TransferReference"] = result.ReferenceNumber,
                    ["EstimatedClearingTime"] = "2-3 business days",
                    ["BankName"] = result.BankName
                };

                return new PaymentResult(true, result.TransactionId, 
                                       "Bank transfer initiated successfully", request.Amount, metadata);
            }
            else
            {
                return PaymentResult.Failure($"Bank transfer failed: {result.ErrorMessage}");
            }
        }
        catch (Exception ex)
        {
            return PaymentResult.Failure($"Bank transfer error: {ex.Message}");
        }
    }

    public async Task<PaymentResult> RefundPaymentAsync(string transactionId, decimal amount)
    {
        // Bank transfers don't typically support direct refunds
        await Task.CompletedTask; // Async compliance
        return PaymentResult.Failure("Bank transfers do not support automatic refunds. Please process manually.");
    }
}

// Payment context that uses strategies
public class PaymentProcessor
{
    private readonly Dictionary<string, IPaymentStrategy> _strategies;
    private readonly ILogger<PaymentProcessor> _logger;

    public PaymentProcessor(IEnumerable<IPaymentStrategy> strategies, ILogger<PaymentProcessor> logger)
    {
        _strategies = strategies?.ToDictionary(s => s.Name, s => s) ?? 
                     throw new ArgumentNullException(nameof(strategies));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<PaymentResult> ProcessPaymentAsync(string paymentMethod, PaymentRequest request)
    {
        if (!_strategies.TryGetValue(paymentMethod, out var strategy))
        {
            var availableMethods = string.Join(", ", _strategies.Keys);
            return PaymentResult.Failure($"Payment method '{paymentMethod}' not supported. Available: {availableMethods}");
        }

        _logger.LogInformation("Processing {PaymentMethod} payment for amount {Amount} {Currency}", 
                              paymentMethod, request.Amount, request.Currency);

        try
        {
            var result = await strategy.ProcessPaymentAsync(request);
            
            _logger.LogInformation("Payment {Status}: {TransactionId} - {Message}", 
                                  result.IsSuccessful ? "Success" : "Failed", 
                                  result.TransactionId, result.Message);

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error processing {PaymentMethod} payment", paymentMethod);
            return PaymentResult.Failure($"Payment processing failed: {ex.Message}");
        }
    }

    public async Task<PaymentResult> RefundPaymentAsync(string paymentMethod, string transactionId, decimal amount)
    {
        if (!_strategies.TryGetValue(paymentMethod, out var strategy))
        {
            return PaymentResult.Failure($"Payment method '{paymentMethod}' not supported for refunds");
        }

        if (!strategy.SupportsRefunds)
        {
            return PaymentResult.Failure($"{paymentMethod} does not support automatic refunds");
        }

        _logger.LogInformation("Processing refund for {PaymentMethod} transaction {TransactionId}, amount {Amount}", 
                              paymentMethod, transactionId, amount);

        try
        {
            var result = await strategy.RefundPaymentAsync(transactionId, amount);
            
            _logger.LogInformation("Refund {Status}: {TransactionId} - {Message}", 
                                  result.IsSuccessful ? "Success" : "Failed", 
                                  result.TransactionId, result.Message);

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error processing refund for {PaymentMethod}", paymentMethod);
            return PaymentResult.Failure($"Refund processing failed: {ex.Message}");
        }
    }

    public IEnumerable<string> GetAvailablePaymentMethods()
    {
        return _strategies.Keys.ToList();
    }

    public IPaymentStrategy GetPaymentStrategy(string paymentMethod)
    {
        return _strategies.TryGetValue(paymentMethod, out var strategy) ? strategy : null;
    }
}

// Usage example
public class PaymentProcessingExample
{
    public async Task DemonstratePaymentProcessing()
    {
        // Setup strategies (normally done through DI container)
        var strategies = new List<IPaymentStrategy>
        {
            new CreditCardPaymentStrategy(new MockCreditCardProcessor()),
            new PayPalPaymentStrategy(new MockPayPalClient()),
            new BankTransferPaymentStrategy(new MockBankTransferService())
        };

        var logger = new ConsoleLogger<PaymentProcessor>();
        var processor = new PaymentProcessor(strategies, logger);

        Console.WriteLine("Available payment methods: " + 
                         string.Join(", ", processor.GetAvailablePaymentMethods()));

        // Test credit card payment
        var creditCardRequest = new PaymentRequest(
            amount: 99.99m,
            currency: "USD",
            description: "Premium subscription",
            merchantId: "MERCHANT_001",
            paymentDetails: new Dictionary<string, object>
            {
                ["CardNumber"] = "4532123456789012",
                ["ExpiryDate"] = "12/25",
                ["CVV"] = "123",
                ["CardholderName"] = "John Doe"
            });

        var creditCardResult = await processor.ProcessPaymentAsync("Credit Card", creditCardRequest);
        Console.WriteLine($"Credit Card Payment: {creditCardResult.Message}");

        // Test PayPal payment
        var paypalRequest = new PaymentRequest(
            amount: 49.99m,
            currency: "USD", 
            description: "Digital download",
            merchantId: "MERCHANT_001",
            paymentDetails: new Dictionary<string, object>
            {
                ["PayPalEmail"] = "user@example.com"
            });

        var paypalResult = await processor.ProcessPaymentAsync("PayPal", paypalRequest);
        Console.WriteLine($"PayPal Payment: {paypalResult.Message}");

        // Test refund
        if (creditCardResult.IsSuccessful)
        {
            var refundResult = await processor.RefundPaymentAsync("Credit Card", 
                                                                 creditCardResult.TransactionId, 
                                                                 25.00m);
            Console.WriteLine($"Refund: {refundResult.Message}");
        }
    }
}
```

#### Data Processing Strategy System

#### Implementation 2: Sorting and Data Processing Strategies

```csharp
// Generic strategy interface for data processing
public interface IDataProcessingStrategy<T>
{
    string Name { get; }
    string Description { get; }
    bool IsApplicable(IEnumerable<T> data);
    IEnumerable<T> Process(IEnumerable<T> data);
    TimeSpan EstimatedProcessingTime(int itemCount);
}

// Sorting strategies for different scenarios
public class QuickSortStrategy<T> : IDataProcessingStrategy<T> where T : IComparable<T>
{
    public string Name => "QuickSort";
    public string Description => "Fast general-purpose sorting algorithm";

    public bool IsApplicable(IEnumerable<T> data)
    {
        var count = data.Count();
        return count > 10 && count < 100000; // Best for medium datasets
    }

    public IEnumerable<T> Process(IEnumerable<T> data)
    {
        var array = data.ToArray();
        QuickSort(array, 0, array.Length - 1);
        return array;
    }

    public TimeSpan EstimatedProcessingTime(int itemCount)
    {
        // O(n log n) average case
        var operations = itemCount * Math.Log2(itemCount);
        return TimeSpan.FromMilliseconds(operations * 0.001); // Rough estimate
    }

    private void QuickSort(T[] array, int low, int high)
    {
        if (low < high)
        {
            int partitionIndex = Partition(array, low, high);
            QuickSort(array, low, partitionIndex - 1);
            QuickSort(array, partitionIndex + 1, high);
        }
    }

    private int Partition(T[] array, int low, int high)
    {
        T pivot = array[high];
        int i = low - 1;

        for (int j = low; j < high; j++)
        {
            if (array[j].CompareTo(pivot) <= 0)
            {
                i++;
                Swap(array, i, j);
            }
        }

        Swap(array, i + 1, high);
        return i + 1;
    }

    private void Swap(T[] array, int i, int j)
    {
        (array[i], array[j]) = (array[j], array[i]);
    }
}

public class MergeSortStrategy<T> : IDataProcessingStrategy<T> where T : IComparable<T>
{
    public string Name => "MergeSort";
    public string Description => "Stable sorting algorithm with guaranteed O(n log n) performance";

    public bool IsApplicable(IEnumerable<T> data)
    {
        var count = data.Count();
        return count > 1000; // Best for large datasets where stability matters
    }

    public IEnumerable<T> Process(IEnumerable<T> data)
    {
        var array = data.ToArray();
        var temp = new T[array.Length];
        MergeSort(array, temp, 0, array.Length - 1);
        return array;
    }

    public TimeSpan EstimatedProcessingTime(int itemCount)
    {
        // O(n log n) guaranteed
        var operations = itemCount * Math.Log2(itemCount);
        return TimeSpan.FromMilliseconds(operations * 0.002); // Slightly slower than QuickSort
    }

    private void MergeSort(T[] array, T[] temp, int left, int right)
    {
        if (left < right)
        {
            int middle = left + (right - left) / 2;
            MergeSort(array, temp, left, middle);
            MergeSort(array, temp, middle + 1, right);
            Merge(array, temp, left, middle, right);
        }
    }

    private void Merge(T[] array, T[] temp, int left, int middle, int right)
    {
        Array.Copy(array, left, temp, left, right - left + 1);

        int i = left, j = middle + 1, k = left;

        while (i <= middle && j <= right)
        {
            if (temp[i].CompareTo(temp[j]) <= 0)
                array[k++] = temp[i++];
            else
                array[k++] = temp[j++];
        }

        while (i <= middle)
            array[k++] = temp[i++];

        while (j <= right)
            array[k++] = temp[j++];
    }
}

public class BubbleSortStrategy<T> : IDataProcessingStrategy<T> where T : IComparable<T>
{
    public string Name => "BubbleSort";
    public string Description => "Simple sorting algorithm for small datasets";

    public bool IsApplicable(IEnumerable<T> data)
    {
        return data.Count() <= 50; // Only for very small datasets
    }

    public IEnumerable<T> Process(IEnumerable<T> data)
    {
        var array = data.ToArray();
        int n = array.Length;

        for (int i = 0; i < n - 1; i++)
        {
            for (int j = 0; j < n - i - 1; j++)
            {
                if (array[j].CompareTo(array[j + 1]) > 0)
                {
                    (array[j], array[j + 1]) = (array[j + 1], array[j]);
                }
            }
        }

        return array;
    }

    public TimeSpan EstimatedProcessingTime(int itemCount)
    {
        // O(n²) performance
        var operations = itemCount * itemCount;
        return TimeSpan.FromMilliseconds(operations * 0.0001);
    }
}

// Data processing context with strategy selection
public class DataProcessor<T> where T : IComparable<T>
{
    private readonly List<IDataProcessingStrategy<T>> _strategies;
    private IDataProcessingStrategy<T> _currentStrategy;

    public DataProcessor()
    {
        _strategies = new List<IDataProcessingStrategy<T>>
        {
            new BubbleSortStrategy<T>(),
            new QuickSortStrategy<T>(),
            new MergeSortStrategy<T>()
        };
    }

    public void AddStrategy(IDataProcessingStrategy<T> strategy)
    {
        _strategies.Add(strategy ?? throw new ArgumentNullException(nameof(strategy)));
    }

    public IDataProcessingStrategy<T> SelectOptimalStrategy(IEnumerable<T> data)
    {
        var applicableStrategies = _strategies.Where(s => s.IsApplicable(data)).ToList();
        
        if (!applicableStrategies.Any())
        {
            // Fallback to the first strategy that can handle any data
            return _strategies.FirstOrDefault() ?? throw new InvalidOperationException("No strategies available");
        }

        // Select strategy with best estimated performance
        var dataCount = data.Count();
        var optimalStrategy = applicableStrategies
            .OrderBy(s => s.EstimatedProcessingTime(dataCount))
            .First();

        return optimalStrategy;
    }

    public void SetStrategy(string strategyName)
    {
        _currentStrategy = _strategies.FirstOrDefault(s => s.Name.Equals(strategyName, StringComparison.OrdinalIgnoreCase))
                         ?? throw new ArgumentException($"Strategy '{strategyName}' not found");
    }

    public ProcessingResult<T> ProcessData(IEnumerable<T> data, bool autoSelectStrategy = true)
    {
        var stopwatch = Stopwatch.StartNew();
        
        IDataProcessingStrategy<T> strategy;
        if (autoSelectStrategy)
        {
            strategy = SelectOptimalStrategy(data);
        }
        else
        {
            strategy = _currentStrategy ?? throw new InvalidOperationException("No strategy set");
        }

        var dataCount = data.Count();
        var estimatedTime = strategy.EstimatedProcessingTime(dataCount);

        Console.WriteLine($"Processing {dataCount} items using {strategy.Name} (estimated: {estimatedTime.TotalMilliseconds:F1}ms)");

        var processedData = strategy.Process(data);
        stopwatch.Stop();

        return new ProcessingResult<T>
        {
            Data = processedData,
            StrategyUsed = strategy.Name,
            ItemCount = dataCount,
            EstimatedTime = estimatedTime,
            ActualTime = stopwatch.Elapsed,
            PerformanceRatio = stopwatch.Elapsed.TotalMilliseconds / estimatedTime.TotalMilliseconds
        };
    }

    public IEnumerable<string> GetAvailableStrategies()
    {
        return _strategies.Select(s => $"{s.Name}: {s.Description}");
    }
}

public class ProcessingResult<T>
{
    public IEnumerable<T> Data { get; set; }
    public string StrategyUsed { get; set; }
    public int ItemCount { get; set; }
    public TimeSpan EstimatedTime { get; set; }
    public TimeSpan ActualTime { get; set; }
    public double PerformanceRatio { get; set; }

    public override string ToString()
    {
        var efficiency = PerformanceRatio <= 1.0 ? "better than expected" : 
                        PerformanceRatio <= 2.0 ? "as expected" : "slower than expected";
        
        return $"{StrategyUsed}: {ItemCount} items in {ActualTime.TotalMilliseconds:F1}ms " +
               $"(estimated {EstimatedTime.TotalMilliseconds:F1}ms) - {efficiency}";
    }
}

// Usage example
public class DataProcessingExample
{
    public void DemonstrateSortingStrategies()
    {
        var processor = new DataProcessor<int>();
        
        Console.WriteLine("Available strategies:");
        foreach (var strategy in processor.GetAvailableStrategies())
        {
            Console.WriteLine($"  - {strategy}");
        }

        // Test with different dataset sizes
        var datasets = new[]
        {
            GenerateRandomData(25, "Small dataset"),
            GenerateRandomData(500, "Medium dataset"),  
            GenerateRandomData(5000, "Large dataset")
        };

        foreach (var (data, description) in datasets)
        {
            Console.WriteLine($"\n=== {description} ===");
            
            // Auto-select optimal strategy
            var result = processor.ProcessData(data, autoSelectStrategy: true);
            Console.WriteLine(result);
            
            // Verify sorting correctness
            var isSorted = IsSorted(result.Data);
            Console.WriteLine($"Sorting correctness: {(isSorted ? "✅ Correct" : "❌ Failed")}");
        }

        // Manual strategy selection
        Console.WriteLine("\n=== Manual Strategy Selection ===");
        processor.SetStrategy("MergeSort");
        var manualResult = processor.ProcessData(datasets[1].data, autoSelectStrategy: false);
        Console.WriteLine($"Manual selection: {manualResult}");
    }

    private (IEnumerable<int> data, string description) GenerateRandomData(int count, string description)
    {
        var random = new Random(42); // Fixed seed for reproducibility
        var data = Enumerable.Range(0, count)
                            .Select(_ => random.Next(0, 1000))
                            .ToList();
        return (data, description);
    }

    private bool IsSorted<T>(IEnumerable<T> data) where T : IComparable<T>
    {
        var array = data.ToArray();
        for (int i = 1; i < array.Length; i++)
        {
            if (array[i - 1].CompareTo(array[i]) > 0)
                return false;
        }
        return true;
    }
}
```

### Practical Implementation (8 minutes)

#### Business Rules Strategy System

#### Implementation 3: Pricing and Validation Strategies

```csharp
// Customer context for pricing decisions
public class Customer
{
    public string Id { get; }
    public string Name { get; }
    public CustomerType Type { get; }
    public DateTime JoinDate { get; }
    public decimal TotalPurchases { get; set; }
    public bool IsVip => Type == CustomerType.VIP || TotalPurchases > 10000;

    public Customer(string id, string name, CustomerType type, DateTime joinDate)
    {
        Id = id ?? throw new ArgumentNullException(nameof(id));
        Name = name ?? throw new ArgumentNullException(nameof(name));
        Type = type;
        JoinDate = joinDate;
    }
}

public enum CustomerType { Regular, Premium, VIP, Enterprise }

// Product information for pricing
public class Product
{
    public string Id { get; }
    public string Name { get; }
    public decimal BasePrice { get; }
    public ProductCategory Category { get; }
    public bool IsOnSale { get; set; }

    public Product(string id, string name, decimal basePrice, ProductCategory category)
    {
        Id = id ?? throw new ArgumentNullException(nameof(id));
        Name = name ?? throw new ArgumentNullException(nameof(name));
        BasePrice = basePrice;
        Category = category;
    }
}

public enum ProductCategory { Electronics, Books, Clothing, Software, Services }

// Pricing context
public class PricingContext
{
    public Customer Customer { get; }
    public Product Product { get; }
    public int Quantity { get; }
    public DateTime PurchaseDate { get; }
    public string PromoCode { get; }

    public PricingContext(Customer customer, Product product, int quantity, 
                         DateTime purchaseDate, string promoCode = null)
    {
        Customer = customer ?? throw new ArgumentNullException(nameof(customer));
        Product = product ?? throw new ArgumentNullException(nameof(product));
        Quantity = quantity > 0 ? quantity : throw new ArgumentException("Quantity must be positive");
        PurchaseDate = purchaseDate;
        PromoCode = promoCode;
    }
}

// Pricing result
public class PricingResult
{
    public decimal OriginalPrice { get; }
    public decimal FinalPrice { get; }
    public decimal TotalDiscount => OriginalPrice - FinalPrice;
    public decimal DiscountPercentage => OriginalPrice > 0 ? (TotalDiscount / OriginalPrice) * 100 : 0;
    public List<string> AppliedRules { get; }

    public PricingResult(decimal originalPrice, decimal finalPrice, List<string> appliedRules = null)
    {
        OriginalPrice = originalPrice;
        FinalPrice = Math.Max(0, finalPrice); // Ensure non-negative price
        AppliedRules = appliedRules ?? new List<string>();
    }
}

// Pricing strategy interface
public interface IPricingStrategy
{
    string Name { get; }
    int Priority { get; } // Higher priority = applied first
    bool IsApplicable(PricingContext context);
    decimal CalculatePrice(PricingContext context, decimal currentPrice);
    string GetDiscountDescription(PricingContext context);
}

// Concrete pricing strategies
public class VipDiscountStrategy : IPricingStrategy
{
    public string Name => "VIP Discount";
    public int Priority => 100;

    public bool IsApplicable(PricingContext context)
    {
        return context.Customer.IsVip;
    }

    public decimal CalculatePrice(PricingContext context, decimal currentPrice)
    {
        var discountRate = context.Customer.Type == CustomerType.VIP ? 0.15m : 0.10m;
        return currentPrice * (1 - discountRate);
    }

    public string GetDiscountDescription(PricingContext context)
    {
        var percentage = context.Customer.Type == CustomerType.VIP ? 15 : 10;
        return $"VIP customer discount: {percentage}%";
    }
}

public class BulkDiscountStrategy : IPricingStrategy
{
    public string Name => "Bulk Discount";
    public int Priority => 90;

    public bool IsApplicable(PricingContext context)
    {
        return context.Quantity >= 10;
    }

    public decimal CalculatePrice(PricingContext context, decimal currentPrice)
    {
        var discountRate = context.Quantity switch
        {
            >= 100 => 0.20m,
            >= 50 => 0.15m,
            >= 20 => 0.10m,
            >= 10 => 0.05m,
            _ => 0m
        };

        return currentPrice * (1 - discountRate);
    }

    public string GetDiscountDescription(PricingContext context)
    {
        var percentage = context.Quantity switch
        {
            >= 100 => 20,
            >= 50 => 15,
            >= 20 => 10,
            >= 10 => 5,
            _ => 0
        };

        return $"Bulk discount for {context.Quantity} items: {percentage}%";
    }
}

public class SeasonalDiscountStrategy : IPricingStrategy
{
    public string Name => "Seasonal Discount";
    public int Priority => 80;

    public bool IsApplicable(PricingContext context)
    {
        // Black Friday, Christmas sales, etc.
        var month = context.PurchaseDate.Month;
        var day = context.PurchaseDate.Day;
        
        // Black Friday (last Friday of November - simplified as November 25-30)
        if (month == 11 && day >= 25) return true;
        
        // Christmas season (December)
        if (month == 12) return true;
        
        // Summer sale (July)
        if (month == 7) return true;

        return false;
    }

    public decimal CalculatePrice(PricingContext context, decimal currentPrice)
    {
        var month = context.PurchaseDate.Month;
        
        var discountRate = month switch
        {
            11 => 0.25m, // Black Friday
            12 => 0.20m, // Christmas
            7 => 0.15m,  // Summer sale
            _ => 0m
        };

        return currentPrice * (1 - discountRate);
    }

    public string GetDiscountDescription(PricingContext context)
    {
        var month = context.PurchaseDate.Month;
        
        return month switch
        {
            11 => "Black Friday special: 25% off",
            12 => "Christmas sale: 20% off",
            7 => "Summer sale: 15% off",
            _ => "No seasonal discount"
        };
    }
}

public class PromoCodeStrategy : IPricingStrategy
{
    private readonly Dictionary<string, (decimal discount, string description)> _promoCodes;

    public string Name => "Promo Code";
    public int Priority => 70;

    public PromoCodeStrategy()
    {
        _promoCodes = new Dictionary<string, (decimal, string)>
        {
            ["SAVE10"] = (0.10m, "10% off with SAVE10"),
            ["WELCOME20"] = (0.20m, "20% welcome discount"),
            ["STUDENT"] = (0.15m, "Student discount: 15% off"),
            ["FIRST50"] = (50.00m, "$50 off first purchase")
        };
    }

    public bool IsApplicable(PricingContext context)
    {
        return !string.IsNullOrEmpty(context.PromoCode) && 
               _promoCodes.ContainsKey(context.PromoCode.ToUpper());
    }

    public decimal CalculatePrice(PricingContext context, decimal currentPrice)
    {
        var promoCode = context.PromoCode.ToUpper();
        if (!_promoCodes.TryGetValue(promoCode, out var promo))
            return currentPrice;

        // Handle both percentage and fixed amount discounts
        if (promo.discount < 1.0m) // Percentage discount
        {
            return currentPrice * (1 - promo.discount);
        }
        else // Fixed amount discount
        {
            return Math.Max(0, currentPrice - promo.discount);
        }
    }

    public string GetDiscountDescription(PricingContext context)
    {
        var promoCode = context.PromoCode?.ToUpper();
        return _promoCodes.TryGetValue(promoCode, out var promo) 
            ? promo.description 
            : "Invalid promo code";
    }
}

// Pricing engine that orchestrates strategies
public class PricingEngine
{
    private readonly List<IPricingStrategy> _strategies;

    public PricingEngine(IEnumerable<IPricingStrategy> strategies)
    {
        _strategies = strategies?.OrderByDescending(s => s.Priority).ToList() 
                    ?? throw new ArgumentNullException(nameof(strategies));
    }

    public PricingResult CalculatePrice(PricingContext context)
    {
        var originalPrice = context.Product.BasePrice * context.Quantity;
        var currentPrice = originalPrice;
        var appliedRules = new List<string>();

        foreach (var strategy in _strategies)
        {
            if (strategy.IsApplicable(context))
            {
                var newPrice = strategy.CalculatePrice(context, currentPrice);
                if (newPrice < currentPrice)
                {
                    currentPrice = newPrice;
                    appliedRules.Add(strategy.GetDiscountDescription(context));
                }
            }
        }

        return new PricingResult(originalPrice, currentPrice, appliedRules);
    }

    public void AddStrategy(IPricingStrategy strategy)
    {
        _strategies.Add(strategy);
        _strategies.Sort((a, b) => b.Priority.CompareTo(a.Priority));
    }

    public IEnumerable<string> GetAvailableStrategies()
    {
        return _strategies.Select(s => $"{s.Name} (Priority: {s.Priority})");
    }
}

// Usage example
public class PricingStrategyExample
{
    public void DemonstratePricingStrategies()
    {
        // Setup pricing engine
        var strategies = new List<IPricingStrategy>
        {
            new VipDiscountStrategy(),
            new BulkDiscountStrategy(),
            new SeasonalDiscountStrategy(),
            new PromoCodeStrategy()
        };

        var pricingEngine = new PricingEngine(strategies);

        Console.WriteLine("Available pricing strategies:");
        foreach (var strategy in pricingEngine.GetAvailableStrategies())
        {
            Console.WriteLine($"  - {strategy}");
        }

        // Create test scenarios
        var scenarios = new[]
        {
            CreateScenario("Regular customer, 1 item", CustomerType.Regular, 1, DateTime.Now, null),
            CreateScenario("VIP customer, 1 item", CustomerType.VIP, 1, DateTime.Now, null),
            CreateScenario("Regular customer, 25 items", CustomerType.Regular, 25, DateTime.Now, null),
            CreateScenario("VIP customer, 50 items", CustomerType.VIP, 50, DateTime.Now, "SAVE10"),
            CreateScenario("Black Friday sale", CustomerType.Regular, 5, new DateTime(2025, 11, 28), "WELCOME20"),
            CreateScenario("Christmas sale + VIP", CustomerType.VIP, 100, new DateTime(2025, 12, 15), null)
        };

        foreach (var (context, description) in scenarios)
        {
            Console.WriteLine($"\n=== {description} ===");
            var result = pricingEngine.CalculatePrice(context);
            
            Console.WriteLine($"Product: {context.Product.Name} x {context.Quantity}");
            Console.WriteLine($"Original price: ${result.OriginalPrice:F2}");
            Console.WriteLine($"Final price: ${result.FinalPrice:F2}");
            Console.WriteLine($"Total discount: ${result.TotalDiscount:F2} ({result.DiscountPercentage:F1}%)");
            
            if (result.AppliedRules.Any())
            {
                Console.WriteLine("Applied discounts:");
                foreach (var rule in result.AppliedRules)
                {
                    Console.WriteLine($"  - {rule}");
                }
            }
        }
    }

    private (PricingContext context, string description) CreateScenario(
        string description, CustomerType customerType, int quantity, 
        DateTime purchaseDate, string promoCode)
    {
        var customer = new Customer("CUST001", "Test Customer", customerType, DateTime.Now.AddYears(-1));
        if (customerType == CustomerType.VIP) customer.TotalPurchases = 15000;

        var product = new Product("PROD001", "Premium Software License", 99.99m, ProductCategory.Software);
        
        var context = new PricingContext(customer, product, quantity, purchaseDate, promoCode);
        
        return (context, description);
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Strategy Pattern Benefits**:

- ✅ **Algorithm flexibility**: Easy to switch between different approaches
- ✅ **Open/Closed principle**: New strategies can be added without modifying existing code
- ✅ **Testability**: Individual strategies can be tested in isolation
- ✅ **Runtime selection**: Algorithms can be chosen based on context or data

**Strategy Pattern Applications**:

- **Payment processing** - Multiple payment gateways and methods
- **Data processing** - Sorting, compression, encryption algorithms
- **Business rules** - Pricing, validation, calculation strategies
- **UI rendering** - Different themes, layouts, or display modes

**Implementation Considerations**:

- **Strategy selection logic** - How to choose the appropriate strategy
- **Performance impact** - Strategy switching overhead
- **Configuration** - Static vs. dynamic strategy registration
- **Error handling** - Graceful fallbacks when strategies fail

**Best Practices**:

- Use dependency injection for strategy registration
- Implement strategy validation before execution
- Provide meaningful strategy names and descriptions
- Consider strategy composition for complex scenarios

### Next Steps

**Immediate Actions**:

- Implement strategy factories for complex strategy selection
- Add strategy caching for improved performance
- Continue to **Decorator Pattern**: Dynamic behavior composition

**Advanced Topics**:

- Strategy pattern with middleware pipelines
- Composite strategies for multi-step processing
- Strategy pattern in distributed systems

## 🔗 Related Topics

**Prerequisites**: Observer Pattern (Part 4), Polymorphism, Interface design  
**Builds Upon**: SOLID principles, Dependency injection, Algorithm design  
**Enables**: Decorator Pattern, Template Method Pattern, Command Pattern  
**Related**: State pattern, Policy pattern, Chain of responsibility
