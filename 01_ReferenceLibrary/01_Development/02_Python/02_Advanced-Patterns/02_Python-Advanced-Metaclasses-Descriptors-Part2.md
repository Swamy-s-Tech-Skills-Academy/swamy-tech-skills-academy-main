# 02_Python-Advanced-Metaclasses-Descriptors-Part2

**Learning Level**: Advanced  
**Prerequisites**: Context managers & decorators (Part 1), OOP mastery, Python data model  
**Estimated Time**: Part 2 of 6 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master metaclasses for controlling class creation and behavior at runtime
- Implement descriptors for advanced attribute access control and validation
- Design property-based APIs with computed attributes and lazy loading
- Build framework-level abstractions using Python's advanced object model

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

**Metaclasses** are "classes that create classes" - they control how classes are constructed and behave. **Descriptors** are objects that define how attribute access is handled via `__get__`, `__set__`, and `__delete__` methods. Both enable **framework-level abstractions** and **advanced API design** patterns.

**Core Concepts**:

- **Metaclass Protocol**: `__new__`, `__init__`, `__call__` methods control class lifecycle
- **Descriptor Protocol**: `__get__`, `__set__`, `__delete__` methods control attribute access
- **Data vs Non-Data Descriptors**: Different precedence in attribute resolution
- **Property Factory Patterns**: Dynamic property creation for flexible APIs

### Core Implementation (6 minutes)

