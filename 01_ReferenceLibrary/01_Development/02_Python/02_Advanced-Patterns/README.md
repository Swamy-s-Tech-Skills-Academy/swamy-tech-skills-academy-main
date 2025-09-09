# 02_Advanced-Python-Patterns ⚡

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Solid Python fundamentals, understanding of OOP, basic design patterns  
**Estimated Time**: 50 minutes (5 focused 10-minute modules)

## 📚 Learning Modules

### Advanced Pattern Mastery (100% Complete)

1. **[01_Python-Advanced-Context-Decorators-Part1](./01_Python-Advanced-Context-Decorators-Part1.md)** - Context managers & advanced decorators ✅
2. **[02_Python-Advanced-Metaclasses-Descriptors-Part2](./02_Python-Advanced-Metaclasses-Descriptors-Part2.md)** - Metaclasses & descriptors for framework building ✅
3. **[03_Python-Advanced-Async-Concurrency-Part3](./03_Python-Advanced-Async-Concurrency-Part3.md)** - Async patterns & production concurrency ✅
4. **[04_Python-Performance-Memory-Management-Part4](./04_Python-Performance-Memory-Management-Part4.md)** - Performance optimization & memory management ✅
5. **[05_Python-Advanced-Design-Architecture-Part5](./05_Python-Advanced-Design-Architecture-Part5.md)** - Enterprise architecture & design patterns ✅

**🎉 Advanced Patterns Status: 100% Complete** _(5/5 modules, 25,000+ lines of production-ready code)_

## 🎯 Learning Objectives

By the end of this content, you will:

- Master advanced Python design patterns for robust software architecture
- Understand when and how to apply complex Python language features effectively
- Learn performance optimization techniques for Python applications
- Implement scalable and maintainable Python codebases using advanced patterns
- Apply modern Python features for clean, efficient, and professional code

## 📋 Advanced Design Patterns in Python

### 🏗️ Creational Patterns

#### **The Builder Pattern with Method Chaining**

**Use Case**: Creating complex objects with many optional parameters

```python
class QueryBuilder:
    def __init__(self):
        self._select_fields = []
        self._where_conditions = []
        self._joins = []
        self._order_by = []
        self._limit_value = None

    def select(self, *fields):
        self._select_fields.extend(fields)
        return self

    def where(self, condition):
        self._where_conditions.append(condition)
        return self

    def join(self, table, on_condition):
        self._joins.append(f"JOIN {table} ON {on_condition}")
        return self

    def order_by(self, field, direction="ASC"):
        self._order_by.append(f"{field} {direction}")
        return self

    def limit(self, count):
        self._limit_value = count
        return self

    def build(self):
        query_parts = []
        query_parts.append(f"SELECT {', '.join(self._select_fields)}")

        if self._joins:
            query_parts.extend(self._joins)

        if self._where_conditions:
            query_parts.append(f"WHERE {' AND '.join(self._where_conditions)}")

        if self._order_by:
            query_parts.append(f"ORDER BY {', '.join(self._order_by)}")

        if self._limit_value:
            query_parts.append(f"LIMIT {self._limit_value}")

        return ' '.join(query_parts)

# Usage
query = (QueryBuilder()
         .select("name", "email", "age")
         .where("age > 18")
         .where("status = 'active'")
         .order_by("name")
         .limit(100)
         .build())
```

#### **Factory Pattern with Registration**

**Use Case**: Dynamic object creation based on runtime parameters

```python
from typing import Dict, Type, Any
from abc import ABC, abstractmethod

class DataProcessor(ABC):
    @abstractmethod
    def process(self, data: Any) -> Any:
        pass

class JSONProcessor(DataProcessor):
    def process(self, data: dict) -> str:
        import json
        return json.dumps(data, indent=2)

class XMLProcessor(DataProcessor):
    def process(self, data: dict) -> str:
        # Simplified XML conversion
        def dict_to_xml(d, root_name="data"):
            xml_str = f"<{root_name}>"
            for key, value in d.items():
                xml_str += f"<{key}>{value}</{key}>"
            xml_str += f"</{root_name}>"
            return xml_str
        return dict_to_xml(data)

class ProcessorFactory:
    _processors: Dict[str, Type[DataProcessor]] = {}

    @classmethod
    def register(cls, name: str, processor_class: Type[DataProcessor]):
        cls._processors[name] = processor_class

    @classmethod
    def create(cls, name: str) -> DataProcessor:
        processor_class = cls._processors.get(name)
        if not processor_class:
            raise ValueError(f"Unknown processor: {name}")
        return processor_class()

    @classmethod
    def available_processors(cls) -> list:
        return list(cls._processors.keys())

# Registration
ProcessorFactory.register("json", JSONProcessor)
ProcessorFactory.register("xml", XMLProcessor)

# Usage
processor = ProcessorFactory.create("json")
result = processor.process({"name": "John", "age": 30})
```

