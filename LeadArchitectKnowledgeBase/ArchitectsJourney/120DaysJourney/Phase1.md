# 🚀 Phase 1: Foundations & Core Concepts

> _(Days 1–30, 6 Weeks, 5 Days/Week, ~1 Hour Daily)_

This phase lays the groundwork by building a robust understanding of cloud computing, Azure fundamentals, architectural principles, and Infrastructure as Code (IaC). It sets the stage for deeper exploration in later phases by combining theory with real-world, hands-on activities.

---

## 🎯 Goals

1. **Deep Understanding:** Master cloud computing fundamentals, Azure core services, and architectural design principles.
2. **Hands-On Experience:** Gain practical experience using the Azure Portal, CLI, and IaC tools.
3. **Critical Evaluation:** Learn to assess cloud solutions based on cost, security, scalability, and operational excellence.

---

## 📌 Key Topics

### 1. Cloud Fundamentals _(Estimated Time: 2 days)_

1. **Concepts:**
   - IaaS, PaaS, SaaS, serverless computing, shared responsibility model.
2. **Economics:**
   - Total Cost of Ownership (TCO), Return on Investment (ROI), Pay-as-you-Go vs. Reserved Pricing.

### 2. Azure Fundamentals _(Estimated Time: 4 days)_

1. **Azure Constructs:**
   - Regions, resource groups, subscriptions, management groups, and Azure Resource Manager (ARM).
2. **Pricing & Governance:**
   - Azure pricing models, support plans, Azure Policy & Blueprints, and an overview of Azure Active Directory (Azure AD) with Role-Based Access Control (RBAC).

### 3. Architectural Principles _(Estimated Time: 9 days)_

1. **Design Patterns:**
   - SOLID, DRY, KISS, YAGNI, and Separation of Concerns.
2. **Domain-Driven Design (DDD):**
   - Strategic patterns (Bounded Contexts) and tactical patterns (Aggregates).
3. **Microservices Architecture:**
   - Principles, benefits, challenges, and decomposition strategies.
4. **Azure Well-Architected Framework:**
   - Emphasis on reliability, security, and cost optimization.

### 4. Azure Core Services _(Estimated Time: 9 days – 3 days per service area)_

1. **Compute:**
   - Virtual Machines (VMs), Azure App Service, Azure Functions.
2. **Storage:**
   - Azure Blob, Queue, Table, and File Storage.
3. **Networking:**
   - Virtual Networks (VNets), subnets, Network Security Groups (NSGs), Load Balancers, and DNS.

### 5. Infrastructure as Code (IaC) Fundamentals _(Estimated Time: 6 days)_

1. **Overview:**
   - ARM Templates, Bicep, and Terraform.
2. **Benefits:**
   - Version control, automation, repeatability, and consistency.

---

## 🛠️ Activities (Real-World Focus)

1. **Azure Portal & CLI:**
   - Deploy basic resources (VMs, Storage, VNets) and manage configurations.
2. **Microsoft Learn:**
   - Complete the Azure Fundamentals learning path.
3. **Architectural Design Exercises:**
   - Apply SOLID and DDD principles to design simple cloud architectures (e.g., a scalable, available web app).
4. **Pricing Analysis:**
   - Use the Azure Pricing Calculator to compare costs (e.g., VMs vs. App Service vs. Functions) and understand cost implications.
5. **IaC – ARM Templates & Bicep:**
   - Deploy parameterized ARM templates (e.g., creating a Storage Account) and develop Bicep templates (e.g., deploying a Virtual Network and NSG).
6. **Storage Activity:**
   - Upload and download files to Azure Blob Storage using Azure CLI; experiment with different access tiers (Hot, Cool, Archive).
7. **Terraform Lab (Optional):**
   - Deploy a Resource Group and Storage Account using Terraform to understand its workflow (init, plan, apply, destroy).
8. **Deploy a Simple Web App:**
   - Deploy a basic web app on Azure App Service (with a database and HTTPS) and perform a Well-Architected Review.
9. **Implement Basic CI/CD Pipeline:**
   - Set up a pipeline using Azure DevOps or GitHub Actions to automatically build, test (unit, integration), and deploy the web app.
10. **Configure Networking via IaC:**
    - Use IaC to configure VNets, Subnets, NSGs, and a Load Balancer for a multi-tier application.

---

## 📆 Weekly Schedule (5 Days/Week)

### Week 1: Cloud & Azure Basics

**Goal:** Establish a strong foundation in cloud concepts, pricing, and governance.

