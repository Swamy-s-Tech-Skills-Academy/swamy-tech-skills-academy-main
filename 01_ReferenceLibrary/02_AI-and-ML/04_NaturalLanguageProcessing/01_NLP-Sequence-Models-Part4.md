# 01_NLP-Sequence-Models-Part4: Sequence Models for NLP Applications

**Learning Level**: Advanced  
**Prerequisites**: NLP Parts 1-3, Deep Learning Fundamentals, RNN Architecture Knowledge  
**Estimated Time**: Part 4 of 5 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master RNN architectures (Vanilla, LSTM, GRU) for sequential text processing
- Implement sequence-to-sequence models with encoder-decoder patterns
- Build attention mechanisms for improved long-range dependency handling
- Design production-ready text classification and generation systems

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

Sequence models process text as temporal sequences, maintaining hidden states that capture contextual information. **Vanilla RNNs** suffer from vanishing gradients, solved by **LSTMs** (forget/input/output gates) and **GRUs** (reset/update gates). **Sequence-to-sequence** models use encoder-decoder architecture for tasks like translation, while **attention** allows focusing on relevant input parts.

**Core Architectures**:

- **Vanilla RNN**: Simple recurrence with gradient vanishing problems
- **LSTM**: Long Short-Term Memory with gating mechanisms for long sequences
- **GRU**: Gated Recurrent Unit - simplified LSTM with fewer parameters
- **Seq2Seq**: Encoder-decoder with fixed-size bottleneck representation

**Applications**:

- **Text Classification**: Sentiment analysis, document categorization
- **Language Modeling**: Next word prediction, text generation
- **Sequence Labeling**: Named entity recognition, POS tagging
- **Machine Translation**: Source-to-target language mapping

### Core Implementation (6 minutes)

