# Database Design for Scalable Systems

## Overview

Database design is fundamental to building scalable, performant, and reliable systems. This chapter covers database selection criteria, design patterns, scaling strategies, and best practices for handling data in large-scale distributed systems.

## Learning Objectives

By the end of this chapter, you will understand:
- SQL vs NoSQL database trade-offs and selection criteria
- Database scaling patterns (replication, sharding, federation)
- Data modeling strategies for different database types
- ACID properties vs BASE principles
- Database performance optimization techniques
- Data consistency patterns in distributed systems

---

## 1. Database Fundamentals

### 1.1 Database Types Overview

**Relational Databases (SQL)**
- Structured data with predefined schema
- ACID compliance (Atomicity, Consistency, Isolation, Durability)
- Complex queries with JOINs
- Strong consistency guarantees
- Mature ecosystem and tooling

**NoSQL Databases**
- Flexible schema or schema-less
- Horizontal scaling capabilities
- Eventual consistency models
- High performance for specific use cases
- Different data models (document, key-value, column, graph)

### 1.2 ACID vs BASE

**ACID Properties (SQL Databases)**
```
Atomicity: All operations in a transaction succeed or fail together
- Example: Bank transfer (debit + credit) both succeed or both fail

Consistency: Database remains in valid state after transactions
- Example: Foreign key constraints are always maintained

Isolation: Concurrent transactions don't interfere with each other
- Example: Two simultaneous transfers don't see partial states

Durability: Committed transactions are permanently stored
- Example: Data survives system crashes and power failures
```

**BASE Properties (NoSQL Databases)**
```
Basically Available: System remains available for operations
- Example: System responds even during partial failures

Soft State: System state may change over time without input
- Example: Data might be temporarily inconsistent

Eventual Consistency: System becomes consistent over time
- Example: Data propagates to all nodes eventually
```

---

## 2. SQL Database Design

### 2.1 Relational Database Strengths

**When to Choose SQL Databases:**
- Complex relationships between entities
- Need for ACID transactions
- Complex queries and analytics
- Strong consistency requirements
- Mature tooling and expertise available

**Popular SQL Databases:**
- **PostgreSQL**: Advanced features, JSON support, extensibility
- **MySQL**: High performance, wide adoption, cloud integration
- **SQL Server**: Enterprise features, Windows integration
- **Oracle**: Enterprise-grade, advanced features, high performance

### 2.2 Database Schema Design

**Normalization Principles**
```sql
-- First Normal Form (1NF): Atomic values
-- Bad: Multiple values in single column
CREATE TABLE users_bad (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    phone_numbers VARCHAR(255) -- "123-456-7890,098-765-4321"
);

-- Good: Atomic values
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE user_phones (
    id INT PRIMARY KEY,
    user_id INT REFERENCES users(id),
    phone_number VARCHAR(20)
);
```

```sql
-- Third Normal Form (3NF): Remove transitive dependencies
-- Bad: Non-key column depends on another non-key column
CREATE TABLE orders_bad (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100), -- Depends on customer_id
    customer_email VARCHAR(100), -- Depends on customer_id
    order_date DATE,
    total_amount DECIMAL(10,2)
);

-- Good: Separate customer information
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE,
    total_amount DECIMAL(10,2)
);
```

**Denormalization for Performance**
```sql
-- Sometimes denormalization improves performance
-- Example: E-commerce order summary

-- Normalized (slower for reporting)
SELECT 
    o.order_id,
    c.name,
    COUNT(oi.item_id) as item_count,
    SUM(oi.quantity * oi.price) as total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.name;

-- Denormalized (faster, but requires maintenance)
CREATE TABLE order_summary (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100), -- Denormalized
    item_count INT,             -- Calculated
    total_amount DECIMAL(10,2), -- Calculated
    order_date DATE
);
```

### 2.3 Indexing Strategies

