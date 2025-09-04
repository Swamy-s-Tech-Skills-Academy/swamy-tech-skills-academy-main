# One-Hot Encoding — Demonstration (2025-08-11)

Purpose: Show a simple, working implementation of one-hot encoding for a short sentence.

## Implementation

- Code: see external repo script (link below)
- Input: a tokenized sentence (list of lowercase words)
- Output: one-hot matrix, vocabulary, and index mapping

## Quick Usage

```powershell
# Run canonical example from GitHub clone (PowerShell)
# (clone repo if needed)
# git clone https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning
Set-Location .\llm-agents-learning
python .\one_hot.py "i like pizza"
```

Expected (example):

```text
vocab: ['i', 'like', 'pizza']
index: {'i': 0, 'like': 1, 'pizza': 2}
matrix:
[1, 0, 0]
[0, 1, 0]
[0, 0, 1]
```

## Notes

- Rows correspond to token order; columns to sorted unique vocabulary
- Presence only; no meaning or similarity encoded

## Related

- Reference: `03_ReferenceLibrary/02_AI-and-ML/04_NaturalLanguageProcessing/01_Basics/01_One-Hot-Encoding.md`
- Canonical code (external): [llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)
