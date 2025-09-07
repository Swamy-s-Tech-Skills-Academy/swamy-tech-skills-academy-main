# 03_Novice-to-Learner - Integration and Tool Building

**Learning Level**: Beginner to Intermediate  
**Prerequisites**: Completed 02_Nerd-to-Novice (functions, algorithms, file operations)  
**Estimated Time**: 4-5 weeks (15-20 hours per week)

## 🎯 Learning Objectives

By the end of this level, you will:

- **Work with advanced data structures** (lists, dictionaries, sets, tuples)
- **Build command-line tools** with argument parsing and user interaction
- **Process and manipulate data** from various sources (CSV, JSON, text files)
- **Create modular programs** with proper code organization
- **Handle complex data transformations** and analysis tasks
- **Achieve the milestone**: "I can build tools!" with confidence

---

## 📋 Core Concepts

### Advanced Data Structures Mastery

```python
# Working with nested data structures
students = {
    'john': {
        'grades': [85, 92, 78, 96],
        'subjects': ['math', 'science', 'english', 'history'],
        'contact': {'email': 'john@email.com', 'phone': '555-0123'}
    },
    'sarah': {
        'grades': [91, 87, 94, 89],
        'subjects': ['math', 'science', 'english', 'history'],
        'contact': {'email': 'sarah@email.com', 'phone': '555-0456'}
    }
}

# Data processing with comprehensions
def calculate_student_averages(students):
    """Calculate average grade for each student."""
    return {
        name: sum(data['grades']) / len(data['grades'])
        for name, data in students.items()
    }

# Advanced data filtering and transformation
def get_top_students(students, min_average=90):
    """Get students with average above threshold."""
    averages = calculate_student_averages(students)
    return [
        name for name, avg in averages.items() 
        if avg >= min_average
    ]

print(f"Student averages: {calculate_student_averages(students)}")
print(f"Top students: {get_top_students(students)}")
```

### Command-Line Tool Development

```python
import argparse
import sys
from pathlib import Path

def create_file_analyzer():
    """Create a command-line file analysis tool."""
    parser = argparse.ArgumentParser(
        description='Analyze text files for word count, line count, and statistics'
    )
    parser.add_argument('filename', help='Path to the file to analyze')
    parser.add_argument('-v', '--verbose', action='store_true', 
                       help='Show detailed analysis')
    parser.add_argument('-o', '--output', help='Output file for results')
    parser.add_argument('--format', choices=['txt', 'json'], default='txt',
                       help='Output format')
    
    return parser

def analyze_file(filename, verbose=False):
    """Analyze a text file and return statistics."""
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            content = file.read()
            lines = content.split('\n')
            words = content.split()
            
        stats = {
            'filename': filename,
            'character_count': len(content),
            'word_count': len(words),
            'line_count': len(lines),
            'average_line_length': sum(len(line) for line in lines) / len(lines),
            'longest_line': max(lines, key=len) if lines else "",
            'word_frequency': get_word_frequency(words) if verbose else {}
        }
        
        return stats
        
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        return None
    except Exception as e:
        print(f"Error analyzing file: {e}")
        return None

def get_word_frequency(words):
    """Calculate word frequency distribution."""
    frequency = {}
    for word in words:
        word = word.lower().strip('.,!?";')
        frequency[word] = frequency.get(word, 0) + 1
    return dict(sorted(frequency.items(), key=lambda x: x[1], reverse=True)[:10])

# Main CLI application
if __name__ == "__main__":
    parser = create_file_analyzer()
    args = parser.parse_args()
    
    stats = analyze_file(args.filename, args.verbose)
    if stats:
        if args.format == 'json':
            import json
            output = json.dumps(stats, indent=2)
        else:
            output = format_text_output(stats)
        
        if args.output:
            with open(args.output, 'w') as f:
                f.write(output)
            print(f"Results saved to {args.output}")
        else:
            print(output)
```

---

## 🔧 Key Skills Development

### 1. Data Processing and Transformation

```python
import csv
import json
from datetime import datetime

def process_sales_data(csv_file):
    """Process sales data from CSV and generate insights."""
    sales_data = []
    
    with open(csv_file, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            # Data cleaning and transformation
            sales_data.append({
                'date': datetime.strptime(row['date'], '%Y-%m-%d'),
                'product': row['product'].strip().title(),
                'quantity': int(row['quantity']),
                'price': float(row['price']),
                'revenue': int(row['quantity']) * float(row['price'])
            })
    
    return sales_data

def generate_sales_report(sales_data):
    """Generate comprehensive sales analysis."""
    report = {
        'total_revenue': sum(sale['revenue'] for sale in sales_data),
        'total_quantity': sum(sale['quantity'] for sale in sales_data),
        'product_performance': {},
        'daily_sales': {}
    }
    
    # Product performance analysis
    for sale in sales_data:
        product = sale['product']
        if product not in report['product_performance']:
            report['product_performance'][product] = {
                'quantity': 0, 'revenue': 0, 'transactions': 0
            }
        
        report['product_performance'][product]['quantity'] += sale['quantity']
        report['product_performance'][product]['revenue'] += sale['revenue']
        report['product_performance'][product]['transactions'] += 1
    
    # Daily sales analysis
    for sale in sales_data:
        date_str = sale['date'].strftime('%Y-%m-%d')
        if date_str not in report['daily_sales']:
            report['daily_sales'][date_str] = {'revenue': 0, 'transactions': 0}
        
        report['daily_sales'][date_str]['revenue'] += sale['revenue']
        report['daily_sales'][date_str]['transactions'] += 1
    
    return report

# Usage example
sales_data = process_sales_data('sales.csv')
report = generate_sales_report(sales_data)
print(f"Total Revenue: ${report['total_revenue']:,.2f}")
```

