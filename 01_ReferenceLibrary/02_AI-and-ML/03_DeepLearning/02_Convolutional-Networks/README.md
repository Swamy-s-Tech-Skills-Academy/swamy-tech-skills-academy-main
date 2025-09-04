# 02_Convolutional-Networks

Learning Level: Intermediate  
Prerequisites: Basic NN concepts (layers, activations), matrix ops  
Estimated Time: 40–60 minutes

## Learning Objectives

- Explain convolution, stride, padding, and receptive fields
- Understand why CNNs excel on grid-structured data (images)
- Outline a minimal image classification pipeline

## Conceptual Foundation

Convolutions learn local patterns that compose into higher-level features. Parameter sharing and locality reduce overfitting and compute relative to fully-connected layers on images.

## Practical Examples

```text
Minimal image classifier:
  Input -> Conv -> ReLU -> Pool -> Conv -> ReLU -> Pool -> FC -> Softmax
```

## Implementation Guide

- Normalize inputs; use data augmentation to generalize
- Start with small kernels (3x3) and deeper stacks
- Prefer modern activations/normalization when available

## Common Pitfalls

- Overly large kernels without enough data
- Forgetting to monitor validation accuracy vs. training (overfit)
- Ignoring class imbalance in real-world datasets

## Related Topics

- Sequence models: ../03_Sequence-Models/
- Transformers: ../01_Transformer-Architecture.md
