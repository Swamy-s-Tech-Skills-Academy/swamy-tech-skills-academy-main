#!/usr/bin/env python3
"""
Simple command-line tool to view bytecode from .pyc files
Usage: python view_pyc.py <pyc_file>
"""

import sys
import marshal
import dis
import struct
import os


def view_pyc_bytecode(pyc_file_path):
    """View bytecode from a .pyc file with detailed information."""
    if not os.path.exists(pyc_file_path):
        print(f"Error: File '{pyc_file_path}' not found.")
        return

    if not pyc_file_path.endswith('.pyc'):
        print(f"Warning: '{pyc_file_path}' doesn't appear to be a .pyc file.")

    try:
        with open(pyc_file_path, 'rb') as f:
            # Read header information
            magic = f.read(4)
            flags = f.read(4)
            timestamp = f.read(4)
            size = f.read(4)

            print(f"=== .pyc File Information ===")
            print(f"File: {pyc_file_path}")
            print(f"Magic number: {magic.hex()}")
            print(f"Flags: {struct.unpack('<I', flags)[0]}")
            print(f"Timestamp: {struct.unpack('<I', timestamp)[0]}")
            print(f"Size: {struct.unpack('<I', size)[0]} bytes")

            # Load and disassemble the code object
            code = marshal.load(f)

            print(f"\n=== Bytecode Disassembly ===")
            dis.dis(code)

    except Exception as e:
        print(f"Error reading .pyc file: {e}")


def list_pyc_files(directory="."):
    """List all .pyc files in the given directory."""
    pyc_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.pyc'):
                pyc_files.append(os.path.join(root, file))
    return pyc_files


def main():
    """Main function to handle command-line arguments."""
    if len(sys.argv) != 2:
        print("Usage: python view_pyc.py <pyc_file>")
        print("       python view_pyc.py --list    (to list available .pyc files)")
        sys.exit(1)

    arg = sys.argv[1]

    if arg == "--list":
        pyc_files = list_pyc_files()
        if pyc_files:
            print("Available .pyc files:")
            for pyc_file in pyc_files:
                print(f"  {pyc_file}")
        else:
            print("No .pyc files found in current directory.")
    else:
        view_pyc_bytecode(arg)


if __name__ == "__main__":
    main()
