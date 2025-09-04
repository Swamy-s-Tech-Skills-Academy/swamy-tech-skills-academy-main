# 01_One-Hot-Encoding

Learning Level: Beginner  
Prerequisites: Basic Python, intro ML terminology  
Estimated Time: 15–20 minutes

## Learning Objectives

By the end, you will be able to:

- Explain what one-hot encoding is and why it’s used for text
- Build a vocabulary and convert tokens to one-hot vectors
- Identify limitations and when to prefer other representations

## Conceptual Foundation

One-hot encoding maps each token in a fixed vocabulary to a vector of zeros with a single 1 at the token’s index. It’s simple and fast, but:

- Vectors are high-dimensional and sparse
- No semantic similarity ("cat" and "dog" are orthogonal)
- Vocabulary drift and out-of-vocabulary (OOV) tokens require careful handling

## Practical Examples

```text
Tokens: ["cat", "barks", "loud"]
Vocab:  {"cat": 0, "dog": 1, "barks": 2, "meows": 3, "loud": 4}

cat   -> [1, 0, 0, 0, 0]
barks -> [0, 0, 1, 0, 0]
loud  -> [0, 0, 0, 0, 1]
```

Small vocabularies are fine; large corpora quickly become memory-heavy.

## Implementation Guide

- Build vocabulary deterministically (sorted tokens or frequency-based)
- Reserve IDs for special tokens (UNK/OOV, PAD)
- Keep a versioned vocabulary file to avoid index drift across runs

## Common Pitfalls

- Using different vocabularies between training and inference
- Memory blow-up when the vocabulary isn’t constrained
- Treating one-hot vectors as if they contained semantic information

## Next Steps

- Progress to bag-of-words (counts) and TF-IDF (reweighted counts)
- Adopt embeddings (word2vec/fastText) for semantic similarity

## Related Topics

- Bag of Words: 02_Bag-of-Words.md
- TF-IDF: 03_TF-IDF.md
- Embeddings: 04_Word2Vec-and-Embeddings.md
- Knowledge Base evidence: ../../../../01_LeadArchitectKnowledgeBase/AI-NLP/2025-08-11_One-Hot-Encoding/README.md
- LLM foundation context: ../../05_LargeLanguageModels/01_LLM-Fundamentals.md
