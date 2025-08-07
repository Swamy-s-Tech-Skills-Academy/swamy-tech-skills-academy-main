# 02_MCP-Server-Development

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Programming experience (Python/JavaScript), API development, MCP fundamentals  
**Estimated Time**: 90-120 minutes  

## 🎯 Learning Objectives

By the end of this content, you will:

- Build complete MCP servers from scratch using modern frameworks
- Implement core MCP protocol features including resources, tools, and prompts
- Design secure and scalable MCP server architectures
- Deploy MCP servers for production use with proper error handling
- Integrate custom business logic with MCP protocol requirements

---

## 📋 MCP Server Development Overview

Building an MCP server means creating a **protocol-compliant service** that exposes your data sources, APIs, or tools through the standardized MCP interface. Think of it as creating a **universal adapter** for your systems that any MCP client can understand and use.

### **Core Development Principles**

**Protocol Compliance**: Must implement required MCP methods and message formats
**Resource Abstraction**: Transform your data/tools into MCP resource concepts
**Security First**: Implement proper authentication, authorization, and validation
**Error Handling**: Provide clear, actionable error messages and recovery paths
**Performance**: Design for concurrent connections and efficient resource usage

---

## 🏗️ MCP Server Architecture Patterns

### **1. Resource Provider Pattern**

**Purpose**: Expose data sources as queryable MCP resources

**Use Cases**:

- Database connectors
- File system access
- API aggregators
- Content management systems

**Architecture**:

```text
MCP Client Request
       ↓
   [MCP Protocol Layer]
       ↓
   [Resource Manager]
       ↓
   [Data Source Adapter]
       ↓
   [Underlying System]
```

### **2. Tool Provider Pattern**

**Purpose**: Expose functions and operations as callable MCP tools

**Use Cases**:

- Workflow automation
- External API calls
- System operations
- Custom business logic

**Architecture**:

```text
MCP Client Tool Call
       ↓
   [MCP Protocol Layer]
       ↓
   [Tool Registry]
       ↓
   [Function Executor]
       ↓
   [Business Logic]
```

### **3. Hybrid Provider Pattern**

**Purpose**: Combine resources and tools in a single server

**Use Cases**:

- Complete system integrations
- Business application connectors
- Multi-functional service adapters

---

## 🔧 Implementation Guide: Python MCP Server

### **Setting Up the Development Environment**

```python
# requirements.txt
mcp-server>=0.1.0
pydantic>=2.0.0
asyncio-mqtt>=0.11.0
python-dotenv>=1.0.0
```

```python
# mcp_server.py - Basic Server Structure
import asyncio
from mcp.server import MCPServer
from mcp.types import Resource, Tool, TextContent
from typing import List, Dict, Any

class CustomMCPServer:
    def __init__(self):
        self.server = MCPServer("custom-server", "1.0.0")
        self.setup_handlers()
    
    def setup_handlers(self):
        # Register protocol handlers
        self.server.list_resources = self.list_resources
        self.server.read_resource = self.read_resource
        self.server.list_tools = self.list_tools
        self.server.call_tool = self.call_tool
    
    async def list_resources(self) -> List[Resource]:
        """Return available resources"""
        return [
            Resource(
                uri="custom://database/customers",
                name="Customer Database",
                description="Access to customer records",
                mimeType="application/json"
            ),
            Resource(
                uri="custom://api/orders",
                name="Order API",
                description="Real-time order information",
                mimeType="application/json"
            )
        ]
    
    async def read_resource(self, uri: str) -> str:
        """Read specific resource content"""
        if uri == "custom://database/customers":
            return await self.get_customer_data()
        elif uri == "custom://api/orders":
            return await self.get_order_data()
        else:
            raise ValueError(f"Unknown resource: {uri}")
    
    async def list_tools(self) -> List[Tool]:
        """Return available tools"""
        return [
            Tool(
                name="send_email",
                description="Send email to customer",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "to": {"type": "string"},
                        "subject": {"type": "string"},
                        "body": {"type": "string"}
                    },
                    "required": ["to", "subject", "body"]
                }
            )
        ]
    
    async def call_tool(self, name: str, arguments: Dict[str, Any]) -> TextContent:
        """Execute tool with given arguments"""
        if name == "send_email":
            return await self.send_email_tool(arguments)
        else:
            raise ValueError(f"Unknown tool: {name}")
    
    # Business logic implementations
    async def get_customer_data(self) -> str:
        # Connect to database and return customer data
        # This is where you implement your actual data access
        customers = [
            {"id": 1, "name": "John Doe", "email": "john@example.com"},
            {"id": 2, "name": "Jane Smith", "email": "jane@example.com"}
        ]
        return json.dumps(customers)
    
    async def get_order_data(self) -> str:
        # Connect to order API and return data
        orders = [
            {"id": 101, "customer_id": 1, "status": "shipped"},
            {"id": 102, "customer_id": 2, "status": "processing"}
        ]
        return json.dumps(orders)
    
    async def send_email_tool(self, args: Dict[str, Any]) -> TextContent:
        # Implement email sending logic
        # This could integrate with SendGrid, SES, etc.
        result = f"Email sent to {args['to']} with subject '{args['subject']}'"
        return TextContent(type="text", text=result)
    
    async def run(self, port: int = 3000):
        """Start the MCP server"""
        await self.server.run(port=port)

# Run the server
if __name__ == "__main__":
    server = CustomMCPServer()
    asyncio.run(server.run())
```

