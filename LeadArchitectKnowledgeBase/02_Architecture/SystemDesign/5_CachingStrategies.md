# Chapter 5: Caching Strategies

## Overview

Caching is a fundamental technique used to improve system performance by storing frequently accessed data in a temporary storage layer that provides faster access than the original data source. This chapter explores various caching strategies, patterns, and implementation approaches to optimize system performance and reduce latency.

## Learning Objectives

By the end of this chapter, you will understand:

- Different types of caching and their use cases
- Cache invalidation strategies and cache coherence
- Popular caching patterns and when to apply them
- Implementation considerations and trade-offs
- Cache sizing, eviction policies, and performance optimization
- Distributed caching architectures

---

## 1. Types of Caching

### 1.1 Browser Caching

**Client-side caching** that stores static resources locally in the user's browser.

```html
<!-- Cache control headers -->
<meta http-equiv="Cache-Control" content="max-age=3600, must-revalidate">

<!-- Static resource caching -->
<link rel="stylesheet" href="styles.css?v=1.2.3">
<script src="app.js?v=1.2.3"></script>
```

**HTTP Cache Headers:**
```http
Cache-Control: public, max-age=31536000  # 1 year
ETag: "abc123"
Last-Modified: Wed, 21 Oct 2024 07:28:00 GMT
Expires: Thu, 21 Oct 2025 07:28:00 GMT
```

### 1.2 CDN Caching

**Edge caching** that stores content closer to users geographically.

```yaml
# CloudFront configuration example
Distribution:
  Origins:
    - DomainName: api.example.com
      Id: api-origin
      CustomOriginConfig:
        HTTPPort: 80
        HTTPSPort: 443
  DefaultCacheBehavior:
    TargetOriginId: api-origin
    ViewerProtocolPolicy: redirect-to-https
    CachePolicyId: 4135ea2d-6df8-44a3-9df3-4b5a84be39ad  # Managed-CachingOptimized
    TTL:
      DefaultTTL: 86400  # 24 hours
      MaxTTL: 31536000   # 1 year
```

### 1.3 Reverse Proxy Caching

**Server-side caching** at the web server or load balancer level.

```nginx
# Nginx caching configuration
http {
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=10g 
                     inactive=60m use_temp_path=off;
    
    server {
        location /api/ {
            proxy_cache my_cache;
            proxy_cache_valid 200 302 10m;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout invalid_header updating;
            proxy_cache_lock on;
            
            proxy_pass http://backend;
        }
    }
}
```

### 1.4 Application-Level Caching

**In-memory caching** within the application process.

```python
# Python with Redis
import redis
import json
from functools import wraps

redis_client = redis.Redis(host='localhost', port=6379, db=0)

def cache_result(expiration=3600):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Create cache key
            cache_key = f"{func.__name__}:{hash(str(args) + str(kwargs))}"
            
            # Try to get from cache
            cached_result = redis_client.get(cache_key)
            if cached_result:
                return json.loads(cached_result)
            
            # Execute function and cache result
            result = func(*args, **kwargs)
            redis_client.setex(cache_key, expiration, json.dumps(result))
            return result
        return wrapper
    return decorator

@cache_result(expiration=1800)
def get_user_profile(user_id):
    # Expensive database operation
    return fetch_user_from_database(user_id)
```

### 1.5 Database Caching

**Query result caching** and **connection pooling**.

```python
# SQLAlchemy with query caching
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dogpile.cache import make_region

# Configure cache region
cache_region = make_region().configure(
    'dogpile.cache.redis',
    arguments={
        'host': 'localhost',
        'port': 6379,
        'db': 0,
        'redis_expiration_time': 60*60*2,  # 2 hours
        'distributed_lock': True
    }
)

class UserRepository:
    def __init__(self, session):
        self.session = session
    
    @cache_region.cache_on_arguments()
    def get_user_by_id(self, user_id):
        return self.session.query(User).filter(User.id == user_id).first()
    
    @cache_region.cache_on_arguments()
    def get_users_by_department(self, department_id):
        return self.session.query(User).filter(
            User.department_id == department_id
        ).all()
```

---

## 2. Caching Patterns

