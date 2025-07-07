# 💻 Code Example Templates

## 📋 Template Overview

This file provides standardized code templates for all curriculum materials. These templates eliminate duplication while ensuring consistency across Python, JavaScript, and C# implementations.

---

## 🐍 Python Template

### **Basic Algorithm Template**

```python
from typing import List, Optional, Any
import time

def {{ALGORITHM_NAME}}({{PARAMETERS}}) -> {{RETURN_TYPE}}:
    """
    {{ALGORITHM_DESCRIPTION}}

    Args:
        {{PARAMETER_DOCS}}

    Returns:
        {{RETURN_DESCRIPTION}}

    Time Complexity: O({{TIME_COMPLEXITY}})
    Space Complexity: O({{SPACE_COMPLEXITY}})

    Examples:
        >>> {{ALGORITHM_NAME}}({{EXAMPLE_INPUT}})
        {{EXAMPLE_OUTPUT}}

        >>> {{ALGORITHM_NAME}}({{EDGE_CASE_INPUT}})
        {{EDGE_CASE_OUTPUT}}

    Raises:
        {{EXCEPTION_TYPE}}: {{EXCEPTION_DESCRIPTION}}
    """
    # TODO: Implement algorithm
    pass

# Performance measurement utility
def measure_time(func, *args, **kwargs) -> float:
    """Measure execution time of a function."""
    start_time = time.perf_counter()
    result = func(*args, **kwargs)
    end_time = time.perf_counter()
    return end_time - start_time, result

# Test cases template
def test_{{ALGORITHM_NAME}}():
    """Comprehensive test cases for {{ALGORITHM_NAME}}."""
    # Basic test cases
    assert {{ALGORITHM_NAME}}({{TEST_INPUT}}) == {{EXPECTED_OUTPUT}}

    # Edge cases
    assert {{ALGORITHM_NAME}}([]) == {{EMPTY_CASE_OUTPUT}}
    assert {{ALGORITHM_NAME}}({{SINGLE_ELEMENT}}) == {{SINGLE_OUTPUT}}

    # Error cases
    try:
        {{ALGORITHM_NAME}}({{INVALID_INPUT}})
        assert False, "Should have raised exception"
    except {{EXCEPTION_TYPE}}:
        pass  # Expected

if __name__ == "__main__":
    # Demonstration
    test_{{ALGORITHM_NAME}}()
    print("All tests passed!")

    # Performance testing
    test_data = {{PERFORMANCE_TEST_DATA}}
    execution_time, result = measure_time({{ALGORITHM_NAME}}, test_data)
    print(f"Execution time: {execution_time:.6f}s")
    print(f"Result: {result}")
```

### **Class-Based Template**

```python
from typing import Generic, TypeVar, Optional

T = TypeVar('T')

class {{CLASS_NAME}}(Generic[T]):
    """
    {{CLASS_DESCRIPTION}}

    Time Complexity:
        - Insert: O({{INSERT_COMPLEXITY}})
        - Search: O({{SEARCH_COMPLEXITY}})
        - Delete: O({{DELETE_COMPLEXITY}})

    Space Complexity: O({{SPACE_COMPLEXITY}})
    """

    def __init__(self, {{INIT_PARAMETERS}}):
        """Initialize the data structure."""
        self.{{INTERNAL_STATE}} = {{INITIAL_VALUE}}

    def {{PRIMARY_METHOD}}(self, {{METHOD_PARAMETERS}}) -> {{RETURN_TYPE}}:
        """
        {{METHOD_DESCRIPTION}}

        Time Complexity: O({{METHOD_COMPLEXITY}})
        """
        # TODO: Implement method
        pass

    def __str__(self) -> str:
        """String representation for debugging."""
        return f"{{CLASS_NAME}}({{DISPLAY_ATTRIBUTES}})"

    def __len__(self) -> int:
        """Return number of elements."""
        return len(self.{{INTERNAL_STATE}})
```

---

## 🟨 JavaScript Template

### **Function-Based Template**

