# 🎯 Prompt Engineering Quick Reference

## 🚀 Essential Patterns

### **Zero-Shot**

```text
Summarize this article: [content]
```

### **Few-Shot**

```text
Examples:
Q: What is 2+2? A: 4
Q: What is 3+3? A: 6
Q: What is 5+5? A: ?
```

### **Chain-of-Thought**

```text
Let me think step by step:
1. First, I'll analyze...
2. Then, I'll consider...
3. Finally, I'll conclude...
```

### **Role-Based**

```text
You are a senior data scientist with 10 years of experience.
Analyze this dataset and provide insights...
```

---

## 🎭 Effective Roles

| Role                  | Use Case            | Example                          |
| --------------------- | ------------------- | -------------------------------- |
| **Expert Consultant** | Technical analysis  | "As a cloud architect..."        |
| **Teacher**           | Explanations        | "Explain like I'm a beginner..." |
| **Critic**            | Reviews             | "Critically evaluate this..."    |
| **Assistant**         | Task completion     | "Help me create a..."            |
| **Analyst**           | Data interpretation | "From a business perspective..." |

---

## 📝 Template Structure

```text
[CONTEXT]
You are a [ROLE] with expertise in [DOMAIN].

[TASK]
Your task is to [ACTION] based on the following [INPUT_TYPE]:

[INPUT]
[User input here]

[CONSTRAINTS]
- Format: [Specify format]
- Length: [Specify length]
- Style: [Specify tone/style]
- Focus: [Key areas to emphasize]

[OUTPUT FORMAT]
Please structure your response as:
1. [Section 1]
2. [Section 2]
3. [Section 3]
```

---

## 🔧 Common Fixes

### **Problem: Generic responses**

❌ **Bad**: "Write a summary"
✅ **Good**: "Write a 3-sentence executive summary focusing on financial impact and next steps"

### **Problem: Inconsistent format**

❌ **Bad**: "Analyze this data"
✅ **Good**: "Analyze this data and respond in JSON format with 'insights', 'recommendations', and 'confidence_score' fields"

### **Problem: Missing context**

❌ **Bad**: "Is this good?"
✅ **Good**: "As a security expert, evaluate this authentication mechanism for a banking application"

### **Problem: Vague instructions**

❌ **Bad**: "Make it better"
✅ **Good**: "Improve code readability by adding comments, using descriptive variable names, and following PEP 8 style guidelines"

---

## 🎯 Format Specifiers

### **JSON Output**

```text
Respond in valid JSON format:
{
  "summary": "brief overview",
  "details": ["item1", "item2"],
  "confidence": 0.85
}
```

### **Markdown Format**

```text
Format your response in markdown with:
- ## Main heading
- ### Subheadings
- **Bold** for emphasis
- `code` for technical terms
- Numbered lists for steps
```

### **Table Format**

```text
Present findings in a table:
| Metric | Value | Status |
|--------|-------|--------|
| [data] | [data]| [data] |
```

---

## 🛡️ Safety Guidelines

### **Input Validation**

- Sanitize user inputs
- Check for injection attempts
- Validate content appropriateness
- Implement rate limiting

### **Output Filtering**

- Remove sensitive information
- Check for harmful content
- Validate against policies
- Apply content moderation

### **Monitoring**

- Track usage patterns
- Monitor for abuse
- Log all interactions
- Set up alerts

---

## 💡 Optimization Tips

### **Token Efficiency**

- Remove redundant words
- Use concise language
- Combine similar examples
- Optimize prompt structure

### **Performance**

- Cache common patterns
- Batch similar requests
- Use appropriate models
- Monitor response times

### **Cost Management**

- Set token budgets
- Monitor usage patterns
- Optimize model selection
- Implement usage controls

---

## 🧪 Testing Checklist

- [ ] **Accuracy**: Outputs match expectations
- [ ] **Consistency**: Similar inputs produce similar outputs
- [ ] **Format**: Response follows specified structure
- [ ] **Safety**: No harmful or inappropriate content
- [ ] **Performance**: Response time within limits
- [ ] **Cost**: Token usage within budget

---

## 📊 Success Metrics

### **Quality Metrics**

- Response relevance (1-10)
- Format compliance (%)
- User satisfaction (1-5)
- Task completion rate (%)

### **Performance Metrics**

- Average response time (seconds)
- Token usage per request
- Cache hit rate (%)
- Error rate (%)

### **Business Metrics**

- Cost per interaction ($)
- User engagement (sessions)
- Productivity improvement (%)
- ROI on AI investment (%)

---

## 🚨 Common Pitfalls

### **Ambiguous Instructions**

❌ "Analyze this"
✅ "Perform sentiment analysis on this customer feedback and categorize as positive/negative/neutral"

### **Missing Examples**

❌ "Format the output properly"
✅ "Format like this example: {'name': 'John', 'age': 30}"

### **Overloading Context**

❌ Including 10 pages of background
✅ Provide only relevant context (< 1 page)

### **Ignoring Edge Cases**

❌ Only testing happy path
✅ Test with edge cases, errors, empty inputs

---

## 🔄 Iteration Process

1. **Start Simple**: Basic prompt with core requirements
2. **Test**: Run with sample inputs
3. **Identify Issues**: Note problems and gaps
4. **Refine**: Add constraints, examples, format specifiers
5. **Validate**: Test with diverse inputs
6. **Deploy**: Release with monitoring
7. **Monitor**: Track performance and feedback
8. **Improve**: Iterate based on data

---

## 🛠️ Tools & Resources

### **Development**

- [OpenAI Playground](https://platform.openai.com/playground)
- [Anthropic Console](https://console.anthropic.com/)
- [Azure AI Studio](https://ai.azure.com/)

### **Testing**

- [PromptBench](https://github.com/microsoft/promptbench)
- [OpenAI Evals](https://github.com/openai/evals)
- [LangChain](https://langchain.readthedocs.io/)

### **Monitoring**

- [Weights & Biases](https://wandb.ai/)
- [MLflow](https://mlflow.org/)
- [PromptLayer](https://promptlayer.com/)

---

## 📱 Mobile-First Prompting

### **Concise Prompts**

Design for limited screen space and attention spans.

### **Clear CTAs**

Make next steps obvious and actionable.

### **Progressive Disclosure**

Start simple, allow drilling down for details.

---

_Quick reference for effective prompt engineering. Keep this handy for daily AI interactions._
