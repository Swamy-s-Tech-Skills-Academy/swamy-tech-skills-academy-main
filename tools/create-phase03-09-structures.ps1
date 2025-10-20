<#
.SYNOPSIS
Create Phase03-Phase09 structures for Lead Architect learning pathway

.DESCRIPTION
Generates Phase03 through Phase09 directory structures with 9 clusters each,
54 content files per phase, and 10 portfolio templates. Uses parameterized
design to support all phases 3-9 (441 total files). Based on Phase02 proven pattern.

.PARAMETER PhaseNumbers
Comma-separated list of phases to generate (e.g., 3,4,5 or 3-9). Default: 3-9 (all remaining phases)

.PARAMETER BasePath
Root path for Phase directories (default: 02_LeadArchitect-Learning)

.EXAMPLE
.\create-phase03-09-structures.ps1
.\create-phase03-09-structures.ps1 -PhaseNumbers 3,4,5
.\create-phase03-09-structures.ps1 -PhaseNumbers "3-9"

.NOTES
- Generates 7 phases × 9 clusters × 6 files = 441 total content files
- Plus 70 template files (10 per phase) = 511 total files
- Follows automation-first methodology (copilot-instructions.md v1.5)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$PhaseNumbers = "3-9",
    
    [Parameter(Mandatory=$false)]
    [string]$BasePath = "02_LeadArchitect-Learning"
)

$ErrorActionPreference = "Stop"

# ╔════════════════════════════════════════════════════════════╗
# ║          PHASE03-09 STRUCTURES GENERATOR                  ║
# ╚════════════════════════════════════════════════════════════╝

Write-Host "🏗️  Creating Phase03-Phase09 Learning Structures" -ForegroundColor Cyan
Write-Host ""

# ─────────────────────────────────────────────────────────
# Parse phase numbers
# ─────────────────────────────────────────────────────────

$phasesToGenerate = @()

if ($PhaseNumbers -match "-") {
    # Range format (e.g., "3-9")
    $parts = $PhaseNumbers.Split("-")
    $start = [int]$parts[0].Trim()
    $end = [int]$parts[1].Trim()
    for ($i = $start; $i -le $end; $i++) {
        $phasesToGenerate += $i
    }
} else {
    # List format (e.g., "3,4,5")
    $phasesToGenerate = @($PhaseNumbers.Split(",") | ForEach-Object { [int]$_.Trim() })
}

Write-Host "📋 Phases to generate: $($phasesToGenerate -join ', ')" -ForegroundColor Gray
Write-Host ""

# ─────────────────────────────────────────────────────────
# Phase definitions with unique cluster themes
# ─────────────────────────────────────────────────────────

