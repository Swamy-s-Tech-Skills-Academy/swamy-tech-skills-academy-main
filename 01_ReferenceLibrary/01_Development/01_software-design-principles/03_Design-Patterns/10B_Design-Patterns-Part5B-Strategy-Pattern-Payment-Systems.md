# 10B_Design-Patterns-Part5B-Strategy-Pattern-Payment-Systems

**Learning Level**: Intermediate  
**Prerequisites**: Strategy Pattern Fundamentals (Part A), Payment processing concepts  
**Estimated Time**: Part B of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement concrete payment strategies for real-world e-commerce systems
- Design Credit Card, PayPal, and Bank Transfer processing strategies
- Handle strategy-specific validation and error scenarios
- Build strategy selection logic based on business requirements

## 📋 Content Sections (27-Minute Structure)

### E-Commerce Payment Strategies (5 minutes)

Building on Part A's foundation, we now implement concrete payment strategies for different payment methods:

```csharp
// Refund request model
public class RefundRequest
{
    public string TransactionId { get; set; }
    public decimal Amount { get; set; }
    public string Reason { get; set; }
    public string CustomerId { get; set; }

    public RefundRequest(string transactionId, decimal amount, string reason, string customerId)
    {
        TransactionId = transactionId ?? throw new ArgumentNullException(nameof(transactionId));
        Amount = amount;
        Reason = reason ?? "Customer request";
        CustomerId = customerId ?? throw new ArgumentNullException(nameof(customerId));
    }
}

// Refund result
public class RefundResult
{
    public bool IsSuccessful { get; }
    public string RefundId { get; }
    public string Message { get; }
    public DateTime ProcessedAt { get; }

    public RefundResult(bool isSuccessful, string refundId, string message)
    {
        IsSuccessful = isSuccessful;
        RefundId = refundId ?? string.Empty;
        Message = message ?? string.Empty;
        ProcessedAt = DateTime.UtcNow;
    }

    public static RefundResult Success(string refundId, string message = "Refund processed successfully")
    {
        return new RefundResult(true, refundId, message);
    }

    public static RefundResult Failure(string message)
    {
        return new RefundResult(false, string.Empty, message);
    }
}
```

### Concrete Payment Strategies (15 minutes)

#### Credit Card Strategy

```csharp
public class CreditCardStrategy : IPaymentStrategy
{
    public string StrategyName => "Credit Card";
    public decimal ProcessingFee => 0.029m; // 2.9%
    public TimeSpan EstimatedProcessingTime => TimeSpan.FromSeconds(3);
    public bool SupportsRefunds => true;

    private readonly ICreditCardGateway _gateway;

    public CreditCardStrategy(ICreditCardGateway gateway)
    {
        _gateway = gateway ?? throw new ArgumentNullException(nameof(gateway));
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            // Validate credit card specific details
            if (!request.PaymentDetails.ContainsKey("CardNumber") ||
                !request.PaymentDetails.ContainsKey("ExpiryDate") ||
                !request.PaymentDetails.ContainsKey("CVV"))
            {
                return PaymentResult.Failure("Missing credit card details: CardNumber, ExpiryDate, CVV required");
            }

            var cardNumber = request.PaymentDetails["CardNumber"].ToString();
            var expiryDate = request.PaymentDetails["ExpiryDate"].ToString();
            var cvv = request.PaymentDetails["CVV"].ToString();

            // Validate card number format
            if (!IsValidCardNumber(cardNumber))
            {
                return PaymentResult.Failure("Invalid credit card number format");
            }

            // Calculate processing fee
            var fee = request.Amount * ProcessingFee;

            // Process with gateway
            var gatewayRequest = new CreditCardPaymentRequest
            {
                Amount = request.Amount,
                Currency = request.Currency,
                CardNumber = cardNumber,
                ExpiryDate = expiryDate,
                CVV = cvv,
                Description = request.Description,
                CustomerId = request.CustomerId,
                OrderId = request.OrderId
            };

            var gatewayResponse = await _gateway.ProcessPaymentAsync(gatewayRequest, cancellationToken);

            if (gatewayResponse.IsSuccessful)
            {
                var metadata = new Dictionary<string, object>
                {
                    { "CardLast4", cardNumber.Substring(cardNumber.Length - 4) },
                    { "AuthorizationCode", gatewayResponse.AuthorizationCode },
                    { "ProcessorResponse", gatewayResponse.ProcessorResponse }
                };

                return PaymentResult.Success(gatewayResponse.TransactionId, fee, 
                    "Credit card payment processed successfully", metadata);
            }
            else
            {
                return PaymentResult.Failure($"Credit card payment failed: {gatewayResponse.ErrorMessage}", fee);
            }
        }
        catch (Exception ex)
        {
            return PaymentResult.Failure($"Credit card processing error: {ex.Message}");
        }
    }

    public async Task<RefundResult> ProcessRefundAsync(RefundRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            var refundResponse = await _gateway.ProcessRefundAsync(
                request.TransactionId, request.Amount, request.Reason, cancellationToken);

            if (refundResponse.IsSuccessful)
            {
                return RefundResult.Success(refundResponse.RefundId, "Credit card refund processed successfully");
            }
            else
            {
                return RefundResult.Failure($"Credit card refund failed: {refundResponse.ErrorMessage}");
            }
        }
        catch (Exception ex)
        {
            return RefundResult.Failure($"Credit card refund error: {ex.Message}");
        }
    }

    private bool IsValidCardNumber(string cardNumber)
    {
        // Simplified Luhn algorithm validation
        cardNumber = cardNumber.Replace(" ", "").Replace("-", "");
        
        if (cardNumber.Length < 13 || cardNumber.Length > 19)
            return false;

        return cardNumber.All(char.IsDigit);
    }
}

// Gateway interface for dependency injection
public interface ICreditCardGateway
{
    Task<CreditCardGatewayResponse> ProcessPaymentAsync(CreditCardPaymentRequest request, CancellationToken cancellationToken);
    Task<RefundGatewayResponse> ProcessRefundAsync(string transactionId, decimal amount, string reason, CancellationToken cancellationToken);
}
```

