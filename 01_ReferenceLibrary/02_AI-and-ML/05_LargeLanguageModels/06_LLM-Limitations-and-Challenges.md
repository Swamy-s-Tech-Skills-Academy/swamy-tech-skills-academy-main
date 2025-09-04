# 06_LLM-Limitations-and-Challenges

Learning Level: Intermediate  
Prerequisites: 05_Prompt-Engineering  
Estimated Time: 45–60 minutes

## 🎯 Learning Objectives

By the end of this module, you will:

- Identify common LLM failure modes and their root causes
- Design mitigations: retrieval, constraining, self-critique, evals
- Understand cost/latency trade-offs and caching strategies
- Know when to switch to agents, tools, or classical ML

## 📋 Content Sections

### Conceptual Foundation

- Hallucination vs. uncertainty; calibration basics
- Context window limits; long-context degradation
- Data freshness and retrieval augmentation

### Practical Examples

- Adding a critique step; JSON schema verification
- Retrieval-augmented prompting (outline)

### Implementation Guide

- Caching policies and idempotency
- Small, targeted evals; offline replay logs

### Common Pitfalls

- Over-reliance on prompt magic; ignoring deterministic baselines
- No guardrails on cost/time; missing stop conditions

### Next Steps

- Proceed to 07_LLM-to-Agent-Bridge

## 🔗 Related Topics

- Prerequisites: 05_Prompt-Engineering
- Related: 06_MCP-Servers (tools), 07_AI-Agents
- Advanced: Agentic AI risk management
