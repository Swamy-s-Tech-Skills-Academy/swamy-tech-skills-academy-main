# Azure Networking Services

This folder contains resources, patterns, and best practices for Azure networking services.

## Core Networking Services

### Azure Virtual Network (VNet)
- Isolated network environment in Azure
- IP address space segmentation with subnets
- Foundation for private communication between Azure resources
- Enables hybrid connectivity with on-premises networks

### Azure Load Balancer
- Distributes incoming traffic among healthy VMs
- Layer 4 (TCP, UDP) load balancing
- High availability with zone redundancy
- Supports internal and external traffic distribution

### Azure Application Gateway
- Web traffic (HTTP/HTTPS) load balancer
- Layer 7 application delivery controller
- SSL termination and end-to-end encryption
- Web Application Firewall integration

### Azure Front Door
- Global, scalable entry point for web applications
- Multi-site hosting and global HTTP/HTTPS load balancing
- SSL offloading and instant global failover
- Web Application Firewall integration at the edge

### Azure Firewall
- Managed, cloud-based network security service
- Centralized network filtering and protection
- Built-in high availability and seamless scaling
- Application and network level filtering

### Azure DNS
- Hosting service for DNS domains
- Name resolution using Microsoft's global DNS infrastructure
- High availability and fast performance
- Support for private DNS zones

### Azure ExpressRoute
- Private connections between Azure and on-premises infrastructure
- Higher reliability, faster speeds, and lower latencies
- Does not go over the public internet
- Layer 3 connectivity through connectivity providers

### Azure VPN Gateway
- Securely connect on-premises networks to Azure
- Site-to-site and point-to-site VPN connections
- Encrypted IPsec/IKE connections
- Lower cost alternative to ExpressRoute

### Azure Private Link
- Private connectivity to Azure PaaS services
- Brings services into your virtual network
- Eliminates data exposure to the public internet
- Simplifies network security configuration

### Azure Network Watcher
- Network performance monitoring and diagnostics
- Packet capture and flow logging
- NSG flow logs and diagnostics
- Network topology visualization

## Networking Patterns & Architectures

### Hub-and-Spoke Network Topology
- Central hub VNet connected to multiple spoke VNets
- Centralized management of common services and connectivity
- Efficient use of ExpressRoute or VPN connections
- Separation of concerns across different workloads

### Secure Transit Connectivity
- Secure all traffic between networks with inspection
- Implement Azure Firewall in hub VNet
- Apply consistent security policies
- Enable secure internet breakout

### Multi-region Network Design
- Replicate workloads across Azure regions
- Connect regional VNets via global VNet peering
- Implement Traffic Manager or Front Door for global routing
- Design for regional failure scenarios

### DMZ Architecture
- Implement network segmentation for security
- Secure public-facing resources in screened subnets
- Apply defense-in-depth with multiple security controls
- Use NSGs and Azure Firewall for traffic filtering

### Service Endpoints vs Private Link
- Service Endpoints: Traffic stays on Azure backbone but services remain public endpoints
- Private Link: Bring services into your VNet with private IPs
- Private Link provides higher security isolation
- Service Endpoints are simpler to implement

## Best Practices

### Network Security
- Implement defense in depth with multiple security controls
- Use NSGs to filter traffic within VNets
- Implement Azure Firewall for centralized security policy
- Enable DDoS Protection for public endpoints
- Regularly audit and refine security rules

### Hybrid Connectivity
- Choose between ExpressRoute and VPN based on requirements
- Implement redundant connections for critical workloads
- Use BGP for dynamic routing when possible
- Design for appropriate bandwidth and latency needs

### IP Address Management
- Plan IP address space to avoid overlaps
- Use address spaces that don't conflict with on-premises networks
- Reserve capacity for future growth
- Consider IPv6 dual-stack for modern applications

### Performance Optimization
- Use Accelerated Networking for high-performance VMs
- Implement Azure CDN for content delivery
- Choose appropriate VM sizes for network-intensive workloads
- Optimize VM placement within proximity placement groups when needed

### Cost Management
- Right-size gateways based on throughput requirements
- Optimize outbound data transfer costs
- Use NAT Gateway for efficient outbound connectivity
- Monitor usage and adjust resources accordingly

## Decision Matrix: Choosing the Right Networking Service

| Requirement | Recommended Service |
|-------------|---------------------|
| Basic network isolation | Azure Virtual Network |
| TCP/UDP load balancing | Azure Load Balancer |
| HTTP/HTTPS load balancing | Application Gateway |
| Global load balancing | Azure Front Door |
| Network security | Azure Firewall + NSGs |
| High-bandwidth hybrid connectivity | ExpressRoute |
| Cost-effective hybrid connectivity | VPN Gateway |
| Private PaaS connectivity | Private Link |
| DNS management | Azure DNS |
| Network monitoring | Network Watcher |

## Resources

- [Azure Networking Documentation](https://learn.microsoft.com/en-us/azure/networking/)
- [Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Azure Application Gateway Documentation](https://learn.microsoft.com/en-us/azure/application-gateway/)
- [Azure Front Door Documentation](https://learn.microsoft.com/en-us/azure/frontdoor/)
- [Private Link Documentation](https://learn.microsoft.com/en-us/azure/private-link/)