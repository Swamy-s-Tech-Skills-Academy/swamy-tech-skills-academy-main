# OOP Fundamentals Part 3: Advanced Patterns and Error Handling

**Learning Level**: Intermediate  
**Prerequisites**: OOP Fundamentals Parts 1-2 (Four Pillars, Interfaces, Composition)  
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this session, you will understand:

- Advanced OOP patterns (Factory, Observer, Strategy)
- Comprehensive error handling in OOP systems
- Method chaining and fluent interfaces
- Enterprise-grade exception management

## 📋 Quick Overview (5 minutes)

### Beyond Basic OOP

Building on our foundation of four pillars, interfaces, and composition, we now explore:

**Factory Patterns**: Create objects without exposing instantiation logic
**Observer Pattern**: Implement publish-subscribe communication
**Strategy Pattern**: Encapsulate algorithms and make them interchangeable
**Error Handling**: Robust exception management with custom exceptions

These patterns enable scalable, maintainable enterprise applications.

## 🔧 Core Concepts (15 minutes)

### Factory Pattern Implementation

Create objects based on conditions without exposing creation logic:

```python
from abc import ABC, abstractmethod
from enum import Enum
from typing import Dict, List, Optional
import logging

class VehicleType(Enum):
    CAR = "car"
    TRUCK = "truck"
    MOTORCYCLE = "motorcycle"

class Vehicle(ABC):
    def __init__(self, model: str, year: int):
        self.model = model
        self.year = year
        self.mileage = 0.0
    
    @abstractmethod
    def get_max_speed(self) -> float:
        pass
    
    @abstractmethod
    def get_fuel_efficiency(self) -> float:
        pass
    
    def drive(self, distance: float) -> str:
        self.mileage += distance
        return f"{self.model}: Drove {distance} miles, total: {self.mileage}"

class Car(Vehicle):
    def __init__(self, model: str, year: int, doors: int = 4):
        super().__init__(model, year)
        self.doors = doors
    
    def get_max_speed(self) -> float:
        return 120.0
    
    def get_fuel_efficiency(self) -> float:
        return 30.0  # MPG

class Truck(Vehicle):
    def __init__(self, model: str, year: int, cargo_capacity: float):
        super().__init__(model, year)
        self.cargo_capacity = cargo_capacity
    
    def get_max_speed(self) -> float:
        return 80.0
    
    def get_fuel_efficiency(self) -> float:
        return 15.0  # MPG

class Motorcycle(Vehicle):
    def __init__(self, model: str, year: int, engine_cc: int):
        super().__init__(model, year)
        self.engine_cc = engine_cc
    
    def get_max_speed(self) -> float:
        return 150.0
    
    def get_fuel_efficiency(self) -> float:
        return 50.0  # MPG

# Factory implementation
class VehicleFactory:
    @staticmethod
    def create_vehicle(vehicle_type: VehicleType, model: str, year: int, **kwargs) -> Vehicle:
        if vehicle_type == VehicleType.CAR:
            return Car(model, year, kwargs.get('doors', 4))
        elif vehicle_type == VehicleType.TRUCK:
            cargo_capacity = kwargs.get('cargo_capacity', 1000.0)
            return Truck(model, year, cargo_capacity)
        elif vehicle_type == VehicleType.MOTORCYCLE:
            engine_cc = kwargs.get('engine_cc', 600)
            return Motorcycle(model, year, engine_cc)
        else:
            raise ValueError(f"Unknown vehicle type: {vehicle_type}")
```

### Observer Pattern Implementation

Enable objects to notify multiple observers about state changes:

