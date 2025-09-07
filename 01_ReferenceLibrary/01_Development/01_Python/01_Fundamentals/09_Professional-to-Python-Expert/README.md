# 09_Professional-to-Python-Expert - Advanced Features

**Learning Level**: Expert  
**Prerequisites**: Completed 08_Specialist-to-Professional (Third-party Ecosystem)  
**Estimated Time**: 12-15 weeks

## 🎯 Learning Objectives

- **Master advanced Python features and internals**
- **Implement metaclasses and descriptors**
- **Optimize performance and memory usage**
- **Understand Python's execution model**
- **Achieve the milestone**: "I am a Python Expert!"

## 📋 Core Concepts

### Metaclasses and Dynamic Programming

```python
class SingletonMeta(type):
    """Metaclass that creates singleton instances."""
    _instances = {}
    
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]

class DatabaseConnection(metaclass=SingletonMeta):
    def __init__(self):
        self.connection_string = "postgresql://localhost:5432"

class ValidatedMeta(type):
    """Metaclass that adds validation to class creation."""
    
    def __new__(mcs, name, bases, namespace):
        # Validate required methods
        required_methods = namespace.get('_required_methods', [])
        for method in required_methods:
            if method not in namespace:
                raise TypeError(f"Class {name} must implement {method} method")
        
        # Add automatic property validation
        for key, value in namespace.items():
            if hasattr(value, '_validators'):
                namespace[key] = mcs._create_validated_property(key, value)
        
        return super().__new__(mcs, name, bases, namespace)
    
    @staticmethod
    def _create_validated_property(name, original_property):
        def getter(self):
            return getattr(self, f'_{name}', None)
        
        def setter(self, value):
            for validator in original_property._validators:
                if not validator(value):
                    raise ValueError(f"Invalid value for {name}: {value}")
            setattr(self, f'_{name}', value)
        
        return property(getter, setter)

# Dynamic class creation
def create_model_class(name, fields):
    """Dynamically create a model class with specified fields."""
    
    def __init__(self, **kwargs):
        for field_name, field_type in fields.items():
            value = kwargs.get(field_name)
            if value is not None and not isinstance(value, field_type):
                raise TypeError(f"{field_name} must be of type {field_type.__name__}")
            setattr(self, field_name, value)
    
    def __repr__(self):
        field_values = ', '.join(f"{k}={getattr(self, k)}" for k in fields.keys())
        return f"{name}({field_values})"
    
    def to_dict(self):
        return {field: getattr(self, field) for field in fields.keys()}
    
    namespace = {
        '__init__': __init__,
        '__repr__': __repr__,
        'to_dict': to_dict,
        '_fields': fields
    }
    
    return type(name, (), namespace)
```

### Descriptors and Property Management

```python
class TypedProperty:
    """Descriptor that enforces type checking."""
    
    def __init__(self, expected_type, default=None):
        self.expected_type = expected_type
        self.default = default
        self.name = None
    
    def __set_name__(self, owner, name):
        self.name = name
        self.private_name = f'_{name}'
    
    def __get__(self, instance, owner):
        if instance is None:
            return self
        return getattr(instance, self.private_name, self.default)
    
    def __set__(self, instance, value):
        if not isinstance(value, self.expected_type):
            raise TypeError(f"{self.name} must be of type {self.expected_type.__name__}")
        setattr(instance, self.private_name, value)
    
    def __delete__(self, instance):
        setattr(instance, self.private_name, self.default)

class ValidatedProperty:
    """Descriptor with custom validation."""
    
    def __init__(self, validator_func=None, default=None):
        self.validator_func = validator_func
        self.default = default
        self.name = None
    
    def __set_name__(self, owner, name):
        self.name = name
        self.private_name = f'_{name}'
    
    def __get__(self, instance, owner):
        if instance is None:
            return self
        return getattr(instance, self.private_name, self.default)
    
    def __set__(self, instance, value):
        if self.validator_func and not self.validator_func(value):
            raise ValueError(f"Invalid value for {self.name}: {value}")
        setattr(instance, self.private_name, value)

# Usage example
class Person:
    name = TypedProperty(str, "")
    age = ValidatedProperty(lambda x: isinstance(x, int) and 0 <= x <= 150, 0)
    email = ValidatedProperty(lambda x: "@" in x if x else True, "")
    
    def __init__(self, name="", age=0, email=""):
        self.name = name
        self.age = age
        self.email = email
```

### Performance Optimization

