# 02_Bag-of-Words

Learning Level: Beginner  
Prerequisites: One-hot encoding basics  
Estimated Time: 20–25 minutes

## Learning Objectives

- Describe the bag-of-words (BoW) representation
- Build a document-term matrix and interpret counts
- Understand sparsity and dimensionality tradeoffs

## Conceptual Foundation

BoW represents a document by token frequency over a fixed vocabulary. Word order is discarded; only term presence and counts remain. It’s effective for linear models and fast baselines.

## Practical Examples

```text
Docs:
  d1: "cats meow"
  d2: "dogs bark loud"

Vocab: cats, dogs, meow, bark, loud
Matrix (rows=docs, cols=vocab):
  d1 -> [1, 0, 1, 0, 0]
  d2 -> [0, 1, 0, 1, 1]
```

## Implementation Guide

- Normalize text (case, punctuation, simple tokenization)
- Use stopword removal only if measured to help your task
- Track vocabulary size; consider top-k features by frequency/MI

## Common Pitfalls

- Aggressive stopword removal that drops task-relevant tokens
- Vocabulary mismatch between train/test
- Ignoring class-imbalance effects on term counts

## Next Steps

- Apply TF-IDF weighting to reduce the influence of ubiquitous terms
- Explore n-grams for limited order sensitivity

## Related Topics

- One-hot: 01_One-Hot-Encoding.md
- TF-IDF: 03_TF-IDF.md
- Embeddings: 04_Word2Vec-and-Embeddings.md
- Knowledge Base evidence: ../../../../01_LeadArchitectKnowledgeBase/AI-NLP/2025-08-12_Bag-of-Words/README.md
