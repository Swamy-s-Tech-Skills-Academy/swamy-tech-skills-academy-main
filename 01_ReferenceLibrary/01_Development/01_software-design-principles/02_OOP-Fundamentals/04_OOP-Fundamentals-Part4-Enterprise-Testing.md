# OOP Fundamentals Part 4: Enterprise Best Practices and Testing

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: OOP Fundamentals Parts 1-3 (Complete OOP Foundation)  
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this session, you will understand:

- Enterprise-grade class design principles
- Comprehensive testing patterns for OOP systems
- Performance optimization in object-oriented code
- Production deployment considerations

## 📋 Quick Overview (5 minutes)

### Enterprise OOP Excellence

Building on our complete OOP foundation, we now focus on production-ready implementations:

**Class Design**: Single responsibility, immutability, and clean contracts
**Testing Strategies**: Unit testing, mocking, and integration testing  
**Performance**: Memory management, lazy loading, and optimization patterns
**Production**: Logging, monitoring, and deployment best practices

These practices ensure scalable, maintainable enterprise applications.

## 🔧 Core Concepts (15 minutes)

### Enterprise Class Design

Design classes for production scalability and maintainability:

```python
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any, Protocol
from datetime import datetime, timedelta
from functools import wraps
import logging
import time

# Configure logging for enterprise systems
logging.basicConfig(level=logging.INFO, 
                   format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

@dataclass(frozen=True)  # Immutable value objects
class Money:
    """Immutable money representation for financial calculations"""
    amount: float
    currency: str = "USD"
    
    def __post_init__(self):
        if self.amount < 0:
            raise ValueError("Money amount cannot be negative")
        if not self.currency or len(self.currency) != 3:
            raise ValueError("Currency must be 3-character code")
    
    def add(self, other: 'Money') -> 'Money':
        if self.currency != other.currency:
            raise ValueError(f"Cannot add {self.currency} and {other.currency}")
        return Money(self.amount + other.amount, self.currency)
    
    def multiply(self, factor: float) -> 'Money':
        return Money(self.amount * factor, self.currency)
    
    def __str__(self) -> str:
        return f"{self.amount:.2f} {self.currency}"

@dataclass(frozen=True)
class CustomerInfo:
    """Immutable customer data with validation"""
    customer_id: str
    email: str
    name: str
    created_at: datetime = field(default_factory=datetime.now)
    
    def __post_init__(self):
        if not self.customer_id or not self.email or not self.name:
            raise ValueError("Customer ID, email, and name are required")
        if "@" not in self.email:
            raise ValueError("Invalid email format")

# Performance decorator for monitoring
def performance_monitor(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        execution_time = time.time() - start_time
        
        logger = logging.getLogger(func.__module__)
        logger.info(f"{func.__name__} executed in {execution_time:.4f} seconds")
        
        return result
    return wrapper

# Repository pattern for data access
class CustomerRepository(ABC):
    @abstractmethod
    def save(self, customer: CustomerInfo) -> bool:
        pass
    
    @abstractmethod
    def find_by_id(self, customer_id: str) -> Optional[CustomerInfo]:
        pass
    
    @abstractmethod
    def find_by_email(self, email: str) -> Optional[CustomerInfo]:
        pass

class InMemoryCustomerRepository(CustomerRepository):
    def __init__(self):
        self._customers: Dict[str, CustomerInfo] = {}
        self._email_index: Dict[str, str] = {}
        self._logger = logging.getLogger(__name__)
    
    @performance_monitor
    def save(self, customer: CustomerInfo) -> bool:
        try:
            self._customers[customer.customer_id] = customer
            self._email_index[customer.email] = customer.customer_id
            self._logger.info(f"Customer saved: {customer.customer_id}")
            return True
        except Exception as e:
            self._logger.error(f"Failed to save customer {customer.customer_id}: {e}")
            return False
    
    def find_by_id(self, customer_id: str) -> Optional[CustomerInfo]:
        return self._customers.get(customer_id)
    
    def find_by_email(self, email: str) -> Optional[CustomerInfo]:
        customer_id = self._email_index.get(email)
        return self._customers.get(customer_id) if customer_id else None

# Service layer with comprehensive error handling
class OrderProcessingError(Exception):
    def __init__(self, message: str, error_code: str, order_id: str = None):
        super().__init__(message)
        self.error_code = error_code
        self.order_id = order_id

@dataclass
class OrderItem:
    product_id: str
    quantity: int
    unit_price: Money
    
    def get_total_price(self) -> Money:
        return self.unit_price.multiply(self.quantity)

class OrderService:
    def __init__(self, customer_repo: CustomerRepository):
        self._customer_repo = customer_repo
        self._orders: Dict[str, Dict] = {}
        self._order_counter = 0
        self._logger = logging.getLogger(__name__)
    
    @performance_monitor
    def create_order(self, customer_id: str, items: List[OrderItem]) -> str:
        try:
            # Validate customer exists
            customer = self._customer_repo.find_by_id(customer_id)
            if not customer:
                raise OrderProcessingError(
                    f"Customer not found: {customer_id}",
                    "CUSTOMER_NOT_FOUND"
                )
            
            # Validate order items
            if not items or len(items) == 0:
                raise OrderProcessingError(
                    "Order must contain at least one item",
                    "EMPTY_ORDER"
                )
            
            # Calculate total
            total = Money(0.0, items[0].unit_price.currency)
            for item in items:
                if item.quantity <= 0:
                    raise OrderProcessingError(
                        f"Invalid quantity for product {item.product_id}",
                        "INVALID_QUANTITY"
                    )
                total = total.add(item.get_total_price())
            
            # Create order
            self._order_counter += 1
            order_id = f"ORD-{self._order_counter:06d}"
            
            order = {
                'order_id': order_id,
                'customer_id': customer_id,
                'items': items,
                'total': total,
                'status': 'created',
                'created_at': datetime.now()
            }
            
            self._orders[order_id] = order
            self._logger.info(f"Order created: {order_id} for customer {customer_id}, total {total}")
            
            return order_id
            
        except OrderProcessingError:
            raise  # Re-raise business exceptions
        except Exception as e:
            self._logger.error(f"Unexpected error creating order: {e}")
            raise OrderProcessingError(
                "Internal error during order processing",
                "INTERNAL_ERROR"
            )
    
    def get_order(self, order_id: str) -> Optional[Dict]:
        return self._orders.get(order_id)
    
    def get_orders_by_customer(self, customer_id: str) -> List[Dict]:
        return [order for order in self._orders.values() 
                if order['customer_id'] == customer_id]
```

