# 03_TF-IDF

Learning Level: Beginner  
Prerequisites: BoW counts, log/exponent basics  
Estimated Time: 25–30 minutes

## Learning Objectives

- Define term frequency (TF), document frequency (DF), and inverse DF (IDF)
- Compute TF-IDF and understand why it down-weights ubiquitous words
- Choose normalization strategies for robust features

## Conceptual Foundation

TF-IDF rescales raw counts so that terms frequent in one document but rare across the corpus receive more weight. This often improves linear models for classification and retrieval.

## Practical Examples

```text
TF: term count (optionally normalized by document length)
DF: number of documents containing the term
IDF: log((N + 1) / (DF + 1)) + 1  # smoothed

TF-IDF(term, doc) = TF(term, doc) * IDF(term)
```

## Implementation Guide

- Use smoothing for IDF to avoid division by zero
- Normalize each document vector (L2) to compare across lengths
- Persist the fitted IDF parameters with the vocabulary for reproducibility

## Common Pitfalls

- Fitting IDF on test data (data leakage)
- Comparing unnormalized TF-IDF vectors of different lengths
- Treating TF-IDF as semantic — it’s still based on counts

## Next Steps

- Move to embeddings for semantic similarity (word2vec/fastText)
- Consider transformer embeddings for downstream tasks

## Related Topics

- BoW: 02_Bag-of-Words.md
- Embeddings: 04_Word2Vec-and-Embeddings.md
- Knowledge Base evidence: ../../../../01_LeadArchitectKnowledgeBase/AI-NLP/2025-08-13_TF-IDF/README.md
