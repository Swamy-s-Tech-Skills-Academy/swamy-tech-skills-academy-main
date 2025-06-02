# Attention Mechanisms

Attention mechanisms allow models to dynamically focus on different parts of an input sequence when computing an output, by assigning weights (attention scores) to each element based on relevance.

## 1. Scaled Dot-Product Attention
Given query (q), key (k), and value (v) matrices, attention is computed as:

```
Attention(Q, K, V) = softmax( (Q K^T) / sqrt(d_k) ) V
```

where d_k is the key dimension.

## 2. Multi-Head Attention
- Splits Q, K, V into multiple heads to capture diverse subspace relationships.
- Concatenates and projects head outputs for richer representations.

## 3. Types of Attention
- **Self-Attention:** Each element attends to all elements within the same sequence.
- **Encoder–Decoder Attention:** Decoder tokens attend to encoder outputs to integrate source information.
- **Cross-Attention:** Generalization where attention is computed between different modalities or sequences.

## 4. Role in Transformer Architectures
- Enables modeling of long-range dependencies without recurrence.
- Facilitates parallel computation over entire sequences.

## 5. Applications
- Machine translation, text summarization, question answering.
- Vision Transformers: apply attention to image patches.
- Multimodal fusion (e.g., VideoBERT cross-modal attention).

## 6. Variants and Optimizations
- **Relative Positional Encoding:** Incorporates position information dynamically.
- **Sparse / Linear Approximations:** Reduce quadratic complexity for long sequences (e.g., Longformer, Performer).