1. **Day 1:** Study Cloud Concepts – IaaS, PaaS, SaaS, serverless, shared responsibility.
2. **Day 2:** Explore Cloud Economics – Understand TCO, ROI, and perform a basic cost-benefit analysis.
3. **Day 3:** Learn Azure Constructs – Focus on Regions, Resource Groups, and Subscriptions.
4. **Day 4:** Dive into Management Groups, ARM, and Governance (including Azure Policy, Blueprints, Azure AD, RBAC).
5. **Day 5:** Hands-on: Review Azure Pricing Models & Support Plans; use the Azure Pricing Calculator.

### Week 2: Architectural Principles & Compute Services

**Goal:** Apply SOLID, DDD, and microservices principles to Azure Compute.

1. **Day 6:** Review SOLID and DRY Principles; discuss their impact on cloud design.
2. **Day 7:** Explore KISS, YAGNI, and Separation of Concerns; evaluate design trade-offs.
3. **Day 8:** Study Domain-Driven Design (DDD) – Focus on Strategic Patterns (Bounded Contexts, Aggregates).
4. **Day 9:** Study DDD – Focus on Tactical Patterns.
5. **Day 10:** Introduction to Microservices Architecture – Overview of principles, benefits, challenges; review Azure Compute services (VMs, App Service, Functions).

### Week 3: Storage & Databases

**Goal:** Gain hands-on experience with Azure storage solutions and database services.

1. **Day 11:** Review Azure Compute – Focus on VMs and their configurations.
2. **Day 12:** Learn about Azure App Service deployment strategies.
3. **Day 13:** Explore Azure Functions and serverless computing models.
4. **Day 14:** Study Azure Blob Storage – Understand features and use cases.
5. **Day 15:** Hands-on: Upload and download files to Azure Blob Storage using Azure CLI.

### Week 4: Networking & IaC Introduction

**Goal:** Learn network security fundamentals and introduce IaC.

1. **Day 16:** Overview of Azure Networking – VNets, Subnets, and optional Azure File Storage.
2. **Day 17:** Learn about Network Security – Configure and modify NSG rules.
3. **Day 18:** Understand Load Balancers and DNS – Explore Azure Load Balancer, Traffic Manager, and App Gateway.
4. **Day 19:** Hands-on Lab: Deploy a basic resource using ARM Templates.
5. **Day 20:** Review and Q&A: Reinforce Networking fundamentals and IaC basics.

### Week 5: IaC & CI/CD Fundamentals

**Goal:** Deep dive into Infrastructure as Code and build a CI/CD pipeline.

1. **Day 21:** Deep Dive into ARM Templates – Focus on parameters and variables.
2. **Day 22:** Advance ARM Templates – Explore modules and deployment techniques.
3. **Day 23:** Introduction to Bicep – Learn fundamentals and compare with ARM Templates.
4. **Day 24:** Hands-on: Deploy a Virtual Network and NSG using a Bicep template.
5. **Day 25:** Overview of Terraform Fundamentals – Understand providers, resources, and basic workflow.

### Week 6: Final Review & Capstone Project

**Goal:** Validate your learning with a comprehensive deployment and review.

1. **Day 26:** Hands-on: Deploy a resource (e.g., a Storage Account) using Terraform.
2. **Day 27:** Review and discuss Architectural Principles (SOLID, DDD, Microservices) with real-world examples.
3. **Day 28:** Design Exercise: Create an architecture diagram applying at least three principles.
4. **Day 29:** Perform a Pricing Calculator Analysis – Compare IaaS vs. PaaS costs and document findings.
5. **Day 30:** Capstone Project: Deploy a simple web app using Bicep or Terraform, integrated with Azure Monitor and Logging; include security best practices (HTTPS, Managed Identities) and cost optimization techniques.

---

## ✅ Milestones

1. **Cost & Service Trade-offs:** Explain the trade-offs between IaaS, PaaS, and SaaS using Azure-specific examples.
2. **Architectural Design:** Design and document an architecture applying at least three principles (e.g., SOLID, DDD, Microservices).
3. **End-to-End Deployment:** Deploy a secure, cost-effective web app using IaC (Bicep/Terraform) that integrates a database, Azure Monitor, and security best practices.
4. **Governance & Cost Optimization:** Demonstrate governance and cost optimization through hands-on deployments and detailed pricing analysis.

---

## 📝 Tracking Progress

1. **Weekly Task Checklists:**
   1. **Week 1 Example:**
      1. Study Cloud Concepts.
      2. Deploy a VM using CLI.
      3. Complete Azure Fundamentals on Microsoft Learn.
   2. _(Similar checklists for Weeks 2–6.)_
2. **Kanban Board / Progress Tracker:**
   1. To Do | In Progress | Completed
