# 03_TF-IDF

Learning Level: Beginner  
Prerequisites: Tokenization, Bag-of-Words  
Estimated Time: 15–20 minutes

## 🎯 Learning Objectives

- Explain TF, IDF, and TF×IDF at a high level
- Interpret a small TF-IDF matrix
- Compute a tiny TF-IDF by hand for intuition

## Conceptual Foundation

- TF (term frequency): within a document, counts normalized by document length
- IDF (inverse document frequency): down-weights terms common across many documents
- TF-IDF = TF × IDF: highlights terms that are frequent in a document but rare overall

## Tiny Example (3 sentences)

1) "this movie is awesome awesome"  
2) "i do not say is good, but neither awesome"  
3) "awesome only a fool can say that"

Intuition:

- "awesome" appears in all 3 → IDF lower than a rare word
- A repeated word in one sentence can still rank high if it’s not ubiquitous

## Minimal Computation Sketch

- Compute TF per sentence: count(word)/len(sentence)
- Compute IDF with smoothing (sklearn-style): log((1+N)/(1+df)) + 1
- Multiply TF by IDF per term to get TF-IDF matrix

## Code (reference-only, see repo for runnable)

```python
import numpy as np


def compute_tf(sentences):
    tokenized = [clean_tokenize(s) for s in sentences]
    vocabulary = sorted(set(w for sent in tokenized for w in sent))
    word_index = {w: i for i, w in enumerate(vocabulary)}
    tf = np.zeros((len(sentences), len(vocabulary)), dtype=np.float32)
    for i, words in enumerate(tokenized):
        denom = len(words) or 1
        for w in words:
            tf[i, word_index[w]] += 1.0 / denom
    return tf, vocabulary


def compute_idf(sentences, vocabulary):
    tokenized = [set(clean_tokenize(s)) for s in sentences]
    N = len(sentences)
    word_index = {w: i for i, w in enumerate(vocabulary)}
    idf = np.zeros(len(vocabulary), dtype=np.float32)
    for w in vocabulary:
        df = sum(1 for s in tokenized if w in s)
        idf[word_index[w]] = np.log((1 + N) / (1 + df)) + 1.0
    return idf


def tf_idf(sentences):
    tf, vocab = compute_tf(sentences)
    idf = compute_idf(sentences, vocab)
    return vocab, tf * idf
```

## Canonical Code Location

- External repo (single source of truth for runnable code):
  - GitHub: [Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)

## 🔗 Related Topics

- Prerequisites: `00_Tokenization.md`
- Related: `02_Bag-of-Words.md`
- Next: distributed embeddings (word2vec, GloVe)
