# 03_Deployment-Automation

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Pipeline Architecture, Testing Integration  
**Estimated Time**: 50 minutes

## 🎯 Learning Objectives

By the end of this content, you will:

- Design automated deployment strategies for different environments
- Implement safe deployment practices with rollback capabilities
- Understand deployment patterns (blue-green, canary, rolling updates)
- Configure environment-specific deployment pipelines

## 📋 Content Sections

### Conceptual Foundation

#### What is Deployment Automation?

Deployment automation is the practice of using tools and scripts to automatically deploy applications to target environments without manual intervention. It ensures:

- **Consistency**: Same deployment process across all environments
- **Reliability**: Reduces human error in deployment steps
- **Speed**: Faster time from code to production
- **Traceability**: Clear deployment history and rollback capability

#### Deployment Pipeline Architecture

```text
Code Merge → Build → Test → Deploy
                            ├── Development Environment
                            ├── Staging Environment  
                            ├── Production Environment
                            └── Disaster Recovery Environment

Each environment deployment includes:
├── Configuration Management
├── Infrastructure Provisioning
├── Application Deployment
├── Health Checks
└── Rollback Capability
```

### Deployment Patterns

#### Blue-Green Deployment

**Concept**: Maintain two identical production environments (Blue and Green). Deploy to the inactive environment, then switch traffic.

```text
Current State: Blue (Live) ← 100% Traffic
               Green (Idle)

Deployment:    Blue (Live) ← 100% Traffic
               Green (New Version) ← Testing

Switch:        Blue (Previous) ← 0% Traffic
               Green (Live) ← 100% Traffic

Rollback:      Blue (Previous) ← 100% Traffic (instant switch)
               Green (Failed) ← 0% Traffic
```

**Implementation Example:**

```yaml
# Blue-Green Deployment Pipeline
name: Blue-Green Deployment

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Determine target environment
        id: target
        run: |
          CURRENT=$(kubectl get service app-service -o jsonpath='{.spec.selector.version}')
          if [ "$CURRENT" = "blue" ]; then
            echo "target=green" >> $GITHUB_OUTPUT
          else
            echo "target=blue" >> $GITHUB_OUTPUT
          fi
      
      - name: Deploy to target environment
        run: |
          # Deploy new version to inactive environment
          kubectl apply -f k8s/deployment-${{ steps.target.outputs.target }}.yaml
          kubectl set image deployment/app-${{ steps.target.outputs.target }} \
            app=myapp:${{ github.sha }}
      
      - name: Wait for deployment ready
        run: |
          kubectl rollout status deployment/app-${{ steps.target.outputs.target }}
      
      - name: Run health checks
        run: |
          ./scripts/health-check.sh ${{ steps.target.outputs.target }}
      
      - name: Switch traffic
        run: |
          kubectl patch service app-service \
            -p '{"spec":{"selector":{"version":"${{ steps.target.outputs.target }}"}}}'
      
      - name: Verify production traffic
        run: |
          ./scripts/production-verification.sh
```

#### Canary Deployment

**Concept**: Gradually roll out new version to small percentage of users, monitor metrics, then increase traffic.

```text
Phase 1: 95% Old Version, 5% New Version
Phase 2: 90% Old Version, 10% New Version
Phase 3: 75% Old Version, 25% New Version
Phase 4: 50% Old Version, 50% New Version
Phase 5: 0% Old Version, 100% New Version
```

**Implementation Example:**

```yaml
# Canary Deployment with Istio
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: app-canary
spec:
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: app-service
        subset: v2
  - route:
    - destination:
        host: app-service
        subset: v1
      weight: 95
    - destination:
        host: app-service
        subset: v2
      weight: 5
```

#### Rolling Updates

**Concept**: Gradually replace instances of the old version with new version, maintaining service availability.

```text
Initial:   [V1] [V1] [V1] [V1]  ← 4 instances running V1
Step 1:    [V2] [V1] [V1] [V1]  ← Replace 1 instance
Step 2:    [V2] [V2] [V1] [V1]  ← Replace 2nd instance
Step 3:    [V2] [V2] [V2] [V1]  ← Replace 3rd instance
Final:     [V2] [V2] [V2] [V2]  ← All instances running V2
```

### Environment-Specific Deployment

#### Development Environment

**Characteristics:**