### 2.1 Cache-Aside (Lazy Loading)

Application manages cache explicitly.

```python
class CacheAsideExample:
    def __init__(self, cache, database):
        self.cache = cache
        self.database = database
    
    def get_user(self, user_id):
        # Try cache first
        user = self.cache.get(f"user:{user_id}")
        if user:
            return user
        
        # Cache miss - fetch from database
        user = self.database.get_user(user_id)
        if user:
            # Store in cache with TTL
            self.cache.setex(f"user:{user_id}", 3600, json.dumps(user))
        
        return user
    
    def update_user(self, user_id, user_data):
        # Update database
        updated_user = self.database.update_user(user_id, user_data)
        
        # Invalidate cache
        self.cache.delete(f"user:{user_id}")
        
        return updated_user
```

### 2.2 Write-Through

Data is written to cache and database simultaneously.

```python
class WriteThroughCache:
    def __init__(self, cache, database):
        self.cache = cache
        self.database = database
    
    def save_user(self, user_id, user_data):
        # Write to database first
        saved_user = self.database.save_user(user_id, user_data)
        
        # Write to cache
        self.cache.setex(f"user:{user_id}", 3600, json.dumps(saved_user))
        
        return saved_user
    
    def get_user(self, user_id):
        # Try cache first
        user = self.cache.get(f"user:{user_id}")
        if user:
            return json.loads(user)
        
        # Cache miss - fetch from database and cache
        user = self.database.get_user(user_id)
        if user:
            self.cache.setex(f"user:{user_id}", 3600, json.dumps(user))
        
        return user
```

### 2.3 Write-Behind (Write-Back)

Data is written to cache immediately and to database asynchronously.

```python
import asyncio
from collections import defaultdict
import time

class WriteBehindCache:
    def __init__(self, cache, database, batch_size=100, flush_interval=30):
        self.cache = cache
        self.database = database
        self.batch_size = batch_size
        self.flush_interval = flush_interval
        self.write_buffer = defaultdict(dict)
        self.last_flush = time.time()
        
        # Start background flush task
        asyncio.create_task(self._background_flush())
    
    async def save_user(self, user_id, user_data):
        # Write to cache immediately
        self.cache.setex(f"user:{user_id}", 3600, json.dumps(user_data))
        
        # Add to write buffer
        self.write_buffer['users'][user_id] = user_data
        
        # Check if we need to flush
        if (len(self.write_buffer['users']) >= self.batch_size or 
            time.time() - self.last_flush > self.flush_interval):
            await self._flush_to_database()
    
    async def _flush_to_database(self):
        if not self.write_buffer['users']:
            return
        
        # Batch write to database
        users_to_write = dict(self.write_buffer['users'])
        self.write_buffer['users'].clear()
        self.last_flush = time.time()
        
        try:
            await self.database.batch_save_users(users_to_write)
        except Exception as e:
            # Re-queue failed writes
            self.write_buffer['users'].update(users_to_write)
            raise e
    
    async def _background_flush(self):
        while True:
            await asyncio.sleep(self.flush_interval)
            await self._flush_to_database()
```

### 2.4 Refresh-Ahead

Cache is refreshed before expiration to avoid cache misses.

```python
import threading
import time
from concurrent.futures import ThreadPoolExecutor

class RefreshAheadCache:
    def __init__(self, cache, database, refresh_threshold=0.8):
        self.cache = cache
        self.database = database
        self.refresh_threshold = refresh_threshold
        self.executor = ThreadPoolExecutor(max_workers=5)
        self.refreshing = set()
    
    def get_user(self, user_id):
        cache_key = f"user:{user_id}"
        
        # Get from cache with TTL info
        cached_data = self.cache.get_with_ttl(cache_key)
        
        if cached_data:
            data, ttl = cached_data
            total_ttl = 3600  # Original TTL
            
            # Check if we need to refresh
            if ttl < total_ttl * self.refresh_threshold:
                self._schedule_refresh(user_id, cache_key)
            
            return json.loads(data)
        
        # Cache miss - fetch immediately
        return self._fetch_and_cache(user_id, cache_key)
    
    def _schedule_refresh(self, user_id, cache_key):
        if cache_key not in self.refreshing:
            self.refreshing.add(cache_key)
            self.executor.submit(self._refresh_cache, user_id, cache_key)
    
    def _refresh_cache(self, user_id, cache_key):
        try:
            user = self.database.get_user(user_id)
            if user:
                self.cache.setex(cache_key, 3600, json.dumps(user))
        finally:
            self.refreshing.discard(cache_key)
    
    def _fetch_and_cache(self, user_id, cache_key):
        user = self.database.get_user(user_id)
        if user:
            self.cache.setex(cache_key, 3600, json.dumps(user))
        return user
```

