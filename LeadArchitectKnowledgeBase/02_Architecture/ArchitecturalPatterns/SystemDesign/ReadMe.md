# **Learning System Design**

**System design involves making key architectural choices while balancing trade-offs for scalability, performance, reliability, and maintainability.**

---

## **High-Scale Engineering Strategies**

For real-world examples of handling massive traffic, see:

- **[HighScaleEngineering.md](./HighScaleEngineering.md)** - Battle-tested strategies for $5M/minute traffic (High-scale event handling)

---

## **Choosing the Right Database**

Selecting the right database is critical for efficient storage and retrieval. Consider factors such as **data type**, **query patterns**, **scale**, and **consistency**.

---

### **Caching**

Caching improves performance by storing frequently accessed data closer to the application.

- **Use cases**: Speeding up reads, reducing database load, and minimizing latency.

> 1. Redis — Popular for its high throughput and flexibility (in-memory key-value store).
> 2. Memcached — Lightweight, distributed cache system.

---

### **Blob Storage**

Blob storage is used for storing large unstructured data such as images, videos, and backups.

> 1. **S3** — Scalable object storage service by AWS.
> 2. **Azure Blob Storage** — Microsoft’s solution for unstructured data.

---

### **CDN (Content Delivery Network)**

A CDN helps deliver static and dynamic content (e.g., images, videos, and scripts) closer to the user by caching it in geographically distributed edge locations.

- **Use case**: Reduced latency and improved load times.

> 1. **Cloudflare** — A global CDN and web performance service.
> 2. **AWS CloudFront** — Amazon's CDN for dynamic and static content.
> 3. **Akamai** — A widely used enterprise-grade CDN solution.

---

### **Text Search**

Text search involves querying and analyzing large amounts of textual data efficiently.

> 1. **Elasticsearch** — Distributed text search engine with full-text search support.
> 2. **Solr** — Another search engine with enterprise-grade features.
> 3. **Fuzzy Search** — Useful for misspellings and approximate matches, supported by both Elasticsearch and Solr.

---

### **Time Series Databases**

Time series databases are optimized for handling sequential data indexed by timestamps.

> 1. **InfluxDB** — Ideal for metrics and monitoring data.
> 2. **TimescaleDB** — Built on PostgreSQL, optimized for time-series data.
> 3. **Prometheus** — A monitoring tool with a time-series database at its core.
> 4. **Key Features**:
>    - Append-only write mode.
>    - Bulk reads.
>    - Retention policies to manage storage efficiently.

---

### **Analytics**

Analytics databases are designed for complex queries and data aggregation.

> 1. **Data Warehouse** — Centralized repository for structured and semi-structured data.

- Examples: **Snowflake**, **Google BigQuery**, **AWS Redshift**.
  > 2. **Hadoop** — A framework for large-scale distributed data processing.
  > 3. **Databricks** — Unified analytics platform combining big data and AI capabilities.
  > 4. **Offline Reporting** — Batch jobs for generating insights from stored data.

---

### **RDBMS vs NoSQL**

Choosing between relational databases and NoSQL depends on your data structure and consistency needs.

> 1. **RDBMS**:
>    - Use cases: Strong consistency and relationships between tables.
>    - Examples: **MySQL**, **PostgreSQL**, **SQL Server**.
> 2. **NoSQL**:
>    - Use cases: Unstructured or semi-structured data with high scalability.
>    - Examples: **MongoDB**, **Cassandra**, **DynamoDB**.

---

### **ACID Properties**

ACID ensures database reliability during transactions.

> 1. **Atomicity** — Ensures transactions are all-or-nothing.
> 2. **Consistency** — Guarantees the database remains valid after a transaction.
> 3. **Isolation** — Transactions occur independently.
> 4. **Durability** — Changes from a transaction are permanent.

---

### **Cassandra (Columnar Database)**

Columnar databases are optimized for write-heavy workloads and analytical queries.

> 1. **Use cases**:
>    - Ever-increasing data (e.g., logs, IoT events).
>    - Limited/finite query patterns (e.g., time-bound searches).
> 2. **Key Features**:
>    - Horizontal scalability.
>    - High availability with eventual consistency.

---

### **Document Database**

Document databases store data in flexible, schema-less formats like JSON.

> 1. **MongoDB** — Popular document database for scalable applications.
> 2. **Cosmos DB** — Microsoft's globally distributed, multi-model database with JSON support.
> 3. **Couchbase** — Combines document and key-value capabilities.

---

This enhanced structure and content should cover the basics while also helping you explore specific areas in greater detail!
