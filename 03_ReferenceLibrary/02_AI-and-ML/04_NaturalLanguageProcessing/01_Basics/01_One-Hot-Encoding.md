# 01_One-Hot-Encoding

Learning Level: Beginner  
Prerequisites: Basic Python lists, concept of tokens/words  
Estimated Time: 10–15 minutes

## 🎯 Learning Objectives

- Explain what one-hot encoding is and when to use it
- Describe the relationship between tokens, rows, and vocabulary columns
- Create a small one-hot matrix for a toy sentence

## Conceptual Foundation

One-hot encoding represents each token (word) by a vector where exactly one element is 1 and the rest are 0.

- Rows correspond to token positions in the sentence (sequence order preserved)
- Columns correspond to the unique vocabulary for that sentence or corpus
- It captures presence/position but not similarity or meaning

## Code policy (single source of truth)

- Runnable code lives in the external canonical repo. This page shows reference-only pseudocode to explain the idea.
- If you need runnable examples, use the repo linked below. If no repo exists for this topic, ask for code and we’ll generate it externally.

## Practical Example

Sentence: "I like pizza"

Vocabulary (sorted, lowercase): ["i", "like", "pizza"]

Matrix (rows = tokens in order, columns = vocabulary):

| Token | i | like | pizza |
|-------|---|------|-------|
| i     | 1 | 0    | 0     |
| like  | 0 | 1    | 0     |
| pizza | 0 | 0    | 1     |

## Reference pseudocode (non-runnable)

```text
function one_hot(tokens):
    vocab := sorted(unique(tokens))
    index := { word -> position } from vocab order
    matrix := []
    for each token t in tokens:
        row := zeros(length(vocab))
        row[index[t]] := 1
        append row to matrix
    return matrix, vocab, index
```

## Common Pitfalls

- Large vocabulary → huge sparse matrices (memory-inefficient)
- No semantics: "pizza" and "pasta" are orthogonal (0 similarity)
- OOV words (not in the vocabulary) need a strategy (e.g., [UNK])

## Next Steps

- Bag-of-Words and term frequency (TF)
- TF-IDF to weight importance
- Distributed representations (word2vec, GloVe, fastText)

## Canonical Code Location

- External repo (single source of truth for runnable code):
  - GitHub: [Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)

## 🔗 Related Topics

- Prerequisites: `../01_Basics/00_Tokenization.md` (create if missing)
- Related: `../01_Basics/02_Bag-of-Words.md` (create if missing)
- Advanced: `../../05_LargeLanguageModels/01_LLM-Fundamentals.md`
