# 04_Training-and-Fine-Tuning

Learning Level: Intermediate  
Prerequisites: 03_Transformer-Deep-Dive, Python basics, GPU basics  
Estimated Time: 90–120 minutes

## 🎯 Learning Objectives

By the end of this module, you will:

- Outline pretraining vs. fine-tuning vs. instruction-tuning vs. RLHF
- Choose datasets, tokenizers, and loss objectives appropriately
- Understand optimizer choices (AdamW), schedulers, and mixed precision
- Know when to use LoRA/QLoRA and parameter-efficient fine-tuning

## 📋 Content Sections

### Conceptual Foundation

- Pretraining objectives (causal LM) and data curation
- Supervised fine-tuning and preference optimization
- Safety alignment and evaluation

### Practical Examples

- Minimal fine-tune with parameter-efficient adapters (outline)
- Data pipeline: tokenize, batch, pad, mask

### Implementation Guide

- Training loop components and checkpoints
- Evaluations (perplexity vs. task metrics) and overfitting checks

### Common Pitfalls

- Overfitting small datasets; data leakage
- Forgetting to freeze base layers in PEFT; instability without warmup

### Next Steps

- Proceed to 05_Prompt-Engineering

## 🔗 Related Topics

- Prerequisites: 03_Transformer-Deep-Dive
- Related: 06_LLM-Limitations-and-Challenges
- Advanced: 07_LLM-to-Agent-Bridge
