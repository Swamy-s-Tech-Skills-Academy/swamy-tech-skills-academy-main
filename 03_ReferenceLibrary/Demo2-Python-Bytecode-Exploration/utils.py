# utils.py
def add_numbers(a, b):
    """Add two numbers together."""
    return a + b


def multiply_numbers(a, b):
    """Multiply two numbers together."""
    return a * b


def format_message(message):
    """Format a message with decorative borders."""
    border = "=" * (len(message) + 4)
    return f"{border}\n  {message}  \n{border}"