**Index Types and Usage**
```sql
-- Primary Index (automatically created)
CREATE TABLE users (
    id INT PRIMARY KEY,  -- Clustered index
    email VARCHAR(100) UNIQUE,  -- Unique index
    name VARCHAR(100)
);

-- Secondary Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_name ON users(name);

-- Composite Index
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Partial Index (PostgreSQL)
CREATE INDEX idx_active_users ON users(email) WHERE active = true;

-- Functional Index
CREATE INDEX idx_users_lower_email ON users(LOWER(email));
```

**Index Performance Considerations**
```sql
-- Good: Uses index efficiently
SELECT * FROM orders 
WHERE customer_id = 123 
ORDER BY order_date DESC;

-- Bad: Function on column prevents index usage
SELECT * FROM orders 
WHERE YEAR(order_date) = 2024;

-- Good: Rewrite to use index
SELECT * FROM orders 
WHERE order_date >= '2024-01-01' 
  AND order_date < '2025-01-01';
```

---

## 3. NoSQL Database Design

### 3.1 NoSQL Database Types

**Document Databases (MongoDB, CouchDB)**
```javascript
// Flexible schema, nested documents
{
  "_id": "user123",
  "name": "John Doe",
  "email": "john@example.com",
  "profile": {
    "age": 30,
    "location": "New York",
    "preferences": {
      "notifications": true,
      "theme": "dark"
    }
  },
  "orders": [
    {
      "orderId": "order456",
      "date": "2024-01-01",
      "total": 99.99,
      "items": [
        {"product": "laptop", "quantity": 1, "price": 99.99}
      ]
    }
  ]
}
```

**Key-Value Stores (Redis, DynamoDB)**
```javascript
// Simple key-value pairs
"user:123:profile" → {"name": "John", "email": "john@example.com"}
"user:123:sessions" → ["session1", "session2", "session3"]
"product:456:inventory" → {"count": 100, "reserved": 5}
"cache:trending_products" → ["prod1", "prod2", "prod3"]
```

**Column-Family (Cassandra, HBase)**
```javascript
// Column families with dynamic columns
RowKey: "user123"
ColumnFamily: "profile"
  name: "John Doe"
  email: "john@example.com"
  last_login: "2024-01-01T10:00:00Z"
  
ColumnFamily: "activity"
  "2024-01-01:login": "10:00:00"
  "2024-01-01:purchase": "14:30:00"
  "2024-01-02:login": "09:15:00"
```

**Graph Databases (Neo4j, Amazon Neptune)**
```cypher
// Nodes and relationships
CREATE (u:User {name: "John", email: "john@example.com"})
CREATE (p:Product {name: "Laptop", price: 999.99})
CREATE (u)-[:PURCHASED {date: "2024-01-01", quantity: 1}]->(p)
CREATE (u)-[:FOLLOWS]->(u2:User {name: "Jane"})

// Query relationships
MATCH (u:User)-[:PURCHASED]->(p:Product)
WHERE u.name = "John"
RETURN p.name, p.price
```

### 3.2 Data Modeling Patterns

**Embedding vs Referencing (MongoDB)**
```javascript
// Embedding (denormalized) - good for data accessed together
{
  "_id": "order123",
  "customer": {
    "name": "John Doe",
    "email": "john@example.com"
  },
  "items": [
    {"product": "laptop", "price": 999.99, "quantity": 1},
    {"product": "mouse", "price": 29.99, "quantity": 1}
  ],
  "total": 1029.98,
  "status": "shipped"
}

// Referencing (normalized) - good for data that changes frequently
{
  "_id": "order123",
  "customer_id": "user456",
  "items": [
    {"product_id": "prod789", "quantity": 1},
    {"product_id": "prod101", "quantity": 1}
  ],
  "total": 1029.98,
  "status": "shipped"
}
```

