# 📋 Assignment Template - Week [X]: [Topic Name]

## 📝 Assignment Overview

| **Attribute**         | **Details**                       |
| --------------------- | --------------------------------- |
| **Week**              | Week [X] - Phase [Y]              |
| **Topic**             | [Primary Topic]                   |
| **Due Date**          | [Date and Time]                   |
| **Submission Format** | GitHub Repository / Canvas Upload |
| **Estimated Time**    | [X] hours                         |
| **Points**            | [X] out of [Total]                |

---

## 🎯 Learning Objectives

This assignment reinforces the following learning objectives:

- [ ] **Objective 1**: [Specific skill or knowledge]
- [ ] **Objective 2**: [Implementation ability]
- [ ] **Objective 3**: [Analysis capability]
- [ ] **Objective 4**: [Application to real-world scenarios]

---

## 📋 Assignment Requirements

### **Core Requirements (80% of grade)**

1. **Implementation Component**

   - Implement [specific algorithm/data structure] in [language(s)]
   - Include proper documentation and comments
   - Follow coding standards and best practices

2. **Analysis Component**

   - Analyze time and space complexity
   - Compare with alternative approaches
   - Provide empirical performance measurements

3. **Testing Component**
   - Create comprehensive test cases
   - Include edge cases and boundary conditions
   - Demonstrate correctness with examples

### **Advanced Requirements (20% of grade)**

4. **Optimization Challenge**

   - Identify and implement performance improvements
   - Compare optimized vs. baseline versions
   - Document optimization strategies

5. **Real-World Application**
   - Apply the algorithm to a practical problem
   - Explain the business value or use case
   - Discuss scalability considerations

---

## 🏗️ Project Structure

### **Repository Organization**

```
week-[X]-[topic]-[your-name]/
├── README.md                    # Project overview and setup
├── requirements.txt             # Python dependencies
├── package.json                # Node.js dependencies (if applicable)
├── .gitignore                  # Git ignore file
│
├── src/                        # Source code
│   ├── python/
│   │   ├── [algorithm].py      # Main implementation
│   │   ├── tests/
│   │   │   └── test_[algorithm].py
│   │   └── benchmarks/
│   │       └── performance_test.py
│   │
│   ├── javascript/
│   │   ├── [algorithm].js      # Main implementation
│   │   ├── tests/
│   │   │   └── [algorithm].test.js
│   │   └── benchmarks/
│   │       └── performance-test.js
│   │
│   └── shared/
│       ├── test-data/          # Common test datasets
│       └── results/            # Performance results
│
├── docs/                       # Documentation
│   ├── complexity-analysis.md  # Theoretical analysis
│   ├── performance-results.md  # Empirical results
│   └── reflection.md          # Learning reflection
│
├── examples/                   # Usage examples
│   ├── basic-usage.py
│   ├── advanced-example.js
│   └── real-world-application/
│
└── presentation/               # Optional presentation materials
    ├── slides.md
    └── demo/
```

---

## 💻 Technical Specifications

### **Code Requirements**

#### **Python Implementation**

- **Version**: Python 3.9+
- **Style**: Follow PEP 8 guidelines
- **Type Hints**: Required for all functions
- **Documentation**: Docstrings with complexity analysis
- **Testing**: pytest with minimum 90% coverage

```python
def example_algorithm(input_data: List[int]) -> int:
    """
    Brief description of what this algorithm does.

    Args:
        input_data: Description of the input parameter

    Returns:
        Description of the return value

    Time Complexity: O(?)
    Space Complexity: O(?)

    Examples:
        >>> example_algorithm([1, 2, 3])
        6
        >>> example_algorithm([])
        0
    """
    # Implementation here
    pass
```

#### **JavaScript Implementation**

- **Version**: ES6+ (Node.js 18+)
- **Style**: Follow Airbnb JavaScript style guide
- **Documentation**: JSDoc comments required
- **Testing**: Jest with minimum 90% coverage

```javascript
/**
 * Brief description of what this algorithm does
 * @param {number[]} inputData - Description of input
 * @returns {number} Description of return value
 *
 * Time Complexity: O(?)
 * Space Complexity: O(?)
 *
 * @example
 * exampleAlgorithm([1, 2, 3]); // returns 6
 * exampleAlgorithm([]); // returns 0
 */
function exampleAlgorithm(inputData) {
  // Implementation here
}
```

#### **C# Implementation (Optional Bonus)**

- **Version**: .NET 6+
- **Style**: Follow Microsoft C# conventions
- **Documentation**: XML documentation comments
- **Testing**: xUnit with minimum 90% coverage

---

## 🧪 Testing Requirements

### **Test Categories**

1. **Unit Tests**

   - Test individual functions with various inputs
   - Cover all branches and edge cases
   - Include both positive and negative test cases