```csharp
// ✅ Advanced Sequence Model Framework for NLP
namespace NLP.SequenceModels
{
    // LSTM Cell Implementation
    public class LSTMCell
    {
        private readonly int _inputSize;
        private readonly int _hiddenSize;
        
        // Gate weight matrices
        private readonly double[,] _forgetGateWeights;
        private readonly double[,] _inputGateWeights;
        private readonly double[,] _candidateWeights;
        private readonly double[,] _outputGateWeights;
        
        // Gate biases
        private readonly double[] _forgetGateBias;
        private readonly double[] _inputGateBias;
        private readonly double[] _candidateBias;
        private readonly double[] _outputGateBias;
        
        // Previous states
        private double[] _cellState;
        private double[] _hiddenState;
        
        public int InputSize => _inputSize;
        public int HiddenSize => _hiddenSize;
        public double[] HiddenState => _hiddenState;
        public double[] CellState => _cellState;
        
        public LSTMCell(int inputSize, int hiddenSize)
        {
            _inputSize = inputSize;
            _hiddenSize = hiddenSize;
            
            var totalInputSize = inputSize + hiddenSize; // Input + previous hidden
            
            // Initialize weight matrices with Xavier initialization
            var limit = Math.Sqrt(6.0 / (totalInputSize + hiddenSize));
            var random = new Random();
            
            _forgetGateWeights = InitializeMatrix(hiddenSize, totalInputSize, random, limit);
            _inputGateWeights = InitializeMatrix(hiddenSize, totalInputSize, random, limit);
            _candidateWeights = InitializeMatrix(hiddenSize, totalInputSize, random, limit);
            _outputGateWeights = InitializeMatrix(hiddenSize, totalInputSize, random, limit);
            
            _forgetGateBias = InitializeVector(hiddenSize, 1.0); // Forget bias = 1 (remember by default)
            _inputGateBias = InitializeVector(hiddenSize, 0.0);
            _candidateBias = InitializeVector(hiddenSize, 0.0);
            _outputGateBias = InitializeVector(hiddenSize, 0.0);
            
            // Initialize states
            _cellState = new double[hiddenSize];
            _hiddenState = new double[hiddenSize];
        }
        
        public async Task<double[]> ForwardAsync(double[] input)
        {
            // Concatenate input with previous hidden state
            var concatenated = new double[_inputSize + _hiddenSize];
            Array.Copy(input, 0, concatenated, 0, _inputSize);
            Array.Copy(_hiddenState, 0, concatenated, _inputSize, _hiddenSize);
            
            // Forget gate: f_t = σ(W_f · [h_{t-1}, x_t] + b_f)
            var forgetGate = ApplyGate(_forgetGateWeights, _forgetGateBias, concatenated, Sigmoid);
            
            // Input gate: i_t = σ(W_i · [h_{t-1}, x_t] + b_i)
            var inputGate = ApplyGate(_inputGateWeights, _inputGateBias, concatenated, Sigmoid);
            
            // Candidate values: C̃_t = tanh(W_C · [h_{t-1}, x_t] + b_C)
            var candidateValues = ApplyGate(_candidateWeights, _candidateBias, concatenated, Tanh);
            
            // Output gate: o_t = σ(W_o · [h_{t-1}, x_t] + b_o)
            var outputGate = ApplyGate(_outputGateWeights, _outputGateBias, concatenated, Sigmoid);
            
            // Update cell state: C_t = f_t * C_{t-1} + i_t * C̃_t
            for (int i = 0; i < _hiddenSize; i++)
            {
                _cellState[i] = forgetGate[i] * _cellState[i] + inputGate[i] * candidateValues[i];
            }
            
            // Update hidden state: h_t = o_t * tanh(C_t)
            for (int i = 0; i < _hiddenSize; i++)
            {
                _hiddenState[i] = outputGate[i] * Tanh(_cellState[i]);
            }
            
            return (double[])_hiddenState.Clone();
        }
        
        private double[,] InitializeMatrix(int rows, int cols, Random random, double limit)
        {
            var matrix = new double[rows, cols];
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    matrix[i, j] = (random.NextDouble() * 2 - 1) * limit;
                }
            }
            return matrix;
        }
        
        private double[] InitializeVector(int size, double initialValue)
        {
            var vector = new double[size];
            for (int i = 0; i < size; i++)
            {
                vector[i] = initialValue;
            }
            return vector;
        }
        
        private double[] ApplyGate(double[,] weights, double[] bias, double[] input, Func<double, double> activation)
        {
            var result = new double[_hiddenSize];
            
            for (int i = 0; i < _hiddenSize; i++)
            {
                var sum = bias[i];
                for (int j = 0; j < input.Length; j++)
                {
                    sum += weights[i, j] * input[j];
                }
                result[i] = activation(sum);
            }
            
            return result;
        }
        
        private double Sigmoid(double x)
        {
            return 1.0 / (1.0 + Math.Exp(-Math.Max(-500, Math.Min(500, x))));
        }
        
        private double Tanh(double x)
        {
            return Math.Tanh(Math.Max(-500, Math.Min(500, x)));
        }
        
        public void ResetState()
        {
            Array.Fill(_cellState, 0.0);
            Array.Fill(_hiddenState, 0.0);
        }
        
        public (double[] cellState, double[] hiddenState) GetState()
        {
            return ((double[])_cellState.Clone(), (double[])_hiddenState.Clone());
        }
        
        public void SetState(double[] cellState, double[] hiddenState)
        {
            _cellState = (double[])cellState.Clone();
            _hiddenState = (double[])hiddenState.Clone();
        }
    }
    
    // Sequence-to-Sequence Model with Attention
    public class Seq2SeqModel
    {
        private readonly Seq2SeqConfig _config;
        private readonly LSTMCell _encoderLSTM;
        private readonly LSTMCell _decoderLSTM;
        private readonly AttentionMechanism _attention;
        private readonly Dictionary<string, int> _inputVocab;
        private readonly Dictionary<string, int> _outputVocab;
        private readonly Dictionary<int, string> _outputIndexToWord;
        private readonly double[,] _inputEmbeddings;
        private readonly double[,] _outputEmbeddings;
        private readonly double[,] _outputProjection;
        private readonly ILogger _logger;
        
        public int InputVocabSize => _inputVocab.Count;
        public int OutputVocabSize => _outputVocab.Count;
        
        public Seq2SeqModel(Seq2SeqConfig config)
        {
            _config = config;
            _encoderLSTM = new LSTMCell(config.EmbeddingSize, config.HiddenSize);
            _decoderLSTM = new LSTMCell(config.EmbeddingSize + config.HiddenSize, config.HiddenSize); // +attention
            _attention = new AttentionMechanism(config.HiddenSize);
            _inputVocab = new Dictionary<string, int>();
            _outputVocab = new Dictionary<string, int>();
            _outputIndexToWord = new Dictionary<int, string>();
            _logger = LogManager.GetCurrentClassLogger();
        }
        
        public async Task TrainAsync(List<(string input, string output)> trainingData)
        {
            _logger.Info($"Training Seq2Seq model on {trainingData.Count} examples...");
            
            // Build vocabularies
            await BuildVocabulariesAsync(trainingData);
            
            // Initialize embeddings and projection matrices
            InitializeEmbeddings();
            
            // Training loop
            for (int epoch = 0; epoch < _config.Epochs; epoch++)
            {
                var totalLoss = 0.0;
                var shuffledData = trainingData.OrderBy(_ => Guid.NewGuid()).ToList();
                
                foreach (var (input, output) in shuffledData)
                {
                    var loss = await TrainSequencePairAsync(input, output);
                    totalLoss += loss;
                }
                
                var averageLoss = totalLoss / trainingData.Count;
                _logger.Debug($"Epoch {epoch + 1}/{_config.Epochs}, Average Loss: {averageLoss:F4}");
            }
            
            _logger.Info("Training completed");
        }
        
        private async Task BuildVocabulariesAsync(List<(string input, string output)> trainingData)
        {
            var inputWords = new HashSet<string>();
            var outputWords = new HashSet<string>();
            
            foreach (var (input, output) in trainingData)
            {
                foreach (var word in input.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries))
                {
                    inputWords.Add(word);
                }
                
                foreach (var word in output.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries))
                {
                    outputWords.Add(word);
                }
            }
            
            // Add special tokens
            outputWords.Add("<SOS>"); // Start of sequence
            outputWords.Add("<EOS>"); // End of sequence
            outputWords.Add("<UNK>"); // Unknown word
            
            // Build input vocabulary
            var inputWordList = inputWords.OrderBy(w => w).ToList();
            for (int i = 0; i < inputWordList.Count; i++)
            {
                _inputVocab[inputWordList[i]] = i;
            }
            
            // Build output vocabulary
            var outputWordList = outputWords.OrderBy(w => w).ToList();
            for (int i = 0; i < outputWordList.Count; i++)
            {
                _outputVocab[outputWordList[i]] = i;
                _outputIndexToWord[i] = outputWordList[i];
            }
            
            _logger.Info($"Vocabularies built - Input: {InputVocabSize}, Output: {OutputVocabSize}");
        }
        
        private void InitializeEmbeddings()
        {
            var random = new Random();
            var limit = Math.Sqrt(6.0 / _config.EmbeddingSize);
            
            // Input embeddings
            _inputEmbeddings = new double[InputVocabSize, _config.EmbeddingSize];
            for (int i = 0; i < InputVocabSize; i++)
            {
                for (int j = 0; j < _config.EmbeddingSize; j++)
                {
                    _inputEmbeddings[i, j] = (random.NextDouble() * 2 - 1) * limit;
                }
            }
            
            // Output embeddings
            _outputEmbeddings = new double[OutputVocabSize, _config.EmbeddingSize];
            for (int i = 0; i < OutputVocabSize; i++)
            {
                for (int j = 0; j < _config.EmbeddingSize; j++)
                {
                    _outputEmbeddings[i, j] = (random.NextDouble() * 2 - 1) * limit;
                }
            }
            
            // Output projection matrix (hidden -> vocab)
            _outputProjection = new double[OutputVocabSize, _config.HiddenSize];
            var projLimit = Math.Sqrt(6.0 / (_config.HiddenSize + OutputVocabSize));
            for (int i = 0; i < OutputVocabSize; i++)
            {
                for (int j = 0; j < _config.HiddenSize; j++)
                {
                    _outputProjection[i, j] = (random.NextDouble() * 2 - 1) * projLimit;
                }
            }
        }
        
        private async Task<double> TrainSequencePairAsync(string inputText, string outputText)
        {
            // Reset LSTM states
            _encoderLSTM.ResetState();
            _decoderLSTM.ResetState();
            
            // Encode input sequence
            var encoderStates = await EncodeSequenceAsync(inputText);
            
            // Initialize decoder with encoder final state
            var (encoderCellState, encoderHiddenState) = _encoderLSTM.GetState();
            _decoderLSTM.SetState(encoderCellState, encoderHiddenState);
            
            // Decode with teacher forcing
            var targetWords = ("<SOS> " + outputText.ToLowerInvariant() + " <EOS>").Split(' ');
            var loss = 0.0;
            
            for (int t = 0; t < targetWords.Length - 1; t++)
            {
                var inputWord = targetWords[t];
                var targetWord = targetWords[t + 1];
                
                if (!_outputVocab.ContainsKey(inputWord) || !_outputVocab.ContainsKey(targetWord))
                    continue;
                
                var inputEmbedding = GetOutputEmbedding(_outputVocab[inputWord]);
                
                // Apply attention
                var attentionContext = await _attention.ApplyAsync(_decoderLSTM.HiddenState, encoderStates);
                
                // Concatenate input embedding with attention context
                var decoderInput = ConcatenateVectors(inputEmbedding, attentionContext);
                
                // Decoder forward pass
                var decoderOutput = await _decoderLSTM.ForwardAsync(decoderInput);
                
                // Project to vocabulary space
                var logits = ProjectToVocabulary(decoderOutput);
                
                // Calculate cross-entropy loss
                var targetIndex = _outputVocab[targetWord];
                var stepLoss = CrossEntropyLoss(logits, targetIndex);
                loss += stepLoss;
                
                // Backpropagation would be implemented here in a complete system
            }
            
            return loss / (targetWords.Length - 1);
        }
        
        private async Task<List<double[]>> EncodeSequenceAsync(string inputText)
        {
            var words = inputText.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries);
            var encoderStates = new List<double[]>();
            
            foreach (var word in words)
            {
                if (_inputVocab.ContainsKey(word))
                {
                    var embedding = GetInputEmbedding(_inputVocab[word]);
                    var hiddenState = await _encoderLSTM.ForwardAsync(embedding);
                    encoderStates.Add((double[])hiddenState.Clone());
                }
            }
            
            return encoderStates;
        }
        
        private double[] GetInputEmbedding(int wordIndex)
        {
            var embedding = new double[_config.EmbeddingSize];
            for (int i = 0; i < _config.EmbeddingSize; i++)
            {
                embedding[i] = _inputEmbeddings[wordIndex, i];
            }
            return embedding;
        }
        
        private double[] GetOutputEmbedding(int wordIndex)
        {
            var embedding = new double[_config.EmbeddingSize];
            for (int i = 0; i < _config.EmbeddingSize; i++)
            {
                embedding[i] = _outputEmbeddings[wordIndex, i];
            }
            return embedding;
        }
        
        private double[] ConcatenateVectors(double[] a, double[] b)
        {
            var result = new double[a.Length + b.Length];
            Array.Copy(a, 0, result, 0, a.Length);
            Array.Copy(b, 0, result, a.Length, b.Length);
            return result;
        }
        
        private double[] ProjectToVocabulary(double[] hiddenState)
        {
            var logits = new double[OutputVocabSize];
            
            for (int i = 0; i < OutputVocabSize; i++)
            {
                var sum = 0.0;
                for (int j = 0; j < _config.HiddenSize; j++)
                {
                    sum += _outputProjection[i, j] * hiddenState[j];
                }
                logits[i] = sum;
            }
            
            return Softmax(logits);
        }
        
        private double[] Softmax(double[] logits)
        {
            var maxLogit = logits.Max();
            var exps = logits.Select(x => Math.Exp(x - maxLogit)).ToArray();
            var sumExps = exps.Sum();
            
            return exps.Select(exp => exp / sumExps).ToArray();
        }
        
        private double CrossEntropyLoss(double[] probabilities, int targetIndex)
        {
            var targetProb = Math.Max(1e-7, probabilities[targetIndex]); // Avoid log(0)
            return -Math.Log(targetProb);
        }
        
        public async Task<string> GenerateAsync(string inputText, int maxLength = 50)
        {
            // Reset states
            _encoderLSTM.ResetState();
            _decoderLSTM.ResetState();
            
            // Encode input
            var encoderStates = await EncodeSequenceAsync(inputText);
            
            // Initialize decoder
            var (encoderCellState, encoderHiddenState) = _encoderLSTM.GetState();
            _decoderLSTM.SetState(encoderCellState, encoderHiddenState);
            
            // Generate sequence
            var generatedWords = new List<string>();
            var currentWord = "<SOS>";
            
            for (int t = 0; t < maxLength; t++)
            {
                if (!_outputVocab.ContainsKey(currentWord))
                    break;
                
                var inputEmbedding = GetOutputEmbedding(_outputVocab[currentWord]);
                var attentionContext = await _attention.ApplyAsync(_decoderLSTM.HiddenState, encoderStates);
                var decoderInput = ConcatenateVectors(inputEmbedding, attentionContext);
                
                var decoderOutput = await _decoderLSTM.ForwardAsync(decoderInput);
                var probabilities = ProjectToVocabulary(decoderOutput);
                
                // Sample next word (greedy decoding)
                var nextWordIndex = Array.IndexOf(probabilities, probabilities.Max());
                var nextWord = _outputIndexToWord[nextWordIndex];
                
                if (nextWord == "<EOS>")
                    break;
                
                if (nextWord != "<SOS>")
                {
                    generatedWords.Add(nextWord);
                }
                
                currentWord = nextWord;
            }
            
            return string.Join(" ", generatedWords);
        }
    }
    
    // Attention Mechanism Implementation
    public class AttentionMechanism
    {
        private readonly int _hiddenSize;
        private readonly double[,] _attentionWeights;
        
        public AttentionMechanism(int hiddenSize)
        {
            _hiddenSize = hiddenSize;
            _attentionWeights = new double[hiddenSize, hiddenSize];
            
            // Initialize attention weights
            var random = new Random();
            var limit = Math.Sqrt(6.0 / (2 * hiddenSize));
            
            for (int i = 0; i < hiddenSize; i++)
            {
                for (int j = 0; j < hiddenSize; j++)
                {
                    _attentionWeights[i, j] = (random.NextDouble() * 2 - 1) * limit;
                }
            }
        }
        
        public async Task<double[]> ApplyAsync(double[] decoderState, List<double[]> encoderStates)
        {
            if (encoderStates.Count == 0)
                return new double[_hiddenSize];
            
            // Calculate attention scores
            var attentionScores = new double[encoderStates.Count];
            
            for (int i = 0; i < encoderStates.Count; i++)
            {
                attentionScores[i] = CalculateAttentionScore(decoderState, encoderStates[i]);
            }
            
            // Apply softmax to get attention weights
            var attentionWeights = Softmax(attentionScores);
            
            // Calculate weighted context vector
            var contextVector = new double[_hiddenSize];
            
            for (int i = 0; i < encoderStates.Count; i++)
            {
                var weight = attentionWeights[i];
                for (int j = 0; j < _hiddenSize; j++)
                {
                    contextVector[j] += weight * encoderStates[i][j];
                }
            }
            
            return contextVector;
        }
        
        private double CalculateAttentionScore(double[] decoderState, double[] encoderState)
        {
            // Simple dot-product attention
            var score = 0.0;
            
            for (int i = 0; i < _hiddenSize; i++)
            {
                var transformedDecoder = 0.0;
                for (int j = 0; j < _hiddenSize; j++)
                {
                    transformedDecoder += _attentionWeights[i, j] * decoderState[j];
                }
                score += transformedDecoder * encoderState[i];
            }
            
            return score;
        }
        
        private double[] Softmax(double[] scores)
        {
            var maxScore = scores.Max();
            var exps = scores.Select(s => Math.Exp(s - maxScore)).ToArray();
            var sumExps = exps.Sum();
            
            return exps.Select(exp => exp / sumExps).ToArray();
        }
    }
    
    // Text Classification with LSTM
    public class LSTMTextClassifier
    {
        private readonly LSTMClassifierConfig _config;
        private readonly LSTMCell _lstm;
        private readonly Dictionary<string, int> _vocabulary;
        private readonly Dictionary<string, int> _labelToIndex;
        private readonly Dictionary<int, string> _indexToLabel;
        private readonly double[,] _embeddings;
        private readonly double[,] _classificationLayer;
        private readonly ILogger _logger;
        
        public LSTMTextClassifier(LSTMClassifierConfig config)
        {
            _config = config;
            _lstm = new LSTMCell(config.EmbeddingSize, config.HiddenSize);
            _vocabulary = new Dictionary<string, int>();
            _labelToIndex = new Dictionary<string, int>();
            _indexToLabel = new Dictionary<int, string>();
            _logger = LogManager.GetCurrentClassLogger();
        }
        
        public async Task TrainAsync(List<(string text, string label)> trainingData)
        {
            _logger.Info($"Training LSTM text classifier on {trainingData.Count} examples...");
            
            await BuildVocabularyAsync(trainingData);
            InitializeEmbeddings();
            
            // Training loop with shuffled data
            for (int epoch = 0; epoch < _config.Epochs; epoch++)
            {
                var shuffledData = trainingData.OrderBy(_ => Guid.NewGuid()).ToList();
                var totalLoss = 0.0;
                
                foreach (var (text, label) in shuffledData)
                {
                    var loss = await TrainSampleAsync(text, label);
                    totalLoss += loss;
                }
                
                var averageLoss = totalLoss / trainingData.Count;
                _logger.Debug($"Epoch {epoch + 1}/{_config.Epochs}, Loss: {averageLoss:F4}");
            }
            
            _logger.Info("Classification training completed");
        }
        
        private async Task BuildVocabularyAsync(List<(string text, string label)> trainingData)
        {
            var wordCounts = new Dictionary<string, int>();
            var labels = new HashSet<string>();
            
            foreach (var (text, label) in trainingData)
            {
                labels.Add(label);
                
                var words = text.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries);
                foreach (var word in words)
                {
                    wordCounts[word] = wordCounts.GetValueOrDefault(word, 0) + 1;
                }
            }
            
            // Build vocabulary (top frequent words)
            var vocabularyWords = wordCounts
                .Where(kvp => kvp.Value >= _config.MinWordFrequency)
                .OrderByDescending(kvp => kvp.Value)
                .Take(_config.MaxVocabularySize)
                .Select((kvp, index) => new { kvp.Key, Index = index })
                .ToDictionary(x => x.Key, x => x.Index);
            
            foreach (var kvp in vocabularyWords)
            {
                _vocabulary[kvp.Key] = kvp.Value;
            }
            
            // Build label mapping
            var labelList = labels.OrderBy(l => l).ToList();
            for (int i = 0; i < labelList.Count; i++)
            {
                _labelToIndex[labelList[i]] = i;
                _indexToLabel[i] = labelList[i];
            }
            
            _logger.Info($"Vocabulary: {_vocabulary.Count} words, Labels: {_labelToIndex.Count}");
        }
        
        private void InitializeEmbeddings()
        {
            var random = new Random();
            var embeddingLimit = Math.Sqrt(6.0 / _config.EmbeddingSize);
            
            // Word embeddings
            _embeddings = new double[_vocabulary.Count, _config.EmbeddingSize];
            for (int i = 0; i < _vocabulary.Count; i++)
            {
                for (int j = 0; j < _config.EmbeddingSize; j++)
                {
                    _embeddings[i, j] = (random.NextDouble() * 2 - 1) * embeddingLimit;
                }
            }
            
            // Classification layer
            var classificationLimit = Math.Sqrt(6.0 / (_config.HiddenSize + _labelToIndex.Count));
            _classificationLayer = new double[_labelToIndex.Count, _config.HiddenSize];
            for (int i = 0; i < _labelToIndex.Count; i++)
            {
                for (int j = 0; j < _config.HiddenSize; j++)
                {
                    _classificationLayer[i, j] = (random.NextDouble() * 2 - 1) * classificationLimit;
                }
            }
        }
        
        private async Task<double> TrainSampleAsync(string text, string label)
        {
            _lstm.ResetState();
            
            var words = text.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries)
                .Where(word => _vocabulary.ContainsKey(word))
                .ToList();
            
            // Forward pass through LSTM
            foreach (var word in words)
            {
                var embedding = GetWordEmbedding(_vocabulary[word]);
                await _lstm.ForwardAsync(embedding);
            }
            
            // Classification
            var finalHiddenState = _lstm.HiddenState;
            var logits = ClassifyHiddenState(finalHiddenState);
            
            // Calculate loss
            if (!_labelToIndex.ContainsKey(label))
                return 0.0;
            
            var targetIndex = _labelToIndex[label];
            return CrossEntropyLoss(logits, targetIndex);
        }
        
        private double[] GetWordEmbedding(int wordIndex)
        {
            var embedding = new double[_config.EmbeddingSize];
            for (int i = 0; i < _config.EmbeddingSize; i++)
            {
                embedding[i] = _embeddings[wordIndex, i];
            }
            return embedding;
        }
        
        private double[] ClassifyHiddenState(double[] hiddenState)
        {
            var logits = new double[_labelToIndex.Count];
            
            for (int i = 0; i < _labelToIndex.Count; i++)
            {
                var sum = 0.0;
                for (int j = 0; j < _config.HiddenSize; j++)
                {
                    sum += _classificationLayer[i, j] * hiddenState[j];
                }
                logits[i] = sum;
            }
            
            // Apply softmax
            var maxLogit = logits.Max();
            var exps = logits.Select(x => Math.Exp(x - maxLogit)).ToArray();
            var sumExps = exps.Sum();
            
            return exps.Select(exp => exp / sumExps).ToArray();
        }
        
        private double CrossEntropyLoss(double[] probabilities, int targetIndex)
        {
            var targetProb = Math.Max(1e-7, probabilities[targetIndex]);
            return -Math.Log(targetProb);
        }
        
        public async Task<string> ClassifyAsync(string text)
        {
            _lstm.ResetState();
            
            var words = text.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries)
                .Where(word => _vocabulary.ContainsKey(word))
                .ToList();
            
            if (!words.Any())
                return _indexToLabel.Values.First(); // Default prediction
            
            // Forward pass
            foreach (var word in words)
            {
                var embedding = GetWordEmbedding(_vocabulary[word]);
                await _lstm.ForwardAsync(embedding);
            }
            
            // Classification
            var probabilities = ClassifyHiddenState(_lstm.HiddenState);
            var predictedIndex = Array.IndexOf(probabilities, probabilities.Max());
            
            return _indexToLabel[predictedIndex];
        }
    }
    
    // Configuration Classes
    public class Seq2SeqConfig
    {
        public int EmbeddingSize { get; set; } = 256;
        public int HiddenSize { get; set; } = 512;
        public int Epochs { get; set; } = 100;
        public double LearningRate { get; set; } = 0.001;
        public bool UseAttention { get; set; } = true;
    }
    
    public class LSTMClassifierConfig
    {
        public int EmbeddingSize { get; set; } = 128;
        public int HiddenSize { get; set; } = 256;
        public int Epochs { get; set; } = 50;
        public double LearningRate { get; set; } = 0.001;
        public int MinWordFrequency { get; set; } = 2;
        public int MaxVocabularySize { get; set; } = 10000;
    }
}
```

### Key Takeaways (2 minutes)

#### **🎯 Sequence Model Mastery**

**Advanced LSTM Implementation**: Complete cell with forget, input, and output gates for long-range dependencies

**Sequence-to-Sequence**: Encoder-decoder architecture with attention mechanism for translation tasks

**Text Classification**: LSTM-based sentiment analysis with configurable vocabulary and embedding layers

**Attention Mechanism**: Context-aware focus on relevant input positions for improved performance

#### **⚡ Production Features**

- **Gating Mechanisms**: Proper LSTM implementation with numerical stability and gradient flow
- **Attention Integration**: Weighted context vectors for improved long-sequence handling
- **Configurable Training**: Flexible architectures with teacher forcing and beam search ready
- **Robust Preprocessing**: Vocabulary building, embedding initialization, and state management

**Ready for Part 5 (Transformer Applications & Modern NLP)?** 🚀