$phaseDefinitions = @{
    3 = @{
        Name = "Phase03_Pattern_Studio"
        Title = "Pattern Studio: Design Patterns & Principles"
        Clusters = @(
            @{ Name = "Cluster01_Creational_Patterns"; Theme = "Creational Patterns"; Days = @("Abstract_Factory", "Builder_Pattern", "Factory_Method", "Prototype_Pattern", "Singleton_Pattern") }
            @{ Name = "Cluster02_Structural_Patterns"; Theme = "Structural Patterns"; Days = @("Adapter_Pattern", "Bridge_Pattern", "Composite_Pattern", "Decorator_Pattern", "Facade_Pattern") }
            @{ Name = "Cluster03_Behavioral_Patterns"; Theme = "Behavioral Patterns"; Days = @("Chain_of_Responsibility", "Command_Pattern", "Interpreter_Pattern", "Iterator_Pattern", "Mediator_Pattern") }
            @{ Name = "Cluster04_SOLID_Principles"; Theme = "SOLID Design Principles"; Days = @("Single_Responsibility", "Open_Closed_Principle", "Liskov_Substitution", "Interface_Segregation", "Dependency_Inversion") }
            @{ Name = "Cluster05_DDD_Patterns"; Theme = "Domain-Driven Design Patterns"; Days = @("Entity_Design", "Value_Objects", "Aggregates", "Bounded_Contexts", "Ubiquitous_Language") }
            @{ Name = "Cluster06_Integration_Patterns"; Theme = "Integration Pattern Design"; Days = @("Message_Patterns", "Routing_Patterns", "Transformation_Patterns", "Endpoint_Patterns", "Channel_Patterns") }
            @{ Name = "Cluster07_Enterprise_Patterns"; Theme = "Enterprise Application Patterns"; Days = @("Service_Locator", "Repository_Pattern", "Unit_of_Work", "Data_Mapper", "Active_Record") }
            @{ Name = "Cluster08_API_Patterns"; Theme = "API Design Patterns"; Days = @("RESTful_Principles", "Versioning_Strategies", "Pagination_Patterns", "Error_Handling", "Rate_Limiting") }
            @{ Name = "Cluster09_Pattern_Studio_Declaration"; Theme = "Pattern Mastery & Commitment"; Days = @("Pattern_Selection_Criteria", "Anti_Patterns", "Pattern_Composition", "Team_Patterns", "Sustainable_Design") }
        )
        Templates = @(
            @{ Name = "Pattern-Analysis.md"; Desc = "Design pattern evaluation and analysis template" }
            @{ Name = "SOLID-Audit.md"; Desc = "SOLID principles compliance checklist" }
            @{ Name = "DDD-Context-Map.md"; Desc = "Domain-driven design bounded context mapping" }
            @{ Name = "Integration-Design.md"; Desc = "Enterprise integration pattern documentation" }
            @{ Name = "API-Specification.md"; Desc = "RESTful API design specification template" }
            @{ Name = "Anti-Pattern-Log.md"; Desc = "Anti-pattern identification and remediation log" }
            @{ Name = "Pattern-Implementation.md"; Desc = "Pattern implementation checklist and guide" }
            @{ Name = "Architecture-Patterns.md"; Desc = "Architectural pattern selection framework" }
            @{ Name = "Pattern-Review.md"; Desc = "Pattern review and validation document" }
            @{ Name = "Design-Playbook.md"; Desc = "Team design pattern playbook and guidelines" }
        )
    }
    
    4 = @{
        Name = "Phase04_Scale_Systems"
        Title = "Scale Systems: Building for Enterprise Scale"
        Clusters = @(
            @{ Name = "Cluster01_Scalability_Foundations"; Theme = "Scalability Fundamentals"; Days = @("Vertical_Scaling", "Horizontal_Scaling", "Database_Scaling", "Caching_Strategies", "Load_Distribution") }
            @{ Name = "Cluster02_Distributed_Systems"; Theme = "Distributed Systems Design"; Days = @("CAP_Theorem", "Consistency_Models", "Distributed_Transactions", "Consensus_Algorithms", "Failure_Modes") }
            @{ Name = "Cluster03_Data_Pipeline_Architecture"; Theme = "Data Pipeline & ETL"; Days = @("Pipeline_Design", "Data_Ingestion", "Stream_Processing", "Batch_Processing", "Data_Quality") }
            @{ Name = "Cluster04_Event_Driven_Architecture"; Theme = "Event-Driven Systems"; Days = @("Event_Sourcing", "Event_Streaming", "Message_Brokers", "Saga_Pattern", "Choreography_vs_Orchestration") }
            @{ Name = "Cluster05_Polyglot_Persistence"; Theme = "Polyglot Data Architecture"; Days = @("SQL_Databases", "NoSQL_Selection", "Graph_Databases", "Time_Series_Data", "Data_Consistency") }
            @{ Name = "Cluster06_Search_Analytics"; Theme = "Search & Analytics Architecture"; Days = @("Search_Engines", "Full_Text_Search", "Real_Time_Analytics", "Data_Warehouse", "OLAP_vs_OLTP") }
            @{ Name = "Cluster07_Performance_Optimization"; Theme = "Performance Tuning at Scale"; Days = @("Query_Optimization", "Index_Strategy", "Profiling_Tools", "Bottleneck_Analysis", "Performance_Metrics") }
            @{ Name = "Cluster08_High_Availability"; Theme = "High Availability Design"; Days = @("Redundancy_Patterns", "Failover_Strategies", "Health_Checks", "Circuit_Breakers", "Graceful_Degradation") }
            @{ Name = "Cluster09_Scale_System_Declaration"; Theme = "Enterprise Scale Mastery"; Days = @("Capacity_Planning", "Scaling_Strategy", "Cost_Optimization", "Performance_SLAs", "Scalability_Audit") }
        )
        Templates = @(
            @{ Name = "Scalability-Assessment.md"; Desc = "System scalability evaluation framework" }
            @{ Name = "Load-Testing-Plan.md"; Desc = "Load testing strategy and execution plan" }
            @{ Name = "Data-Architecture.md"; Desc = "Enterprise data architecture documentation" }
            @{ Name = "Event-Design.md"; Desc = "Event-driven system design template" }
            @{ Name = "Cache-Strategy.md"; Desc = "Caching strategy and implementation guide" }
            @{ Name = "Distributed-Tracing.md"; Desc = "Distributed systems tracing documentation" }
            @{ Name = "Performance-Baseline.md"; Desc = "Performance baseline and metrics documentation" }
            @{ Name = "Failover-Plan.md"; Desc = "Failover strategy and runbook template" }
            @{ Name = "Scale-Roadmap.md"; Desc = "System scaling roadmap and milestones" }
            @{ Name = "SLA-Framework.md"; Desc = "Service level agreement framework" }
        )
    }
    
    5 = @{
        Name = "Phase05_Delivery_Engine"
        Title = "Delivery Engine: Building Robust Deployment Systems"
        Clusters = @(
            @{ Name = "Cluster01_CI_CD_Mastery"; Theme = "CI-CD Pipeline Excellence"; Days = @("Pipeline_Design", "Build_Automation", "Artifact_Management", "Test_Automation", "Deployment_Automation") }
            @{ Name = "Cluster02_GitOps_Operations"; Theme = "GitOps & Infrastructure as Code"; Days = @("GitOps_Principles", "Declarative_Infrastructure", "Configuration_Management", "State_Management", "Reconciliation") }
            @{ Name = "Cluster03_Container_Orchestration"; Theme = "Container & Orchestration Strategy"; Days = @("Container_Fundamentals", "Kubernetes_Architecture", "Service_Discovery", "Load_Balancing", "Auto_Scaling") }
            @{ Name = "Cluster04_Observability_at_Scale"; Theme = "Observability & Monitoring"; Days = @("Metrics_Collection", "Log_Aggregation", "Distributed_Tracing", "Alerting_Strategy", "SLO_Management") }
            @{ Name = "Cluster05_Incident_Management"; Theme = "Incident Response & Runbooks"; Days = @("Incident_Detection", "Runbook_Design", "Root_Cause_Analysis", "Blameless_Culture", "Post_Mortem") }
            @{ Name = "Cluster06_Release_Management"; Theme = "Release & Change Management"; Days = @("Release_Planning", "Change_Control", "Rollback_Strategies", "Feature_Flags", "Canary_Deployments") }
            @{ Name = "Cluster07_Environment_Management"; Theme = "Environment & Configuration"; Days = @("Environment_Promotion", "Secrets_Management", "Configuration_Patterns", "Compliance_as_Code", "Audit_Trail") }
            @{ Name = "Cluster08_Disaster_Recovery"; Theme = "Disaster Recovery & Resilience"; Days = @("Backup_Strategies", "Recovery_Planning", "RTO_RPO_Analysis", "Chaos_Engineering", "Resilience_Testing") }
            @{ Name = "Cluster09_Delivery_Declaration"; Theme = "Delivery Excellence Mastery"; Days = @("Deployment_Metrics", "Velocity_Tracking", "Quality_Gates", "Technology_Roadmap", "Operational_Maturity") }
        )
        Templates = @(
            @{ Name = "Pipeline-Specification.md"; Desc = "CI/CD pipeline specification and design" }
            @{ Name = "GitOps-Strategy.md"; Desc = "GitOps implementation strategy document" }
            @{ Name = "Kubernetes-Setup.md"; Desc = "Kubernetes cluster setup and configuration" }
            @{ Name = "Monitoring-Stack.md"; Desc = "Observability stack configuration" }
            @{ Name = "Incident-Playbook.md"; Desc = "Incident response playbook and runbooks" }
            @{ Name = "Release-Plan.md"; Desc = "Release planning and coordination template" }
            @{ Name = "Environment-Promotion.md"; Desc = "Environment promotion strategy and checklist" }
            @{ Name = "Disaster-Recovery-Plan.md"; Desc = "Disaster recovery and continuity plan" }
            @{ Name = "Deployment-Checklist.md"; Desc = "Pre-deployment verification checklist" }
            @{ Name = "Operational-Runbook.md"; Desc = "System operational runbook template" }
        )
    }
    
    6 = @{
        Name = "Phase06_Data_Trust"
        Title = "Data Trust: Building Data-Driven Organizations"
        Clusters = @(
            @{ Name = "Cluster01_Data_Governance"; Theme = "Data Governance Framework"; Days = @("Data_Classification", "Data_Stewardship", "Data_Lineage", "Metadata_Management", "Data_Standards") }
            @{ Name = "Cluster02_Data_Quality"; Theme = "Data Quality Assurance"; Days = @("Quality_Metrics", "Validation_Rules", "Anomaly_Detection", "Data_Profiling", "Quality_Monitoring") }
            @{ Name = "Cluster03_Privacy_Compliance"; Theme = "Privacy & Compliance"; Days = @("GDPR_Requirements", "Data_Masking", "Access_Control", "Audit_Logging", "Consent_Management") }
            @{ Name = "Cluster04_Master_Data"; Theme = "Master Data Management"; Days = @("MDM_Architecture", "Golden_Records", "Data_Consolidation", "Matching_Algorithms", "Survivorship_Rules") }
            @{ Name = "Cluster05_Data_Integration"; Theme = "Enterprise Data Integration"; Days = @("Data_Pipelines", "Integration_Patterns", "CDC_Mechanisms", "Data_Replication", "Change_Data_Capture") }
            @{ Name = "Cluster06_Analytics_Platform"; Theme = "Analytics & Business Intelligence"; Days = @("BI_Architecture", "Data_Marts", "Cube_Design", "KPI_Framework", "Reporting_Engine") }
            @{ Name = "Cluster07_Data_Science_Engineering"; Theme = "Data Science & ML Engineering"; Days = @("ML_Pipelines", "Feature_Engineering", "Model_Training", "Model_Validation", "ML_Operations") }
            @{ Name = "Cluster08_Data_Security"; Theme = "Data Security & Protection"; Days = @("Encryption_Strategies", "Key_Management", "Data_Isolation", "Threat_Detection", "Security_Monitoring") }
            @{ Name = "Cluster09_Data_Trust_Declaration"; Theme = "Data Trust Mastery"; Days = @("Data_Monetization", "Data_Culture", "Ethical_Data_Use", "Data_Innovation", "Trust_Metrics") }
        )
        Templates = @(
            @{ Name = "Data-Governance-Policy.md"; Desc = "Data governance policy framework" }
            @{ Name = "Data-Quality-Report.md"; Desc = "Data quality assessment and reporting" }
            @{ Name = "Privacy-Impact-Assessment.md"; Desc = "Privacy impact assessment template" }
            @{ Name = "MDM-Design.md"; Desc = "Master data management system design" }
            @{ Name = "Data-Pipeline-SLA.md"; Desc = "Data pipeline SLA and monitoring" }
            @{ Name = "Analytics-Blueprint.md"; Desc = "Analytics platform architecture blueprint" }
            @{ Name = "ML-Development-Lifecycle.md"; Desc = "ML development lifecycle and governance" }
            @{ Name = "Data-Security-Plan.md"; Desc = "Data security strategy and implementation" }
            @{ Name = "Data-Catalog.md"; Desc = "Enterprise data catalog template" }
            @{ Name = "Data-Ethics-Framework.md"; Desc = "Data ethics and responsible AI framework" }
        )
    }
    
    7 = @{
        Name = "Phase07_Polyglot_Delivery"
        Title = "Polyglot Delivery: Multi-Language & Multi-Platform Architecture"
        Clusters = @(
            @{ Name = "Cluster01_Language_Strategy"; Theme = "Language Selection & Strategy"; Days = @("Language_Evaluation", "Ecosystem_Analysis", "Performance_Characteristics", "Team_Capability", "Total_Cost_of_Ownership") }
            @{ Name = "Cluster02_Polyglot_Architecture"; Theme = "Polyglot System Architecture"; Days = @("Service_Boundaries", "Interoperability", "API_Standards", "Protocol_Selection", "Version_Management") }
            @{ Name = "Cluster03_Frontend_Architecture"; Theme = "Frontend Architecture & Frameworks"; Days = @("Framework_Selection", "Component_Design", "State_Management", "Performance_Optimization", "Progressive_Enhancement") }
            @{ Name = "Cluster04_Backend_Architecture"; Theme = "Backend Architecture & Patterns"; Days = @("Service_Design", "Request_Handling", "Business_Logic", "Data_Persistence", "Caching_Layer") }
            @{ Name = "Cluster05_Mobile_Architecture"; Theme = "Mobile & Cross-Platform Development"; Days = @("Native_vs_Hybrid", "Platform_APIs", "Offline_Capability", "Synchronization", "Device_Integration") }
            @{ Name = "Cluster06_Real_Time_Systems"; Theme = "Real-Time & WebSocket Architecture"; Days = @("WebSocket_Design", "Message_Protocols", "Connection_Management", "Scalable_Broadcasting", "Fallback_Mechanisms") }
            @{ Name = "Cluster07_Edge_Computing"; Theme = "Edge & Distributed Computing"; Days = @("Edge_Architecture", "Fog_Computing", "IoT_Integration", "Local_Processing", "Sync_Mechanisms") }
            @{ Name = "Cluster08_Legacy_Integration"; Theme = "Legacy & Brownfield Integration"; Days = @("Legacy_Assessment", "Strangler_Pattern", "Adapter_Design", "Data_Migration", "Gradual_Modernization") }
            @{ Name = "Cluster09_Polyglot_Declaration"; Theme = "Polyglot Delivery Mastery"; Days = @("Technology_Portfolio", "Standards_Framework", "Operational_Complexity", "Team_Scaling", "Innovation_Strategy") }
        )
        Templates = @(
            @{ Name = "Technology-Stack-Evaluation.md"; Desc = "Technology stack evaluation matrix" }
            @{ Name = "Polyglot-Architecture-Design.md"; Desc = "Polyglot system architecture design" }
            @{ Name = "Frontend-Architecture-Plan.md"; Desc = "Frontend architecture and design system" }
            @{ Name = "Backend-Service-Design.md"; Desc = "Backend service design specification" }
            @{ Name = "Mobile-Strategy.md"; Desc = "Mobile development strategy" }
            @{ Name = "Real-Time-Design.md"; Desc = "Real-time system design patterns" }
            @{ Name = "Edge-Computing-Plan.md"; Desc = "Edge computing deployment strategy" }
            @{ Name = "Legacy-Integration-Plan.md"; Desc = "Legacy system integration roadmap" }
            @{ Name = "Interoperability-Framework.md"; Desc = "Cross-platform interoperability framework" }
            @{ Name = "Polyglot-Operations.md"; Desc = "Operating multi-technology environment" }
        )
    }
    
    8 = @{
        Name = "Phase08_Intelligent_Futures"
        Title = "Intelligent Futures: AI/ML Integration & Strategy"
        Clusters = @(
            @{ Name = "Cluster01_AI_Strategy"; Theme = "AI/ML Strategy & Governance"; Days = @("AI_Vision", "Use_Case_Prioritization", "Model_Lifecycle", "Team_Structure", "Ethical_AI_Framework") }
            @{ Name = "Cluster02_ML_Architecture"; Theme = "Machine Learning Architecture"; Days = @("Feature_Store", "Model_Registry", "Training_Pipeline", "Inference_Engine", "Model_Monitoring") }
            @{ Name = "Cluster03_LLM_Integration"; Theme = "Large Language Models Integration"; Days = @("LLM_Selection", "Prompt_Engineering", "Fine_Tuning", "RAG_Systems", "LLM_Optimization") }
            @{ Name = "Cluster04_GenAI_Applications"; Theme = "Generative AI Applications"; Days = @("Text_Generation", "Code_Generation", "Image_Generation", "Multimodal_Systems", "Creative_AI") }
            @{ Name = "Cluster05_AI_Agents"; Theme = "Autonomous AI Agents"; Days = @("Agent_Architecture", "Tool_Integration", "Decision_Making", "Multi_Agent_Systems", "Agent_Safety") }
            @{ Name = "Cluster06_AI_Operations"; Theme = "AI Operations & Deployment"; Days = @("Model_Serving", "A_B_Testing", "Drift_Detection", "Model_Retraining", "Production_ML") }
            @{ Name = "Cluster07_Responsible_AI"; Theme = "Responsible & Trustworthy AI"; Days = @("Bias_Detection", "Explainability", "Fairness_Metrics", "Model_Governance", "AI_Audit_Trail") }
            @{ Name = "Cluster08_AI_Economics"; Theme = "AI Economics & ROI"; Days = @("Cost_Modeling", "Value_Extraction", "ROI_Measurement", "Risk_Assessment", "Scaling_Economics") }
            @{ Name = "Cluster09_Intelligent_Futures_Declaration"; Theme = "Intelligent Future Mastery"; Days = @("AI_Competitive_Advantage", "Transformation_Roadmap", "Innovation_Culture", "Emerging_Tech", "Future_Ready_Organization") }
        )
        Templates = @(
            @{ Name = "AI-Strategy-Framework.md"; Desc = "AI/ML strategic planning framework" }
            @{ Name = "ML-Architecture-Design.md"; Desc = "ML system architecture design" }
            @{ Name = "LLM-Implementation-Plan.md"; Desc = "LLM integration implementation guide" }
            @{ Name = "GenAI-Use-Case.md"; Desc = "Generative AI use case development template" }
            @{ Name = "AI-Agent-Design.md"; Desc = "AI agent architecture and design" }
            @{ Name = "ML-Operations-Blueprint.md"; Desc = "ML operations (MLOps) setup guide" }
            @{ Name = "Responsible-AI-Charter.md"; Desc = "Responsible AI governance charter" }
            @{ Name = "AI-Economics-Model.md"; Desc = "AI economics and ROI model" }
            @{ Name = "AI-Risk-Assessment.md"; Desc = "AI risk assessment and mitigation" }
            @{ Name = "AI-Innovation-Roadmap.md"; Desc = "AI innovation and transformation roadmap" }
        )
    }
    
    9 = @{
        Name = "Phase09_Leadership_Impact"
        Title = "Leadership Impact: Director-Level Technology Strategy"
        Clusters = @(
            @{ Name = "Cluster01_Technology_Vision"; Theme = "Technology Vision & Strategy"; Days = @("Competitive_Analysis", "Technology_Trends", "Strategic_Positioning", "Innovation_Pipeline", "Technology_Roadmap") }
            @{ Name = "Cluster02_Organizational_Design"; Theme = "Organization & Team Structure"; Days = @("Team_Composition", "Skills_Development", "Career_Pathways", "Culture_Building", "Retention_Strategy") }
            @{ Name = "Cluster03_Financial_Acumen"; Theme = "Financial & Budget Management"; Days = @("Budget_Planning", "Cost_Control", "Vendor_Management", "ROI_Analysis", "Financial_Reporting") }
            @{ Name = "Cluster04_Stakeholder_Leadership"; Theme = "Stakeholder & Executive Leadership"; Days = @("Executive_Communication", "Board_Reporting", "Influencing_Without_Authority", "Negotiation_Skills", "Relationship_Building") }
            @{ Name = "Cluster05_Risk_Management"; Theme = "Risk, Compliance & Governance"; Days = @("Risk_Assessment", "Compliance_Framework", "Security_Governance", "Regulatory_Requirements", "Audit_Readiness") }
            @{ Name = "Cluster06_Digital_Transformation"; Theme = "Digital Transformation Leadership"; Days = @("Transformation_Strategy", "Change_Management", "Organizational_Readiness", "Capability_Building", "Value_Realization") }
            @{ Name = "Cluster07_Competitive_Advantage"; Theme = "Building Competitive Advantage"; Days = @("Technology_Differentiation", "Speed_to_Market", "Customer_Experience", "Operational_Excellence", "Market_Disruption") }
            @{ Name = "Cluster08_Ecosystem_Leadership"; Theme = "Partner & Ecosystem Strategy"; Days = @("Partner_Strategy", "Platform_Thinking", "API_Economy", "Ecosystem_Design", "Network_Effects") }
            @{ Name = "Cluster09_Legacy_Leadership_Declaration"; Theme = "Legacy & Impact Mastery"; Days = @("Long_Term_Vision", "Organization_Transformation", "Industry_Influence", "Thought_Leadership", "Lasting_Impact") }
        )
        Templates = @(
            @{ Name = "Technology-Vision-Statement.md"; Desc = "Corporate technology vision and strategy" }
            @{ Name = "Organizational-Design-Plan.md"; Desc = "Organizational structure and design plan" }
            @{ Name = "Annual-Budget-Plan.md"; Desc = "Annual budget and financial planning" }
            @{ Name = "Executive-Dashboard.md"; Desc = "Executive metrics and reporting dashboard" }
            @{ Name = "Risk-Register.md"; Desc = "Technology risk register and mitigation" }
            @{ Name = "Transformation-Roadmap.md"; Desc = "Digital transformation roadmap" }
            @{ Name = "Competitive-Analysis.md"; Desc = "Competitive technology analysis" }
            @{ Name = "Partner-Strategy.md"; Desc = "Partner and ecosystem strategy" }
            @{ Name = "Succession-Plan.md"; Desc = "Leadership succession planning" }
            @{ Name = "Legacy-Impact-Framework.md"; Desc = "Long-term impact and legacy framework" }
        )
    }
}

