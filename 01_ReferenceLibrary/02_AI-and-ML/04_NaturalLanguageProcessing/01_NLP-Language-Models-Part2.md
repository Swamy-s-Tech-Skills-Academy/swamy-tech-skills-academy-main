# 01_NLP-Language-Models-Part2: Statistical Language Models & N-grams

**Learning Level**: Intermediate  
**Prerequisites**: NLP Part 1 (Text Processing), Basic Probability Theory, Statistical Concepts  
**Estimated Time**: Part 2 of 5 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master statistical language models with N-gram probability calculations
- Implement advanced smoothing techniques (Laplace, Good-Turing, Kneser-Ney)
- Build Markov chain text generation systems with controllable randomness
- Design efficient N-gram storage and retrieval systems for production use

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

Statistical language models predict the probability of word sequences using **N-grams** - sequences of N consecutive words. **Unigrams** (1-gram) model individual words, **bigrams** (2-gram) model word pairs, **trigrams** (3-gram) model triples. Higher-order N-grams capture more context but require exponentially more training data.

**Core Concepts**:

- **Maximum Likelihood Estimation**: P(word|context) = count(context+word) / count(context)
- **Smoothing**: Handle unseen N-grams to avoid zero probabilities
- **Perplexity**: Measure model quality - lower perplexity indicates better prediction
- **Text Generation**: Sample from probability distributions to generate coherent text

**Smoothing Techniques**:

- **Laplace (Add-1)**: Add 1 to all counts to avoid zeros
- **Good-Turing**: Estimate probabilities of unseen events using frequency statistics
- **Kneser-Ney**: Advanced backoff with absolute discounting
- **Interpolation**: Combine multiple N-gram orders with weighted averaging

### Core Implementation (6 minutes)

