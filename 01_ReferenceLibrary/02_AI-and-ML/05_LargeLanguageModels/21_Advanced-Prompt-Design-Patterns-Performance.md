# Advanced Prompt Design Patterns - Part B: Performance Optimization

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Part A - Structural Foundations  
**Estimated Time**: 27 minutes  
**Part**: B of 3-part series on Advanced Prompt Design

---

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- **Optimize prompt efficiency** for faster responses and lower costs
- **Design token-conscious prompts** that maximize value per API call
- **Implement caching strategies** for repeated operations
- **Apply performance patterns** for production AI systems

---

## ⚡ Token Efficiency and Cost Optimization

### **The Economics of Prompt Engineering**

Every token counts in production AI systems. Poor prompt design leads to:

- **Exponential cost growth** as usage scales
- **Slower response times** with verbose prompts
- **API rate limiting** issues under load
- **Poor user experience** from delayed responses

### **Token Analysis Framework**

```python
class PromptTokenAnalyzer:
    """Analyze and optimize prompt token usage."""
    
    def __init__(self, model_name: str = "gpt-4"):
        self.model_name = model_name
        self.cost_per_token = {
            "gpt-4": {"input": 0.00003, "output": 0.00006},
            "gpt-3.5-turbo": {"input": 0.000001, "output": 0.000002},
            "claude-3": {"input": 0.000008, "output": 0.000024}
        }
    
    def estimate_cost(self, prompt: str, expected_output_tokens: int = 500) -> dict:
        """Calculate estimated API cost for a prompt."""
        input_tokens = len(prompt.split()) * 1.3  # Rough token estimation
        
        input_cost = input_tokens * self.cost_per_token[self.model_name]["input"]
        output_cost = expected_output_tokens * self.cost_per_token[self.model_name]["output"]
        
        return {
            "input_tokens": int(input_tokens),
            "output_tokens": expected_output_tokens,
            "input_cost": round(input_cost, 6),
            "output_cost": round(output_cost, 6),
            "total_cost": round(input_cost + output_cost, 6),
            "efficiency_score": round(expected_output_tokens / input_tokens, 2)
        }
    
    def compare_prompts(self, prompts: dict) -> dict:
        """Compare efficiency across multiple prompt versions."""
        results = {}
        for name, prompt in prompts.items():
            results[name] = self.estimate_cost(prompt)
        return results

# Example usage
analyzer = PromptTokenAnalyzer("gpt-4")

verbose_prompt = """
You are a highly experienced software engineer with deep expertise in multiple programming languages, 
frameworks, and architectural patterns. You have worked at top-tier technology companies and have 
extensive experience in building scalable, maintainable, and performant systems. Your knowledge spans 
across various domains including web development, mobile applications, data engineering, machine learning, 
and DevOps practices. You understand industry best practices, design patterns, and modern development 
methodologies. Given your extensive background and expertise, I would like you to carefully analyze 
the following code snippet and provide comprehensive feedback covering multiple aspects including but 
not limited to code quality, performance optimizations, security considerations, maintainability 
improvements, and architectural recommendations.
"""

optimized_prompt = """
ROLE: Senior Software Engineer
TASK: Analyze code for quality, performance, security, maintainability
OUTPUT: Structured review with specific recommendations
"""

comparison = analyzer.compare_prompts({
    "verbose": verbose_prompt,
    "optimized": optimized_prompt
})
```

### **Compression Techniques**

#### **Before: Verbose Requirements**

```text
I need you to create a comprehensive database schema design for our e-commerce platform. 
The platform needs to handle product catalogs with multiple categories and subcategories. 
We need to store customer information including their contact details, billing addresses, 
and shipping addresses. The system should support orders with multiple items, and each 
item can have variations like size and color. We also need to track inventory levels, 
supplier information, and handle discount codes. The database should be optimized for 
both read and write operations as we expect high traffic. Please include proper indexing 
strategies and foreign key relationships. Make sure the design follows database 
normalization principles and can scale as our business grows.
```

**Token Count**: ~175 tokens  
**Efficiency**: Low - redundant phrases, unnecessary context

#### **After: Compressed Precision**

```text
TASK: E-commerce database schema design
ENTITIES: Products (categories, variations), Customers (addresses), Orders (items, discounts), Inventory, Suppliers
REQUIREMENTS: High-traffic optimization, proper indexing, normalized design, scalability
OUTPUT: PostgreSQL DDL with relationships and indexes
```

