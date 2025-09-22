# Azure Security Services

This folder contains resources, patterns, and best practices for Azure security services.

## Core Security Services

### Microsoft Entra ID (formerly Azure Active Directory)

- Cloud-based identity and access management service
- Single sign-on, multi-factor authentication, and conditional access
- B2B and B2C capabilities for external users
- Integration with on-premises Active Directory

### Azure Key Vault

- Centralized secret management
- Hardware Security Module (HSM) backed keys
- Certificate management and storage
- Access policies and RBAC for secure access

### Microsoft Defender for Cloud

- Cloud security posture management
- Continuous security assessment and recommendations
- Threat protection across hybrid cloud workloads
- Regulatory compliance monitoring

### Azure Sentinel

- Cloud-native SIEM (Security Information and Event Management)
- AI-powered security analytics
- Threat intelligence integration
- Automated response to threats

### Azure Firewall

- Managed network security service
- Threat intelligence-based filtering
- FQDN, application, and network rules
- Outbound traffic filtering

### Azure DDoS Protection

- Protection against distributed denial-of-service attacks
- Always-on traffic monitoring
- Automatic attack mitigation
- Real-time metrics and alerts

### Azure Information Protection

- Classification and protection of documents and emails
- Data classification and labeling
- Rights management and encryption
- Tracking and revocation capabilities

### Azure Private Link

- Private connectivity to Azure PaaS services
- Elimination of data exposure to the public internet
- Protection against data exfiltration
- Service consumption over private IP addresses

## Security Architecture Patterns

### Zero Trust Architecture

- Verify explicitly - Always authenticate and authorize based on all available data points
- Use least privilege access - Limit user access with Just-In-Time and Just-Enough-Access
- Assume breach - Minimize blast radius and segment access, verify end-to-end encryption

### Defense in Depth

- Layer security controls throughout the application architecture
- Implement security at physical, identity, perimeter, network, compute, application, and data layers
- Ensure that the failure of any single security mechanism doesn't expose the application

### Secure DevOps

- Security as Code - implement security controls in templates and pipelines
- Shift-left security - include security validation in early development phases
- Automated security testing - include security tests in CI/CD pipelines
- Continuous security monitoring - detect and respond to issues in production

### Data Protection Architecture

- Classify data based on sensitivity and compliance requirements
- Implement encryption in transit and at rest
- Use key management best practices with regular rotation
- Apply appropriate access controls at each data layer

## Best Practices

### Identity and Access Management

- Implement least privilege access
- Use conditional access policies
- Enable multi-factor authentication for all users
- Regularly review and audit access permissions
- Implement Privileged Identity Management for just-in-time access

### Network Security

- Segment networks using Virtual Networks and subnets
- Use Network Security Groups and Application Security Groups
- Implement Azure Firewall for centralized policy enforcement
- Enable Private Link for PaaS services where available
- Deploy Web Application Firewall for HTTP/HTTPS workloads

### Data Security

- Encrypt sensitive data at rest and in transit
- Use Azure Key Vault for secure key management
- Implement appropriate data retention and purging policies
- Consider using Always Encrypted for sensitive database columns
- Implement SQL data masking and row-level security where appropriate

### Security Monitoring and Operations

- Enable diagnostic logs for all resources
- Centralize log collection in Log Analytics
- Implement automated alerts for security events
- Use Microsoft Sentinel for security analytics
- Create and test incident response procedures

### Application Security

- Implement secure development practices
- Use Azure App Service authentication and authorization
- Validate all inputs and implement output encoding
- Implement proper exception handling and logging
- Use managed identities for service-to-service authentication

## Compliance Frameworks

### Azure and Compliance

- ISO 27001/27018
- SOC 1, 2, and 3
- HIPAA/HITECH
- FedRAMP
- GDPR
- PCI DSS

### Compliance Tools

- Microsoft Compliance Manager
- Azure Policy
- Azure Blueprints
- Compliance documentation and audit reports

## Decision Matrix: Choosing the Right Security Service

| Requirement | Recommended Service |
|-------------|---------------------|
| Identity management | Microsoft Entra ID |
| Secret management | Azure Key Vault |
| Security posture management | Microsoft Defender for Cloud |
| SIEM and security analytics | Azure Sentinel |
| Network security | Azure Firewall, NSGs |
| DDoS protection | Azure DDoS Protection |
| Data classification | Azure Information Protection |
| Secure PaaS connectivity | Azure Private Link |
| Web application security | Azure Web Application Firewall |
| Access reviews | Microsoft Entra ID Access Reviews |

## Resources

- [Azure Security Documentation](https://learn.microsoft.com/en-us/azure/security/)
- [Microsoft Entra ID Documentation](https://learn.microsoft.com/en-us/entra/identity/)
- [Azure Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
- [Microsoft Defender for Cloud Documentation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/)
- [Azure Security Benchmarks](https://learn.microsoft.com/en-us/security/benchmark/azure/)