**Bucket Pattern (Time-Series Data)**
```javascript
// Instead of one document per reading
{
  "_id": "sensor123_reading_1",
  "sensor_id": "sensor123",
  "timestamp": "2024-01-01T10:00:00Z",
  "temperature": 22.5
}

// Group readings into buckets
{
  "_id": "sensor123_2024-01-01-10",
  "sensor_id": "sensor123",
  "date": "2024-01-01",
  "hour": 10,
  "readings": [
    {"minute": 0, "temperature": 22.5},
    {"minute": 1, "temperature": 22.6},
    {"minute": 2, "temperature": 22.4}
    // ... up to 60 readings per hour
  ],
  "summary": {
    "avg_temp": 22.5,
    "min_temp": 22.1,
    "max_temp": 22.9
  }
}
```

---

## 4. Database Scaling Patterns

### 4.1 Read Replicas

**Master-Slave Replication**
```
Master Database (Read/Write)
    ↓ (Replication)
Slave Database 1 (Read Only)
Slave Database 2 (Read Only)
Slave Database 3 (Read Only)

Benefits:
- Scale read operations
- Improve read performance
- Provide backup/failover option

Implementation Pattern:
- All writes go to master
- Reads distributed across slaves
- Asynchronous replication (eventual consistency)
```

**Application Implementation**
```python
class DatabaseRouter:
    def __init__(self):
        self.master = connect_to_master()
        self.slaves = [connect_to_slave(url) for url in slave_urls]
        self.current_slave = 0
    
    def execute_write(self, query):
        return self.master.execute(query)
    
    def execute_read(self, query):
        # Round-robin across slaves
        slave = self.slaves[self.current_slave]
        self.current_slave = (self.current_slave + 1) % len(self.slaves)
        return slave.execute(query)
```

**Read Replica Challenges**
```
Replication Lag:
- Master writes at time T
- Slave receives update at time T+delay
- Read after write consistency issues

Solution Strategies:
1. Read from master for recent writes
2. Use session-based routing
3. Implement read-your-writes consistency
4. Use timestamp-based routing
```

### 4.2 Database Sharding

**Horizontal Sharding (Partitioning)**
```
User Data Distribution:
Shard 1: user_id 1-1000000      (Database Server 1)
Shard 2: user_id 1000001-2000000 (Database Server 2)
Shard 3: user_id 2000001-3000000 (Database Server 3)

Application Logic:
def get_shard(user_id):
    if user_id <= 1000000:
        return shard1
    elif user_id <= 2000000:
        return shard2
    else:
        return shard3
```

**Sharding Strategies**

**Range-Based Sharding**
```python
class RangeBasedSharder:
    def __init__(self):
        self.shards = [
            {"min": 0, "max": 1000000, "db": "shard1"},
            {"min": 1000001, "max": 2000000, "db": "shard2"},
            {"min": 2000001, "max": 3000000, "db": "shard3"}
        ]
    
    def get_shard(self, user_id):
        for shard in self.shards:
            if shard["min"] <= user_id <= shard["max"]:
                return shard["db"]
        raise ValueError("No shard found for user_id")
```

**Hash-Based Sharding**
```python
class HashBasedSharder:
    def __init__(self, num_shards):
        self.num_shards = num_shards
        self.shards = [f"shard{i}" for i in range(num_shards)]
    
    def get_shard(self, key):
        hash_value = hash(str(key))
        shard_index = hash_value % self.num_shards
        return self.shards[shard_index]
```

**Directory-Based Sharding**
```python
class DirectoryBasedSharder:
    def __init__(self):
        # Lookup service maintains user->shard mapping
        self.directory_service = DirectoryService()
    
    def get_shard(self, user_id):
        return self.directory_service.lookup(user_id)
    
    def migrate_user(self, user_id, target_shard):
        # Move user data between shards
        self.directory_service.update_mapping(user_id, target_shard)
```