- Frequent deployments (multiple times per day)
- Latest features and experiments
- Relaxed security policies
- Shared resources

**Pipeline Configuration:**

```yaml
development:
  trigger:
    - push to feature branches
    - pull request creation
  
  deployment:
    strategy: direct-replace
    health_checks: basic
    rollback: manual
    
  environment:
    resources: minimal
    monitoring: basic
    data: synthetic/mocked
```

#### Staging Environment

**Characteristics:**

- Production-like environment
- Comprehensive testing
- Final validation before production
- Real data subset

**Pipeline Configuration:**

```yaml
staging:
  trigger:
    - merge to main branch
    - manual deployment
  
  deployment:
    strategy: blue-green
    health_checks: comprehensive
    rollback: automatic-on-failure
    
  environment:
    resources: production-like
    monitoring: full-observability
    data: production-subset
```

#### Production Environment

**Characteristics:**

- High availability requirements
- Safety-first deployment approach
- Comprehensive monitoring
- Immediate rollback capability

**Pipeline Configuration:**

```yaml
production:
  trigger:
    - manual approval after staging
    - scheduled maintenance windows
  
  deployment:
    strategy: canary-with-monitoring
    health_checks: extensive
    rollback: automatic-on-alerts
    
  environment:
    resources: auto-scaling
    monitoring: full-alerting
    data: live-production
```

### Implementation Examples

#### Kubernetes Deployment Automation

**Complete Deployment Script:**

```bash
#!/bin/bash
# deploy.sh - Automated Kubernetes deployment script

set -e  # Exit on any error

# Configuration
NAMESPACE=${1:-default}
APP_NAME=${2:-myapp}
IMAGE_TAG=${3:-latest}
DEPLOYMENT_TYPE=${4:-rolling}

echo "🚀 Starting deployment of $APP_NAME:$IMAGE_TAG to $NAMESPACE"

# Pre-deployment checks
echo "📋 Running pre-deployment checks..."
kubectl cluster-info
kubectl get nodes
kubectl get namespace $NAMESPACE || kubectl create namespace $NAMESPACE

# Update deployment manifest
echo "📝 Updating deployment manifest..."
sed -i "s|IMAGE_TAG|$IMAGE_TAG|g" k8s/deployment.yaml
sed -i "s|NAMESPACE|$NAMESPACE|g" k8s/deployment.yaml

# Apply configuration changes
echo "⚙️ Applying configuration changes..."
kubectl apply -f k8s/configmap.yaml -n $NAMESPACE
kubectl apply -f k8s/secrets.yaml -n $NAMESPACE

# Deploy based on strategy
case $DEPLOYMENT_TYPE in
  "blue-green")
    echo "🔵 Executing Blue-Green deployment..."
    ./scripts/blue-green-deploy.sh $NAMESPACE $APP_NAME $IMAGE_TAG
    ;;
  "canary")
    echo "🐤 Executing Canary deployment..."
    ./scripts/canary-deploy.sh $NAMESPACE $APP_NAME $IMAGE_TAG
    ;;
  "rolling")
    echo "🔄 Executing Rolling update..."
    kubectl set image deployment/$APP_NAME-deployment \
      $APP_NAME=$APP_NAME:$IMAGE_TAG -n $NAMESPACE
    ;;
esac

# Wait for deployment to complete
echo "⏳ Waiting for deployment to complete..."
kubectl rollout status deployment/$APP_NAME-deployment -n $NAMESPACE --timeout=300s

# Health checks
echo "🏥 Running health checks..."
kubectl get pods -n $NAMESPACE -l app=$APP_NAME
kubectl get services -n $NAMESPACE -l app=$APP_NAME

# Application-specific health check
echo "🔍 Testing application endpoints..."
SERVICE_IP=$(kubectl get service $APP_NAME-service -n $NAMESPACE \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -n "$SERVICE_IP" ]; then
  echo "Testing health endpoint..."
  curl -f "http://$SERVICE_IP/health" || {
    echo "❌ Health check failed!"
    echo "🔄 Rolling back deployment..."
    kubectl rollout undo deployment/$APP_NAME-deployment -n $NAMESPACE
    exit 1
  }
  echo "✅ Health check passed!"
else
  echo "⚠️ Could not determine service IP, skipping external health check"
fi

echo "🎉 Deployment completed successfully!"

# Post-deployment tasks
echo "📊 Gathering deployment metrics..."
kubectl top pods -n $NAMESPACE -l app=$APP_NAME
kubectl describe deployment $APP_NAME-deployment -n $NAMESPACE

echo "📱 Sending notification..."
# Integration with Slack, Teams, or other notification systems
curl -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d "{\"text\":\"✅ $APP_NAME:$IMAGE_TAG deployed to $NAMESPACE successfully\"}"
```

