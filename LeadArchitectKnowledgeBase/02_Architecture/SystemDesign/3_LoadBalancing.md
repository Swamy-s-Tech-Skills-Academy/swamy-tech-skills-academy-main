# Load Balancing

## Overview

Load balancing is a critical technique for distributing incoming network traffic across multiple servers to ensure no single server becomes overwhelmed. This chapter covers load balancing concepts, algorithms, types, and implementation strategies for building scalable and resilient systems.

## Learning Objectives

By the end of this chapter, you will understand:
- Load balancing concepts and benefits
- Different types of load balancers and their use cases
- Load balancing algorithms and their trade-offs
- Health checking and failover mechanisms
- Session management in load-balanced environments
- Advanced load balancing techniques

---

## 1. Introduction to Load Balancing

### 1.1 What is Load Balancing?

Load balancing is the process of distributing incoming requests across multiple backend servers (also called backend pool, server farm, or server cluster) to:

- **Maximize throughput**: Efficiently utilize all available resources
- **Minimize response time**: Reduce latency by preventing server overload
- **Avoid overload**: Ensure no single server becomes a bottleneck
- **Increase availability**: Provide redundancy and fault tolerance
- **Enable scalability**: Add/remove servers dynamically

### 1.2 Benefits of Load Balancing

**Performance Benefits**
- Improved response times
- Higher throughput capacity
- Better resource utilization
- Reduced server stress

**Availability Benefits**
- Elimination of single points of failure
- Automatic failover capabilities
- Graceful handling of server failures
- Reduced downtime

**Scalability Benefits**
- Horizontal scaling capability
- Dynamic server addition/removal
- Elastic capacity management
- Cost-effective scaling

**Operational Benefits**
- Easier maintenance and updates
- Zero-downtime deployments
- Better monitoring and management
- Simplified disaster recovery

---

## 2. Types of Load Balancers

### 2.1 Based on Implementation

**Hardware Load Balancers**
- Dedicated physical appliances
- High performance and reliability
- Advanced features and capabilities
- Higher cost and complexity

*Examples: F5 BIG-IP, Citrix NetScaler, Barracuda*

**Software Load Balancers**
- Software running on standard servers
- More flexible and cost-effective
- Easier to configure and manage
- Cloud-native options available

*Examples: HAProxy, NGINX, Apache HTTP Server*

**Cloud Load Balancers**
- Managed services from cloud providers
- Auto-scaling capabilities
- Integration with cloud services
- Pay-as-you-use pricing

*Examples: AWS ALB/NLB, Azure Load Balancer, GCP Load Balancing*

### 2.2 Based on Network Layer (OSI Model)

**Layer 4 (Transport Layer) Load Balancers**
- Operate at TCP/UDP level
- Route based on IP and port
- Protocol-agnostic
- Higher performance
- Lower latency

```
Client Request → Load Balancer → Server
[TCP connection directly forwarded]

Features:
- TCP/UDP load balancing
- Port-based routing
- Connection multiplexing
- SSL passthrough
```

**Layer 7 (Application Layer) Load Balancers**
- Operate at HTTP/HTTPS level
- Route based on application data
- Content-aware routing
- Advanced features
- Higher resource usage

```
Client Request → Load Balancer → Server
[HTTP request parsed and modified]

Features:
- URL-based routing
- Header inspection
- SSL termination
- Content compression
- Request modification
```

### 2.3 Deployment Patterns

**External Load Balancer**
- Routes traffic from internet to servers
- Public-facing load balancer
- Handles external client requests
- SSL termination point

**Internal Load Balancer**
- Routes traffic between internal services
- Private network load balancer
- Service-to-service communication
- Microservices architecture

**Global Load Balancer**
- Routes traffic across multiple regions
- DNS-based load balancing
- Geographic routing
- Disaster recovery

---

## 3. Load Balancing Algorithms

### 3.1 Static Algorithms

**Round Robin**
```
Algorithm: Distribute requests sequentially
Request 1 → Server A
Request 2 → Server B
Request 3 → Server C
Request 4 → Server A (cycle repeats)

Pros:
- Simple implementation
- Equal distribution
- Good for similar servers

Cons:
- Ignores server capacity
- No consideration for server load
- May cause uneven actual load
```