```javascript
/**
 * {{ALGORITHM_DESCRIPTION}}
 *
 * @param {{{PARAMETER_TYPE}}} {{PARAMETER_NAME}} - {{PARAMETER_DESCRIPTION}}
 * @returns {{{RETURN_TYPE}}} {{RETURN_DESCRIPTION}}
 *
 * Time Complexity: O({{TIME_COMPLEXITY}})
 * Space Complexity: O({{SPACE_COMPLEXITY}})
 *
 * @example
 * {{ALGORITHM_NAME}}({{EXAMPLE_INPUT}}); // returns {{EXAMPLE_OUTPUT}}
 * {{ALGORITHM_NAME}}({{EDGE_CASE_INPUT}}); // returns {{EDGE_CASE_OUTPUT}}
 */
function {{ALGORITHM_NAME}}({{PARAMETERS}}) {
    // Input validation
    if ({{VALIDATION_CONDITION}}) {
        throw new Error('{{ERROR_MESSAGE}}');
    }

    // TODO: Implement algorithm
    return {{DEFAULT_RETURN}};
}

/**
 * Measure execution time of a function
 * @param {Function} func - Function to measure
 * @param {...any} args - Arguments for the function
 * @returns {Object} Object with time and result properties
 */
function measureTime(func, ...args) {
    const startTime = performance.now();
    const result = func(...args);
    const endTime = performance.now();

    return {
        time: endTime - startTime,
        result: result
    };
}

/**
 * Test suite for {{ALGORITHM_NAME}}
 */
function test{{ALGORITHM_NAME}}() {
    console.log('Testing {{ALGORITHM_NAME}}...');

    // Basic test cases
    console.assert(
        {{ALGORITHM_NAME}}({{TEST_INPUT}}) === {{EXPECTED_OUTPUT}},
        'Basic test case failed'
    );

    // Edge cases
    console.assert(
        {{ALGORITHM_NAME}}([]) === {{EMPTY_CASE_OUTPUT}},
        'Empty input test failed'
    );

    // Performance test
    const testData = {{PERFORMANCE_TEST_DATA}};
    const {time, result} = measureTime({{ALGORITHM_NAME}}, testData);
    console.log(`Execution time: ${time.toFixed(3)}ms`);
    console.log(`Result: ${result}`);

    console.log('All tests passed!');
}

// Run tests if in Node.js environment
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { {{ALGORITHM_NAME}}, measureTime };

    // Run tests
    test{{ALGORITHM_NAME}}();
}
```

### **Class-Based Template**

```javascript
/**
 * {{CLASS_DESCRIPTION}}
 *
 * Time Complexity:
 *   - Insert: O({{INSERT_COMPLEXITY}})
 *   - Search: O({{SEARCH_COMPLEXITY}})
 *   - Delete: O({{DELETE_COMPLEXITY}})
 *
 * Space Complexity: O({{SPACE_COMPLEXITY}})
 */
class {{CLASS_NAME}} {
    /**
     * Create a new {{CLASS_NAME}}
     * @param {{{INIT_PARAMETER_TYPE}}} {{INIT_PARAMETER_NAME}} - {{INIT_PARAMETER_DESCRIPTION}}
     */
    constructor({{INIT_PARAMETERS}}) {
        this.{{INTERNAL_STATE}} = {{INITIAL_VALUE}};
        this.{{SIZE_PROPERTY}} = 0;
    }

    /**
     * {{PRIMARY_METHOD_DESCRIPTION}}
     * @param {{{METHOD_PARAMETER_TYPE}}} {{METHOD_PARAMETER_NAME}} - {{METHOD_PARAMETER_DESCRIPTION}}
     * @returns {{{METHOD_RETURN_TYPE}}} {{METHOD_RETURN_DESCRIPTION}}
     *
     * Time Complexity: O({{METHOD_COMPLEXITY}})
     */
    {{PRIMARY_METHOD}}({{METHOD_PARAMETERS}}) {
        // TODO: Implement method
        return {{METHOD_DEFAULT_RETURN}};
    }

    /**
     * Get the number of elements
     * @returns {number} Number of elements
     */
    get size() {
        return this.{{SIZE_PROPERTY}};
    }

    /**
     * Check if the data structure is empty
     * @returns {boolean} True if empty
     */
    isEmpty() {
        return this.{{SIZE_PROPERTY}} === 0;
    }

    /**
     * String representation for debugging
     * @returns {string} String representation
     */
    toString() {
        return `{{CLASS_NAME}}({{DISPLAY_ATTRIBUTES}})`;
    }
}
```

---

