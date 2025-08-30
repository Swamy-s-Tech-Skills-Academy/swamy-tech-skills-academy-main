# 03_Bag-of-Words

Learning Level: Beginner  
Prerequisites: Tokenization  
Estimated Time: 10–15 minutes

## 🎯 Learning Objectives

- Describe Bag-of-Words (BoW) vs One-Hot
- Build a simple BoW vector for a sentence
- Note limitations and when to move to TF-IDF

## Conceptual Foundation

BoW counts token occurrences per vocabulary item. Order is ignored.

- Vector length = vocabulary size
- Value = token frequency (per sentence or document)

## Code policy (single source of truth)

- Runnable code lives in the external canonical repo. This page shows reference-only pseudocode to explain the idea.
- If you need runnable examples, use the repo linked below. If no repo exists for this topic, ask for code and we’ll generate it externally.

## Toy Corpus Example

Sentences (lowercased and tokenized):

1) "this movie is awesome awesome"  
2) "i do not say is good, but neither awesome"  
3) "awesome only a fool can say that"

How to read it:

- Each row is a sentence; each column is a word in the vocabulary. Values are counts.
- Row 1 shows 2 for "awesome"; absent words have 0.
- Order is ignored: "movie awesome" equals "awesome movie".

## Reference pseudocode (non-runnable)

```text
function bag_of_words(tokens):
  vocab := sorted(unique(tokens))
  counts := frequency_map(tokens)
  vector := []
  for each word w in vocab:
    append counts[w] or 0 to vector
  return vector, vocab
```

## Next Steps

- TF-IDF to weight rare vs frequent terms (see 03_TF-IDF.md)
- Move to distributed embeddings for semantics (word2vec, GloVe)

## Canonical Code Location

- External repo (single source of truth for runnable code):
  - GitHub: [Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)