**Weighted Round Robin**
```
Algorithm: Round robin with server weights
Server A (weight=3): Gets 3 requests
Server B (weight=2): Gets 2 requests
Server C (weight=1): Gets 1 request

Configuration Example:
- Server A: High-performance (weight=5)
- Server B: Medium-performance (weight=3)
- Server C: Low-performance (weight=1)

Use Cases:
- Servers with different capacities
- Gradual traffic shifting
- A/B testing scenarios
```

**IP Hash**
```
Algorithm: hash(client_IP) % number_of_servers

Implementation:
def ip_hash_balance(client_ip, servers):
    hash_value = hash(client_ip)
    server_index = hash_value % len(servers)
    return servers[server_index]

Pros:
- Session affinity (sticky sessions)
- Consistent routing for same client
- Simple implementation

Cons:
- Uneven distribution possible
- Server removal affects routing
- Limited load distribution
```

**URL Hash**
```
Algorithm: hash(request_URL) % number_of_servers

Use Cases:
- Cache optimization
- Content-based routing
- CDN integration

Example:
/images/* → Image servers
/api/* → API servers
/static/* → Static content servers
```

### 3.2 Dynamic Algorithms

**Least Connections**
```
Algorithm: Route to server with fewest active connections

Tracking:
Server A: 5 active connections
Server B: 3 active connections ← Selected
Server C: 7 active connections

Advantages:
- Better load distribution
- Adapts to server performance
- Good for long-running requests

Implementation Considerations:
- Connection counting overhead
- Connection state tracking
- Periodic cleanup required
```

**Weighted Least Connections**
```
Algorithm: Combine least connections with server weights

Calculation: active_connections / server_weight

Example:
Server A: 10 connections, weight=2 → 10/2 = 5
Server B: 8 connections, weight=1 → 8/1 = 8
Server C: 6 connections, weight=3 → 6/3 = 2 ← Selected

Benefits:
- Accounts for server capacity
- Dynamic load balancing
- Better resource utilization
```

**Least Response Time**
```
Algorithm: Route to server with lowest response time

Metrics Tracked:
- Average response time
- Current response time
- Historical performance

Implementation:
def least_response_time(servers):
    return min(servers, key=lambda s: s.avg_response_time)

Advantages:
- Performance-based routing
- Automatic adaptation to server health
- Better user experience
```

**Resource-Based Algorithms**
```
CPU-based:
- Route to server with lowest CPU utilization
- Monitor CPU usage in real-time
- Prevent server overload

Memory-based:
- Route based on available memory
- Useful for memory-intensive applications
- Prevent out-of-memory errors

Custom Metrics:
- Application-specific metrics
- Business logic considerations
- Composite scoring algorithms
```

### 3.3 Advanced Algorithms

**Consistent Hashing**
```
Purpose: Minimize remapping when servers are added/removed

Implementation:
1. Hash servers and requests to a ring
2. Route request to next server clockwise
3. Virtual nodes for better distribution

Benefits:
- Minimal disruption on server changes
- Good for distributed caching
- Scalable architecture

Use Cases:
- Distributed databases
- CDN routing
- Microservices mesh
```

**Geolocation-Based**
```
Algorithm: Route based on client geographical location

Implementation:
1. Determine client location (IP geolocation)
2. Route to nearest server/datacenter
3. Fallback to other regions if needed

Metrics:
- Geographic distance
- Network latency
- Regional capacity

Benefits:
- Reduced latency
- Better user experience
- Regulatory compliance
```

---

## 4. Health Checking and Failover

### 4.1 Health Check Types

**Active Health Checks**
```
HTTP Health Check:
GET /health HTTP/1.1
Host: server.example.com

Expected Response:
HTTP/1.1 200 OK
Content-Type: application/json
{"status": "healthy", "timestamp": "2024-01-01T00:00:00Z"}

TCP Health Check:
- Establish TCP connection
- Verify port accessibility
- Check connection success

Custom Health Checks:
- Application-specific endpoints
- Database connectivity checks
- Business logic validation
```

**Passive Health Checks**
```
Monitor ongoing traffic:
- Response codes (4xx, 5xx errors)
- Response times (timeouts)
- Connection failures
- Application errors

Thresholds:
- Error rate > 5% → Mark unhealthy
- Response time > 2 seconds → Mark slow
- Connection failures > 3 consecutive → Mark down
```

### 4.2 Health Check Configuration

**HAProxy Example**
```
backend web_servers
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    
    server web1 192.168.1.10:80 check inter 2s rise 2 fall 3
    server web2 192.168.1.11:80 check inter 2s rise 2 fall 3
    server web3 192.168.1.12:80 check inter 2s rise 2 fall 3

Parameters:
- inter: Check interval (2 seconds)
- rise: Checks needed to mark healthy (2)
- fall: Checks needed to mark unhealthy (3)
```

