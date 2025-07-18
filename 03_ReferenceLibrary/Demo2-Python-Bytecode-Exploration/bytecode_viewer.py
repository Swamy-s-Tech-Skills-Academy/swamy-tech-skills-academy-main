#!/usr/bin/env python3
"""
Bytecode Viewer - A comprehensive tool for viewing Python bytecode
"""

import dis
import marshal
import os
import sys
import struct
import importlib.util


def view_function_bytecode(module_name, function_name=None):
    """
    View bytecode of a specific function or entire module.

    Args:
        module_name (str): Name of the module to import
        function_name (str, optional): Name of specific function to disassemble
    """
    try:
        # Import the module
        module = __import__(module_name)

        print(f"=== Bytecode for module '{module_name}' ===")

        if function_name:
            # Disassemble specific function
            if hasattr(module, function_name):
                func = getattr(module, function_name)
                print(f"\nFunction: {function_name}")
                print("-" * 50)
                dis.dis(func)
            else:
                print(
                    f"Function '{function_name}' not found in module '{module_name}'")
        else:
            # Disassemble entire module
            dis.dis(module)

    except ImportError as e:
        print(f"Error importing module '{module_name}': {e}")
    except Exception as e:
        print(f"Error: {e}")


def view_pyc_file(pyc_file_path):
    """
    View bytecode directly from a .pyc file.

    Args:
        pyc_file_path (str): Path to the .pyc file
    """
    try:
        with open(pyc_file_path, 'rb') as f:
            # Read magic number
            magic = f.read(4)
            print(f"Magic number: {magic.hex()}")

            # Read flags (Python 3.7+)
            flags = f.read(4)
            print(f"Flags: {struct.unpack('<I', flags)[0]}")

            # Read timestamp
            timestamp = f.read(4)
            print(f"Timestamp: {struct.unpack('<I', timestamp)[0]}")

            # Read size
            size = f.read(4)
            print(f"Size: {struct.unpack('<I', size)[0]}")

            # Load code object
            code = marshal.load(f)

            print(f"\n=== Bytecode from {pyc_file_path} ===")
            print("-" * 60)
            dis.dis(code)

    except FileNotFoundError:
        print(f"File not found: {pyc_file_path}")
    except Exception as e:
        print(f"Error reading .pyc file: {e}")


def analyze_function_detailed(func):
    """
    Provide detailed analysis of a function's bytecode.

    Args:
        func: Function object to analyze
    """
    code = func.__code__

    print(f"=== Detailed Analysis: {func.__name__} ===")
    print(f"Function name: {func.__name__}")
    print(f"Module: {func.__module__}")
    print(f"File: {code.co_filename}")
    print(f"Line number: {code.co_firstlineno}")
    print(f"Argument count: {code.co_argcount}")
    print(f"Positional-only args: {code.co_posonlyargcount}")
    print(f"Keyword-only args: {code.co_kwonlyargcount}")
    print(f"Local variables: {len(code.co_varnames)}")
    print(f"Stack size: {code.co_stacksize}")
    print(f"Flags: {code.co_flags}")

    print(f"\nConstants: {code.co_consts}")
    print(f"Names: {code.co_names}")
    print(f"Variable names: {code.co_varnames}")
    print(f"Free variables: {code.co_freevars}")
    print(f"Cell variables: {code.co_cellvars}")

    # Count instruction types
    instructions = list(dis.get_instructions(func))
    instruction_counts = {}
    for instr in instructions:
        instruction_counts[instr.opname] = instruction_counts.get(
            instr.opname, 0) + 1

    print(f"\nInstruction counts:")
    for opname, count in sorted(instruction_counts.items()):
        print(f"  {opname}: {count}")

    print(f"\nTotal instructions: {len(instructions)}")

    print(f"\n=== Bytecode ===")
    print("-" * 40)
    dis.dis(func)


def compare_functions(*functions):
    """
    Compare bytecode of multiple functions.

    Args:
        *functions: Variable number of function objects to compare
    """
    print("=== Function Comparison ===")

    for i, func in enumerate(functions, 1):
        print(f"\n--- Function {i}: {func.__name__} ---")

        # Get instruction count
        instructions = list(dis.get_instructions(func))
        print(f"Instructions: {len(instructions)}")

        # Get stack size
        print(f"Stack size: {func.__code__.co_stacksize}")

        # Show bytecode
        dis.dis(func)
        print("-" * 50)


def find_pyc_files(directory="."):
    """
    Find all .pyc files in a directory.

    Args:
        directory (str): Directory to search (default: current directory)
    """
    pyc_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.pyc'):
                pyc_files.append(os.path.join(root, file))
    return pyc_files


def main():
    """Main function to demonstrate bytecode viewing capabilities."""
    print("=== Python Bytecode Viewer Demo ===\n")

    # 1. View bytecode from current modules
    print("1. Viewing bytecode from utils module:")
    view_function_bytecode('utils', 'add_numbers')

    print("\n" + "="*80 + "\n")

    # 2. View bytecode from .pyc files
    print("2. Viewing bytecode from .pyc files:")
    pyc_files = find_pyc_files()
    if pyc_files:
        print(f"Found {len(pyc_files)} .pyc files:")
        for pyc_file in pyc_files:
            print(f"  - {pyc_file}")

        # View the first .pyc file
        print(f"\nAnalyzing: {pyc_files[0]}")
        view_pyc_file(pyc_files[0])
    else:
        print("No .pyc files found. Run 'python app.py' first to generate them.")

    print("\n" + "="*80 + "\n")

    # 3. Detailed function analysis
    print("3. Detailed function analysis:")
    try:
        import utils
        analyze_function_detailed(utils.add_numbers)
    except ImportError:
        print("utils module not found. Make sure you're in the correct directory.")

    print("\n" + "="*80 + "\n")

    # 4. Function comparison
    print("4. Function comparison:")

    # Define test functions
    def loop_version(items):
        result = []
        for item in items:
            result.append(item * 2)
        return result

    def comprehension_version(items):
        return [item * 2 for item in items]

    compare_functions(loop_version, comprehension_version)


if __name__ == "__main__":
    main()
