# 03_Python-Advanced-Async-Concurrency-Part3

**Learning Level**: Advanced  
**Prerequisites**: Async/await basics, threading concepts, metaclasses & descriptors (Part 2)  
**Estimated Time**: Part 3 of 6 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master advanced asyncio patterns for high-performance concurrent applications
- Implement custom async context managers and iterators for resource management
- Design thread-safe async patterns with proper synchronization primitives
- Build production-ready async frameworks with error handling and monitoring

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

**Asyncio Patterns** enable high-concurrency I/O operations without blocking threads. **Advanced async patterns** include custom async context managers, async iterators, and sophisticated error handling. **Thread Safety** becomes critical when mixing async and sync code in production systems.

**Key Concepts**:

- **Async Context Managers**: `__aenter__` and `__aexit__` for async resource management
- **Async Iterators**: `__aiter__` and `__anext__` for streaming data processing
- **Semaphores & Locks**: Control concurrent access to shared resources
- **Exception Propagation**: Proper error handling in concurrent environments

### Core Implementation (6 minutes)

```python
# ✅ Advanced Async Context Manager Implementation
import asyncio
import aiohttp
import logging
import time
import weakref
from contextlib import asynccontextmanager
from dataclasses import dataclass
from typing import Any, AsyncGenerator, AsyncIterator, Dict, List, Optional, Union
import json
import random

class AsyncDatabasePool:
    """Production-ready async database connection pool with health monitoring."""
    
    def __init__(self, connection_string: str, max_connections: int = 10, 
                 health_check_interval: float = 30.0):
        self.connection_string = connection_string
        self.max_connections = max_connections
        self.health_check_interval = health_check_interval
        
        self._pool: List['AsyncConnection'] = []
        self._available: asyncio.Queue = asyncio.Queue(maxsize=max_connections)
        self._semaphore = asyncio.Semaphore(max_connections)
        self._lock = asyncio.Lock()
        self._health_task: Optional[asyncio.Task] = None
        self._closed = False
        
        self.logger = logging.getLogger(__name__)
    
    async def __aenter__(self) -> 'AsyncDatabasePool':
        """Initialize connection pool and start health monitoring."""
        await self._initialize_pool()
        self._health_task = asyncio.create_task(self._health_monitor())
        self.logger.info(f"Database pool initialized with {self.max_connections} connections")
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Cleanup pool and cancel health monitoring."""
        self._closed = True
        
        if self._health_task:
            self._health_task.cancel()
            try:
                await self._health_task
            except asyncio.CancelledError:
                pass
        
        async with self._lock:
            for connection in self._pool:
                await connection.close()
            self._pool.clear()
        
        self.logger.info("Database pool closed")
        return False
    
    async def _initialize_pool(self):
        """Create initial connection pool."""
        for _ in range(self.max_connections):
            connection = AsyncConnection(self.connection_string)
            await connection.connect()
            self._pool.append(connection)
            await self._available.put(connection)
    
    async def _health_monitor(self):
        """Monitor connection health and replace failed connections."""
        while not self._closed:
            try:
                await asyncio.sleep(self.health_check_interval)
                
                async with self._lock:
                    for i, connection in enumerate(self._pool):
                        if not await connection.is_healthy():
                            self.logger.warning(f"Replacing unhealthy connection {i}")
                            await connection.close()
                            
                            # Create replacement connection
                            new_connection = AsyncConnection(self.connection_string)
                            await new_connection.connect()
                            self._pool[i] = new_connection
                            
            except asyncio.CancelledError:
                break
            except Exception as e:
                self.logger.error(f"Health monitor error: {e}")
    
    @asynccontextmanager
    async def get_connection(self) -> AsyncGenerator['AsyncConnection', None]:
        """Get connection from pool with automatic return."""
        async with self._semaphore:
            connection = await self._available.get()
            try:
                yield connection
            finally:
                await self._available.put(connection)

class AsyncConnection:
    """Mock async database connection with health checking."""
    
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
        self._connected = False
        self._last_activity = time.time()
    
    async def connect(self):
        """Establish database connection."""
        await asyncio.sleep(0.01)  # Simulate connection time
        self._connected = True
        self._last_activity = time.time()
    
    async def close(self):
        """Close database connection."""
        self._connected = False
    
    async def is_healthy(self) -> bool:
        """Check connection health."""
        if not self._connected:
            return False
        
        # Simulate health check
        await asyncio.sleep(0.001)
        
        # Consider connection unhealthy if no activity for 5 minutes
        return time.time() - self._last_activity < 300
    
    async def execute(self, query: str, params: tuple = ()) -> Dict[str, Any]:
        """Execute database query."""
        if not self._connected:
            raise RuntimeError("Connection not established")
        
        self._last_activity = time.time()
        await asyncio.sleep(0.01)  # Simulate query execution
        
        return {"affected_rows": 1, "result": "success"}

# ✅ Advanced Async Iterator Implementation
class AsyncDataStream:
    """Async iterator for streaming data processing with backpressure control."""
    
    def __init__(self, data_source: str, batch_size: int = 100, 
                 max_buffer_size: int = 1000):
        self.data_source = data_source
        self.batch_size = batch_size
        self.max_buffer_size = max_buffer_size
        
        self._buffer: asyncio.Queue = asyncio.Queue(maxsize=max_buffer_size)
        self._producer_task: Optional[asyncio.Task] = None
        self._finished = False
        self._error: Optional[Exception] = None
        
        self.logger = logging.getLogger(__name__)
    
    def __aiter__(self) -> AsyncIterator[Dict[str, Any]]:
        """Return async iterator interface."""
        return self
    
    async def __anext__(self) -> Dict[str, Any]:
        """Get next item from stream."""
        if self._producer_task is None:
            self._producer_task = asyncio.create_task(self._produce_data())
        
        try:
            # Wait for data with timeout to check for completion
            item = await asyncio.wait_for(self._buffer.get(), timeout=1.0)
            
            if item is StopAsyncIteration:
                raise StopAsyncIteration
            
            return item
            
        except asyncio.TimeoutError:
            # Check if producer finished or encountered error
            if self._finished:
                raise StopAsyncIteration
            
            if self._error:
                raise self._error
            
            # Continue waiting if producer is still running
            return await self.__anext__()
    
    async def _produce_data(self):
        """Background task to produce data and populate buffer."""
        try:
            for batch_num in range(10):  # Simulate 10 batches of data
                batch_data = []
                
                for item_num in range(self.batch_size):
                    # Simulate data generation
                    await asyncio.sleep(0.001)  # Simulate processing time
                    
                    item = {
                        'id': batch_num * self.batch_size + item_num,
                        'batch': batch_num,
                        'data': f'item_{item_num}',
                        'timestamp': time.time()
                    }
                    
                    batch_data.append(item)
                
                # Send batch items to buffer
                for item in batch_data:
                    await self._buffer.put(item)
                
                self.logger.debug(f"Produced batch {batch_num} with {len(batch_data)} items")
                
                # Simulate variable processing speed
                await asyncio.sleep(random.uniform(0.01, 0.05))
            
            # Signal completion
            await self._buffer.put(StopAsyncIteration)
            self._finished = True
            
        except Exception as e:
            self._error = e
            await self._buffer.put(StopAsyncIteration)
    
    async def close(self):
        """Clean up resources."""
        if self._producer_task and not self._producer_task.done():
            self._producer_task.cancel()
            try:
                await self._producer_task
            except asyncio.CancelledError:
                pass

# ✅ Async Rate Limiter with Token Bucket Algorithm
class AsyncRateLimiter:
    """Production-ready async rate limiter using token bucket algorithm."""
    
    def __init__(self, rate: float, burst_size: int = 1):
        """
        Initialize rate limiter.
        
        Args:
            rate: Tokens per second
            burst_size: Maximum burst capacity
        """
        self.rate = rate
        self.burst_size = burst_size
        self.tokens = burst_size
        self.last_update = time.time()
        self._lock = asyncio.Lock()
    
    async def acquire(self, tokens: int = 1) -> bool:
        """Acquire tokens from bucket, waiting if necessary."""
        async with self._lock:
            now = time.time()
            
            # Add tokens based on elapsed time
            elapsed = now - self.last_update
            self.tokens = min(self.burst_size, self.tokens + elapsed * self.rate)
            self.last_update = now
            
            if self.tokens >= tokens:
                self.tokens -= tokens
                return True
            
            # Calculate wait time for required tokens
            wait_time = (tokens - self.tokens) / self.rate
        
        # Wait outside of lock to allow other coroutines
        await asyncio.sleep(wait_time)
        return await self.acquire(tokens)
    
    @asynccontextmanager
    async def limit(self, tokens: int = 1):
        """Context manager interface for rate limiting."""
        await self.acquire(tokens)
        yield

# ✅ Advanced Async HTTP Client with Circuit Breaker
@dataclass
class CircuitBreakerConfig:
    failure_threshold: int = 5
    recovery_timeout: float = 60.0
    expected_exception: type = Exception

class AsyncHTTPClient:
    """HTTP client with circuit breaker pattern and connection pooling."""
    
    def __init__(self, base_url: str, circuit_config: CircuitBreakerConfig = None):
        self.base_url = base_url
        self.circuit_config = circuit_config or CircuitBreakerConfig()
        
        # Circuit breaker state
        self._failure_count = 0
        self._last_failure_time = 0
        self._state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN
        
        self._session: Optional[aiohttp.ClientSession] = None
        self._lock = asyncio.Lock()
        self.logger = logging.getLogger(__name__)
    
    async def __aenter__(self) -> 'AsyncHTTPClient':
        """Initialize HTTP session."""
        connector = aiohttp.TCPConnector(
            limit=100,  # Connection pool size
            limit_per_host=30,
            keepalive_timeout=30
        )
        
        self._session = aiohttp.ClientSession(
            connector=connector,
            timeout=aiohttp.ClientTimeout(total=30)
        )
        
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Clean up HTTP session."""
        if self._session:
            await self._session.close()
        return False
    
    async def get(self, endpoint: str, **kwargs) -> Dict[str, Any]:
        """GET request with circuit breaker protection."""
        return await self._make_request("GET", endpoint, **kwargs)
    
    async def post(self, endpoint: str, json_data: Dict = None, **kwargs) -> Dict[str, Any]:
        """POST request with circuit breaker protection."""
        return await self._make_request("POST", endpoint, json=json_data, **kwargs)
    
    async def _make_request(self, method: str, endpoint: str, **kwargs) -> Dict[str, Any]:
        """Make HTTP request with circuit breaker logic."""
        async with self._lock:
            if self._state == "OPEN":
                if time.time() - self._last_failure_time > self.circuit_config.recovery_timeout:
                    self._state = "HALF_OPEN"
                    self.logger.info("Circuit breaker moved to HALF_OPEN state")
                else:
                    raise RuntimeError("Circuit breaker is OPEN - requests blocked")
        
        url = f"{self.base_url.rstrip('/')}/{endpoint.lstrip('/')}"
        
        try:
            async with self._session.request(method, url, **kwargs) as response:
                response.raise_for_status()
                
                # Success - reset failure count if in HALF_OPEN
                async with self._lock:
                    if self._state == "HALF_OPEN":
                        self._state = "CLOSED"
                        self._failure_count = 0
                        self.logger.info("Circuit breaker CLOSED - service recovered")
                
                if response.content_type == 'application/json':
                    return await response.json()
                else:
                    return {"text": await response.text(), "status": response.status}
                
        except self.circuit_config.expected_exception as e:
            async with self._lock:
                self._failure_count += 1
                self._last_failure_time = time.time()
                
                if self._failure_count >= self.circuit_config.failure_threshold:
                    self._state = "OPEN"
                    self.logger.error(f"Circuit breaker OPENED due to {self._failure_count} failures")
            
            raise

# ✅ Production Usage Examples
class AsyncDataProcessor:
    """Example service demonstrating advanced async patterns."""
    
    def __init__(self, api_base_url: str):
        self.api_base_url = api_base_url
        self.rate_limiter = AsyncRateLimiter(rate=10.0, burst_size=5)  # 10 requests/second
        self.logger = logging.getLogger(__name__)
    
    async def process_data_stream(self) -> List[Dict[str, Any]]:
        """Process streaming data with rate limiting and database operations."""
        
        results = []
        
        async with AsyncDatabasePool("postgresql://localhost/testdb") as db_pool:
            async with AsyncHTTPClient(self.api_base_url) as http_client:
                
                stream = AsyncDataStream("data_source_1")
                
                try:
                    async for item in stream:
                        # Rate limit API calls
                        async with self.rate_limiter.limit():
                            # Enrich data with API call
                            try:
                                api_data = await http_client.get(f"/enrich/{item['id']}")
                                item['enriched'] = api_data
                            except Exception as e:
                                self.logger.warning(f"API enrichment failed for {item['id']}: {e}")
                                item['enriched'] = None
                        
                        # Store in database
                        async with db_pool.get_connection() as conn:
                            await conn.execute(
                                "INSERT INTO processed_items (id, data) VALUES (?, ?)",
                                (item['id'], json.dumps(item))
                            )
                        
                        results.append(item)
                        
                        # Log progress
                        if item['id'] % 100 == 0:
                            self.logger.info(f"Processed {item['id']} items")
                
                finally:
                    await stream.close()
        
        return results
    
    async def concurrent_batch_processing(self, batch_size: int = 10) -> Dict[str, Any]:
        """Process multiple batches concurrently with controlled parallelism."""
        
        semaphore = asyncio.Semaphore(batch_size)
        
        async def process_batch(batch_id: int) -> Dict[str, Any]:
            async with semaphore:
                # Simulate batch processing
                await asyncio.sleep(random.uniform(0.1, 0.5))
                
                return {
                    'batch_id': batch_id,
                    'items_processed': random.randint(50, 200),
                    'processing_time': random.uniform(0.1, 0.5)
                }
        
        # Create concurrent tasks
        tasks = [process_batch(i) for i in range(50)]
        
        # Wait for all batches to complete
        batch_results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Separate successful results from exceptions
        successful = [r for r in batch_results if not isinstance(r, Exception)]
        failed = [r for r in batch_results if isinstance(r, Exception)]
        
        return {
            'successful_batches': len(successful),
            'failed_batches': len(failed),
            'results': successful,
            'errors': failed
        }

# ✅ Advanced Usage Demonstration
async def demonstrate_async_patterns():
    """Demonstrate advanced async patterns in action."""
    
    # Setup logging
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
    
    # Create data processor
    processor = AsyncDataProcessor("https://jsonplaceholder.typicode.com")
    
    try:
        # Test streaming data processing
        print("Starting streaming data processing...")
        start_time = time.time()
        
        # Note: This would use real HTTP endpoints in production
        # results = await processor.process_data_stream()
        # print(f"Processed {len(results)} items in {time.time() - start_time:.2f}s")
        
        # Test concurrent batch processing
        print("Starting concurrent batch processing...")
        batch_start = time.time()
        
        batch_results = await processor.concurrent_batch_processing(batch_size=5)
        print(f"Batch processing completed in {time.time() - batch_start:.2f}s")
        print(f"Results: {batch_results}")
        
    except Exception as e:
        print(f"Processing error: {e}")

if __name__ == "__main__":
    asyncio.run(demonstrate_async_patterns())
```

### Key Takeaways (2 minutes)

#### **🎯 Async Context Manager Excellence**

**Resource Management**: Async context managers handle complex resource lifecycles with proper cleanup

**Connection Pooling**: Database pools with health monitoring and automatic connection replacement

**Error Handling**: Comprehensive exception propagation in async environments

#### **⚡ Advanced Concurrency Patterns**

- **Async Iterators**: Streaming data processing with backpressure control
- **Rate Limiting**: Token bucket algorithm for API request throttling
- **Circuit Breaker**: Fault tolerance for external service dependencies  
- **Controlled Parallelism**: Semaphores for managing concurrent operations

**🎉 Next**: Part 4 covers Performance Optimization & Memory Management! 🚀
