# 03_Tokenization-and-Token-IDs

**Learning Level**: Beginner to Intermediate  
**Prerequisites**: Basic understanding of neural networks, text processing fundamentals  
**Estimated Time**: 20-25 minutes  
**Last Updated**: August 29, 2025

## 🎯 Learning Objectives

By the end of this content, you will:

- Understand what tokenization is and why it's necessary for language models
- Explain the concept of Token IDs and their role in neural network processing
- Recognize the two-step process: Text → Tokens → Token IDs
- Understand why neural networks work with numbers instead of raw text
- Identify common tokenization patterns and vocabulary mapping strategies

## 📋 Content Overview

### 🔤 What is Tokenization?

Tokenization is the process of breaking down text into smaller, manageable pieces called **tokens**. These tokens can be:

- **Words**: "apple", "running", "beautiful"
- **Subwords**: "un-", "-ing", "pre-"
- **Characters**: Individual letters or punctuation marks
- **Byte-level**: Raw bytes representing text

### 🔢 The Two-Step Transformation Process

When Large Language Models (LLMs) process text, they follow a systematic transformation:

```text
Step 1: Text Segmentation
"The human brain is complex" → ["The", " human", " brain", " is", " complex"]

Step 2: Numerical Mapping  
["The", " human", " brain", " is", " complex"] → [791, 3823, 8271, 374, 6485]
```

#### Why This Two-Step Process?

1. **Neural Network Compatibility**: Neural networks operate on numerical matrices, not text strings
2. **Computational Efficiency**: Integer operations are faster than string processing
3. **Consistent Representation**: Each token maps to exactly one ID across all uses
4. **Memory Optimization**: IDs require less storage than storing full token strings repeatedly

### 🗂️ Understanding Token IDs

**Token IDs** are unique integers that serve as lookup keys in the model's vocabulary:

```text
Vocabulary Mapping Example:
Token      → Token ID
"The"      → 791
" human"   → 3823
" brain"   → 8271
" is"      → 374
","        → 11
"problem"  → 3575
"-solving" → 99246
```

#### Key Characteristics of Token IDs

- **Unique Mapping**: Each token in the vocabulary has exactly one ID
- **Model-Specific**: Different models use different vocabularies and ID mappings
- **Arbitrary Numbers**: The actual ID values have no inherent meaning
- **Consistent**: The same token always maps to the same ID within a model

### 🧠 Why Numbers Instead of Text?

Neural networks are fundamentally mathematical systems that require numerical inputs:

#### Technical Reasons

1. **Matrix Operations**: Neural networks perform linear algebra on numerical matrices
2. **Embedding Lookups**: Token IDs index into learned embedding vectors
3. **Gradient Computation**: Backpropagation requires differentiable numerical operations
4. **Hardware Optimization**: GPUs are designed for numerical computation

#### Practical Benefits

```text
Text Processing Flow:
Raw Text → Tokenizer → Token IDs → Embedding Layer → Neural Network

"incredible" → Token ID 17235 → [0.2, -0.8, 1.1, ...] → Processing
```

### �️ Understanding tiktoken Encodings

**tiktoken** is OpenAI's tokenizer library that provides different **encodings** - specific sets of rules for breaking text into tokens, each with its own vocabulary mapping tokens to Token IDs.

#### What are Encodings?

An **encoding** in tiktoken consists of:

- **Tokenization Rules**: How text is split into tokens
- **Vocabulary Mapping**: Each token mapped to a unique Token ID
- **Model Compatibility**: Each model was trained with a specific encoding

#### Why Different Encodings Exist

Different encodings exist because:

- **Model Evolution**: Each model generation has improved tokenization
- **Training Data**: Models trained on different datasets need different vocabularies
- **Efficiency**: Newer encodings produce fewer tokens for the same text (lower costs)
- **Specialization**: Some encodings optimized for code, others for general text

#### The Three Main Encodings

##### 1️⃣ `cl100k_base` (Current Standard)

**Used by:**

