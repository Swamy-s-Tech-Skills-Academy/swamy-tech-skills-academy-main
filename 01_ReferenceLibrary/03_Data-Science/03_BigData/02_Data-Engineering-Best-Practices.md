# 02_Data-Engineering-Best-Practices

**Learning Level**: Intermediate to Advanced  
**Prerequisites**: Basic data processing, Python/SQL knowledge, understanding of databases  
**Estimated Time**: 75-90 minutes

## 🎯 Learning Objectives

By the end of this content, you will:

- Understand core principles of robust data engineering
- Learn best practices for building scalable data pipelines
- Master data quality, monitoring, and observability techniques
- Implement efficient data processing and storage strategies
- Design fault-tolerant and maintainable data systems

## 📋 Foundation Principles

### 🏗️ Data Pipeline Architecture

#### **The Modern Data Stack Paradigm**

**Layer-Based Architecture**:

1. **Data Sources**: APIs, databases, files, streaming sources
2. **Ingestion Layer**: Batch and streaming data collection
3. **Storage Layer**: Data lakes, warehouses, and operational stores
4. **Processing Layer**: Transformation, enrichment, and analytics
5. **Serving Layer**: APIs, dashboards, and applications
6. **Orchestration Layer**: Workflow management and scheduling

**Key Design Principles**:

- **Separation of Concerns**: Each layer has distinct responsibilities
- **Loose Coupling**: Components can evolve independently
- **Scalability**: Horizontal scaling capabilities at each layer
- **Fault Tolerance**: Graceful handling of failures and retries
- **Observability**: Comprehensive monitoring and logging

#### **Data Pipeline Patterns**

**ELT vs ETL Decision Framework**:

```python
class PipelineStrategy:
    """Framework for choosing ELT vs ETL approach"""

    @staticmethod
    def recommend_approach(data_characteristics: dict) -> str:
        """
        Recommend ELT or ETL based on data characteristics

        Args:
            data_characteristics: {
                'volume': 'small'|'medium'|'large',
                'variety': 'structured'|'semi-structured'|'unstructured',
                'velocity': 'batch'|'micro-batch'|'streaming',
                'compute_resources': 'limited'|'moderate'|'abundant',
                'transformation_complexity': 'simple'|'moderate'|'complex',
                'storage_cost': 'high'|'moderate'|'low'
            }
        """
        score_elt = 0
        score_etl = 0

        # Volume considerations
        if data_characteristics.get('volume') == 'large':
            score_elt += 2
        elif data_characteristics.get('volume') == 'small':
            score_etl += 1

        # Variety considerations
        if data_characteristics.get('variety') in ['semi-structured', 'unstructured']:
            score_elt += 2
        else:
            score_etl += 1

        # Compute resource considerations
        if data_characteristics.get('compute_resources') == 'abundant':
            score_elt += 2
        elif data_characteristics.get('compute_resources') == 'limited':
            score_etl += 2

        # Storage cost considerations
        if data_characteristics.get('storage_cost') == 'low':
            score_elt += 1
        elif data_characteristics.get('storage_cost') == 'high':
            score_etl += 2

        # Transformation complexity
        if data_characteristics.get('transformation_complexity') == 'complex':
            score_elt += 1
        else:
            score_etl += 1

        recommendation = "ELT" if score_elt > score_etl else "ETL"
        confidence = abs(score_elt - score_etl) / max(score_elt, score_etl)

        return {
            'recommendation': recommendation,
            'confidence': confidence,
            'elt_score': score_elt,
            'etl_score': score_etl,
            'reasoning': PipelineStrategy._generate_reasoning(
                recommendation, data_characteristics
            )
        }

    @staticmethod
    def _generate_reasoning(recommendation: str, characteristics: dict) -> str:
        reasons = []

        if recommendation == "ELT":
            if characteristics.get('volume') == 'large':
                reasons.append("Large data volume benefits from cloud storage and compute separation")
            if characteristics.get('variety') in ['semi-structured', 'unstructured']:
                reasons.append("Schema-on-read approach handles varied data structures efficiently")
            if characteristics.get('storage_cost') == 'low':
                reasons.append("Low storage costs make raw data retention economical")
        else:
            if characteristics.get('compute_resources') == 'limited':
                reasons.append("Limited compute resources favor preprocessing optimization")
            if characteristics.get('storage_cost') == 'high':
                reasons.append("High storage costs justify transformation before loading")

        return "; ".join(reasons)

# Usage example
data_profile = {
    'volume': 'large',
    'variety': 'semi-structured',
    'velocity': 'batch',
    'compute_resources': 'abundant',
    'transformation_complexity': 'moderate',
    'storage_cost': 'low'
}

recommendation = PipelineStrategy.recommend_approach(data_profile)
print(f"Recommended approach: {recommendation['recommendation']}")
print(f"Reasoning: {recommendation['reasoning']}")
```

