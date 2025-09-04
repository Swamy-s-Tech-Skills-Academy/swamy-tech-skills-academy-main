# 02_Tokenization-Basics

Learning Level: Beginner  
Prerequisites: Basic Python strings  
Estimated Time: 10 minutes

## 🎯 Learning Objectives

- Explain what tokens are and why tokenization matters
- List common tokenization steps (lowercasing, punctuation stripping, splitting)
- Inspect tokens for a short sentence

## Conceptual Foundation

Tokenization splits text into smaller units (tokens). A simple baseline:

- Lowercase
- Remove punctuation/non-letters
- Collapse whitespace
- Split on spaces

## Code policy (single source of truth)

- Runnable code lives in the external canonical repo. This page shows reference-only pseudocode to explain the idea.
- If you need runnable examples, use the repo linked below. If no repo exists for this topic, ask for code and we’ll generate it externally.

## Reference pseudocode (non-runnable)

```text
function clean_tokenize(text):
    1) lowercase text
    2) replace all non-letters with a space
    3) collapse multiple spaces to one and trim ends
    4) split on space to get tokens
    5) return tokens
```

## Next Steps

- One-hot encoding (see 01_One-Hot-Encoding.md)
- Bag-of-Words (02_Bag-of-Words.md)
- TF-IDF (03_TF-IDF.md)

## Canonical code location

- External repo (single source of truth for runnable code):
  - GitHub: [Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)