### **Advanced Server Features**

#### **Authentication and Security**

```python
class SecureMCPServer(CustomMCPServer):
    def __init__(self, api_key: str):
        super().__init__()
        self.api_key = api_key
        self.server.authenticate = self.authenticate_client
    
    async def authenticate_client(self, credentials: Dict[str, Any]) -> bool:
        """Validate client credentials"""
        provided_key = credentials.get('api_key')
        return provided_key == self.api_key
    
    async def authorize_resource(self, uri: str, client_id: str) -> bool:
        """Check if client can access specific resource"""
        # Implement role-based access control
        client_permissions = await self.get_client_permissions(client_id)
        return self.check_resource_permission(uri, client_permissions)
```

#### **Error Handling and Logging**

```python
import logging
from mcp.exceptions import MCPError

class RobustMCPServer(SecureMCPServer):
    def __init__(self, api_key: str):
        super().__init__(api_key)
        self.setup_logging()
    
    def setup_logging(self):
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
    
    async def read_resource(self, uri: str) -> str:
        """Read resource with comprehensive error handling"""
        try:
            self.logger.info(f"Reading resource: {uri}")
            
            if not await self.authorize_resource(uri, self.current_client_id):
                raise MCPError("Unauthorized access to resource", code=-32001)
            
            result = await super().read_resource(uri)
            self.logger.info(f"Successfully read resource: {uri}")
            return result
            
        except ValueError as e:
            self.logger.error(f"Resource not found: {uri}")
            raise MCPError(f"Resource not found: {uri}", code=-32002)
        except Exception as e:
            self.logger.error(f"Error reading resource {uri}: {str(e)}")
            raise MCPError("Internal server error", code=-32603)
```

#### **Performance Optimization**

```python
import asyncio
from asyncio import Semaphore
from functools import lru_cache
import time

class PerformantMCPServer(RobustMCPServer):
    def __init__(self, api_key: str, max_concurrent: int = 10):
        super().__init__(api_key)
        self.semaphore = Semaphore(max_concurrent)
        self.cache_ttl = 300  # 5 minutes
    
    @lru_cache(maxsize=128)
    async def cached_read_resource(self, uri: str, timestamp: int) -> str:
        """Cache resource data with TTL"""
        return await super().read_resource(uri)
    
    async def read_resource(self, uri: str) -> str:
        """Rate-limited resource reading with caching"""
        async with self.semaphore:
            # Use timestamp for cache invalidation
            cache_key = int(time.time() // self.cache_ttl)
            return await self.cached_read_resource(uri, cache_key)
```

---

## 🔧 Implementation Guide: JavaScript/Node.js MCP Server

### **TypeScript MCP Server Implementation**

```typescript
// package.json dependencies
{
  "dependencies": {
    "@anthropic/mcp-sdk": "^0.1.0",
    "express": "^4.18.0",
    "zod": "^3.22.0"
  }
}
```

