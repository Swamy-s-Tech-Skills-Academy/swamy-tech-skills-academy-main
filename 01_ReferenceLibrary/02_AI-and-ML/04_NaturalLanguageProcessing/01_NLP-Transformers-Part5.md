# 01_NLP-Transformers-Part5: Transformer Applications & Modern NLP

**Learning Level**: Advanced  
**Prerequisites**: NLP Parts 1-4, Attention Mechanisms, Deep Learning Fundamentals  
**Estimated Time**: Part 5 of 5 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master Transformer architecture with self-attention and multi-head attention mechanisms
- Implement BERT-style bidirectional encoding for classification and question answering
- Build GPT-style autoregressive generation for text completion and dialogue systems
- Design modern NLP pipelines with pre-trained models and fine-tuning workflows

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

Transformers revolutionized NLP by replacing recurrence with **self-attention**, allowing parallel processing and better long-range dependencies. **BERT** uses bidirectional encoding for understanding tasks (classification, QA), while **GPT** uses autoregressive decoding for generation tasks. **Multi-head attention** captures different types of relationships simultaneously.

**Core Components**:

- **Self-Attention**: Query, Key, Value matrices for attention weight calculation
- **Multi-Head Attention**: Multiple parallel attention mechanisms with different learned projections  
- **Positional Encoding**: Add position information since transformers have no inherent sequence order
- **Layer Normalization**: Stabilize training with residual connections

**Modern Applications**:

- **BERT**: Masked language modeling for bidirectional understanding
- **GPT**: Autoregressive generation with causal attention masking  
- **T5**: Text-to-text unified framework for all NLP tasks
- **Fine-tuning**: Adapt pre-trained models to specific downstream tasks

### Core Implementation (6 minutes)