#### Database Migration Integration

**Safe Database Deployment:**

```yaml
# Database-aware deployment pipeline
name: Deploy with Database Migration

jobs:
  database-migration:
    runs-on: ubuntu-latest
    steps:
      - name: Backup production database
        run: |
          pg_dump $DATABASE_URL > backup-$(date +%Y%m%d_%H%M%S).sql
          aws s3 cp backup-*.sql s3://db-backups/
      
      - name: Run database migrations
        run: |
          # Test migrations on copy first
          ./scripts/test-migration.sh
          
          # Apply migrations to production
          npm run migrate:up
      
      - name: Verify migration success
        run: |
          npm run migrate:status
          ./scripts/verify-schema.sh

  application-deployment:
    needs: database-migration
    runs-on: ubuntu-latest
    steps:
      - name: Deploy application
        run: |
          kubectl set image deployment/app \
            app=myapp:${{ github.sha }}
      
      - name: Monitor deployment
        run: |
          kubectl rollout status deployment/app
          ./scripts/post-deploy-verification.sh
```

### Rollback Strategies

#### Automated Rollback Triggers

**Monitoring-Based Rollback:**

```yaml
# Automated rollback configuration
rollback:
  triggers:
    - error_rate > 5%
    - response_time > 2000ms
    - availability < 99%
    - custom_metric_threshold_exceeded
  
  actions:
    - immediate_traffic_redirect
    - rollback_to_previous_version
    - alert_operations_team
    - create_incident_ticket

# Implementation example
monitoring:
  checks:
    - name: error-rate-check
      query: "rate(http_requests_errors[5m]) > 0.05"
      duration: 2m
      action: rollback
    
    - name: response-time-check
      query: "histogram_quantile(0.95, http_request_duration_seconds) > 2"
      duration: 3m
      action: rollback
```

#### Manual Rollback Procedures

**Quick Rollback Commands:**

```bash
# Kubernetes rollback
kubectl rollout undo deployment/myapp-deployment

# Blue-Green environment switch
kubectl patch service myapp-service \
  -p '{"spec":{"selector":{"version":"blue"}}}'

# Canary rollback (remove canary traffic)
kubectl patch virtualservice myapp-canary \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/http/0/route/1/weight", "value": 0}]'

# Database rollback (if needed)
npm run migrate:down -- --count=3
```

### Security Considerations

#### Deployment Security

1. **Secret Management**: Use secure secret management systems
2. **Image Scanning**: Scan container images for vulnerabilities
3. **Network Policies**: Implement proper network segmentation
4. **Access Controls**: Limit who can deploy to production

**Implementation Example:**

```yaml
# Secure deployment pipeline
security-checks:
  - name: Container image vulnerability scan
    run: |
      docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy image myapp:${{ github.sha }}
  
  - name: Kubernetes security scan
    run: |
      kubesec scan k8s/deployment.yaml
  
  - name: Network policy validation
    run: |
      kubectl apply --dry-run=server -f k8s/network-policy.yaml
```

## 🔗 Related Topics

### Prerequisites

- [01_Pipeline-Architecture](01_Pipeline-Architecture.md)
- [02_Testing-Integration](02_Testing-Integration.md)

### Builds Upon

- Container orchestration (Kubernetes)
- Infrastructure as Code principles
- Monitoring and observability

### Enables

- [04_Security-Integration](04_Security-Integration.md)
- [05_Pipeline-Monitoring](05_Pipeline-Monitoring.md)
- [Release Strategies](../04_Release-Strategies/)

### Cross-References

- [Infrastructure as Code](../02_Infrastructure-as-Code/)
- [Observability and Monitoring](../03_Observability-and-Monitoring/)

---

## STSA Metadata

- **Learning Level**: Intermediate to Advanced
- **Domain**: DevOps - CI/CD Fundamentals  
- **Taxonomy Code**: OPS-CI-003
- **Last Updated**: January 2025
- **Next Review**: April 2025
