# 05_Prompt-Engineering

Learning Level: Intermediate  
Prerequisites: 01_LLM-Fundamentals, basic JSON familiarity  
Estimated Time: 60–90 minutes

## 🎯 Learning Objectives

By the end of this module, you will:

- Write clear system prompts and role/task constraints
- Produce structured outputs (JSON/CSV) reliably with format guards
- Apply few-shot and chain-of-thought variants responsibly
- Build small eval sets and rubrics to measure prompt changes

## 📋 Content Sections

### Conceptual Foundation

- Task decomposition and instruction templates
- Style control, safety constraints, and refusal boundaries

### Practical Examples

- JSON schema prompting; retry-on-parse-fail strategy
- Few-shot vs. zero-shot tradeoffs in small tasks

### Implementation Guide

- Guarded generation with lightweight validators
- Prompt versioning, caching, and offline evals

### Common Pitfalls

- Overfitting prompts to evals; hidden state changes
- Leaking secrets or PII in examples

### Next Steps

- Proceed to 06_LLM-Limitations-and-Challenges

## 🔗 Related Topics

- Prerequisites: 01_LLM-Fundamentals
- Related: 07_LLM-to-Agent-Bridge
- Advanced: 06_MCP-Servers (for tool-augmented prompting)