## 🟦 C# Template

### **Static Method Template**

```csharp
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace AlgorithmsAndDataStructures
{
    /// <summary>
    /// {{ALGORITHM_DESCRIPTION}}
    /// </summary>
    public static class {{CLASS_NAME}}
    {
        /// <summary>
        /// {{METHOD_DESCRIPTION}}
        /// Time Complexity: O({{TIME_COMPLEXITY}})
        /// Space Complexity: O({{SPACE_COMPLEXITY}})
        /// </summary>
        /// <param name="{{PARAMETER_NAME}}">{{PARAMETER_DESCRIPTION}}</param>
        /// <returns>{{RETURN_DESCRIPTION}}</returns>
        /// <exception cref="{{EXCEPTION_TYPE}}">{{EXCEPTION_DESCRIPTION}}</exception>
        public static {{RETURN_TYPE}} {{METHOD_NAME}}({{PARAMETER_TYPE}} {{PARAMETER_NAME}})
        {
            // Input validation
            if ({{VALIDATION_CONDITION}})
            {
                throw new {{EXCEPTION_TYPE}}("{{ERROR_MESSAGE}}");
            }

            // TODO: Implement algorithm
            return {{DEFAULT_RETURN}};
        }

        /// <summary>
        /// Measure execution time of an action
        /// </summary>
        /// <param name="action">Action to measure</param>
        /// <returns>Execution time</returns>
        public static TimeSpan MeasureTime(Action action)
        {
            var stopwatch = Stopwatch.StartNew();
            action();
            stopwatch.Stop();
            return stopwatch.Elapsed;
        }

        /// <summary>
        /// Measure execution time of a function
        /// </summary>
        /// <typeparam name="T">Return type</typeparam>
        /// <param name="func">Function to measure</param>
        /// <returns>Tuple of time and result</returns>
        public static (TimeSpan Time, T Result) MeasureTime<T>(Func<T> func)
        {
            var stopwatch = Stopwatch.StartNew();
            var result = func();
            stopwatch.Stop();
            return (stopwatch.Elapsed, result);
        }
    }

    /// <summary>
    /// Test cases for {{CLASS_NAME}}
    /// </summary>
    public static class {{CLASS_NAME}}Tests
    {
        /// <summary>
        /// Run all test cases
        /// </summary>
        public static void RunTests()
        {
            Console.WriteLine($"Testing {nameof({{CLASS_NAME}})}...");

            // Basic test cases
            TestBasicCases();
            TestEdgeCases();
            TestPerformance();

            Console.WriteLine("All tests passed!");
        }

        private static void TestBasicCases()
        {
            var result = {{CLASS_NAME}}.{{METHOD_NAME}}({{TEST_INPUT}});
            Debug.Assert(result.Equals({{EXPECTED_OUTPUT}}), "Basic test case failed");
        }

        private static void TestEdgeCases()
        {
            // Empty input test
            var emptyResult = {{CLASS_NAME}}.{{METHOD_NAME}}({{EMPTY_INPUT}});
            Debug.Assert(emptyResult.Equals({{EMPTY_OUTPUT}}), "Empty case failed");

            // Exception test
            Assert.ThrowsException<{{EXCEPTION_TYPE}}>(() =>
                {{CLASS_NAME}}.{{METHOD_NAME}}({{INVALID_INPUT}}));
        }

        private static void TestPerformance()
        {
            var testData = {{PERFORMANCE_TEST_DATA}};
            var (time, result) = {{CLASS_NAME}}.MeasureTime(() =>
                {{CLASS_NAME}}.{{METHOD_NAME}}(testData));

            Console.WriteLine($"Execution time: {time.TotalMilliseconds:F3}ms");
            Console.WriteLine($"Result: {result}");
        }
    }
}
```

### **Class-Based Template**