### 2. Modular Program Design

```python
# config.py - Configuration management
import json
from pathlib import Path

class Config:
    """Application configuration manager."""
    
    def __init__(self, config_file='config.json'):
        self.config_file = Path(config_file)
        self.settings = self.load_config()
    
    def load_config(self):
        """Load configuration from file or create defaults."""
        if self.config_file.exists():
            with open(self.config_file, 'r') as f:
                return json.load(f)
        else:
            return self.create_default_config()
    
    def create_default_config(self):
        """Create default configuration."""
        defaults = {
            'data_directory': './data',
            'output_directory': './output',
            'file_formats': ['csv', 'json', 'txt'],
            'max_file_size': '10MB',
            'logging_level': 'INFO'
        }
        self.save_config(defaults)
        return defaults
    
    def save_config(self, settings=None):
        """Save configuration to file."""
        config_to_save = settings or self.settings
        with open(self.config_file, 'w') as f:
            json.dump(config_to_save, f, indent=2)
    
    def get(self, key, default=None):
        """Get configuration value."""
        return self.settings.get(key, default)
    
    def set(self, key, value):
        """Set configuration value."""
        self.settings[key] = value
        self.save_config()

# utils.py - Utility functions
def validate_file_path(file_path, allowed_extensions=None):
    """Validate file path and extension."""
    path = Path(file_path)
    
    if not path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")
    
    if allowed_extensions:
        if path.suffix.lower() not in allowed_extensions:
            raise ValueError(f"Invalid file type. Allowed: {allowed_extensions}")
    
    return path

def create_output_directory(directory):
    """Create output directory if it doesn't exist."""
    path = Path(directory)
    path.mkdir(parents=True, exist_ok=True)
    return path

def format_file_size(size_bytes):
    """Format file size in human-readable format."""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f} TB"
```

---

## 📝 Practice Projects

### Project 1: Personal Expense Tracker

Build a command-line expense tracking tool:

- CSV data import/export capabilities
- Category-based expense organization
- Monthly and yearly spending reports
- Budget tracking and alerts
- Data visualization with ASCII charts

### Project 2: Log File Analyzer

Create a log analysis tool:

- Parse different log formats (Apache, Nginx, custom)
- Extract key metrics (errors, response times, traffic patterns)
- Generate summary reports
- Filter logs by date range, severity, or patterns
- Export analysis results in multiple formats

### Project 3: Contact Management System

Develop a contact manager:

- Store contacts in JSON format
- Search and filter capabilities
- Import from CSV files
- Export to various formats
- Backup and restore functionality

### Project 4: Simple Task Manager

Build a task management CLI tool:

- Add, edit, delete, and list tasks
- Priority levels and due dates
- Mark tasks as complete
- Filter by status, priority, or date
- Generate productivity reports

---

## 🎯 Learning Milestones

### Week 1: Data Structure Mastery

- [ ] Master nested dictionaries and lists
- [ ] Implement data comprehensions effectively
- [ ] Practice data filtering and transformation
- [ ] Complete advanced data structure exercises

### Week 2: File Processing and Data Analysis

- [ ] Process CSV and JSON files
- [ ] Implement data cleaning and validation
- [ ] Create data analysis functions
- [ ] Build data processing pipeline

### Week 3: Command-Line Interface Development

- [ ] Use argparse for CLI arguments
- [ ] Implement user-friendly interfaces
- [ ] Add error handling and validation
- [ ] Create modular CLI applications

### Week 4: Integration and Tool Building

- [ ] Combine all concepts in complete tools
- [ ] Implement configuration management
- [ ] Add logging and error reporting
- [ ] Complete comprehensive CLI tool project

---

## 🚀 Next Steps

### Preparation for Level 4 (Learner-to-Beginner)

To succeed in the next level, ensure you can:

- [ ] **Process complex data structures** efficiently
- [ ] **Build command-line tools** with proper interfaces
- [ ] **Organize code into modules** effectively
- [ ] **Handle data from multiple sources** reliably
- [ ] **Create user-friendly applications** with error handling

### Skills That Will Be Built Upon

- **Modular Design**: Code organization (expanded to OOP principles)
- **Data Processing**: File and data handling (expanded to database integration)
- **CLI Development**: User interfaces (expanded to GUI applications)
- **Error Handling**: Robust validation (expanded to exception hierarchies)

## 🔗 Related Topics

### Prerequisites

- [02_Nerd-to-Novice](../02_Nerd-to-Novice/) - Functions, algorithms, file operations

### Builds Upon

- Function design and implementation
- File operations and data processing
- Basic algorithm implementation
- Systematic debugging approaches

### Enables

- [04_Learner-to-Beginner](../04_Learner-to-Beginner/) - Object-oriented programming
- Database integration and API development
- GUI application development
- Web scraping and automation

### Cross-References

- **Software Design Principles**: Modular design and separation of concerns
- **Data Science Track**: Data processing and analysis foundations
- **Professional Practice**: CLI tool development and configuration management

---

**Last Updated**: September 7, 2025  
**Next Review**: December 7, 2025  
**Maintained By**: STSA Learning System