#### PayPal Strategy

```csharp
public class PayPalStrategy : IPaymentStrategy
{
    public string StrategyName => "PayPal";
    public decimal ProcessingFee => 0.034m; // 3.4%
    public TimeSpan EstimatedProcessingTime => TimeSpan.FromSeconds(5);
    public bool SupportsRefunds => true;

    private readonly IPayPalGateway _gateway;

    public PayPalStrategy(IPayPalGateway gateway)
    {
        _gateway = gateway ?? throw new ArgumentNullException(nameof(gateway));
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            // Validate PayPal specific details
            if (!request.PaymentDetails.ContainsKey("PayPalEmail"))
            {
                return PaymentResult.Failure("Missing PayPal email address");
            }

            var paypalEmail = request.PaymentDetails["PayPalEmail"].ToString();

            if (!IsValidEmail(paypalEmail))
            {
                return PaymentResult.Failure("Invalid PayPal email address format");
            }

            // Calculate processing fee
            var fee = request.Amount * ProcessingFee;

            // Process with PayPal gateway
            var gatewayRequest = new PayPalPaymentRequest
            {
                Amount = request.Amount,
                Currency = request.Currency,
                PayerEmail = paypalEmail,
                Description = request.Description,
                CustomerId = request.CustomerId,
                OrderId = request.OrderId,
                ReturnUrl = request.PaymentDetails.ContainsKey("ReturnUrl") ? 
                           request.PaymentDetails["ReturnUrl"].ToString() : null,
                CancelUrl = request.PaymentDetails.ContainsKey("CancelUrl") ? 
                           request.PaymentDetails["CancelUrl"].ToString() : null
            };

            var gatewayResponse = await _gateway.ProcessPaymentAsync(gatewayRequest, cancellationToken);

            if (gatewayResponse.IsSuccessful)
            {
                var metadata = new Dictionary<string, object>
                {
                    { "PayPalTransactionId", gatewayResponse.PayPalTransactionId },
                    { "PayerEmail", paypalEmail },
                    { "PaymentStatus", gatewayResponse.PaymentStatus }
                };

                return PaymentResult.Success(gatewayResponse.TransactionId, fee,
                    "PayPal payment processed successfully", metadata);
            }
            else
            {
                return PaymentResult.Failure($"PayPal payment failed: {gatewayResponse.ErrorMessage}", fee);
            }
        }
        catch (Exception ex)
        {
            return PaymentResult.Failure($"PayPal processing error: {ex.Message}");
        }
    }

    public async Task<RefundResult> ProcessRefundAsync(RefundRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            var refundResponse = await _gateway.ProcessRefundAsync(
                request.TransactionId, request.Amount, request.Reason, cancellationToken);

            if (refundResponse.IsSuccessful)
            {
                return RefundResult.Success(refundResponse.RefundId, "PayPal refund processed successfully");
            }
            else
            {
                return RefundResult.Failure($"PayPal refund failed: {refundResponse.ErrorMessage}");
            }
        }
        catch (Exception ex)
        {
            return RefundResult.Failure($"PayPal refund error: {ex.Message}");
        }
    }

    private bool IsValidEmail(string email)
    {
        try
        {
            var addr = new System.Net.Mail.MailAddress(email);
            return addr.Address == email;
        }
        catch
        {
            return false;
        }
    }
}
```

#### Bank Transfer Strategy