**Token Count**: ~45 tokens  
**Efficiency**: High - 74% token reduction, same information

---

## 🎯 Strategic Prompt Patterns

### **Template Inheritance Pattern**

```python
class PromptTemplate:
    """Base template for reusable prompt patterns."""
    
    BASE_STRUCTURE = """
ROLE: {role}
CONTEXT: {context}
TASK: {task}
OUTPUT: {output_format}
CONSTRAINTS: {constraints}
"""
    
    def __init__(self, role: str, default_constraints: list = None):
        self.role = role
        self.default_constraints = default_constraints or []
    
    def generate(self, context: str, task: str, output_format: str, 
                 additional_constraints: list = None) -> str:
        """Generate prompt from template."""
        all_constraints = self.default_constraints + (additional_constraints or [])
        constraints_text = " | ".join(all_constraints)
        
        return self.BASE_STRUCTURE.format(
            role=self.role,
            context=context,
            task=task,
            output_format=output_format,
            constraints=constraints_text
        ).strip()

class SecurityAuditorTemplate(PromptTemplate):
    """Specialized template for security audits."""
    
    def __init__(self):
        super().__init__(
            role="Senior Security Engineer",
            default_constraints=[
                "OWASP Top 10 focus",
                "CWE references required", 
                "Severity ratings (CRITICAL|HIGH|MEDIUM|LOW)",
                "Actionable remediation steps"
            ]
        )

class PerformanceEngineerTemplate(PromptTemplate):
    """Specialized template for performance analysis."""
    
    def __init__(self):
        super().__init__(
            role="Performance Engineering Specialist",
            default_constraints=[
                "Quantified metrics required",
                "Bottleneck identification",
                "Optimization recommendations",
                "Before/after comparisons"
            ]
        )

# Usage example
security_template = SecurityAuditorTemplate()
security_prompt = security_template.generate(
    context="React frontend application with user authentication",
    task="Identify XSS vulnerabilities in user input handling",
    output_format="Security findings report with remediation code",
    additional_constraints=["GDPR compliance check", "React 18+ patterns only"]
)
```

### **Batch Processing Pattern**

```text
ROLE: Database Performance Specialist

BATCH TASK: Analyze multiple query performance issues

BATCH INPUT FORMAT:
Query_ID | SQL_Statement | Execution_Plan | Current_Performance_Metrics

ANALYSIS SCOPE: Each query should be evaluated for:
- Index optimization opportunities
- Query rewrite possibilities  
- Resource utilization efficiency
- Scalability bottlenecks

OUTPUT FORMAT: Performance analysis matrix
| Query_ID | Issue_Type | Severity | Optimization | Est_Improvement |

CONSTRAINTS:
- PostgreSQL 14+ syntax only
- Focus on read-heavy workloads
- Consider 10M+ row tables
- Provide specific index DDL recommendations

BATCH DATA:
Q001 | SELECT * FROM orders WHERE customer_id = ? | Seq Scan on orders | 2.3s avg
Q002 | SELECT COUNT(*) FROM products WHERE category_id IN (?) | Nested Loop | 890ms avg  
Q003 | SELECT o.*, c.name FROM orders o JOIN customers c ON o.customer_id = c.id WHERE o.created_at > ? | Hash Join | 1.2s avg
```

---

## 🔄 Intelligent Caching Strategies

### **Prompt Response Caching**