---

## 3. Cache Invalidation Strategies

### 3.1 Time-Based Expiration (TTL)

```python
# Redis TTL examples
redis_client.setex("user:123", 3600, json.dumps(user_data))  # 1 hour
redis_client.expire("session:abc", 1800)  # 30 minutes

# Different TTL for different data types
CACHE_TTLS = {
    'user_profile': 3600,      # 1 hour
    'user_preferences': 86400,  # 24 hours
    'session_data': 1800,      # 30 minutes
    'product_catalog': 43200,   # 12 hours
    'real_time_data': 60       # 1 minute
}
```

### 3.2 Event-Based Invalidation

```python
# Event-driven cache invalidation
class EventDrivenCache:
    def __init__(self, cache, event_bus):
        self.cache = cache
        self.event_bus = event_bus
        self._setup_event_listeners()
    
    def _setup_event_listeners(self):
        self.event_bus.subscribe('user.updated', self._handle_user_updated)
        self.event_bus.subscribe('user.deleted', self._handle_user_deleted)
        self.event_bus.subscribe('product.updated', self._handle_product_updated)
    
    def _handle_user_updated(self, event):
        user_id = event['user_id']
        # Invalidate user-related cache entries
        cache_keys = [
            f"user:{user_id}",
            f"user_profile:{user_id}",
            f"user_recommendations:{user_id}"
        ]
        self.cache.delete(*cache_keys)
    
    def _handle_user_deleted(self, event):
        user_id = event['user_id']
        # Remove all user-related data
        pattern = f"*user*{user_id}*"
        keys = self.cache.keys(pattern)
        if keys:
            self.cache.delete(*keys)
    
    def _handle_product_updated(self, event):
        product_id = event['product_id']
        # Invalidate product and related caches
        self.cache.delete(f"product:{product_id}")
        self.cache.delete("product_catalog")  # Invalidate catalog cache
```

### 3.3 Cache Tags and Dependencies

```python
class TaggedCache:
    def __init__(self, cache):
        self.cache = cache
        self.tag_keys = defaultdict(set)
    
    def set_with_tags(self, key, value, ttl, tags=None):
        # Store the value
        self.cache.setex(key, ttl, value)
        
        # Associate with tags
        if tags:
            for tag in tags:
                self.tag_keys[tag].add(key)
                # Store tag associations in Redis
                self.cache.sadd(f"tag:{tag}", key)
    
    def invalidate_by_tag(self, tag):
        # Get all keys with this tag
        keys = self.cache.smembers(f"tag:{tag}")
        
        if keys:
            # Delete the actual cached values
            self.cache.delete(*keys)
            
            # Clean up tag associations
            for key in keys:
                self._remove_key_from_all_tags(key)
            
            # Delete the tag set
            self.cache.delete(f"tag:{tag}")
    
    def _remove_key_from_all_tags(self, key):
        # Scan for all tag sets that contain this key
        for tag_key in self.cache.scan_iter(match="tag:*"):
            self.cache.srem(tag_key, key)

# Usage example
tagged_cache = TaggedCache(redis_client)

# Cache user data with tags
tagged_cache.set_with_tags(
    "user:123", 
    json.dumps(user_data), 
    3600, 
    tags=["user", "department:engineering"]
)

# Invalidate all engineering department data
tagged_cache.invalidate_by_tag("department:engineering")
```

---

## 4. Distributed Caching

### 4.1 Consistent Hashing