**Sharding Challenges**
```
1. Cross-Shard Queries:
   Problem: JOINs across different databases
   Solution: Denormalization, application-level joins

2. Rebalancing:
   Problem: Adding/removing shards
   Solution: Consistent hashing, virtual shards

3. Hot Spots:
   Problem: Uneven data distribution
   Solution: Better shard key selection, resharding

4. Transactions:
   Problem: ACID across multiple shards
   Solution: Two-phase commit, saga pattern
```

### 4.3 Database Federation

**Functional Partitioning**
```
Split by domain/feature:

User Service Database:
- users table
- user_profiles table
- user_sessions table

Product Service Database:
- products table
- categories table
- inventory table

Order Service Database:
- orders table
- order_items table
- payments table

Benefits:
- Domain isolation
- Independent scaling
- Technology diversity
- Team ownership
```

**Implementation Pattern**
```python
class DatabaseFederation:
    def __init__(self):
        self.user_db = UserDatabase()
        self.product_db = ProductDatabase()
        self.order_db = OrderDatabase()
    
    def create_order(self, user_id, product_ids):
        # Validate user exists
        user = self.user_db.get_user(user_id)
        if not user:
            raise ValueError("User not found")
        
        # Validate products exist
        products = self.product_db.get_products(product_ids)
        if len(products) != len(product_ids):
            raise ValueError("Some products not found")
        
        # Create order
        order = self.order_db.create_order(user_id, products)
        return order
```

---

## 5. NoSQL Scaling Patterns

### 5.1 MongoDB Scaling

**Replica Sets**
```javascript
// Replica set configuration
rs.initiate({
  _id: "myReplicaSet",
  members: [
    {_id: 0, host: "mongodb1.example.com:27017", priority: 2},
    {_id: 1, host: "mongodb2.example.com:27017", priority: 1},
    {_id: 2, host: "mongodb3.example.com:27017", priority: 1, arbiterOnly: true}
  ]
});

// Read preference configuration
db.collection.find().readPref("secondary");
db.collection.find().readPref("secondaryPreferred");
```

**Sharded Clusters**
```javascript
// Enable sharding for database
sh.enableSharding("ecommerce");

// Shard collection by user_id
sh.shardCollection("ecommerce.users", {user_id: 1});

// Shard collection by compound key
sh.shardCollection("ecommerce.orders", {customer_id: 1, order_date: 1});

// Query router automatically directs queries to appropriate shards
```

### 5.2 Cassandra Scaling

**Ring Architecture**
```
Cassandra Ring (4 nodes):
Node A (Token range: 0 - 25%)
Node B (Token range: 25% - 50%)
Node C (Token range: 50% - 75%)
Node D (Token range: 75% - 100%)

Data Distribution:
- Each row assigned to node based on partition key hash
- Replication factor determines number of copies
- Consistent hashing ensures even distribution
```

**Data Modeling for Cassandra**
```cql
-- Design tables for specific queries
-- Table for user profile lookups
CREATE TABLE users_by_id (
    user_id UUID PRIMARY KEY,
    name TEXT,
    email TEXT,
    created_at TIMESTAMP
);

-- Table for user lookups by email
CREATE TABLE users_by_email (
    email TEXT PRIMARY KEY,
    user_id UUID,
    name TEXT,
    created_at TIMESTAMP
);

-- Table for time-series data
CREATE TABLE user_activities (
    user_id UUID,
    activity_date DATE,
    activity_time TIMESTAMP,
    activity_type TEXT,
    details TEXT,
    PRIMARY KEY ((user_id, activity_date), activity_time)
) WITH CLUSTERING ORDER BY (activity_time DESC);
```

### 5.3 DynamoDB Scaling

**Partition Key Design**
```python
# Good partition key - evenly distributed
{
    "user_id": "user123",  # Partition key
    "timestamp": "2024-01-01T10:00:00Z",  # Sort key
    "activity": "login",
    "ip_address": "192.168.1.1"
}

# Bad partition key - hot partition
{
    "date": "2024-01-01",  # All today's data in one partition
    "user_id": "user123",
    "activity": "login"
}

# Better design with distributed partition key
{
    "partition_key": "2024-01-01#bucket-5",  # Date + random bucket
    "user_id": "user123",
    "timestamp": "2024-01-01T10:00:00Z",
    "activity": "login"
}
```