```python
class Observer(ABC):
    @abstractmethod
    def update(self, subject: 'Subject', event_data: dict) -> None:
        pass

class Subject:
    def __init__(self):
        self._observers: List[Observer] = []
    
    def attach(self, observer: Observer) -> None:
        if observer not in self._observers:
            self._observers.append(observer)
    
    def detach(self, observer: Observer) -> None:
        self._observers.remove(observer)
    
    def notify(self, event_data: dict) -> None:
        for observer in self._observers:
            observer.update(self, event_data)

class InventorySystem(Subject):
    def __init__(self):
        super().__init__()
        self.products: Dict[str, int] = {}
    
    def add_stock(self, product: str, quantity: int) -> None:
        current = self.products.get(product, 0)
        self.products[product] = current + quantity
        
        self.notify({
            'event': 'stock_added',
            'product': product,
            'quantity': quantity,
            'total_stock': self.products[product]
        })
    
    def sell_product(self, product: str, quantity: int) -> bool:
        current = self.products.get(product, 0)
        if current >= quantity:
            self.products[product] = current - quantity
            
            self.notify({
                'event': 'product_sold',
                'product': product,
                'quantity': quantity,
                'remaining_stock': self.products[product]
            })
            return True
        return False

# Observer implementations
class EmailNotifier(Observer):
    def __init__(self, email: str):
        self.email = email
    
    def update(self, subject: Subject, event_data: dict) -> None:
        event = event_data['event']
        product = event_data['product']
        
        if event == 'product_sold' and event_data['remaining_stock'] < 5:
            print(f"EMAIL to {self.email}: Low stock alert for {product}")
        elif event == 'stock_added':
            print(f"EMAIL to {self.email}: Stock replenished for {product}")

class AnalyticsTracker(Observer):
    def __init__(self):
        self.sales_data = []
    
    def update(self, subject: Subject, event_data: dict) -> None:
        if event_data['event'] == 'product_sold':
            self.sales_data.append({
                'product': event_data['product'],
                'quantity': event_data['quantity'],
                'timestamp': 'now'  # In real system, use datetime
            })
            print(f"ANALYTICS: Recorded sale of {event_data['quantity']} {event_data['product']}")
```

### Strategy Pattern with Error Handling

Encapsulate algorithms and provide robust error management:

```python
class PaymentException(Exception):
    """Base exception for payment processing errors"""
    def __init__(self, message: str, error_code: str = None):
        super().__init__(message)
        self.error_code = error_code

class InsufficientFundsException(PaymentException):
    """Raised when account has insufficient funds"""
    def __init__(self, required: float, available: float):
        message = f"Insufficient funds: Required ${required:.2f}, Available ${available:.2f}"
        super().__init__(message, "INSUFFICIENT_FUNDS")
        self.required = required
        self.available = available

class PaymentMethodException(PaymentException):
    """Raised when payment method is invalid or unavailable"""
    def __init__(self, method: str, reason: str):
        message = f"Payment method '{method}' failed: {reason}"
        super().__init__(message, "PAYMENT_METHOD_ERROR")
        self.method = method
        self.reason = reason

# Strategy interface
class PaymentStrategy(ABC):
    @abstractmethod
    def process_payment(self, amount: float, account_info: dict) -> dict:
        pass
    
    @abstractmethod
    def validate_account(self, account_info: dict) -> bool:
        pass

class CreditCardStrategy(PaymentStrategy):
    def validate_account(self, account_info: dict) -> bool:
        required_fields = ['card_number', 'cvv', 'expiry_date']
        return all(field in account_info for field in required_fields)
    
    def process_payment(self, amount: float, account_info: dict) -> dict:
        try:
            if not self.validate_account(account_info):
                raise PaymentMethodException("credit_card", "Missing required fields")
            
            # Simulate payment processing
            card_number = account_info['card_number']
            if len(card_number) < 16:
                raise PaymentMethodException("credit_card", "Invalid card number format")
            
            # Simulate insufficient funds check
            credit_limit = account_info.get('credit_limit', 1000.0)
            if amount > credit_limit:
                raise InsufficientFundsException(amount, credit_limit)
            
            return {
                'success': True,
                'transaction_id': f"CC_{card_number[-4:]}_{int(amount*100)}",
                'amount': amount,
                'method': 'credit_card'
            }
        
        except PaymentException:
            raise  # Re-raise payment exceptions
        except Exception as e:
            raise PaymentException(f"Unexpected error in credit card processing: {str(e)}")

class BankTransferStrategy(PaymentStrategy):
    def validate_account(self, account_info: dict) -> bool:
        required_fields = ['account_number', 'routing_number']
        return all(field in account_info for field in required_fields)
    
    def process_payment(self, amount: float, account_info: dict) -> dict:
        try:
            if not self.validate_account(account_info):
                raise PaymentMethodException("bank_transfer", "Missing account details")
            
            # Simulate bank balance check
            balance = account_info.get('balance', 500.0)
            if amount > balance:
                raise InsufficientFundsException(amount, balance)
            
            return {
                'success': True,
                'transaction_id': f"BT_{account_info['account_number'][-4:]}_{int(amount*100)}",
                'amount': amount,
                'method': 'bank_transfer'
            }
        
        except PaymentException:
            raise
        except Exception as e:
            raise PaymentException(f"Bank transfer system error: {str(e)}")

# Payment processor with method chaining
class PaymentProcessor:
    def __init__(self):
        self.strategy: Optional[PaymentStrategy] = None
        self.transaction_log: List[dict] = []
    
    def set_strategy(self, strategy: PaymentStrategy) -> 'PaymentProcessor':
        """Fluent interface for method chaining"""
        self.strategy = strategy
        return self
    
    def process(self, amount: float, account_info: dict) -> 'PaymentProcessor':
        """Process payment and return self for chaining"""
        if not self.strategy:
            raise PaymentException("No payment strategy set", "NO_STRATEGY")
        
        try:
            result = self.strategy.process_payment(amount, account_info)
            self.transaction_log.append(result)
            print(f"Payment processed: {result['transaction_id']} for ${amount:.2f}")
            
        except PaymentException as e:
            error_entry = {
                'success': False,
                'error': str(e),
                'error_code': e.error_code,
                'amount': amount
            }
            self.transaction_log.append(error_entry)
            print(f"Payment failed: {e}")
            raise
        
        return self
    
    def get_transaction_count(self) -> int:
        return len(self.transaction_log)
```