```typescript
// server.ts
import { MCPServer } from '@anthropic/mcp-sdk';
import { z } from 'zod';

interface CustomerData {
  id: number;
  name: string;
  email: string;
  orders?: OrderData[];
}

interface OrderData {
  id: number;
  customerId: number;
  status: string;
  amount: number;
}

class TypeScriptMCPServer {
  private server: MCPServer;
  private customers: CustomerData[] = [];
  private orders: OrderData[] = [];

  constructor() {
    this.server = new MCPServer('typescript-server', '1.0.0');
    this.setupHandlers();
    this.loadSampleData();
  }

  private setupHandlers(): void {
    this.server.addResourceHandler('customers', this.getCustomers.bind(this));
    this.server.addResourceHandler('orders', this.getOrders.bind(this));
    
    this.server.addTool({
      name: 'create_customer',
      description: 'Create a new customer record',
      parameters: z.object({
        name: z.string(),
        email: z.string().email(),
      }),
      handler: this.createCustomer.bind(this),
    });

    this.server.addTool({
      name: 'place_order',
      description: 'Place a new order for a customer',
      parameters: z.object({
        customerId: z.number(),
        amount: z.number().positive(),
      }),
      handler: this.placeOrder.bind(this),
    });
  }

  private async getCustomers(): Promise<string> {
    return JSON.stringify(this.customers, null, 2);
  }

  private async getOrders(): Promise<string> {
    return JSON.stringify(this.orders, null, 2);
  }

  private async createCustomer(params: { name: string; email: string }): Promise<string> {
    const newCustomer: CustomerData = {
      id: this.customers.length + 1,
      name: params.name,
      email: params.email,
    };

    this.customers.push(newCustomer);
    return `Customer created successfully: ${JSON.stringify(newCustomer)}`;
  }

  private async placeOrder(params: { customerId: number; amount: number }): Promise<string> {
    const customer = this.customers.find(c => c.id === params.customerId);
    
    if (!customer) {
      throw new Error(`Customer with ID ${params.customerId} not found`);
    }

    const newOrder: OrderData = {
      id: this.orders.length + 1,
      customerId: params.customerId,
      status: 'pending',
      amount: params.amount,
    };

    this.orders.push(newOrder);
    return `Order placed successfully: ${JSON.stringify(newOrder)}`;
  }

  private loadSampleData(): void {
    this.customers = [
      { id: 1, name: 'John Doe', email: 'john@example.com' },
      { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
    ];

    this.orders = [
      { id: 1, customerId: 1, status: 'completed', amount: 99.99 },
      { id: 2, customerId: 2, status: 'shipped', amount: 149.99 },
    ];
  }

  public async start(port: number = 3000): Promise<void> {
    await this.server.listen(port);
    console.log(`MCP Server running on port ${port}`);
  }
}

// Start the server
const server = new TypeScriptMCPServer();
server.start().catch(console.error);
```

---

## 🗄️ Database Integration Patterns

### **SQL Database MCP Server**

```python
import asyncpg
from typing import Optional

class DatabaseMCPServer(CustomMCPServer):
    def __init__(self, database_url: str):
        super().__init__()
        self.database_url = database_url
        self.pool: Optional[asyncpg.Pool] = None
    
    async def start(self):
        """Initialize database connection pool"""
        self.pool = await asyncpg.create_pool(self.database_url)
    
    async def list_resources(self) -> List[Resource]:
        """Dynamically discover database tables as resources"""
        async with self.pool.acquire() as connection:
            tables = await connection.fetch("""
                SELECT table_name FROM information_schema.tables 
                WHERE table_schema = 'public'
            """)
            
            return [
                Resource(
                    uri=f"database://tables/{table['table_name']}",
                    name=f"Table: {table['table_name']}",
                    description=f"Access to {table['table_name']} table",
                    mimeType="application/json"
                )
                for table in tables
            ]
    
    async def read_resource(self, uri: str) -> str:
        """Query database table based on URI"""
        if not uri.startswith("database://tables/"):
            raise ValueError("Invalid database URI")
        
        table_name = uri.split("/")[-1]
        
        # Validate table name to prevent SQL injection
        if not table_name.isalnum():
            raise ValueError("Invalid table name")
        
        async with self.pool.acquire() as connection:
            rows = await connection.fetch(f"SELECT * FROM {table_name} LIMIT 100")
            return json.dumps([dict(row) for row in rows])
```