### Comprehensive Testing Patterns

Implement thorough testing strategies for OOP systems:

```python
import unittest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime

class TestCustomerRepository(unittest.TestCase):
    def setUp(self):
        """Set up test fixtures before each test method."""
        self.repo = InMemoryCustomerRepository()
        self.test_customer = CustomerInfo(
            customer_id="CUST001",
            email="test@example.com",
            name="Test Customer"
        )
    
    def test_save_customer_success(self):
        """Test successful customer save operation."""
        result = self.repo.save(self.test_customer)
        
        self.assertTrue(result)
        saved_customer = self.repo.find_by_id("CUST001")
        self.assertIsNotNone(saved_customer)
        self.assertEqual(saved_customer.email, "test@example.com")
    
    def test_find_by_email(self):
        """Test customer lookup by email."""
        self.repo.save(self.test_customer)
        
        found_customer = self.repo.find_by_email("test@example.com")
        self.assertIsNotNone(found_customer)
        self.assertEqual(found_customer.customer_id, "CUST001")
    
    def test_customer_not_found(self):
        """Test handling of non-existent customer."""
        result = self.repo.find_by_id("NONEXISTENT")
        self.assertIsNone(result)

class TestOrderService(unittest.TestCase):
    def setUp(self):
        """Set up test dependencies with mocks."""
        self.mock_repo = Mock(spec=CustomerRepository)
        self.order_service = OrderService(self.mock_repo)
        
        self.test_customer = CustomerInfo(
            customer_id="CUST001",
            email="test@example.com", 
            name="Test Customer"
        )
        
        self.test_items = [
            OrderItem("PROD001", 2, Money(25.00, "USD")),
            OrderItem("PROD002", 1, Money(15.00, "USD"))
        ]
    
    def test_create_order_success(self):
        """Test successful order creation."""
        # Arrange
        self.mock_repo.find_by_id.return_value = self.test_customer
        
        # Act
        order_id = self.order_service.create_order("CUST001", self.test_items)
        
        # Assert
        self.assertTrue(order_id.startswith("ORD-"))
        self.mock_repo.find_by_id.assert_called_once_with("CUST001")
        
        # Verify order details
        order = self.order_service.get_order(order_id)
        self.assertIsNotNone(order)
        self.assertEqual(order['customer_id'], "CUST001")
        self.assertEqual(order['total'].amount, 65.00)  # 2*25 + 1*15
    
    def test_create_order_customer_not_found(self):
        """Test order creation with non-existent customer."""
        # Arrange
        self.mock_repo.find_by_id.return_value = None
        
        # Act & Assert
        with self.assertRaises(OrderProcessingError) as context:
            self.order_service.create_order("NONEXISTENT", self.test_items)
        
        self.assertEqual(context.exception.error_code, "CUSTOMER_NOT_FOUND")
    
    def test_create_order_empty_items(self):
        """Test order creation with empty items list."""
        # Arrange
        self.mock_repo.find_by_id.return_value = self.test_customer
        
        # Act & Assert
        with self.assertRaises(OrderProcessingError) as context:
            self.order_service.create_order("CUST001", [])
        
        self.assertEqual(context.exception.error_code, "EMPTY_ORDER")
    
    @patch('time.time')
    def test_performance_monitoring(self, mock_time):
        """Test performance monitoring decorator."""
        # Arrange
        mock_time.side_effect = [1000.0, 1000.5]  # 0.5 second execution
        self.mock_repo.find_by_id.return_value = self.test_customer
        
        # Act
        with patch('logging.getLogger') as mock_logger:
            mock_log_instance = mock_logger.return_value
            order_id = self.order_service.create_order("CUST001", self.test_items)
            
            # Assert performance was logged
            mock_log_instance.info.assert_called()
            log_calls = [call.args[0] for call in mock_log_instance.info.call_args_list]
            performance_logs = [log for log in log_calls if "executed in" in log]
            self.assertTrue(any("create_order executed in 0.5000 seconds" in log 
                              for log in performance_logs))

class TestMoneyValueObject(unittest.TestCase):
    """Test immutable money value object."""
    
    def test_money_creation(self):
        """Test money object creation and immutability."""
        money = Money(100.50, "USD")
        
        self.assertEqual(money.amount, 100.50)
        self.assertEqual(money.currency, "USD")
        
        # Test immutability
        with self.assertRaises(AttributeError):
            money.amount = 200.00  # Should raise error due to frozen dataclass
    
    def test_money_addition(self):
        """Test money arithmetic operations."""
        money1 = Money(100.00, "USD")
        money2 = Money(50.00, "USD")
        
        result = money1.add(money2)
        
        self.assertEqual(result.amount, 150.00)
        self.assertEqual(result.currency, "USD")
    
    def test_money_currency_mismatch(self):
        """Test currency validation in operations."""
        usd_money = Money(100.00, "USD")
        eur_money = Money(50.00, "EUR")
        
        with self.assertRaises(ValueError) as context:
            usd_money.add(eur_money)
        
        self.assertIn("Cannot add USD and EUR", str(context.exception))

# Integration test example
class TestOrderSystemIntegration(unittest.TestCase):
    """Integration tests for complete order system."""
    
    def setUp(self):
        self.customer_repo = InMemoryCustomerRepository()
        self.order_service = OrderService(self.customer_repo)
    
    def test_complete_order_workflow(self):
        """Test end-to-end order processing workflow."""
        # Create customer
        customer = CustomerInfo("CUST001", "test@example.com", "Test Customer")
        self.assertTrue(self.customer_repo.save(customer))
        
        # Create order
        items = [
            OrderItem("LAPTOP001", 1, Money(999.99, "USD")),
            OrderItem("MOUSE001", 2, Money(29.99, "USD"))
        ]
        
        order_id = self.order_service.create_order("CUST001", items)
        self.assertIsNotNone(order_id)
        
        # Verify order
        order = self.order_service.get_order(order_id)
        self.assertEqual(order['customer_id'], "CUST001")
        self.assertEqual(order['total'].amount, 1059.97)  # 999.99 + 2*29.99
        
        # Verify customer's orders
        customer_orders = self.order_service.get_orders_by_customer("CUST001")
        self.assertEqual(len(customer_orders), 1)
        self.assertEqual(customer_orders[0]['order_id'], order_id)

def run_comprehensive_tests():
    """Run all test suites with detailed reporting."""
    test_classes = [
        TestCustomerRepository,
        TestOrderService, 
        TestMoneyValueObject,
        TestOrderSystemIntegration
    ]
    
    total_tests = 0
    total_failures = 0
    
    for test_class in test_classes:
        suite = unittest.TestLoader().loadTestsFromTestCase(test_class)
        runner = unittest.TextTestRunner(verbosity=2)
        result = runner.run(suite)
        
        total_tests += result.testsRun
        total_failures += len(result.failures) + len(result.errors)
    
    print(f"\n=== Test Summary ===")
    print(f"Total Tests: {total_tests}")
    print(f"Failures: {total_failures}")
    print(f"Success Rate: {((total_tests - total_failures) / total_tests * 100):.1f}%")
```