**NGINX Example**
```
upstream backend {
    server backend1.example.com:8080 max_fails=3 fail_timeout=30s;
    server backend2.example.com:8080 max_fails=3 fail_timeout=30s;
    server backend3.example.com:8080 max_fails=3 fail_timeout=30s;
}

server {
    location / {
        proxy_pass http://backend;
        proxy_next_upstream error timeout http_500 http_502 http_503;
    }
}
```

### 4.3 Failover Strategies

**Immediate Failover**
- Remove failed servers immediately
- Route traffic to healthy servers
- Fast recovery for users
- Risk of cascading failures

**Graceful Failover**
- Gradually reduce traffic to failing server
- Allow in-flight requests to complete
- Slower but safer transition
- Better for stateful applications

**Circuit Breaker Pattern**
```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = 'CLOSED'  # CLOSED, OPEN, HALF_OPEN
    
    def call(self, func, *args, **kwargs):
        if self.state == 'OPEN':
            if time.time() - self.last_failure_time > self.timeout:
                self.state = 'HALF_OPEN'
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            self.on_success()
            return result
        except Exception as e:
            self.on_failure()
            raise e
    
    def on_success(self):
        self.failure_count = 0
        self.state = 'CLOSED'
    
    def on_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        if self.failure_count >= self.failure_threshold:
            self.state = 'OPEN'
```

---

## 5. Session Management

### 5.1 Session Affinity (Sticky Sessions)

**Cookie-Based Affinity**
```
Load Balancer Action:
1. First request → Route to any server
2. Server response includes session cookie
3. Subsequent requests → Route based on cookie

Cookie Example:
Set-Cookie: SERVERID=server1; Path=/; HttpOnly

Benefits:
- Simple implementation
- Maintains session state
- No application changes needed

Drawbacks:
- Uneven load distribution
- Server failure affects sessions
- Scaling complications
```

**IP-Based Affinity**
```
Implementation: hash(client_IP) % number_of_servers

Advantages:
- No cookie dependency
- Works with any protocol
- Simple configuration

Disadvantages:
- Users behind NAT get same server
- Uneven distribution possible
- Mobile users may change IPs
```

### 5.2 Session Sharing

**Shared Session Storage**
```
Architecture:
Client → Load Balancer → Server 1 ↘
                      → Server 2 → Shared Session Store (Redis/DB)
                      → Server 3 ↗

Implementation Example (Node.js + Redis):
const session = require('express-session');
const RedisStore = require('connect-redis')(session);
const redis = require('redis');
const client = redis.createClient();

app.use(session({
    store: new RedisStore({ client: client }),
    secret: 'your-secret-key',
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false, maxAge: 3600000 }
}));
```

**Database Session Storage**
```sql
CREATE TABLE sessions (
    id VARCHAR(255) PRIMARY KEY,
    data TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Session cleanup job
DELETE FROM sessions WHERE expires_at < NOW();
```

### 5.3 Stateless Design

**JWT Token-Based Authentication**
```javascript
// JWT token contains all necessary information
const jwt = require('jsonwebtoken');

// Create token
const token = jwt.sign({
    userId: user.id,
    username: user.username,
    role: user.role,
    exp: Math.floor(Date.now() / 1000) + (60 * 60) // 1 hour
}, process.env.JWT_SECRET);

// Verify token (on any server)
const decoded = jwt.verify(token, process.env.JWT_SECRET);
console.log(decoded.userId); // User information available
```

**API Design for Statelessness**
```
Stateful Design (Bad):
POST /login → Creates server-side session
GET /profile → Uses session to identify user
POST /logout → Destroys server-side session

Stateless Design (Good):
POST /login → Returns JWT token
GET /profile
    Authorization: Bearer <jwt_token>
POST /logout → Client discards token
```

---

## 6. SSL/TLS Handling

### 6.1 SSL Termination

**SSL Termination at Load Balancer**
```
Internet (HTTPS) → Load Balancer (SSL termination) → Backend (HTTP)

Benefits:
- Reduced CPU load on backend servers
- Centralized certificate management
- Better performance
- Easier SSL configuration

Configuration Example (NGINX):
server {
    listen 443 ssl;
    server_name example.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**SSL Passthrough**
```
Internet (HTTPS) → Load Balancer (passthrough) → Backend (HTTPS)