2. **Integration Tests**

   - Test algorithm with realistic datasets
   - Verify performance on larger inputs
   - Test interaction with other components

3. **Performance Tests**
   - Benchmark with different input sizes
   - Compare with alternative implementations
   - Measure memory usage and execution time

### **Test Data Requirements**

- **Small Datasets**: 10-100 elements
- **Medium Datasets**: 1,000-10,000 elements
- **Large Datasets**: 100,000+ elements
- **Edge Cases**: Empty inputs, single elements, duplicates
- **Special Cases**: Already sorted, reverse sorted, random data

---

## 📊 Performance Analysis

### **Complexity Analysis Document**

Create a markdown document (`complexity-analysis.md`) that includes:

1. **Theoretical Analysis**

   - Derive the time complexity step-by-step
   - Explain the space complexity
   - Compare with alternative approaches

2. **Empirical Results**

   - Create performance graphs
   - Include timing data tables
   - Analyze growth patterns

3. **Optimization Discussion**
   - Identify bottlenecks
   - Propose improvements
   - Discuss trade-offs

### **Performance Benchmark Template**

```python
import time
import matplotlib.pyplot as plt
from typing import List, Callable

def benchmark_algorithm(algorithm: Callable, test_sizes: List[int]) -> dict:
    """
    Benchmark an algorithm across different input sizes.

    Args:
        algorithm: Function to benchmark
        test_sizes: List of input sizes to test

    Returns:
        Dictionary with timing results
    """
    results = {'sizes': [], 'times': []}

    for size in test_sizes:
        # Generate test data
        test_data = generate_test_data(size)

        # Measure execution time
        start_time = time.perf_counter()
        algorithm(test_data)
        end_time = time.perf_counter()

        results['sizes'].append(size)
        results['times'].append(end_time - start_time)

    return results

def plot_performance(results: dict, title: str):
    """Create a performance visualization."""
    plt.figure(figsize=(10, 6))
    plt.plot(results['sizes'], results['times'], 'b-o')
    plt.xlabel('Input Size')
    plt.ylabel('Execution Time (seconds)')
    plt.title(title)
    plt.grid(True, alpha=0.3)
    plt.show()
```

---

## 📝 Deliverables

### **1. Code Implementation (40 points)**

- [ ] Working implementation in required language(s)
- [ ] Proper code structure and organization
- [ ] Clear, well-commented code
- [ ] Adherence to style guidelines

### **2. Test Suite (20 points)**

- [ ] Comprehensive test coverage (90%+)
- [ ] Edge cases and boundary conditions
- [ ] Performance benchmarks
- [ ] Clear test documentation

### **3. Analysis Report (25 points)**

- [ ] Theoretical complexity analysis
- [ ] Empirical performance results
- [ ] Comparison with alternatives
- [ ] Optimization recommendations

### **4. Documentation (10 points)**

- [ ] Clear README with setup instructions
- [ ] Code documentation and comments
- [ ] Usage examples
- [ ] API documentation

### **5. Presentation (5 points - Optional)**

- [ ] 5-minute presentation of your solution
- [ ] Demonstration of key features
- [ ] Discussion of challenges and insights
- [ ] Q&A with class

---

## 🎯 Assessment Rubric

### **Code Quality (40 points)**

| **Criteria**      | **Excellent (36-40)**                        | **Good (32-35)**                   | **Satisfactory (28-31)**    | **Needs Improvement (0-27)**     |
| ----------------- | -------------------------------------------- | ---------------------------------- | --------------------------- | -------------------------------- |
| **Correctness**   | Algorithm works perfectly for all test cases | Minor bugs in edge cases           | Works for most common cases | Significant bugs or doesn't work |
| **Efficiency**    | Optimal complexity, well-optimized           | Good complexity, some optimization | Acceptable complexity       | Poor complexity or inefficient   |
| **Code Style**    | Follows all style guidelines perfectly       | Minor style issues                 | Some style inconsistencies  | Poor style, hard to read         |
| **Documentation** | Excellent comments and docstrings            | Good documentation                 | Basic documentation         | Poor or missing documentation    |

### **Testing & Validation (20 points)**

| **Criteria**     | **Excellent (18-20)**              | **Good (16-17)**            | **Satisfactory (14-15)** | **Needs Improvement (0-13)** |
| ---------------- | ---------------------------------- | --------------------------- | ------------------------ | ---------------------------- |
| **Coverage**     | 95%+ test coverage                 | 90-94% coverage             | 80-89% coverage          | Less than 80% coverage       |
| **Test Quality** | Comprehensive, well-designed tests | Good test cases, minor gaps | Basic test coverage      | Poor or missing tests        |
| **Edge Cases**   | All edge cases covered             | Most edge cases covered     | Some edge cases          | Missing important edge cases |