## ⚡ Practical Implementation (8 minutes)

### Production-Ready Demonstration

```python
def demonstrate_enterprise_practices():
    print("=== Enterprise Class Design Demo ===")
    
    # Setup enterprise system
    customer_repo = InMemoryCustomerRepository()
    order_service = OrderService(customer_repo)
    
    # Create customers with validation
    try:
        customer1 = CustomerInfo("CUST001", "alice@company.com", "Alice Johnson")
        customer2 = CustomerInfo("CUST002", "bob@enterprise.com", "Bob Smith")
        
        customer_repo.save(customer1)
        customer_repo.save(customer2)
        
        print(f"Created customers: {customer1.name}, {customer2.name}")
        
    except ValueError as e:
        print(f"Customer validation error: {e}")
    
    # Process orders with comprehensive error handling
    try:
        # Successful order
        items = [
            OrderItem("LAPTOP001", 1, Money(1299.99, "USD")),
            OrderItem("WARRANTY001", 1, Money(199.99, "USD"))
        ]
        
        order_id = order_service.create_order("CUST001", items)
        print(f"Order created successfully: {order_id}")
        
        # Display order details
        order = order_service.get_order(order_id)
        print(f"Order total: {order['total']}")
        
    except OrderProcessingError as e:
        print(f"Order processing failed: {e} (Code: {e.error_code})")
    
    # Demonstrate error scenarios
    print("\n=== Error Handling Demo ===")
    try:
        # Invalid customer
        order_service.create_order("INVALID", items)
    except OrderProcessingError as e:
        print(f"Expected error: {e.error_code}")
    
    try:
        # Empty order
        order_service.create_order("CUST001", [])
    except OrderProcessingError as e:
        print(f"Expected error: {e.error_code}")
    
    # Money operations demo
    print("\n=== Money Value Object Demo ===")
    price1 = Money(99.99, "USD")
    price2 = Money(149.99, "USD")
    
    total = price1.add(price2)
    discounted = total.multiply(0.9)  # 10% discount
    
    print(f"Original total: {total}")
    print(f"After discount: {discounted}")
    
    # Performance monitoring demo
    print("\n=== Performance Monitoring Demo ===")
    with patch('logging.getLogger') as mock_logger:
        # Create multiple orders to demonstrate monitoring
        for i in range(3):
            customer_id = f"CUST00{i+1}"
            if customer_repo.find_by_id(customer_id):
                order_service.create_order(customer_id, [
                    OrderItem(f"PROD{i+1}", 1, Money(50.0, "USD"))
                ])

if __name__ == "__main__":
    # Run enterprise demonstration
    demonstrate_enterprise_practices()
    
    print("\n" + "="*50)
    print("RUNNING COMPREHENSIVE TEST SUITE")
    print("="*50)
    
    # Run test suite
    run_comprehensive_tests()
```