```python
import hashlib
import bisect

class ConsistentHashRing:
    def __init__(self, nodes=None, replicas=3):
        self.replicas = replicas
        self.ring = {}
        self.sorted_keys = []
        
        if nodes:
            for node in nodes:
                self.add_node(node)
    
    def _hash(self, key):
        return int(hashlib.md5(key.encode('utf-8')).hexdigest(), 16)
    
    def add_node(self, node):
        for i in range(self.replicas):
            virtual_key = self._hash(f"{node}:{i}")
            self.ring[virtual_key] = node
            bisect.insort(self.sorted_keys, virtual_key)
    
    def remove_node(self, node):
        for i in range(self.replicas):
            virtual_key = self._hash(f"{node}:{i}")
            if virtual_key in self.ring:
                del self.ring[virtual_key]
                self.sorted_keys.remove(virtual_key)
    
    def get_node(self, key):
        if not self.ring:
            return None
        
        hash_key = self._hash(key)
        idx = bisect.bisect_right(self.sorted_keys, hash_key)
        
        if idx == len(self.sorted_keys):
            idx = 0
        
        return self.ring[self.sorted_keys[idx]]

class DistributedCache:
    def __init__(self, cache_nodes):
        self.hash_ring = ConsistentHashRing(cache_nodes.keys())
        self.cache_clients = cache_nodes
    
    def get(self, key):
        node = self.hash_ring.get_node(key)
        if node:
            return self.cache_clients[node].get(key)
        return None
    
    def set(self, key, value, ttl=3600):
        node = self.hash_ring.get_node(key)
        if node:
            return self.cache_clients[node].setex(key, ttl, value)
        return False
    
    def delete(self, key):
        node = self.hash_ring.get_node(key)
        if node:
            return self.cache_clients[node].delete(key)
        return False
```

### 4.2 Cache Replication

```python
class ReplicatedCache:
    def __init__(self, primary_cache, replica_caches, replication_factor=2):
        self.primary = primary_cache
        self.replicas = replica_caches
        self.replication_factor = min(replication_factor, len(replica_caches))
    
    def set(self, key, value, ttl=3600):
        # Write to primary
        success = self.primary.setex(key, ttl, value)
        
        if success:
            # Replicate to secondary caches
            replicated = 0
            for replica in self.replicas[:self.replication_factor]:
                try:
                    replica.setex(key, ttl, value)
                    replicated += 1
                except Exception as e:
                    print(f"Replication failed for {replica}: {e}")
            
            # Consider successful if we replicated to at least one replica
            return replicated > 0
        
        return False
    
    def get(self, key):
        # Try primary first
        try:
            value = self.primary.get(key)
            if value:
                return value
        except Exception:
            pass
        
        # Fallback to replicas
        for replica in self.replicas:
            try:
                value = replica.get(key)
                if value:
                    # Repair primary cache
                    try:
                        self.primary.setex(key, 3600, value)
                    except Exception:
                        pass
                    return value
            except Exception:
                continue
        
        return None
```

---

## 5. Cache Performance Optimization

### 5.1 Cache Sizing and Memory Management

```python
class CacheManager:
    def __init__(self, max_memory_mb=1024):
        self.max_memory = max_memory_mb * 1024 * 1024  # Convert to bytes
        self.cache = {}
        self.access_times = {}
        self.memory_usage = 0
    
    def _estimate_size(self, obj):
        """Estimate memory usage of an object"""
        import sys
        return sys.getsizeof(obj)
    
    def _evict_lru(self):
        """Evict least recently used items"""
        if not self.access_times:
            return
        
        # Sort by access time
        sorted_items = sorted(self.access_times.items(), key=lambda x: x[1])
        
        # Remove oldest 25% of items
        to_remove = len(sorted_items) // 4
        for key, _ in sorted_items[:to_remove]:
            self._remove_item(key)
    
    def _remove_item(self, key):
        if key in self.cache:
            self.memory_usage -= self._estimate_size(self.cache[key])
            del self.cache[key]
            del self.access_times[key]
    
    def set(self, key, value):
        size = self._estimate_size(value)
        
        # Check if we need to evict
        while self.memory_usage + size > self.max_memory and self.cache:
            self._evict_lru()
        
        # Remove existing item if updating
        if key in self.cache:
            self._remove_item(key)
        
        # Add new item
        self.cache[key] = value
        self.access_times[key] = time.time()
        self.memory_usage += size
    
    def get(self, key):
        if key in self.cache:
            self.access_times[key] = time.time()
            return self.cache[key]
        return None
```