```python
import sys
import gc
import weakref
from functools import wraps
import time
import cProfile
import pstats
from memory_profiler import profile

class PerformanceMonitor:
    """Monitor and optimize performance."""
    
    def __init__(self):
        self.execution_times = {}
        self.memory_usage = {}
    
    def time_it(self, func_name=None):
        """Decorator to measure execution time."""
        def decorator(func):
            name = func_name or func.__name__
            
            @wraps(func)
            def wrapper(*args, **kwargs):
                start_time = time.perf_counter()
                result = func(*args, **kwargs)
                end_time = time.perf_counter()
                
                execution_time = end_time - start_time
                if name not in self.execution_times:
                    self.execution_times[name] = []
                self.execution_times[name].append(execution_time)
                
                return result
            return wrapper
        return decorator
    
    def profile_memory(self, func):
        """Decorator to profile memory usage."""
        @wraps(func)
        def wrapper(*args, **kwargs):
            gc.collect()  # Clean up before measurement
            before = sys.getsizeof(gc.get_objects())
            
            result = func(*args, **kwargs)
            
            gc.collect()
            after = sys.getsizeof(gc.get_objects())
            
            memory_diff = after - before
            if func.__name__ not in self.memory_usage:
                self.memory_usage[func.__name__] = []
            self.memory_usage[func.__name__].append(memory_diff)
            
            return result
        return wrapper
    
    def get_stats(self):
        """Get performance statistics."""
        stats = {}
        
        for func_name, times in self.execution_times.items():
            stats[func_name] = {
                'avg_time': sum(times) / len(times),
                'min_time': min(times),
                'max_time': max(times),
                'total_calls': len(times)
            }
        
        for func_name, memory_usage in self.memory_usage.items():
            if func_name in stats:
                stats[func_name]['avg_memory'] = sum(memory_usage) / len(memory_usage)
        
        return stats

# Optimized data structures
class OptimizedCache:
    """Memory-efficient cache with weak references."""
    
    def __init__(self, max_size=1000):
        self.max_size = max_size
        self.cache = {}
        self.weak_refs = weakref.WeakValueDictionary()
    
    def __slots__ = ['max_size', 'cache', 'weak_refs']  # Memory optimization
    
    def get(self, key):
        # Try weak reference first
        if key in self.weak_refs:
            return self.weak_refs[key]
        
        # Fall back to regular cache
        return self.cache.get(key)
    
    def set(self, key, value):
        # Try to store as weak reference if possible
        try:
            self.weak_refs[key] = value
        except TypeError:
            # Object doesn't support weak references
            if len(self.cache) >= self.max_size:
                # Remove oldest item (simple FIFO)
                oldest_key = next(iter(self.cache))
                del self.cache[oldest_key]
            self.cache[key] = value

# Generator for memory efficiency
def process_large_dataset(filename, chunk_size=1000):
    """Process large datasets efficiently using generators."""
    
    def read_chunks():
        with open(filename, 'r') as file:
            chunk = []
            for line in file:
                chunk.append(line.strip())
                if len(chunk) >= chunk_size:
                    yield chunk
                    chunk = []
            if chunk:  # Yield remaining items
                yield chunk
    
    for chunk in read_chunks():
        # Process each chunk
        processed_chunk = [process_line(line) for line in chunk]
        yield processed_chunk

def process_line(line):
    # Simulate processing
    return line.upper()
```

### Advanced Concurrency Patterns