### 🔄 Behavioral Patterns

#### **Observer Pattern with Weak References**

**Use Case**: Event-driven programming with automatic cleanup

```python
import weakref
from typing import List, Callable, Any
from abc import ABC, abstractmethod

class Subject:
    def __init__(self):
        self._observers: List[weakref.ReferenceType] = []

    def attach(self, observer):
        """Attach an observer using weak reference to prevent memory leaks"""
        weak_observer = weakref.ref(observer, self._cleanup_observer)
        self._observers.append(weak_observer)

    def detach(self, observer):
        """Detach an observer"""
        self._observers = [obs for obs in self._observers
                          if obs() is not None and obs() is not observer]

    def _cleanup_observer(self, weak_observer):
        """Automatically clean up dead weak references"""
        self._observers.remove(weak_observer)

    def notify(self, event_type: str, data: Any = None):
        """Notify all active observers"""
        for observer_ref in self._observers[:]:  # Copy to avoid modification during iteration
            observer = observer_ref()
            if observer is not None:
                observer.update(event_type, data)
            else:
                self._observers.remove(observer_ref)

class EventObserver(ABC):
    @abstractmethod
    def update(self, event_type: str, data: Any = None):
        pass

class LoggingObserver(EventObserver):
    def __init__(self, name: str):
        self.name = name

    def update(self, event_type: str, data: Any = None):
        print(f"[{self.name}] Event: {event_type}, Data: {data}")

class MetricsObserver(EventObserver):
    def __init__(self):
        self.event_counts = {}

    def update(self, event_type: str, data: Any = None):
        self.event_counts[event_type] = self.event_counts.get(event_type, 0) + 1

    def get_metrics(self):
        return self.event_counts.copy()

# Usage
subject = Subject()
logger = LoggingObserver("SystemLogger")
metrics = MetricsObserver()

subject.attach(logger)
subject.attach(metrics)

subject.notify("user_login", {"user_id": 123})
subject.notify("data_processed", {"records": 500})
```

#### **Strategy Pattern with Decorators**

**Use Case**: Pluggable algorithms with decorator-based registration

```python
from typing import Dict, Callable, Any
from functools import wraps

class ValidationStrategy:
    """Registry for validation strategies"""
    _strategies: Dict[str, Callable] = {}

    @classmethod
    def register(cls, name: str):
        """Decorator to register validation strategies"""
        def decorator(func: Callable):
            cls._strategies[name] = func
            return func
        return decorator

    @classmethod
    def validate(cls, strategy_name: str, data: Any) -> tuple[bool, str]:
        """Execute a validation strategy"""
        if strategy_name not in cls._strategies:
            raise ValueError(f"Unknown validation strategy: {strategy_name}")

        return cls._strategies[strategy_name](data)

    @classmethod
    def available_strategies(cls) -> list:
        return list(cls._strategies.keys())

# Register validation strategies using decorators
@ValidationStrategy.register("email")
def validate_email(email: str) -> tuple[bool, str]:
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if re.match(pattern, email):
        return True, "Valid email"
    return False, "Invalid email format"

@ValidationStrategy.register("strong_password")
def validate_strong_password(password: str) -> tuple[bool, str]:
    if len(password) < 8:
        return False, "Password must be at least 8 characters"
    if not any(c.isupper() for c in password):
        return False, "Password must contain uppercase letter"
    if not any(c.islower() for c in password):
        return False, "Password must contain lowercase letter"
    if not any(c.isdigit() for c in password):
        return False, "Password must contain digit"
    return True, "Strong password"

@ValidationStrategy.register("phone")
def validate_phone(phone: str) -> tuple[bool, str]:
    import re
    # Simple US phone validation
    pattern = r'^\+?1?[-.\s]?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})$'
    if re.match(pattern, phone):
        return True, "Valid phone number"
    return False, "Invalid phone number format"

# Usage
class UserValidator:
    def __init__(self):
        self.validation_rules = []

    def add_rule(self, field: str, strategy: str):
        self.validation_rules.append((field, strategy))
        return self

    def validate(self, user_data: dict) -> dict:
        results = {}
        for field, strategy in self.validation_rules:
            if field in user_data:
                is_valid, message = ValidationStrategy.validate(strategy, user_data[field])
                results[field] = {"valid": is_valid, "message": message}
            else:
                results[field] = {"valid": False, "message": f"Field {field} is required"}
        return results

# Usage
validator = (UserValidator()
            .add_rule("email", "email")
            .add_rule("password", "strong_password")
            .add_rule("phone", "phone"))

user_data = {
    "email": "user@example.com",
    "password": "StrongPass123",
    "phone": "(555) 123-4567"
}

validation_results = validator.validate(user_data)
```