### 5.2 Cache Warming Strategies

```python
class CacheWarmer:
    def __init__(self, cache, data_source):
        self.cache = cache
        self.data_source = data_source
    
    async def warm_popular_data(self):
        """Pre-load frequently accessed data"""
        # Get popular products
        popular_products = await self.data_source.get_popular_products(limit=1000)
        
        # Cache in batches
        batch_size = 50
        for i in range(0, len(popular_products), batch_size):
            batch = popular_products[i:i + batch_size]
            await self._cache_product_batch(batch)
    
    async def warm_user_data(self, user_ids):
        """Pre-load user data for active users"""
        for user_id in user_ids:
            user = await self.data_source.get_user(user_id)
            if user:
                self.cache.setex(f"user:{user_id}", 3600, json.dumps(user))
    
    async def warm_from_access_logs(self, log_file):
        """Warm cache based on access patterns"""
        access_patterns = self._analyze_access_patterns(log_file)
        
        for pattern in access_patterns:
            if pattern['frequency'] > 10:  # Threshold for caching
                data = await self.data_source.get_data(pattern['key'])
                if data:
                    ttl = min(3600, pattern['frequency'] * 60)  # Dynamic TTL
                    self.cache.setex(pattern['key'], ttl, json.dumps(data))
    
    def _analyze_access_patterns(self, log_file):
        # Analyze log file to find patterns
        patterns = defaultdict(int)
        
        with open(log_file, 'r') as f:
            for line in f:
                # Extract key from log line (implementation specific)
                key = self._extract_key_from_log(line)
                if key:
                    patterns[key] += 1
        
        return [{'key': k, 'frequency': v} for k, v in patterns.items()]
```

---

## 6. Cache Monitoring and Metrics

### 6.1 Cache Performance Metrics

```python
import time
from collections import defaultdict, deque
from threading import Lock

class CacheMetrics:
    def __init__(self, window_size=3600):  # 1 hour window
        self.window_size = window_size
        self.hits = deque()
        self.misses = deque()
        self.response_times = deque()
        self.lock = Lock()
    
    def record_hit(self, response_time):
        with self.lock:
            current_time = time.time()
            self.hits.append(current_time)
            self.response_times.append(response_time)
            self._cleanup_old_entries(current_time)
    
    def record_miss(self, response_time):
        with self.lock:
            current_time = time.time()
            self.misses.append(current_time)
            self.response_times.append(response_time)
            self._cleanup_old_entries(current_time)
    
    def _cleanup_old_entries(self, current_time):
        cutoff = current_time - self.window_size
        
        while self.hits and self.hits[0] < cutoff:
            self.hits.popleft()
        
        while self.misses and self.misses[0] < cutoff:
            self.misses.popleft()
        
        while self.response_times and len(self.response_times) > 1000:
            self.response_times.popleft()
    
    def get_hit_rate(self):
        with self.lock:
            total_requests = len(self.hits) + len(self.misses)
            if total_requests == 0:
                return 0
            return len(self.hits) / total_requests
    
    def get_average_response_time(self):
        with self.lock:
            if not self.response_times:
                return 0
            return sum(self.response_times) / len(self.response_times)
    
    def get_metrics(self):
        return {
            'hit_rate': self.get_hit_rate(),
            'total_hits': len(self.hits),
            'total_misses': len(self.misses),
            'avg_response_time': self.get_average_response_time(),
            'requests_per_second': (len(self.hits) + len(self.misses)) / self.window_size
        }

class MonitoredCache:
    def __init__(self, cache, metrics=None):
        self.cache = cache
        self.metrics = metrics or CacheMetrics()
    
    def get(self, key):
        start_time = time.time()
        value = self.cache.get(key)
        response_time = time.time() - start_time
        
        if value is not None:
            self.metrics.record_hit(response_time)
        else:
            self.metrics.record_miss(response_time)
        
        return value
    
    def set(self, key, value, ttl=3600):
        return self.cache.setex(key, ttl, value)
    
    def get_stats(self):
        return self.metrics.get_metrics()
```

