# 10C_Design-Patterns-Part5C-Strategy-Pattern-Data-Processing

**Learning Level**: Intermediate  
**Prerequisites**: Strategy Pattern Payment Systems (Part B), Algorithm complexity concepts  
**Estimated Time**: Part C of 4 - 27 minutes  

## 🎯 Learning Objectives

By the end of this 27-minute session, you will:

- Implement data processing strategies for sorting and transformation algorithms
- Design compression and encryption strategy families
- Apply Strategy Pattern to algorithm selection based on data characteristics
- Build performance-optimized strategy selection logic

## 📋 Content Sections (27-Minute Structure)

### Data Processing Strategy Foundation (5 minutes)

```csharp
// Generic data processing strategy interface
public interface IDataProcessingStrategy<TInput, TOutput>
{
    string StrategyName { get; }
    string Description { get; }
    TimeComplexity TimeComplexity { get; }
    SpaceComplexity SpaceComplexity { get; }
    int OptimalDataSizeThreshold { get; }
    
    Task<ProcessingResult<TOutput>> ProcessAsync(TInput data, CancellationToken cancellationToken = default);
    bool IsOptimalFor(TInput data);
}

// Processing result with performance metrics
public class ProcessingResult<T>
{
    public bool IsSuccessful { get; }
    public T Data { get; }
    public string Message { get; }
    public TimeSpan ProcessingTime { get; }
    public long MemoryUsed { get; }
    public Dictionary<string, object> Metrics { get; }

    public ProcessingResult(bool isSuccessful, T data, string message, TimeSpan processingTime, 
                          long memoryUsed = 0, Dictionary<string, object> metrics = null)
    {
        IsSuccessful = isSuccessful;
        Data = data;
        Message = message ?? string.Empty;
        ProcessingTime = processingTime;
        MemoryUsed = memoryUsed;
        Metrics = metrics ?? new Dictionary<string, object>();
    }

    public static ProcessingResult<T> Success(T data, TimeSpan processingTime, string message = "Processing successful",
                                           long memoryUsed = 0, Dictionary<string, object> metrics = null)
    {
        return new ProcessingResult<T>(true, data, message, processingTime, memoryUsed, metrics);
    }

    public static ProcessingResult<T> Failure(string message, TimeSpan processingTime = default)
    {
        return new ProcessingResult<T>(false, default(T), message, processingTime);
    }
}

// Complexity enums
public enum TimeComplexity
{
    Constant,     // O(1)
    Logarithmic,  // O(log n)
    Linear,       // O(n)
    Linearithmic, // O(n log n)
    Quadratic,    // O(n²)
    Exponential   // O(2^n)
}

public enum SpaceComplexity
{
    Constant,     // O(1)
    Logarithmic,  // O(log n)
    Linear        // O(n)
}
```

### Sorting Strategy Implementations (15 minutes)

#### Quick Sort Strategy

```csharp
public class QuickSortStrategy : IDataProcessingStrategy<int[], int[]>
{
    public string StrategyName => "Quick Sort";
    public string Description => "Divide-and-conquer sorting algorithm with average O(n log n) performance";
    public TimeComplexity TimeComplexity => TimeComplexity.Linearithmic;
    public SpaceComplexity SpaceComplexity => SpaceComplexity.Logarithmic;
    public int OptimalDataSizeThreshold => 100;

    public async Task<ProcessingResult<int[]>> ProcessAsync(int[] data, CancellationToken cancellationToken = default)
    {
        if (data == null)
            return ProcessingResult<int[]>.Failure("Input data cannot be null");

        var stopwatch = Stopwatch.StartNew();
        var initialMemory = GC.GetTotalMemory(false);

        try
        {
            var sortedArray = new int[data.Length];
            Array.Copy(data, sortedArray, data.Length);

            await Task.Run(() => QuickSort(sortedArray, 0, sortedArray.Length - 1, cancellationToken), cancellationToken);

            stopwatch.Stop();
            var finalMemory = GC.GetTotalMemory(false);
            var memoryUsed = Math.Max(0, finalMemory - initialMemory);

            var metrics = new Dictionary<string, object>
            {
                { "ArrayLength", data.Length },
                { "ComparisonsEstimate", data.Length * Math.Log2(data.Length) },
                { "AlgorithmType", "Divide and Conquer" }
            };

            return ProcessingResult<int[]>.Success(sortedArray, stopwatch.Elapsed, 
                $"Quick sort completed for {data.Length} elements", memoryUsed, metrics);
        }
        catch (OperationCanceledException)
        {
            stopwatch.Stop();
            return ProcessingResult<int[]>.Failure("Quick sort operation was cancelled");
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            return ProcessingResult<int[]>.Failure($"Quick sort failed: {ex.Message}");
        }
    }

    public bool IsOptimalFor(int[] data)
    {
        // Quick sort is optimal for large datasets that are not nearly sorted
        return data != null && data.Length >= OptimalDataSizeThreshold && !IsNearlySorted(data);
    }

    private void QuickSort(int[] arr, int low, int high, CancellationToken cancellationToken)
    {
        if (low < high)
        {
            cancellationToken.ThrowIfCancellationRequested();

            int partitionIndex = Partition(arr, low, high);
            
            QuickSort(arr, low, partitionIndex - 1, cancellationToken);
            QuickSort(arr, partitionIndex + 1, high, cancellationToken);
        }
    }

    private int Partition(int[] arr, int low, int high)
    {
        int pivot = arr[high];
        int i = low - 1;

        for (int j = low; j < high; j++)
        {
            if (arr[j] < pivot)
            {
                i++;
                (arr[i], arr[j]) = (arr[j], arr[i]);
            }
        }

        (arr[i + 1], arr[high]) = (arr[high], arr[i + 1]);
        return i + 1;
    }

    private bool IsNearlySorted(int[] data)
    {
        int inversions = 0;
        for (int i = 0; i < data.Length - 1; i++)
        {
            if (data[i] > data[i + 1])
                inversions++;
        }
        return inversions < data.Length * 0.1; // Less than 10% inversions
    }
}
```

