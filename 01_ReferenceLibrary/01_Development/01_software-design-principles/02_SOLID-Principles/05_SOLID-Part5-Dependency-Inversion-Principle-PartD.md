# 05_SOLID-Part5-Dependency-Inversion-Principle - Part D

**Learning Level**: Advanced  
**Prerequisites**: Interface Segregation Principle (Part 4), Dependency injection concepts  
**Estimated Time**: 30 minutes  

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master the Dependency Inversion Principle (DIP) and its architectural implications

## Part D of 4

Previous: [05_SOLID-Part5-Dependency-Inversion-Principle-PartC.md](05_SOLID-Part5-Dependency-Inversion-Principle-PartC.md)

---

    private readonly IEnumerable`IPaymentProcessor` _processors;
    private readonly ILogger _logger;
    
    public PaymentService(IEnumerable`IPaymentProcessor` processors, ILogger logger)
    {
        _processors = processors;
        _logger = logger;
    }
    
    public async Task`PaymentResult` ProcessPaymentAsync(PaymentRequest request)
    {
        var processor = _processors.FirstOrDefault(p => p.CanProcess(request.PaymentType));
        
        if (processor == null)
        {
            var error = $"No processor found for payment type: {request.PaymentType}";
            _logger.LogError(error);
            return PaymentResult.Failed(error);
        }
        
        _logger.Log($"Processing {request.PaymentType} payment for ${request.Amount}");
        
        try
        {
            return await processor.ProcessAsync(request);
        }
        catch (Exception ex)
        {
            _logger.LogError("Payment processing failed", ex);
            return PaymentResult.Failed("Payment processing error");
        }
    }
}

// Concrete processors implement the abstraction
public class CreditCardProcessor : IPaymentProcessor
{
    private readonly ICreditCardGateway _gateway;

    public CreditCardProcessor(ICreditCardGateway gateway)
    {
        _gateway = gateway;
    }
    
    public bool CanProcess(PaymentType paymentType)
    {
        return paymentType == PaymentType.CreditCard;
    }
    
    public async Task`PaymentResult` ProcessAsync(PaymentRequest request)
    {
        var result = await _gateway.ChargeCardAsync(request.CardNumber, request.Amount);
        return new PaymentResult
        {
            Success = result.IsSuccess,
            TransactionId = result.TransactionId
        };
    }
}

public class PayPalProcessor : IPaymentProcessor
{
    private readonly IPayPalApi _payPalApi;

    public PayPalProcessor(IPayPalApi payPalApi)
    {
        _payPalApi = payPalApi;
    }
    
    public bool CanProcess(PaymentType paymentType)
    {
        return paymentType == PaymentType.PayPal;
    }
    
    public async Task`PaymentResult` ProcessAsync(PaymentRequest request)
    {
        var result = await _payPalApi.ProcessPaymentAsync(request.PayPalToken, request.Amount);
        return new PaymentResult
        {
            Success = result.Status == "SUCCESS",
            TransactionId = result.Id
        };
    }
}


    #### Testing with DIP
csharp
// DIP makes unit testing straightforward
public class OrderServiceTests
{
    [Test]
    public async Task ProcessOrder_ValidOrder_ShouldReturnSuccess()
    {
        // Arrange - create mocks for all dependencies
        var mockRepository = new Mock`IOrderRepository`();
        var mockEmailService = new Mock`IEmailService`();
        var mockLogger = new Mock`ILogger`();
        
        var order = new Order
        {
            Id = 1,
            CustomerEmail = "customer@example.com",
            Total = 100.00m,
            Items = new List`OrderItem` { new OrderItem { ProductId = 1, Quantity = 1, Price = 100.00m } }
        };
        
        var orderService = new OrderService(mockRepository.Object, mockEmailService.Object, mockLogger.Object);
        
        // Act
        var result = await orderService.ProcessOrderAsync(order);
        
        // Assert
        Assert.True(result.IsSuccess);
        
        // Verify interactions with dependencies
        mockRepository.Verify(r => r.SaveAsync(It.IsAny`Order`()), Times.Once);
        mockEmailService.Verify(e => e.SendTemplatedAsync(
            "customer@example.com",
            "OrderConfirmation",
            It.IsAny`object`()), Times.Once);
        mockLogger.Verify(l => l.Log(It.IsAny`string`()), Times.AtLeastOnce);
    }
    
    [Test]
    public async Task ProcessOrder_InvalidOrder_ShouldReturnFailure()
    {
        // Arrange
        var mockRepository = new Mock`IOrderRepository`();
        var mockEmailService = new Mock`IEmailService`();
        var mockLogger = new Mock`ILogger`();
        
        var invalidOrder = new Order
        {
            Id = 1,
            CustomerEmail = "", // Invalid - empty email
            Total = 0,          // Invalid - zero total
            Items = new List`OrderItem`() // Invalid - no items
        };
        
        var orderService = new OrderService(mockRepository.Object, mockEmailService.Object, mockLogger.Object);
        
        // Act
        var result = await orderService.ProcessOrderAsync(invalidOrder);
        
        // Assert
        Assert.False(result.IsSuccess);
        Assert.Contains("Customer email is required", result.Errors);
        Assert.Contains("Order total must be greater than zero", result.Errors);
        Assert.Contains("Order must contain at least one item", result.Errors);
        
        // Verify no side effects occurred
        mockRepository.Verify(r => r.SaveAsync(It.IsAny`Order`()), Times.Never);