# ─────────────────────────────────────────────────────────
# Generate each phase
# ─────────────────────────────────────────────────────────

$totalFilesCreated = 0

foreach ($phaseNum in $phasesToGenerate) {
    if (-not $phaseDefinitions.ContainsKey($phaseNum)) {
        Write-Host "⚠️  Phase $phaseNum not defined in configuration" -ForegroundColor Yellow
        continue
    }
    
    $phaseDef = $phaseDefinitions[$phaseNum]
    $phasePath = Join-Path $BasePath $phaseDef.Name
    
    # Create phase directory
    if (-not (Test-Path $phasePath)) {
        New-Item -ItemType Directory -Path $phasePath -Force | Out-Null
    }
    
    # Create templates directory and files
    $templatesPath = Join-Path $phasePath "01_Templates"
    if (-not (Test-Path $templatesPath)) {
        New-Item -ItemType Directory -Path $templatesPath -Force | Out-Null
    }
    
    foreach ($template in $phaseDef.Templates) {
        $templateFile = Join-Path $templatesPath $template.Name
        $templateContent = @"
# $($template.Name -replace '\.md$', '')

**Learning Level**: Advanced (Lead Architect)  
**Purpose**: $($template.Desc)  
**Phase**: Phase$(((Get-Item $phasePath).Name) -replace 'Phase0', '')

## 🎯 Overview

$($template.Desc)

## 📋 Key Sections

- Section 1
- Section 2
- Section 3
- Section 4
- Section 5

## 📚 References

See related documentation in Phase01, Phase02, and ReferenceLibrary folders.

---

**Last Updated**: October 19, 2025
"@
        Set-Content -Path $templateFile -Value $templateContent -Encoding UTF8
    }
    
    # Create clusters
    foreach ($cluster in $phaseDef.Clusters) {
        $clusterPath = Join-Path $phasePath $cluster.Name
        if (-not (Test-Path $clusterPath)) {
            New-Item -ItemType Directory -Path $clusterPath -Force | Out-Null
        }
        
        # Create week overview file
        $weekNum = $phaseDef.Clusters.IndexOf($cluster) + 1
        $weekFile = Join-Path $clusterPath "00_Week$($weekNum.ToString('00'))_$($cluster.Theme.Replace(' ', '_').Replace('/', '_')).md"
        
        $weekContent = @"
# Week $weekNum`: $($cluster.Theme)

**Learning Level**: Advanced (Lead Architect)  
**Prerequisites**: Previous phase completion  
**Estimated Time**: 4.5 hours (10 × 27-minute loops)

## 🎯 Learning Objectives

By the end of this week, you will:

- Understand core principles of $($cluster.Theme.ToLower())
- Apply frameworks to real-world scenarios
- Build commitment artifacts

## 📅 10-Loop Structure

| Loop | Time | Focus | Outcome |
|------|------|-------|---------|
| 1 | 27 min | Concepts | Foundational understanding |
| 2 | 27 min | Principles | Core knowledge |
| 3 | 27 min | Patterns | Architectural perspective |
| 4 | 27 min | Integration | System mapping |
| 5 | 27 min | Examples | Real-world cases |
| 6 | 27 min | Validation | Checklist review |
| 7 | 27 min | Architecture | Architectural sketch |
| 8 | 27 min | Practice | Implementation plan |
| 9 | 27 min | Feedback | Team review |
| 10 | 27 min | Synthesis | Weekly summary |

## 📅 Daily Flow (5 Days)

| Day | Theme | Loops | Intent |
|-----|-------|-------|--------|
| Day 1 | Understanding | 2 | Build foundational knowledge |
| Day 2 | Application | 2 | Apply to real scenarios |
| Day 3 | Analysis | 2 | Deep dive into patterns |
| Day 4 | Integration | 2 | Connect with other frameworks |
| Day 5 | Synthesis | 2 | Create commitment artifact |

## 🔑 Core Concepts

1. **Foundation**: Understanding the historical context and design principles
2. **Architecture**: How this framework influences system design decisions
3. **Implementation**: Practical steps for adoption in enterprise environments

---

**Phase Phase$(((Get-Item $phasePath).Name) -replace 'Phase0', '') - Week $weekNum**  
**Status**: Ready for daily deep-dives  
**Last Updated**: October 19, 2025
"@
        
        Set-Content -Path $weekFile -Value $weekContent -Encoding UTF8
        $totalFilesCreated++
        
        # Create 5 daily files
        for ($dayNum = 1; $dayNum -le 5; $dayNum++) {
            $dayTheme = $cluster.Days[$dayNum - 1]
            $dayFile = Join-Path $clusterPath "$($dayNum.ToString('00'))_Day$($dayNum.ToString('00'))_$($dayTheme).md"
            
            $dayContent = @"
# Day $dayNum`: $dayTheme

**Learning Level**: Advanced  
**Time**: 27 minutes (10 min concept + 10 min practice + 7 min reflection)  
**Week**: Week $weekNum | Cluster**: $($cluster.Name)

## 🎯 Today's Focus

Single learning objective for this 27-minute session focused on $($dayTheme.Replace('_', ' ').ToLower()).

## ⏱️ 27-Minute Breakdown

### Concept Explanation (10 minutes)
- Key principle or pattern
- Why it matters in enterprise architecture
- Real-world context

### Practical Application (10 minutes)
- Exercise or scenario
- Step-by-step implementation
- Validation approach

### Reflection & Integration (7 minutes)
- Journal reflection prompt
- Connection to previous learning
- Application in your context

## 🔍 Deep Dive

Detailed exploration of today's topic with:
- Core principles
- Implementation patterns
- Common pitfalls
- Best practices

## 💼 Evidence Artifact

**Deliverable**: Complete the daily reflection in your journal or portfolio template.

## ✅ Daily Metrics

- [ ] Concept understood
- [ ] Practice exercise completed
- [ ] Reflection documented
- [ ] Integration with framework confirmed

## 🔗 Connection Points

- Previous day learning
- Related patterns from other clusters
- Enterprise application scenarios

---

**Phase Phase$(((Get-Item $phasePath).Name) -replace 'Phase0', '') - Week $weekNum, Day $dayNum**  
**Status**: Daily learning module  
**Last Updated**: October 19, 2025
"@
            
            Set-Content -Path $dayFile -Value $dayContent -Encoding UTF8
            $totalFilesCreated++
        }
        
        Write-Host "✓ $($cluster.Name) (6 files)" -ForegroundColor Green
    }
    
    # Create phase README
    $phaseReadme = Join-Path $phasePath "README.md"
    
    # Build templates list
    $templatesList = ""
    foreach ($template in $phaseDef.Templates) {
        $templatesList += "- $($template.Name)`n"
    }
    
    # Build clusters list
    $clustersList = ""
    $clusterIndex = 1
    foreach ($cluster in $phaseDef.Clusters) {
        $clustersList += "$clusterIndex. **$($cluster.Name)** - $($cluster.Theme)`n"
        $clusterIndex++
    }
    
    $readmeContent = @"
# $($phaseDef.Title)

**Phase**: $($phaseDef.Name)  
**Status**: ✅ Structure created  
**Learning Level**: Advanced (Lead Architect)  
**Total Content**: 54 files across 9 clusters  
**Estimated Time**: 45 hours (4.5 hours per cluster)

---

## 🎯 Phase Overview

$($phaseDef.Title)

### Learning Journey

Nine cluster progression building enterprise-level expertise.

## 📚 9 Learning Clusters

$clustersList

## 🛠️ Portfolio Templates (10 Reusable)

Located in `01_Templates/`:

$templatesList

## 📖 Learning Structure

**Per Cluster**:
- 1 Week Overview file (00_WeekXX)
- 5 Daily Deep-Dive files (01-05_DayXX)
- Total: 6 files per cluster

**Per Phase**:
- 9 clusters
- 54 learning files
- 10 portfolio templates
- 45 hours total curriculum

## 🚀 Next Steps

1. Begin with Cluster01
2. Follow the 5-day weekly sprint
3. Complete daily 27-minute learning loops
4. Generate portfolio artifacts
5. Advance to next cluster

---

**$($phaseDef.Title)**  
**Structure**: 9 clusters × 6 files = 54 learning modules  
**Prerequisites**: Completion of Phase$($phaseNum - 1)  
**Next Phase**: Phase$(if ($phaseNum -lt 9) { $phaseNum + 1 } else { "Career Leadership" })

Last Updated: October 19, 2025
"@
    
    Set-Content -Path $phaseReadme -Value $readmeContent -Encoding UTF8
    
    Write-Host "✓ Created $($phaseDef.Name) (65 files)" -ForegroundColor Green
    $totalFilesCreated += 65
}