## 🔄 Data Quality and Validation

### **Comprehensive Data Quality Framework**

```python
from typing import Dict, List, Any, Callable, Optional
from dataclasses import dataclass
from enum import Enum
import pandas as pd
import numpy as np
from datetime import datetime

class QualityCheckSeverity(Enum):
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"

@dataclass
class QualityCheckResult:
    check_name: str
    passed: bool
    severity: QualityCheckSeverity
    message: str
    failed_records: int = 0
    total_records: int = 0
    details: Dict[str, Any] = None

class DataQualityFramework:
    """Comprehensive data quality validation framework"""

    def __init__(self):
        self.checks: Dict[str, Callable] = {}
        self.results: List[QualityCheckResult] = []

    def register_check(self, name: str, severity: QualityCheckSeverity):
        """Decorator to register data quality checks"""
        def decorator(func: Callable):
            self.checks[name] = (func, severity)
            return func
        return decorator

    def run_quality_checks(self, df: pd.DataFrame,
                          check_names: Optional[List[str]] = None) -> List[QualityCheckResult]:
        """Run specified quality checks on dataframe"""
        self.results = []
        checks_to_run = check_names or list(self.checks.keys())

        for check_name in checks_to_run:
            if check_name in self.checks:
                check_func, severity = self.checks[check_name]
                try:
                    result = check_func(df)
                    if isinstance(result, QualityCheckResult):
                        self.results.append(result)
                    else:
                        # Convert simple boolean result
                        self.results.append(QualityCheckResult(
                            check_name=check_name,
                            passed=result,
                            severity=severity,
                            message=f"Check {check_name} {'passed' if result else 'failed'}",
                            total_records=len(df)
                        ))
                except Exception as e:
                    self.results.append(QualityCheckResult(
                        check_name=check_name,
                        passed=False,
                        severity=QualityCheckSeverity.ERROR,
                        message=f"Check {check_name} failed with error: {str(e)}",
                        total_records=len(df)
                    ))

        return self.results

    def get_quality_report(self) -> Dict[str, Any]:
        """Generate comprehensive quality report"""
        total_checks = len(self.results)
        passed_checks = sum(1 for r in self.results if r.passed)
        failed_checks = total_checks - passed_checks

        severity_breakdown = {}
        for severity in QualityCheckSeverity:
            severity_breakdown[severity.value] = sum(
                1 for r in self.results
                if r.severity == severity and not r.passed
            )

        return {
            'timestamp': datetime.now().isoformat(),
            'total_checks': total_checks,
            'passed_checks': passed_checks,
            'failed_checks': failed_checks,
            'success_rate': passed_checks / total_checks if total_checks > 0 else 0,
            'severity_breakdown': severity_breakdown,
            'failed_checks_details': [
                {
                    'check_name': r.check_name,
                    'severity': r.severity.value,
                    'message': r.message,
                    'failed_records': r.failed_records,
                    'total_records': r.total_records
                }
                for r in self.results if not r.passed
            ]
        }

# Initialize quality framework
quality_framework = DataQualityFramework()

# Register quality checks using decorators
@quality_framework.register_check("no_null_values", QualityCheckSeverity.ERROR)
def check_no_nulls(df: pd.DataFrame) -> QualityCheckResult:
    """Check for null values in critical columns"""
    critical_columns = ['id', 'email', 'created_at']  # Define based on your schema
    existing_critical_cols = [col for col in critical_columns if col in df.columns]

    null_counts = df[existing_critical_cols].isnull().sum()
    total_nulls = null_counts.sum()

    return QualityCheckResult(
        check_name="no_null_values",
        passed=total_nulls == 0,
        severity=QualityCheckSeverity.ERROR,
        message=f"Found {total_nulls} null values in critical columns",
        failed_records=int(total_nulls),
        total_records=len(df) * len(existing_critical_cols),
        details=null_counts.to_dict()
    )

@quality_framework.register_check("unique_ids", QualityCheckSeverity.CRITICAL)
def check_unique_ids(df: pd.DataFrame) -> QualityCheckResult:
    """Check for unique IDs"""
    if 'id' not in df.columns:
        return QualityCheckResult(
            check_name="unique_ids",
            passed=True,
            severity=QualityCheckSeverity.CRITICAL,
            message="No ID column found, skipping uniqueness check",
            total_records=len(df)
        )

    duplicates = df['id'].duplicated().sum()

    return QualityCheckResult(
        check_name="unique_ids",
        passed=duplicates == 0,
        severity=QualityCheckSeverity.CRITICAL,
        message=f"Found {duplicates} duplicate IDs",
        failed_records=int(duplicates),
        total_records=len(df)
    )

@quality_framework.register_check("data_freshness", QualityCheckSeverity.WARNING)
def check_data_freshness(df: pd.DataFrame) -> QualityCheckResult:
    """Check if data is recent enough"""
    if 'created_at' not in df.columns:
        return QualityCheckResult(
            check_name="data_freshness",
            passed=True,
            severity=QualityCheckSeverity.WARNING,
            message="No timestamp column found",
            total_records=len(df)
        )

    try:
        df['created_at'] = pd.to_datetime(df['created_at'])
        max_date = df['created_at'].max()
        days_old = (datetime.now() - max_date).days

        # Data should be no more than 7 days old
        is_fresh = days_old <= 7

        return QualityCheckResult(
            check_name="data_freshness",
            passed=is_fresh,
            severity=QualityCheckSeverity.WARNING,
            message=f"Most recent data is {days_old} days old",
            total_records=len(df),
            details={'days_old': days_old, 'max_date': max_date.isoformat()}
        )
    except Exception as e:
        return QualityCheckResult(
            check_name="data_freshness",
            passed=False,
            severity=QualityCheckSeverity.ERROR,
            message=f"Error checking data freshness: {str(e)}",
            total_records=len(df)
        )
```

