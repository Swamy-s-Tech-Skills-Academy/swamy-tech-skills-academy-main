# 07_Skilled-Coder-to-Specialist - Python Standard Library

**Learning Level**: Advanced  
**Prerequisites**: Completed 06_Practitioner-to-Skilled-Coder (Design Patterns)  
**Estimated Time**: 8-10 weeks

## 🎯 Learning Objectives

- **Master Python's extensive standard library**
- **Implement advanced data structures and algorithms**
- **Use built-in modules for common tasks**
- **Apply functional programming concepts**
- **Achieve the milestone**: "I leverage Python's full power!"

## 📋 Core Concepts

### Collections and Data Structures

```python
from collections import defaultdict, Counter, deque, namedtuple
from dataclasses import dataclass
from typing import Dict, List, Optional

# defaultdict for grouping
def group_by_category(items):
    groups = defaultdict(list)
    for item in items:
        groups[item.category].append(item)
    return dict(groups)

# Counter for frequency analysis
def analyze_text(text):
    words = text.lower().split()
    word_count = Counter(words)
    return {
        'total_words': len(words),
        'unique_words': len(word_count),
        'most_common': word_count.most_common(5)
    }

# deque for efficient operations
class LRUCache:
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.cache = {}
        self.order = deque()
    
    def get(self, key):
        if key in self.cache:
            self.order.remove(key)
            self.order.append(key)
            return self.cache[key]
        return None
    
    def put(self, key, value):
        if key in self.cache:
            self.order.remove(key)
        elif len(self.cache) >= self.capacity:
            oldest = self.order.popleft()
            del self.cache[oldest]
        
        self.cache[key] = value
        self.order.append(key)

# namedtuple and dataclass
Point = namedtuple('Point', ['x', 'y'])

@dataclass
class Product:
    name: str
    price: float
    category: str
    in_stock: bool = True
    
    def discounted_price(self, discount: float) -> float:
        return self.price * (1 - discount)
```

### Functional Programming

```python
from functools import reduce, partial, lru_cache
from itertools import chain, combinations, groupby
from operator import itemgetter, attrgetter

# Higher-order functions
def compose(*functions):
    return reduce(lambda f, g: lambda x: f(g(x)), functions, lambda x: x)

def curry(func):
    def curried(*args, **kwargs):
        if len(args) + len(kwargs) >= func.__code__.co_argcount:
            return func(*args, **kwargs)
        return lambda *more_args, **more_kwargs: curried(*(args + more_args), **{**kwargs, **more_kwargs})
    return curried

# Using itertools for data processing
def process_sales_data(sales):
    # Group by date
    sales_by_date = groupby(
        sorted(sales, key=itemgetter('date')), 
        key=itemgetter('date')
    )
    
    daily_totals = {}
    for date, sales_group in sales_by_date:
        daily_total = sum(sale['amount'] for sale in sales_group)
        daily_totals[date] = daily_total
    
    return daily_totals

# Memoization with lru_cache
@lru_cache(maxsize=None)
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# Partial function application
def log_message(level, message, timestamp=None):
    import datetime
    if timestamp is None:
        timestamp = datetime.datetime.now()
    return f"[{timestamp}] {level}: {message}"

log_error = partial(log_message, "ERROR")
log_info = partial(log_message, "INFO")
```

### Concurrency and Parallelism

