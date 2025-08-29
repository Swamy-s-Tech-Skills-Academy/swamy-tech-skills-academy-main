# 04_Tiktoken-Encodings-Guide

**Learning Level**: Intermediate  
**Prerequisites**: Basic understanding of tokenization, Token IDs  
**Estimated Time**: 15 minutes

## 🎯 Learning Objectives

By the end of this content, you will:

- Understand what encodings are in the context of tiktoken and OpenAI models
- Know the differences between cl100k_base, p50k_base, and r50k_base encodings
- Be able to choose the correct encoding for different OpenAI models
- Understand why different encodings exist and their impact on token efficiency

## 📋 What are Tiktoken Encodings?

In OpenAI's tokenizer library **tiktoken**, an **encoding** is essentially:

> A *specific set of rules* for breaking text into tokens, plus a *vocabulary* mapping each token to a unique **Token ID**.

Different encodings exist because **different models** were trained with different tokenization rules and vocabularies. Using the wrong encoding for a model results in incorrect token counts and potential model misinterpretation.

## 🔧 The Three Primary Encodings

### 1️⃣ cl100k_base (Current Standard)

**Used by:**

- GPT-4 (all variants)
- GPT-3.5-Turbo and newer chat models
- text-embedding-ada-002 embeddings model

**Characteristics:**

- Current, most efficient tokenizer
- Optimized for English but supports many languages
- "cl" stands for "Core Language"
- "100k" indicates vocabulary size of approximately 100,000 tokens
- Produces fewer tokens for the same text compared to older encodings

**Why it matters:**

- Lower token counts = reduced API costs
- Faster processing due to efficiency
- Better handling of modern text patterns

### 2️⃣ p50k_base (Code-Optimized)

**Used by:**

- Codex models (code-davinci-002, code-cushman-001)
- Some older GPT-3 models for text
- text-davinci-edit-001 (uses variant p50k_edit)

**Characteristics:**

- "p" stands for "pile" (trained on The Pile dataset)
- Vocabulary size of approximately 50,000 tokens
- Optimized for both code and natural language
- Better code tokenization compared to r50k_base

### 3️⃣ r50k_base (Legacy)

**Used by:**

- Early GPT-3 models (davinci, curie, babbage, ada)
- Original OpenAI text completion models

**Characteristics:**

- "r" stands for "reference" (original GPT-3 tokenizer)
- Vocabulary size of approximately 50,000 tokens
- Less efficient for modern usage
- Produces more tokens for the same input compared to newer encodings

## 📊 Encoding Comparison Example

Let's examine how the same sentence is tokenized differently:

**Input Text:**

```text
I have a white dog named Champ.
```

**Tokenization Results:**

| Encoding      | Token Count | Efficiency | Token IDs Example                            |
|---------------|-------------|------------|----------------------------------------------|
| cl100k_base   | 8           | Highest    | [40, 617, 264, 4251, 5679, 7086, 56690, 13] |
| p50k_base     | 9           | Medium     | [40, 423, 257, 1576, 3290, 2863, 12682, 13] |
| r50k_base     | 9           | Lowest     | [40, 423, 257, 1576, 3290, 2863, 12682, 13] |

**Key Observations:**

- **Token counts vary** between encodings
- **Token IDs are completely different** (each has its own vocabulary)
- **cl100k_base is most efficient** (fewer tokens for same content)

## 🔍 Why Different Encodings Exist

### Historical Evolution

1. **r50k_base (2020)**: Original GPT-3 tokenizer
2. **p50k_base (2021)**: Improved for code and diverse text
3. **cl100k_base (2022)**: Optimized for modern models and efficiency

### Technical Improvements

- **Increased vocabulary size**: More tokens = better representation
- **Better punctuation handling**: Improved tokenization of special characters
- **Multi-language support**: Enhanced non-English text processing
- **Efficiency gains**: Reduced token counts = lower costs

### Model-Specific Training

Each model was trained with a specific encoding:

- The vocabulary is **fixed at training time**
- Models expect tokens from their specific vocabulary
- Using wrong encoding breaks the model's understanding

## 🛠️ Practical Usage Guidelines

### Model-to-Encoding Mapping

```text
GPT-4 Family          → cl100k_base
GPT-3.5-Turbo        → cl100k_base
Embeddings (ada-002)  → cl100k_base
Codex Models          → p50k_base
Legacy GPT-3          → r50k_base
```

### Code Example

```python
import tiktoken

# Get the correct encoding for your model
encoding = tiktoken.get_encoding("cl100k_base")  # For GPT-4/3.5-Turbo

# Or get encoding by model name
encoding = tiktoken.encoding_for_model("gpt-4")

# Tokenize text
text = "I have a white dog named Champ."
tokens = encoding.encode(text)
token_count = len(tokens)

print(f"Token count: {token_count}")
print(f"Token IDs: {tokens}")
```

## ⚠️ Common Pitfalls

### Using Wrong Encoding

**Problem**: Counting tokens with r50k_base for GPT-4

```python
# WRONG - will give incorrect token count
wrong_encoding = tiktoken.get_encoding("r50k_base")
wrong_count = len(wrong_encoding.encode(text))  # Inaccurate

# CORRECT - matches GPT-4's actual tokenization
correct_encoding = tiktoken.get_encoding("cl100k_base")
correct_count = len(correct_encoding.encode(text))  # Accurate
```

**Impact**: Incorrect cost estimates, unexpected API errors

### Model Name Confusion

**Problem**: Using encoding name instead of model name

```python
# WRONG - "gpt-4" is not an encoding name
encoding = tiktoken.get_encoding("gpt-4")  # Error

# CORRECT - use encoding_for_model for model names
encoding = tiktoken.encoding_for_model("gpt-4")  # Works
```

## 🎓 Key Takeaways

1. **Encodings are model-specific** - each model expects its training encoding
2. **cl100k_base is current standard** - use for GPT-4 and GPT-3.5-Turbo
3. **Efficiency matters** - newer encodings produce fewer tokens
4. **Always verify** - use correct encoding for accurate token counting
5. **Cost impact** - wrong encoding leads to incorrect cost estimates

## 🔗 Related Topics

### Prerequisites

- [03_Tokenization-and-Token-IDs](./03_Tokenization-and-Token-IDs.md) - Understanding basic tokenization concepts

### Builds Upon

- Token vocabulary concepts
- Neural network text processing
- OpenAI model architecture

### Enables

- Accurate token counting for API costs
- Proper model selection for applications
- Debugging tokenization issues
- Optimizing text for token efficiency

### Cross-References

- **Development Track**: API integration patterns, cost optimization
- **AI Track**: Model selection criteria, performance optimization

---

**Last Updated**: August 29, 2025  
**Next Review**: December 2025
