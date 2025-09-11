# LLM Explainability Implementation - Part B: Prompt Tracing & Attention Visualization

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Part A (Explainability Fundamentals), Python programming  
**Estimated Time**: 27 minutes  
**Part**: B of 3-part series on LLM Explainability

---

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- **Implement prompt tracing** for debugging AI decisions
- **Understand attention visualization** concepts and applications
- **Debug real-world AI problems** using explainability techniques
- **Build production-ready logging** for AI transparency

---

## 🔍 Prompt Tracing Implementation

### **What is Prompt Tracing?**

Prompt tracing creates a complete audit trail of AI interactions by capturing:

- **Input prompts** sent to the model
- **Template variables** and their actual values
- **System messages** and conversation context
- **Output responses** and their metadata
- **Timestamp and model information**

```text
Example Prompt Trace Record:
┌─────────────────────────────────────────────┐
│ Timestamp: 2025-01-15 14:32:17 UTC         │
│ Model: gpt-4o-mini                          │
│ Request ID: req_abc123                      │
├─────────────────────────────────────────────┤
│ SYSTEM PROMPT:                              │
│ You are SpendBot, an autonomous purchasing  │
│ assistant. Current budget: ${budget}        │
│ Risk tolerance: ${risk_level}               │
├─────────────────────────────────────────────┤
│ USER INPUT:                                 │
│ Order office supplies for next month        │
├─────────────────────────────────────────────┤
│ TEMPLATE VARIABLES:                         │
│ budget = 5000                               │
│ risk_level = "conservative"                 │
├─────────────────────────────────────────────┤
│ AI RESPONSE:                                │
│ I'll place an order for standard supplies   │
│ within our $5000 budget...                  │
└─────────────────────────────────────────────┘
```

### **Basic Prompt Tracing Implementation**

```python
import json
from datetime import datetime
from typing import Dict, Any, List
import logging

class PromptTracer:
    def __init__(self, log_file: str = "prompt_trace.log"):
        """Initialize prompt tracer with file logging."""
        self.logger = logging.getLogger("prompt_tracer")
        handler = logging.FileHandler(log_file)
        handler.setFormatter(logging.Formatter(
            '%(asctime)s - %(levelname)s - %(message)s'
        ))
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.INFO)
    
    def trace_request(self, 
                     prompt: str,
                     response: str,
                     model: str = "unknown",
                     template_vars: Dict[str, Any] = None,
                     request_id: str = None) -> Dict[str, Any]:
        """
        Log a complete prompt trace for later analysis.
        
        Args:
            prompt: The input prompt sent to the model
            response: The model's response
            model: Model identifier
            template_vars: Variables used in prompt templating
            request_id: Unique identifier for this request
        
        Returns:
            Dictionary containing the trace record
        """
        trace_record = {
            "timestamp": datetime.utcnow().isoformat(),
            "request_id": request_id or f"req_{int(datetime.now().timestamp())}",
            "model": model,
            "prompt": prompt,
            "response": response,
            "template_variables": template_vars or {},
            "prompt_length": len(prompt),
            "response_length": len(response)
        }
        
        # Log the trace record
        self.logger.info(f"TRACE: {json.dumps(trace_record, indent=2)}")
        
        return trace_record
    
    def analyze_traces(self, search_term: str = None) -> List[Dict[str, Any]]:
        """
        Analyze logged traces for patterns or issues.
        
        Args:
            search_term: Optional term to search for in prompts/responses
        
        Returns:
            List of matching trace records
        """
        # Implementation would read log file and parse JSON records
        # This is a simplified example
        print(f"Analyzing traces for: {search_term}")
        return []
```

### **Advanced Prompt Tracing with Context**

```python
from openai import OpenAI
from typing import Optional

class AdvancedPromptTracer:
    def __init__(self, api_key: str):
        self.client = OpenAI(api_key=api_key)
        self.tracer = PromptTracer()
        self.conversation_history = []
    
    def traced_completion(self,
                         messages: List[Dict[str, str]],
                         model: str = "gpt-4o-mini",
                         trace_metadata: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Make an API call with comprehensive tracing.
        
        Args:
            messages: Conversation messages
            model: Model to use
            trace_metadata: Additional metadata for tracing
        
        Returns:
            Response with trace information
        """
        # Prepare prompt for tracing
        full_prompt = self._format_messages_for_trace(messages)
        
        # Make the API call
        try:
            response = self.client.chat.completions.create(
                model=model,
                messages=messages,
                temperature=0.7
            )
            
            response_text = response.choices[0].message.content
            
            # Create trace record
            trace_record = self.tracer.trace_request(
                prompt=full_prompt,
                response=response_text,
                model=model,
                template_vars=trace_metadata,
                request_id=response.id
            )
            
            # Update conversation history
            self.conversation_history.append({
                "messages": messages,
                "response": response_text,
                "trace_id": trace_record["request_id"]
            })
            
            return {
                "response": response_text,
                "trace_record": trace_record,
                "conversation_id": len(self.conversation_history)
            }
            
        except Exception as e:
            # Trace the error as well
            error_trace = self.tracer.trace_request(
                prompt=full_prompt,
                response=f"ERROR: {str(e)}",
                model=model,
                template_vars=trace_metadata
            )
            raise
    
    def _format_messages_for_trace(self, messages: List[Dict[str, str]]) -> str:
        """Format conversation messages for readable tracing."""
        formatted = []
        for msg in messages:
            formatted.append(f"{msg['role'].upper()}: {msg['content']}")
        return "\n".join(formatted)
```

