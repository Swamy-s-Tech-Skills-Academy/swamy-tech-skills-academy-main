# 08_Specialist-to-Professional - Third-party Ecosystem

**Learning Level**: Professional  
**Prerequisites**: Completed 07_Skilled-Coder-to-Specialist (Standard Library)  
**Estimated Time**: 10-12 weeks

## 🎯 Learning Objectives

- **Master essential third-party libraries**
- **Integrate multiple libraries effectively**
- **Build production-ready applications**
- **Understand package management and virtual environments**
- **Achieve the milestone**: "I build with the ecosystem!"

## 📋 Core Concepts

### Data Science and Analysis

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, timedelta

class DataAnalyzer:
    def __init__(self, data_source):
        self.df = pd.read_csv(data_source) if isinstance(data_source, str) else data_source
    
    def clean_data(self):
        """Clean and prepare data for analysis."""
        # Remove duplicates
        self.df = self.df.drop_duplicates()
        
        # Handle missing values
        numeric_columns = self.df.select_dtypes(include=[np.number]).columns
        self.df[numeric_columns] = self.df[numeric_columns].fillna(self.df[numeric_columns].median())
        
        # Handle categorical missing values
        categorical_columns = self.df.select_dtypes(include=['object']).columns
        for col in categorical_columns:
            self.df[col] = self.df[col].fillna(self.df[col].mode()[0] if not self.df[col].mode().empty else 'Unknown')
        
        return self
    
    def analyze_trends(self, date_column, value_column, period='M'):
        """Analyze trends over time."""
        self.df[date_column] = pd.to_datetime(self.df[date_column])
        trends = self.df.groupby(pd.Grouper(key=date_column, freq=period))[value_column].agg(['sum', 'mean', 'count'])
        return trends
    
    def create_dashboard(self, output_file='dashboard.png'):
        """Create a comprehensive dashboard."""
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        
        # Distribution plot
        numeric_cols = self.df.select_dtypes(include=[np.number]).columns
        if len(numeric_cols) > 0:
            self.df[numeric_cols[0]].hist(bins=30, ax=axes[0, 0])
            axes[0, 0].set_title(f'Distribution of {numeric_cols[0]}')
        
        # Correlation heatmap
        if len(numeric_cols) > 1:
            corr_matrix = self.df[numeric_cols].corr()
            sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', ax=axes[0, 1])
            axes[0, 1].set_title('Correlation Matrix')
        
        # Time series if date column exists
        date_cols = self.df.select_dtypes(include=['datetime64']).columns
        if len(date_cols) > 0 and len(numeric_cols) > 0:
            self.df.set_index(date_cols[0])[numeric_cols[0]].plot(ax=axes[1, 0])
            axes[1, 0].set_title('Time Series Analysis')
        
        # Box plot for categorical vs numeric
        categorical_cols = self.df.select_dtypes(include=['object']).columns
        if len(categorical_cols) > 0 and len(numeric_cols) > 0:
            self.df.boxplot(column=numeric_cols[0], by=categorical_cols[0], ax=axes[1, 1])
            axes[1, 1].set_title(f'{numeric_cols[0]} by {categorical_cols[0]}')
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        return output_file
```

### Web Development and APIs

```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import json
from typing import Dict, List, Optional

class APIClient:
    def __init__(self, base_url: str, api_key: Optional[str] = None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        
        # Configure retry strategy
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)
        
        # Set default headers
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'Python-APIClient/1.0'
        })
        
        if api_key:
            self.session.headers.update({'Authorization': f'Bearer {api_key}'})
    
    def get(self, endpoint: str, params: Optional[Dict] = None) -> Dict:
        """Make GET request to API endpoint."""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        response = self.session.get(url, params=params)
        response.raise_for_status()
        return response.json()
    
    def post(self, endpoint: str, data: Dict) -> Dict:
        """Make POST request to API endpoint."""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        response = self.session.post(url, json=data)
        response.raise_for_status()
        return response.json()
    
    def upload_file(self, endpoint: str, file_path: str, additional_data: Optional[Dict] = None):
        """Upload file to API endpoint."""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        
        with open(file_path, 'rb') as f:
            files = {'file': f}
            data = additional_data or {}
            response = self.session.post(url, files=files, data=data)
        
        response.raise_for_status()
        return response.json()

# Example usage with popular APIs
class GitHubAPI(APIClient):
    def __init__(self, token: Optional[str] = None):
        super().__init__('https://api.github.com', token)
    
    def get_user_repos(self, username: str) -> List[Dict]:
        return self.get(f'/users/{username}/repos')
    
    def create_issue(self, owner: str, repo: str, title: str, body: str) -> Dict:
        return self.post(f'/repos/{owner}/{repo}/issues', {
            'title': title,
            'body': body
        })
```

### Testing and Quality Assurance

```python
import pytest
import unittest.mock as mock
from dataclasses import dataclass
from typing import List, Callable
import tempfile
import json

@dataclass
class TestCase:
    name: str
    input_data: any
    expected_output: any
    should_raise: Optional[Exception] = None