## ⚡ Practical Implementation (8 minutes)

### Enterprise System Integration

```python
def demonstrate_advanced_patterns():
    print("=== Factory Pattern Demo ===")
    factory = VehicleFactory()
    
    # Create different vehicles
    car = factory.create_vehicle(VehicleType.CAR, "Honda Civic", 2023, doors=4)
    truck = factory.create_vehicle(VehicleType.TRUCK, "Ford F-150", 2023, cargo_capacity=1500.0)
    bike = factory.create_vehicle(VehicleType.MOTORCYCLE, "Yamaha R6", 2023, engine_cc=600)
    
    vehicles = [car, truck, bike]
    for vehicle in vehicles:
        print(f"{vehicle.model}: Max Speed {vehicle.get_max_speed()} mph, "
              f"Efficiency {vehicle.get_fuel_efficiency()} MPG")
    
    print("\n=== Observer Pattern Demo ===")
    # Setup inventory system with observers
    inventory = InventorySystem()
    
    email_notifier = EmailNotifier("manager@company.com")
    analytics = AnalyticsTracker()
    
    inventory.attach(email_notifier)
    inventory.attach(analytics)
    
    # Simulate inventory operations
    inventory.add_stock("Laptop", 10)
    inventory.sell_product("Laptop", 7)  # Triggers low stock alert
    inventory.sell_product("Laptop", 2)
    
    print(f"Analytics tracked {len(analytics.sales_data)} sales")
    
    print("\n=== Strategy Pattern with Error Handling Demo ===")
    processor = PaymentProcessor()
    
    # Test successful payments with method chaining
    try:
        credit_card_info = {
            'card_number': '1234567890123456',
            'cvv': '123',
            'expiry_date': '12/25',
            'credit_limit': 2000.0
        }
        
        processor.set_strategy(CreditCardStrategy()).process(150.0, credit_card_info)
        
        # Test bank transfer
        bank_info = {
            'account_number': '9876543210',
            'routing_number': '123456789',
            'balance': 1000.0
        }
        
        processor.set_strategy(BankTransferStrategy()).process(75.0, bank_info)
        
        print(f"Successfully processed {processor.get_transaction_count()} transactions")
    
    except PaymentException as e:
        print(f"Payment processing error: {e}")
    
    # Test error scenarios
    print("\n=== Error Handling Demo ===")
    try:
        # Test insufficient funds
        low_balance_info = {
            'account_number': '1111111111',
            'routing_number': '123456789',
            'balance': 50.0
        }
        
        processor.set_strategy(BankTransferStrategy()).process(100.0, low_balance_info)
    
    except InsufficientFundsException as e:
        print(f"Insufficient funds: Required ${e.required:.2f}, Available ${e.available:.2f}")
    except PaymentException as e:
        print(f"Payment error: {e} (Code: {e.error_code})")

if __name__ == "__main__":
    demonstrate_advanced_patterns()
```

## 🎯 Key Takeaways & Next Steps (2 minutes)

### Advanced Pattern Benefits

- **Factory Pattern**: Centralized object creation with flexible configuration
- **Observer Pattern**: Loose coupling between objects with event-driven communication
- **Strategy Pattern**: Interchangeable algorithms with clean separation of concerns
- **Error Handling**: Robust exception management with meaningful error information

### Enterprise Architecture Impact

- **Scalability**: Patterns support growing system complexity
- **Maintainability**: Clear separation enables easier updates
- **Testability**: Each component can be tested independently
- **Reliability**: Comprehensive error handling prevents system failures

## 🔗 Related Topics

**Prerequisites**: OOP Fundamentals Parts 1-2  
**Builds Upon**: Four Pillars, Interfaces, Composition, Dependency Injection  
**Enables**: Design Patterns, Clean Architecture, Enterprise Applications  
**Next Module**: OOP Fundamentals Part 4 (Enterprise Best Practices and Testing)