---

## 🧠 Attention Visualization Concepts

### **Understanding Attention Mechanisms**

Attention visualization reveals which parts of the input the model considers most important when generating responses. This helps identify:

- **Bias patterns** in model focus
- **Unexpected associations** between words
- **Context utilization** effectiveness
- **Information processing priorities**

```text
Attention Visualization Example:

Input: "Schedule maintenance for the production line equipment"

Attention Weights (simplified):
┌─────────────────────────────────────────────┐
│ Token         │ Attention Weight │ Visual   │
├─────────────────────────────────────────────┤
│ "Schedule"    │ 0.42             │ ██████████▌│
│ "maintenance" │ 0.38             │ █████████▌ │
│ "for"         │ 0.04             │ ▌          │
│ "the"         │ 0.03             │ ▎          │
│ "production"  │ 0.28             │ ███████    │
│ "line"        │ 0.25             │ ██████▌    │
│ "equipment"   │ 0.35             │ ████████▌  │
└─────────────────────────────────────────────┘

Insight: Model correctly focuses on action verbs and key nouns
```

### **Implementing Attention Analysis**

```python
import numpy as np
from typing import List, Tuple

class AttentionAnalyzer:
    def __init__(self):
        """Initialize attention visualization tools."""
        self.attention_data = []
    
    def simulate_attention_weights(self, 
                                 tokens: List[str], 
                                 query_focus: str) -> List[Tuple[str, float]]:
        """
        Simulate attention weights for educational purposes.
        In production, these would come from model internals.
        
        Args:
            tokens: List of input tokens
            query_focus: What the model should focus on
        
        Returns:
            List of (token, attention_weight) tuples
        """
        # Simplified simulation based on keyword matching
        weights = []
        focus_words = query_focus.lower().split()
        
        for token in tokens:
            base_weight = 0.1  # Minimum attention
            
            # Higher attention for focus words
            if token.lower() in focus_words:
                weight = 0.4 + np.random.normal(0, 0.1)
            # Moderate attention for related words
            elif any(focus in token.lower() for focus in focus_words):
                weight = 0.25 + np.random.normal(0, 0.05)
            # Lower attention for common words
            elif token.lower() in ['the', 'a', 'an', 'to', 'of', 'for']:
                weight = 0.05 + np.random.normal(0, 0.02)
            else:
                weight = base_weight + np.random.normal(0, 0.03)
            
            # Ensure weights are positive and sum appropriately
            weight = max(0.01, min(0.6, weight))
            weights.append((token, weight))
        
        # Normalize weights to sum to 1
        total_weight = sum(w[1] for w in weights)
        normalized_weights = [(token, weight/total_weight) for token, weight in weights]
        
        return normalized_weights
    
    def visualize_attention(self, 
                          attention_weights: List[Tuple[str, float]],
                          max_bar_length: int = 20) -> str:
        """
        Create a text-based visualization of attention weights.
        
        Args:
            attention_weights: List of (token, weight) tuples
            max_bar_length: Maximum length of visualization bars
        
        Returns:
            Formatted attention visualization string
        """
        viz_lines = ["Attention Visualization:", "=" * 50]
        
        max_weight = max(weight for _, weight in attention_weights)
        
        for token, weight in attention_weights:
            # Calculate bar length
            bar_length = int((weight / max_weight) * max_bar_length)
            bar = "█" * bar_length
            
            # Format the line
            viz_lines.append(f"{token:12} │ {weight:.3f} │ {bar}")
        
        return "\n".join(viz_lines)
    
    def analyze_attention_patterns(self, 
                                 attention_weights: List[Tuple[str, float]]) -> Dict[str, Any]:
        """
        Analyze attention patterns for insights.
        
        Args:
            attention_weights: List of (token, weight) tuples
        
        Returns:
            Dictionary with analysis results
        """
        weights = [weight for _, weight in attention_weights]
        tokens = [token for token, _ in attention_weights]
        
        analysis = {
            "total_tokens": len(tokens),
            "max_attention": max(weights),
            "min_attention": min(weights),
            "avg_attention": np.mean(weights),
            "attention_std": np.std(weights),
            "most_attended_token": tokens[weights.index(max(weights))],
            "least_attended_token": tokens[weights.index(min(weights))],
            "concentration_ratio": max(weights) / np.mean(weights)
        }
        
        return analysis
```

---