```csharp
public class BankTransferStrategy : IPaymentStrategy
{
    public string StrategyName => "Bank Transfer";
    public decimal ProcessingFee => 5.00m; // Flat fee
    public TimeSpan EstimatedProcessingTime => TimeSpan.FromHours(24); // Next business day
    public bool SupportsRefunds => true;

    private readonly IBankTransferGateway _gateway;

    public BankTransferStrategy(IBankTransferGateway gateway)
    {
        _gateway = gateway ?? throw new ArgumentNullException(nameof(gateway));
    }

    public async Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            // Validate bank transfer specific details
            if (!request.PaymentDetails.ContainsKey("AccountNumber") ||
                !request.PaymentDetails.ContainsKey("RoutingNumber") ||
                !request.PaymentDetails.ContainsKey("AccountType"))
            {
                return PaymentResult.Failure("Missing bank details: AccountNumber, RoutingNumber, AccountType required");
            }

            var accountNumber = request.PaymentDetails["AccountNumber"].ToString();
            var routingNumber = request.PaymentDetails["RoutingNumber"].ToString();
            var accountType = request.PaymentDetails["AccountType"].ToString();

            // Validate routing number format (9 digits)
            if (!IsValidRoutingNumber(routingNumber))
            {
                return PaymentResult.Failure("Invalid routing number format (must be 9 digits)");
            }

            // Bank transfers have a minimum amount requirement
            if (request.Amount < 10.00m)
            {
                return PaymentResult.Failure("Bank transfers require a minimum amount of $10.00");
            }

            // Process with bank gateway
            var gatewayRequest = new BankTransferPaymentRequest
            {
                Amount = request.Amount,
                Currency = request.Currency,
                AccountNumber = accountNumber,
                RoutingNumber = routingNumber,
                AccountType = accountType,
                Description = request.Description,
                CustomerId = request.CustomerId,
                OrderId = request.OrderId
            };

            var gatewayResponse = await _gateway.ProcessPaymentAsync(gatewayRequest, cancellationToken);

            if (gatewayResponse.IsSuccessful)
            {
                var metadata = new Dictionary<string, object>
                {
                    { "BankName", gatewayResponse.BankName },
                    { "AccountLast4", accountNumber.Substring(accountNumber.Length - 4) },
                    { "ExpectedSettlement", DateTime.UtcNow.AddBusinessDays(1) },
                    { "ACHTransactionId", gatewayResponse.ACHTransactionId }
                };

                return PaymentResult.Success(gatewayResponse.TransactionId, ProcessingFee,
                    "Bank transfer initiated successfully", metadata);
            }
            else
            {
                return PaymentResult.Failure($"Bank transfer failed: {gatewayResponse.ErrorMessage}", ProcessingFee);
            }
        }
        catch (Exception ex)
        {
            return PaymentResult.Failure($"Bank transfer processing error: {ex.Message}");
        }
    }

    public async Task<RefundResult> ProcessRefundAsync(RefundRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            var refundResponse = await _gateway.ProcessRefundAsync(
                request.TransactionId, request.Amount, request.Reason, cancellationToken);

            if (refundResponse.IsSuccessful)
            {
                return RefundResult.Success(refundResponse.RefundId, 
                    "Bank transfer refund initiated (will process in 3-5 business days)");
            }
            else
            {
                return RefundResult.Failure($"Bank transfer refund failed: {refundResponse.ErrorMessage}");
            }
        }
        catch (Exception ex)
        {
            return RefundResult.Failure($"Bank transfer refund error: {ex.Message}");
        }
    }

    private bool IsValidRoutingNumber(string routingNumber)
    {
        return routingNumber.Length == 9 && routingNumber.All(char.IsDigit);
    }
}
```

### Strategy Selection Logic (5 minutes)

```csharp
public class PaymentStrategyFactory
{
    private readonly IServiceProvider _serviceProvider;

    public PaymentStrategyFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider ?? throw new ArgumentNullException(nameof(serviceProvider));
    }

    public IPaymentStrategy CreateStrategy(string paymentMethod, decimal amount)
    {
        return paymentMethod.ToLowerInvariant() switch
        {
            "creditcard" => _serviceProvider.GetRequiredService<CreditCardStrategy>(),
            "paypal" => _serviceProvider.GetRequiredService<PayPalStrategy>(),
            "banktransfer" when amount >= 10.00m => _serviceProvider.GetRequiredService<BankTransferStrategy>(),
            "banktransfer" => throw new ArgumentException("Bank transfers require minimum $10.00"),
            _ => throw new ArgumentException($"Unsupported payment method: {paymentMethod}")
        };
    }

    public static List<string> GetAvailablePaymentMethods(decimal amount)
    {
        var methods = new List<string> { "creditcard", "paypal" };
        
        if (amount >= 10.00m)
        {
            methods.Add("banktransfer");
        }

        return methods;
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Mastered in Part B**:

- Concrete payment strategy implementations for e-commerce systems
- Strategy-specific validation and error handling
- Gateway abstraction for external payment processors
- Strategy selection logic based on business requirements

**Next Steps**:

- **Part C**: Data Processing Strategies (Sorting algorithms, compression strategies)
- **Part D**: Business Rules Strategies (Pricing models, validation rules) + Key Takeaways

## 🔗 Related Topics

**Prerequisites**:

- **[Part A - Strategy Fundamentals](10A_Design-Patterns-Part5A-Strategy-Pattern-Fundamentals.md)**
- [Dependency injection concepts](../../dependency-patterns/)

**Enables**:

- **[Part C - Data Processing](10C_Design-Patterns-Part5C-Strategy-Pattern-Data-Processing.md)**
- [Payment gateway integration](../../integration-patterns/)
- [E-commerce system architecture](../../business-patterns/)