```python
# ✅ Advanced Metaclass Implementation
import functools
import inspect
import logging
import threading
import weakref
from abc import ABC, abstractmethod
from typing import Any, Callable, Dict, List, Optional, Type, Union

class SingletonMeta(type):
    """Thread-safe singleton metaclass with lazy initialization."""
    
    _instances: Dict[Type, Any] = {}
    _lock = threading.Lock()
    
    def __call__(cls, *args, **kwargs):
        """Create or return existing instance with thread safety."""
        if cls not in cls._instances:
            with cls._lock:
                # Double-check locking pattern
                if cls not in cls._instances:
                    instance = super().__call__(*args, **kwargs)
                    cls._instances[cls] = instance
        return cls._instances[cls]
    
    def clear_instances(cls):
        """Clear all singleton instances (useful for testing)."""
        with cls._lock:
            cls._instances.clear()

class ValidationMeta(type):
    """Metaclass that automatically adds validation to class methods."""
    
    def __new__(mcs, name: str, bases: tuple, namespace: dict, **kwargs):
        """Create class with automatic validation decoration."""
        
        # Find methods that need validation
        validation_rules = namespace.get('_validation_rules', {})
        
        for attr_name, attr_value in namespace.items():
            if (callable(attr_value) and 
                not attr_name.startswith('_') and 
                attr_name in validation_rules):
                
                # Wrap method with validation
                validation_rule = validation_rules[attr_name]
                namespace[attr_name] = mcs._add_validation(attr_value, validation_rule)
        
        return super().__new__(mcs, name, bases, namespace)
    
    @staticmethod
    def _add_validation(method: Callable, validation_rule: dict) -> Callable:
        """Add validation decorator to method."""
        
        @functools.wraps(method)
        def wrapper(self, *args, **kwargs):
            # Validate arguments
            sig = inspect.signature(method)
            bound_args = sig.bind(self, *args, **kwargs)
            bound_args.apply_defaults()
            
            for param_name, expected_type in validation_rule.items():
                if param_name in bound_args.arguments:
                    value = bound_args.arguments[param_name]
                    if not isinstance(value, expected_type):
                        raise TypeError(
                            f"Parameter '{param_name}' must be {expected_type.__name__}, "
                            f"got {type(value).__name__}: {value}"
                        )
            
            return method(self, *args, **kwargs)
        
        return wrapper

class ORM_Meta(type):
    """Metaclass for creating ORM-like classes with automatic field mapping."""
    
    def __new__(mcs, name: str, bases: tuple, namespace: dict, **kwargs):
        """Create ORM class with automatic field discovery."""
        
        # Extract table configuration
        table_name = namespace.get('_table_name', name.lower())
        
        # Find field descriptors
        fields = {}
        for attr_name, attr_value in list(namespace.items()):
            if isinstance(attr_value, Field):
                fields[attr_name] = attr_value
                attr_value.name = attr_name
                attr_value.table_name = table_name
        
        # Store field metadata
        namespace['_fields'] = fields
        namespace['_table_name'] = table_name
        
        # Add ORM methods
        namespace['save'] = mcs._create_save_method(fields, table_name)
        namespace['load'] = classmethod(mcs._create_load_method(fields, table_name))
        
        return super().__new__(mcs, name, bases, namespace)
    
    @staticmethod
    def _create_save_method(fields: dict, table_name: str) -> Callable:
        """Create save method for ORM instance."""
        
        def save(self) -> bool:
            """Save instance to database."""
            field_values = {}
            for field_name, field_obj in fields.items():
                if hasattr(self, f'_{field_name}'):
                    field_values[field_name] = getattr(self, f'_{field_name}')
            
            # Simulate database save
            logger = logging.getLogger(__name__)
            logger.info(f"Saving {table_name}: {field_values}")
            return True
        
        return save
    
    @staticmethod
    def _create_load_method(fields: dict, table_name: str) -> Callable:
        """Create class method for loading from database."""
        
        def load(cls, id_value: Any):
            """Load instance from database by ID."""
            # Simulate database load
            instance = cls()
            
            # Mock data loading
            for field_name in fields:
                setattr(instance, field_name, f"mock_{field_name}_value")
            
            logger = logging.getLogger(__name__)
            logger.info(f"Loaded {table_name} with id: {id_value}")
            return instance
        
        return load

# ✅ Advanced Descriptor Implementation
class Field:
    """Base descriptor class for ORM fields with validation and type conversion."""
    
    def __init__(self, field_type: Type, required: bool = True, default: Any = None):
        self.field_type = field_type
        self.required = required
        self.default = default
        self.name = None
        self.table_name = None
    
    def __set_name__(self, owner: Type, name: str):
        """Called when descriptor is assigned to class attribute."""
        self.name = name
        self.private_name = f'_{name}'
    
    def __get__(self, instance: Any, owner: Type) -> Any:
        """Get attribute value with default handling."""
        if instance is None:
            return self
        
        if hasattr(instance, self.private_name):
            return getattr(instance, self.private_name)
        
        if self.default is not None:
            return self.default() if callable(self.default) else self.default
        
        if self.required:
            raise AttributeError(f"Required field '{self.name}' not set")
        
        return None
    
    def __set__(self, instance: Any, value: Any):
        """Set attribute value with validation and type conversion."""
        if value is None and self.required:
            raise ValueError(f"Field '{self.name}' is required")
        
        if value is not None:
            # Type conversion
            try:
                converted_value = self.field_type(value)
            except (ValueError, TypeError) as e:
                raise TypeError(
                    f"Field '{self.name}' expects {self.field_type.__name__}, "
                    f"cannot convert {type(value).__name__}: {value}"
                ) from e
            
            # Additional validation
            self._validate_value(converted_value)
            setattr(instance, self.private_name, converted_value)
        else:
            setattr(instance, self.private_name, None)
    
    def __delete__(self, instance: Any):
        """Delete attribute with required field checking."""
        if self.required:
            raise AttributeError(f"Cannot delete required field '{self.name}'")
        
        if hasattr(instance, self.private_name):
            delattr(instance, self.private_name)
    
    def _validate_value(self, value: Any):
        """Override in subclasses for custom validation."""
        pass

class StringField(Field):
    """String field with length validation."""
    
    def __init__(self, max_length: Optional[int] = None, **kwargs):
        super().__init__(str, **kwargs)
        self.max_length = max_length
    
    def _validate_value(self, value: str):
        """Validate string length."""
        if self.max_length and len(value) > self.max_length:
            raise ValueError(
                f"Field '{self.name}' exceeds max length {self.max_length}: "
                f"got {len(value)} characters"
            )

class IntegerField(Field):
    """Integer field with range validation."""
    
    def __init__(self, min_value: Optional[int] = None, max_value: Optional[int] = None, **kwargs):
        super().__init__(int, **kwargs)
        self.min_value = min_value
        self.max_value = max_value
    
    def _validate_value(self, value: int):
        """Validate integer range."""
        if self.min_value is not None and value < self.min_value:
            raise ValueError(f"Field '{self.name}' below minimum {self.min_value}: {value}")
        
        if self.max_value is not None and value > self.max_value:
            raise ValueError(f"Field '{self.name}' exceeds maximum {self.max_value}: {value}")

class CachedProperty:
    """Descriptor for cached computed properties with thread safety."""
    
    def __init__(self, func: Callable):
        self.func = func
        self.attrname = None
        self.__doc__ = func.__doc__
        self._lock = threading.Lock()
    
    def __set_name__(self, owner: Type, name: str):
        """Set attribute name for cache storage."""
        if self.attrname is None:
            self.attrname = name
        elif name != self.attrname:
            raise RuntimeError(
                f"Cannot assign the same cached_property to two different names "
                f"({self.attrname!r} and {name!r})."
            )
    
    def __get__(self, instance: Any, owner: Type) -> Any:
        """Get cached value or compute and cache it."""
        if instance is None:
            return self
        
        cache_name = f'_cached_{self.attrname}'
        
        # Check if already cached
        if hasattr(instance, cache_name):
            return getattr(instance, cache_name)
        
        # Compute value with thread safety
        with self._lock:
            # Double-check pattern
            if hasattr(instance, cache_name):
                return getattr(instance, cache_name)
            
            value = self.func(instance)
            setattr(instance, cache_name, value)
            return value
    
    def __delete__(self, instance: Any):
        """Clear cached value."""
        cache_name = f'_cached_{self.attrname}'
        if hasattr(instance, cache_name):
            delattr(instance, cache_name)

# ✅ Production Usage Examples
class ConfigurationManager(metaclass=SingletonMeta):
    """Singleton configuration manager using metaclass."""
    
    def __init__(self):
        self._config = {}
        self._lock = threading.Lock()
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get configuration value thread-safely."""
        with self._lock:
            return self._config.get(key, default)
    
    def set(self, key: str, value: Any):
        """Set configuration value thread-safely."""
        with self._lock:
            self._config[key] = value

class User(metaclass=ORM_Meta):
    """Example ORM model using metaclass and descriptors."""
    
    _table_name = 'users'
    _validation_rules = {
        'set_email': {'email': str},
        'set_age': {'age': int}
    }
    
    # Field descriptors
    id = IntegerField(min_value=1)
    username = StringField(max_length=50)
    email = StringField(max_length=100)
    age = IntegerField(min_value=0, max_value=150, required=False)
    
    @CachedProperty
    def display_name(self) -> str:
        """Computed property that gets cached."""
        # Simulate expensive computation
        import time
        time.sleep(0.001)  # Simulate database lookup
        return f"{self.username} ({self.email})"
    
    def set_email(self, email: str):
        """Method with automatic validation via metaclass."""
        self.email = email
    
    def set_age(self, age: int):
        """Method with automatic validation via metaclass."""
        self.age = age

# ✅ Advanced Usage Demonstration
def demonstrate_metaclasses_descriptors():
    """Demonstrate metaclasses and descriptors in action."""
    
    # Setup logging
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
    
    # Test singleton metaclass
    config1 = ConfigurationManager()
    config2 = ConfigurationManager()
    
    print(f"Singleton test: {config1 is config2}")  # Should be True
    
    config1.set("api_key", "secret123")
    print(f"Config from instance 2: {config2.get('api_key')}")
    
    # Test ORM with descriptors
    user = User()
    
    try:
        # Set valid values
        user.id = 1
        user.username = "john_doe"
        user.set_email("john@example.com")  # Uses validation
        user.set_age(30)  # Uses validation
        
        # Test cached property
        print(f"Display name (first call): {user.display_name}")
        print(f"Display name (cached): {user.display_name}")
        
        # Test ORM methods
        user.save()
        loaded_user = User.load(1)
        
        print(f"Loaded user: {loaded_user.username}")
        
    except Exception as e:
        print(f"Error: {e}")
    
    # Test validation errors
    try:
        user.set_age("invalid")  # Should raise TypeError
    except TypeError as e:
        print(f"Validation error caught: {e}")

if __name__ == "__main__":
    demonstrate_metaclasses_descriptors()
```

### Key Takeaways (2 minutes)

#### **🎯 Metaclass Mastery**

**Class Creation Control**: Metaclasses intercept class creation to add behavior automatically

**Singleton Patterns**: Thread-safe singleton implementation with proper locking

**Framework Abstractions**: ORM-like behavior through automatic method generation

#### **⚡ Descriptor Power**

- **Attribute Control**: Complete control over getting, setting, and deleting attributes
- **Validation & Conversion**: Automatic type checking and data transformation
- **Computed Properties**: Cached properties with lazy evaluation and thread safety
- **Framework Building**: Foundation for ORM, validation frameworks, and APIs

**🎉 Next**: Part 3 covers Async Patterns & Concurrency for modern Python applications! 🚀
