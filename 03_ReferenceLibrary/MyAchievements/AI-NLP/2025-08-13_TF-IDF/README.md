# TF-IDF — Evidence (2025-08-13)

Purpose: Capture outcome and pointers for a tiny TF-IDF computation and interpretation.

## Implementation

- Code: use external canonical repo (link below)
- Input: short list of sentences
- Output: vocabulary and TF-IDF matrix

## Quick Usage

```powershell
# Run canonical example from GitHub clone (PowerShell)
# (clone repo if needed)
# git clone https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning
Set-Location .\llm-agents-learning
# Example script name is illustrative; use the actual script/notebook in the repo
python .\tfidf_demo.py
```

Expected (illustrative):

```text
vocab: [...]
TF-IDF matrix: (m x n) with higher weights for terms frequent in a doc but rare overall
```

## Notes

- TF = term freq within a doc; IDF down-weights ubiquitous terms
- Prefer smoothing: idf = log((1+N)/(1+df)) + 1

## Related

- Reference: `03_ReferenceLibrary/02_AI-and-ML/04_NaturalLanguageProcessing/01_Basics/03_TF-IDF.md`
- Canonical code (external): [llm-agents-learning](https://github.com/Swamy-s-Tech-Skills-Academy-AI-ML-Data/llm-agents-learning)