#### Insertion Sort Strategy

```csharp
public class InsertionSortStrategy : IDataProcessingStrategy<int[], int[]>
{
    public string StrategyName => "Insertion Sort";
    public string Description => "Simple sorting algorithm optimal for small or nearly sorted datasets";
    public TimeComplexity TimeComplexity => TimeComplexity.Quadratic;
    public SpaceComplexity SpaceComplexity => SpaceComplexity.Constant;
    public int OptimalDataSizeThreshold => 50;

    public async Task<ProcessingResult<int[]>> ProcessAsync(int[] data, CancellationToken cancellationToken = default)
    {
        if (data == null)
            return ProcessingResult<int[]>.Failure("Input data cannot be null");

        var stopwatch = Stopwatch.StartNew();
        var initialMemory = GC.GetTotalMemory(false);

        try
        {
            var sortedArray = new int[data.Length];
            Array.Copy(data, sortedArray, data.Length);

            await Task.Run(() => InsertionSort(sortedArray, cancellationToken), cancellationToken);

            stopwatch.Stop();
            var finalMemory = GC.GetTotalMemory(false);
            var memoryUsed = Math.Max(0, finalMemory - initialMemory);

            var metrics = new Dictionary<string, object>
            {
                { "ArrayLength", data.Length },
                { "ComparisonsEstimate", Math.Pow(data.Length, 2) / 4 },
                { "AlgorithmType", "Incremental" }
            };

            return ProcessingResult<int[]>.Success(sortedArray, stopwatch.Elapsed,
                $"Insertion sort completed for {data.Length} elements", memoryUsed, metrics);
        }
        catch (OperationCanceledException)
        {
            stopwatch.Stop();
            return ProcessingResult<int[]>.Failure("Insertion sort operation was cancelled");
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            return ProcessingResult<int[]>.Failure($"Insertion sort failed: {ex.Message}");
        }
    }

    public bool IsOptimalFor(int[] data)
    {
        // Insertion sort is optimal for small arrays or nearly sorted data
        return data != null && (data.Length <= OptimalDataSizeThreshold || IsNearlySorted(data));
    }

    private void InsertionSort(int[] arr, CancellationToken cancellationToken)
    {
        for (int i = 1; i < arr.Length; i++)
        {
            cancellationToken.ThrowIfCancellationRequested();

            int key = arr[i];
            int j = i - 1;

            while (j >= 0 && arr[j] > key)
            {
                arr[j + 1] = arr[j];
                j--;
            }
            arr[j + 1] = key;
        }
    }

    private bool IsNearlySorted(int[] data)
    {
        int inversions = 0;
        for (int i = 0; i < data.Length - 1; i++)
        {
            if (data[i] > data[i + 1])
                inversions++;
        }
        return inversions < data.Length * 0.1; // Less than 10% inversions
    }
}
```

#### Merge Sort Strategy

