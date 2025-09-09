# 01_NLP-Text-Processing-Part1: Text Processing & Tokenization

**Learning Level**: Intermediate  
**Prerequisites**: Basic Programming, String Manipulation, Regular Expressions  
**Estimated Time**: Part 1 of 5 - 10 minutes (focused segment)

## 🎯 Learning Objectives

By the end of this focused 10-minute segment, you will:

- Master fundamental text preprocessing techniques for NLP pipelines
- Implement comprehensive tokenization algorithms (word, subword, sentence-level)
- Build robust text normalization and cleaning systems
- Design production-ready text processing pipelines with performance optimization

## 📋 Content Overview (10-Minute Structure)

### Quick Foundation (2 minutes)

Text processing is the foundation of all NLP tasks. Raw text contains noise, inconsistencies, and structural variations that must be normalized before analysis. **Tokenization** breaks text into meaningful units (tokens), while **normalization** standardizes format, case, and encoding.

**Core Processing Steps**:

- **Cleaning**: Remove noise, HTML, special characters, normalize encoding
- **Tokenization**: Split text into words, subwords, or sentences
- **Normalization**: Standardize case, punctuation, whitespace
- **Filtering**: Remove stop words, apply frequency filtering

**Tokenization Approaches**:

- **Word-Level**: Split by whitespace and punctuation (simple but limited)
- **Subword-Level**: BPE, WordPiece for handling OOV words
- **Character-Level**: Individual characters for multilingual robustness
- **Sentence-Level**: Paragraph and document segmentation

### Core Implementation (6 minutes)

