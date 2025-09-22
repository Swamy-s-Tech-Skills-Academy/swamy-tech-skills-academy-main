# Azure Compute Services

This folder contains resources, patterns, and best practices for Azure compute services.

## Core Compute Services

### Virtual Machines

- Infrastructure as a Service (IaaS) offering
- Full control over the operating system and software
- Support for Windows and Linux operating systems
- Ideal for lift-and-shift migrations and custom workloads

### Azure App Service

- Platform as a Service (PaaS) for web applications
- Supports multiple languages and frameworks (.NET, Node.js, Python, Java, PHP)
- Built-in CI/CD integration and scaling
- Ideal for web applications, RESTful APIs, and mobile backends

### Azure Functions

- Serverless compute service
- Event-driven execution model
- Pay-per-execution pricing
- Ideal for microservices, event processing, and background tasks

### Azure Container Instances

- Serverless container runtime
- Simple container deployment without orchestration
- Per-second billing
- Ideal for simple container workloads and batch processing

### Azure Kubernetes Service (AKS)

- Managed Kubernetes service
- Simplified container orchestration
- Integrated developer and CI/CD tooling
- Ideal for complex containerized applications

### Azure Container Apps

- Serverless container service with Kubernetes-like features
- Built-in scaling, networking, and service discovery
- Integrated with DAPR for microservices development
- Ideal for cloud-native applications and microservices

## Best Practices

### Scalability

- Choose appropriate VM sizes or service tiers based on workload requirements
- Implement auto-scaling to handle variable loads efficiently
- Use availability sets or zones for high availability
- Design stateless applications where possible

### Security

- Use managed identities for service authentication
- Implement least privilege access through RBAC
- Enable just-in-time VM access
- Apply security patches regularly
- Implement network security groups (NSGs)

### Cost Optimization

- Resize underutilized VMs
- Implement start/stop schedules for non-production resources
- Use reserved instances for predictable workloads
- Consider Spot instances for batch processing and dev/test

### Performance

- Choose the right VM size and family for your workload
- Use Premium SSD or Ultra Disk for I/O-intensive applications
- Implement appropriate caching strategies
- Monitor and tune performance regularly

## Application Patterns

### Microservices Architecture

- Use AKS or Container Apps for container orchestration
- Implement service discovery with managed solutions
- Design for fault isolation and independent scaling
- Use event-driven communication where appropriate

### Serverless Applications

- Combine Azure Functions with other serverless services
- Design around event-driven architecture
- Optimize function execution time and memory usage
- Use durable functions for stateful workflows

### Hybrid Applications

- Use Azure Arc to extend Azure management to on-premises resources
- Implement consistent identity management across environments
- Design for data synchronization and latency
- Consider Azure Stack for edge computing scenarios

## Decision Matrix: Choosing the Right Compute Service

| Requirement | Recommended Service |
|-------------|---------------------|
| Full OS/software control | Virtual Machines |
| Web applications | App Service |
| Event-driven processing | Azure Functions |
| Simple containers | Container Instances |
| Complex container orchestration | AKS |
| Cloud-native microservices | Container Apps |
| Batch processing | Batch or Container Instances |
| High-performance computing | VM Scale Sets with HPC sizes |

## Resources

- [Azure Compute Documentation](https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/compute-decision-tree)
- [Azure Virtual Machine Sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- [App Service Documentation](https://learn.microsoft.com/en-us/azure/app-service/)
- [Azure Functions Documentation](https://learn.microsoft.com/en-us/azure/azure-functions/)
- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
