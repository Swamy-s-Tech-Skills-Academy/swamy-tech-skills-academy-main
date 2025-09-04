# 🛠️ Practical NLP Implementation Examples

**Purpose**: Working code examples and implementation demonstrations for fundamental NLP concepts  
**Learning Level**: Beginner to Intermediate  
**Repository**: [LLM Agents Learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)

## 📋 Available Implementations

### **One-Hot Encoding Implementation**

**Concept**: Convert tokens to sparse binary vectors with single 1-position per token

**Quick Demo**:

```powershell
# Clone and run canonical implementation
git clone https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning
Set-Location .\llm-agents-learning
python .\one_hot.py "i like pizza"
```

**Expected Output**:

```text
vocab: ['i', 'like', 'pizza']
index: {'i': 0, 'like': 1, 'pizza': 2}
matrix:
[1, 0, 0]  ← "i"
[0, 1, 0]  ← "like"  
[0, 0, 1]  ← "pizza"
```

**Key Learning**: Each token maps to exactly one position in vocabulary-sized vector

---

### **Bag-of-Words Implementation**

**Concept**: Count token frequencies across documents, ignore order

**Quick Demo**:

```powershell
# Using same repository
python .\bag_of_words.py "i like pizza i like"
```

**Expected Output**:

```text
vocab: ['i', 'like', 'pizza']
vector: [2, 2, 1]  ← counts for each vocabulary item
```

**Key Learning**: BoW captures frequency but loses positional information

---

### **TF-IDF Implementation**

**Concept**: Weight terms by frequency and inverse document frequency

**Quick Demo**:

```powershell
# Multi-document analysis
python .\tfidf_demo.py
```

**Expected Output**:

```text
vocab: [complete vocabulary from corpus]
TF-IDF matrix: (documents × vocabulary)
- Higher weights: frequent in document, rare in corpus
- Lower weights: common across all documents
```

**Key Learning**: TF-IDF highlights distinctive terms per document

---

### **Token Encoding and Embeddings Concepts**

**Concept**: Complete text-to-vector pipeline understanding

**Practical Knowledge Areas**:

1. **Tokenization Strategies**
   - Word-level: "machine learning" → ["machine", "learning"]
   - Sub-word: "machine learning" → ["mach", "ine", "learn", "ing"]
   - Character: "machine learning" → ["m", "a", "c", "h", ...]

2. **Token ID Mapping**

   ```text
   "machine" → Token ID: 1456
   "learning" → Token ID: 1247
   ```

3. **Embedding Vectors**

   ```text
   Token ID 1456 → [0.234, -0.156, 0.789, ...]  (512-dim vector)
   Token ID 1247 → [0.312, -0.089, 0.845, ...]  (512-dim vector)
   ```

4. **Semantic Relationships**
   - Similar concepts have similar vectors
   - Distance measures capture meaning relationships
   - Context can modify base embeddings

**Implementation Focus**: Understanding pipeline flow rather than coding from scratch

## 🔗 Integration with Reference Library

### **Cross-References**

- **[One-Hot Encoding Guide](../01_One-Hot-Encoding.md)** - Theoretical foundation
- **[Bag-of-Words Guide](../03_Bag-of-Words.md)** - Conceptual understanding  
- **[TF-IDF Guide](../04_TF-IDF.md)** - Mathematical background
- **[Token Encoding Guide](../06_Token-Encoding-and-Embeddings.md)** - Complete pipeline

### **Learning Progression**

1. **Study concept** in Reference Library guide
2. **Run implementation** from this examples collection
3. **Experiment** with variations and edge cases
4. **Apply** to real-world text processing tasks

## 🚀 Getting Started

### **Prerequisites**

- Python 3.8+ installed
- Basic command line familiarity
- Understanding of fundamental NLP concepts

### **Setup Instructions**

```powershell
# Clone the canonical implementation repository
git clone https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning

# Navigate to repository
Set-Location .\llm-agents-learning

# Install dependencies (if requirements.txt exists)
pip install -r requirements.txt

# Run examples as shown above
```

### **Next Steps**

- Modify examples with your own text data
- Experiment with different vocabulary sizes
- Compare results across different tokenization strategies
- Explore integration with modern NLP libraries

---

**Last Updated**: September 4, 2025  
**External Repository**: [llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)  
**Status**: Educational examples for Reference Library integration