```csharp
// ✅ Transformer Architecture Framework
namespace NLP.Transformers
{
    // Multi-Head Self-Attention Implementation
    public class MultiHeadAttention
    {
        private readonly int _embedSize;
        private readonly int _numHeads;
        private readonly int _headDim;
        private readonly double[,] _queryWeights;
        private readonly double[,] _keyWeights;
        private readonly double[,] _valueWeights;
        private readonly double[,] _outputWeights;
        private readonly double _attentionDropout;
        private readonly Random _random;
        
        public MultiHeadAttention(int embedSize, int numHeads, double attentionDropout = 0.1)
        {
            _embedSize = embedSize;
            _numHeads = numHeads;
            _headDim = embedSize / numHeads;
            _attentionDropout = attentionDropout;
            _random = new Random();
            
            if (embedSize % numHeads != 0)
                throw new ArgumentException("Embedding size must be divisible by number of heads");
            
            // Initialize weight matrices with Xavier initialization
            var limit = Math.Sqrt(6.0 / (2 * embedSize));
            
            _queryWeights = InitializeMatrix(embedSize, embedSize, limit);
            _keyWeights = InitializeMatrix(embedSize, embedSize, limit);
            _valueWeights = InitializeMatrix(embedSize, embedSize, limit);
            _outputWeights = InitializeMatrix(embedSize, embedSize, limit);
        }
        
        public async Task<double[,]> ForwardAsync(double[,] input, double[,] attentionMask = null, bool isTraining = true)
        {
            var seqLength = input.GetLength(0);
            var embedSize = input.GetLength(1);
            
            // Linear transformations for Q, K, V
            var queries = MatrixMultiply(input, _queryWeights);
            var keys = MatrixMultiply(input, _keyWeights);
            var values = MatrixMultiply(input, _valueWeights);
            
            // Reshape for multi-head attention: [seq_len, embed_size] -> [seq_len, num_heads, head_dim]
            var queryHeads = ReshapeForMultiHead(queries, seqLength, _numHeads, _headDim);
            var keyHeads = ReshapeForMultiHead(keys, seqLength, _numHeads, _headDim);
            var valueHeads = ReshapeForMultiHead(values, seqLength, _numHeads, _headDim);
            
            // Scaled dot-product attention for each head
            var attentionOutputs = new double[_numHeads][,];
            
            for (int h = 0; h < _numHeads; h++)
            {
                var queryHead = ExtractHead(queryHeads, h, seqLength, _headDim);
                var keyHead = ExtractHead(keyHeads, h, seqLength, _headDim);
                var valueHead = ExtractHead(valueHeads, h, seqLength, _headDim);
                
                attentionOutputs[h] = await ScaledDotProductAttentionAsync(
                    queryHead, keyHead, valueHead, attentionMask, isTraining);
            }
            
            // Concatenate heads and apply output projection
            var concatenated = ConcatenateHeads(attentionOutputs, seqLength, _embedSize);
            var output = MatrixMultiply(concatenated, _outputWeights);
            
            return output;
        }
        
        private async Task<double[,]> ScaledDotProductAttentionAsync(
            double[,] query, double[,] key, double[,] value, 
            double[,] mask = null, bool isTraining = true)
        {
            var seqLength = query.GetLength(0);
            var headDim = query.GetLength(1);
            
            // Calculate attention scores: Q * K^T
            var scores = new double[seqLength, seqLength];
            
            for (int i = 0; i < seqLength; i++)
            {
                for (int j = 0; j < seqLength; j++)
                {
                    var score = 0.0;
                    for (int k = 0; k < headDim; k++)
                    {
                        score += query[i, k] * key[j, k];
                    }
                    scores[i, j] = score / Math.Sqrt(headDim); // Scale by sqrt(d_k)
                }
            }
            
            // Apply attention mask if provided
            if (mask != null)
            {
                for (int i = 0; i < seqLength; i++)
                {
                    for (int j = 0; j < seqLength; j++)
                    {
                        if (mask[i, j] == 0)
                        {
                            scores[i, j] = double.NegativeInfinity;
                        }
                    }
                }
            }
            
            // Apply softmax to get attention weights
            var attentionWeights = ApplySoftmax(scores);
            
            // Apply dropout if training
            if (isTraining && _attentionDropout > 0)
            {
                attentionWeights = ApplyDropout(attentionWeights, _attentionDropout);
            }
            
            // Apply attention to values: Attention * V
            var output = new double[seqLength, headDim];
            
            for (int i = 0; i < seqLength; i++)
            {
                for (int d = 0; d < headDim; d++)
                {
                    var sum = 0.0;
                    for (int j = 0; j < seqLength; j++)
                    {
                        sum += attentionWeights[i, j] * value[j, d];
                    }
                    output[i, d] = sum;
                }
            }
            
            return output;
        }
        
        private double[,] ApplySoftmax(double[,] scores)
        {
            var seqLength = scores.GetLength(0);
            var result = new double[seqLength, seqLength];
            
            for (int i = 0; i < seqLength; i++)
            {
                // Find max for numerical stability
                var maxScore = double.NegativeInfinity;
                for (int j = 0; j < seqLength; j++)
                {
                    if (scores[i, j] > maxScore)
                        maxScore = scores[i, j];
                }
                
                // Calculate softmax
                var sumExp = 0.0;
                for (int j = 0; j < seqLength; j++)
                {
                    if (!double.IsNegativeInfinity(scores[i, j]))
                    {
                        sumExp += Math.Exp(scores[i, j] - maxScore);
                    }
                }
                
                for (int j = 0; j < seqLength; j++)
                {
                    if (double.IsNegativeInfinity(scores[i, j]))
                    {
                        result[i, j] = 0.0;
                    }
                    else
                    {
                        result[i, j] = Math.Exp(scores[i, j] - maxScore) / sumExp;
                    }
                }
            }
            
            return result;
        }
        
        private double[,] ApplyDropout(double[,] input, double dropoutRate)
        {
            var rows = input.GetLength(0);
            var cols = input.GetLength(1);
            var result = new double[rows, cols];
            
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    result[i, j] = _random.NextDouble() > dropoutRate ? input[i, j] / (1 - dropoutRate) : 0.0;
                }
            }
            
            return result;
        }
        
        private double[,] InitializeMatrix(int rows, int cols, double limit)
        {
            var matrix = new double[rows, cols];
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    matrix[i, j] = (_random.NextDouble() * 2 - 1) * limit;
                }
            }
            return matrix;
        }
        
        private double[,] MatrixMultiply(double[,] a, double[,] b)
        {
            var aRows = a.GetLength(0);
            var aCols = a.GetLength(1);
            var bCols = b.GetLength(1);
            
            var result = new double[aRows, bCols];
            
            for (int i = 0; i < aRows; i++)
            {
                for (int j = 0; j < bCols; j++)
                {
                    var sum = 0.0;
                    for (int k = 0; k < aCols; k++)
                    {
                        sum += a[i, k] * b[k, j];
                    }
                    result[i, j] = sum;
                }
            }
            
            return result;
        }
        
        private double[,,] ReshapeForMultiHead(double[,] input, int seqLength, int numHeads, int headDim)
        {
            var result = new double[seqLength, numHeads, headDim];
            
            for (int s = 0; s < seqLength; s++)
            {
                for (int h = 0; h < numHeads; h++)
                {
                    for (int d = 0; d < headDim; d++)
                    {
                        result[s, h, d] = input[s, h * headDim + d];
                    }
                }
            }
            
            return result;
        }
        
        private double[,] ExtractHead(double[,,] heads, int headIndex, int seqLength, int headDim)
        {
            var result = new double[seqLength, headDim];
            
            for (int s = 0; s < seqLength; s++)
            {
                for (int d = 0; d < headDim; d++)
                {
                    result[s, d] = heads[s, headIndex, d];
                }
            }
            
            return result;
        }
        
        private double[,] ConcatenateHeads(double[][,] attentionOutputs, int seqLength, int embedSize)
        {
            var result = new double[seqLength, embedSize];
            var headDim = embedSize / _numHeads;
            
            for (int s = 0; s < seqLength; s++)
            {
                for (int h = 0; h < _numHeads; h++)
                {
                    for (int d = 0; d < headDim; d++)
                    {
                        result[s, h * headDim + d] = attentionOutputs[h][s, d];
                    }
                }
            }
            
            return result;
        }
    }
    
    // Positional Encoding for Transformers
    public class PositionalEncoding
    {
        private readonly int _maxSequenceLength;
        private readonly int _embedSize;
        private readonly double[,] _positionEncodings;
        
        public PositionalEncoding(int maxSequenceLength, int embedSize)
        {
            _maxSequenceLength = maxSequenceLength;
            _embedSize = embedSize;
            _positionEncodings = GeneratePositionalEncodings();
        }
        
        private double[,] GeneratePositionalEncodings()
        {
            var encodings = new double[_maxSequenceLength, _embedSize];
            
            for (int pos = 0; pos < _maxSequenceLength; pos++)
            {
                for (int i = 0; i < _embedSize; i++)
                {
                    if (i % 2 == 0)
                    {
                        // Even positions: sin
                        var angle = pos / Math.Pow(10000, (double)i / _embedSize);
                        encodings[pos, i] = Math.Sin(angle);
                    }
                    else
                    {
                        // Odd positions: cos
                        var angle = pos / Math.Pow(10000, (double)(i - 1) / _embedSize);
                        encodings[pos, i] = Math.Cos(angle);
                    }
                }
            }
            
            return encodings;
        }
        
        public double[,] AddPositionalEncoding(double[,] embeddings)
        {
            var seqLength = embeddings.GetLength(0);
            var embedSize = embeddings.GetLength(1);
            var result = new double[seqLength, embedSize];
            
            for (int i = 0; i < seqLength; i++)
            {
                for (int j = 0; j < embedSize; j++)
                {
                    result[i, j] = embeddings[i, j] + _positionEncodings[i, j];
                }
            }
            
            return result;
        }
    }
    
    // Transformer Block (Encoder Layer)
    public class TransformerBlock
    {
        private readonly MultiHeadAttention _attention;
        private readonly FeedForwardNetwork _feedForward;
        private readonly LayerNormalization _norm1;
        private readonly LayerNormalization _norm2;
        private readonly double _dropout;
        private readonly Random _random;
        
        public TransformerBlock(int embedSize, int numHeads, int ffnHiddenSize, double dropout = 0.1)
        {
            _attention = new MultiHeadAttention(embedSize, numHeads, dropout);
            _feedForward = new FeedForwardNetwork(embedSize, ffnHiddenSize, dropout);
            _norm1 = new LayerNormalization(embedSize);
            _norm2 = new LayerNormalization(embedSize);
            _dropout = dropout;
            _random = new Random();
        }
        
        public async Task<double[,]> ForwardAsync(double[,] input, double[,] attentionMask = null, bool isTraining = true)
        {
            // Multi-head self-attention with residual connection and layer norm
            var attentionOutput = await _attention.ForwardAsync(input, attentionMask, isTraining);
            
            if (isTraining && _dropout > 0)
            {
                attentionOutput = ApplyDropout(attentionOutput, _dropout);
            }
            
            var afterAttention = AddResidualAndNorm(input, attentionOutput, _norm1);
            
            // Feed-forward network with residual connection and layer norm
            var ffnOutput = await _feedForward.ForwardAsync(afterAttention, isTraining);
            
            if (isTraining && _dropout > 0)
            {
                ffnOutput = ApplyDropout(ffnOutput, _dropout);
            }
            
            var output = AddResidualAndNorm(afterAttention, ffnOutput, _norm2);
            
            return output;
        }
        
        private double[,] AddResidualAndNorm(double[,] input, double[,] output, LayerNormalization norm)
        {
            var rows = input.GetLength(0);
            var cols = input.GetLength(1);
            var residual = new double[rows, cols];
            
            // Add residual connection
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    residual[i, j] = input[i, j] + output[i, j];
                }
            }
            
            // Apply layer normalization
            return norm.Forward(residual);
        }
        
        private double[,] ApplyDropout(double[,] input, double dropoutRate)
        {
            var rows = input.GetLength(0);
            var cols = input.GetLength(1);
            var result = new double[rows, cols];
            
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    result[i, j] = _random.NextDouble() > dropoutRate ? input[i, j] / (1 - dropoutRate) : 0.0;
                }
            }
            
            return result;
        }
    }
    
    // Feed-Forward Network
    public class FeedForwardNetwork
    {
        private readonly int _inputSize;
        private readonly int _hiddenSize;
        private readonly double[,] _weights1;
        private readonly double[] _biases1;
        private readonly double[,] _weights2;
        private readonly double[] _biases2;
        private readonly double _dropout;
        private readonly Random _random;
        
        public FeedForwardNetwork(int inputSize, int hiddenSize, double dropout = 0.1)
        {
            _inputSize = inputSize;
            _hiddenSize = hiddenSize;
            _dropout = dropout;
            _random = new Random();
            
            // Initialize weights with Xavier initialization
            var limit1 = Math.Sqrt(6.0 / (inputSize + hiddenSize));
            var limit2 = Math.Sqrt(6.0 / (hiddenSize + inputSize));
            
            _weights1 = InitializeMatrix(inputSize, hiddenSize, limit1);
            _biases1 = new double[hiddenSize];
            
            _weights2 = InitializeMatrix(hiddenSize, inputSize, limit2);
            _biases2 = new double[inputSize];
        }
        
        public async Task<double[,]> ForwardAsync(double[,] input, bool isTraining = true)
        {
            var seqLength = input.GetLength(0);
            
            // First linear transformation + ReLU activation
            var hidden = MatrixMultiplyAndAddBias(input, _weights1, _biases1);
            hidden = ApplyReLU(hidden);
            
            // Apply dropout if training
            if (isTraining && _dropout > 0)
            {
                hidden = ApplyDropout(hidden, _dropout);
            }
            
            // Second linear transformation
            var output = MatrixMultiplyAndAddBias(hidden, _weights2, _biases2);
            
            return output;
        }
        
        private double[,] MatrixMultiplyAndAddBias(double[,] input, double[,] weights, double[] biases)
        {
            var inputRows = input.GetLength(0);
            var inputCols = input.GetLength(1);
            var outputCols = weights.GetLength(1);
            
            var result = new double[inputRows, outputCols];
            
            for (int i = 0; i < inputRows; i++)
            {
                for (int j = 0; j < outputCols; j++)
                {
                    var sum = biases[j];
                    for (int k = 0; k < inputCols; k++)
                    {
                        sum += input[i, k] * weights[k, j];
                    }
                    result[i, j] = sum;
                }
            }
            
            return result;
        }
        
        private double[,] ApplyReLU(double[,] input)
        {
            var rows = input.GetLength(0);
            var cols = input.GetLength(1);
            var result = new double[rows, cols];
            
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    result[i, j] = Math.Max(0, input[i, j]);
                }
            }
            
            return result;
        }
        
        private double[,] ApplyDropout(double[,] input, double dropoutRate)
        {
            var rows = input.GetLength(0);
            var cols = input.GetLength(1);
            var result = new double[rows, cols];
            
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    result[i, j] = _random.NextDouble() > dropoutRate ? input[i, j] / (1 - dropoutRate) : 0.0;
                }
            }
            
            return result;
        }
        
        private double[,] InitializeMatrix(int rows, int cols, double limit)
        {
            var matrix = new double[rows, cols];
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    matrix[i, j] = (_random.NextDouble() * 2 - 1) * limit;
                }
            }
            return matrix;
        }
    }
    
    // Layer Normalization
    public class LayerNormalization
    {
        private readonly int _size;
        private readonly double[] _gamma;
        private readonly double[] _beta;
        private readonly double _epsilon;
        
        public LayerNormalization(int size, double epsilon = 1e-6)
        {
            _size = size;
            _epsilon = epsilon;
            _gamma = Enumerable.Repeat(1.0, size).ToArray();
            _beta = new double[size];
        }
        
        public double[,] Forward(double[,] input)
        {
            var seqLength = input.GetLength(0);
            var embedSize = input.GetLength(1);
            var result = new double[seqLength, embedSize];
            
            for (int i = 0; i < seqLength; i++)
            {
                // Calculate mean and variance for this sequence position
                var mean = 0.0;
                for (int j = 0; j < embedSize; j++)
                {
                    mean += input[i, j];
                }
                mean /= embedSize;
                
                var variance = 0.0;
                for (int j = 0; j < embedSize; j++)
                {
                    var diff = input[i, j] - mean;
                    variance += diff * diff;
                }
                variance /= embedSize;
                
                var std = Math.Sqrt(variance + _epsilon);
                
                // Normalize and apply learned parameters
                for (int j = 0; j < embedSize; j++)
                {
                    var normalized = (input[i, j] - mean) / std;
                    result[i, j] = _gamma[j] * normalized + _beta[j];
                }
            }
            
            return result;
        }
    }
    
    // BERT-style Model for Classification
    public class BERTClassifier
    {
        private readonly BERTConfig _config;
        private readonly List<TransformerBlock> _encoderLayers;
        private readonly PositionalEncoding _positionalEncoding;
        private readonly double[,] _tokenEmbeddings;
        private readonly double[,] _classificationHead;
        private readonly Dictionary<string, int> _vocabulary;
        private readonly ILogger _logger;
        
        public BERTClassifier(BERTConfig config)
        {
            _config = config;
            _encoderLayers = new List<TransformerBlock>();
            _vocabulary = new Dictionary<string, int>();
            _logger = LogManager.GetCurrentClassLogger();
            
            // Initialize encoder layers
            for (int i = 0; i < config.NumLayers; i++)
            {
                _encoderLayers.Add(new TransformerBlock(
                    config.EmbedSize, 
                    config.NumHeads, 
                    config.FfnHiddenSize, 
                    config.Dropout));
            }
            
            _positionalEncoding = new PositionalEncoding(config.MaxSequenceLength, config.EmbedSize);
        }
        
        public async Task<string> ClassifyAsync(string text)
        {
            // Tokenize and encode input
            var tokens = TokenizeText(text);
            var tokenIds = tokens.Select(t => _vocabulary.GetValueOrDefault(t, 0)).ToArray();
            
            // Create token embeddings
            var embeddings = CreateTokenEmbeddings(tokenIds);
            
            // Add positional encodings
            var input = _positionalEncoding.AddPositionalEncoding(embeddings);
            
            // Pass through encoder layers
            var output = input;
            foreach (var layer in _encoderLayers)
            {
                output = await layer.ForwardAsync(output, isTraining: false);
            }
            
            // Use [CLS] token representation for classification
            var clsRepresentation = ExtractCLSToken(output);
            
            // Apply classification head
            var logits = ApplyClassificationHead(clsRepresentation);
            
            // Return predicted class
            var predictedIndex = Array.IndexOf(logits, logits.Max());
            return $"Class_{predictedIndex}"; // Simplified class mapping
        }
        
        private string[] TokenizeText(string text)
        {
            // Simplified tokenization - add [CLS] and [SEP] tokens
            var words = text.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries);
            var tokens = new List<string> { "[CLS]" };
            tokens.AddRange(words);
            tokens.Add("[SEP]");
            return tokens.ToArray();
        }
        
        private double[,] CreateTokenEmbeddings(int[] tokenIds)
        {
            var seqLength = tokenIds.Length;
            var embeddings = new double[seqLength, _config.EmbedSize];
            
            for (int i = 0; i < seqLength; i++)
            {
                for (int j = 0; j < _config.EmbedSize; j++)
                {
                    embeddings[i, j] = _tokenEmbeddings[tokenIds[i], j];
                }
            }
            
            return embeddings;
        }
        
        private double[] ExtractCLSToken(double[,] encoderOutput)
        {
            var clsRepresentation = new double[_config.EmbedSize];
            for (int i = 0; i < _config.EmbedSize; i++)
            {
                clsRepresentation[i] = encoderOutput[0, i]; // [CLS] is always first token
            }
            return clsRepresentation;
        }
        
        private double[] ApplyClassificationHead(double[] clsRepresentation)
        {
            var numClasses = _classificationHead.GetLength(0);
            var logits = new double[numClasses];
            
            for (int i = 0; i < numClasses; i++)
            {
                var sum = 0.0;
                for (int j = 0; j < _config.EmbedSize; j++)
                {
                    sum += _classificationHead[i, j] * clsRepresentation[j];
                }
                logits[i] = sum;
            }
            
            // Apply softmax
            var maxLogit = logits.Max();
            var exps = logits.Select(x => Math.Exp(x - maxLogit)).ToArray();
            var sumExps = exps.Sum();
            
            return exps.Select(exp => exp / sumExps).ToArray();
        }
    }
    
    // GPT-style Autoregressive Generator
    public class GPTGenerator
    {
        private readonly GPTConfig _config;
        private readonly List<TransformerBlock> _decoderLayers;
        private readonly PositionalEncoding _positionalEncoding;
        private readonly double[,] _tokenEmbeddings;
        private readonly double[,] _outputProjection;
        private readonly Dictionary<string, int> _vocabulary;
        private readonly Dictionary<int, string> _indexToWord;
        private readonly Random _random;
        private readonly ILogger _logger;
        
        public GPTGenerator(GPTConfig config)
        {
            _config = config;
            _decoderLayers = new List<TransformerBlock>();
            _vocabulary = new Dictionary<string, int>();
            _indexToWord = new Dictionary<int, string>();
            _random = new Random();
            _logger = LogManager.GetCurrentClassLogger();
            
            // Initialize decoder layers
            for (int i = 0; i < config.NumLayers; i++)
            {
                _decoderLayers.Add(new TransformerBlock(
                    config.EmbedSize, 
                    config.NumHeads, 
                    config.FfnHiddenSize, 
                    config.Dropout));
            }
            
            _positionalEncoding = new PositionalEncoding(config.MaxSequenceLength, config.EmbedSize);
        }
        
        public async Task<string> GenerateAsync(string prompt, int maxTokens = 50, double temperature = 1.0)
        {
            var tokens = TokenizeText(prompt).ToList();
            
            for (int i = 0; i < maxTokens; i++)
            {
                var nextToken = await GenerateNextTokenAsync(tokens, temperature);
                tokens.Add(nextToken);
                
                if (nextToken == "[END]" || tokens.Count >= _config.MaxSequenceLength)
                    break;
            }
            
            // Convert back to text (skip prompt tokens)
            var generatedTokens = tokens.Skip(TokenizeText(prompt).Length);
            return string.Join(" ", generatedTokens.Where(t => t != "[END]"));
        }
        
        private async Task<string> GenerateNextTokenAsync(List<string> tokens, double temperature)
        {
            // Convert tokens to embeddings
            var tokenIds = tokens.Select(t => _vocabulary.GetValueOrDefault(t, 0)).ToArray();
            var embeddings = CreateTokenEmbeddings(tokenIds);
            
            // Add positional encoding
            var input = _positionalEncoding.AddPositionalEncoding(embeddings);
            
            // Create causal attention mask (lower triangular)
            var attentionMask = CreateCausalMask(tokens.Count);
            
            // Pass through decoder layers
            var output = input;
            foreach (var layer in _decoderLayers)
            {
                output = await layer.ForwardAsync(output, attentionMask, isTraining: false);
            }
            
            // Get last token representation
            var lastTokenOutput = ExtractLastToken(output);
            
            // Project to vocabulary space
            var logits = ProjectToVocabulary(lastTokenOutput);
            
            // Apply temperature scaling
            for (int i = 0; i < logits.Length; i++)
            {
                logits[i] /= temperature;
            }
            
            // Sample from probability distribution
            var probabilities = Softmax(logits);
            var sampledIndex = SampleFromDistribution(probabilities);
            
            return _indexToWord.GetValueOrDefault(sampledIndex, "[UNK]");
        }
        
        private double[,] CreateCausalMask(int seqLength)
        {
            var mask = new double[seqLength, seqLength];
            
            for (int i = 0; i < seqLength; i++)
            {
                for (int j = 0; j < seqLength; j++)
                {
                    mask[i, j] = j <= i ? 1.0 : 0.0; // Can only attend to previous positions
                }
            }
            
            return mask;
        }
        
        private string[] TokenizeText(string text)
        {
            return text.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries);
        }
        
        private double[,] CreateTokenEmbeddings(int[] tokenIds)
        {
            var seqLength = tokenIds.Length;
            var embeddings = new double[seqLength, _config.EmbedSize];
            
            for (int i = 0; i < seqLength; i++)
            {
                for (int j = 0; j < _config.EmbedSize; j++)
                {
                    embeddings[i, j] = _tokenEmbeddings[tokenIds[i], j];
                }
            }
            
            return embeddings;
        }
        
        private double[] ExtractLastToken(double[,] output)
        {
            var seqLength = output.GetLength(0);
            var embedSize = output.GetLength(1);
            var lastToken = new double[embedSize];
            
            for (int i = 0; i < embedSize; i++)
            {
                lastToken[i] = output[seqLength - 1, i];
            }
            
            return lastToken;
        }
        
        private double[] ProjectToVocabulary(double[] hidden)
        {
            var vocabSize = _outputProjection.GetLength(0);
            var logits = new double[vocabSize];
            
            for (int i = 0; i < vocabSize; i++)
            {
                var sum = 0.0;
                for (int j = 0; j < hidden.Length; j++)
                {
                    sum += _outputProjection[i, j] * hidden[j];
                }
                logits[i] = sum;
            }
            
            return logits;
        }
        
        private double[] Softmax(double[] logits)
        {
            var maxLogit = logits.Max();
            var exps = logits.Select(x => Math.Exp(x - maxLogit)).ToArray();
            var sumExps = exps.Sum();
            
            return exps.Select(exp => exp / sumExps).ToArray();
        }
        
        private int SampleFromDistribution(double[] probabilities)
        {
            var randomValue = _random.NextDouble();
            var cumulativeProbability = 0.0;
            
            for (int i = 0; i < probabilities.Length; i++)
            {
                cumulativeProbability += probabilities[i];
                if (randomValue <= cumulativeProbability)
                    return i;
            }
            
            return probabilities.Length - 1; // Fallback to last token
        }
    }
    
    // Configuration Classes
    public class BERTConfig
    {
        public int EmbedSize { get; set; } = 768;
        public int NumHeads { get; set; } = 12;
        public int NumLayers { get; set; } = 12;
        public int FfnHiddenSize { get; set; } = 3072;
        public int MaxSequenceLength { get; set; } = 512;
        public double Dropout { get; set; } = 0.1;
        public int NumClasses { get; set; } = 2;
    }
    
    public class GPTConfig
    {
        public int EmbedSize { get; set; } = 768;
        public int NumHeads { get; set; } = 12;
        public int NumLayers { get; set; } = 12;
        public int FfnHiddenSize { get; set; } = 3072;
        public int MaxSequenceLength { get; set; } = 1024;
        public double Dropout { get; set; } = 0.1;
        public int VocabularySize { get; set; } = 50000;
    }
}
```

### Key Takeaways (2 minutes)

#### **🎯 Transformer Architecture Mastery**

**Multi-Head Self-Attention**: Complete implementation with query/key/value projections and scaled dot-product attention

**Positional Encoding**: Sinusoidal position embeddings for sequence order awareness

**Modern Architectures**: BERT for bidirectional understanding and GPT for autoregressive generation

**Production Components**: Layer normalization, residual connections, and dropout regularization

#### **⚡ State-of-the-Art Features**

- **Parallelizable Training**: Self-attention enables parallel processing unlike RNNs
- **Long-Range Dependencies**: Direct connections between any input positions
- **Transfer Learning Ready**: Pre-training and fine-tuning framework architecture
- **Scalable Design**: Configurable layers, heads, and dimensions for different model sizes

**🎉 Complete NLP Track Achieved!** Ready to systematically convert all domains to 200-line format! 🚀
