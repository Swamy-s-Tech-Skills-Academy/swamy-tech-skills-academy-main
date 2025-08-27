# 🏗️ Reference Library Organization & Domain Structure

> See also: [README](README.md) · [INDEX](INDEX.md) · [TAXONOMY_MAP](TAXONOMY_MAP.md)

> When to edit this file: Update structure rules, numbering, stub policy, and governance. Do not place navigation graphs here (see INDEX).

## Comprehensive mapping of AI ecosystem domains with clear boundaries and relationships

---

## 🎯 Organizational Philosophy

Our reference library follows the **interconnected domain model** where each folder represents a distinct field while maintaining clear relationships with related domains. This structure reflects the reality that modern AI solutions typically combine multiple domains.

---

## 📁 Domain Structure & Relationships

### **Core AI Ecosystem**

```text
03_ReferenceLibrary/
├── AI/                           # Umbrella domain (broadest scope)
├── MachineLearning/              # AI subset (algorithms & training)
├── DeepLearning/                 # ML subset (neural networks)
├── NaturalLanguageProcessing/    # AI specialization (text & language)
├── DataScience/                  # Overlapping domain (insights & modeling)
├── DataAnalytics/                # Data science subset (analysis & visualization)
├── BigData/                      # Infrastructure domain (scale & processing)
├── Python/                       # Programming foundation
└── software-design-principles/   # Engineering foundation
```

---

## 🔗 Domain Definitions & Scope

### **AI/ (Artificial Intelligence)**

**Scope**: Broadest AI concepts, general intelligence, and cross-domain topics
**Contents**:

- AI fundamentals and philosophy
- Domain relationship mappings
- AI ethics and governance
- General AI applications
- Historical perspectives

**Example Topics**: AGI, AI safety, multi-domain AI systems, AI strategy

---

### **MachineLearning/**

**Scope**: Algorithms, training methods, and traditional ML approaches
**Contents**:

- Classical ML algorithms
- Model training and evaluation
- Feature engineering
- Ensemble methods
- AutoML and optimization

**Example Topics**: Random forests, SVM, gradient boosting, cross-validation

---

### **DeepLearning/**

**Scope**: Neural networks, deep architectures, and advanced learning
**Contents**:

- Neural network architectures
- Training techniques and optimization
- Computer vision models
- Advanced deep learning research
- Framework-specific guides

**Example Topics**: CNNs, RNNs, Transformers, backpropagation, regularization

---

### **NaturalLanguageProcessing/**

**Scope**: Text processing, language understanding, and linguistic AI
**Contents**:

- Text preprocessing and tokenization
- Language models and embeddings
- NLP applications and tasks
- Linguistic concepts for AI
- Speech and language generation

**Example Topics**: BERT, sentiment analysis, NER, machine translation

---

### **DataScience/**

**Scope**: Data-driven insights, statistical analysis, and scientific methodology
**Contents**:

- Statistical methods and inference
- Experimental design
- Data visualization principles
- Business intelligence
- Research methodologies

**Example Topics**: Hypothesis testing, A/B testing, causal inference, statistical modeling

---

### **DataAnalytics/**

**Scope**: Data analysis, visualization, and business intelligence
**Contents**:

- Descriptive analytics
- Exploratory data analysis
- Dashboard design
- KPI development
- Reporting frameworks

**Example Topics**: Data visualization, business metrics, trend analysis, reporting

---

### **BigData/**

**Scope**: Large-scale data processing, distributed systems, and infrastructure
**Contents**:

- Distributed computing frameworks
- Data pipeline architectures
- Stream processing
- Cloud data platforms
- Scalability patterns

**Example Topics**: Spark, Hadoop, Kafka, data lakes, distributed storage

---

## 🎯 Content Placement Guidelines

### **Where to Place Content**

#### **Cross-Domain Topics**

Place in the **highest-level applicable domain**:

- AI ethics → `AI/`
- ML model deployment → `MachineLearning/`
- Deep learning for NLP → `DeepLearning/` (with cross-reference to NLP)

#### **Specialized Applications**

Place in the **most specific domain**:

- Computer vision → `DeepLearning/`
- Named entity recognition → `NaturalLanguageProcessing/`
- Recommendation systems → `MachineLearning/`

#### **Infrastructure & Tools**

Place in the **most relevant domain**:

- TensorFlow/PyTorch → `DeepLearning/`
- Scikit-learn → `MachineLearning/`
- Apache Spark → `BigData/`

#### **Business Applications**

Place based on **primary methodology**:

- Customer segmentation (ML-based) → `MachineLearning/`
- Sales dashboards → `DataAnalytics/`
- Market research → `DataScience/`

---

## 🔄 Cross-Reference System

### **Linking Strategy**

Each domain README includes:

- **Related Domains**: Direct relationships
- **Upstream Dependencies**: What you need to know first
- **Downstream Applications**: What builds on this domain
- **Cross-References**: Links to related content in other folders

### **Example Cross-Reference Pattern**