### 6.2 Cache Health Monitoring

```python
class CacheHealthMonitor:
    def __init__(self, cache, alert_thresholds=None):
        self.cache = cache
        self.thresholds = alert_thresholds or {
            'hit_rate_min': 0.8,
            'response_time_max': 0.1,  # 100ms
            'memory_usage_max': 0.9,
            'error_rate_max': 0.01
        }
        self.alerts = []
    
    def check_health(self):
        health_status = {
            'status': 'healthy',
            'checks': {},
            'alerts': []
        }
        
        # Check hit rate
        hit_rate = self._get_hit_rate()
        health_status['checks']['hit_rate'] = {
            'value': hit_rate,
            'status': 'pass' if hit_rate >= self.thresholds['hit_rate_min'] else 'fail'
        }
        
        if hit_rate < self.thresholds['hit_rate_min']:
            alert = f"Cache hit rate below threshold: {hit_rate:.2%}"
            health_status['alerts'].append(alert)
            health_status['status'] = 'degraded'
        
        # Check response time
        avg_response_time = self._get_average_response_time()
        health_status['checks']['response_time'] = {
            'value': avg_response_time,
            'status': 'pass' if avg_response_time <= self.thresholds['response_time_max'] else 'fail'
        }
        
        if avg_response_time > self.thresholds['response_time_max']:
            alert = f"Cache response time above threshold: {avg_response_time:.3f}s"
            health_status['alerts'].append(alert)
            health_status['status'] = 'degraded'
        
        # Check memory usage
        memory_usage = self._get_memory_usage()
        health_status['checks']['memory_usage'] = {
            'value': memory_usage,
            'status': 'pass' if memory_usage <= self.thresholds['memory_usage_max'] else 'fail'
        }
        
        if memory_usage > self.thresholds['memory_usage_max']:
            alert = f"Cache memory usage above threshold: {memory_usage:.1%}"
            health_status['alerts'].append(alert)
            health_status['status'] = 'critical'
        
        return health_status
    
    def _get_hit_rate(self):
        # Implementation depends on cache type
        info = self.cache.info()
        hits = info.get('keyspace_hits', 0)
        misses = info.get('keyspace_misses', 0)
        total = hits + misses
        return hits / total if total > 0 else 0
    
    def _get_average_response_time(self):
        # This would typically come from application metrics
        return 0.05  # Placeholder
    
    def _get_memory_usage(self):
        info = self.cache.info()
        used_memory = info.get('used_memory', 0)
        max_memory = info.get('maxmemory', 1)
        return used_memory / max_memory if max_memory > 0 else 0
```

---

## 7. Tools and Technologies

### Popular Caching Solutions

1. **Redis**
   - In-memory data structure store
   - Supports various data types (strings, hashes, lists, sets)
   - Persistence options (RDB, AOF)
   - Clustering and replication support

2. **Memcached**
   - High-performance distributed memory caching system
   - Simple key-value store
   - Multi-threaded architecture
   - Good for simple caching scenarios

3. **Apache Ignite**
   - In-memory computing platform
   - Distributed caching with SQL support
   - Machine learning capabilities
   - Persistent storage options

4. **Hazelcast**
   - In-memory data grid
   - Distributed caching and computing
   - Built-in data structures
   - Event-driven architecture

### Application-Level Libraries

```python
# Python caching libraries
from functools import lru_cache
from cachetools import TTLCache, cached
import diskcache

# Built-in LRU cache
@lru_cache(maxsize=128)
def expensive_function(arg):
    return perform_expensive_operation(arg)

# TTL cache with cachetools
cache = TTLCache(maxsize=100, ttl=300)  # 5 minutes

@cached(cache)
def get_user_data(user_id):
    return fetch_user_from_database(user_id)

# Disk-based cache
disk_cache = diskcache.Cache('/tmp/cache')

@disk_cache.memoize(expire=3600)
def process_large_dataset(data_path):
    return expensive_data_processing(data_path)
```

---

## 8. Best Practices

### 8.1 Cache Key Design