```python
import asyncio
import concurrent.futures
from threading import Thread, Lock
import time

# Async/await patterns
class AsyncDataProcessor:
    def __init__(self):
        self.session = None
    
    async def __aenter__(self):
        # Initialize async resources
        self.session = "async_session"
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        # Cleanup async resources
        self.session = None
    
    async def fetch_data(self, url):
        await asyncio.sleep(0.1)  # Simulate network call
        return f"Data from {url}"
    
    async def process_multiple_urls(self, urls):
        tasks = [self.fetch_data(url) for url in urls]
        results = await asyncio.gather(*tasks)
        return results

# Thread-safe data structures
class ThreadSafeCounter:
    def __init__(self):
        self._value = 0
        self._lock = Lock()
    
    def increment(self):
        with self._lock:
            self._value += 1
    
    def get_value(self):
        with self._lock:
            return self._value

# ProcessPoolExecutor for CPU-bound tasks
def cpu_intensive_task(n):
    return sum(i * i for i in range(n))

def parallel_processing(numbers):
    with concurrent.futures.ProcessPoolExecutor() as executor:
        futures = [executor.submit(cpu_intensive_task, n) for n in numbers]
        results = [future.result() for future in concurrent.futures.as_completed(futures)]
    return results
```

### File and Data Handling

```python
import json
import csv
import pathlib
import tempfile
import contextlib
from typing import Generator

# Path operations with pathlib
class FileManager:
    def __init__(self, base_path: str):
        self.base_path = pathlib.Path(base_path)
        self.base_path.mkdir(exist_ok=True)
    
    def create_file(self, filename: str, content: str):
        file_path = self.base_path / filename
        file_path.write_text(content)
        return file_path
    
    def list_files(self, pattern: str = "*"):
        return list(self.base_path.glob(pattern))
    
    def get_file_info(self, filename: str):
        file_path = self.base_path / filename
        if file_path.exists():
            return {
                'size': file_path.stat().st_size,
                'modified': file_path.stat().st_mtime,
                'is_file': file_path.is_file()
            }
        return None

# Context managers for resource handling
@contextlib.contextmanager
def temp_directory():
    with tempfile.TemporaryDirectory() as temp_dir:
        old_cwd = pathlib.Path.cwd()
        temp_path = pathlib.Path(temp_dir)
        try:
            import os
            os.chdir(temp_path)
            yield temp_path
        finally:
            os.chdir(old_cwd)

# Data serialization
class DataSerializer:
    @staticmethod
    def to_json(data, filename):
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2, default=str)
    
    @staticmethod
    def from_json(filename):
        with open(filename, 'r') as f:
            return json.load(f)
    
    @staticmethod
    def to_csv(data, filename, fieldnames=None):
        if not data:
            return
        
        if fieldnames is None:
            fieldnames = data[0].keys() if hasattr(data[0], 'keys') else range(len(data[0]))
        
        with open(filename, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(data)
```

## 📝 Practice Projects

### Project 1: Log Analysis Tool

Build a comprehensive log analysis tool using collections, itertools, and file handling.

### Project 2: Async Web Scraper

Create an asynchronous web scraping system with concurrent processing and data serialization.

### Project 3: Data Pipeline Framework

Develop a functional programming-based data processing pipeline with caching and optimization.

## 🎯 Learning Milestones

### Week 1-2: Collections and Data Structures

- [ ] Master collections module
- [ ] Implement custom data structures
- [ ] Use dataclasses effectively

### Week 3-4: Functional Programming

- [ ] Apply map, filter, reduce patterns
- [ ] Use itertools for data processing
- [ ] Implement functional composition

### Week 5-6: Concurrency and Async

- [ ] Write async/await code
- [ ] Handle threading and multiprocessing
- [ ] Implement concurrent patterns

### Week 7-8: File and System Operations

- [ ] Master pathlib for file operations
- [ ] Implement context managers
- [ ] Handle data serialization

### Week 9-10: Integration and Optimization

- [ ] Combine multiple modules
- [ ] Optimize performance with profiling
- [ ] Build complete applications

## 🔗 Related Topics

### Prerequisites

- [06_Practitioner-to-Skilled-Coder](../06_Practitioner-to-Skilled-Coder/) - Design Patterns

### Enables

- [08_Specialist-to-Professional](../08_Specialist-to-Professional/) - Third-party Ecosystem

---

**Last Updated**: September 7, 2025  
**Maintained By**: STSA Learning System
