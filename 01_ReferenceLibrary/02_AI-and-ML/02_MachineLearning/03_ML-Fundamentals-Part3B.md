# 03_ML-Fundamentals-Part3B: Hyperparameter Optimization

**Learning Level**: Intermediate  
**Prerequisites**: ML Parts 1, 2, 3A - Model Evaluation Basics  
**Estimated Time**: Part 3B of 3 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master Grid Search, Random Search, and Bayesian optimization techniques
- Implement automated hyperparameter tuning with cross-validation
- Design efficient search strategies that balance exploration vs exploitation
- Build production-ready hyperparameter optimization pipelines

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

Hyperparameters control how your model learns but aren't learned from data. Poor hyperparameter choices lead to underperforming models, while optimal tuning can dramatically improve accuracy.

**Common Hyperparameters**:

- **Learning Rate**: How fast the model adapts (too high = instability, too low = slow learning)
- **Regularization**: Prevents overfitting (L1, L2, dropout rates)
- **Model Structure**: Tree depth, number of estimators, hidden layers

**Three Optimization Strategies**:

- **Grid Search**: Exhaustive search over parameter combinations
- **Random Search**: Random sampling from parameter distributions  
- **Bayesian Optimization**: Smart search using previous results

### Core Implementation (6 minutes)

```csharp
// ✅ Hyperparameter Optimization Framework
namespace MachineLearning.Optimization
{
    public interface IHyperparameterOptimizer<TModel, TParams>
    {
        Task<OptimizationResult<TParams>> OptimizeAsync(
            Func<TParams, Task<TModel>> modelFactory,
            IEnumerable<(double[] Features, object Target)> data,
            ParameterSpace<TParams> searchSpace,
            OptimizationConfig config = null);
    }
    
    public class GridSearchOptimizer<TModel, TParams> : IHyperparameterOptimizer<TModel, TParams>
    {
        private readonly IModelEvaluator<TModel, double[], object> _evaluator;
        private readonly ILogger<GridSearchOptimizer<TModel, TParams>> _logger;
        
        public GridSearchOptimizer(
            IModelEvaluator<TModel, double[], object> evaluator,
            ILogger<GridSearchOptimizer<TModel, TParams>> logger = null)
        {
            _evaluator = evaluator;
            _logger = logger;
        }
        
        public async Task<OptimizationResult<TParams>> OptimizeAsync(
            Func<TParams, Task<TModel>> modelFactory,
            IEnumerable<(double[] Features, object Target)> data,
            ParameterSpace<TParams> searchSpace,
            OptimizationConfig config = null)
        {
            config ??= new OptimizationConfig();
            var dataList = data.ToList();
            
            _logger?.LogInformation("Starting Grid Search optimization with {Combinations} parameter combinations",
                searchSpace.GetTotalCombinations());
            
            var results = new List<ParameterResult<TParams>>();
            var parameterCombinations = searchSpace.GenerateGridCombinations();
            
            var totalCombinations = parameterCombinations.Count();
            var processedCount = 0;
            
            foreach (var parameters in parameterCombinations)
            {
                try
                {
                    // Train model with current parameters
                    var model = await modelFactory(parameters);
                    
                    // Evaluate using cross-validation
                    var cvResult = await _evaluator.CrossValidateAsync(
                        async trainData => await modelFactory(parameters),
                        dataList,
                        folds: config.CrossValidationFolds);
                    
                    // Extract primary metric (e.g., accuracy for classification)
                    var primaryMetric = cvResult.MeanMetrics[config.PrimaryMetric];
                    
                    results.Add(new ParameterResult<TParams>
                    {
                        Parameters = parameters,
                        Score = primaryMetric,
                        StandardDeviation = cvResult.MeanMetrics[$"StdDev{config.PrimaryMetric}"],
                        CrossValidationResults = cvResult,
                        TrainingTime = DateTime.UtcNow // Simplified timing
                    });
                    
                    processedCount++;
                    
                    if (processedCount % 10 == 0)
                    {
                        _logger?.LogDebug("Processed {Processed}/{Total} combinations. Best score so far: {BestScore:F4}",
                            processedCount, totalCombinations, results.Max(r => r.Score));
                    }
                }
                catch (Exception ex)
                {
                    _logger?.LogWarning(ex, "Failed to evaluate parameters: {Parameters}", parameters);
                }
            }
            
            // Find best parameters
            var bestResult = results.OrderByDescending(r => r.Score).First();
            
            _logger?.LogInformation("Grid Search completed. Best score: {Score:F4} with parameters: {Parameters}",
                bestResult.Score, bestResult.Parameters);
            
            return new OptimizationResult<TParams>
            {
                BestParameters = bestResult.Parameters,
                BestScore = bestResult.Score,
                AllResults = results,
                OptimizationMethod = "GridSearch",
                TotalEvaluations = results.Count
            };
        }
    }
    
    public class RandomSearchOptimizer<TModel, TParams> : IHyperparameterOptimizer<TModel, TParams>
    {
        private readonly IModelEvaluator<TModel, double[], object> _evaluator;
        private readonly ILogger<RandomSearchOptimizer<TModel, TParams>> _logger;
        private readonly Random _random;
        
        public RandomSearchOptimizer(
            IModelEvaluator<TModel, double[], object> evaluator,
            ILogger<RandomSearchOptimizer<TModel, TParams>> logger = null,
            int? seed = null)
        {
            _evaluator = evaluator;
            _logger = logger;
            _random = seed.HasValue ? new Random(seed.Value) : new Random();
        }
        
        public async Task<OptimizationResult<TParams>> OptimizeAsync(
            Func<TParams, Task<TModel>> modelFactory,
            IEnumerable<(double[] Features, object Target)> data,
            ParameterSpace<TParams> searchSpace,
            OptimizationConfig config = null)
        {
            config ??= new OptimizationConfig { MaxEvaluations = 50 };
            var dataList = data.ToList();
            
            _logger?.LogInformation("Starting Random Search optimization with {MaxEvals} evaluations",
                config.MaxEvaluations);
            
            var results = new List<ParameterResult<TParams>>();
            
            for (int i = 0; i < config.MaxEvaluations; i++)
            {
                try
                {
                    // Sample random parameters from search space
                    var parameters = searchSpace.SampleRandom(_random);
                    
                    // Train and evaluate model
                    var model = await modelFactory(parameters);
                    
                    var cvResult = await _evaluator.CrossValidateAsync(
                        async trainData => await modelFactory(parameters),
                        dataList,
                        folds: config.CrossValidationFolds);
                    
                    var primaryMetric = cvResult.MeanMetrics[config.PrimaryMetric];
                    
                    results.Add(new ParameterResult<TParams>
                    {
                        Parameters = parameters,
                        Score = primaryMetric,
                        StandardDeviation = cvResult.MeanMetrics[$"StdDev{config.PrimaryMetric}"],
                        CrossValidationResults = cvResult,
                        TrainingTime = DateTime.UtcNow
                    });
                    
                    if ((i + 1) % 10 == 0)
                    {
                        var currentBest = results.Max(r => r.Score);
                        _logger?.LogDebug("Completed {Count}/{Total} evaluations. Best score: {BestScore:F4}",
                            i + 1, config.MaxEvaluations, currentBest);
                    }
                }
                catch (Exception ex)
                {
                    _logger?.LogWarning(ex, "Failed evaluation {Index}", i + 1);
                }
            }
            
            var bestResult = results.OrderByDescending(r => r.Score).First();
            
            _logger?.LogInformation("Random Search completed. Best score: {Score:F4}",
                bestResult.Score);
            
            return new OptimizationResult<TParams>
            {
                BestParameters = bestResult.Parameters,
                BestScore = bestResult.Score,
                AllResults = results,
                OptimizationMethod = "RandomSearch",
                TotalEvaluations = results.Count
            };
        }
    }
    
    public class BayesianOptimizer<TModel, TParams> : IHyperparameterOptimizer<TModel, TParams>
    {
        private readonly IModelEvaluator<TModel, double[], object> _evaluator;
        private readonly ILogger<BayesianOptimizer<TModel, TParams>> _logger;
        private readonly Random _random;
        
        public BayesianOptimizer(
            IModelEvaluator<TModel, double[], object> evaluator,
            ILogger<BayesianOptimizer<TModel, TParams>> logger = null)
        {
            _evaluator = evaluator;
            _logger = logger;
            _random = new Random();
        }
        
        public async Task<OptimizationResult<TParams>> OptimizeAsync(
            Func<TParams, Task<TModel>> modelFactory,
            IEnumerable<(double[] Features, object Target)> data,
            ParameterSpace<TParams> searchSpace,
            OptimizationConfig config = null)
        {
            config ??= new OptimizationConfig { MaxEvaluations = 25 };
            var dataList = data.ToList();
            
            _logger?.LogInformation("Starting Bayesian optimization with {MaxEvals} evaluations",
                config.MaxEvaluations);
            
            var results = new List<ParameterResult<TParams>>();
            var gaussianProcess = new GaussianProcess(); // Simplified GP implementation
            
            // Initial random sampling (exploration phase)
            var initialSamples = Math.Min(5, config.MaxEvaluations / 3);
            
            for (int i = 0; i < initialSamples; i++)
            {
                var parameters = searchSpace.SampleRandom(_random);
                var score = await EvaluateParameters(modelFactory, parameters, dataList, config);
                
                results.Add(new ParameterResult<TParams>
                {
                    Parameters = parameters,
                    Score = score.Score,
                    StandardDeviation = score.StandardDeviation,
                    TrainingTime = DateTime.UtcNow
                });
            }
            
            // Bayesian optimization loop (exploitation + exploration)
            for (int i = initialSamples; i < config.MaxEvaluations; i++)
            {
                // Update Gaussian Process with all previous results
                await UpdateGaussianProcess(gaussianProcess, results, searchSpace);
                
                // Find next best parameters using acquisition function (Upper Confidence Bound)
                var nextParameters = await FindNextParameters(gaussianProcess, searchSpace);
                
                var score = await EvaluateParameters(modelFactory, nextParameters, dataList, config);
                
                results.Add(new ParameterResult<TParams>
                {
                    Parameters = nextParameters,
                    Score = score.Score,
                    StandardDeviation = score.StandardDeviation,
                    TrainingTime = DateTime.UtcNow
                });
                
                _logger?.LogDebug("Bayesian iteration {Iteration}: Score = {Score:F4}",
                    i + 1, score.Score);
            }
            
            var bestResult = results.OrderByDescending(r => r.Score).First();
            
            _logger?.LogInformation("Bayesian optimization completed. Best score: {Score:F4}",
                bestResult.Score);
            
            return new OptimizationResult<TParams>
            {
                BestParameters = bestResult.Parameters,
                BestScore = bestResult.Score,
                AllResults = results,
                OptimizationMethod = "BayesianOptimization",
                TotalEvaluations = results.Count
            };
        }
        
        private async Task<(double Score, double StandardDeviation)> EvaluateParameters(
            Func<TParams, Task<TModel>> modelFactory,
            TParams parameters,
            List<(double[] Features, object Target)> data,
            OptimizationConfig config)
        {
            var cvResult = await _evaluator.CrossValidateAsync(
                async trainData => await modelFactory(parameters),
                data,
                folds: config.CrossValidationFolds);
            
            var score = cvResult.MeanMetrics[config.PrimaryMetric];
            var stdDev = cvResult.MeanMetrics[$"StdDev{config.PrimaryMetric}"];
            
            return (score, stdDev);
        }
        
        private async Task UpdateGaussianProcess(
            GaussianProcess gp,
            List<ParameterResult<TParams>> results,
            ParameterSpace<TParams> searchSpace)
        {
            // Simplified GP update - in production use libraries like ML.NET or Accord.NET
            var parameterVectors = results.Select(r => searchSpace.ToVector(r.Parameters)).ToList();
            var scores = results.Select(r => r.Score).ToList();
            
            await gp.FitAsync(parameterVectors, scores);
        }
        
        private async Task<TParams> FindNextParameters(
            GaussianProcess gp,
            ParameterSpace<TParams> searchSpace)
        {
            // Simplified acquisition function - Upper Confidence Bound (UCB)
            var bestAcquisition = double.MinValue;
            TParams bestParameters = default;
            
            // Sample candidate points and evaluate acquisition function
            for (int i = 0; i < 100; i++) // 100 candidate samples
            {
                var candidateParams = searchSpace.SampleRandom(_random);
                var candidateVector = searchSpace.ToVector(candidateParams);
                
                var (mean, variance) = await gp.PredictAsync(candidateVector);
                var ucb = mean + 2.0 * Math.Sqrt(variance); // UCB with beta = 2.0
                
                if (ucb > bestAcquisition)
                {
                    bestAcquisition = ucb;
                    bestParameters = candidateParams;
                }
            }
            
            return bestParameters;
        }
    }
    
    // Simplified Gaussian Process for demonstration
    public class GaussianProcess
    {
        private List<double[]> _trainingInputs;
        private List<double> _trainingOutputs;
        
        public async Task FitAsync(List<double[]> inputs, List<double> outputs)
        {
            _trainingInputs = inputs;
            _trainingOutputs = outputs;
        }
        
        public async Task<(double Mean, double Variance)> PredictAsync(double[] testInput)
        {
            // Simplified GP prediction using nearest neighbor approximation
            if (_trainingInputs?.Any() != true)
                return (0, 1); // Default prediction
            
            var distances = _trainingInputs.Select(input => 
                EuclideanDistance(testInput, input)).ToList();
            
            var nearestIndex = distances.IndexOf(distances.Min());
            var nearestOutput = _trainingOutputs[nearestIndex];
            
            // Simple variance estimation based on distance
            var minDistance = distances.Min();
            var variance = Math.Max(0.01, minDistance); // Minimum variance
            
            return (nearestOutput, variance);
        }
        
        private double EuclideanDistance(double[] a, double[] b)
        {
            return Math.Sqrt(a.Zip(b, (x, y) => (x - y) * (x - y)).Sum());
        }
    }
}
```

### Key Takeaways (2 minutes)

#### **🎯 Optimization Strategy Selection**

**Grid Search**: Best when few parameters and computational budget allows exhaustive search

**Random Search**: More efficient than grid search, good baseline approach

**Bayesian Optimization**: Most sophisticated, learns from previous evaluations to guide search

#### **⚡ Performance Tips**

- **Start with Random Search** (quick baseline)
- **Use Bayesian for expensive models** (fewer evaluations needed)
- **Parallel evaluation** when computationally feasible
- **Early stopping** based on convergence criteria

**Ready for Part 3C (Production Deployment)?** 🚀