```csharp
// ✅ Advanced Text Processing Framework
namespace NLP.TextProcessing
{
    // Comprehensive Text Processor
    public class TextProcessor
    {
        private readonly TextCleaner _cleaner;
        private readonly Tokenizer _tokenizer;
        private readonly TextNormalizer _normalizer;
        private readonly StopWordFilter _stopWordFilter;
        private readonly ILogger _logger;
        
        public TextProcessingConfig Config { get; private set; }
        
        public TextProcessor(TextProcessingConfig config = null)
        {
            Config = config ?? TextProcessingConfig.Default();
            _cleaner = new TextCleaner(Config.CleaningOptions);
            _tokenizer = new Tokenizer(Config.TokenizationOptions);
            _normalizer = new TextNormalizer(Config.NormalizationOptions);
            _stopWordFilter = new StopWordFilter(Config.StopWords);
            _logger = LogManager.GetCurrentClassLogger();
        }
        
        public async Task<ProcessedText> ProcessAsync(string rawText)
        {
            if (string.IsNullOrWhiteSpace(rawText))
                return ProcessedText.Empty();
            
            var stopwatch = Stopwatch.StartNew();
            
            try
            {
                // Step 1: Clean raw text
                var cleaned = await _cleaner.CleanAsync(rawText);
                
                // Step 2: Normalize text
                var normalized = await _normalizer.NormalizeAsync(cleaned);
                
                // Step 3: Tokenize
                var tokens = await _tokenizer.TokenizeAsync(normalized);
                
                // Step 4: Filter tokens
                var filtered = Config.ApplyStopWordFiltering 
                    ? await _stopWordFilter.FilterAsync(tokens)
                    : tokens;
                
                // Step 5: Generate statistics
                var statistics = GenerateStatistics(rawText, filtered);
                
                stopwatch.Stop();
                
                return new ProcessedText
                {
                    OriginalText = rawText,
                    CleanedText = cleaned,
                    NormalizedText = normalized,
                    Tokens = filtered,
                    Statistics = statistics,
                    ProcessingTime = stopwatch.Elapsed
                };
            }
            catch (Exception ex)
            {
                _logger.Error(ex, "Error processing text");
                throw new TextProcessingException("Failed to process text", ex);
            }
        }
        
        public async Task<List<ProcessedText>> ProcessBatchAsync(IEnumerable<string> texts, 
            int maxConcurrency = 4)
        {
            var semaphore = new SemaphoreSlim(maxConcurrency, maxConcurrency);
            var tasks = texts.Select(async text =>
            {
                await semaphore.WaitAsync();
                try
                {
                    return await ProcessAsync(text);
                }
                finally
                {
                    semaphore.Release();
                }
            });
            
            return (await Task.WhenAll(tasks)).ToList();
        }
        
        private TextStatistics GenerateStatistics(string original, List<Token> tokens)
        {
            return new TextStatistics
            {
                OriginalLength = original.Length,
                OriginalWordCount = original.Split(new[] { ' ', '\t', '\n' }, 
                    StringSplitOptions.RemoveEmptyEntries).Length,
                TokenCount = tokens.Count,
                UniqueTokenCount = tokens.Select(t => t.Text).Distinct().Count(),
                AverageTokenLength = tokens.Count > 0 ? tokens.Average(t => t.Text.Length) : 0,
                VocabularySize = tokens.GroupBy(t => t.Text).Count()
            };
        }
    }
    
    // Advanced Text Cleaner
    public class TextCleaner
    {
        private readonly CleaningOptions _options;
        private readonly Regex _htmlRegex;
        private readonly Regex _urlRegex;
        private readonly Regex _emailRegex;
        private readonly Regex _phoneRegex;
        private readonly Regex _extraWhitespaceRegex;
        
        public TextCleaner(CleaningOptions options)
        {
            _options = options;
            
            // Pre-compile regex patterns for performance
            _htmlRegex = new Regex(@"<[^>]+>", RegexOptions.Compiled | RegexOptions.IgnoreCase);
            _urlRegex = new Regex(@"https?://[^\s/$.?#].[^\s]*", RegexOptions.Compiled | RegexOptions.IgnoreCase);
            _emailRegex = new Regex(@"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b", RegexOptions.Compiled);
            _phoneRegex = new Regex(@"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b", RegexOptions.Compiled);
            _extraWhitespaceRegex = new Regex(@"\s+", RegexOptions.Compiled);
        }
        
        public async Task<string> CleanAsync(string text)
        {
            if (string.IsNullOrEmpty(text))
                return string.Empty;
            
            var result = text;
            
            // Remove HTML tags
            if (_options.RemoveHtml)
                result = _htmlRegex.Replace(result, " ");
            
            // Handle URLs
            if (_options.RemoveUrls)
                result = _urlRegex.Replace(result, _options.ReplaceUrlsWith ?? " ");
            
            // Handle emails
            if (_options.RemoveEmails)
                result = _emailRegex.Replace(result, _options.ReplaceEmailsWith ?? " ");
            
            // Handle phone numbers
            if (_options.RemovePhoneNumbers)
                result = _phoneRegex.Replace(result, _options.ReplacePhonesWith ?? " ");
            
            // Remove or replace special characters
            if (_options.RemoveSpecialCharacters)
            {
                var allowedChars = _options.AllowedSpecialCharacters ?? new HashSet<char> { '.', ',', '!', '?' };
                result = new string(result.Where(c => char.IsLetterOrDigit(c) || 
                    char.IsWhiteSpace(c) || allowedChars.Contains(c)).ToArray());
            }
            
            // Remove extra whitespace
            result = _extraWhitespaceRegex.Replace(result, " ");
            
            // Trim and return
            return result.Trim();
        }
    }
    
    // Advanced Tokenizer with Multiple Strategies
    public class Tokenizer
    {
        private readonly TokenizationOptions _options;
        private readonly Regex _wordBoundaryRegex;
        private readonly Regex _sentenceBoundaryRegex;
        private readonly SubwordTokenizer _subwordTokenizer;
        
        public Tokenizer(TokenizationOptions options)
        {
            _options = options;
            
            // Word tokenization patterns
            _wordBoundaryRegex = new Regex(@"\b\w+\b", RegexOptions.Compiled | RegexOptions.IgnoreCase);
            
            // Sentence boundary detection
            _sentenceBoundaryRegex = new Regex(@"[.!?]+", RegexOptions.Compiled);
            
            // Initialize subword tokenizer if needed
            if (_options.TokenizationMethod == TokenizationMethod.Subword)
            {
                _subwordTokenizer = new SubwordTokenizer(_options.VocabularySize);
            }
        }
        
        public async Task<List<Token>> TokenizeAsync(string text)
        {
            switch (_options.TokenizationMethod)
            {
                case TokenizationMethod.Word:
                    return await TokenizeWordsAsync(text);
                
                case TokenizationMethod.Subword:
                    return await TokenizeSubwordsAsync(text);
                
                case TokenizationMethod.Character:
                    return await TokenizeCharactersAsync(text);
                
                case TokenizationMethod.Sentence:
                    return await TokenizeSentencesAsync(text);
                
                default:
                    throw new NotSupportedException($"Tokenization method {_options.TokenizationMethod} not supported");
            }
        }
        
        private async Task<List<Token>> TokenizeWordsAsync(string text)
        {
            var matches = _wordBoundaryRegex.Matches(text);
            var tokens = new List<Token>();
            
            for (int i = 0; i < matches.Count; i++)
            {
                var match = matches[i];
                tokens.Add(new Token
                {
                    Text = match.Value,
                    Position = match.Index,
                    Length = match.Length,
                    TokenType = TokenType.Word,
                    Index = i
                });
            }
            
            return tokens;
        }
        
        private async Task<List<Token>> TokenizeSubwordsAsync(string text)
        {
            // Simplified BPE-like subword tokenization
            var words = await TokenizeWordsAsync(text);
            var subwordTokens = new List<Token>();
            
            foreach (var word in words)
            {
                var subwords = _subwordTokenizer.TokenizeWord(word.Text);
                
                for (int i = 0; i < subwords.Count; i++)
                {
                    subwordTokens.Add(new Token
                    {
                        Text = subwords[i],
                        Position = word.Position + i, // Simplified position calculation
                        Length = subwords[i].Length,
                        TokenType = TokenType.Subword,
                        Index = subwordTokens.Count,
                        ParentToken = word
                    });
                }
            }
            
            return subwordTokens;
        }
        
        private async Task<List<Token>> TokenizeCharactersAsync(string text)
        {
            var tokens = new List<Token>();
            
            for (int i = 0; i < text.Length; i++)
            {
                if (!char.IsWhiteSpace(text[i]))
                {
                    tokens.Add(new Token
                    {
                        Text = text[i].ToString(),
                        Position = i,
                        Length = 1,
                        TokenType = TokenType.Character,
                        Index = tokens.Count
                    });
                }
            }
            
            return tokens;
        }
        
        private async Task<List<Token>> TokenizeSentencesAsync(string text)
        {
            var sentences = _sentenceBoundaryRegex.Split(text)
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .ToList();
            
            var tokens = new List<Token>();
            var position = 0;
            
            for (int i = 0; i < sentences.Count; i++)
            {
                var sentence = sentences[i].Trim();
                if (!string.IsNullOrEmpty(sentence))
                {
                    tokens.Add(new Token
                    {
                        Text = sentence,
                        Position = position,
                        Length = sentence.Length,
                        TokenType = TokenType.Sentence,
                        Index = i
                    });
                    
                    position += sentence.Length + 1; // +1 for delimiter
                }
            }
            
            return tokens;
        }
    }
    
    // Subword Tokenizer (Simplified BPE)
    public class SubwordTokenizer
    {
        private readonly int _vocabularySize;
        private readonly Dictionary<string, int> _vocabulary;
        private readonly Dictionary<(string, string), int> _pairFrequencies;
        
        public SubwordTokenizer(int vocabularySize = 10000)
        {
            _vocabularySize = vocabularySize;
            _vocabulary = new Dictionary<string, int>();
            _pairFrequencies = new Dictionary<(string, string), int>();
        }
        
        public List<string> TokenizeWord(string word)
        {
            // Start with character-level tokenization
            var tokens = word.ToCharArray().Select(c => c.ToString()).ToList();
            
            // Apply learned merges (simplified - in practice, this uses pre-trained BPE merges)
            while (tokens.Count > 1)
            {
                var bestPair = FindBestPair(tokens);
                if (bestPair == null) break;
                
                tokens = MergePair(tokens, bestPair.Value.Item1, bestPair.Value.Item2);
            }
            
            return tokens;
        }
        
        private (string, string)? FindBestPair(List<string> tokens)
        {
            var pairs = new Dictionary<(string, string), int>();
            
            for (int i = 0; i < tokens.Count - 1; i++)
            {
                var pair = (tokens[i], tokens[i + 1]);
                pairs[pair] = pairs.GetValueOrDefault(pair, 0) + 1;
            }
            
            return pairs.Count > 0 ? pairs.OrderByDescending(p => p.Value).First().Key : null;
        }
        
        private List<string> MergePair(List<string> tokens, string first, string second)
        {
            var result = new List<string>();
            var i = 0;
            
            while (i < tokens.Count)
            {
                if (i < tokens.Count - 1 && tokens[i] == first && tokens[i + 1] == second)
                {
                    result.Add(first + second);
                    i += 2;
                }
                else
                {
                    result.Add(tokens[i]);
                    i++;
                }
            }
            
            return result;
        }
    }
    
    // Text Normalizer
    public class TextNormalizer
    {
        private readonly NormalizationOptions _options;
        
        public TextNormalizer(NormalizationOptions options)
        {
            _options = options;
        }
        
        public async Task<string> NormalizeAsync(string text)
        {
            if (string.IsNullOrEmpty(text))
                return string.Empty;
            
            var result = text;
            
            // Case normalization
            if (_options.ConvertToLowercase)
                result = result.ToLowerInvariant();
            
            // Unicode normalization
            if (_options.NormalizeUnicode)
                result = result.Normalize(NormalizationForm.FormC);
            
            // Accent removal
            if (_options.RemoveAccents)
                result = RemoveAccents(result);
            
            // Number normalization
            if (_options.NormalizeNumbers)
                result = NormalizeNumbers(result);
            
            return result;
        }
        
        private string RemoveAccents(string text)
        {
            var normalizedString = text.Normalize(NormalizationForm.FormD);
            var stringBuilder = new StringBuilder();
            
            foreach (var c in normalizedString)
            {
                var unicodeCategory = CharUnicodeInfo.GetUnicodeCategory(c);
                if (unicodeCategory != UnicodeCategory.NonSpacingMark)
                {
                    stringBuilder.Append(c);
                }
            }
            
            return stringBuilder.ToString().Normalize(NormalizationForm.FormC);
        }
        
        private string NormalizeNumbers(string text)
        {
            // Replace all numbers with a placeholder token
            return Regex.Replace(text, @"\d+", "<NUM>", RegexOptions.Compiled);
        }
    }
    
    // Stop Word Filter
    public class StopWordFilter
    {
        private readonly HashSet<string> _stopWords;
        
        public StopWordFilter(IEnumerable<string> stopWords = null)
        {
            _stopWords = new HashSet<string>(stopWords ?? GetDefaultStopWords(), StringComparer.OrdinalIgnoreCase);
        }
        
        public async Task<List<Token>> FilterAsync(List<Token> tokens)
        {
            return tokens.Where(token => !_stopWords.Contains(token.Text)).ToList();
        }
        
        private static IEnumerable<string> GetDefaultStopWords()
        {
            return new[]
            {
                "a", "an", "and", "are", "as", "at", "be", "by", "for", "from",
                "has", "he", "in", "is", "it", "its", "of", "on", "that", "the",
                "to", "was", "will", "with", "the", "this", "but", "they", "have",
                "had", "what", "said", "each", "which", "she", "do", "how", "their",
                "if", "up", "out", "many", "then", "them", "these", "so", "some"
            };
        }
    }
    
    // Supporting Data Structures
    public class ProcessedText
    {
        public string OriginalText { get; set; }
        public string CleanedText { get; set; }
        public string NormalizedText { get; set; }
        public List<Token> Tokens { get; set; }
        public TextStatistics Statistics { get; set; }
        public TimeSpan ProcessingTime { get; set; }
        
        public static ProcessedText Empty() => new ProcessedText
        {
            OriginalText = string.Empty,
            CleanedText = string.Empty,
            NormalizedText = string.Empty,
            Tokens = new List<Token>(),
            Statistics = new TextStatistics(),
            ProcessingTime = TimeSpan.Zero
        };
    }
    
    public class Token
    {
        public string Text { get; set; }
        public int Position { get; set; }
        public int Length { get; set; }
        public TokenType TokenType { get; set; }
        public int Index { get; set; }
        public Token ParentToken { get; set; }
    }
    
    public enum TokenType
    {
        Word,
        Subword,
        Character,
        Sentence,
        Punctuation
    }
    
    public enum TokenizationMethod
    {
        Word,
        Subword,
        Character,
        Sentence
    }
    
    public class TextStatistics
    {
        public int OriginalLength { get; set; }
        public int OriginalWordCount { get; set; }
        public int TokenCount { get; set; }
        public int UniqueTokenCount { get; set; }
        public double AverageTokenLength { get; set; }
        public int VocabularySize { get; set; }
    }
    
    // Configuration Classes
    public class TextProcessingConfig
    {
        public CleaningOptions CleaningOptions { get; set; }
        public TokenizationOptions TokenizationOptions { get; set; }
        public NormalizationOptions NormalizationOptions { get; set; }
        public IEnumerable<string> StopWords { get; set; }
        public bool ApplyStopWordFiltering { get; set; }
        
        public static TextProcessingConfig Default() => new TextProcessingConfig
        {
            CleaningOptions = CleaningOptions.Default(),
            TokenizationOptions = TokenizationOptions.Default(),
            NormalizationOptions = NormalizationOptions.Default(),
            StopWords = null, // Uses default stop words
            ApplyStopWordFiltering = true
        };
    }
    
    public class CleaningOptions
    {
        public bool RemoveHtml { get; set; } = true;
        public bool RemoveUrls { get; set; } = true;
        public bool RemoveEmails { get; set; } = true;
        public bool RemovePhoneNumbers { get; set; } = true;
        public bool RemoveSpecialCharacters { get; set; } = false;
        public HashSet<char> AllowedSpecialCharacters { get; set; }
        public string ReplaceUrlsWith { get; set; } = " ";
        public string ReplaceEmailsWith { get; set; } = " ";
        public string ReplacePhonesWith { get; set; } = " ";
        
        public static CleaningOptions Default() => new CleaningOptions();
    }
    
    public class TokenizationOptions
    {
        public TokenizationMethod TokenizationMethod { get; set; } = TokenizationMethod.Word;
        public int VocabularySize { get; set; } = 10000;
        
        public static TokenizationOptions Default() => new TokenizationOptions();
    }
    
    public class NormalizationOptions
    {
        public bool ConvertToLowercase { get; set; } = true;
        public bool NormalizeUnicode { get; set; } = true;
        public bool RemoveAccents { get; set; } = false;
        public bool NormalizeNumbers { get; set; } = false;
        
        public static NormalizationOptions Default() => new NormalizationOptions();
    }
    
    public class TextProcessingException : Exception
    {
        public TextProcessingException(string message) : base(message) { }
        public TextProcessingException(string message, Exception innerException) : base(message, innerException) { }
    }
}
```

### Key Takeaways (2 minutes)

#### **🎯 Text Processing Mastery**

**Comprehensive Cleaning**: HTML, URL, email removal with configurable replacements

**Multi-Strategy Tokenization**: Word, subword (BPE), character, and sentence-level tokenization

**Advanced Normalization**: Unicode, case, accent, and number normalization

**Production Features**: Batch processing, performance monitoring, and error handling

#### **⚡ Enterprise Implementation**

- **Configurable Pipeline**: Modular components with customizable options
- **Performance Optimized**: Pre-compiled regex patterns and concurrent processing
- **Statistical Analysis**: Comprehensive text statistics and vocabulary metrics
- **Robust Error Handling**: Exception management and logging integration

**Ready for Part 2 (Language Models & N-grams)?** 🚀