- GPT-4 (all variants)
- GPT-3.5-Turbo (all versions)
- text-embedding-ada-002

**Characteristics:**

- "cl" = Core Language, "100k" = ~100,000 token vocabulary
- Most efficient: produces fewer tokens per text
- Optimized for multiple languages
- Lower API costs due to fewer tokens

##### 2️⃣ `p50k_base` (Code-Optimized)

**Used by:**

- Codex models (code-davinci-002, code-cushman-001)
- Some GPT-3 text completion models
- text-davinci-003, text-davinci-002

**Characteristics:**

- "p" = Pile (trained on The Pile dataset)
- ~50,000 token vocabulary
- Optimized for code and text
- Variant: `p50k_edit` for edit models

##### 3️⃣ `r50k_base` (Legacy)

**Used by:**

- Original GPT-3 models (davinci, curie, babbage, ada)
- Older embedding models

**Characteristics:**

- "r" = Reference (original GPT-3 tokenizer)
- ~50,000 token vocabulary
- Less efficient: produces more tokens for same text
- Legacy compatibility only

#### Encoding Comparison Example

Same text tokenized with different encodings:

```text
Input: "I have a white dog named Champ."

cl100k_base: 8 tokens → [40, 617, 264, 4251, 5679, 7086, 56690, 13]
p50k_base:   9 tokens → [40, 423, 257, 1576, 3290, 2863, 12682, 13]
r50k_base:   9 tokens → [40, 423, 257, 1576, 3290, 2863, 12682, 13]
```

**Key Observations:**

- **Different token counts**: cl100k_base is more efficient
- **Different Token IDs**: Each encoding has its own vocabulary
- **Cost implications**: Fewer tokens = lower API costs

### 📋 OpenAI Model-to-Encoding Reference

| **Model Name** | **Model Type** | **tiktoken Encoding** | **Notes** |
|----------------|----------------|-----------------------|-----------|
| **gpt-4**, **gpt-4-32k** | Chat | `cl100k_base` | Latest GPT-4 models |
| **gpt-4-turbo**, **gpt-4-1106-preview** | Chat | `cl100k_base` | Cheaper, faster GPT-4 variants |
| **gpt-3.5-turbo** (all versions) | Chat | `cl100k_base` | Default for GPT-3.5 chat |
| **text-embedding-ada-002** | Embeddings | `cl100k_base` | Latest embeddings model |
| **text-davinci-003**, **text-davinci-002** | Completion | `p50k_base` | GPT-3 text completion |
| **code-davinci-002**, **code-cushman-001** | Code | `p50k_base` | Codex models for code |
| **text-davinci-edit-001**, **code-davinci-edit-001** | Edit | `p50k_edit` | Special edit mode tokenizer |
| **davinci**, **curie**, **babbage**, **ada** | Completion | `r50k_base` | Original GPT-3 models |
| **text-similarity-ada-001** | Embeddings | `r50k_base` | Older embeddings model |
| **text-search-ada-doc-001**, **text-search-ada-query-001** | Embeddings/Search | `r50k_base` | Older search models |
| **code-search-ada-code-001**, **code-search-ada-text-001** | Embeddings/Search | `r50k_base` | Older code search models |

#### How to Use This Reference

**Manual Encoding Selection:**

```python
import tiktoken

# Specify encoding directly
encoding = tiktoken.get_encoding("cl100k_base")
tokens = encoding.encode("Your text here")
```

**Automatic Model-Based Selection:**

```python
import tiktoken

# Let tiktoken choose the encoding for the model
encoding = tiktoken.encoding_for_model("gpt-4")
tokens = encoding.encode("Your text here")
```

#### Quick Reference Summary

- **cl100k_base** → Modern GPT-4, GPT-3.5, latest embeddings
- **p50k_base** → GPT-3 completions and Codex models
- **p50k_edit** → Edit models only
- **r50k_base** → Legacy GPT-3 and older embeddings

#### Critical Usage Guidelines