class TestFramework:
    def __init__(self):
        self.test_cases: List[TestCase] = []
        self.setup_functions: List[Callable] = []
        self.teardown_functions: List[Callable] = []
    
    def add_test_case(self, test_case: TestCase):
        self.test_cases.append(test_case)
    
    def add_setup(self, func: Callable):
        self.setup_functions.append(func)
    
    def add_teardown(self, func: Callable):
        self.teardown_functions.append(func)
    
    def run_tests(self, target_function: Callable):
        results = []
        
        for test_case in self.test_cases:
            # Setup
            for setup_func in self.setup_functions:
                setup_func()
            
            try:
                if test_case.should_raise:
                    with pytest.raises(test_case.should_raise):
                        result = target_function(test_case.input_data)
                    results.append({'name': test_case.name, 'status': 'PASS', 'error': None})
                else:
                    result = target_function(test_case.input_data)
                    if result == test_case.expected_output:
                        results.append({'name': test_case.name, 'status': 'PASS', 'error': None})
                    else:
                        results.append({
                            'name': test_case.name, 
                            'status': 'FAIL', 
                            'error': f'Expected {test_case.expected_output}, got {result}'
                        })
            except Exception as e:
                results.append({'name': test_case.name, 'status': 'ERROR', 'error': str(e)})
            
            # Teardown
            for teardown_func in self.teardown_functions:
                teardown_func()
        
        return results

# Mock and fixture examples
class DatabaseMock:
    def __init__(self):
        self.data = {}
    
    def save(self, key, value):
        self.data[key] = value
        return True
    
    def get(self, key):
        return self.data.get(key)
    
    def delete(self, key):
        return self.data.pop(key, None)

@pytest.fixture
def temp_file():
    with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
        f.write(json.dumps({'test': 'data'}))
        temp_path = f.name
    
    yield temp_path
    
    import os
    os.unlink(temp_path)
```

### CLI and System Integration

```python
import click
import argparse
from pathlib import Path
import subprocess
import sys
from typing import Optional
import logging

# Click framework for CLI applications
@click.group()
@click.option('--verbose', '-v', is_flag=True, help='Enable verbose output')
@click.pass_context
def cli(ctx, verbose):
    """Professional Python CLI Application."""
    ctx.ensure_object(dict)
    ctx.obj['verbose'] = verbose
    
    # Configure logging
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(level=level, format='%(asctime)s - %(levelname)s - %(message)s')

@cli.command()
@click.argument('input_file', type=click.Path(exists=True))
@click.option('--output', '-o', type=click.Path(), help='Output file path')
@click.option('--format', type=click.Choice(['json', 'csv', 'xml']), default='json')
@click.pass_context
def process(ctx, input_file, output, format):
    """Process input file and generate output."""
    if ctx.obj['verbose']:
        click.echo(f"Processing {input_file} in {format} format")
    
    # Processing logic here
    result = {'processed': True, 'input': input_file, 'format': format}
    
    if output:
        with open(output, 'w') as f:
            if format == 'json':
                json.dump(result, f, indent=2)
            else:
                f.write(str(result))
        click.echo(f"Output saved to {output}")
    else:
        click.echo(json.dumps(result, indent=2))

@cli.command()
@click.option('--command', '-c', required=True, help='System command to execute')
@click.option('--timeout', default=30, help='Command timeout in seconds')
def execute(command, timeout):
    """Execute system command safely."""
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        
        if result.returncode == 0:
            click.echo("✅ Command executed successfully")
            click.echo(result.stdout)
        else:
            click.echo("❌ Command failed")
            click.echo(result.stderr)
            sys.exit(result.returncode)
            
    except subprocess.TimeoutExpired:
        click.echo(f"❌ Command timed out after {timeout} seconds")
        sys.exit(1)
    except Exception as e:
        click.echo(f"❌ Error executing command: {e}")
        sys.exit(1)

if __name__ == '__main__':
    cli()
```

## 📝 Practice Projects

### Project 1: Data Analysis Dashboard

Build a comprehensive data analysis tool using pandas, matplotlib, and a web framework.

### Project 2: API Integration Platform

Create a platform that integrates multiple APIs with testing, caching, and monitoring.

### Project 3: Professional CLI Tool

Develop a feature-rich command-line application with proper testing and documentation.

## 🎯 Learning Milestones

### Week 1-3: Data Science Stack

- [ ] Master pandas for data manipulation
- [ ] Use numpy for numerical computations
- [ ] Create visualizations with matplotlib/seaborn

### Week 4-6: Web and API Development

- [ ] Build REST API clients
- [ ] Handle authentication and rate limiting
- [ ] Implement robust error handling

### Week 7-9: Testing and Quality

- [ ] Write comprehensive unit tests
- [ ] Use mocking and fixtures
- [ ] Implement integration testing

### Week 10-12: CLI and System Integration

- [ ] Build professional CLI applications
- [ ] Handle system interactions safely
- [ ] Package and distribute applications

## 🔗 Related Topics

### Prerequisites

- [07_Skilled-Coder-to-Specialist](../07_Skilled-Coder-to-Specialist/) - Standard Library

### Enables

- [09_Professional-to-Curious-Learner](../09_Professional-to-Curious-Learner/) - Advanced Features

---

**Last Updated**: September 7, 2025  
**Maintained By**: STSA Learning System