## 📊 Monitoring and Observability

### **Pipeline Monitoring Framework**

```python
import time
import functools
from typing import Dict, Any, Optional
from dataclasses import dataclass
from datetime import datetime
import logging

@dataclass
class PipelineMetrics:
    """Container for pipeline execution metrics"""
    pipeline_name: str
    stage_name: str
    start_time: datetime
    end_time: Optional[datetime] = None
    duration_seconds: Optional[float] = None
    records_processed: int = 0
    records_failed: int = 0
    memory_usage_mb: Optional[float] = None
    status: str = "running"
    error_message: Optional[str] = None
    custom_metrics: Dict[str, Any] = None

class PipelineMonitor:
    """Comprehensive pipeline monitoring and observability"""

    def __init__(self, pipeline_name: str):
        self.pipeline_name = pipeline_name
        self.metrics: List[PipelineMetrics] = []
        self.logger = logging.getLogger(f"pipeline.{pipeline_name}")
        self.current_stage_metrics: Optional[PipelineMetrics] = None

    def stage_monitor(self, stage_name: str):
        """Decorator for monitoring pipeline stages"""
        def decorator(func):
            @functools.wraps(func)
            def wrapper(*args, **kwargs):
                # Start monitoring
                metrics = PipelineMetrics(
                    pipeline_name=self.pipeline_name,
                    stage_name=stage_name,
                    start_time=datetime.now(),
                    custom_metrics={}
                )
                self.current_stage_metrics = metrics

                self.logger.info(f"Starting stage: {stage_name}")

                try:
                    # Execute function
                    result = func(*args, **kwargs)

                    # Complete monitoring
                    metrics.end_time = datetime.now()
                    metrics.duration_seconds = (
                        metrics.end_time - metrics.start_time
                    ).total_seconds()
                    metrics.status = "completed"

                    # Try to extract record counts from result
                    if hasattr(result, '__len__'):
                        metrics.records_processed = len(result)
                    elif isinstance(result, dict) and 'record_count' in result:
                        metrics.records_processed = result['record_count']

                    self.logger.info(
                        f"Completed stage: {stage_name} "
                        f"({metrics.duration_seconds:.2f}s, "
                        f"{metrics.records_processed} records)"
                    )

                    return result

                except Exception as e:
                    # Handle failure
                    metrics.end_time = datetime.now()
                    metrics.duration_seconds = (
                        metrics.end_time - metrics.start_time
                    ).total_seconds()
                    metrics.status = "failed"
                    metrics.error_message = str(e)

                    self.logger.error(
                        f"Failed stage: {stage_name} "
                        f"({metrics.duration_seconds:.2f}s) - {str(e)}"
                    )

                    raise

                finally:
                    self.metrics.append(metrics)
                    self.current_stage_metrics = None

            return wrapper
        return decorator

    def add_metric(self, key: str, value: Any):
        """Add custom metric to current stage"""
        if self.current_stage_metrics:
            if self.current_stage_metrics.custom_metrics is None:
                self.current_stage_metrics.custom_metrics = {}
            self.current_stage_metrics.custom_metrics[key] = value

    def get_pipeline_summary(self) -> Dict[str, Any]:
        """Generate pipeline execution summary"""
        if not self.metrics:
            return {"status": "no_metrics", "pipeline_name": self.pipeline_name}

        total_duration = sum(m.duration_seconds or 0 for m in self.metrics)
        total_records = sum(m.records_processed for m in self.metrics)
        failed_stages = [m for m in self.metrics if m.status == "failed"]

        return {
            "pipeline_name": self.pipeline_name,
            "total_stages": len(self.metrics),
            "failed_stages": len(failed_stages),
            "total_duration_seconds": total_duration,
            "total_records_processed": total_records,
            "throughput_records_per_second": total_records / total_duration if total_duration > 0 else 0,
            "status": "failed" if failed_stages else "completed",
            "stage_details": [
                {
                    "stage_name": m.stage_name,
                    "duration_seconds": m.duration_seconds,
                    "records_processed": m.records_processed,
                    "status": m.status,
                    "error_message": m.error_message
                }
                for m in self.metrics
            ]
        }

# Usage example
class DataPipeline:
    def __init__(self, name: str):
        self.monitor = PipelineMonitor(name)

    @property
    def stage_monitor(self):
        return self.monitor.stage_monitor

    @stage_monitor("data_extraction")
    def extract_data(self, source: str) -> pd.DataFrame:
        """Extract data from source"""
        time.sleep(2)  # Simulate extraction time

        # Simulate data extraction
        data = pd.DataFrame({
            'id': range(1000),
            'value': np.random.randn(1000),
            'category': np.random.choice(['A', 'B', 'C'], 1000)
        })

        self.monitor.add_metric("source", source)
        self.monitor.add_metric("extraction_method", "api")

        return data

    @stage_monitor("data_transformation")
    def transform_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """Transform the data"""
        time.sleep(1)  # Simulate transformation time

        # Simple transformation
        df_transformed = df.copy()
        df_transformed['value_squared'] = df_transformed['value'] ** 2
        df_transformed['normalized_value'] = (
            df_transformed['value'] - df_transformed['value'].mean()
        ) / df_transformed['value'].std()

        self.monitor.add_metric("transformation_type", "feature_engineering")
        self.monitor.add_metric("columns_added", 2)

        return df_transformed

    @stage_monitor("data_loading")
    def load_data(self, df: pd.DataFrame, destination: str) -> Dict[str, Any]:
        """Load data to destination"""
        time.sleep(0.5)  # Simulate loading time

        # Simulate data loading
        self.monitor.add_metric("destination", destination)
        self.monitor.add_metric("load_method", "bulk_insert")

        return {
            "record_count": len(df),
            "destination": destination,
            "status": "success"
        }

    def run_pipeline(self, source: str, destination: str) -> Dict[str, Any]:
        """Run the complete pipeline"""
        try:
            # Extract
            raw_data = self.extract_data(source)

            # Transform
            transformed_data = self.transform_data(raw_data)

            # Load
            load_result = self.load_data(transformed_data, destination)

            # Get summary
            summary = self.monitor.get_pipeline_summary()
            summary["pipeline_result"] = load_result

            return summary

        except Exception as e:
            summary = self.monitor.get_pipeline_summary()
            summary["pipeline_error"] = str(e)
            return summary

# Usage
pipeline = DataPipeline("user_analytics_pipeline")
result = pipeline.run_pipeline("user_database", "analytics_warehouse")
print(f"Pipeline completed in {result['total_duration_seconds']:.2f} seconds")
print(f"Processed {result['total_records_processed']} records")
```