### **Analysis & Understanding (25 points)**

| **Criteria**            | **Excellent (23-25)**                  | **Good (20-22)**            | **Satisfactory (18-19)**  | **Needs Improvement (0-17)**         |
| ----------------------- | -------------------------------------- | --------------------------- | ------------------------- | ------------------------------------ |
| **Complexity Analysis** | Perfect theoretical analysis           | Good analysis, minor errors | Basic analysis            | Poor or incorrect analysis           |
| **Performance Study**   | Thorough empirical study               | Good performance analysis   | Basic performance testing | Missing or poor performance analysis |
| **Insights**            | Deep understanding, excellent insights | Good understanding          | Basic understanding       | Poor understanding                   |

### **Documentation & Communication (10 points)**

| **Criteria**      | **Excellent (9-10)**           | **Good (8)**        | **Satisfactory (7)** | **Needs Improvement (0-6)**   |
| ----------------- | ------------------------------ | ------------------- | -------------------- | ----------------------------- |
| **README**        | Comprehensive, professional    | Good documentation  | Basic documentation  | Poor or missing documentation |
| **Code Comments** | Excellent inline documentation | Good comments       | Basic comments       | Poor or missing comments      |
| **Clarity**       | Crystal clear communication    | Clear communication | Mostly clear         | Confusing or unclear          |

---

## 📤 Submission Guidelines

### **Submission Format**

1. **GitHub Repository** (Preferred)

   - Create a public repository
   - Include all required files and documentation
   - Add instructor as collaborator
   - Submit repository URL via course platform

2. **Zip Archive** (Alternative)
   - Create zip file with all project files
   - Include README with setup instructions
   - Upload to course submission system

### **Submission Checklist**

- [ ] All code files are included and executable
- [ ] Tests run successfully and pass
- [ ] Documentation is complete and clear
- [ ] Performance analysis is included
- [ ] Repository/archive is properly organized
- [ ] README includes setup and usage instructions
- [ ] Code follows style guidelines
- [ ] No sensitive information (passwords, keys) included

### **Late Submission Policy**

- **Within 24 hours**: -10% penalty
- **Within 48 hours**: -20% penalty
- **Within 72 hours**: -30% penalty
- **After 72 hours**: Contact instructor for individual arrangement

---

## 💡 Tips for Success

### **Getting Started**

1. **Start Early**: Begin as soon as the assignment is released
2. **Read Carefully**: Understand all requirements before coding
3. **Plan First**: Sketch out your approach before implementation
4. **Test Often**: Write tests as you develop, not after

### **Common Pitfalls to Avoid**

- **Skipping edge cases**: Always test boundary conditions
- **Poor documentation**: Code without comments is hard to grade
- **Ignoring performance**: Don't forget the complexity analysis
- **Last-minute work**: Quality suffers under time pressure

### **Getting Help**

- **Office Hours**: Attend instructor office hours for guidance
- **Discussion Forum**: Ask questions and help classmates
- **Study Groups**: Collaborate (but don't copy) with peers
- **Online Resources**: Use documentation and tutorials

---

## 🎪 Extension Opportunities

### **Advanced Challenges**

1. **Multi-Language Implementation**

   - Implement in Python, JavaScript, AND C#
   - Compare performance across languages
   - Discuss language-specific optimizations

2. **Real-World Application**

   - Apply algorithm to solve a practical problem
   - Build a simple web interface or CLI tool
   - Document the business value

3. **Research Component**
   - Research alternative algorithms for the same problem
   - Implement and compare multiple approaches
   - Write a comparative analysis

### **Creative Applications**

- **Visualization**: Create interactive algorithm visualizations
- **Game Development**: Use algorithm in a simple game
- **Data Analysis**: Apply to analyze real datasets
- **API Development**: Build REST API around your algorithm

---

## 📞 Support Resources

### **Technical Help**

- **Instructor Office Hours**: [Times and location]
- **TA Support**: [Contact information]
- **Discussion Forum**: [Link to forum]
- **Video Tutorials**: [Supplementary video links]

### **Academic Support**

- **Writing Center**: Help with documentation and reports
- **Tutoring Services**: General programming assistance
- **Study Groups**: Peer learning opportunities
- **Accessibility Services**: Accommodations if needed

---

## 🏷️ Metadata

**Assignment Type**: Implementation + Analysis  
**Difficulty Level**: [🟢🟡🔴] [Beginner/Intermediate/Advanced]  
**Languages**: [Primary languages for this assignment]  
**Estimated Time**: [X] hours  
**Prerequisites**: [Required knowledge]  
**Version**: 1.0  
**Last Updated**: [Date]

---

_This assignment template provides a comprehensive framework for meaningful, challenging projects that reinforce learning objectives while developing practical coding skills._
