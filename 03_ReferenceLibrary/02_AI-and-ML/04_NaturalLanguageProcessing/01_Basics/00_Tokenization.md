# 00_Tokenization

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

## Minimal Example (Python)

```python
import re

def clean_tokenize(text: str) -> list[str]:
    text = text.lower()
    text = re.sub(r"[^a-z]+", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text.split()

print(clean_tokenize("Should we go to a pizzeria or do you prefer a restaurant?"))
```

## Next Steps

- One-hot encoding (see 01_One-Hot-Encoding.md)
- Bag-of-Words (02_Bag-of-Words.md)
- TF-IDF (03_TF-IDF.md)