**Global Secondary Indexes (GSI)**
```python
# Main table: partition by user_id
{
    "user_id": "user123",     # Partition key
    "order_id": "order456",   # Sort key
    "status": "shipped",
    "total": 99.99,
    "created_at": "2024-01-01T10:00:00Z"
}

# GSI: Query orders by status
GSI_Status = {
    "status": "shipped",      # GSI Partition key
    "created_at": "2024-01-01T10:00:00Z",  # GSI Sort key
    "user_id": "user123",
    "order_id": "order456",
    "total": 99.99
}
```

---

## 6. Caching Strategies

### 6.1 Database Caching Layers

**Query Result Caching**
```python
import redis
import json
import hashlib

class QueryCache:
    def __init__(self):
        self.redis_client = redis.Redis(host='localhost', port=6379, db=0)
        self.default_ttl = 3600  # 1 hour
    
    def get_cache_key(self, query, params):
        query_string = f"{query}:{json.dumps(params, sort_keys=True)}"
        return f"query:{hashlib.md5(query_string.encode()).hexdigest()}"
    
    def get_cached_result(self, query, params):
        cache_key = self.get_cache_key(query, params)
        cached_result = self.redis_client.get(cache_key)
        if cached_result:
            return json.loads(cached_result)
        return None
    
    def cache_result(self, query, params, result, ttl=None):
        cache_key = self.get_cache_key(query, params)
        ttl = ttl or self.default_ttl
        self.redis_client.setex(
            cache_key, 
            ttl, 
            json.dumps(result, default=str)
        )
```

**Application-Level Caching**
```python
class UserService:
    def __init__(self):
        self.db = Database()
        self.cache = Redis()
    
    def get_user(self, user_id):
        # Try cache first
        cache_key = f"user:{user_id}"
        cached_user = self.cache.get(cache_key)
        if cached_user:
            return json.loads(cached_user)
        
        # Cache miss - query database
        user = self.db.query(
            "SELECT * FROM users WHERE id = %s", 
            [user_id]
        )
        
        # Cache the result
        if user:
            self.cache.setex(
                cache_key, 
                3600,  # 1 hour TTL
                json.dumps(user)
            )
        
        return user
    
    def update_user(self, user_id, data):
        # Update database
        self.db.execute(
            "UPDATE users SET name = %s, email = %s WHERE id = %s",
            [data['name'], data['email'], user_id]
        )
        
        # Invalidate cache
        cache_key = f"user:{user_id}"
        self.cache.delete(cache_key)
```

### 6.2 Cache Patterns

**Cache-Aside (Lazy Loading)**
```python
def get_product(product_id):
    # 1. Check cache
    product = cache.get(f"product:{product_id}")
    if product:
        return product
    
    # 2. Cache miss - load from database
    product = database.get_product(product_id)
    
    # 3. Update cache
    cache.set(f"product:{product_id}", product, ttl=3600)
    
    return product
```

**Write-Through**
```python
def update_product(product_id, data):
    # 1. Update database
    database.update_product(product_id, data)
    
    # 2. Update cache
    cache.set(f"product:{product_id}", data, ttl=3600)
```

**Write-Behind (Write-Back)**
```python
class WriteBehindCache:
    def __init__(self):
        self.cache = {}
        self.dirty_keys = set()
        self.write_interval = 60  # Flush every minute
    
    def set(self, key, value):
        self.cache[key] = value
        self.dirty_keys.add(key)
    
    def flush_dirty_data(self):
        for key in self.dirty_keys:
            if key in self.cache:
                database.save(key, self.cache[key])
        self.dirty_keys.clear()
```

---

## 7. Data Consistency Patterns

### 7.1 Consistency Models