## ⚡ Performance Optimization Patterns

### **Lazy Loading and Caching**

```python
from functools import lru_cache, cached_property
from typing import Any, Optional
import time

class LazyDataLoader:
    """Demonstrates lazy loading with caching for expensive operations"""

    def __init__(self):
        self._data_cache = {}
        self._metadata_cache = {}

    @cached_property
    def expensive_computation(self) -> dict:
        """Cached property - computed only once"""
        print("Performing expensive computation...")
        time.sleep(2)  # Simulate expensive operation
        return {"result": "computed_value", "timestamp": time.time()}

    @lru_cache(maxsize=128)
    def get_processed_data(self, data_id: str, processing_type: str) -> dict:
        """LRU cached method with multiple parameters"""
        print(f"Processing data {data_id} with {processing_type}")
        # Simulate data processing
        time.sleep(1)
        return {
            "data_id": data_id,
            "type": processing_type,
            "processed_at": time.time()
        }

    def get_data_with_fallback(self, data_id: str) -> Optional[dict]:
        """Lazy loading with fallback mechanism"""
        # Try cache first
        if data_id in self._data_cache:
            return self._data_cache[data_id]

        # Try primary data source
        data = self._fetch_from_primary(data_id)
        if data:
            self._data_cache[data_id] = data
            return data

        # Fallback to secondary source
        data = self._fetch_from_secondary(data_id)
        if data:
            self._data_cache[data_id] = data
            return data

        return None

    def _fetch_from_primary(self, data_id: str) -> Optional[dict]:
        # Simulate primary data source (might fail)
        if data_id.startswith("fail"):
            return None
        return {"source": "primary", "data_id": data_id, "value": f"primary_{data_id}"}

    def _fetch_from_secondary(self, data_id: str) -> Optional[dict]:
        # Simulate secondary data source
        return {"source": "secondary", "data_id": data_id, "value": f"secondary_{data_id}"}
```

### **Memory-Efficient Generators and Iterators**

```python
from typing import Iterator, Generator, Any
import csv
from pathlib import Path

class DataStreamProcessor:
    """Demonstrates memory-efficient data processing using generators"""

    @staticmethod
    def read_large_file(file_path: Path) -> Generator[str, None, None]:
        """Generator for reading large files line by line"""
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                yield line.strip()

    @staticmethod
    def process_csv_stream(file_path: Path) -> Generator[dict, None, None]:
        """Stream CSV processing without loading entire file into memory"""
        with open(file_path, 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                # Process each row
                processed_row = {k: v.strip() for k, v in row.items()}
                yield processed_row

    @staticmethod
    def batch_processor(items: Iterator[Any], batch_size: int = 100) -> Generator[list, None, None]:
        """Process items in batches to optimize memory usage"""
        batch = []
        for item in items:
            batch.append(item)
            if len(batch) >= batch_size:
                yield batch
                batch = []

        # Yield remaining items
        if batch:
            yield batch

    @staticmethod
    def filtered_transform(items: Iterator[dict],
                          filter_func: Callable[[dict], bool],
                          transform_func: Callable[[dict], dict]) -> Generator[dict, None, None]:
        """Efficient filtering and transformation pipeline"""
        for item in items:
            if filter_func(item):
                yield transform_func(item)

# Usage example
def example_stream_processing():
    processor = DataStreamProcessor()

    # Simulate large data processing
    def is_valid_record(record: dict) -> bool:
        return record.get('status') == 'active'

    def transform_record(record: dict) -> dict:
        return {
            'id': record['id'],
            'name': record['name'].upper(),
            'processed_at': time.time()
        }

    # Process large CSV file in memory-efficient way
    csv_path = Path("large_data.csv")  # Hypothetical large file

    # Create processing pipeline
    raw_data = processor.process_csv_stream(csv_path)
    filtered_data = processor.filtered_transform(raw_data, is_valid_record, transform_record)
    batched_data = processor.batch_processor(filtered_data, batch_size=1000)

    # Process each batch
    for batch_num, batch in enumerate(batched_data):
        print(f"Processing batch {batch_num} with {len(batch)} records")
        # Process batch (e.g., save to database, send to API, etc.)
```

## 🏛️ Advanced Architectural Patterns

### **Dependency Injection Container**

