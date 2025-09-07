# 02_Nerd-to-Novice - Problem Solving Foundations

**Learning Level**: Beginner  
**Prerequisites**: Completed 01_Noob-to-Nerd (basic Python syntax and operations)  
**Estimated Time**: 3-4 weeks (15-20 hours per week)

## 🎯 Learning Objectives

By the end of this level, you will:

- **Think algorithmically** and break down complex problems into smaller steps
- **Write functions** effectively with proper parameters, return values, and documentation
- **Implement basic algorithms** for searching, sorting, and data manipulation
- **Handle user input and file operations** for practical program interaction
- **Debug systematically** using print statements and logical reasoning
- **Achieve the milestone**: "I can solve problems!" with confidence

---

## 📋 Core Concepts

### Problem Decomposition

Learn to break complex problems into manageable parts:

```text
🧩 Problem-Solving Process

1. Understand the Problem
   ├── Read requirements carefully
   ├── Identify inputs and expected outputs
   └── Ask clarifying questions

2. Design the Solution
   ├── Break into smaller sub-problems
   ├── Plan the algorithm step-by-step
   └── Consider edge cases

3. Implement and Test
   ├── Write code incrementally
   ├── Test each component
   └── Integrate and validate

4. Refine and Optimize
   ├── Review for improvements
   ├── Handle edge cases
   └── Add error handling
```

### Function Design Principles

```python
# Example: Well-designed function
def calculate_bmi(weight_kg, height_m):
    """
    Calculate Body Mass Index (BMI) from weight and height.
    
    Args:
        weight_kg (float): Weight in kilograms
        height_m (float): Height in meters
    
    Returns:
        float: BMI value rounded to 2 decimal places
    
    Raises:
        ValueError: If weight or height is negative or zero
    """
    if weight_kg <= 0 or height_m <= 0:
        raise ValueError("Weight and height must be positive numbers")
    
    bmi = weight_kg / (height_m ** 2)
    return round(bmi, 2)

# Function with clear purpose and proper documentation
def categorize_bmi(bmi):
    """Categorize BMI value into health categories."""
    if bmi < 18.5:
        return "Underweight"
    elif bmi < 25:
        return "Normal weight"
    elif bmi < 30:
        return "Overweight"
    else:
        return "Obese"

# Example usage
weight = 70.0  # kg
height = 1.75  # meters
bmi = calculate_bmi(weight, height)
category = categorize_bmi(bmi)
print(f"BMI: {bmi}, Category: {category}")
```

---

## 🔧 Key Skills Development

### 1. Algorithm Implementation

#### Basic Search Algorithms

```python
def linear_search(numbers, target):
    """Find the index of target in numbers list."""
    for i, num in enumerate(numbers):
        if num == target:
            return i
    return -1

def binary_search(sorted_numbers, target):
    """Binary search in a sorted list."""
    left, right = 0, len(sorted_numbers) - 1
    
    while left <= right:
        mid = (left + right) // 2
        if sorted_numbers[mid] == target:
            return mid
        elif sorted_numbers[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1

# Example usage
numbers = [1, 3, 5, 7, 9, 11, 13]
print(f"Linear search for 7: {linear_search(numbers, 7)}")
print(f"Binary search for 7: {binary_search(numbers, 7)}")
```

#### Basic Sorting Algorithms

```python
def bubble_sort(numbers):
    """Sort numbers using bubble sort algorithm."""
    n = len(numbers)
    for i in range(n):
        # Flag to optimize - stop if no swaps occurred
        swapped = False
        for j in range(0, n - i - 1):
            if numbers[j] > numbers[j + 1]:
                numbers[j], numbers[j + 1] = numbers[j + 1], numbers[j]
                swapped = True
        if not swapped:
            break
    return numbers

def selection_sort(numbers):
    """Sort numbers using selection sort algorithm."""
    n = len(numbers)
    for i in range(n):
        min_idx = i
        for j in range(i + 1, n):
            if numbers[j] < numbers[min_idx]:
                min_idx = j
        numbers[i], numbers[min_idx] = numbers[min_idx], numbers[i]
    return numbers

# Example usage
unsorted = [64, 34, 25, 12, 22, 11, 90]
print(f"Bubble sort: {bubble_sort(unsorted.copy())}")
print(f"Selection sort: {selection_sort(unsorted.copy())}")
```

### 2. File Operations and Data Processing

