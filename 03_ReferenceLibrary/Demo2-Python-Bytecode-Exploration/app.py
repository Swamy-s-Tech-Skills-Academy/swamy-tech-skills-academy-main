# app.py
import os
from utils import add_numbers, multiply_numbers, format_message
from math_operations import calculate_circle_area, calculate_factorial, get_square_root


def greet(name):
    """Greet a person with a formatted message."""
    greeting = f"Hello, {name}! {os.getenv('GREETING_SUFFIX', 'Welcome to Demo2!')}"
    return format_message(greeting)


def demonstrate_calculations():
    """Demonstrate various calculations using imported modules."""
    print("=== Math Demonstrations ===")

    # Basic arithmetic
    result1 = add_numbers(15, 25)
    result2 = multiply_numbers(8, 7)
    print(f"15 + 25 = {result1}")
    print(f"8 × 7 = {result2}")

    # Circle area
    radius = 5
    area = calculate_circle_area(radius)
    print(f"Area of circle with radius {radius}: {area:.2f}")

    # Factorial
    number = 6
    factorial = calculate_factorial(number)
    print(f"Factorial of {number}: {factorial}")

    # Square root
    sqrt_num = 64
    sqrt_result = get_square_root(sqrt_num)
    print(f"Square root of {sqrt_num}: {sqrt_result}")


def main():
    """Main function to run the demo."""
    print(greet("World"))
    print()
    demonstrate_calculations()


if __name__ == "__main__":
    main()
