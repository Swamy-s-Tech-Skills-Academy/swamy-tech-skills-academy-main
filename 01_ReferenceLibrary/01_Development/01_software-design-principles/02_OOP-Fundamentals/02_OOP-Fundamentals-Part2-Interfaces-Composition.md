# OOP Fundamentals Part 2: Interfaces, Composition, and Dependency Injection

**Learning Level**: Beginner to Intermediate  
**Prerequisites**: OOP Fundamentals Part 1 (Four Pillars of OOP)  
**Estimated Time**: 30 minutes

## 🎯 Learning Objectives

By the end of this session, you will understand:

- Interface contracts and multiple inheritance simulation
- Composition over inheritance principle
- Dependency injection patterns
- Practical enterprise implementations

## 📋 Quick Overview (5 minutes)

### Beyond the Four Pillars

While encapsulation, inheritance, polymorphism, and abstraction form OOP's foundation, modern software development requires additional patterns:

**Interfaces**: Define contracts without implementation
**Composition**: Build complex objects from simpler parts
**Dependency Injection**: Manage object dependencies externally

These patterns enable flexible, testable, and maintainable enterprise systems.

## 🔧 Core Concepts (15 minutes)

### Interface Contracts

Interfaces define what an object can do without specifying how:

```python
from abc import ABC, abstractmethod
from typing import Protocol

class Flyable(Protocol):
    """Interface for objects that can fly"""
    def fly(self) -> str:
        pass
    
    def get_altitude(self) -> float:
        pass

class Drivable(Protocol):
    """Interface for objects that can be driven"""
    def start_engine(self) -> bool:
        pass
    
    def accelerate(self, speed: float) -> float:
        pass

# Multiple interface implementation
class FlyingCar:
    def __init__(self, model: str):
        self.model = model
        self.altitude = 0.0
        self.speed = 0.0
        self.engine_running = False
    
    # Flyable interface
    def fly(self) -> str:
        if not self.engine_running:
            return f"{self.model}: Cannot fly - engine not running"
        self.altitude = 1000.0
        return f"{self.model}: Flying at {self.altitude} feet"
    
    def get_altitude(self) -> float:
        return self.altitude
    
    # Drivable interface  
    def start_engine(self) -> bool:
        self.engine_running = True
        return True
    
    def accelerate(self, target_speed: float) -> float:
        if self.engine_running:
            self.speed = min(target_speed, 200.0)  # Max speed limit
        return self.speed
```

### Composition Over Inheritance

Build complex objects by combining simpler components:

```python
class Engine:
    def __init__(self, power: float, fuel_type: str):
        self.power = power
        self.fuel_type = fuel_type
        self.running = False
    
    def start(self) -> bool:
        self.running = True
        return True
    
    def stop(self) -> bool:
        self.running = False
        return True
    
    def get_power_output(self) -> float:
        return self.power if self.running else 0.0

class GPS:
    def __init__(self):
        self.current_location = (0.0, 0.0)
    
    def get_location(self) -> tuple[float, float]:
        return self.current_location
    
    def navigate_to(self, destination: tuple[float, float]) -> str:
        lat, lon = destination
        return f"Navigating to ({lat}, {lon})"

class SafetySystem:
    def __init__(self):
        self.airbags_deployed = False
        self.emergency_brake = False
    
    def deploy_airbags(self) -> str:
        self.airbags_deployed = True
        return "Airbags deployed for safety"
    
    def emergency_stop(self) -> str:
        self.emergency_brake = True
        return "Emergency brake activated"

# Composition-based vehicle
class ModernVehicle:
    def __init__(self, model: str, engine: Engine):
        self.model = model
        self.engine = engine  # Composed engine
        self.gps = GPS()      # Composed navigation
        self.safety = SafetySystem()  # Composed safety
        self.speed = 0.0
    
    def start_vehicle(self) -> str:
        if self.engine.start():
            return f"{self.model}: Vehicle started successfully"
        return f"{self.model}: Failed to start vehicle"
    
    def drive_to(self, destination: tuple[float, float]) -> str:
        if not self.engine.running:
            return f"{self.model}: Start engine first"
        
        navigation = self.gps.navigate_to(destination)
        power = self.engine.get_power_output()
        self.speed = min(power / 10, 120.0)  # Speed calculation
        
        return f"{self.model}: {navigation} at {self.speed} mph"
    
    def emergency_response(self) -> str:
        safety_msg = self.safety.emergency_stop()
        airbag_msg = self.safety.deploy_airbags()
        return f"{self.model}: {safety_msg} | {airbag_msg}"
```

### Dependency Injection Pattern

Manage dependencies externally for flexibility and testing:

```python
from typing import List, Optional

class Logger(ABC):
    @abstractmethod
    def log(self, message: str) -> None:
        pass

class FileLogger(Logger):
    def __init__(self, filename: str):
        self.filename = filename
    
    def log(self, message: str) -> None:
        print(f"[FILE LOG to {self.filename}]: {message}")

class DatabaseLogger(Logger):
    def __init__(self, connection_string: str):
        self.connection = connection_string
    
    def log(self, message: str) -> None:
        print(f"[DB LOG to {self.connection}]: {message}")

class NotificationService(ABC):
    @abstractmethod
    def send(self, message: str, recipient: str) -> bool:
        pass

class EmailService(NotificationService):
    def send(self, message: str, recipient: str) -> bool:
        print(f"EMAIL to {recipient}: {message}")
        return True

class SMSService(NotificationService):
    def send(self, message: str, recipient: str) -> bool:
        print(f"SMS to {recipient}: {message}")
        return True

# Service with injected dependencies
class OrderService:
    def __init__(self, logger: Logger, notification: NotificationService):
        self.logger = logger  # Injected dependency
        self.notification = notification  # Injected dependency
        self.orders = []
    
    def create_order(self, product: str, customer: str) -> str:
        order_id = f"ORD-{len(self.orders) + 1:04d}"
        
        # Business logic
        order = {
            'id': order_id,
            'product': product,
            'customer': customer,
            'status': 'created'
        }
        self.orders.append(order)
        
        # Use injected dependencies
        self.logger.log(f"Order created: {order_id} for {customer}")
        self.notification.send(
            f"Order {order_id} created for {product}",
            customer
        )
        
        return order_id
    
    def get_order_count(self) -> int:
        return len(self.orders)
```

## ⚡ Practical Implementation (8 minutes)

### Enterprise E-commerce System

```python
# Dependency injection container (simple implementation)
class ServiceContainer:
    def __init__(self):
        self.services = {}
    
    def register(self, service_type: type, implementation: object):
        self.services[service_type] = implementation
    
    def get(self, service_type: type):
        return self.services.get(service_type)

# Complete system demonstration
def demonstrate_advanced_oop():
    print("=== Interface Implementation Demo ===")
    flying_car = FlyingCar("Tesla Model F")
    
    # Test interfaces
    print(flying_car.start_engine())
    print(flying_car.fly())
    print(f"Current altitude: {flying_car.get_altitude()} feet")
    print(f"Accelerating to: {flying_car.accelerate(150.0)} mph")
    
    print("\n=== Composition Demo ===")
    # Create components
    electric_engine = Engine(300.0, "Electric")
    modern_car = ModernVehicle("Tesla Model S", electric_engine)
    
    # Test composition
    print(modern_car.start_vehicle())
    print(modern_car.drive_to((37.7749, -122.4194)))  # San Francisco
    print(modern_car.emergency_response())
    
    print("\n=== Dependency Injection Demo ===")
    # Setup dependency injection
    container = ServiceContainer()
    
    # Register services
    file_logger = FileLogger("orders.log")
    email_service = EmailService()
    
    container.register(Logger, file_logger)
    container.register(NotificationService, email_service)
    
    # Create service with injected dependencies
    order_service = OrderService(
        container.get(Logger),
        container.get(NotificationService)
    )
    
    # Test business operations
    order1 = order_service.create_order("Laptop", "john@example.com")
    order2 = order_service.create_order("Mouse", "jane@example.com")
    
    print(f"Total orders processed: {order_service.get_order_count()}")
    
    # Demonstrate flexibility - switch to different implementations
    print("\n=== Switching Dependencies ===")
    db_logger = DatabaseLogger("postgresql://localhost:5432/orders")
    sms_service = SMSService()
    
    # New service instance with different dependencies
    premium_service = OrderService(db_logger, sms_service)
    order3 = premium_service.create_order("Premium Support", "+1-555-0123")

if __name__ == "__main__":
    demonstrate_advanced_oop()
```

## 🎯 Key Takeaways & Next Steps (2 minutes)

### Critical Insights

- **Interfaces**: Enable multiple inheritance-like behavior and contract enforcement
- **Composition**: Provides flexibility over rigid inheritance hierarchies  
- **Dependency Injection**: Enables testing, configuration, and maintainable code

### Architecture Benefits

- **Testability**: Easy to mock dependencies
- **Flexibility**: Swap implementations without code changes
- **Separation**: Business logic separated from infrastructure concerns

## 🔗 Related Topics

**Prerequisites**: OOP Fundamentals Part 1 (Four Pillars)  
**Builds Upon**: Encapsulation, Abstraction, Polymorphism  
**Enables**: SOLID Principles, Design Patterns, Clean Architecture  
**Next Module**: OOP Fundamentals Part 3 (Advanced Patterns and Error Handling)

---

**Part of Software Design Principles Series - Advanced OOP Foundation**