**Strong Consistency**
```
All nodes return the same data at any given time
- Read after write returns updated value
- Linearizability guaranteed
- Higher latency, lower availability

Example: Financial transactions, inventory management
```

**Eventual Consistency**
```
System becomes consistent over time
- Temporary inconsistencies allowed
- Higher availability and performance
- Complex conflict resolution

Example: Social media feeds, product catalogs
```

**Session Consistency**
```
Consistency within a user session
- User sees their own writes
- May see stale data from other users
- Good balance of performance and usability

Implementation:
- Route user requests to same replica
- Use read-your-writes pattern
```

### 7.2 Distributed Transactions

**Two-Phase Commit (2PC)**
```python
class TwoPhaseCommitCoordinator:
    def __init__(self, participants):
        self.participants = participants
    
    def execute_transaction(self, operations):
        transaction_id = generate_transaction_id()
        
        # Phase 1: Prepare
        prepare_responses = []
        for participant in self.participants:
            response = participant.prepare(transaction_id, operations)
            prepare_responses.append(response)
        
        # Check if all participants can commit
        if all(response.can_commit for response in prepare_responses):
            # Phase 2: Commit
            for participant in self.participants:
                participant.commit(transaction_id)
            return "COMMITTED"
        else:
            # Phase 2: Abort
            for participant in self.participants:
                participant.abort(transaction_id)
            return "ABORTED"
```

**Saga Pattern**
```python
class SagaOrchestrator:
    def __init__(self):
        self.steps = []
        self.compensations = []
    
    def add_step(self, action, compensation):
        self.steps.append(action)
        self.compensations.append(compensation)
    
    def execute(self):
        completed_steps = []
        
        try:
            for i, step in enumerate(self.steps):
                result = step()
                completed_steps.append(i)
                
        except Exception as e:
            # Compensate in reverse order
            for step_index in reversed(completed_steps):
                try:
                    self.compensations[step_index]()
                except Exception as comp_error:
                    # Log compensation failure
                    logger.error(f"Compensation failed: {comp_error}")
            
            raise e

# Usage example
saga = SagaOrchestrator()
saga.add_step(
    action=lambda: payment_service.charge_card(amount),
    compensation=lambda: payment_service.refund(amount)
)
saga.add_step(
    action=lambda: inventory_service.reserve_items(items),
    compensation=lambda: inventory_service.release_items(items)
)
saga.add_step(
    action=lambda: shipping_service.create_shipment(order),
    compensation=lambda: shipping_service.cancel_shipment(order)
)

saga.execute()
```

---

## 8. Performance Optimization

### 8.1 Query Optimization

**Index Optimization**
```sql
-- Identify slow queries
EXPLAIN ANALYZE SELECT * FROM orders 
WHERE customer_id = 123 AND order_date > '2024-01-01';

-- Create composite index
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Monitor index usage
SELECT 
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE tablename = 'orders';
```

**Query Rewriting**
```sql
-- Inefficient subquery
SELECT * FROM products 
WHERE category_id IN (
    SELECT id FROM categories WHERE name = 'Electronics'
);

-- More efficient JOIN
SELECT p.* FROM products p
JOIN categories c ON p.category_id = c.id
WHERE c.name = 'Electronics';

-- Use EXISTS instead of IN for large datasets
SELECT * FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.customer_id = c.id AND o.order_date > '2024-01-01'
);
```

### 8.2 Connection Pooling

**Database Connection Pool**
```python
import psycopg2.pool

class DatabasePool:
    def __init__(self, min_connections=5, max_connections=20):
        self.pool = psycopg2.pool.ThreadedConnectionPool(
            min_connections,
            max_connections,
            host="localhost",
            database="myapp",
            user="dbuser",
            password="password"
        )
    
    def get_connection(self):
        return self.pool.getconn()
    
    def return_connection(self, connection):
        self.pool.putconn(connection)
    
    def execute_query(self, query, params=None):
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute(query, params)
                return cursor.fetchall()
        finally:
            self.return_connection(conn)
```