```python
import hashlib
import json
from typing import Dict, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class CachedResponse:
    """Cached prompt response with metadata."""
    response: str
    timestamp: datetime
    token_count: int
    model_used: str
    cache_key: str

class PromptCache:
    """Intelligent caching for prompt responses."""
    
    def __init__(self, ttl_hours: int = 24):
        self.cache: Dict[str, CachedResponse] = {}
        self.ttl = timedelta(hours=ttl_hours)
        self.hit_count = 0
        self.miss_count = 0
    
    def _generate_cache_key(self, prompt: str, model: str) -> str:
        """Generate consistent cache key from prompt content."""
        # Normalize prompt (remove extra whitespace, case-insensitive for certain patterns)
        normalized = " ".join(prompt.split()).lower()
        content_hash = hashlib.md5(f"{normalized}:{model}".encode()).hexdigest()
        return content_hash[:16]  # Short key for efficiency
    
    def get(self, prompt: str, model: str) -> Optional[CachedResponse]:
        """Retrieve cached response if available and valid."""
        cache_key = self._generate_cache_key(prompt, model)
        
        if cache_key in self.cache:
            cached = self.cache[cache_key]
            
            # Check if cache entry is still valid
            if datetime.now() - cached.timestamp < self.ttl:
                self.hit_count += 1
                return cached
            else:
                # Remove expired entry
                del self.cache[cache_key]
        
        self.miss_count += 1
        return None
    
    def set(self, prompt: str, model: str, response: str, token_count: int):
        """Cache a new response."""
        cache_key = self._generate_cache_key(prompt, model)
        
        self.cache[cache_key] = CachedResponse(
            response=response,
            timestamp=datetime.now(),
            token_count=token_count,
            model_used=model,
            cache_key=cache_key
        )
    
    def get_stats(self) -> dict:
        """Get cache performance statistics."""
        total_requests = self.hit_count + self.miss_count
        hit_rate = (self.hit_count / total_requests * 100) if total_requests > 0 else 0
        
        return {
            "hit_rate": round(hit_rate, 2),
            "total_hits": self.hit_count,
            "total_misses": self.miss_count,
            "cached_entries": len(self.cache),
            "estimated_tokens_saved": sum(entry.token_count for entry in self.cache.values())
        }
    
    def clear_expired(self):
        """Remove all expired cache entries."""
        now = datetime.now()
        expired_keys = [
            key for key, entry in self.cache.items()
            if now - entry.timestamp >= self.ttl
        ]
        
        for key in expired_keys:
            del self.cache[key]
            
        return len(expired_keys)

# Usage example
cache = PromptCache(ttl_hours=6)

# Check cache before API call
cached_response = cache.get(my_prompt, "gpt-4")
if cached_response:
    print(f"Cache hit! Saved {cached_response.token_count} tokens")
    result = cached_response.response
else:
    # Make API call
    result = openai_client.chat.completions.create(...)
    cache.set(my_prompt, "gpt-4", result, estimated_tokens)
```

### **Semantic Similarity Caching**

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

class SemanticPromptCache:
    """Cache with semantic similarity matching for near-duplicate prompts."""
    
    def __init__(self, similarity_threshold: float = 0.85):
        self.similarity_threshold = similarity_threshold
        self.vectorizer = TfidfVectorizer(stop_words='english', max_features=1000)
        self.prompt_vectors = None
        self.cached_prompts = []
        self.cached_responses = []
    
    def _vectorize_prompts(self):
        """Update vectorization of all cached prompts."""
        if self.cached_prompts:
            self.prompt_vectors = self.vectorizer.fit_transform(self.cached_prompts)
    
    def find_similar(self, new_prompt: str) -> Optional[tuple]:
        """Find semantically similar cached prompt."""
        if not self.cached_prompts:
            return None
        
        # Vectorize new prompt
        new_vector = self.vectorizer.transform([new_prompt])
        
        # Calculate similarities
        similarities = cosine_similarity(new_vector, self.prompt_vectors)[0]
        
        # Find best match above threshold
        best_match_idx = np.argmax(similarities)
        best_similarity = similarities[best_match_idx]
        
        if best_similarity >= self.similarity_threshold:
            return (
                self.cached_prompts[best_match_idx],
                self.cached_responses[best_match_idx],
                best_similarity
            )
        
        return None
    
    def add_to_cache(self, prompt: str, response: str):
        """Add new prompt-response pair to semantic cache."""
        self.cached_prompts.append(prompt)
        self.cached_responses.append(response)
        self._vectorize_prompts()
    
    def get_semantic_match(self, prompt: str) -> Optional[dict]:
        """Get semantically similar response if available."""
        match = self.find_similar(prompt)
        
        if match:
            cached_prompt, cached_response, similarity = match
            return {
                "response": cached_response,
                "similarity": round(similarity, 3),
                "original_prompt": cached_prompt,
                "cache_type": "semantic"
            }
        
        return None

# Usage example
semantic_cache = SemanticPromptCache(similarity_threshold=0.80)