```python
from typing import Dict, Type, Any, Optional, Callable
from abc import ABC, abstractmethod
import inspect

class DIContainer:
    """Dependency Injection Container for loose coupling"""

    def __init__(self):
        self._services: Dict[str, Any] = {}
        self._singletons: Dict[str, Any] = {}
        self._factories: Dict[str, Callable] = {}

    def register_singleton(self, interface: Type, implementation: Type):
        """Register a singleton service"""
        self._services[interface.__name__] = ('singleton', implementation)
        return self

    def register_transient(self, interface: Type, implementation: Type):
        """Register a transient service (new instance each time)"""
        self._services[interface.__name__] = ('transient', implementation)
        return self

    def register_factory(self, interface: Type, factory: Callable):
        """Register a factory function"""
        self._factories[interface.__name__] = factory
        return self

    def resolve(self, interface: Type) -> Any:
        """Resolve a service instance"""
        service_name = interface.__name__

        # Check for factory first
        if service_name in self._factories:
            return self._factories[service_name]()

        # Check for registered service
        if service_name not in self._services:
            raise ValueError(f"Service {service_name} not registered")

        service_type, implementation = self._services[service_name]

        if service_type == 'singleton':
            if service_name not in self._singletons:
                self._singletons[service_name] = self._create_instance(implementation)
            return self._singletons[service_name]

        elif service_type == 'transient':
            return self._create_instance(implementation)

    def _create_instance(self, implementation_class: Type) -> Any:
        """Create instance with dependency injection"""
        # Get constructor signature
        sig = inspect.signature(implementation_class.__init__)
        kwargs = {}

        for param_name, param in sig.parameters.items():
            if param_name == 'self':
                continue

            # Try to resolve parameter type
            if param.annotation != inspect.Parameter.empty:
                try:
                    kwargs[param_name] = self.resolve(param.annotation)
                except ValueError:
                    if param.default == inspect.Parameter.empty:
                        raise ValueError(f"Cannot resolve dependency {param.annotation} for {implementation_class}")

        return implementation_class(**kwargs)

# Example usage
class ILogger(ABC):
    @abstractmethod
    def log(self, message: str):
        pass

class IDatabase(ABC):
    @abstractmethod
    def save(self, data: dict):
        pass

class ConsoleLogger(ILogger):
    def log(self, message: str):
        print(f"[LOG] {message}")

class MockDatabase(IDatabase):
    def __init__(self):
        self.data = []

    def save(self, data: dict):
        self.data.append(data)
        print(f"Saved to database: {data}")

class UserService:
    def __init__(self, logger: ILogger, database: IDatabase):
        self.logger = logger
        self.database = database

    def create_user(self, user_data: dict):
        self.logger.log(f"Creating user: {user_data['name']}")
        self.database.save(user_data)
        self.logger.log("User created successfully")

# Setup DI container
container = DIContainer()
container.register_singleton(ILogger, ConsoleLogger)
container.register_singleton(IDatabase, MockDatabase)
container.register_transient(UserService, UserService)

# Usage
user_service = container.resolve(UserService)
user_service.create_user({"name": "John Doe", "email": "john@example.com"})
```

## 🔗 Related Topics

### **Prerequisites**

- **01_Python-Fundamentals.md**: Core Python language features
- **Basic Design Patterns**: Understanding of common design patterns
- **Object-Oriented Programming**: Solid OOP concepts

### **Related**

- **02_software-design-principles/**: SOLID principles and clean architecture
- **Performance Optimization**: Memory management and profiling
- **Testing Patterns**: Advanced testing strategies for complex code

### **Advanced**

- **Metaprogramming**: Dynamic code generation and reflection
- **Async Patterns**: Asynchronous programming patterns
- **Microservices Patterns**: Distributed system design patterns

## 💡 Practical Applications

### **For Senior Developers**

- **Code Architecture**: Design scalable and maintainable Python applications
- **Performance Optimization**: Implement efficient algorithms and data structures
- **Team Leadership**: Establish coding standards and architectural guidelines
- **Code Review**: Identify and suggest improvements using advanced patterns

### **For Technical Architects**

- **System Design**: Apply patterns at system and service level
- **Technology Selection**: Choose appropriate patterns for specific use cases
- **Team Training**: Educate teams on advanced Python techniques
- **Legacy Modernization**: Refactor existing codebases using modern patterns

## 🎯 Next Steps

1. **Practice Implementation**: Apply these patterns in real projects
2. **Performance Analysis**: Profile and benchmark pattern implementations
3. **Custom Patterns**: Develop domain-specific patterns for your use cases
4. **Team Adoption**: Introduce patterns gradually to development teams
5. **Continuous Learning**: Stay updated with Python language evolution and new patterns

---

**📅 Last Updated**: July 30, 2025  
**🔗 Standards**: Based on Python 3.11+ features and modern best practices  
**📍 Domain**: Development → Python Programming  
**🎯 Impact**: Essential patterns for building professional, scalable Python applications