## 🔗 Related Topics

### **Prerequisites**

- **01_DataScience/**: Statistical foundations and data analysis
- **02_DataAnalytics/**: Business intelligence and visualization
- **Python/SQL**: Programming and query languages

### **Related**

- **01_Development/**: Software engineering best practices
- **02_AI-and-ML/**: Machine learning pipeline patterns
- **Cloud Platforms**: AWS, Azure, GCP data services

### **Advanced**

- **Stream Processing**: Real-time data processing patterns
- **Data Mesh Architecture**: Decentralized data architecture
- **MLOps Integration**: ML pipeline and data pipeline coordination

## 💡 Practical Applications

### **For Data Engineers**

- **Pipeline Design**: Build robust, scalable data processing systems
- **Quality Assurance**: Implement comprehensive data validation frameworks
- **Monitoring**: Establish observability and alerting for data systems
- **Performance Optimization**: Optimize data processing performance and costs

### **For Data Teams**

- **Collaboration**: Establish clear interfaces between data producers and consumers
- **Governance**: Implement data governance and compliance frameworks
- **Documentation**: Maintain comprehensive data lineage and documentation
- **Incident Response**: Develop procedures for data quality issues and outages

## 🎯 Next Steps

1. **Assessment**: Evaluate current data pipeline maturity
2. **Framework Selection**: Choose appropriate tools and frameworks for your stack
3. **Quality Implementation**: Deploy data quality monitoring and validation
4. **Monitoring Setup**: Implement comprehensive pipeline observability
5. **Team Training**: Educate team on data engineering best practices

---

**📅 Last Updated**: July 30, 2025  
**🔗 Standards**: Based on modern data engineering practices and industry standards  
**📍 Domain**: Data Science → Big Data Engineering  
**🎯 Impact**: Essential practices for building reliable, scalable data systems