### 8.3 Database Partitioning

**Table Partitioning (PostgreSQL)**
```sql
-- Range partitioning by date
CREATE TABLE orders (
    order_id SERIAL,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2)
) PARTITION BY RANGE (order_date);

-- Create partitions
CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- Hash partitioning by customer_id
CREATE TABLE user_activities (
    user_id INT,
    activity_date DATE,
    activity_type VARCHAR(50),
    details JSONB
) PARTITION BY HASH (user_id);

CREATE TABLE user_activities_0 PARTITION OF user_activities
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE user_activities_1 PARTITION OF user_activities
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);
```

---

## 9. Monitoring and Observability

### 9.1 Database Metrics

**Key Performance Indicators**
```sql
-- Query performance metrics (PostgreSQL)
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    stddev_time,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Connection statistics
SELECT 
    state,
    count(*) as connections
FROM pg_stat_activity
GROUP BY state;

-- Cache hit ratio
SELECT 
    sum(heap_blks_read) as heap_read,
    sum(heap_blks_hit) as heap_hit,
    sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM pg_statio_user_tables;
```

**MongoDB Monitoring**
```javascript
// Database statistics
db.runCommand({dbStats: 1});

// Collection statistics
db.collection.stats();

// Current operations
db.currentOp();

// Profiler for slow operations
db.setProfilingLevel(2, {slowms: 100});
db.system.profile.find().sort({ts: -1}).limit(5);
```

### 9.2 Alerting and Thresholds

**Critical Metrics to Monitor**
```yaml
# Database monitoring configuration
metrics:
  - name: connection_pool_usage
    threshold: 80%
    alert: "Connection pool usage high"
    
  - name: query_response_time_p95
    threshold: 1000ms
    alert: "95th percentile query time exceeded"
    
  - name: disk_usage
    threshold: 85%
    alert: "Database disk usage critical"
    
  - name: replication_lag
    threshold: 10s
    alert: "Replication lag too high"
    
  - name: cache_hit_ratio
    threshold: 90%
    alert: "Cache hit ratio below threshold"
```

---

## 10. Best Practices

### 10.1 Design Best Practices

1. **Choose the Right Database Type**: Match database capabilities to use case requirements
2. **Design for Scale**: Consider future growth in data modeling decisions
3. **Normalize Appropriately**: Balance normalization with performance needs
4. **Index Strategically**: Create indexes based on actual query patterns
5. **Plan for Consistency**: Choose appropriate consistency model for each use case

### 10.2 Performance Best Practices

1. **Connection Pooling**: Always use connection pools in production
2. **Query Optimization**: Regular query performance analysis and optimization
3. **Caching Strategy**: Implement multi-level caching where appropriate
4. **Monitor Continuously**: Set up comprehensive monitoring and alerting
5. **Capacity Planning**: Plan for growth and perform regular capacity assessments

### 10.3 Operational Best Practices

1. **Backup Strategy**: Implement automated backups with regular restore testing
2. **Security**: Use encryption, access controls, and audit logging
3. **Documentation**: Document schema changes and operational procedures
4. **Testing**: Test database changes in staging environments
5. **Disaster Recovery**: Plan and test disaster recovery procedures

---

## Key Takeaways

1. **Database Selection**: Choose databases based on consistency, scalability, and query requirements
2. **Scaling Strategy**: Plan scaling approach early - vertical vs horizontal
3. **Consistency Trade-offs**: Understand CAP theorem implications for your use case
4. **Performance Optimization**: Focus on indexing, query optimization, and caching
5. **Monitoring is Critical**: Monitor performance, capacity, and health continuously
6. **Plan for Growth**: Design data models and architecture to accommodate scale
7. **Test Everything**: Test performance, failover, and disaster recovery regularly

---

**Previous**: [← Load Balancing](3_LoadBalancing.md)  
**Next**: [Caching Strategies →](5_CachingStrategies.md)
