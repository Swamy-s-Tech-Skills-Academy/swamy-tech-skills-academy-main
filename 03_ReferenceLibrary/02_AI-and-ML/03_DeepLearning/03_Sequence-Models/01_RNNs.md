# 01_RNNs

Learning Level: Intermediate  
Prerequisites: Basics of gradients/optimization  
Estimated Time: 30–40 minutes

## Learning Objectives

- Describe recurrent computation over sequences
- Understand vanishing/exploding gradients at a high level
- Know typical use cases before transformers became dominant

## Conceptual Foundation

RNNs process inputs step-by-step, carrying a hidden state. They model temporal dependencies, but struggle with long-range context without gating or attention.

## Related Topics

- 02_LSTM.md — gated memory to mitigate gradient issues
- 03_GRU.md — a lighter gated alternative