1. **Always match encoding to model** - wrong encoding gives incorrect token counts
2. **Use automatic selection when possible** - `tiktoken.encoding_for_model()` prevents errors
3. **Verify token counts** - incorrect encoding leads to wrong cost calculations
4. **Test with sample text** - different encodings can have significant count differences

### 🔧 Robust Implementation Helper

For production use, here's an improved helper function with proper error handling and documentation:

```python
import tiktoken

def get_encoding_for_model(model_name: str) -> tiktoken.Encoding:
    """
    Determine and return the correct tiktoken encoding for a given OpenAI model.

    This function uses tiktoken's internal mapping to look up the correct
    encoding scheme for the specified model. Encodings define how text is
    split into tokens and how tokens are mapped to unique IDs.

    If the provided model name is not recognized, the function falls back
    to using 'cl100k_base', which is the default encoding for most modern
    OpenAI models (e.g., GPT-4, GPT-3.5, and latest embeddings).

    Args:
        model_name (str):
            The name of the OpenAI model (e.g., "gpt-4", "text-davinci-003").
            The name should match an official OpenAI model identifier.

    Returns:
        tiktoken.Encoding:
            The encoding object corresponding to the given model. This object
            can be used to encode text into token IDs and decode token IDs back
            into text.

    Example:
        >>> enc = get_encoding_for_model("gpt-4")
        >>> tokens = enc.encode("Hello world!")
        >>> print(tokens)
        [9906, 1917, 0]
        >>> text = enc.decode(tokens)
        >>> print(text)
        Hello world!
    """
    try:
        # tiktoken has a built-in function for this lookup
        encoding = tiktoken.encoding_for_model(model_name)
    except KeyError:
        # If the model isn't recognized, use cl100k_base as a safe default
        print(f"[Warning] Model '{model_name}' not found in tiktoken database. Using 'cl100k_base'.")
        encoding = tiktoken.get_encoding("cl100k_base")
    return encoding


# Example usage demonstration
if __name__ == "__main__":
    models = [
        "gpt-4",
        "gpt-3.5-turbo",
        "text-davinci-003",
        "code-davinci-002",
        "davinci",
        "text-embedding-ada-002",
        "unknown-model"
    ]

    for model in models:
        enc = get_encoding_for_model(model)
        print(f"Model: {model:<25} | Encoding: {enc.name}")
```

#### Expected Output

```text
Model: gpt-4                   | Encoding: cl100k_base
Model: gpt-3.5-turbo            | Encoding: cl100k_base
Model: text-davinci-003         | Encoding: p50k_base
Model: code-davinci-002         | Encoding: p50k_base
Model: davinci                  | Encoding: r50k_base
Model: text-embedding-ada-002   | Encoding: cl100k_base
[Warning] Model 'unknown-model' not found in tiktoken database. Using 'cl100k_base'.
Model: unknown-model            | Encoding: cl100k_base
```

#### Implementation Benefits

- **Error handling**: Graceful fallback for unknown models
- **Type hints**: Clear parameter and return types
- **Comprehensive docstring**: Follows PEP 257 standards
- **Production ready**: Suitable for real applications
- **Warning system**: Alerts when fallback encoding is used

### �📊 Practical Example with tiktoken

Here's how the tokenization process works in practice:

#### Input Text

```text
"The human brain is an incredibly complex organ, capable of processing information."
```

#### Tokenization Result

```text
Decoded Tokens: ['The', ' human', ' brain', ' is', ' an', ' incredibly', ' complex', ' organ', ',', ' capable', ' of', ' processing', ' information', '.']

Token IDs: [791, 3823, 8271, 374, 459, 17235, 6485, 2942, 11, 13171, 315, 8863, 2038, 13]
```

#### Analysis

- **"The"** → ID 791 (common word, low ID number)
- **" human"** → ID 3823 (note the leading space)
- **","** → ID 11 (punctuation gets its own token)
- **"-solving"** → ID 99246 (suffix/compound, higher ID number)

