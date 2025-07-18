# 🔍 Demo2 - Python Bytecode Exploration

**Practical examples and tools for understanding Python bytecode and `.pyc` files**

---

## 📁 Files Overview

| File                            | Purpose                                                                      | Key Features                                          |
| ------------------------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------- |
| **`app.py`**                    | Main application that imports local modules, triggering bytecode compilation | Module imports, function calls, environment variables |
| **`utils.py`**                  | Utility functions for basic operations and message formatting                | Simple arithmetic, string formatting                  |
| **`math_operations.py`**        | Mathematical operations using the math module                                | Circle area, factorial, square root calculations      |
| **`bytecode_viewer.py`**        | Comprehensive bytecode analysis tool                                         | Function analysis, .pyc file viewing, comparisons     |
| **`view_pyc.py`**               | Simple command-line tool to view .pyc files                                  | Header parsing, bytecode disassembly                  |
| **`BYTECODE_DOCUMENTATION.md`** | Complete documentation on bytecode generation and viewing                    | 📍 **Links to main documentation**                    |

---

## 🎯 Key Concepts Demonstrated

### 1. Bytecode Generation

- **Automatic**: Generated when importing modules
- **Manual**: Using `py_compile`, `compileall`, or command-line tools
- **Optimization levels**: Level 0 (default), Level 1 (-O), Level 2 (-OO)

### 2. .pyc Files

- **Location**: `__pycache__/` directory (Python 3.2+)
- **Naming**: `filename.cpython-<version>.pyc`
- **Structure**: Magic number, flags, timestamp, size, bytecode
- **Purpose**: Faster loading by skipping compilation

### 3. Viewing Bytecode

- **Using `dis` module**: Standard Python approach
- **From .pyc files**: Direct bytecode inspection
- **Analysis tools**: Custom scripts for detailed examination

---

## 🚀 Running the Examples

### Basic Usage

```bash
# Run the main app (generates .pyc files)
python app.py

# View available .pyc files
python view_pyc.py --list

# View specific .pyc file
python view_pyc.py "__pycache__\utils.cpython-313.pyc"

# Run comprehensive bytecode analysis
python bytecode_viewer.py
```

### Command Line Bytecode Viewing

```bash
# View bytecode of a Python file
python -m dis utils.py

# View bytecode of a specific function
python -c "import dis; import utils; dis.dis(utils.add_numbers)"

# Compile with optimization
python -O app.py    # Level 1 optimization
python -OO app.py   # Level 2 optimization
```

---

## 🔍 Understanding the Output

### Common Bytecode Instructions

| Instruction        | Description                                    |
| ------------------ | ---------------------------------------------- |
| **`LOAD_FAST`**    | Load local variable                            |
| **`LOAD_GLOBAL`**  | Load global variable                           |
| **`LOAD_CONST`**   | Load constant value                            |
| **`BINARY_OP`**    | Perform binary operation (add, multiply, etc.) |
| **`CALL`**         | Call a function                                |
| **`RETURN_VALUE`** | Return from function                           |

### .pyc File Information

- **Magic number**: Python version identifier (e.g., `f30d0d0a` for Python 3.13)
- **Flags**: Compilation flags and optimization level
- **Timestamp**: When the source file was last modified
- **Size**: Size of the original source file

---

## 💡 Practical Applications

1. **Performance Analysis**: Compare bytecode efficiency between different implementations
2. **Debugging**: Understand how Python interprets your code
3. **Optimization**: Identify bottlenecks in code execution
4. **Learning**: Understand Python's internal workings

---

## 🔗 Integration with Your Learning

### Connects to

- **Python-Bytecode-Advanced.md**: Complete theoretical documentation
- **Python-Compilation-and-Interpretation.md**: Foundation concepts
- **Week-01-OOP.md**: Practical Python application in OOP context

### Supports

- **Hands-on Learning**: Interactive bytecode exploration
- **Performance Understanding**: See how Python optimizes code
- **Debugging Skills**: Understand code execution at bytecode level

---

## 🎯 Next Steps

- Experiment with different code patterns and compare their bytecode
- Try optimization levels and see the differences
- Use the analysis tools to understand complex functions
- Explore advanced bytecode manipulation techniques

**📍 For complete documentation, see `Python-Bytecode-Advanced.md` in the Reference Library.**

---

**📅 Created**: July 18, 2025  
**🎯 Purpose**: Hands-on bytecode exploration and learning  
**📚 Learning Context**: Practical application of Python internals knowledge  
**🔧 Tools**: Interactive Python scripts for bytecode analysis
