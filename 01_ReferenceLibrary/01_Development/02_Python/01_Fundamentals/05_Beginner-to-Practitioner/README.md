# 05_Beginner-to-Practitioner - Clean Code Principles

**Learning Level**: Intermediate  
**Prerequisites**: Completed 04_Learner-to-Beginner (OOP fundamentals)  
**Estimated Time**: 5-6 weeks

## 🎯 Learning Objectives

- **Apply SOLID principles** in Python code design
- **Write clean, readable code** following PEP 8 standards
- **Implement effective error handling** and logging
- **Use type hints and documentation** for better code quality
- **Achieve the milestone**: "I write clean code!"

## 📋 Core Concepts

### SOLID Principles in Python

```python
# Single Responsibility Principle
class EmailValidator:
    def validate(self, email):
        return "@" in email and "." in email

class EmailSender:
    def send(self, email, message):
        print(f"Sending '{message}' to {email}")

# Open/Closed Principle
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self):
        pass

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    def area(self):
        return self.width * self.height

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius
    
    def area(self):
        import math
        return math.pi * self.radius ** 2
```

### Error Handling and Logging

```python
import logging
from typing import Optional, List

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class DataProcessor:
    def __init__(self):
        self.data: List[dict] = []
    
    def load_data(self, filename: str) -> bool:
        """Load data from file with proper error handling."""
        try:
            with open(filename, 'r') as file:
                import json
                self.data = json.load(file)
                logger.info(f"Successfully loaded {len(self.data)} records")
                return True
        except FileNotFoundError:
            logger.error(f"File not found: {filename}")
            return False
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in {filename}: {e}")
            return False
        except Exception as e:
            logger.error(f"Unexpected error loading {filename}: {e}")
            return False
    
    def process_record(self, record: dict) -> Optional[dict]:
        """Process a single record with validation."""
        try:
            required_fields = ['name', 'age', 'email']
            for field in required_fields:
                if field not in record:
                    raise ValueError(f"Missing required field: {field}")
            
            if record['age'] < 0:
                raise ValueError("Age cannot be negative")
            
            # Process the record
            processed = {
                'name': record['name'].strip().title(),
                'age': int(record['age']),
                'email': record['email'].lower().strip(),
                'processed_at': datetime.now().isoformat()
            }
            
            logger.debug(f"Processed record for {processed['name']}")
            return processed
            
        except (ValueError, TypeError) as e:
            logger.warning(f"Invalid record data: {e}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error processing record: {e}")
            return None
```

## 📝 Practice Projects

### Project 1: Clean Banking System

Redesign a banking system using SOLID principles with proper error handling and logging.

### Project 2: File Processing Pipeline

Build a data processing pipeline with clean code practices, type hints, and comprehensive testing.

### Project 3: Configuration Manager

Create a configuration management system following clean code principles.

## 🎯 Learning Milestones

### Week 1-2: Clean Code Fundamentals

- [ ] Apply PEP 8 style guidelines
- [ ] Implement proper naming conventions
- [ ] Write clear, self-documenting code

### Week 3-4: SOLID Principles

- [ ] Apply Single Responsibility Principle
- [ ] Implement Open/Closed Principle
- [ ] Use Dependency Inversion

### Week 5-6: Error Handling and Testing

- [ ] Implement comprehensive error handling
- [ ] Add logging and monitoring
- [ ] Write unit tests for code validation

## 🔗 Related Topics

### Prerequisites

- [04_Learner-to-Beginner](../04_Learner-to-Beginner/) - OOP fundamentals

### Enables

- [06_Practitioner-to-Skilled-Coder](../06_Practitioner-to-Skilled-Coder/) - Design patterns

---

**Last Updated**: September 7, 2025  
**Maintained By**: STSA Learning System
