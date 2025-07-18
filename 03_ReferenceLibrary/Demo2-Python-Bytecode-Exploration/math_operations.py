# math_operations.py
import math


def calculate_circle_area(radius):
    """Calculate the area of a circle."""
    return math.pi * radius ** 2


def calculate_factorial(n):
    """Calculate the factorial of a number."""
    if n < 0:
        raise ValueError("Factorial is not defined for negative numbers")
    return math.factorial(n)


def get_square_root(number):
    """Get the square root of a number."""
    if number < 0:
        raise ValueError("Cannot calculate square root of negative number")
    return math.sqrt(number)
