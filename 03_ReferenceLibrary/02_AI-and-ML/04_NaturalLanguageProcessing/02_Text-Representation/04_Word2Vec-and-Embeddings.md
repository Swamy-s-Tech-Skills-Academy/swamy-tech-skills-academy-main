# 04_Word2Vec-and-Embeddings

Learning Level: Intermediate  
Prerequisites: BoW/TF-IDF, vector math basics  
Estimated Time: 30–40 minutes

## Learning Objectives

- Contrast count-based features with distributional embeddings
- Explain CBOW vs. Skip-gram training objectives
- Use pre-trained embeddings and interpret cosine similarity

## Conceptual Foundation

Embeddings map tokens into dense vectors so semantic relationships emerge via geometry (e.g., analogy structure). Word2Vec popularized training via shallow neural networks predicting context from a target word (Skip-gram) or the target from its context (CBOW).

## Practical Examples

```text
Similarity:
  cos(u, v) = (u · v) / (||u|| * ||v||)

Nearest neighbors reveal topical clusters and related terms.
```

## Implementation Guide

- Prefer pre-trained vectors for small datasets; fine-tune if data allows
- Normalize vectors; use cosine similarity for retrieval
- Handle OOV via subword models (fastText) or fallback strategies

## Common Pitfalls

- Mismatched tokenization between training and inference
- Ignoring domain shift; generic embeddings may underperform in niche domains
- Overinterpreting analogies; treat them as signals, not guarantees

## Next Steps

- Sentence/document embeddings for classification and search
- Transformer-based embeddings (e.g., from LLMs) for richer semantics

## Related Topics

- One-hot: 01_One-Hot-Encoding.md
- BoW: 02_Bag-of-Words.md
- TF-IDF: 03_TF-IDF.md
- LLMs foundation: ../../05_LargeLanguageModels/01_LLM-Fundamentals.md