## 🔧 Practical Debugging Example

### **Case Study: Manufacturing Supply Chain Bug**

Let's apply prompt tracing to debug the warehouse inventory ordering problem:

```python
class WarehouseDebugger:
    def __init__(self):
        self.tracer = AdvancedPromptTracer(api_key="your_api_key_here")
    
    def debug_inventory_ordering(self, current_stock: Dict[str, int], demand_forecast: Dict[str, int]):
        """Debug the inventory ordering logic with tracing."""
        
        # Prepare the prompt that might be causing issues
        messages = [
            {
                "role": "system",
                "content": f"""You are InventoryBot, an autonomous warehouse manager.
                Current stock levels: {current_stock}
                30-day demand forecast: {demand_forecast}
                Operating principle: Never allow stockouts under any circumstances
                Cost consideration: Storage costs are manageable expense
                """
            },
            {
                "role": "user",
                "content": "Should we place new orders for next month's production?"
            }
        ]
        
        # Trace the interaction
        result = self.tracer.traced_completion(
            messages=messages,
            trace_metadata={
                "current_stock": current_stock,
                "demand_forecast": demand_forecast,
                "debug_session": "inventory_ordering_investigation"
            }
        )
        
        # Analyze the trace
        print("TRACED INTERACTION:")
        print("=" * 50)
        print(f"Response: {result['response']}")
        print("\nTrace Analysis:")
        print(f"Request ID: {result['trace_record']['request_id']}")
        print(f"Prompt Length: {result['trace_record']['prompt_length']}")
        
        # Check for problematic patterns
        prompt = result['trace_record']['prompt']
        if "never allow stockouts" in prompt.lower():
            print("⚠️  POTENTIAL ISSUE: 'never allow stockouts' may cause over-ordering")
        if "manageable expense" in prompt.lower():
            print("⚠️  POTENTIAL ISSUE: 'manageable expense' lacks specific cost constraints")
        
        return result

# Example usage
debugger = WarehouseDebugger()
result = debugger.debug_inventory_ordering(
    current_stock={"steel_sheets": 50000, "plastic_components": 25000, "electronics": 8000},
    demand_forecast={"steel_sheets": 12000, "plastic_components": 8000, "electronics": 3000}
)
```

---

## 🎯 Production Implementation Best Practices

### **1. Structured Logging**

```python
import structlog

# Configure structured logging for production
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.stdlib.BoundLogger,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)

class ProductionTracer:
    def __init__(self):
        self.logger = structlog.get_logger("ai_explainability")
    
    def log_ai_interaction(self, **kwargs):
        """Log AI interactions with structured data."""
        self.logger.info("ai_interaction", **kwargs)
```

### **2. Privacy-Aware Tracing**

```python
import hashlib
import re

class PrivacyAwareTracer(PromptTracer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.pii_patterns = [
            r'\b\d{3}-\d{2}-\d{4}\b',  # SSN
            r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',  # Email
            r'\b\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\b'  # Credit card
        ]
    
    def sanitize_text(self, text: str) -> str:
        """Remove or hash PII from text before logging."""
        sanitized = text
        for pattern in self.pii_patterns:
            sanitized = re.sub(pattern, '[REDACTED]', sanitized)
        return sanitized
    
    def trace_request(self, prompt: str, response: str, **kwargs):
        """Override to sanitize data before tracing."""
        sanitized_prompt = self.sanitize_text(prompt)
        sanitized_response = self.sanitize_text(response)
        return super().trace_request(sanitized_prompt, sanitized_response, **kwargs)
```

---

## 🎯 Key Takeaways

### **Prompt Tracing Benefits**

1. **Bug Detection**: Identify templating errors and unexpected prompt content
2. **Decision Auditing**: Understand what information influenced AI decisions
3. **Performance Analysis**: Track prompt effectiveness over time
4. **Compliance**: Maintain records for regulatory requirements

### **Attention Visualization Insights**

1. **Bias Detection**: Identify unexpected focus patterns
2. **Model Validation**: Ensure model attention aligns with expectations
3. **Input Optimization**: Improve prompt structure based on attention patterns
4. **Trust Building**: Demonstrate model reasoning to stakeholders

---

## 🔗 Related Topics

**Prerequisites**:

- [Part A: Explainability Fundamentals](17_LLM-Explainability-Fundamentals.md)
- Python programming and API integration

**Builds Upon**:

- [LLM Fundamentals](01_LLM-Fundamentals.md)
- [Prompt Engineering](05_Prompt-Engineering.md)

**Enables**:

- **Part C**: Advanced Behavior Tracing
- Production AI debugging and monitoring
- Regulatory compliance for AI systems

**Cross-References**:

- [DevOps Observability](../../04_DevOps/03_Observability-and-Monitoring/) - System monitoring
- [Software Design Principles](../../01_Development/02_software-design-principles/) - Testing patterns

---

## Next Steps

Continue to Part C for advanced behavior tracing techniques and production patterns
