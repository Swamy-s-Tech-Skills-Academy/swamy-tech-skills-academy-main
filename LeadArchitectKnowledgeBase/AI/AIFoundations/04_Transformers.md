# Transformers

Transformers are a class of neural network architectures introduced by Vaswani et al. (2017) that rely entirely on attention mechanisms to process sequential data, eliminating recurrent or convolutional layers.

## 1. Core Components

- **Self-Attention:** Computes pairwise interactions between all positions in the input sequence:
  \[\text{Attention}(Q,K,V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V\]
  - **Q, K, V:** Query, Key, and Value matrices derived from input embeddings.
  - **Scaled Dot-Product:** Stabilizes gradients by dividing by \(\sqrt{d_k}\).

- **Multi-Head Attention:** Runs multiple attention operations in parallel to capture different subspace relationships, then concatenates and projects the results.

- **Position-wise Feed-Forward Network:** Two linear transformations with a non-linearity in between, applied to each position independently.

- **Positional Encoding:** Adds sequence order information to input embeddings (e.g., sinusoidal functions).

- **Layer Normalization & Residual Connections:** Improve training stability and gradient flow.

## 2. Encoder and Decoder Stacks

- **Encoder:** Composed of N identical layers, each containing:
  1. Multi-Head Self-Attention (with input mask optionally)
  2. Feed-Forward Network
  3. Add & Norm after each sub-layer

- **Decoder:** Composed of N identical layers, each containing:
  1. Masked Multi-Head Self-Attention (to prevent attending to future tokens)
  2. Encoder–Decoder Attention (attends to encoder outputs)
  3. Feed-Forward Network
  4. Add & Norm after each sub-layer

## 3. Variants

- **Encoder-Only:** BERT, RoBERTa, ELECTRA — suited for classification and embedding tasks.
- **Decoder-Only:** GPT series, Transformer-XL — optimized for autoregressive language modeling.
- **Encoder–Decoder (Seq2Seq):** T5, BART — effective for translation, summarization, and text generation.

## 4. Applications

- **Machine Translation:** Replaced RNN-based models in neural machine translation.
- **Text Summarization & Generation:** BART and T5 excel at abstractive summarization and question answering.
- **Language Understanding:** BERT-like models power many NLP benchmarks (GLUE, SQuAD).
- **Vision Transformers (ViT):** Apply transformer blocks to image patches for computer vision tasks.

## 5. Advantages and Considerations

- **Parallelism:** Full sequence attention enables efficient training on GPUs/TPUs.
- **Long-Range Dependencies:** Self-attention captures distant relationships better than RNNs.
- **Computational Cost:** Quadratic complexity with sequence length limits very long sequences (mitigation: sparse or linear approximations).

## References

- Vaswani, A., Shazeer, N., Parmar, N., et al. (2017). Attention Is All You Need. _NeurIPS_.
