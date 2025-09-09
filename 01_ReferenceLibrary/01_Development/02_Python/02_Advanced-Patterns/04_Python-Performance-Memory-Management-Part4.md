# 04_Python-Performance-Memory-Management-Part4

**Learning Level**: Advanced  
**Prerequisites**: Async patterns (Part 3), Python data model, profiling basics  
**Estimated Time**: Part 4 of 6 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master Python memory optimization techniques for high-performance applications
- Implement custom memory management patterns with weak references and object pools
- Design CPU-optimized algorithms using caching, lazy evaluation, and vectorization
- Build production monitoring systems for performance analysis and bottleneck detection

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

**Python Performance** often involves memory optimization (reducing allocations), CPU optimization (algorithmic efficiency), and I/O optimization (async patterns). **Memory Management** includes object pooling, weak references, and memory profiling. **Production systems** require continuous monitoring and automatic optimization.

**Key Strategies**:

- **Memory Pools**: Reuse objects to reduce garbage collection pressure
- **Weak References**: Avoid memory leaks in caches and event systems
- **Lazy Evaluation**: Compute values only when needed using generators and properties
- **Vectorization**: Use NumPy and built-in optimizations for numerical operations

### Core Implementation (6 minutes)

```python
# ✅ Advanced Memory Management Implementation
import gc
import sys
import threading
import time
import tracemalloc
import weakref
from collections import defaultdict, deque
from dataclasses import dataclass, field
from typing import Any, Callable, Dict, Generic, Iterator, List, Optional, Set, TypeVar, Union
import functools
import array
import mmap

T = TypeVar('T')

class ObjectPool(Generic[T]):
    """Thread-safe object pool for reducing allocation overhead."""
    
    def __init__(self, factory: Callable[[], T], max_size: int = 100, 
                 reset_func: Optional[Callable[[T], None]] = None):
        self.factory = factory
        self.max_size = max_size
        self.reset_func = reset_func
        
        self._pool: deque = deque()
        self._lock = threading.Lock()
        self._created_count = 0
        self._reused_count = 0
    
    def acquire(self) -> T:
        """Get object from pool or create new one."""
        with self._lock:
            if self._pool:
                obj = self._pool.popleft()
                self._reused_count += 1
                return obj
        
        # Create new object outside of lock
        obj = self.factory()
        self._created_count += 1
        return obj
    
    def release(self, obj: T):
        """Return object to pool for reuse."""
        if self.reset_func:
            self.reset_func(obj)
        
        with self._lock:
            if len(self._pool) < self.max_size:
                self._pool.append(obj)
    
    def get_stats(self) -> Dict[str, int]:
        """Get pool usage statistics."""
        with self._lock:
            return {
                'created': self._created_count,
                'reused': self._reused_count,
                'current_pool_size': len(self._pool),
                'max_pool_size': self.max_size,
                'reuse_ratio': self._reused_count / max(1, self._created_count + self._reused_count)
            }

class WeakCache:
    """Memory-efficient cache using weak references to avoid memory leaks."""
    
    def __init__(self, max_size: int = 1000):
        self.max_size = max_size
        self._cache: Dict[Any, Any] = weakref.WeakValueDictionary()
        self._access_times: Dict[Any, float] = {}
        self._lock = threading.RLock()
    
    def get(self, key: Any, factory: Optional[Callable[[], Any]] = None) -> Any:
        """Get value from cache or create using factory function."""
        with self._lock:
            # Try to get from cache
            value = self._cache.get(key)
            if value is not None:
                self._access_times[key] = time.time()
                return value
            
            # Create new value if factory provided
            if factory:
                value = factory()
                self.set(key, value)
                return value
            
            return None
    
    def set(self, key: Any, value: Any):
        """Store value in cache with LRU eviction."""
        with self._lock:
            # Check if we need to evict old entries
            if len(self._cache) >= self.max_size:
                self._evict_lru()
            
            # Store new value
            self._cache[key] = value
            self._access_times[key] = time.time()
    
    def _evict_lru(self):
        """Remove least recently used items."""
        if not self._access_times:
            return
        
        # Find oldest 25% of entries to remove
        items_to_remove = len(self._access_times) // 4
        if items_to_remove == 0:
            items_to_remove = 1
        
        # Sort by access time and remove oldest
        sorted_keys = sorted(self._access_times.items(), key=lambda x: x[1])
        
        for key, _ in sorted_keys[:items_to_remove]:
            self._cache.pop(key, None)
            self._access_times.pop(key, None)
    
    def clear(self):
        """Clear all cached values."""
        with self._lock:
            self._cache.clear()
            self._access_times.clear()
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics."""
        with self._lock:
            return {
                'size': len(self._cache),
                'max_size': self.max_size,
                'hit_ratio': getattr(self, '_hits', 0) / max(1, getattr(self, '_total_requests', 1))
            }

class MemoryMonitor:
    """Real-time memory monitoring and analysis."""
    
    def __init__(self, sample_interval: float = 1.0):
        self.sample_interval = sample_interval
        self._monitoring = False
        self._samples: List[Dict[str, Any]] = []
        self._monitor_thread: Optional[threading.Thread] = None
        self._stop_event = threading.Event()
    
    def start(self):
        """Start memory monitoring."""
        if self._monitoring:
            return
        
        tracemalloc.start()
        self._monitoring = True
        self._stop_event.clear()
        
        self._monitor_thread = threading.Thread(target=self._monitor_loop, daemon=True)
        self._monitor_thread.start()
    
    def stop(self) -> List[Dict[str, Any]]:
        """Stop monitoring and return collected samples."""
        if not self._monitoring:
            return self._samples
        
        self._monitoring = False
        self._stop_event.set()
        
        if self._monitor_thread:
            self._monitor_thread.join(timeout=5.0)
        
        tracemalloc.stop()
        return self._samples.copy()
    
    def _monitor_loop(self):
        """Background monitoring loop."""
        while not self._stop_event.wait(self.sample_interval):
            try:
                sample = self._collect_sample()
                self._samples.append(sample)
                
                # Keep only last 1000 samples
                if len(self._samples) > 1000:
                    self._samples = self._samples[-1000:]
                    
            except Exception as e:
                # Continue monitoring even if sample collection fails
                pass
    
    def _collect_sample(self) -> Dict[str, Any]:
        """Collect memory usage sample."""
        import psutil
        import os
        
        # Process memory info
        process = psutil.Process(os.getpid())
        memory_info = process.memory_info()
        
        # Tracemalloc info
        current, peak = tracemalloc.get_traced_memory()
        
        # Garbage collection info
        gc_stats = gc.get_stats()
        
        return {
            'timestamp': time.time(),
            'rss_mb': memory_info.rss / 1024 / 1024,
            'vms_mb': memory_info.vms / 1024 / 1024,
            'traced_current_mb': current / 1024 / 1024,
            'traced_peak_mb': peak / 1024 / 1024,
            'gc_collections': [stat['collections'] for stat in gc_stats],
            'gc_collected': [stat['collected'] for stat in gc_stats],
            'object_count': len(gc.get_objects())
        }
    
    def get_summary(self) -> Dict[str, Any]:
        """Get memory usage summary."""
        if not self._samples:
            return {}
        
        rss_values = [s['rss_mb'] for s in self._samples]
        traced_values = [s['traced_current_mb'] for s in self._samples]
        
        return {
            'duration_seconds': self._samples[-1]['timestamp'] - self._samples[0]['timestamp'],
            'sample_count': len(self._samples),
            'rss_mb': {
                'min': min(rss_values),
                'max': max(rss_values),
                'avg': sum(rss_values) / len(rss_values),
                'current': rss_values[-1]
            },
            'traced_mb': {
                'min': min(traced_values),
                'max': max(traced_values),
                'avg': sum(traced_values) / len(traced_values),
                'current': traced_values[-1]
            }
        }

# ✅ CPU Optimization Patterns
class LazyProperty:
    """Lazy-evaluated property with caching and optional expiry."""
    
    def __init__(self, func: Callable, expires_after: Optional[float] = None):
        self.func = func
        self.expires_after = expires_after
        self.attrname = None
        self.__doc__ = func.__doc__
    
    def __set_name__(self, owner, name):
        if self.attrname is None:
            self.attrname = name
        elif name != self.attrname:
            raise RuntimeError(f"Cannot assign LazyProperty to two different names")
    
    def __get__(self, instance, owner):
        if instance is None:
            return self
        
        cache_name = f'_lazy_{self.attrname}'
        time_name = f'_lazy_time_{self.attrname}'
        
        # Check if value exists and is not expired
        if hasattr(instance, cache_name):
            if self.expires_after is None:
                return getattr(instance, cache_name)
            
            cached_time = getattr(instance, time_name, 0)
            if time.time() - cached_time < self.expires_after:
                return getattr(instance, cache_name)
        
        # Compute and cache value
        value = self.func(instance)
        setattr(instance, cache_name, value)
        setattr(instance, time_name, time.time())
        
        return value
    
    def __delete__(self, instance):
        cache_name = f'_lazy_{self.attrname}'
        time_name = f'_lazy_time_{self.attrname}'
        
        if hasattr(instance, cache_name):
            delattr(instance, cache_name)
        if hasattr(instance, time_name):
            delattr(instance, time_name)

def memoize_with_ttl(ttl_seconds: float = 300):
    """Memoization decorator with time-to-live expiry."""
    
    def decorator(func: Callable) -> Callable:
        cache: Dict[tuple, tuple] = {}  # (args, kwargs) -> (result, timestamp)
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # Create cache key
            key = (args, tuple(sorted(kwargs.items())))
            
            # Check cache
            if key in cache:
                result, timestamp = cache[key]
                if time.time() - timestamp < ttl_seconds:
                    return result
                else:
                    del cache[key]
            
            # Compute and cache result
            result = func(*args, **kwargs)
            cache[key] = (result, time.time())
            
            return result
        
        wrapper.cache_clear = cache.clear
        wrapper.cache_info = lambda: {
            'size': len(cache),
            'ttl': ttl_seconds
        }
        
        return wrapper
    
    return decorator

class VectorizedProcessor:
    """Optimized numerical processing using array operations."""
    
    def __init__(self):
        # Use array.array for efficient numeric storage
        self._buffer = array.array('d')  # double precision float
        self._results = array.array('d')
    
    def process_batch(self, data: List[float]) -> List[float]:
        """Process numerical data using vectorized operations."""
        
        # Clear and populate buffer
        self._buffer = array.array('d', data)
        
        # Vectorized processing (simplified example)
        # In production, would use NumPy for complex operations
        result_data = []
        
        # Use memory-mapped processing for large datasets
        if len(self._buffer) > 10000:
            return self._process_large_batch()
        
        # Optimized loop for smaller datasets
        for i in range(len(self._buffer)):
            # Example computation: running average
            if i == 0:
                avg = self._buffer[i]
            else:
                avg = (sum(self._buffer[:i+1])) / (i + 1)
            
            result_data.append(avg * 1.1)  # Apply some transformation
        
        return result_data
    
    def _process_large_batch(self) -> List[float]:
        """Memory-efficient processing for large datasets."""
        # Simulate memory-mapped file processing
        # In production, would use actual mmap for very large datasets
        
        chunk_size = 1000
        results = []
        
        for i in range(0, len(self._buffer), chunk_size):
            chunk = self._buffer[i:i+chunk_size]
            
            # Process chunk
            chunk_results = []
            running_sum = 0
            for j, value in enumerate(chunk):
                running_sum += value
                avg = running_sum / (j + 1)
                chunk_results.append(avg * 1.1)
            
            results.extend(chunk_results)
        
        return results

# ✅ Production Performance Framework
class PerformanceProfiler:
    """Production performance profiler with automatic optimization suggestions."""
    
    def __init__(self):
        self.profiles: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
        self._active_profiles: Dict[str, Dict[str, Any]] = {}
        self._lock = threading.Lock()
    
    def profile_function(self, name: str = None):
        """Decorator for profiling function execution."""
        
        def decorator(func: Callable) -> Callable:
            profile_name = name or f"{func.__module__}.{func.__name__}"
            
            @functools.wraps(func)
            def wrapper(*args, **kwargs):
                return self._profile_execution(profile_name, func, args, kwargs)
            
            return wrapper
        
        return decorator
    
    def _profile_execution(self, name: str, func: Callable, args: tuple, kwargs: dict) -> Any:
        """Execute function with performance profiling."""
        
        # Start profiling
        start_time = time.perf_counter()
        start_memory = 0
        
        if tracemalloc.is_tracing():
            start_memory = tracemalloc.get_traced_memory()[0]
        
        try:
            result = func(*args, **kwargs)
            
            # Record successful execution
            end_time = time.perf_counter()
            end_memory = 0
            
            if tracemalloc.is_tracing():
                end_memory = tracemalloc.get_traced_memory()[0]
            
            profile_data = {
                'timestamp': time.time(),
                'execution_time': end_time - start_time,
                'memory_delta': end_memory - start_memory,
                'success': True,
                'args_count': len(args),
                'kwargs_count': len(kwargs)
            }
            
            with self._lock:
                self.profiles[name].append(profile_data)
                # Keep only last 1000 profiles per function
                if len(self.profiles[name]) > 1000:
                    self.profiles[name] = self.profiles[name][-1000:]
            
            return result
            
        except Exception as e:
            # Record failed execution
            end_time = time.perf_counter()
            
            profile_data = {
                'timestamp': time.time(),
                'execution_time': end_time - start_time,
                'memory_delta': 0,
                'success': False,
                'error': str(e),
                'args_count': len(args),
                'kwargs_count': len(kwargs)
            }
            
            with self._lock:
                self.profiles[name].append(profile_data)
            
            raise
    
    def get_performance_summary(self) -> Dict[str, Dict[str, Any]]:
        """Get performance summary for all profiled functions."""
        
        summary = {}
        
        with self._lock:
            for func_name, profile_list in self.profiles.items():
                if not profile_list:
                    continue
                
                successful_profiles = [p for p in profile_list if p['success']]
                
                if not successful_profiles:
                    summary[func_name] = {'error': 'No successful executions'}
                    continue
                
                execution_times = [p['execution_time'] for p in successful_profiles]
                memory_deltas = [p['memory_delta'] for p in successful_profiles]
                
                summary[func_name] = {
                    'call_count': len(successful_profiles),
                    'error_count': len(profile_list) - len(successful_profiles),
                    'avg_execution_time': sum(execution_times) / len(execution_times),
                    'max_execution_time': max(execution_times),
                    'min_execution_time': min(execution_times),
                    'avg_memory_delta': sum(memory_deltas) / len(memory_deltas) if memory_deltas else 0,
                    'max_memory_delta': max(memory_deltas) if memory_deltas else 0,
                    'suggestions': self._generate_suggestions(func_name, successful_profiles)
                }
        
        return summary
    
    def _generate_suggestions(self, func_name: str, profiles: List[Dict[str, Any]]) -> List[str]:
        """Generate optimization suggestions based on profile data."""
        
        suggestions = []
        
        if not profiles:
            return suggestions
        
        execution_times = [p['execution_time'] for p in profiles]
        avg_time = sum(execution_times) / len(execution_times)
        max_time = max(execution_times)
        
        # Performance suggestions
        if max_time > avg_time * 3:
            suggestions.append("High execution time variance - consider caching or optimization")
        
        if avg_time > 1.0:
            suggestions.append("Average execution time > 1s - consider async processing")
        
        if len(profiles) > 100 and avg_time > 0.1:
            suggestions.append("Frequently called slow function - high optimization priority")
        
        # Memory suggestions
        memory_deltas = [p['memory_delta'] for p in profiles if p['memory_delta'] > 0]
        if memory_deltas:
            avg_memory = sum(memory_deltas) / len(memory_deltas)
            if avg_memory > 1024 * 1024:  # 1MB
                suggestions.append("High memory usage - consider object pooling or streaming")
        
        return suggestions

# ✅ Usage Examples
class OptimizedDataProcessor:
    """Example class demonstrating performance optimization patterns."""
    
    def __init__(self):
        self.cache = WeakCache(max_size=1000)
        self.object_pool = ObjectPool(
            factory=lambda: {'data': None, 'processed': False},
            reset_func=lambda obj: obj.update({'data': None, 'processed': False})
        )
        self.profiler = PerformanceProfiler()
    
    @LazyProperty
    def expensive_computation(self) -> Dict[str, Any]:
        """Lazy-evaluated expensive computation."""
        # Simulate expensive operation
        time.sleep(0.1)
        return {'result': 'computed_value', 'timestamp': time.time()}
    
    @memoize_with_ttl(ttl_seconds=300)
    def cached_operation(self, key: str) -> str:
        """Memoized operation with TTL."""
        # Simulate expensive lookup
        time.sleep(0.05)
        return f"result_for_{key}"
    
    def process_with_pooling(self, data_items: List[Any]) -> List[Dict[str, Any]]:
        """Process data using object pooling."""
        
        results = []
        
        for item in data_items:
            # Get object from pool
            processor_obj = self.object_pool.acquire()
            
            try:
                # Use object
                processor_obj['data'] = item
                processor_obj['processed'] = True
                
                results.append(processor_obj.copy())
                
            finally:
                # Return to pool
                self.object_pool.release(processor_obj)
        
        return results

# ✅ Advanced Usage Demonstration
def demonstrate_performance_optimization():
    """Demonstrate performance optimization patterns."""
    
    # Setup monitoring
    monitor = MemoryMonitor(sample_interval=0.1)
    monitor.start()
    
    try:
        # Create processor
        processor = OptimizedDataProcessor()
        
        # Test lazy property
        print("Testing lazy property...")
        result1 = processor.expensive_computation
        result2 = processor.expensive_computation  # Should use cached value
        
        # Test memoization
        print("Testing memoization...")
        cached1 = processor.cached_operation("test_key")
        cached2 = processor.cached_operation("test_key")  # Should use cache
        
        # Test object pooling
        print("Testing object pooling...")
        test_data = list(range(100))
        pooled_results = processor.process_with_pooling(test_data)
        
        print(f"Pool stats: {processor.object_pool.get_stats()}")
        
        # Test vectorized processing
        print("Testing vectorized processing...")
        vector_processor = VectorizedProcessor()
        numeric_data = [float(i) for i in range(1000)]
        vector_results = vector_processor.process_batch(numeric_data)
        
        print(f"Processed {len(vector_results)} items")
        
    finally:
        # Stop monitoring and get results
        memory_samples = monitor.stop()
        memory_summary = monitor.get_summary()
        
        print(f"Memory monitoring summary: {memory_summary}")

if __name__ == "__main__":
    demonstrate_performance_optimization()
```

### Key Takeaways (2 minutes)

#### **🎯 Memory Management Excellence**

**Object Pooling**: Reduce allocation overhead with reusable object pools and statistics tracking

**Weak References**: Memory-safe caching that prevents memory leaks in long-running applications

**Memory Monitoring**: Real-time tracking with automatic sample collection and analysis

#### **⚡ CPU Optimization Mastery**

- **Lazy Evaluation**: Compute values only when needed with expiry support
- **Memoization**: Time-based caching with automatic cleanup for expensive operations
- **Vectorization**: Array-based processing for numerical computations
- **Performance Profiling**: Automatic optimization suggestions based on execution patterns

**🎉 Next**: Part 5 covers Design Patterns & Architecture for scalable Python systems! 🚀