# Example prompts that are semantically similar
prompt1 = "Create a REST API for user authentication with JWT tokens"
prompt2 = "Design a RESTful authentication service using JSON Web Tokens"

# First prompt
semantic_cache.add_to_cache(prompt1, "Generated authentication API code...")

# Second prompt will find semantic match
match = semantic_cache.get_semantic_match(prompt2)
if match:
    print(f"Semantic match found! Similarity: {match['similarity']}")
```

---

## 📊 Performance Monitoring and Optimization

### **Prompt Performance Metrics**

```python
class PromptPerformanceTracker:
    """Track and analyze prompt performance metrics."""
    
    def __init__(self):
        self.metrics = {
            "response_times": [],
            "token_costs": [],
            "quality_scores": [],
            "cache_hits": 0,
            "total_requests": 0
        }
    
    def record_request(self, response_time: float, token_cost: float, 
                      quality_score: float = None, cache_hit: bool = False):
        """Record metrics for a prompt request."""
        self.metrics["response_times"].append(response_time)
        self.metrics["token_costs"].append(token_cost)
        
        if quality_score:
            self.metrics["quality_scores"].append(quality_score)
        
        if cache_hit:
            self.metrics["cache_hits"] += 1
            
        self.metrics["total_requests"] += 1
    
    def get_performance_report(self) -> dict:
        """Generate comprehensive performance report."""
        response_times = self.metrics["response_times"]
        token_costs = self.metrics["token_costs"]
        quality_scores = self.metrics["quality_scores"]
        
        return {
            "performance_summary": {
                "avg_response_time": round(np.mean(response_times), 2),
                "p95_response_time": round(np.percentile(response_times, 95), 2),
                "total_token_cost": round(sum(token_costs), 4),
                "avg_cost_per_request": round(np.mean(token_costs), 4),
                "cache_hit_rate": round((self.metrics["cache_hits"] / self.metrics["total_requests"]) * 100, 2)
            },
            "quality_metrics": {
                "avg_quality_score": round(np.mean(quality_scores), 2) if quality_scores else None,
                "quality_consistency": round(np.std(quality_scores), 2) if quality_scores else None
            },
            "optimization_opportunities": self._identify_optimizations()
        }
    
    def _identify_optimizations(self) -> list:
        """Suggest optimization opportunities based on metrics."""
        suggestions = []
        
        avg_response_time = np.mean(self.metrics["response_times"])
        if avg_response_time > 5.0:
            suggestions.append("Consider prompt compression - response time > 5s")
        
        total_cost = sum(self.metrics["token_costs"])
        if total_cost > 10.0:  # $10 threshold
            suggestions.append("High token costs detected - review prompt efficiency")
        
        cache_hit_rate = (self.metrics["cache_hits"] / self.metrics["total_requests"]) * 100
        if cache_hit_rate < 30:
            suggestions.append("Low cache hit rate - consider semantic caching")
        
        if len(self.metrics["quality_scores"]) > 10:
            quality_variance = np.std(self.metrics["quality_scores"])
            if quality_variance > 0.3:
                suggestions.append("Inconsistent quality - review prompt constraints")
        
        return suggestions
