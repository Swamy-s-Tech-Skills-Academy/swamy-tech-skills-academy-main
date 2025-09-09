# 06_Practitioner-to-Skilled-Coder - Design Patterns

**Learning Level**: Advanced  
**Prerequisites**: Completed 05_Beginner-to-Practitioner (Clean Code Principles)  
**Estimated Time**: 6-7 weeks

## 🎯 Learning Objectives

- **Master Gang of Four (GoF) design patterns** in Python
- **Implement creational, structural, and behavioral patterns**
- **Apply patterns to solve real-world problems**
- **Understand when to use each pattern**
- **Achieve the milestone**: "I design with patterns!"

## 📋 Core Concepts

### Creational Patterns

```python
# Singleton Pattern
class DatabaseConnection:
    _instance = None
    _connection = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def connect(self):
        if self._connection is None:
            self._connection = "Database connected"
            print("New database connection established")
        return self._connection

# Factory Pattern
from abc import ABC, abstractmethod

class Animal(ABC):
    @abstractmethod
    def make_sound(self):
        pass

class Dog(Animal):
    def make_sound(self):
        return "Woof!"

class Cat(Animal):
    def make_sound(self):
        return "Meow!"

class AnimalFactory:
    @staticmethod
    def create_animal(animal_type: str) -> Animal:
        animals = {
            'dog': Dog,
            'cat': Cat
        }
        animal_class = animals.get(animal_type.lower())
        if animal_class:
            return animal_class()
        raise ValueError(f"Unknown animal type: {animal_type}")

# Builder Pattern
class Computer:
    def __init__(self):
        self.cpu = None
        self.memory = None
        self.storage = None
        self.graphics = None
    
    def __str__(self):
        return f"Computer(CPU: {self.cpu}, Memory: {self.memory}, Storage: {self.storage}, Graphics: {self.graphics})"

class ComputerBuilder:
    def __init__(self):
        self.computer = Computer()
    
    def set_cpu(self, cpu):
        self.computer.cpu = cpu
        return self
    
    def set_memory(self, memory):
        self.computer.memory = memory
        return self
    
    def set_storage(self, storage):
        self.computer.storage = storage
        return self
    
    def set_graphics(self, graphics):
        self.computer.graphics = graphics
        return self
    
    def build(self):
        return self.computer
```

### Structural Patterns

```python
# Adapter Pattern
class LegacyPrinter:
    def old_print(self, text):
        return f"Legacy: {text}"

class ModernPrinter:
    def print(self, text):
        return f"Modern: {text}"

class PrinterAdapter:
    def __init__(self, legacy_printer):
        self.legacy_printer = legacy_printer
    
    def print(self, text):
        return self.legacy_printer.old_print(text)

# Decorator Pattern
from functools import wraps

def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        import time
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.4f} seconds")
        return result
    return wrapper

def logger(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__} with args: {args}, kwargs: {kwargs}")
        result = func(*args, **kwargs)
        print(f"{func.__name__} returned: {result}")
        return result
    return wrapper

@timer
@logger
def calculate_fibonacci(n):
    if n <= 1:
        return n
    return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)
```

### Behavioral Patterns

```python
# Observer Pattern
class EventManager:
    def __init__(self):
        self._observers = {}
    
    def subscribe(self, event_type, observer):
        if event_type not in self._observers:
            self._observers[event_type] = []
        self._observers[event_type].append(observer)
    
    def unsubscribe(self, event_type, observer):
        if event_type in self._observers:
            self._observers[event_type].remove(observer)
    
    def notify(self, event_type, data):
        if event_type in self._observers:
            for observer in self._observers[event_type]:
                observer.update(data)

class EmailNotifier:
    def update(self, data):
        print(f"Email notification: {data}")

class SMSNotifier:
    def update(self, data):
        print(f"SMS notification: {data}")

# Strategy Pattern
class PaymentStrategy(ABC):
    @abstractmethod
    def pay(self, amount):
        pass

class CreditCardPayment(PaymentStrategy):
    def __init__(self, card_number):
        self.card_number = card_number
    
    def pay(self, amount):
        return f"Paid ${amount} using Credit Card ending in {self.card_number[-4:]}"

class PayPalPayment(PaymentStrategy):
    def __init__(self, email):
        self.email = email
    
    def pay(self, amount):
        return f"Paid ${amount} using PayPal account {self.email}"

class PaymentProcessor:
    def __init__(self, strategy: PaymentStrategy):
        self.strategy = strategy
    
    def process_payment(self, amount):
        return self.strategy.pay(amount)
```

## 📝 Practice Projects

### Project 1: E-commerce System

Design an e-commerce system using multiple patterns (Factory for products, Observer for notifications, Strategy for payments).

### Project 2: Document Processing Pipeline

Build a document processing system using Chain of Responsibility and Command patterns.

### Project 3: Game Development Framework

Create a simple game framework implementing State, Observer, and Factory patterns.

## 🎯 Learning Milestones

### Week 1-2: Creational Patterns

- [ ] Implement Singleton pattern
- [ ] Master Factory and Abstract Factory
- [ ] Apply Builder pattern for complex objects

### Week 3-4: Structural Patterns

- [ ] Use Adapter for legacy integration
- [ ] Implement Decorator pattern
- [ ] Apply Facade for simplified interfaces

### Week 5-6: Behavioral Patterns

- [ ] Implement Observer pattern
- [ ] Use Strategy for algorithm selection
- [ ] Apply Command pattern for actions

### Week 7: Integration and Practice

- [ ] Combine multiple patterns in projects
- [ ] Understand pattern interactions
- [ ] Apply patterns to real-world scenarios

## 🔗 Related Topics

### Prerequisites

- [05_Beginner-to-Practitioner](../05_Beginner-to-Practitioner/) - Clean Code Principles

### Enables

- [07_Skilled-Coder-to-Specialist](../07_Skilled-Coder-to-Specialist/) - Standard Library

---

**Last Updated**: September 7, 2025  
**Maintained By**: STSA Learning System
