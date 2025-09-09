# 01_Python-Advanced-Context-Decorators-Part1

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Python fundamentals, OOP concepts, basic function definitions  
**Estimated Time**: Part 1 of 6 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master context managers with `__enter__` and `__exit__` protocols for resource management
- Implement custom decorators with functools.wraps for clean function enhancement
- Build advanced decorator patterns for logging, timing, and validation
- Design context-aware resource management systems for production applications

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

**Context Managers** handle resource acquisition and cleanup automatically using the `with` statement. **Decorators** are functions that modify or enhance other functions without changing their source code. Both patterns are essential for **clean architecture** and **resource safety** in enterprise Python applications.

**Key Benefits**:

- **Automatic Cleanup**: Context managers ensure resources are properly released
- **Code Reusability**: Decorators eliminate duplicate cross-cutting concerns  
- **Error Safety**: Proper exception handling in resource management
- **Clean APIs**: Separation of concerns and readable function interfaces

### Core Implementation (6 minutes)

```python
# ✅ Advanced Context Manager Implementation
import contextlib
import logging
import time
import threading
from functools import wraps
from typing import Any, Callable, Generator, Optional, Union

class DatabaseConnection:
    """Production-ready database connection context manager with retry logic."""
    
    def __init__(self, connection_string: str, max_retries: int = 3):
        self.connection_string = connection_string
        self.max_retries = max_retries
        self.connection = None
        self.transaction = None
        self._lock = threading.Lock()
        self.logger = logging.getLogger(__name__)
    
    def __enter__(self):
        """Acquire database connection with retry logic."""
        for attempt in range(self.max_retries):
            try:
                self.connection = self._create_connection()
                self.transaction = self.connection.begin()
                self.logger.info(f"Database connection established on attempt {attempt + 1}")
                return self.connection
            except Exception as e:
                self.logger.warning(f"Connection attempt {attempt + 1} failed: {e}")
                if attempt == self.max_retries - 1:
                    raise ConnectionError(f"Failed to connect after {self.max_retries} attempts")
                time.sleep(2 ** attempt)  # Exponential backoff
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Cleanup with proper transaction handling."""
        try:
            if exc_type is None:
                # No exception occurred, commit transaction
                if self.transaction:
                    self.transaction.commit()
                    self.logger.info("Transaction committed successfully")
            else:
                # Exception occurred, rollback transaction
                if self.transaction:
                    self.transaction.rollback()
                    self.logger.error(f"Transaction rolled back due to: {exc_val}")
        except Exception as cleanup_error:
            self.logger.error(f"Error during cleanup: {cleanup_error}")
        finally:
            # Always close connection
            if self.connection:
                self.connection.close()
                self.logger.info("Database connection closed")
        
        # Return False to propagate exceptions
        return False
    
    def _create_connection(self):
        """Mock connection creation - replace with actual database driver."""
        # Simulate connection creation
        import random
        if random.random() < 0.3:  # 30% failure rate for testing
            raise ConnectionError("Simulated connection failure")
        
        class MockConnection:
            def begin(self):
                return MockTransaction()
            def close(self):
                pass
        
        return MockConnection()

class MockTransaction:
    def commit(self):
        pass
    def rollback(self):
        pass

# ✅ Advanced Decorator Patterns with Metadata Preservation
def performance_monitor(track_memory: bool = False, log_level: str = "INFO"):
    """Advanced decorator for performance monitoring with configurable options."""
    
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            import tracemalloc
            import psutil
            import os
            
            # Setup monitoring
            start_time = time.perf_counter()
            process = psutil.Process(os.getpid()) if track_memory else None
            
            if track_memory:
                tracemalloc.start()
                memory_before = process.memory_info().rss / 1024 / 1024  # MB
            
            try:
                # Execute function
                result = func(*args, **kwargs)
                
                # Calculate performance metrics
                execution_time = time.perf_counter() - start_time
                
                metrics = {
                    'function': func.__name__,
                    'execution_time_ms': round(execution_time * 1000, 2),
                    'args_count': len(args),
                    'kwargs_count': len(kwargs)
                }
                
                if track_memory:
                    memory_after = process.memory_info().rss / 1024 / 1024  # MB
                    current, peak = tracemalloc.get_traced_memory()
                    tracemalloc.stop()
                    
                    metrics.update({
                        'memory_delta_mb': round(memory_after - memory_before, 2),
                        'peak_memory_mb': round(peak / 1024 / 1024, 2),
                        'current_memory_mb': round(current / 1024 / 1024, 2)
                    })
                
                # Log performance data
                logger = logging.getLogger(func.__module__)
                log_method = getattr(logger, log_level.lower())
                log_method(f"Performance metrics: {metrics}")
                
                return result
                
            except Exception as e:
                # Log error with performance context
                error_time = time.perf_counter() - start_time
                logger = logging.getLogger(func.__module__)
                logger.error(f"Function {func.__name__} failed after {error_time:.3f}s: {e}")
                raise
        
        # Preserve function metadata
        wrapper.__wrapped__ = func
        wrapper.__performance_monitored__ = True
        return wrapper
    
    return decorator

# ✅ Validation Decorator with Type Checking
def validate_types(**type_hints):
    """Runtime type validation decorator with detailed error messages."""
    
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            import inspect
            
            # Get function signature
            sig = inspect.signature(func)
            bound_args = sig.bind(*args, **kwargs)
            bound_args.apply_defaults()
            
            # Validate types
            for param_name, expected_type in type_hints.items():
                if param_name in bound_args.arguments:
                    value = bound_args.arguments[param_name]
                    
                    if not isinstance(value, expected_type):
                        actual_type = type(value).__name__
                        expected_name = expected_type.__name__ if hasattr(expected_type, '__name__') else str(expected_type)
                        
                        raise TypeError(
                            f"Parameter '{param_name}' in {func.__name__}() "
                            f"expected {expected_name}, got {actual_type}: {value}"
                        )
            
            return func(*args, **kwargs)
        
        return wrapper
    return decorator

# ✅ Contextlib-based Context Managers
@contextlib.contextmanager
def temporary_file_manager(filename: str, content: str = "") -> Generator[str, None, None]:
    """Context manager for temporary file creation with automatic cleanup."""
    import tempfile
    import os
    
    temp_dir = tempfile.gettempdir()
    filepath = os.path.join(temp_dir, filename)
    
    try:
        # Create temporary file
        with open(filepath, 'w') as f:
            f.write(content)
        
        logging.info(f"Temporary file created: {filepath}")
        yield filepath
        
    except Exception as e:
        logging.error(f"Error with temporary file {filepath}: {e}")
        raise
    finally:
        # Cleanup
        try:
            if os.path.exists(filepath):
                os.remove(filepath)
                logging.info(f"Temporary file cleaned up: {filepath}")
        except OSError as cleanup_error:
            logging.warning(f"Failed to cleanup {filepath}: {cleanup_error}")

@contextlib.contextmanager
def performance_context(operation_name: str):
    """Context manager for timing code blocks with logging."""
    start_time = time.perf_counter()
    logger = logging.getLogger(__name__)
    
    logger.info(f"Starting operation: {operation_name}")
    
    try:
        yield
    except Exception as e:
        duration = time.perf_counter() - start_time
        logger.error(f"Operation '{operation_name}' failed after {duration:.3f}s: {e}")
        raise
    else:
        duration = time.perf_counter() - start_time
        logger.info(f"Operation '{operation_name}' completed in {duration:.3f}s")

# ✅ Production Usage Examples
class APIService:
    """Example service demonstrating advanced patterns in production context."""
    
    def __init__(self, db_connection_string: str):
        self.db_connection_string = db_connection_string
        self.logger = logging.getLogger(__name__)
    
    @performance_monitor(track_memory=True, log_level="DEBUG")
    @validate_types(user_id=int, data=dict)
    def update_user_profile(self, user_id: int, data: dict) -> bool:
        """Update user profile with monitoring and validation."""
        
        with DatabaseConnection(self.db_connection_string) as conn:
            with performance_context(f"update_user_{user_id}"):
                # Simulate database update
                query = f"UPDATE users SET profile_data = ? WHERE id = ?"
                # conn.execute(query, (data, user_id))  # Real implementation
                
                # Simulate processing time
                time.sleep(0.01)
                
                return True
    
    def export_user_data(self, user_id: int) -> str:
        """Export user data to temporary file."""
        
        with temporary_file_manager(f"user_export_{user_id}.json") as temp_file:
            # Write user data to temporary file
            with open(temp_file, 'w') as f:
                f.write('{"user_id": ' + str(user_id) + ', "data": "exported"}')
            
            # Process the file
            with open(temp_file, 'r') as f:
                content = f.read()
                
            return content

# ✅ Advanced Usage Demonstration
def demonstrate_advanced_patterns():
    """Demonstrate advanced context managers and decorators in action."""
    
    # Setup logging
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
    
    # Create API service
    api = APIService("postgresql://localhost/testdb")
    
    # Test with valid data
    try:
        result = api.update_user_profile(123, {"name": "John Doe", "email": "john@example.com"})
        print(f"Update successful: {result}")
    except Exception as e:
        print(f"Update failed: {e}")
    
    # Test with invalid data (type validation)
    try:
        result = api.update_user_profile("invalid_id", {"name": "Jane Doe"})
    except TypeError as e:
        print(f"Type validation caught error: {e}")
    
    # Test file export
    try:
        exported_data = api.export_user_data(456)
        print(f"Exported data: {exported_data}")
    except Exception as e:
        print(f"Export failed: {e}")

if __name__ == "__main__":
    demonstrate_advanced_patterns()
```

### Key Takeaways (2 minutes)

#### **🎯 Context Manager Mastery**

**Resource Safety**: Automatic cleanup with `__enter__`/`__exit__` protocol ensures proper resource management

**Exception Handling**: Context managers handle cleanup even when exceptions occur

**Production Patterns**: Database connections, file management, and timing contexts

#### **⚡ Advanced Decorator Features**

- **Metadata Preservation**: functools.wraps maintains function introspection
- **Configurable Behavior**: Decorator factories enable flexible behavior modification
- **Performance Monitoring**: Built-in timing and memory tracking for production debugging
- **Type Validation**: Runtime type checking with detailed error messages

**🎉 Next**: Part 2 covers Metaclasses & Descriptors for advanced object behavior control! 🚀
