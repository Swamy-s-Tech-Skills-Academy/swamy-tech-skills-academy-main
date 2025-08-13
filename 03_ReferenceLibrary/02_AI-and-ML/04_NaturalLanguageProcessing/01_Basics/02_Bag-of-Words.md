# 02_Bag-of-Words

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

## Toy Corpus Example

Sentences (lowercased and tokenized):

1) "this movie is awesome awesome"  
2) "i do not say is good, but neither awesome"  
3) "awesome only a fool can say that"

How to read it:

- Each row is a sentence; each column is a word in the vocabulary. Values are counts.
- Row 1 shows 2 for "awesome"; absent words have 0.
- Order is ignored: "movie awesome" equals "awesome movie".

## Minimal Example (Python)

```python
from collections import Counter

def bag_of_words(tokens: list[str]):
    vocab = sorted(set(tokens))
    counts = Counter(tokens)
    vec = [counts.get(w, 0) for w in vocab]
    return vec, vocab

print(bag_of_words("i like pizza i like".split()))
```

## Next Steps

- TF-IDF to weight rare vs frequent terms (see 03_TF-IDF.md)
- Move to distributed embeddings for semantics (word2vec, GloVe)

## Canonical Code Location

- External repo (single source of truth for runnable code):
  - GitHub: [Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)