```python
import asyncio
import threading
import multiprocessing
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import queue
import time
from dataclasses import dataclass
from typing import Any, Callable, List

@dataclass
class Task:
    id: str
    func: Callable
    args: tuple
    kwargs: dict
    priority: int = 0

class AdvancedTaskScheduler:
    """Advanced task scheduler with multiple execution strategies."""
    
    def __init__(self, max_workers=4):
        self.max_workers = max_workers
        self.task_queue = queue.PriorityQueue()
        self.results = {}
        self.running = False
    
    def add_task(self, task_id: str, func: Callable, args=(), kwargs=None, priority=0):
        """Add task to scheduler."""
        if kwargs is None:
            kwargs = {}
        
        task = Task(task_id, func, args, kwargs, priority)
        self.task_queue.put((priority, task))
    
    def run_sequential(self):
        """Run tasks sequentially."""
        while not self.task_queue.empty():
            priority, task = self.task_queue.get()
            try:
                result = task.func(*task.args, **task.kwargs)
                self.results[task.id] = {'status': 'success', 'result': result}
            except Exception as e:
                self.results[task.id] = {'status': 'error', 'error': str(e)}
    
    def run_threaded(self):
        """Run tasks using thread pool."""
        tasks = []
        while not self.task_queue.empty():
            priority, task = self.task_queue.get()
            tasks.append(task)
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            future_to_task = {
                executor.submit(task.func, *task.args, **task.kwargs): task
                for task in tasks
            }
            
            for future in future_to_task:
                task = future_to_task[future]
                try:
                    result = future.result()
                    self.results[task.id] = {'status': 'success', 'result': result}
                except Exception as e:
                    self.results[task.id] = {'status': 'error', 'error': str(e)}
    
    async def run_async(self):
        """Run tasks asynchronously."""
        tasks = []
        while not self.task_queue.empty():
            priority, task = self.task_queue.get()
            tasks.append(task)
        
        async def execute_task(task):
            try:
                if asyncio.iscoroutinefunction(task.func):
                    result = await task.func(*task.args, **task.kwargs)
                else:
                    result = task.func(*task.args, **task.kwargs)
                return task.id, {'status': 'success', 'result': result}
            except Exception as e:
                return task.id, {'status': 'error', 'error': str(e)}
        
        results = await asyncio.gather(*[execute_task(task) for task in tasks])
        for task_id, result in results:
            self.results[task_id] = result

# Context managers for resource management
class DatabaseTransaction:
    """Context manager for database transactions."""
    
    def __init__(self, connection):
        self.connection = connection
        self.transaction = None
    
    def __enter__(self):
        self.transaction = self.connection.begin()
        return self.transaction
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is None:
            self.transaction.commit()
        else:
            self.transaction.rollback()
        self.transaction = None

class ResourcePool:
    """Generic resource pool with context manager support."""
    
    def __init__(self, create_resource, max_size=10):
        self.create_resource = create_resource
        self.max_size = max_size
        self.pool = queue.Queue(maxsize=max_size)
        self.active_count = 0
        self.lock = threading.Lock()
    
    def acquire(self):
        """Acquire a resource from the pool."""
        try:
            return self.pool.get_nowait()
        except queue.Empty:
            with self.lock:
                if self.active_count < self.max_size:
                    self.active_count += 1
                    return self.create_resource()
            
            # Wait for a resource to become available
            return self.pool.get()
    
    def release(self, resource):
        """Release a resource back to the pool."""
        try:
            self.pool.put_nowait(resource)
        except queue.Full:
            # Pool is full, destroy the resource
            with self.lock:
                self.active_count -= 1
    
    def __enter__(self):
        self.resource = self.acquire()
        return self.resource
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.release(self.resource)
```

## 📝 Practice Projects

### Project 1: Advanced ORM Framework

Build a mini-ORM using metaclasses, descriptors, and advanced Python features.

### Project 2: Performance Monitoring System

Create a comprehensive performance monitoring and optimization toolkit.

### Project 3: Concurrent Data Processing Engine

Develop a high-performance data processing engine with multiple concurrency strategies.

## 🎯 Learning Milestones

### Week 1-3: Metaclasses and Dynamic Programming

- [ ] Master metaclass creation and usage
- [ ] Implement dynamic class generation
- [ ] Understand Python's object model

### Week 4-6: Descriptors and Properties

- [ ] Create custom descriptors
- [ ] Implement advanced property management
- [ ] Build validation frameworks

### Week 7-9: Performance Optimization

- [ ] Profile and optimize code
- [ ] Implement memory-efficient patterns
- [ ] Use advanced data structures

### Week 10-12: Advanced Concurrency

- [ ] Master async/await patterns
- [ ] Implement resource pooling
- [ ] Build high-performance systems

### Week 13-15: Integration and Mastery

- [ ] Combine all advanced features
- [ ] Build production-ready frameworks
- [ ] Mentor others in Python expertise

## 🎉 Expert Achievement

**Congratulations!** You have completed the Python Fundamentals journey from **Noob to Python Expert**!

### Your Python Expert Toolkit

- ✅ **Mastered Python internals** - Metaclasses, descriptors, and object model
- ✅ **Performance optimization** - Profiling, memory management, and efficiency
- ✅ **Advanced concurrency** - Async patterns, threading, and multiprocessing
- ✅ **Dynamic programming** - Runtime class creation and metaprogramming
- ✅ **Production expertise** - Building frameworks and scalable systems

### Next Learning Paths

- **Web Development**: Flask, Django, FastAPI
- **Data Science**: Advanced ML, AI, and analytics
- **DevOps**: Infrastructure, deployment, and monitoring
- **Specialized Domains**: Game development, embedded systems, research

## 🔗 Related Topics

### Prerequisites

- [08_Specialist-to-Professional](../08_Specialist-to-Professional/) - Third-party Ecosystem

### Enables

- Advanced Python tracks in specialized domains
- Leadership and mentoring roles
- Framework and library development
- Python community contributions

---

**Last Updated**: September 7, 2025  
**Maintained By**: STSA Learning System  
**Achievement Level**: 🏆 **PYTHON EXPERT** 🏆