```csharp
using System;
using System.Collections.Generic;
using System.Text;

namespace AlgorithmsAndDataStructures
{
    /// <summary>
    /// {{CLASS_DESCRIPTION}}
    ///
    /// Time Complexity:
    ///   - Insert: O({{INSERT_COMPLEXITY}})
    ///   - Search: O({{SEARCH_COMPLEXITY}})
    ///   - Delete: O({{DELETE_COMPLEXITY}})
    ///
    /// Space Complexity: O({{SPACE_COMPLEXITY}})
    /// </summary>
    /// <typeparam name="T">The type of elements in the data structure</typeparam>
    public class {{CLASS_NAME}}<T> where T : IComparable<T>
    {
        private {{INTERNAL_TYPE}} {{internalField}};

        /// <summary>
        /// Gets the number of elements in the data structure
        /// </summary>
        public int Count { get; private set; }

        /// <summary>
        /// Gets a value indicating whether the data structure is empty
        /// </summary>
        public bool IsEmpty => Count == 0;

        /// <summary>
        /// Initializes a new instance of the {{CLASS_NAME}} class
        /// </summary>
        /// <param name="{{INIT_PARAMETER}}">{{INIT_PARAMETER_DESCRIPTION}}</param>
        public {{CLASS_NAME}}({{INIT_PARAMETER_TYPE}} {{INIT_PARAMETER}} = {{DEFAULT_VALUE}})
        {
            this.{{internalField}} = {{INITIAL_VALUE}};
            Count = 0;
        }

        /// <summary>
        /// {{PRIMARY_METHOD_DESCRIPTION}}
        /// Time Complexity: O({{METHOD_COMPLEXITY}})
        /// </summary>
        /// <param name="{{METHOD_PARAMETER}}">{{METHOD_PARAMETER_DESCRIPTION}}</param>
        /// <returns>{{METHOD_RETURN_DESCRIPTION}}</returns>
        public {{METHOD_RETURN_TYPE}} {{PRIMARY_METHOD}}({{METHOD_PARAMETER_TYPE}} {{METHOD_PARAMETER}})
        {
            // TODO: Implement method
            return {{METHOD_DEFAULT_RETURN}};
        }

        /// <summary>
        /// Returns a string representation of the data structure
        /// </summary>
        /// <returns>String representation</returns>
        public override string ToString()
        {
            var sb = new StringBuilder();
            sb.Append($"{{CLASS_NAME}}<{typeof(T).Name}>[");
            // TODO: Add elements representation
            sb.Append("]");
            return sb.ToString();
        }
    }
}
```

---

## 🔧 Template Usage Guide

### **Step 1: Choose Template**

Select the appropriate template based on:

- **Language**: Python, JavaScript, or C#
- **Structure**: Function-based or class-based
- **Complexity**: Basic algorithm or data structure

### **Step 2: Replace Variables**

Replace all `{{VARIABLE}}` placeholders with actual content:

**Common Variables**:

- `{{ALGORITHM_NAME}}` - Name of algorithm/function
- `{{CLASS_NAME}}` - Name of class
- `{{ALGORITHM_DESCRIPTION}}` - Brief description
- `{{TIME_COMPLEXITY}}` - Big-O time complexity
- `{{SPACE_COMPLEXITY}}` - Big-O space complexity
- `{{PARAMETERS}}` - Function parameters
- `{{RETURN_TYPE}}` - Return type
- `{{TEST_INPUT}}` - Example test input
- `{{EXPECTED_OUTPUT}}` - Expected test output

### **Step 3: Implement Logic**

Replace `// TODO: Implement` comments with actual algorithm logic.

### **Step 4: Add Tests**

Fill in test cases with real data and expected outcomes.

### **Step 5: Validate**

- Ensure code compiles/runs
- Verify all placeholders are replaced
- Test with actual data
- Check documentation completeness

---

## 📋 Template Checklist

### **Before Use**

- [ ] Selected appropriate template for language and structure
- [ ] Identified all variables to replace
- [ ] Gathered example inputs and outputs
- [ ] Understood algorithm complexity

### **During Implementation**

- [ ] Replaced all `{{VARIABLE}}` placeholders
- [ ] Implemented core algorithm logic
- [ ] Added comprehensive test cases
- [ ] Included error handling

### **After Implementation**

- [ ] Code compiles and runs successfully
- [ ] All tests pass
- [ ] Documentation is complete and accurate
- [ ] Performance characteristics match expectations

---

## 🔄 Maintenance Notes

- **Template Version**: 1.0
- **Last Updated**: July 7, 2025
- **Languages Supported**: Python 3.9+, JavaScript ES6+, C# .NET 6+
- **Next Review**: After Phase 1 pilot

_These templates eliminate code duplication across 15+ curriculum files while ensuring consistency and quality._
