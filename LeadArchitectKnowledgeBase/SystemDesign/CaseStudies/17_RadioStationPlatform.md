# Case Study: Radio Station Platform

## Overview

Design a scalable web application for a radio station that serves users across India with state-specific program information, user engagement features, and administrative capabilities. The system needs to handle real-time program updates, user comments, and geographic distribution efficiently.

## Table of Contents
1. [Problem Statement](#problem-statement)
2. [Requirements Gathering](#requirements-gathering)
3. [Capacity Estimation](#capacity-estimation)
4. [High-Level Architecture](#high-level-architecture)
5. [Detailed Design](#detailed-design)
6. [Database Design](#database-design)
7. [API Design](#api-design)
8. [Scalability Considerations](#scalability-considerations)
9. [Security & Reliability](#security--reliability)
10. [Monitoring & Observability](#monitoring--observability)
11. [Implementation Roadmap](#implementation-roadmap)

---

## Problem Statement

Design a web application for a radio station that:
- Displays live program information across different states in India
- Automatically removes programs from display when they end
- Allows user authentication and commenting on live programs
- Provides administrative interface for program management
- Handles geographic distribution and state-specific content
- Scales to support millions of users across India

**Key Challenges:**
- Real-time program updates and removal
- Geographic distribution across Indian states
- High read load for program information
- User engagement through comments
- Administrative content management
- Fault tolerance and high availability

---

## Requirements Gathering

### Functional Requirements

**User Features:**
- User registration and authentication
- View live programs filtered by state/country
- Comment on active programs
- Real-time updates when programs start/end
- Mobile-responsive interface

**Admin Features:**
- Create, update, delete program schedules
- Manage program metadata (title, description, duration)
- View user engagement analytics
- Content moderation for comments
- State-specific program assignment

**System Features:**
- Automatic program lifecycle management
- Real-time program status updates
- Geographic content distribution
- Comment notifications and moderation
- Search functionality for programs

### Non-Functional Requirements

**Performance:**
- Response time < 200ms for program listings
- Support 10,000 concurrent users per state
- 99.9% uptime SLA
- Real-time program updates within 5 seconds

**Scalability:**
- Support 50 million users across India
- Handle 1000 programs per state simultaneously
- Scale to 100,000 comments per hour
- Geographic distribution across Indian regions

**Security:**
- Secure user authentication and authorization
- Data encryption in transit and at rest
- Protection against common web vulnerabilities
- Admin access controls and audit logging

**Reliability:**
- Automatic failover capabilities
- Data backup and disaster recovery
- Graceful degradation during outages
- Circuit breakers and retry mechanisms

---

## Capacity Estimation

### User Traffic Analysis
```
Assumptions:
- Total users: 50 million
- Daily active users: 10 million (20%)
- Peak concurrent users: 500,000 (5% of DAU)
- Average session duration: 30 minutes
- Peak traffic during evening hours (6-10 PM)

Read/Write Ratio:
- Program views: 90% reads, 10% writes
- Comments: 80% reads, 20% writes
- Admin operations: 95% reads, 5% writes
```

### Request Patterns
```
Program Listings:
- Average RPS: 10M DAU × 20 requests/day ÷ 86,400 = ~2,300 RPS
- Peak RPS: 2,300 × 5 = 11,500 RPS

Comments:
- Average comments: 1M comments/day = ~12 RPS
- Peak comment RPS: 12 × 5 = 60 RPS

Admin Operations:
- Program updates: 1,000 programs × 5 updates/day = 5,000 ops/day = ~0.06 RPS
- Peak admin RPS: 0.06 × 10 = 0.6 RPS
```

### Storage Estimation
```
Program Data:
- 35 states × 1,000 programs/state = 35,000 programs
- Program metadata: 5KB per program
- Total program storage: 35,000 × 5KB = 175MB

User Data:
- 50M users × 2KB/user = 100GB user data
- User sessions: 500K concurrent × 1KB = 500MB

Comments:
- 1M comments/day × 365 days = 365M comments/year
- Comment size: 500 bytes average
- Annual comment storage: 365M × 500B = 183GB

Media Assets:
- Program images: 35,000 × 100KB = 3.5GB
- Static assets: ~1GB
- Total media: ~5GB
```

### Bandwidth Requirements
```
Peak Bandwidth:
- Program API responses: 11,500 RPS × 10KB = 115MB/s
- Comment API responses: 60 RPS × 2KB = 120KB/s
- Static assets via CDN: 50MB/s
- Total peak bandwidth: ~165MB/s
```

---

## High-Level Architecture

```
[Internet Users] 
       ↓
[CDN (CloudFlare/Azure CDN)]
       ↓
[Web Application Firewall]
       ↓
[Load Balancer (Geographic Distribution)]
       ↓
┌─────────────────────────────────────────────────────────┐
│                 DMZ Layer                               │
├─────────────────────────────────────────────────────────┤
│  [API Gateway (Rate Limiting, Auth, Routing)]          │
└─────────────────────────────────────────────────────────┘
       ↓
┌─────────────────────────────────────────────────────────┐
│               Application Layer                         │
├─────────────────────────────────────────────────────────┤
│  [User API]  [Admin API]  [Program API]  [Comment API] │
│       ↓           ↓            ↓             ↓         │
│  [Auth Service] [Program Service] [Comment Service]    │
└─────────────────────────────────────────────────────────┘
       ↓
┌─────────────────────────────────────────────────────────┐
│               Caching Layer                             │
├─────────────────────────────────────────────────────────┤
│     [Redis Cluster (Program Cache, Session Cache)]     │
└─────────────────────────────────────────────────────────┘
       ↓
┌─────────────────────────────────────────────────────────┐
│               Data Layer                                │
├─────────────────────────────────────────────────────────┤
│ [PostgreSQL Cluster] [MongoDB Cluster] [Elasticsearch] │
│  (Programs, Users)    (Comments, Logs)   (Search)      │
└─────────────────────────────────────────────────────────┘
       ↓
┌─────────────────────────────────────────────────────────┐
│            Message Queue Layer                          │
├─────────────────────────────────────────────────────────┤
│     [Kafka/RabbitMQ (Events, Notifications)]           │
└─────────────────────────────────────────────────────────┘
```

### Geographic Distribution
```
Regional Deployment:
- North India: Delhi/NCR (Primary)
- South India: Bangalore (Secondary)
- West India: Mumbai (Secondary)
- East India: Kolkata (Cache Layer)

CDN Edge Locations:
- 15+ edge locations across Indian cities
- Static asset caching
- API response caching for read-heavy endpoints
```

---

## Detailed Design

### 1. Frontend Architecture

**Web Application (React/Vue.js)**
```javascript
// Component Structure
src/
├── components/
│   ├── ProgramList/
│   │   ├── ProgramCard.jsx
│   │   ├── StateFilter.jsx
│   │   └── LiveIndicator.jsx
│   ├── Comments/
│   │   ├── CommentList.jsx
│   │   ├── CommentForm.jsx
│   │   └── CommentModeration.jsx
│   └── Admin/
│       ├── ProgramManager.jsx
│       ├── ScheduleEditor.jsx
│       └── Analytics.jsx
├── services/
│   ├── api.js
│   ├── auth.js
│   └── websocket.js
└── store/
    ├── programs.js
    ├── comments.js
    └── user.js

// Real-time Updates
const useWebSocket = (url) => {
  const [socket, setSocket] = useState(null);
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    const ws = new WebSocket(url);
    
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.type === 'PROGRAM_ENDED') {
        // Remove program from UI
        dispatch(removeProgramFromList(data.programId));
      } else if (data.type === 'PROGRAM_STARTED') {
        // Add new program to UI
        dispatch(addProgramToList(data.program));
      }
    };
    
    setSocket(ws);
    return () => ws.close();
  }, [url]);

  return { socket, messages };
};
```

**Mobile Application (React Native/Flutter)**
```dart
// Flutter implementation for mobile
class ProgramListWidget extends StatefulWidget {
  @override
  _ProgramListWidgetState createState() => _ProgramListWidgetState();
}

class _ProgramListWidgetState extends State<ProgramListWidget> {
  late StreamSubscription _programSubscription;
  List<Program> programs = [];

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _loadPrograms();
  }

  void _connectToWebSocket() {
    final channel = WebSocketChannel.connect(
      Uri.parse('wss://api.radiostation.com/ws'),
    );
    
    _programSubscription = channel.stream.listen((data) {
      final event = json.decode(data);
      if (event['type'] == 'PROGRAM_UPDATE') {
        setState(() {
          _updateProgramList(event['data']);
        });
      }
    });
  }
}
```

### 2. API Gateway Design

**Configuration (Kong/AWS API Gateway)**
```yaml
# Kong Configuration
services:
  - name: program-service
    url: http://program-api:8080
    routes:
      - name: programs
        paths: ["/api/programs"]
        methods: ["GET", "POST", "PUT", "DELETE"]
        plugins:
          - name: rate-limiting
            config:
              minute: 1000
              hour: 10000
          - name: jwt
            config:
              secret_is_base64: false
          - name: cors
            config:
              origins: ["https://radiostation.com"]

  - name: comment-service
    url: http://comment-api:8080
    routes:
      - name: comments
        paths: ["/api/comments"]
        plugins:
          - name: rate-limiting
            config:
              minute: 100
              hour: 1000
```

**Circuit Breaker Implementation**
```javascript
// Node.js with Express and opossum
const CircuitBreaker = require('opossum');

const options = {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000
};

const breaker = new CircuitBreaker(callProgramService, options);

breaker.fallback(() => {
  return getCachedPrograms();
});

app.get('/api/programs', async (req, res) => {
  try {
    const programs = await breaker.fire(req.query);
    res.json(programs);
  } catch (error) {
    res.status(503).json({ error: 'Service temporarily unavailable' });
  }
});
```

### 3. Microservices Architecture

**Program Service**
```python
# FastAPI implementation
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
import redis
import json

app = FastAPI()
redis_client = redis.Redis(host='redis-cluster', port=6379)

@app.get("/programs/state/{state_id}")
async def get_programs_by_state(
    state_id: str,
    page: int = 1,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    # Check cache first
    cache_key = f"programs:state:{state_id}:page:{page}"
    cached_result = redis_client.get(cache_key)
    
    if cached_result:
        return json.loads(cached_result)
    
    # Query database
    programs = db.query(Program)\
        .filter(Program.state_id == state_id)\
        .filter(Program.status == 'live')\
        .offset((page - 1) * limit)\
        .limit(limit)\
        .all()
    
    result = {
        "programs": [program.to_dict() for program in programs],
        "total": len(programs),
        "page": page
    }
    
    # Cache for 60 seconds
    redis_client.setex(cache_key, 60, json.dumps(result))
    
    return result

@app.post("/programs/{program_id}/end")
async def end_program(
    program_id: str,
    db: Session = Depends(get_db)
):
    program = db.query(Program).filter(Program.id == program_id).first()
    if not program:
        raise HTTPException(status_code=404, detail="Program not found")
    
    program.status = 'ended'
    program.ended_at = datetime.utcnow()
    db.commit()
    
    # Invalidate cache
    redis_client.delete(f"programs:state:{program.state_id}:*")
    
    # Send event to message queue
    await send_program_ended_event(program_id)
    
    return {"message": "Program ended successfully"}
```

**Comment Service**
```javascript
// Node.js with Express and MongoDB
const express = require('express');
const mongoose = require('mongoose');
const app = express();

const commentSchema = new mongoose.Schema({
  programId: String,
  userId: String,
  content: String,
  createdAt: { type: Date, default: Date.now },
  moderated: { type: Boolean, default: false },
  state: String
});

const Comment = mongoose.model('Comment', commentSchema);

app.post('/comments', async (req, res) => {
  try {
    const { programId, userId, content, state } = req.body;
    
    // Validate program is still live
    const program = await checkProgramStatus(programId);
    if (!program || program.status !== 'live') {
      return res.status(400).json({ error: 'Cannot comment on ended program' });
    }
    
    const comment = new Comment({
      programId,
      userId,
      content,
      state,
      moderated: false
    });
    
    await comment.save();
    
    // Send to moderation queue
    await sendToModerationQueue(comment);
    
    // Real-time notification
    await notifyWebSocketClients({
      type: 'NEW_COMMENT',
      programId,
      comment: comment.toObject()
    });
    
    res.status(201).json(comment);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/comments/program/:programId', async (req, res) => {
  try {
    const { programId } = req.params;
    const { page = 1, limit = 20 } = req.query;
    
    const comments = await Comment.find({
      programId,
      moderated: true
    })
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(parseInt(limit));
    
    res.json(comments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### 4. Real-time Updates with WebSocket

**WebSocket Server (Node.js)**
```javascript
const WebSocket = require('ws');
const redis = require('redis');

class WebSocketManager {
  constructor() {
    this.wss = new WebSocket.Server({ port: 8080 });
    this.clients = new Map(); // userId -> WebSocket
    this.subscriber = redis.createClient();
    this.setupEventHandlers();
  }

  setupEventHandlers() {
    this.wss.on('connection', (ws, req) => {
      const userId = this.extractUserId(req);
      this.clients.set(userId, ws);
      
      ws.on('close', () => {
        this.clients.delete(userId);
      });
      
      ws.on('message', (message) => {
        const data = JSON.parse(message);
        this.handleClientMessage(userId, data);
      });
    });

    // Subscribe to Redis events
    this.subscriber.subscribe('program_events');
    this.subscriber.on('message', (channel, message) => {
      const event = JSON.parse(message);
      this.broadcastEvent(event);
    });
  }

  broadcastEvent(event) {
    const message = JSON.stringify(event);
    
    this.clients.forEach((ws, userId) => {
      if (ws.readyState === WebSocket.OPEN) {
        // Filter events by user's state preference
        if (this.shouldSendToUser(userId, event)) {
          ws.send(message);
        }
      }
    });
  }

  shouldSendToUser(userId, event) {
    // Check user's state preference
    const userState = this.getUserState(userId);
    return !event.state || event.state === userState;
  }
}

const wsManager = new WebSocketManager();
```

---

## Database Design

### 1. PostgreSQL Schema (Primary Database)

```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    state_preference VARCHAR(50),
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- States table
CREATE TABLE states (
    id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50),
    time_zone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Programs table
CREATE TABLE programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    state_id VARCHAR(10) REFERENCES states(id),
    category VARCHAR(100),
    host_name VARCHAR(255),
    scheduled_start TIMESTAMP NOT NULL,
    scheduled_end TIMESTAMP NOT NULL,
    actual_start TIMESTAMP,
    actual_end TIMESTAMP,
    status VARCHAR(20) DEFAULT 'scheduled', -- scheduled, live, ended, cancelled
    image_url VARCHAR(500),
    tags TEXT[],
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Program schedules (for recurring programs)
CREATE TABLE program_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_template_id UUID,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    state_id VARCHAR(10) REFERENCES states(id),
    day_of_week INTEGER, -- 0=Sunday, 1=Monday, etc.
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_programs_state_status ON programs(state_id, status);
CREATE INDEX idx_programs_scheduled_start ON programs(scheduled_start);
CREATE INDEX idx_programs_status_time ON programs(status, scheduled_start, scheduled_end);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_state ON users(state_preference);
```

### 2. MongoDB Schema (Comments and Analytics)

```javascript
// Comments collection
{
  _id: ObjectId,
  programId: String,
  userId: String,
  username: String,
  content: String,
  state: String,
  createdAt: Date,
  updatedAt: Date,
  moderated: Boolean,
  moderatedBy: String,
  moderatedAt: Date,
  flagged: Boolean,
  flagReason: String,
  likes: Number,
  replies: [
    {
      userId: String,
      username: String,
      content: String,
      createdAt: Date
    }
  ]
}

// Program analytics collection
{
  _id: ObjectId,
  programId: String,
  state: String,
  date: Date,
  metrics: {
    viewCount: Number,
    uniqueViewers: Number,
    commentCount: Number,
    averageViewDuration: Number,
    peakConcurrentViewers: Number,
    engagementRate: Number
  },
  hourlyBreakdown: [
    {
      hour: Number,
      viewers: Number,
      comments: Number
    }
  ]
}

// User activity collection
{
  _id: ObjectId,
  userId: String,
  sessionId: String,
  state: String,
  activities: [
    {
      type: String, // 'program_view', 'comment_post', 'like', 'share'
      programId: String,
      timestamp: Date,
      metadata: Object
    }
  ],
  startTime: Date,
  endTime: Date
}
```

### 3. Redis Cache Structure

```redis
# Program cache
programs:state:{state_id}:live -> JSON array of live programs
programs:state:{state_id}:page:{page} -> Paginated program list
program:{program_id} -> Individual program details

# User session cache
session:{user_id} -> User session data
user:{user_id}:preferences -> User preferences

# Comment cache
comments:program:{program_id}:page:{page} -> Paginated comments
comments:recent:{state_id} -> Recent comments for state

# Rate limiting
rate_limit:user:{user_id}:comments -> Comment rate limit counter
rate_limit:ip:{ip_address}:api -> API rate limit counter

# Real-time data
live_programs:{state_id} -> Set of currently live program IDs
user_states -> Hash of user_id -> preferred_state
```

---

## API Design

### 1. User APIs

```yaml
# OpenAPI 3.0 specification
paths:
  /api/programs/state/{stateId}:
    get:
      summary: Get programs by state
      parameters:
        - name: stateId
          in: path
          required: true
          schema:
            type: string
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
        - name: status
          in: query
          schema:
            type: string
            enum: [live, scheduled, ended]
      responses:
        '200':
          description: List of programs
          content:
            application/json:
              schema:
                type: object
                properties:
                  programs:
                    type: array
                    items:
                      $ref: '#/components/schemas/Program'
                  total:
                    type: integer
                  page:
                    type: integer
                  hasMore:
                    type: boolean

  /api/programs/{programId}/comments:
    get:
      summary: Get comments for a program
      parameters:
        - name: programId
          in: path
          required: true
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: List of comments
          
    post:
      summary: Add comment to program
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                content:
                  type: string
                  maxLength: 500
              required:
                - content
      responses:
        '201':
          description: Comment created
        '429':
          description: Rate limit exceeded

  /api/user/preferences:
    get:
      summary: Get user preferences
      security:
        - bearerAuth: []
      responses:
        '200':
          description: User preferences
          
    put:
      summary: Update user preferences
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                statePreference:
                  type: string
                notifications:
                  type: boolean
```

### 2. Admin APIs

```yaml
  /api/admin/programs:
    post:
      summary: Create new program
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateProgramRequest'
      responses:
        '201':
          description: Program created
          
  /api/admin/programs/{programId}:
    put:
      summary: Update program
      security:
        - bearerAuth: []
      parameters:
        - name: programId
          in: path
          required: true
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateProgramRequest'
              
    delete:
      summary: Delete program
      security:
        - bearerAuth: []
      parameters:
        - name: programId
          in: path
          required: true
      responses:
        '204':
          description: Program deleted

  /api/admin/programs/{programId}/status:
    patch:
      summary: Update program status
      security:
        - bearerAuth: []
      parameters:
        - name: programId
          in: path
          required: true
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: string
                  enum: [live, ended, cancelled]
              required:
                - status

  /api/admin/analytics/programs:
    get:
      summary: Get program analytics
      security:
        - bearerAuth: []
      parameters:
        - name: startDate
          in: query
          schema:
            type: string
            format: date
        - name: endDate
          in: query
          schema:
            type: string
            format: date
        - name: stateId
          in: query
          schema:
            type: string
      responses:
        '200':
          description: Analytics data
```

### 3. WebSocket Events

```javascript
// Client to Server events
{
  type: 'SUBSCRIBE_STATE',
  payload: {
    stateId: 'MH' // Maharashtra
  }
}

{
  type: 'UNSUBSCRIBE_STATE',
  payload: {
    stateId: 'MH'
  }
}

// Server to Client events
{
  type: 'PROGRAM_STARTED',
  payload: {
    programId: 'prog-123',
    state: 'MH',
    program: {
      id: 'prog-123',
      title: 'Morning Raaga',
      host: 'RJ Priya',
      startTime: '2024-01-01T06:00:00Z'
    }
  }
}

{
  type: 'PROGRAM_ENDED',
  payload: {
    programId: 'prog-123',
    state: 'MH',
    endTime: '2024-01-01T08:00:00Z'
  }
}

{
  type: 'NEW_COMMENT',
  payload: {
    programId: 'prog-123',
    comment: {
      id: 'comment-456',
      userId: 'user-789',
      username: 'musiclover',
      content: 'Great song!',
      createdAt: '2024-01-01T07:30:00Z'
    }
  }
}

{
  type: 'PROGRAM_UPDATED',
  payload: {
    programId: 'prog-123',
    state: 'MH',
    updates: {
      title: 'Morning Raaga - Special Edition'
    }
  }
}
```

---

## Scalability Considerations

### 1. Horizontal Scaling

**Application Layer Scaling**
```yaml
# Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: program-service
spec:
  replicas: 10
  selector:
    matchLabels:
      app: program-service
  template:
    metadata:
      labels:
        app: program-service
    spec:
      containers:
      - name: program-service
        image: radiostation/program-service:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        env:
        - name: DB_CONNECTION_STRING
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: connection-string
---
apiVersion: v1
kind: Service
metadata:
  name: program-service
spec:
  selector:
    app: program-service
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

**Database Scaling Strategy**
```sql
-- Read replicas configuration
-- Master (Write operations)
CREATE ROLE program_writer;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO program_writer;

-- Read replicas (Read operations)
CREATE ROLE program_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO program_reader;

-- Connection routing in application
class DatabaseRouter:
    def __init__(self):
        self.master = connect_to_master()
        self.replicas = [
            connect_to_replica('replica1'),
            connect_to_replica('replica2'),
            connect_to_replica('replica3')
        ]
        self.replica_index = 0
    
    def execute_write(self, query, params):
        return self.master.execute(query, params)
    
    def execute_read(self, query, params):
        replica = self.replicas[self.replica_index]
        self.replica_index = (self.replica_index + 1) % len(self.replicas)
        return replica.execute(query, params)
```

### 2. Caching Strategy

**Multi-Level Caching**
```python
class CacheManager:
    def __init__(self):
        self.l1_cache = {}  # In-memory cache
        self.l2_cache = redis.Redis()  # Redis cache
        self.l3_cache = memcached.Client(['memcached:11211'])  # Memcached
    
    async def get_programs_by_state(self, state_id, page=1):
        cache_key = f"programs:{state_id}:page:{page}"
        
        # L1 Cache (In-memory)
        if cache_key in self.l1_cache:
            return self.l1_cache[cache_key]
        
        # L2 Cache (Redis)
        cached_data = self.l2_cache.get(cache_key)
        if cached_data:
            data = json.loads(cached_data)
            self.l1_cache[cache_key] = data  # Populate L1
            return data
        
        # L3 Cache (Memcached)
        cached_data = self.l3_cache.get(cache_key)
        if cached_data:
            data = json.loads(cached_data)
            self.l2_cache.setex(cache_key, 300, json.dumps(data))  # Populate L2
            self.l1_cache[cache_key] = data  # Populate L1
            return data
        
        # Cache miss - fetch from database
        data = await self.fetch_from_database(state_id, page)
        
        # Populate all cache levels
        self.l3_cache.set(cache_key, json.dumps(data), time=600)
        self.l2_cache.setex(cache_key, 300, json.dumps(data))
        self.l1_cache[cache_key] = data
        
        return data
```

### 3. CDN Strategy

**Static Asset Distribution**
```nginx
# NGINX configuration for CDN optimization
server {
    listen 80;
    server_name cdn.radiostation.com;
    
    # Program images
    location /images/ {
        root /var/www/static;
        expires 7d;
        add_header Cache-Control "public, immutable";
        add_header Vary "Accept-Encoding";
        
        # Image optimization
        location ~* \.(jpg|jpeg|png|webp)$ {
            try_files $uri $uri.webp $uri.jpg $uri.png =404;
        }
    }
    
    # API response caching
    location /api/programs/ {
        proxy_pass http://backend;
        proxy_cache api_cache;
        proxy_cache_valid 200 60s;
        proxy_cache_key "$scheme$request_method$host$request_uri";
        add_header X-Cache-Status $upstream_cache_status;
    }
    
    # WebSocket proxy
    location /ws {
        proxy_pass http://websocket_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 4. Database Sharding

**Geographic Sharding Strategy**
```python
class DatabaseShardManager:
    def __init__(self):
        self.shards = {
            'north': ['DL', 'PB', 'HR', 'UP', 'UK'],  # Delhi, Punjab, Haryana, UP, Uttarakhand
            'south': ['KA', 'TN', 'AP', 'TS', 'KL'],  # Karnataka, Tamil Nadu, Andhra Pradesh, Telangana, Kerala
            'west': ['MH', 'GJ', 'RJ', 'MP', 'GO'],   # Maharashtra, Gujarat, Rajasthan, Madhya Pradesh, Goa
            'east': ['WB', 'OR', 'JH', 'SK', 'AS']    # West Bengal, Odisha, Jharkhand, Sikkim, Assam
        }
        
        self.connections = {
            'north': connect_to_database('north_db'),
            'south': connect_to_database('south_db'),
            'west': connect_to_database('west_db'),
            'east': connect_to_database('east_db')
        }
    
    def get_shard_for_state(self, state_id):
        for region, states in self.shards.items():
            if state_id in states:
                return region
        return 'north'  # Default shard
    
    def get_connection(self, state_id):
        shard = self.get_shard_for_state(state_id)
        return self.connections[shard]
    
    async def get_programs_by_state(self, state_id):
        connection = self.get_connection(state_id)
        return await connection.fetch(
            "SELECT * FROM programs WHERE state_id = $1 AND status = 'live'",
            state_id
        )
```

---

## Security & Reliability

### 1. Authentication & Authorization

**JWT Token Implementation**
```python
import jwt
import bcrypt
from datetime import datetime, timedelta

class AuthService:
    def __init__(self, secret_key):
        self.secret_key = secret_key
        self.algorithm = 'HS256'
    
    def create_access_token(self, user_id, role='user'):
        payload = {
            'user_id': user_id,
            'role': role,
            'exp': datetime.utcnow() + timedelta(hours=1),
            'iat': datetime.utcnow(),
            'type': 'access'
        }
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
    
    def create_refresh_token(self, user_id):
        payload = {
            'user_id': user_id,
            'exp': datetime.utcnow() + timedelta(days=30),
            'iat': datetime.utcnow(),
            'type': 'refresh'
        }
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
    
    def verify_token(self, token):
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            return payload
        except jwt.ExpiredSignatureError:
            raise AuthError('Token has expired')
        except jwt.InvalidTokenError:
            raise AuthError('Invalid token')

# Role-based access control
class RoleBasedAuth:
    def __init__(self):
        self.permissions = {
            'user': ['read_programs', 'post_comments', 'read_comments'],
            'moderator': ['read_programs', 'post_comments', 'read_comments', 'moderate_comments'],
            'admin': ['*']  # All permissions
        }
    
    def check_permission(self, user_role, required_permission):
        if user_role not in self.permissions:
            return False
        
        user_permissions = self.permissions[user_role]
        return '*' in user_permissions or required_permission in user_permissions
```

### 2. Rate Limiting

**Redis-based Rate Limiting**
```python
import redis
import time
from functools import wraps

class RateLimiter:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def limit_requests(self, key, limit, window_seconds):
        """
        Sliding window rate limiting
        """
        now = time.time()
        window_start = now - window_seconds
        
        pipe = self.redis.pipeline()
        
        # Remove old entries
        pipe.zremrangebyscore(key, 0, window_start)
        
        # Count current requests
        pipe.zcard(key)
        
        # Add current request
        pipe.zadd(key, {str(now): now})
        
        # Set expiry
        pipe.expire(key, window_seconds)
        
        results = pipe.execute()
        
        current_requests = results[1]
        
        return current_requests < limit

def rate_limit(limit=100, window=3600, key_func=lambda: request.remote_addr):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            key = f"rate_limit:{key_func()}"
            
            if not rate_limiter.limit_requests(key, limit, window):
                return jsonify({'error': 'Rate limit exceeded'}), 429
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# Usage
@app.route('/api/comments', methods=['POST'])
@rate_limit(limit=10, window=60, key_func=lambda: get_jwt_identity())
def create_comment():
    # Comment creation logic
    pass
```

### 3. Input Validation & Sanitization

**Comprehensive Input Validation**
```python
from marshmallow import Schema, fields, validate, ValidationError
import bleach

class CommentSchema(Schema):
    content = fields.Str(
        required=True,
        validate=[
            validate.Length(min=1, max=500),
            validate.Regexp(r'^[a-zA-Z0-9\s\.,!?-]+$', error='Invalid characters')
        ]
    )
    program_id = fields.UUID(required=True)

class ProgramSchema(Schema):
    title = fields.Str(
        required=True,
        validate=validate.Length(min=1, max=255)
    )
    description = fields.Str(
        validate=validate.Length(max=1000)
    )
    state_id = fields.Str(
        required=True,
        validate=validate.Length(equal=2)
    )
    scheduled_start = fields.DateTime(required=True)
    scheduled_end = fields.DateTime(required=True)

def sanitize_html_content(content):
    """Remove potentially dangerous HTML/JavaScript"""
    allowed_tags = ['b', 'i', 'u', 'em', 'strong']
    return bleach.clean(content, tags=allowed_tags, strip=True)

def validate_and_sanitize_comment(data):
    schema = CommentSchema()
    try:
        validated_data = schema.load(data)
        validated_data['content'] = sanitize_html_content(validated_data['content'])
        return validated_data
    except ValidationError as err:
        raise ValueError(f"Validation error: {err.messages}")
```

### 4. Circuit Breaker Pattern

**Hystrix-style Circuit Breaker**
```python
import time
import threading
from enum import Enum

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"

class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60, expected_exception=Exception):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.expected_exception = expected_exception
        
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
        self.lock = threading.RLock()
    
    def call(self, func, *args, **kwargs):
        with self.lock:
            if self.state == CircuitState.OPEN:
                if time.time() - self.last_failure_time > self.recovery_timeout:
                    self.state = CircuitState.HALF_OPEN
                    self.failure_count = 0
                else:
                    raise Exception("Circuit breaker is OPEN")
            
            try:
                result = func(*args, **kwargs)
                self.on_success()
                return result
            except self.expected_exception as e:
                self.on_failure()
                raise e
    
    def on_success(self):
        self.failure_count = 0
        self.state = CircuitState.CLOSED
    
    def on_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = CircuitState.OPEN

# Usage with external service calls
program_service_breaker = CircuitBreaker(failure_threshold=3, recovery_timeout=30)

def get_external_program_data(program_id):
    try:
        return program_service_breaker.call(
            requests.get, 
            f"http://external-service/programs/{program_id}",
            timeout=5
        )
    except Exception as e:
        # Fallback to cached data
        return get_cached_program_data(program_id)
```

---

## Monitoring & Observability

### 1. Application Metrics

**Prometheus Metrics Collection**
```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest

# Custom metrics
program_views = Counter('program_views_total', 'Total program views', ['state', 'program_id'])
api_request_duration = Histogram('api_request_duration_seconds', 'API request duration', ['endpoint', 'method'])
active_websocket_connections = Gauge('active_websocket_connections', 'Active WebSocket connections', ['state'])
comment_creation_rate = Counter('comments_created_total', 'Total comments created', ['state'])

# Middleware for automatic metrics collection
def metrics_middleware(app):
    def middleware(environ, start_response):
        start_time = time.time()
        
        def new_start_response(status, response_headers):
            duration = time.time() - start_time
            endpoint = environ.get('PATH_INFO', '')
            method = environ.get('REQUEST_METHOD', '')
            
            api_request_duration.labels(endpoint=endpoint, method=method).observe(duration)
            return start_response(status, response_headers)
        
        return app(environ, new_start_response)
    return middleware

# Custom metric collection
class MetricsCollector:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def track_program_view(self, program_id, state, user_id):
        program_views.labels(state=state, program_id=program_id).inc()
        
        # Store detailed analytics
        key = f"analytics:program:{program_id}:{datetime.now().strftime('%Y-%m-%d-%H')}"
        self.redis.hincrby(key, 'views', 1)
        self.redis.sadd(f"analytics:program:{program_id}:unique_viewers", user_id)
        self.redis.expire(key, 86400 * 7)  # Keep for 7 days
    
    def track_websocket_connection(self, state, action='connect'):
        if action == 'connect':
            active_websocket_connections.labels(state=state).inc()
        elif action == 'disconnect':
            active_websocket_connections.labels(state=state).dec()
```

### 2. Distributed Tracing

**OpenTelemetry Implementation**
```python
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Initialize tracing
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger",
    agent_port=6831,
)

span_processor = BatchSpanProcessor(jaeger_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

# Trace API calls
@tracer.start_as_current_span("get_programs_by_state")
async def get_programs_by_state(state_id, page=1):
    span = trace.get_current_span()
    span.set_attribute("state_id", state_id)
    span.set_attribute("page", page)
    
    try:
        # Check cache
        with tracer.start_as_current_span("cache_lookup") as cache_span:
            cached_result = await get_from_cache(f"programs:{state_id}:{page}")
            cache_span.set_attribute("cache_hit", cached_result is not None)
        
        if cached_result:
            span.set_attribute("cache_hit", True)
            return cached_result
        
        # Database query
        with tracer.start_as_current_span("database_query") as db_span:
            programs = await database.fetch_programs(state_id, page)
            db_span.set_attribute("result_count", len(programs))
        
        # Update cache
        with tracer.start_as_current_span("cache_update"):
            await set_cache(f"programs:{state_id}:{page}", programs, ttl=60)
        
        span.set_attribute("result_count", len(programs))
        return programs
        
    except Exception as e:
        span.record_exception(e)
        span.set_status(trace.Status(trace.StatusCode.ERROR, str(e)))
        raise
```

### 3. Structured Logging

**Centralized Logging with ELK Stack**
```python
import structlog
import json
import sys

# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Usage in application
async def create_comment(program_id, user_id, content):
    request_id = generate_request_id()
    
    logger.info(
        "comment_creation_started",
        request_id=request_id,
        program_id=program_id,
        user_id=user_id,
        content_length=len(content)
    )
    
    try:
        # Validate program is live
        program = await get_program(program_id)
        if not program or program.status != 'live':
            logger.warning(
                "comment_creation_failed",
                request_id=request_id,
                reason="program_not_live",
                program_id=program_id,
                program_status=program.status if program else None
            )
            raise ValueError("Cannot comment on ended program")
        
        # Create comment
        comment = await Comment.create(
            program_id=program_id,
            user_id=user_id,
            content=content
        )
        
        logger.info(
            "comment_created",
            request_id=request_id,
            comment_id=comment.id,
            program_id=program_id,
            user_id=user_id
        )
        
        # Send to moderation queue
        await send_to_moderation_queue(comment.id)
        
        return comment
        
    except Exception as e:
        logger.error(
            "comment_creation_error",
            request_id=request_id,
            error=str(e),
            error_type=type(e).__name__,
            program_id=program_id,
            user_id=user_id
        )
        raise
```

### 4. Health Checks

**Comprehensive Health Check Implementation**
```python
from datetime import datetime
import asyncio

class HealthChecker:
    def __init__(self, database, redis, message_queue):
        self.database = database
        self.redis = redis
        self.message_queue = message_queue
    
    async def check_health(self):
        checks = await asyncio.gather(
            self.check_database(),
            self.check_redis(),
            self.check_message_queue(),
            self.check_external_services(),
            return_exceptions=True
        )
        
        database_health, redis_health, mq_health, external_health = checks
        
        overall_status = "healthy"
        if any(check.get("status") == "unhealthy" for check in [database_health, redis_health, mq_health]):
            overall_status = "unhealthy"
        elif any(check.get("status") == "degraded" for check in [database_health, redis_health, mq_health, external_health]):
            overall_status = "degraded"
        
        return {
            "status": overall_status,
            "timestamp": datetime.utcnow().isoformat(),
            "checks": {
                "database": database_health,
                "redis": redis_health,
                "message_queue": mq_health,
                "external_services": external_health
            }
        }
    
    async def check_database(self):
        try:
            start_time = time.time()
            await self.database.execute("SELECT 1")
            duration = time.time() - start_time
            
            return {
                "status": "healthy" if duration < 0.1 else "degraded",
                "response_time": duration,
                "details": "Database connection successful"
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "details": "Database connection failed"
            }
    
    async def check_redis(self):
        try:
            start_time = time.time()
            await self.redis.ping()
            duration = time.time() - start_time
            
            return {
                "status": "healthy" if duration < 0.05 else "degraded",
                "response_time": duration,
                "details": "Redis connection successful"
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "details": "Redis connection failed"
            }

# Health check endpoint
@app.route('/health')
async def health_check():
    health_checker = HealthChecker(database, redis, message_queue)
    health_status = await health_checker.check_health()
    
    status_code = 200
    if health_status["status"] == "unhealthy":
        status_code = 503
    elif health_status["status"] == "degraded":
        status_code = 200  # Still serving traffic
    
    return jsonify(health_status), status_code
```

---

## Implementation Roadmap

### Phase 1: MVP (Months 1-3)

**Core Infrastructure**
- [ ] Set up PostgreSQL database with basic schema
- [ ] Implement user authentication (JWT-based)
- [ ] Create basic REST APIs for programs and comments
- [ ] Build simple web frontend (React)
- [ ] Deploy on single cloud region

**Features Delivered:**
- User registration and login
- View live programs by state
- Basic commenting functionality
- Admin program management
- Basic monitoring setup

### Phase 2: Scaling & Real-time (Months 4-6)

**Performance & Real-time**
- [ ] Implement Redis caching layer
- [ ] Add WebSocket support for real-time updates
- [ ] Set up CDN for static assets
- [ ] Implement database read replicas
- [ ] Add API rate limiting

**Features Delivered:**
- Real-time program updates
- Improved response times
- Basic scalability improvements
- Enhanced admin analytics
- Mobile-responsive design

### Phase 3: Advanced Features (Months 7-9)

**Advanced Functionality**
- [ ] Implement MongoDB for comments and analytics
- [ ] Add Elasticsearch for search functionality
- [ ] Set up message queue (Kafka/RabbitMQ)
- [ ] Implement comment moderation
- [ ] Add push notifications

**Features Delivered:**
- Advanced search capabilities
- Comment moderation tools
- Push notifications
- Better analytics dashboard
- Performance optimizations

### Phase 4: Enterprise Scale (Months 10-12)

**Enterprise Features**
- [ ] Multi-region deployment
- [ ] Database sharding implementation
- [ ] Advanced monitoring and alerting
- [ ] Disaster recovery setup
- [ ] Security audit and compliance

**Features Delivered:**
- Multi-region high availability
- Enterprise-grade security
- Comprehensive monitoring
- Disaster recovery capabilities
- Performance at scale

### Success Metrics

**Technical Metrics:**
- Response time < 200ms (P95)
- 99.9% uptime SLA
- Support 500K concurrent users
- Cache hit ratio > 80%
- Database query time < 50ms (P95)

**Business Metrics:**
- User engagement rate > 70%
- Comment moderation time < 5 minutes
- Program discovery rate > 85%
- Mobile user experience score > 4.5/5
- Admin productivity improvement > 50%

---

## Conclusion

This Radio Station Platform design provides a comprehensive solution for managing and distributing state-specific radio program information across India. The architecture emphasizes:

1. **Scalability**: Horizontal scaling with microservices, caching, and database replication
2. **Real-time Updates**: WebSocket-based real-time program status updates
3. **Geographic Distribution**: Multi-region deployment with CDN integration
4. **High Availability**: Circuit breakers, failover mechanisms, and redundancy
5. **Performance**: Multi-level caching, optimized database queries, and CDN usage
6. **Security**: JWT authentication, input validation, and rate limiting
7. **Observability**: Comprehensive monitoring, logging, and alerting

The phased implementation approach ensures gradual scaling and risk mitigation while delivering value at each stage. The system is designed to handle the unique challenges of serving diverse content across multiple Indian states while maintaining high performance and reliability standards.

---

**Related Case Studies:**
- [Global Sales Analytics Platform →](18_GlobalSalesAnalytics.md)
- [Social Media Platform →](19_SocialMediaPlatform.md)
- [E-commerce System →](20_EcommerceSystem.md)

**Previous Chapters:**
- [← Interview Preparation](../16_InterviewPrep.md)
