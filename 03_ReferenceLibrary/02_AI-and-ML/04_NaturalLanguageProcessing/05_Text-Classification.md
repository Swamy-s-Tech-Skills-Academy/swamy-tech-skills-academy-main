# 03_Text-Classification

Learning Level: Beginner → Intermediate  
Prerequisites: Text representation (one-hot/BoW/TF-IDF/embeddings)  
Estimated Time: 35–45 minutes

## Learning Objectives

- Describe the end-to-end classical NLP classification pipeline
- Choose a representation (counts vs. embeddings) for the task
- Evaluate with appropriate metrics (macro/micro F1, ROC-AUC)

## Conceptual Foundation

Typical pipeline:

1. Preprocess text (tokenize/normalize)
2. Represent (TF-IDF or embeddings)
3. Train a classifier (LogReg, Linear SVM, NB)
4. Evaluate on a held-out set; tune with cross-validation

## Practical Examples

```text
Binary sentiment:
  Features: TF-IDF (unigram + bigram)
  Model:    Linear SVM
  Metric:   Macro F1 when classes are imbalanced
```

## Implementation Guide

- Start with TF-IDF + linear models as a strong baseline
- Use class weighting or stratified sampling for imbalance
- Track reproducibility: random seeds, fixed vocab/IDF

## Common Pitfalls

- Data leakage (fitting vectorizer on the test set)
- Overfitting with high-order n-grams and small data
- Using accuracy alone when classes are skewed

## Next Steps

- Replace features with contextual embeddings (transformers)
- Explore simple fine-tuning of a small transformer for improved accuracy

## Related Topics

- Text representation: 02_Text-Representation/*
- LLMs: ../../05_LargeLanguageModels/