```python
def read_scores_from_file(filename):
    """Read student scores from a text file."""
    scores = []
    try:
        with open(filename, 'r') as file:
            for line in file:
                # Handle different line formats
                line = line.strip()
                if line and line.isdigit():
                    scores.append(int(line))
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        return []
    except ValueError as e:
        print(f"Error reading file: {e}")
        return []
    
    return scores

def calculate_statistics(scores):
    """Calculate basic statistics for a list of scores."""
    if not scores:
        return None
    
    stats = {
        'count': len(scores),
        'total': sum(scores),
        'average': sum(scores) / len(scores),
        'minimum': min(scores),
        'maximum': max(scores),
        'range': max(scores) - min(scores)
    }
    return stats

def write_statistics_report(stats, output_filename):
    """Write statistics report to file."""
    try:
        with open(output_filename, 'w') as file:
            file.write("Student Scores Analysis Report\n")
            file.write("=" * 35 + "\n\n")
            file.write(f"Number of students: {stats['count']}\n")
            file.write(f"Total points: {stats['total']}\n")
            file.write(f"Average score: {stats['average']:.2f}\n")
            file.write(f"Highest score: {stats['maximum']}\n")
            file.write(f"Lowest score: {stats['minimum']}\n")
            file.write(f"Score range: {stats['range']}\n")
        print(f"Report saved to {output_filename}")
    except IOError as e:
        print(f"Error writing to file: {e}")

# Example usage
scores = read_scores_from_file("student_scores.txt")
if scores:
    stats = calculate_statistics(scores)
    write_statistics_report(stats, "score_analysis.txt")
```

### 3. Input Validation and Error Handling

```python
def get_valid_integer(prompt, min_value=None, max_value=None):
    """Get a valid integer from user with optional range checking."""
    while True:
        try:
            value = int(input(prompt))
            if min_value is not None and value < min_value:
                print(f"Value must be at least {min_value}")
                continue
            if max_value is not None and value > max_value:
                print(f"Value must be at most {max_value}")
                continue
            return value
        except ValueError:
            print("Please enter a valid integer.")

def get_valid_choice(prompt, valid_choices):
    """Get a valid choice from a list of options."""
    while True:
        choice = input(prompt).strip().lower()
        if choice in valid_choices:
            return choice
        print(f"Please choose from: {', '.join(valid_choices)}")

# Example usage in a simple calculator
def simple_calculator():
    """Interactive calculator with error handling."""
    print("Simple Calculator")
    print("-" * 20)
    
    num1 = get_valid_integer("Enter first number: ")
    num2 = get_valid_integer("Enter second number: ")
    
    operation = get_valid_choice(
        "Choose operation (+, -, *, /): ", 
        ['+', '-', '*', '/']
    )
    
    if operation == '+':
        result = num1 + num2
    elif operation == '-':
        result = num1 - num2
    elif operation == '*':
        result = num1 * num2
    elif operation == '/':
        if num2 == 0:
            print("Error: Cannot divide by zero!")
            return
        result = num1 / num2
    
    print(f"{num1} {operation} {num2} = {result}")

# Run calculator
simple_calculator()
```

---

## 📝 Practice Projects

### Project 1: Number Guessing Game

Create an enhanced guessing game with:

- Random number generation within user-specified range
- Limited number of attempts
- Hints (higher/lower) after each guess
- Score tracking based on attempts used
- Option to play multiple rounds

### Project 2: Text File Analyzer

Build a program that:

- Reads a text file
- Counts words, lines, and characters
- Finds the most common words
- Calculates average word length
- Generates a summary report

### Project 3: Simple Grade Book

Develop a grade management system that:

- Stores student names and scores
- Calculates letter grades based on numeric scores
- Computes class statistics (average, highest, lowest)
- Saves data to file for persistence
- Allows adding new students and scores

### Project 4: Basic Password Generator

Create a secure password generator that:

- Generates passwords of specified length
- Includes options for uppercase, lowercase, digits, symbols
- Ensures at least one character from each selected category
- Validates password strength
- Saves generated passwords to encrypted file

---

## 🧪 Debugging and Testing

### Systematic Debugging Approach