```csharp
public class MergeSortStrategy : IDataProcessingStrategy<int[], int[]>
{
    public string StrategyName => "Merge Sort";
    public string Description => "Stable divide-and-conquer algorithm with guaranteed O(n log n) performance";
    public TimeComplexity TimeComplexity => TimeComplexity.Linearithmic;
    public SpaceComplexity SpaceComplexity => SpaceComplexity.Linear;
    public int OptimalDataSizeThreshold => 1000;

    public async Task<ProcessingResult<int[]>> ProcessAsync(int[] data, CancellationToken cancellationToken = default)
    {
        if (data == null)
            return ProcessingResult<int[]>.Failure("Input data cannot be null");

        var stopwatch = Stopwatch.StartNew();
        var initialMemory = GC.GetTotalMemory(false);

        try
        {
            var sortedArray = new int[data.Length];
            Array.Copy(data, sortedArray, data.Length);

            await Task.Run(() => MergeSort(sortedArray, 0, sortedArray.Length - 1, cancellationToken), cancellationToken);

            stopwatch.Stop();
            var finalMemory = GC.GetTotalMemory(false);
            var memoryUsed = Math.Max(0, finalMemory - initialMemory);

            var metrics = new Dictionary<string, object>
            {
                { "ArrayLength", data.Length },
                { "ComparisonsEstimate", data.Length * Math.Log2(data.Length) },
                { "AlgorithmType", "Divide and Conquer" },
                { "StabilityGuarantee", true }
            };

            return ProcessingResult<int[]>.Success(sortedArray, stopwatch.Elapsed,
                $"Merge sort completed for {data.Length} elements", memoryUsed, metrics);
        }
        catch (OperationCanceledException)
        {
            stopwatch.Stop();
            return ProcessingResult<int[]>.Failure("Merge sort operation was cancelled");
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            return ProcessingResult<int[]>.Failure($"Merge sort failed: {ex.Message}");
        }
    }

    public bool IsOptimalFor(int[] data)
    {
        // Merge sort is optimal for large datasets requiring stability
        return data != null && data.Length >= OptimalDataSizeThreshold;
    }

    private void MergeSort(int[] arr, int left, int right, CancellationToken cancellationToken)
    {
        if (left < right)
        {
            cancellationToken.ThrowIfCancellationRequested();

            int middle = left + (right - left) / 2;

            MergeSort(arr, left, middle, cancellationToken);
            MergeSort(arr, middle + 1, right, cancellationToken);
            Merge(arr, left, middle, right);
        }
    }

    private void Merge(int[] arr, int left, int middle, int right)
    {
        int leftSize = middle - left + 1;
        int rightSize = right - middle;

        int[] leftArray = new int[leftSize];
        int[] rightArray = new int[rightSize];

        Array.Copy(arr, left, leftArray, 0, leftSize);
        Array.Copy(arr, middle + 1, rightArray, 0, rightSize);

        int i = 0, j = 0, k = left;

        while (i < leftSize && j < rightSize)
        {
            if (leftArray[i] <= rightArray[j])
            {
                arr[k] = leftArray[i];
                i++;
            }
            else
            {
                arr[k] = rightArray[j];
                j++;
            }
            k++;
        }

        while (i < leftSize)
        {
            arr[k] = leftArray[i];
            i++;
            k++;
        }

        while (j < rightSize)
        {
            arr[k] = rightArray[j];
            j++;
            k++;
        }
    }
}
```

### Strategy Selection and Context (5 minutes)

```csharp
public class SortingContext
{
    private readonly List<IDataProcessingStrategy<int[], int[]>> _strategies;

    public SortingContext()
    {
        _strategies = new List<IDataProcessingStrategy<int[], int[]>>
        {
            new InsertionSortStrategy(),
            new QuickSortStrategy(),
            new MergeSortStrategy()
        };
    }

    public async Task<ProcessingResult<int[]>> SortAsync(int[] data, string preferredStrategy = null, 
                                                       CancellationToken cancellationToken = default)
    {
        if (data == null || data.Length == 0)
            return ProcessingResult<int[]>.Success(new int[0], TimeSpan.Zero, "Empty array sorted");

        IDataProcessingStrategy<int[], int[]> strategy;

        if (!string.IsNullOrEmpty(preferredStrategy))
        {
            strategy = _strategies.FirstOrDefault(s => 
                s.StrategyName.Equals(preferredStrategy, StringComparison.OrdinalIgnoreCase));
            
            if (strategy == null)
                return ProcessingResult<int[]>.Failure($"Strategy '{preferredStrategy}' not found");
        }
        else
        {
            strategy = SelectOptimalStrategy(data);
        }

        return await strategy.ProcessAsync(data, cancellationToken);
    }

    private IDataProcessingStrategy<int[], int[]> SelectOptimalStrategy(int[] data)
    {
        // Find the first strategy that considers itself optimal for this data
        var optimalStrategy = _strategies.FirstOrDefault(s => s.IsOptimalFor(data));
        
        // If no strategy is optimal, use default selection logic
        return optimalStrategy ?? SelectBySize(data);
    }

    private IDataProcessingStrategy<int[], int[]> SelectBySize(int[] data)
    {
        return data.Length switch
        {
            <= 50 => _strategies.OfType<InsertionSortStrategy>().First(),
            <= 1000 => _strategies.OfType<QuickSortStrategy>().First(),
            _ => _strategies.OfType<MergeSortStrategy>().First()
        };
    }

    public List<string> GetAvailableStrategies()
    {
        return _strategies.Select(s => s.StrategyName).ToList();
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

**Mastered in Part C**:

- Data processing strategy implementations for sorting algorithms
- Performance-based strategy selection using complexity analysis
- Algorithm-specific optimization and cancellation support
- Strategy selection logic based on data characteristics

**Next Steps**:

- **Part D**: Business Rules Strategies (Pricing models, validation rules) + Pattern Summary

## 🔗 Related Topics

**Prerequisites**:

- **[Part B - Payment Systems](10B_Design-Patterns-Part5B-Strategy-Pattern-Payment-Systems.md)**
- [Algorithm complexity analysis](../../algorithms/)

**Enables**:

- **[Part D - Business Rules](10D_Design-Patterns-Part5D-Strategy-Pattern-Business-Rules.md)**
- [Performance optimization patterns](../../performance-patterns/)
- [Algorithm selection systems](../../algorithm-patterns/)