Benefits:
- End-to-end encryption
- Backend handles SSL
- No certificate sharing needed

Drawbacks:
- Higher backend CPU usage
- No SSL-based routing
- Complex certificate management
```

### 6.2 Certificate Management

**Centralized Certificate Management**
```
Load Balancer Certificate Store:
- *.example.com (wildcard certificate)
- api.example.com
- admin.example.com

Automatic Renewal:
- Let's Encrypt integration
- Certificate monitoring
- Automatic deployment
```

**SNI (Server Name Indication)**
```
Multiple certificates on same IP:
server {
    listen 443 ssl;
    server_name api.example.com;
    ssl_certificate /certs/api.crt;
    ssl_certificate_key /certs/api.key;
}

server {
    listen 443 ssl;
    server_name admin.example.com;
    ssl_certificate /certs/admin.crt;
    ssl_certificate_key /certs/admin.key;
}
```

---

## 7. Advanced Load Balancing Techniques

### 7.1 Content-Based Routing

**Path-Based Routing**
```
Load Balancer Rules:
/api/* → API Server Pool
/images/* → Image Server Pool
/static/* → CDN or Static Server Pool
/* (default) → Web Server Pool

NGINX Configuration:
location /api/ {
    proxy_pass http://api_servers/;
}

location /images/ {
    proxy_pass http://image_servers/;
}

location / {
    proxy_pass http://web_servers/;
}
```

**Header-Based Routing**
```
Routing Rules:
User-Agent: Mobile → Mobile-optimized servers
Accept-Language: es → Spanish content servers
X-API-Version: v2 → API v2 servers

HAProxy Configuration:
frontend web_frontend
    bind *:80
    
    # Route mobile traffic
    acl is_mobile hdr_sub(User-Agent) -i mobile
    use_backend mobile_servers if is_mobile
    
    # Route API v2 traffic
    acl is_api_v2 hdr(X-API-Version) -i v2
    use_backend api_v2_servers if is_api_v2
    
    default_backend web_servers
```

**Geographic Routing**
```
Implementation:
1. IP Geolocation lookup
2. Route to regional servers
3. Fallback to global servers

Example:
US users → US East Coast servers
EU users → EU West servers
APAC users → Singapore servers
Others → US West Coast servers
```

### 7.2 Auto-Scaling Integration

**Dynamic Server Pool Management**
```python
# Auto-scaling logic example
def auto_scale_check():
    current_load = get_average_cpu_usage()
    active_servers = get_active_server_count()
    
    if current_load > 80 and active_servers < MAX_SERVERS:
        # Scale up
        new_server = launch_new_server()
        add_to_load_balancer(new_server)
        
    elif current_load < 30 and active_servers > MIN_SERVERS:
        # Scale down
        server_to_remove = select_server_for_removal()
        drain_server_connections(server_to_remove)
        remove_from_load_balancer(server_to_remove)
        terminate_server(server_to_remove)
```

**Predictive Scaling**
```
Metrics to Consider:
- Historical traffic patterns
- Seasonal variations
- Marketing campaigns
- Business events

Implementation:
1. Analyze historical data
2. Predict future load
3. Pre-scale resources
4. Monitor and adjust
```

### 7.3 Multi-Tier Load Balancing

**Internet → Global Load Balancer → Regional Load Balancers → Local Load Balancers → Servers**

```
Tier 1: DNS-based global load balancing
- Route users to nearest region
- Disaster recovery capabilities
- Health check integration

Tier 2: Regional load balancers
- Distribute load within region
- Handle regional failovers
- SSL termination

Tier 3: Local load balancers
- Distribute to server clusters
- Service-specific routing
- Fine-grained health checks
```

---

## 8. Load Balancer Configuration Examples

### 8.1 HAProxy Configuration

```
global
    daemon
    maxconn 4096
    log stdout local0
    
defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option httplog
    
frontend web_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/example.pem
    redirect scheme https if !{ ssl_fc }
    
    # ACLs for routing
    acl is_api path_beg /api/
    acl is_admin hdr(host) -i admin.example.com
    
    # Routing rules
    use_backend api_servers if is_api
    use_backend admin_servers if is_admin
    default_backend web_servers
    
backend web_servers
    balance roundrobin
    option httpchk GET /health
    
    server web1 192.168.1.10:8080 check
    server web2 192.168.1.11:8080 check
    server web3 192.168.1.12:8080 check
    
backend api_servers
    balance leastconn
    option httpchk GET /api/health
    
    server api1 192.168.1.20:8080 check
    server api2 192.168.1.21:8080 check
    
backend admin_servers
    balance source
    option httpchk GET /admin/health
    
    server admin1 192.168.1.30:8080 check
```

### 8.2 NGINX Configuration

```nginx
upstream web_backend {
    least_conn;
    server 192.168.1.10:8080 max_fails=3 fail_timeout=30s;
    server 192.168.1.11:8080 max_fails=3 fail_timeout=30s;
    server 192.168.1.12:8080 max_fails=3 fail_timeout=30s;
}

upstream api_backend {
    ip_hash;
    server 192.168.1.20:8080;
    server 192.168.1.21:8080;
}

server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/ssl/certs/example.crt;
    ssl_certificate_key /etc/ssl/private/example.key;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    
    # API routing
    location /api/ {
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # API-specific settings
        proxy_read_timeout 60s;
        proxy_connect_timeout 10s;
    }
    
    # Web application routing
    location / {
        proxy_pass http://web_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Caching for static content
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

---

## 9. Monitoring and Troubleshooting

### 9.1 Key Metrics

**Load Balancer Metrics**
```
Performance Metrics:
- Requests per second
- Response time (P50, P95, P99)
- Throughput (bytes/second)
- Connection count

Health Metrics:
- Active/inactive backend servers
- Health check success rate
- Failover frequency
- Error rates (4xx, 5xx)

Resource Metrics:
- CPU utilization
- Memory usage
- Network bandwidth
- Connection pool usage
```

**Backend Server Metrics**
```
Server Health:
- Response time
- Error rate
- Health check status
- Resource utilization

Load Distribution:
- Requests per server
- Connection count per server
- Response time per server
- CPU/memory per server
```

### 9.2 Common Issues and Solutions

**Uneven Load Distribution**
```
Problem: Some servers overloaded while others idle

Causes:
- Sticky sessions with uneven session distribution
- Server capacity differences not accounted for
- Inefficient load balancing algorithm

Solutions:
- Use weighted algorithms for different server capacities
- Implement session sharing instead of sticky sessions
- Monitor and adjust server weights
- Consider least-connections algorithm
```

**Session Loss**
```
Problem: Users lose sessions when servers fail

Causes:
- Sticky sessions without redundancy
- Server-side session storage
- Inadequate failover handling

Solutions:
- Implement shared session storage (Redis, database)
- Use stateless authentication (JWT)
- Configure session replication
- Implement graceful failover
```

**SSL/TLS Issues**
```
Problem: SSL certificate errors or performance issues

Causes:
- Certificate expiration
- SNI configuration problems
- SSL termination performance impact

Solutions:
- Automated certificate renewal
- Proper SNI configuration
- SSL session caching
- Hardware acceleration for SSL
```

---

## 10. Best Practices

### 10.1 Design Best Practices

1. **Health Checks**: Implement comprehensive health checking
2. **Graceful Failures**: Design for graceful degradation
3. **Session Management**: Use stateless design when possible
4. **Security**: Implement proper security headers and practices
5. **Monitoring**: Monitor all aspects of load balancer performance
6. **Documentation**: Document configuration and procedures

### 10.2 Operational Best Practices

1. **Testing**: Test failover scenarios regularly
2. **Capacity Planning**: Monitor capacity and plan for growth
3. **Configuration Management**: Use version control for configurations
4. **Automation**: Automate common operational tasks
5. **Backup**: Backup configurations and certificates
6. **Performance Tuning**: Regularly review and optimize settings

### 10.3 Security Best Practices

1. **SSL/TLS**: Use modern TLS versions and strong ciphers
2. **Headers**: Implement security headers
3. **Access Control**: Restrict access to load balancer management
4. **DDoS Protection**: Implement rate limiting and DDoS protection
5. **Logging**: Log security events and monitor for anomalies
6. **Updates**: Keep load balancer software updated

---

## Key Takeaways

1. **Choose the Right Algorithm**: Select based on your specific requirements
2. **Health is Critical**: Implement robust health checking
3. **Plan for Failure**: Design failover and recovery procedures
4. **Monitor Everything**: Track performance and health metrics
5. **Security First**: Implement proper security measures
6. **Test Regularly**: Validate failover and performance scenarios
7. **Document Well**: Maintain clear documentation and procedures

---

**Previous**: [← Scalability Principles](2_ScalabilityPrinciples.md)  
**Next**: [Database Design →](4_DatabaseDesign.md)