### 🔍 Common Tokenization Patterns

#### Subword Tokenization Benefits

1. **Handling Unknown Words**: Break rare words into known subparts
2. **Vocabulary Efficiency**: Smaller vocabulary covers more text variations
3. **Morphological Awareness**: Captures prefixes, suffixes, and roots

#### Example Patterns

```text
Word: "unhappiness"
Possible Tokenization: ["un", "happy", "ness"]
Token IDs: [359, 6380, 2136]

Word: "ChatGPT"
Possible Tokenization: ["Chat", "GPT"]  
Token IDs: [14581, 38, 18276]
```

### 💡 Key Insights and Analogies

#### Dictionary Analogy

Think of tokenization like using a **dictionary with page numbers**:

- **Word**: "apple"
- **Dictionary Page**: 1523
- **Model Processing**: Instead of reading "apple", the model reads "page 1523"

#### Library Catalog System

```text
Book Title: "Machine Learning Fundamentals"
Catalog Number: ML-2024-0891
Librarian uses: Number (efficient)
Humans recognize: Title (meaningful)
```

### ⚠️ Common Pitfalls and Considerations

#### Vocabulary Limitations

- **Out-of-Vocabulary (OOV)**: Tokens not in the training vocabulary
- **Model-Specific**: Token IDs are not transferable between different models
- **Case Sensitivity**: "Apple" and "apple" may have different IDs

#### Debugging Tokenization Issues

1. **Unexpected Splits**: Words split in unintuitive ways
2. **Leading Spaces**: Many tokenizers include leading spaces as part of tokens
3. **Special Characters**: Punctuation and symbols may tokenize unexpectedly

### 🔗 Integration with Model Architecture

#### Embedding Layer Connection

```text
Token ID Input: [791, 3823, 8271]
                    ↓
Embedding Lookup: [[0.2, -0.8, 1.1], 
                   [0.5, 0.3, -0.2], 
                   [-0.1, 0.9, 0.4]]
                    ↓
Neural Network Processing
```

#### Why This Matters

- **Learned Representations**: Each ID corresponds to learned semantic vectors
- **Contextual Processing**: The model learns relationships between ID patterns
- **Transfer Learning**: Pre-trained embeddings encode semantic knowledge

## 🚀 Next Steps

### Immediate Applications

- Experiment with different tokenizers (tiktoken, SentencePiece, Hugging Face)
- Analyze tokenization patterns for your specific text domains
- Understand token count implications for API costs and context limits

### Advanced Topics to Explore

- **Byte-Pair Encoding (BPE)**: Subword tokenization algorithm
- **SentencePiece**: Language-agnostic tokenization
- **Token Economy**: Understanding API pricing based on token counts
- **Context Windows**: How token limits affect model performance

### Related Learning Paths

- [Text Preprocessing Fundamentals](../01_Text-Preprocessing-Fundamentals.md)
- [Embedding Techniques](../02_Word-Embeddings-and-Representations.md)
- [Language Model Architecture](../../05_LargeLanguageModels/01_Transformer-Architecture.md)

## 🔗 Related Topics

**Prerequisites:**

- Text preprocessing fundamentals
- Basic neural network concepts
- String manipulation in programming

**Builds Upon:**

- Character encoding (UTF-8, ASCII)
- Data representation in computer systems
- Mathematical foundations of neural networks

**Enables:**

- Understanding LLM API token limits
- Optimizing text for model processing
- Debugging text processing pipelines
- Cost estimation for LLM usage

**Cross-References:**

- [Transformer Architecture](../../01_AI/01_Understanding-Transformer-Architecture.md)
- [Natural Language Processing Pipeline](./01_NLP-Processing-Pipeline.md)
- [Large Language Models Overview](../../05_LargeLanguageModels/01_LLM-Fundamentals.md)

---

*This content is part of Swamy's Tech Skills Academy comprehensive AI & ML learning track. For hands-on examples and code implementations, visit our [practical examples repository](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data).*