```python
# Good cache key patterns
class CacheKeyBuilder:
    @staticmethod
    def user_profile(user_id):
        return f"user:profile:{user_id}"
    
    @staticmethod
    def user_permissions(user_id, resource_type):
        return f"user:permissions:{user_id}:{resource_type}"
    
    @staticmethod
    def search_results(query, page, filters):
        filter_hash = hashlib.md5(str(sorted(filters.items())).encode()).hexdigest()[:8]
        return f"search:{hashlib.md5(query.encode()).hexdigest()[:8]}:p{page}:{filter_hash}"
    
    @staticmethod
    def api_response(endpoint, params):
        param_hash = hashlib.md5(str(sorted(params.items())).encode()).hexdigest()[:8]
        return f"api:{endpoint.replace('/', ':')}:{param_hash}"
```

### 8.2 Cache Configuration

```yaml
# Redis configuration example
redis_config:
  # Memory management
  maxmemory: 2gb
  maxmemory-policy: allkeys-lru
  
  # Persistence
  save: "900 1 300 10 60 10000"  # RDB snapshots
  appendonly: yes                 # AOF logging
  appendfsync: everysec
  
  # Networking
  timeout: 300
  tcp-keepalive: 300
  
  # Performance
  tcp-backlog: 511
  databases: 16
  
  # Security
  requirepass: "your_password_here"
  rename-command: FLUSHALL ""     # Disable dangerous commands
```

### 8.3 Error Handling

```python
class ResilientCache:
    def __init__(self, primary_cache, fallback_cache=None):
        self.primary = primary_cache
        self.fallback = fallback_cache
        self.circuit_breaker = CircuitBreaker()
    
    def get(self, key):
        if self.circuit_breaker.is_open():
            return self._get_fallback(key)
        
        try:
            value = self.primary.get(key)
            self.circuit_breaker.record_success()
            return value
        except Exception as e:
            self.circuit_breaker.record_failure()
            return self._get_fallback(key)
    
    def set(self, key, value, ttl=3600):
        if self.circuit_breaker.is_open():
            return self._set_fallback(key, value, ttl)
        
        try:
            result = self.primary.setex(key, ttl, value)
            self.circuit_breaker.record_success()
            return result
        except Exception as e:
            self.circuit_breaker.record_failure()
            return self._set_fallback(key, value, ttl)
    
    def _get_fallback(self, key):
        if self.fallback:
            try:
                return self.fallback.get(key)
            except Exception:
                pass
        return None
    
    def _set_fallback(self, key, value, ttl):
        if self.fallback:
            try:
                return self.fallback.setex(key, ttl, value)
            except Exception:
                pass
        return False

class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = 'closed'  # closed, open, half-open
    
    def is_open(self):
        if self.state == 'open':
            if time.time() - self.last_failure_time > self.recovery_timeout:
                self.state = 'half-open'
                return False
            return True
        return False
    
    def record_success(self):
        self.failure_count = 0
        self.state = 'closed'
    
    def record_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = 'open'
```

---

## Key Takeaways

### Critical Concepts

1. **Cache Layers**: Implement multiple cache layers (browser, CDN, application, database) for optimal performance
2. **Cache Patterns**: Choose appropriate patterns (cache-aside, write-through, write-behind) based on consistency requirements
3. **Invalidation Strategy**: Design proper cache invalidation to maintain data consistency
4. **Monitoring**: Implement comprehensive monitoring for cache hit rates, response times, and memory usage

### Performance Guidelines

- **Cache Hit Rate**: Aim for >80% hit rate for frequently accessed data
- **Response Time**: Cache operations should complete in <100ms
- **Memory Usage**: Keep cache memory usage below 90% to prevent evictions
- **TTL Strategy**: Use different TTL values based on data volatility

### Scalability Considerations

- **Distributed Caching**: Use consistent hashing for horizontal scaling
- **Replication**: Implement cache replication for high availability
- **Cache Warming**: Pre-load critical data to avoid cold start issues
- **Circuit Breakers**: Implement failure handling to maintain system stability

---

## Navigation

← [Previous: Database Design](4_DatabaseDesign.md) | [Next: Content Delivery Networks →](6_CDN.md)

[Back to System Design Index](1_ReadMe.md)