### **API Aggregation MCP Server**

```python
import aiohttp
from typing import Dict, List

class APIAggregatorMCPServer(CustomMCPServer):
    def __init__(self, api_configs: Dict[str, str]):
        super().__init__()
        self.api_configs = api_configs  # {name: base_url}
        self.session: Optional[aiohttp.ClientSession] = None
    
    async def start(self):
        """Initialize HTTP session"""
        self.session = aiohttp.ClientSession()
    
    async def list_resources(self) -> List[Resource]:
        """List all configured API endpoints as resources"""
        resources = []
        for api_name, base_url in self.api_configs.items():
            resources.append(Resource(
                uri=f"api://{api_name}/health",
                name=f"{api_name} Health Check",
                description=f"Health status of {api_name} API",
                mimeType="application/json"
            ))
            resources.append(Resource(
                uri=f"api://{api_name}/data",
                name=f"{api_name} Data",
                description=f"Data from {api_name} API",
                mimeType="application/json"
            ))
        return resources
    
    async def read_resource(self, uri: str) -> str:
        """Fetch data from external API"""
        parts = uri.split("/")
        if len(parts) < 3 or parts[0] != "api:":
            raise ValueError("Invalid API URI")
        
        api_name = parts[1]
        endpoint = "/".join(parts[2:])
        
        if api_name not in self.api_configs:
            raise ValueError(f"Unknown API: {api_name}")
        
        url = f"{self.api_configs[api_name]}/{endpoint}"
        
        async with self.session.get(url) as response:
            if response.status == 200:
                data = await response.json()
                return json.dumps(data)
            else:
                raise ValueError(f"API request failed: {response.status}")
```

---

## 🚀 Production Deployment Strategies

### **Docker Containerization**

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 3000

CMD ["python", "mcp_server.py"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  mcp-server:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mcpdb
      - API_KEY=${MCP_API_KEY}
    depends_on:
      - db
    restart: unless-stopped
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=mcpdb
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

### **Health Monitoring and Metrics**

```python
from prometheus_client import Counter, Histogram, start_http_server

class MonitoredMCPServer(PerformantMCPServer):
    def __init__(self, api_key: str):
        super().__init__(api_key)
        self.setup_metrics()
    
    def setup_metrics(self):
        self.request_count = Counter('mcp_requests_total', 'Total MCP requests', ['method', 'status'])
        self.request_duration = Histogram('mcp_request_duration_seconds', 'Request duration')
        
        # Start Prometheus metrics server
        start_http_server(8000)
    
    async def read_resource(self, uri: str) -> str:
        """Monitored resource reading"""
        with self.request_duration.time():
            try:
                result = await super().read_resource(uri)
                self.request_count.labels(method='read_resource', status='success').inc()
                return result
            except Exception as e:
                self.request_count.labels(method='read_resource', status='error').inc()
                raise
```

---

## 🔗 Related Topics

### **Prerequisites**

- **[01_MCP-Fundamentals](01_MCP-Fundamentals.md)** - Understanding MCP protocol and architecture
- **[01_Development/01_Python/01_Fundamentals/](../../01_Development/01_Python/01_Fundamentals/)** - Python programming foundation

### **Related**

- **[03_MCP-Client-Integration](03_MCP-Client-Integration.md)** - Building MCP clients
- **[04_Production-MCP-Patterns](04_Production-MCP-Patterns.md)** - Enterprise deployment

### **Advanced**

- **[05_MCP-Agent-Integration](05_MCP-Agent-Integration.md)** - AI agent integration patterns
- **[06_MCP-Security-Best-Practices](06_MCP-Security-Best-Practices.md)** - Security implementation

---

## 🚀 Next Steps

1. **Build Your First Server**: Implement a simple file system MCP server
2. **Add Business Logic**: Integrate with your existing data sources
3. **Implement Security**: Add authentication and authorization
4. **Production Deploy**: Container deployment with monitoring
5. **Community Contribution**: Share your server implementation

---

**💡 Key Takeaway**: MCP server development transforms any data source or tool into a universally accessible service. Focus on protocol compliance, security, and performance to build servers that AI applications can reliably depend on.