# ═══════════════════════════════════════════════════════════
# SUMMARY REPORT
# ═══════════════════════════════════════════════════════════

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   PHASE03-09 STRUCTURES SUCCESSFULLY CREATED               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "📊 SUMMARY" -ForegroundColor Green
Write-Host "  • Phases generated: $($phasesToGenerate.Count)" -ForegroundColor Gray
Write-Host "  • Clusters per phase: 9" -ForegroundColor Gray
Write-Host "  • Content files per phase: 54" -ForegroundColor Gray
Write-Host "  • Template files per phase: 10" -ForegroundColor Gray
Write-Host "  • Total files created: $totalFilesCreated" -ForegroundColor Gray

Write-Host ""
Write-Host "✨ GENERATED PHASES" -ForegroundColor Cyan
foreach ($phaseNum in $phasesToGenerate) {
    if ($phaseDefinitions.ContainsKey($phaseNum)) {
        $phaseName = $phaseDefinitions[$phaseNum].Name
        $phaseTitle = $phaseDefinitions[$phaseNum].Title
        Write-Host "  ✓ $phaseName" -ForegroundColor Green
        Write-Host "    → $phaseTitle" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "🚀 NEXT STEPS" -ForegroundColor Cyan
Write-Host "  1. Validate generated phase structures" -ForegroundColor Gray
Write-Host "  2. Run markdown lint validation (target: 0 errors)" -ForegroundColor Gray
Write-Host "  3. Verify all file counts match expectations" -ForegroundColor Gray
Write-Host "  4. Prepare git commits for all phases" -ForegroundColor Gray

Write-Host ""