```csharp
// ✅ Advanced Statistical Language Model Framework
namespace NLP.LanguageModels
{
    // N-gram Language Model with Advanced Smoothing
    public class NGramLanguageModel
    {
        private readonly int _nGramOrder;
        private readonly SmoothingMethod _smoothingMethod;
        private readonly Dictionary<string, int> _nGramCounts;
        private readonly Dictionary<string, int> _contextCounts;
        private readonly Dictionary<string, double> _nGramProbabilities;
        private readonly HashSet<string> _vocabulary;
        private readonly Random _random;
        private readonly ILogger _logger;
        
        // Smoothing parameters
        private readonly double _laplaceSmoothingAlpha;
        private readonly double _kneserNeyDiscount;
        
        public int VocabularySize => _vocabulary.Count;
        public int NGramOrder => _nGramOrder;
        public long TotalNGrams => _nGramCounts.Values.Sum();
        
        public NGramLanguageModel(int nGramOrder = 3, 
            SmoothingMethod smoothingMethod = SmoothingMethod.KneserNey,
            double laplaceSmoothingAlpha = 1.0,
            double kneserNeyDiscount = 0.75)
        {
            _nGramOrder = Math.Max(1, nGramOrder);
            _smoothingMethod = smoothingMethod;
            _laplaceSmoothingAlpha = laplaceSmoothingAlpha;
            _kneserNeyDiscount = kneserNeyDiscount;
            
            _nGramCounts = new Dictionary<string, int>();
            _contextCounts = new Dictionary<string, int>();
            _nGramProbabilities = new Dictionary<string, double>();
            _vocabulary = new HashSet<string>();
            _random = new Random();
            _logger = LogManager.GetCurrentClassLogger();
        }
        
        public async Task TrainAsync(IEnumerable<string> documents)
        {
            _logger.Info($"Training {_nGramOrder}-gram model with {_smoothingMethod} smoothing...");
            var stopwatch = Stopwatch.StartNew();
            
            // Clear previous training data
            _nGramCounts.Clear();
            _contextCounts.Clear();
            _nGramProbabilities.Clear();
            _vocabulary.Clear();
            
            // Process each document
            var documentCount = 0;
            foreach (var document in documents)
            {
                await ProcessDocumentAsync(document);
                documentCount++;
                
                if (documentCount % 1000 == 0)
                {
                    _logger.Debug($"Processed {documentCount} documents...");
                }
            }
            
            // Calculate probabilities with smoothing
            await CalculateProbabilitiesAsync();
            
            stopwatch.Stop();
            _logger.Info($"Training completed. Processed {documentCount} documents, " +
                        $"Vocabulary: {VocabularySize:N0}, N-grams: {TotalNGrams:N0}, " +
                        $"Time: {stopwatch.Elapsed.TotalSeconds:F2}s");
        }
        
        private async Task ProcessDocumentAsync(string document)
        {
            // Tokenize document (simplified - in practice, use TextProcessor from Part 1)
            var tokens = document.ToLowerInvariant()
                .Split(new[] { ' ', '\t', '\n', '.', '!', '?' }, StringSplitOptions.RemoveEmptyEntries)
                .Where(token => !string.IsNullOrWhiteSpace(token))
                .ToList();
            
            // Add sentence boundaries
            tokens.Insert(0, "<s>");
            tokens.Add("</s>");
            
            // Update vocabulary
            foreach (var token in tokens)
            {
                _vocabulary.Add(token);
            }
            
            // Extract N-grams
            for (int i = 0; i <= tokens.Count - _nGramOrder; i++)
            {
                var nGram = string.Join(" ", tokens.Skip(i).Take(_nGramOrder));
                var context = _nGramOrder > 1 ? string.Join(" ", tokens.Skip(i).Take(_nGramOrder - 1)) : "";
                
                _nGramCounts[nGram] = _nGramCounts.GetValueOrDefault(nGram, 0) + 1;
                
                if (_nGramOrder > 1)
                {
                    _contextCounts[context] = _contextCounts.GetValueOrDefault(context, 0) + 1;
                }
            }
        }
        
        private async Task CalculateProbabilitiesAsync()
        {
            _nGramProbabilities.Clear();
            
            switch (_smoothingMethod)
            {
                case SmoothingMethod.MaximumLikelihood:
                    CalculateMLEProbabilities();
                    break;
                
                case SmoothingMethod.Laplace:
                    CalculateLaplaceProbabilities();
                    break;
                
                case SmoothingMethod.GoodTuring:
                    CalculateGoodTuringProbabilities();
                    break;
                
                case SmoothingMethod.KneserNey:
                    await CalculateKneserNeyProbabilitiesAsync();
                    break;
                
                default:
                    throw new NotSupportedException($"Smoothing method {_smoothingMethod} not supported");
            }
        }
        
        private void CalculateMLEProbabilities()
        {
            foreach (var nGramEntry in _nGramCounts)
            {
                var nGram = nGramEntry.Key;
                var count = nGramEntry.Value;
                
                if (_nGramOrder == 1)
                {
                    // Unigram: P(w) = count(w) / total_tokens
                    _nGramProbabilities[nGram] = (double)count / TotalNGrams;
                }
                else
                {
                    // Higher-order: P(w|context) = count(context+w) / count(context)
                    var context = string.Join(" ", nGram.Split(' ').Take(_nGramOrder - 1));
                    var contextCount = _contextCounts.GetValueOrDefault(context, 0);
                    
                    _nGramProbabilities[nGram] = contextCount > 0 ? (double)count / contextCount : 0.0;
                }
            }
        }
        
        private void CalculateLaplaceProbabilities()
        {
            foreach (var nGramEntry in _nGramCounts)
            {
                var nGram = nGramEntry.Key;
                var count = nGramEntry.Value;
                
                if (_nGramOrder == 1)
                {
                    // Laplace smoothing: P(w) = (count(w) + α) / (total_tokens + α * |V|)
                    _nGramProbabilities[nGram] = (count + _laplaceSmoothingAlpha) / 
                        (TotalNGrams + _laplaceSmoothingAlpha * VocabularySize);
                }
                else
                {
                    // Laplace for higher-order N-grams
                    var context = string.Join(" ", nGram.Split(' ').Take(_nGramOrder - 1));
                    var contextCount = _contextCounts.GetValueOrDefault(context, 0);
                    
                    _nGramProbabilities[nGram] = (count + _laplaceSmoothingAlpha) / 
                        (contextCount + _laplaceSmoothingAlpha * VocabularySize);
                }
            }
        }
        
        private void CalculateGoodTuringProbabilities()
        {
            // Good-Turing smoothing implementation
            var frequencyOfFrequencies = new Dictionary<int, int>();
            
            // Count frequency of frequencies
            foreach (var count in _nGramCounts.Values)
            {
                frequencyOfFrequencies[count] = frequencyOfFrequencies.GetValueOrDefault(count, 0) + 1;
            }
            
            // Calculate Good-Turing estimates
            foreach (var nGramEntry in _nGramCounts)
            {
                var nGram = nGramEntry.Key;
                var count = nGramEntry.Value;
                
                var adjustedCount = count;
                if (frequencyOfFrequencies.ContainsKey(count + 1))
                {
                    // Good-Turing: c* = (c + 1) * N(c+1) / N(c)
                    adjustedCount = (count + 1.0) * frequencyOfFrequencies[count + 1] / 
                        frequencyOfFrequencies[count];
                }
                
                if (_nGramOrder == 1)
                {
                    _nGramProbabilities[nGram] = adjustedCount / TotalNGrams;
                }
                else
                {
                    var context = string.Join(" ", nGram.Split(' ').Take(_nGramOrder - 1));
                    var contextCount = _contextCounts.GetValueOrDefault(context, 0);
                    
                    _nGramProbabilities[nGram] = contextCount > 0 ? adjustedCount / contextCount : 0.0;
                }
            }
        }
        
        private async Task CalculateKneserNeyProbabilitiesAsync()
        {
            // Kneser-Ney smoothing with absolute discounting
            var totalContinuationCount = _nGramCounts.Count; // Number of unique N-grams
            
            foreach (var nGramEntry in _nGramCounts)
            {
                var nGram = nGramEntry.Key;
                var count = nGramEntry.Value;
                
                if (_nGramOrder == 1)
                {
                    // Unigram case: Use continuation count
                    var continuationCount = CountContinuations(nGram);
                    _nGramProbabilities[nGram] = (double)continuationCount / totalContinuationCount;
                }
                else
                {
                    // Higher-order: P_KN(w|context) = max(count - D, 0) / count(context) + λ(context) * P_KN(w|shorter_context)
                    var context = string.Join(" ", nGram.Split(' ').Take(_nGramOrder - 1));
                    var contextCount = _contextCounts.GetValueOrDefault(context, 0);
                    var word = nGram.Split(' ').Last();
                    
                    if (contextCount > 0)
                    {
                        var discountedCount = Math.Max(count - _kneserNeyDiscount, 0.0);
                        var mainProb = discountedCount / contextCount;
                        
                        // Backoff probability (simplified)
                        var lambda = CalculateKneserNeyLambda(context);
                        var backoffProb = GetBackoffProbability(word);
                        
                        _nGramProbabilities[nGram] = mainProb + lambda * backoffProb;
                    }
                    else
                    {
                        _nGramProbabilities[nGram] = GetBackoffProbability(word);
                    }
                }
            }
        }
        
        private int CountContinuations(string word)
        {
            // Count how many different contexts this word appears in
            return _nGramCounts.Keys
                .Where(nGram => nGram.Split(' ').Last() == word)
                .Select(nGram => string.Join(" ", nGram.Split(' ').Take(_nGramOrder - 1)))
                .Distinct()
                .Count();
        }
        
        private double CalculateKneserNeyLambda(string context)
        {
            var contextCount = _contextCounts.GetValueOrDefault(context, 0);
            if (contextCount == 0) return 0.0;
            
            // Lambda = (D * number_of_unique_continuations) / count(context)
            var uniqueContinuations = _nGramCounts.Keys
                .Where(nGram => nGram.StartsWith(context + " "))
                .Count();
            
            return (_kneserNeyDiscount * uniqueContinuations) / contextCount;
        }
        
        private double GetBackoffProbability(string word)
        {
            // Simplified backoff - use unigram probability
            if (_nGramOrder > 1)
            {
                var unigramCount = _nGramCounts.GetValueOrDefault(word, 0);
                return (double)unigramCount / TotalNGrams;
            }
            return 1.0 / VocabularySize;
        }
        
        public double GetProbability(string nGram)
        {
            return _nGramProbabilities.GetValueOrDefault(nGram, GetBackoffProbability(nGram.Split(' ').Last()));
        }
        
        public double CalculatePerplexity(IEnumerable<string> testDocuments)
        {
            var totalLogProb = 0.0;
            var totalTokens = 0;
            
            foreach (var document in testDocuments)
            {
                var tokens = document.ToLowerInvariant()
                    .Split(new[] { ' ', '\t', '\n', '.', '!', '?' }, StringSplitOptions.RemoveEmptyEntries)
                    .Where(token => !string.IsNullOrWhiteSpace(token))
                    .ToList();
                
                tokens.Insert(0, "<s>");
                tokens.Add("</s>");
                
                for (int i = 0; i <= tokens.Count - _nGramOrder; i++)
                {
                    var nGram = string.Join(" ", tokens.Skip(i).Take(_nGramOrder));
                    var prob = GetProbability(nGram);
                    
                    if (prob > 0)
                    {
                        totalLogProb += Math.Log2(prob);
                        totalTokens++;
                    }
                }
            }
            
            var averageLogProb = totalTokens > 0 ? totalLogProb / totalTokens : 0;
            return Math.Pow(2, -averageLogProb);
        }
        
        public async Task<string> GenerateTextAsync(int maxTokens = 100, string seedText = "<s>")
        {
            var tokens = new List<string>(seedText.Split(' '));
            
            for (int i = 0; i < maxTokens; i++)
            {
                var nextToken = await GenerateNextTokenAsync(tokens);
                tokens.Add(nextToken);
                
                if (nextToken == "</s>")
                    break;
            }
            
            return string.Join(" ", tokens.Skip(1).Where(t => t != "</s>"));
        }
        
        private async Task<string> GenerateNextTokenAsync(List<string> context)
        {
            var relevantContext = context.Count >= _nGramOrder - 1 
                ? context.Skip(context.Count - (_nGramOrder - 1)).ToList()
                : context;
            
            var contextStr = string.Join(" ", relevantContext);
            
            // Find all possible continuations
            var candidates = _nGramCounts.Keys
                .Where(nGram => nGram.StartsWith(contextStr + " ") || (_nGramOrder == 1))
                .Select(nGram => new
                {
                    Token = _nGramOrder == 1 ? nGram : nGram.Split(' ').Last(),
                    Probability = GetProbability(nGram)
                })
                .Where(c => c.Probability > 0)
                .OrderByDescending(c => c.Probability)
                .ToList();
            
            if (!candidates.Any())
                return "</s>";
            
            // Sample from probability distribution
            return SampleFromDistribution(candidates.Select(c => (c.Token, c.Probability)));
        }
        
        private string SampleFromDistribution(IEnumerable<(string token, double probability)> distribution)
        {
            var totalProb = distribution.Sum(d => d.probability);
            var randomValue = _random.NextDouble() * totalProb;
            
            var cumulativeProb = 0.0;
            foreach (var (token, probability) in distribution)
            {
                cumulativeProb += probability;
                if (randomValue <= cumulativeProb)
                    return token;
            }
            
            return distribution.First().token;
        }
        
        public LanguageModelStats GetStatistics()
        {
            var nGramFrequencies = _nGramCounts.Values.GroupBy(count => count)
                .ToDictionary(g => g.Key, g => g.Count());
            
            return new LanguageModelStats
            {
                NGramOrder = _nGramOrder,
                VocabularySize = VocabularySize,
                TotalNGrams = TotalNGrams,
                UniqueNGrams = _nGramCounts.Count,
                SmoothingMethod = _smoothingMethod,
                FrequencyDistribution = nGramFrequencies,
                SparsityRatio = (double)_nGramCounts.Count / Math.Pow(VocabularySize, _nGramOrder)
            };
        }
    }
    
    // Language Model Performance Evaluator
    public class LanguageModelEvaluator
    {
        public async Task<ModelComparisonResult> CompareModelsAsync(
            Dictionary<string, NGramLanguageModel> models,
            IEnumerable<string> testData)
        {
            var results = new Dictionary<string, EvaluationMetrics>();
            
            foreach (var (modelName, model) in models)
            {
                var perplexity = model.CalculatePerplexity(testData);
                var crossEntropy = Math.Log2(perplexity);
                var stats = model.GetStatistics();
                
                results[modelName] = new EvaluationMetrics
                {
                    Perplexity = perplexity,
                    CrossEntropy = crossEntropy,
                    VocabularySize = stats.VocabularySize,
                    ModelSize = stats.TotalNGrams,
                    SparsityRatio = stats.SparsityRatio
                };
            }
            
            var bestModel = results.OrderBy(r => r.Value.Perplexity).First();
            
            return new ModelComparisonResult
            {
                ModelResults = results,
                BestModelName = bestModel.Key,
                BestPerplexity = bestModel.Value.Perplexity
            };
        }
    }
    
    // Supporting Enums and Data Structures
    public enum SmoothingMethod
    {
        MaximumLikelihood,
        Laplace,
        GoodTuring,
        KneserNey
    }
    
    public class LanguageModelStats
    {
        public int NGramOrder { get; set; }
        public int VocabularySize { get; set; }
        public long TotalNGrams { get; set; }
        public int UniqueNGrams { get; set; }
        public SmoothingMethod SmoothingMethod { get; set; }
        public Dictionary<int, int> FrequencyDistribution { get; set; }
        public double SparsityRatio { get; set; }
    }
    
    public class EvaluationMetrics
    {
        public double Perplexity { get; set; }
        public double CrossEntropy { get; set; }
        public int VocabularySize { get; set; }
        public long ModelSize { get; set; }
        public double SparsityRatio { get; set; }
    }
    
    public class ModelComparisonResult
    {
        public Dictionary<string, EvaluationMetrics> ModelResults { get; set; }
        public string BestModelName { get; set; }
        public double BestPerplexity { get; set; }
    }
}
```

### Key Takeaways (2 minutes)

#### **🎯 Statistical Language Model Mastery**

**Advanced N-gram Implementation**: Configurable order with efficient storage and retrieval

**Multiple Smoothing Techniques**: MLE, Laplace, Good-Turing, and Kneser-Ney smoothing

**Text Generation**: Probabilistic sampling from learned distributions

**Model Evaluation**: Perplexity and cross-entropy metrics for quality assessment

#### **⚡ Production Features**

- **Memory Efficient**: Optimized N-gram storage with frequency-of-frequencies tracking
- **Configurable Training**: Flexible smoothing parameters and training options  
- **Performance Metrics**: Comprehensive statistics and model comparison tools
- **Robust Generation**: Probabilistic text generation with proper backoff handling

**Ready for Part 3 (Word Embeddings & Vector Representations)?** 🚀