```

### **A/B Testing for Prompt Optimization**

```python
class PromptABTester:
    """A/B testing framework for prompt optimization."""
    
    def __init__(self):
        self.experiments = {}
    
    def create_experiment(self, experiment_name: str, prompt_a: str, 
                         prompt_b: str, traffic_split: float = 0.5):
        """Create new A/B test experiment."""
        self.experiments[experiment_name] = {
            "prompt_a": prompt_a,
            "prompt_b": prompt_b,
            "traffic_split": traffic_split,
            "results_a": [],
            "results_b": [],
            "start_time": datetime.now()
        }
    
    def get_test_prompt(self, experiment_name: str) -> tuple:
        """Get prompt variant for testing (returns prompt and variant name)."""
        experiment = self.experiments[experiment_name]
        
        # Simple random assignment
        if np.random.random() < experiment["traffic_split"]:
            return experiment["prompt_a"], "A"
        else:
            return experiment["prompt_b"], "B"
    
    def record_result(self, experiment_name: str, variant: str, 
                     response_time: float, quality_score: float, cost: float):
        """Record test result for analysis."""
        result = {
            "response_time": response_time,
            "quality_score": quality_score,
            "cost": cost,
            "timestamp": datetime.now()
        }
        
        if variant == "A":
            self.experiments[experiment_name]["results_a"].append(result)
        else:
            self.experiments[experiment_name]["results_b"].append(result)
    
    def analyze_experiment(self, experiment_name: str) -> dict:
        """Analyze A/B test results for statistical significance."""
        experiment = self.experiments[experiment_name]
        results_a = experiment["results_a"]
        results_b = experiment["results_b"]
        
        if len(results_a) < 10 or len(results_b) < 10:
            return {"error": "Insufficient data for analysis (minimum 10 samples per variant)"}
        
        # Extract metrics
        quality_a = [r["quality_score"] for r in results_a]
        quality_b = [r["quality_score"] for r in results_b]
        cost_a = [r["cost"] for r in results_a]
        cost_b = [r["cost"] for r in results_b]
        time_a = [r["response_time"] for r in results_a]
        time_b = [r["response_time"] for r in results_b]
        
        return {
            "sample_sizes": {"A": len(results_a), "B": len(results_b)},
            "quality_comparison": {
                "A_avg": round(np.mean(quality_a), 3),
                "B_avg": round(np.mean(quality_b), 3),
                "improvement": round(((np.mean(quality_b) - np.mean(quality_a)) / np.mean(quality_a)) * 100, 2)
            },
            "cost_comparison": {
                "A_avg": round(np.mean(cost_a), 4),
                "B_avg": round(np.mean(cost_b), 4),
                "cost_change": round(((np.mean(cost_b) - np.mean(cost_a)) / np.mean(cost_a)) * 100, 2)
            },
            "performance_comparison": {
                "A_avg_time": round(np.mean(time_a), 2),
                "B_avg_time": round(np.mean(time_b), 2),
                "speed_change": round(((np.mean(time_b) - np.mean(time_a)) / np.mean(time_a)) * 100, 2)
            },
            "recommendation": self._get_recommendation(quality_a, quality_b, cost_a, cost_b)
        }
    
    def _get_recommendation(self, quality_a, quality_b, cost_a, cost_b) -> str:
        """Generate recommendation based on test results."""
        quality_improvement = (np.mean(quality_b) - np.mean(quality_a)) / np.mean(quality_a)
        cost_change = (np.mean(cost_b) - np.mean(cost_a)) / np.mean(cost_a)
        
        if quality_improvement > 0.05 and cost_change < 0.1:
            return "Variant B shows significant improvement - recommend adoption"
        elif quality_improvement > 0.02 and cost_change < -0.05:
            return "Variant B shows better quality at lower cost - strong recommendation"
        elif abs(quality_improvement) < 0.02 and cost_change < -0.1:
            return "Variant B significantly more cost-effective - recommend for cost optimization"
        else:
            return "No clear winner - continue testing or investigate other variants"
```

---

## 🎯 Key Takeaways

### **Performance Optimization Principles**

1. **Token Efficiency**: Every token has cost and latency impact - compress without losing precision
2. **Intelligent Caching**: Implement both exact and semantic matching for maximum cache utilization
3. **Batch Processing**: Group similar tasks to amortize prompt overhead
4. **A/B Testing**: Continuously optimize through data-driven experimentation

### **Production-Ready Patterns**

- **Performance Monitoring**: Track response times, costs, and quality metrics
- **Cache Hierarchies**: Combine multiple caching strategies for maximum efficiency
- **Template Systems**: Reusable patterns for consistent optimization
- **Continuous Improvement**: Regular analysis and optimization cycles

---

## 🔗 Related Topics

**Prerequisites**:

- **Part A**: Structural foundations and role-based prompting

**Builds Upon**:

- [API Integration Patterns](../../01_Development/) - Efficient API usage patterns
- [Caching Strategies](../../04_DevOps/) - Infrastructure-level caching

**Enables**:

- **Part C**: Few-shot learning and complex reasoning optimization
- Production AI system deployment
- Cost-effective AI integration at scale

**Cross-References**:

- [Performance Engineering](../../04_DevOps/03_Observability-and-Monitoring/) - System performance patterns
- [Cost Optimization](../../04_DevOps/) - Infrastructure cost management

---

## Next Steps

Continue to Part C for advanced few-shot learning patterns and complex reasoning optimization techniques