## 🎯 Key Takeaways & Next Steps (2 minutes)

### Enterprise Excellence Principles

- **Immutable Design**: Use frozen dataclasses for value objects and data transfer objects
- **Comprehensive Testing**: Unit tests, integration tests, and mocking strategies
- **Performance Monitoring**: Decorator patterns for monitoring and logging
- **Error Handling**: Custom exceptions with meaningful error codes and messages
- **Clean Architecture**: Repository pattern, service layer, and dependency injection

### Production Deployment Readiness

- **Logging Integration**: Structured logging for monitoring and debugging
- **Performance Tracking**: Method-level performance monitoring
- **Error Recovery**: Graceful error handling with appropriate user feedback
- **Testing Coverage**: Comprehensive test suites ensuring system reliability

### Complete OOP Foundation Achieved

You now have a complete understanding of:

1. **Four Pillars**: Encapsulation, Inheritance, Polymorphism, Abstraction
2. **Advanced Concepts**: Interfaces, Composition, Dependency Injection
3. **Design Patterns**: Factory, Observer, Strategy with error handling
4. **Enterprise Practices**: Testing, monitoring, and production-ready code

## 🔗 Related Topics

**Prerequisites**: OOP Fundamentals Parts 1-3  
**Completes**: Complete Object-Oriented Programming Foundation  
**Enables**: SOLID Principles Mastery, Design Patterns Implementation, Clean Architecture  
**Next Recommended**: Architectural Patterns, API Design Principles, Performance Optimization

**Next Module**: Advanced Principles - API Design and System Architecture