```markdown
## 🔗 Related Domains

### **Prerequisites**

- `MachineLearning/` - Algorithm fundamentals
- `Python/` - Programming foundation

### **Builds Upon**

- `AI/` - General AI concepts
- `DataScience/` - Statistical methods

### **Enables**

- `NaturalLanguageProcessing/` - Language model applications
- Computer vision applications

### **Cross-References**

- See `AI/AI-Domain-Relationships.md` for conceptual overview
- See `MachineLearning/optimization-methods.md` for training details
```

---

## 📚 Content Distribution Strategy

### **AI Relationship Diagrams Placement**

#### **Main Conceptual Diagrams**

- **Domain relationship diagrams** → `AI/AI-Domain-Relationships.md`
- **Hierarchy visualizations** → `AI/` (as they show the full ecosystem)

#### **Domain-Specific Diagrams**

- **ML algorithm relationships** → `MachineLearning/`
- **Deep learning architecture diagrams** → `DeepLearning/`
- **Data pipeline flows** → `BigData/`
- **Analytics workflow diagrams** → `DataAnalytics/`

### **Learning Path Integration**

- **Cross-domain learning paths** → `AI/AI-Learning-Topics.md`
- **Domain-specific curricula** → Each domain's README
- **Specialization tracks** → Relevant domain folders

---

## 🎯 Maintenance & Evolution

### **Folder Management**

- **Domain Ownership**: Each folder has clear scope and purpose
- **Content Migration**: Move content when scope changes
- **Relationship Updates**: Keep cross-references current
- **Scope Expansion**: Add new domains as needed

### **Deprecation & Renumbering Policy**

When learning sequences are renumbered or restructured to improve pedagogy:

1. **Canonical Files First**: Create (or move) the authoritative content at its new numbered filename.
2. **Redirect Stubs**: Replace the old filename with a short Markdown stub that includes: deprecated notice; bold forward link to canonical file; one-sentence rationale (e.g., sequencing normalization, insertion of new foundational module); removal target date (90–180 day window) and last-reviewed date.
3. **Internal Link Sweep**: Update all internal cross-references to point to the canonical file (avoid chaining through stubs).
4. **Lychee Integrity**: Keep stubs until repository-wide link scans show zero references to the deprecated path for two consecutive review cycles.
5. **Sunset Removal**: Remove the stub file after the retention window; add an entry to a central CHANGELOG (future) or migration note section for historical traceability.
6. **Avoid Silent Deletes**: Never delete or rename numbered learning modules without adding a stub (prevents external link rot and preserves learner bookmarks).

#### Stub Template

```markdown
# {OLD_NUMBER}_{Title} (Renumbered → {NEW_NUMBER}_{Title}.md)

**➡️ Go to: [{NEW_NUMBER}_{Title}.md]({NEW_NUMBER}_{Title}.md)**

This module was renumbered as part of sequence restructuring to improve progression clarity.

**Deprecated**: Yes  
**Original Path**: {old relative path}  
**Canonical Path**: {new relative path}  
**Removal Target**: {YYYY-MM-DD} (≥90 days from change)  
**Last Reviewed**: {YYYY-MM-DD}
```

#### Rationale

Renumbering is sometimes required when:

- Inserting foundational material earlier in the sequence
- Splitting an overloaded module into multiple focused ones
- Aligning numbering across parallel tracks (e.g., AI Agents vs LLM Fundamentals)

#### Review Cadence

- Perform a quarterly audit of deprecated stubs
- Remove any past their removal target with no inbound references
- Document removals in the central CHANGELOG (planned) or quarterly audit note

> NOTE: Current active stubs (Aug 2025): legacy agent files 01_–06_ redirecting to canonical 03_–08_.

### **Future Considerations**

Potential additional domains:

- `ComputerVision/` (if it grows beyond DeepLearning scope)
- `Robotics/` (for physical AI applications)
- `QuantumML/` (for quantum machine learning)
- `MLOps/` (for deployment and operations)

---

## 🔍 Quick Navigation Guide

### **For Beginners**

1. Start with `AI/` for conceptual overview
2. Move to `MachineLearning/` for algorithms
3. Explore `DataAnalytics/` for practical applications
4. Use `Python/` for implementation

### **For Practitioners**

1. Use domain-specific folders for deep dives
2. Reference `AI/AI-Domain-Relationships.md` for positioning
3. Follow cross-references for related concepts
4. Check `software-design-principles/` for engineering best practices

### **For Leaders**

1. Focus on `AI/` for strategic overview
2. Review `DataScience/` for methodology
3. Explore `DataAnalytics/` for business applications
4. Use cross-domain learning paths for team development

---

**📅 Created**: July 2025  
**🎯 Purpose**: Clear organization of interconnected AI domains  
**📍 Context**: Reference library structure for comprehensive AI learning

---

**💡 Organizational Principle**: Each domain is distinct yet interconnected. Content placement follows the principle of most specific applicable domain with clear cross-references to related areas.
