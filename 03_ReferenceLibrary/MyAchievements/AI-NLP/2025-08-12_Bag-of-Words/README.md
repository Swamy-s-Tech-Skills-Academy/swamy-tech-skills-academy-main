# Bag-of-Words — Evidence (2025-08-12)

Purpose: Capture outcome and pointers for a simple Bag-of-Words implementation and usage.

## Implementation

- Code: use external canonical repo (link below)
- Input: tokenized sentence(s)
- Output: BoW vector per sentence and vocabulary

## Quick Usage

```powershell
# Run canonical example from GitHub clone (PowerShell)
# (clone repo if needed)
# git clone https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning
Set-Location .\llm-agents-learning
# Example script name is illustrative; use the actual script/notebook in the repo
python .\bag_of_words.py "i like pizza i like"
```

Expected (illustrative):

```text
vocab: ['i', 'like', 'pizza']
vector: [2, 2, 1]
```

## Notes

- Order is ignored; counts per vocabulary item
- Use TF-IDF next to weight rare vs frequent terms

## Related

- Reference: `03_ReferenceLibrary/02_AI-and-ML/04_NaturalLanguageProcessing/01_Basics/02_Bag-of-Words.md`
- Canonical code (external): [llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)