```python
def debug_example():
    """Example showing debugging techniques."""
    numbers = [1, 2, 3, 4, 5]
    target = 3
    
    # Add debug prints to understand program flow
    print(f"DEBUG: Starting search for {target}")
    print(f"DEBUG: List contains {len(numbers)} numbers: {numbers}")
    
    for i, num in enumerate(numbers):
        print(f"DEBUG: Checking position {i}, value {num}")
        if num == target:
            print(f"DEBUG: Found {target} at position {i}")
            return i
    
    print(f"DEBUG: {target} not found in list")
    return -1

# Testing with assertions
def test_search_function():
    """Test the search function with various inputs."""
    test_cases = [
        ([1, 2, 3, 4, 5], 3, 2),  # (list, target, expected_index)
        ([1, 2, 3, 4, 5], 1, 0),
        ([1, 2, 3, 4, 5], 5, 4),
        ([1, 2, 3, 4, 5], 6, -1),
        ([], 1, -1)
    ]
    
    for i, (numbers, target, expected) in enumerate(test_cases):
        result = linear_search(numbers, target)
        assert result == expected, f"Test {i+1} failed: expected {expected}, got {result}"
        print(f"Test {i+1} passed ✓")

# Run tests
test_search_function()
```

---

## 🎯 Learning Milestones

### Week 1: Function Fundamentals

- [ ] Write functions with parameters and return values
- [ ] Implement proper function documentation
- [ ] Practice function testing and debugging
- [ ] Complete 5 small function-based exercises

### Week 2: Algorithm Implementation

- [ ] Implement basic search algorithms
- [ ] Code simple sorting algorithms
- [ ] Practice algorithm analysis and optimization
- [ ] Complete algorithm comparison project

### Week 3: File Operations and Data Processing

- [ ] Read and write files effectively
- [ ] Process and analyze text data
- [ ] Handle file exceptions gracefully
- [ ] Build a file-based data analysis tool

### Week 4: Problem-Solving Integration

- [ ] Combine all learned concepts in complex projects
- [ ] Practice systematic debugging approaches
- [ ] Implement comprehensive error handling
- [ ] Complete capstone problem-solving project

---

## 🔍 Common Pitfalls and Solutions

### 1. Function Design Issues

❌ **Poor Function Design**:
```python
def do_everything(data):
    # Function that does too many things
    sorted_data = sorted(data)
    total = sum(sorted_data)
    average = total / len(sorted_data)
    print(f"Sorted: {sorted_data}")
    print(f"Average: {average}")
    return sorted_data, total, average
```

✅ **Better Function Design**:
```python
def sort_numbers(numbers):
    """Sort a list of numbers."""
    return sorted(numbers)

def calculate_average(numbers):
    """Calculate average of numbers."""
    return sum(numbers) / len(numbers) if numbers else 0

def display_statistics(numbers):
    """Display statistics for a list of numbers."""
    if not numbers:
        print("No data to display")
        return
    
    sorted_nums = sort_numbers(numbers)
    average = calculate_average(numbers)
    
    print(f"Sorted numbers: {sorted_nums}")
    print(f"Average: {average:.2f}")
```

### 2. Input Validation Problems

❌ **No Input Validation**:
```python
age = int(input("Enter your age: "))  # Crashes on invalid input
```

✅ **Proper Input Validation**:
```python
def get_age():
    while True:
        try:
            age = int(input("Enter your age (0-120): "))
            if 0 <= age <= 120:
                return age
            else:
                print("Age must be between 0 and 120")
        except ValueError:
            print("Please enter a valid number")
```

---

## 🚀 Next Steps

### Preparation for Level 3 (Novice-to-Learner)

To succeed in the next level, ensure you can:

- [ ] **Write clean functions** with single responsibilities
- [ ] **Implement basic algorithms** from memory
- [ ] **Handle file operations** with proper error handling
- [ ] **Debug systematically** using logical approaches
- [ ] **Solve multi-step problems** by breaking them down

### Skills That Will Be Built Upon

- **Data Structures**: Lists and dictionaries (expanded in Level 3)
- **File Operations**: Basic I/O (expanded to APIs and databases)
- **Algorithm Thinking**: Problem decomposition (applied to system integration)
- **Error Handling**: Basic try/except (expanded to robust error management)

## 🔗 Related Topics

### Prerequisites

- [01_Noob-to-Nerd](../01_Noob-to-Nerd/) - Python syntax and basic operations

### Builds Upon

- Variable assignment and basic data types
- Control structures (if/else, loops)
- Basic input/output operations

### Enables

- [03_Novice-to-Learner](../03_Novice-to-Learner/) - Integration and tool building
- Advanced data structure manipulation
- API interaction and system integration

### Cross-References

- **Software Design Principles**: Function design principles
- **Data Science Track**: Data processing and analysis foundations
- **Professional Practice**: Testing and debugging methodologies

---

**Last Updated**: September 7, 2025  
**Next Review**: December 7, 2025  
**Maintained By**: STSA Learning System
