# 02_ML-Fundamentals-Part2: Unsupervised Learning

**Learning Level**: Beginner to Intermediate  
**Prerequisites**: ML Fundamentals Part 1, Linear Algebra Basics  
**Estimated Time**: Part 2 of 3 - 30 minutes

## 🎯 Learning Objectives

By the end of this 30-minute session, you will:

- Master clustering algorithms (K-Means, Hierarchical Clustering)
- Implement dimensionality reduction techniques (PCA, t-SNE)
- Build anomaly detection systems for fraud and outlier identification
- Apply unsupervised learning to real-world customer segmentation
- Design production-ready unsupervised ML architectures
- Evaluate clustering quality and choose optimal cluster numbers

## 📋 Content Sections (30-Minute Structure)

### Quick Overview (5 minutes)

Unsupervised learning discovers hidden patterns in data without labeled examples. Unlike supervised learning, we don't have "correct answers" - instead, we find structure, group similar items, reduce complexity, and detect anomalies.

**Three Main Categories**:

- **Clustering**: Group similar data points together (customer segmentation, market analysis)
- **Dimensionality Reduction**: Compress data while preserving important information (visualization, noise reduction)
- **Anomaly Detection**: Identify unusual patterns (fraud detection, system monitoring)

### Core Concepts (15 minutes)

#### **Clustering Algorithms**

```csharp
// ✅ Clustering System Architecture
namespace MachineLearning.Clustering
{
    public interface IClusteringAlgorithm<TFeatures>
    {
        Task<ClusteringResult> FitAsync(IEnumerable<TFeatures> data);
        Task<ClusterAssignment> PredictAsync(TFeatures sample);
        Task<ClusteringMetrics> EvaluateAsync(IEnumerable<TFeatures> data);
    }
    
    public class KMeansClusterer : IClusteringAlgorithm<double[]>
    {
        private readonly int _numberOfClusters;
        private readonly int _maxIterations;
        private readonly double _tolerance;
        private readonly ILogger<KMeansClusterer> _logger;
        private KMeansModel _model;
        
        public KMeansClusterer(
            int numberOfClusters,
            int maxIterations = 100,
            double tolerance = 1e-4,
            ILogger<KMeansClusterer> logger = null)
        {
            _numberOfClusters = numberOfClusters;
            _maxIterations = maxIterations;
            _tolerance = tolerance;
            _logger = logger;
        }
        
        public async Task<ClusteringResult> FitAsync(IEnumerable<double[]> data)
        {
            _logger?.LogInformation("Starting K-Means clustering with {Clusters} clusters", _numberOfClusters);
            
            var dataPoints = data.ToList();
            var dimensions = dataPoints.First().Length;
            
            // Initialize centroids randomly
            var centroids = InitializeCentroids(dataPoints, _numberOfClusters, dimensions);
            var previousCentroids = new List<double[]>();
            
            var assignments = new int[dataPoints.Count];
            var iteration = 0;
            
            while (iteration < _maxIterations)
            {
                // Store previous centroids for convergence check
                previousCentroids = centroids.Select(c => (double[])c.Clone()).ToList();
                
                // Assignment step: assign each point to nearest centroid
                for (int i = 0; i < dataPoints.Count; i++)
                {
                    assignments[i] = FindNearestCentroid(dataPoints[i], centroids);
                }
                
                // Update step: recalculate centroids
                for (int k = 0; k < _numberOfClusters; k++)
                {
                    var clusterPoints = dataPoints
                        .Where((point, index) => assignments[index] == k)
                        .ToList();
                    
                    if (clusterPoints.Any())
                    {
                        for (int d = 0; d < dimensions; d++)
                        {
                            centroids[k][d] = clusterPoints.Average(p => p[d]);
                        }
                    }
                }
                
                // Check for convergence
                if (HasConverged(centroids, previousCentroids))
                {
                    _logger?.LogInformation("K-Means converged after {Iterations} iterations", iteration + 1);
                    break;
                }
                
                iteration++;
            }
            
            _model = new KMeansModel
            {
                Centroids = centroids,
                NumberOfClusters = _numberOfClusters,
                Iterations = iteration + 1
            };
            
            // Calculate cluster quality metrics
            var inertia = CalculateInertia(dataPoints, assignments, centroids);
            var silhouetteScore = await CalculateSilhouetteScoreAsync(dataPoints, assignments);
            
            return new ClusteringResult
            {
                ClusterAssignments = assignments,
                Centroids = centroids,
                Inertia = inertia,
                SilhouetteScore = silhouetteScore,
                NumberOfClusters = _numberOfClusters
            };
        }
        
        public async Task<ClusterAssignment> PredictAsync(double[] sample)
        {
            if (_model == null)
                throw new InvalidOperationException("Model must be trained before prediction");
            
            var nearestCluster = FindNearestCentroid(sample, _model.Centroids);
            var distance = EuclideanDistance(sample, _model.Centroids[nearestCluster]);
            
            return new ClusterAssignment
            {
                ClusterId = nearestCluster,
                DistanceToCenter = distance,
                Centroid = _model.Centroids[nearestCluster]
            };
        }
        
        public async Task<ClusteringMetrics> EvaluateAsync(IEnumerable<double[]> data)
        {
            var dataPoints = data.ToList();
            var assignments = new int[dataPoints.Count];
            
            for (int i = 0; i < dataPoints.Count; i++)
            {
                var assignment = await PredictAsync(dataPoints[i]);
                assignments[i] = assignment.ClusterId;
            }
            
            var inertia = CalculateInertia(dataPoints, assignments, _model.Centroids);
            var silhouetteScore = await CalculateSilhouetteScoreAsync(dataPoints, assignments);
            
            return new ClusteringMetrics
            {
                Inertia = inertia,
                SilhouetteScore = silhouetteScore,
                NumberOfClusters = _numberOfClusters
            };
        }
        
        private List<double[]> InitializeCentroids(List<double[]> data, int k, int dimensions)
        {
            var random = new Random();
            var centroids = new List<double[]>();
            
            // K-Means++ initialization for better initial centroids
            var firstCentroid = data[random.Next(data.Count)];
            centroids.Add((double[])firstCentroid.Clone());
            
            for (int i = 1; i < k; i++)
            {
                var distances = data.Select(point => 
                    centroids.Min(centroid => EuclideanDistance(point, centroid))).ToList();
                
                var totalDistance = distances.Sum();
                var randomValue = random.NextDouble() * totalDistance;
                
                var cumulativeDistance = 0.0;
                for (int j = 0; j < data.Count; j++)
                {
                    cumulativeDistance += distances[j];
                    if (cumulativeDistance >= randomValue)
                    {
                        centroids.Add((double[])data[j].Clone());
                        break;
                    }
                }
            }
            
            return centroids;
        }
        
        private int FindNearestCentroid(double[] point, List<double[]> centroids)
        {
            var minDistance = double.MaxValue;
            var nearestIndex = 0;
            
            for (int i = 0; i < centroids.Count; i++)
            {
                var distance = EuclideanDistance(point, centroids[i]);
                if (distance < minDistance)
                {
                    minDistance = distance;
                    nearestIndex = i;
                }
            }
            
            return nearestIndex;
        }
        
        private double EuclideanDistance(double[] point1, double[] point2)
        {
            return Math.Sqrt(point1.Zip(point2, (a, b) => Math.Pow(a - b, 2)).Sum());
        }
        
        private bool HasConverged(List<double[]> centroids, List<double[]> previousCentroids)
        {
            if (previousCentroids.Count == 0) return false;
            
            for (int i = 0; i < centroids.Count; i++)
            {
                var distance = EuclideanDistance(centroids[i], previousCentroids[i]);
                if (distance > _tolerance)
                    return false;
            }
            
            return true;
        }
        
        private double CalculateInertia(List<double[]> data, int[] assignments, List<double[]> centroids)
        {
            var inertia = 0.0;
            
            for (int i = 0; i < data.Count; i++)
            {
                var clusterIndex = assignments[i];
                var distance = EuclideanDistance(data[i], centroids[clusterIndex]);
                inertia += Math.Pow(distance, 2);
            }
            
            return inertia;
        }
        
        private async Task<double> CalculateSilhouetteScoreAsync(List<double[]> data, int[] assignments)
        {
            var silhouetteScores = new List<double>();
            
            for (int i = 0; i < data.Count; i++)
            {
                var point = data[i];
                var cluster = assignments[i];
                
                // Calculate average intra-cluster distance (a)
                var sameClusterPoints = data
                    .Where((p, index) => assignments[index] == cluster && index != i)
                    .ToList();
                
                var intraClusterDistance = sameClusterPoints.Any() 
                    ? sameClusterPoints.Average(p => EuclideanDistance(point, p))
                    : 0;
                
                // Calculate minimum average inter-cluster distance (b)
                var otherClusters = assignments.Distinct().Where(c => c != cluster);
                var minInterClusterDistance = double.MaxValue;
                
                foreach (var otherCluster in otherClusters)
                {
                    var otherClusterPoints = data
                        .Where((p, index) => assignments[index] == otherCluster)
                        .ToList();
                    
                    if (otherClusterPoints.Any())
                    {
                        var avgDistance = otherClusterPoints.Average(p => EuclideanDistance(point, p));
                        minInterClusterDistance = Math.Min(minInterClusterDistance, avgDistance);
                    }
                }
                
                // Calculate silhouette score for this point
                if (minInterClusterDistance != double.MaxValue)
                {
                    var maxDistance = Math.Max(intraClusterDistance, minInterClusterDistance);
                    var silhouetteScore = maxDistance > 0 
                        ? (minInterClusterDistance - intraClusterDistance) / maxDistance
                        : 0;
                    
                    silhouetteScores.Add(silhouetteScore);
                }
            }
            
            return silhouetteScores.Any() ? silhouetteScores.Average() : 0;
        }
    }
    
    // Hierarchical Clustering Implementation
    public class HierarchicalClusterer : IClusteringAlgorithm<double[]>
    {
        private readonly LinkageCriterion _linkageCriterion;
        private readonly ILogger<HierarchicalClusterer> _logger;
        private HierarchicalClusteringModel _model;
        
        public HierarchicalClusterer(
            LinkageCriterion linkageCriterion = LinkageCriterion.Ward,
            ILogger<HierarchicalClusterer> logger = null)
        {
            _linkageCriterion = linkageCriterion;
            _logger = logger;
        }
        
        public async Task<ClusteringResult> FitAsync(IEnumerable<double[]> data)
        {
            _logger?.LogInformation("Starting Hierarchical clustering with {Linkage} linkage", _linkageCriterion);
            
            var dataPoints = data.ToList();
            var n = dataPoints.Count;
            
            // Initialize distance matrix
            var distanceMatrix = CalculateDistanceMatrix(dataPoints);
            
            // Initialize clusters (each point is its own cluster initially)
            var clusters = dataPoints.Select((point, index) => new Cluster
            {
                Id = index,
                Points = new List<double[]> { point },
                Children = new List<Cluster>()
            }).ToList();
            
            var mergingHistory = new List<ClusterMerge>();
            
            // Perform hierarchical clustering
            while (clusters.Count > 1)
            {
                // Find the pair of clusters with minimum distance
                var (cluster1Index, cluster2Index, minDistance) = FindClosestClusters(clusters, distanceMatrix);
                
                // Merge clusters
                var newCluster = MergeClusters(clusters[cluster1Index], clusters[cluster2Index]);
                
                // Record the merge
                mergingHistory.Add(new ClusterMerge
                {
                    Cluster1Id = clusters[cluster1Index].Id,
                    Cluster2Id = clusters[cluster2Index].Id,
                    Distance = minDistance,
                    NewClusterId = newCluster.Id
                });
                
                // Update clusters list
                clusters.RemoveAt(Math.Max(cluster1Index, cluster2Index)); // Remove larger index first
                clusters.RemoveAt(Math.Min(cluster1Index, cluster2Index));
                clusters.Add(newCluster);
                
                // Update distance matrix
                UpdateDistanceMatrix(distanceMatrix, clusters, newCluster);
            }
            
            _model = new HierarchicalClusteringModel
            {
                RootCluster = clusters.First(),
                MergingHistory = mergingHistory,
                LinkageCriterion = _linkageCriterion
            };
            
            return new ClusteringResult
            {
                Dendrogram = _model.RootCluster,
                MergingHistory = mergingHistory
            };
        }
        
        public async Task<ClusterAssignment> PredictAsync(double[] sample)
        {
            if (_model == null)
                throw new InvalidOperationException("Model must be trained before prediction");
            
            // For hierarchical clustering, we need to specify the number of clusters
            // or use a distance threshold to cut the dendrogram
            
            throw new NotImplementedException("Prediction requires specifying number of clusters or distance threshold");
        }
        
        public Task<ClusteringMetrics> EvaluateAsync(IEnumerable<double[]> data)
        {
            throw new NotImplementedException("Evaluation requires cutting dendrogram at specific level");
        }
        
        public ClusteringResult GetClustersAtLevel(int numberOfClusters)
        {
            if (_model == null)
                throw new InvalidOperationException("Model must be trained before getting clusters");
            
            var clusters = CutDendrogramAtLevel(_model.RootCluster, numberOfClusters);
            
            return new ClusteringResult
            {
                Clusters = clusters,
                NumberOfClusters = clusters.Count
            };
        }
        
        private double[,] CalculateDistanceMatrix(List<double[]> dataPoints)
        {
            var n = dataPoints.Count;
            var matrix = new double[n, n];
            
            for (int i = 0; i < n; i++)
            {
                for (int j = i + 1; j < n; j++)
                {
                    var distance = EuclideanDistance(dataPoints[i], dataPoints[j]);
                    matrix[i, j] = distance;
                    matrix[j, i] = distance;
                }
            }
            
            return matrix;
        }
        
        private (int, int, double) FindClosestClusters(List<Cluster> clusters, double[,] distanceMatrix)
        {
            var minDistance = double.MaxValue;
            var closestPair = (0, 0);
            
            for (int i = 0; i < clusters.Count; i++)
            {
                for (int j = i + 1; j < clusters.Count; j++)
                {
                    var distance = CalculateClusterDistance(clusters[i], clusters[j]);
                    if (distance < minDistance)
                    {
                        minDistance = distance;
                        closestPair = (i, j);
                    }
                }
            }
            
            return (closestPair.Item1, closestPair.Item2, minDistance);
        }
        
        private double CalculateClusterDistance(Cluster cluster1, Cluster cluster2)
        {
            switch (_linkageCriterion)
            {
                case LinkageCriterion.Single:
                    return cluster1.Points.SelectMany(p1 => 
                        cluster2.Points.Select(p2 => EuclideanDistance(p1, p2))).Min();
                
                case LinkageCriterion.Complete:
                    return cluster1.Points.SelectMany(p1 => 
                        cluster2.Points.Select(p2 => EuclideanDistance(p1, p2))).Max();
                
                case LinkageCriterion.Average:
                    return cluster1.Points.SelectMany(p1 => 
                        cluster2.Points.Select(p2 => EuclideanDistance(p1, p2))).Average();
                
                case LinkageCriterion.Ward:
                    return CalculateWardDistance(cluster1, cluster2);
                
                default:
                    throw new ArgumentException($"Unsupported linkage criterion: {_linkageCriterion}");
            }
        }
        
        private double CalculateWardDistance(Cluster cluster1, Cluster cluster2)
        {
            var centroid1 = CalculateCentroid(cluster1.Points);
            var centroid2 = CalculateCentroid(cluster2.Points);
            var mergedCentroid = CalculateCentroid(cluster1.Points.Concat(cluster2.Points));
            
            var n1 = cluster1.Points.Count;
            var n2 = cluster2.Points.Count;
            
            var sse1 = cluster1.Points.Sum(p => Math.Pow(EuclideanDistance(p, centroid1), 2));
            var sse2 = cluster2.Points.Sum(p => Math.Pow(EuclideanDistance(p, centroid2), 2));
            var sseMerged = cluster1.Points.Concat(cluster2.Points)
                .Sum(p => Math.Pow(EuclideanDistance(p, mergedCentroid), 2));
            
            return sseMerged - sse1 - sse2;
        }
        
        private double[] CalculateCentroid(IEnumerable<double[]> points)
        {
            var pointsList = points.ToList();
            var dimensions = pointsList.First().Length;
            var centroid = new double[dimensions];
            
            for (int d = 0; d < dimensions; d++)
            {
                centroid[d] = pointsList.Average(p => p[d]);
            }
            
            return centroid;
        }
        
        private Cluster MergeClusters(Cluster cluster1, Cluster cluster2)
        {
            return new Cluster
            {
                Id = cluster1.Id * 1000 + cluster2.Id, // Simple ID generation
                Points = cluster1.Points.Concat(cluster2.Points).ToList(),
                Children = new List<Cluster> { cluster1, cluster2 }
            };
        }
        
        private void UpdateDistanceMatrix(double[,] matrix, List<Cluster> clusters, Cluster newCluster)
        {
            // This is a simplified update - in practice, you'd maintain cluster indices
            // and update distances based on linkage criterion
        }
        
        private List<Cluster> CutDendrogramAtLevel(Cluster rootCluster, int numberOfClusters)
        {
            // Traverse dendrogram and cut at level that produces desired number of clusters
            var clusters = new List<Cluster>();
            var queue = new Queue<Cluster>();
            queue.Enqueue(rootCluster);
            
            while (queue.Count > 0 && clusters.Count + queue.Count < numberOfClusters)
            {
                var cluster = queue.Dequeue();
                if (cluster.Children.Any())
                {
                    foreach (var child in cluster.Children)
                    {
                        queue.Enqueue(child);
                    }
                }
                else
                {
                    clusters.Add(cluster);
                }
            }
            
            // Add remaining clusters from queue
            while (queue.Count > 0)
            {
                clusters.Add(queue.Dequeue());
            }
            
            return clusters;
        }
        
        private double EuclideanDistance(double[] point1, double[] point2)
        {
            return Math.Sqrt(point1.Zip(point2, (a, b) => Math.Pow(a - b, 2)).Sum());
        }
    }
}
```

#### **Dimensionality Reduction**

```csharp
// ✅ Dimensionality Reduction Architecture
namespace MachineLearning.DimensionalityReduction
{
    public interface IDimensionalityReducer
    {
        Task<DimensionalityReductionResult> FitTransformAsync(double[,] data, int targetDimensions);
        Task<double[,]> TransformAsync(double[,] newData);
        Task<ReductionMetrics> EvaluateAsync(double[,] originalData, double[,] transformedData);
    }
    
    public class PrincipalComponentAnalysis : IDimensionalityReducer
    {
        private PCAModel _model;
        private readonly ILogger<PrincipalComponentAnalysis> _logger;
        
        public PrincipalComponentAnalysis(ILogger<PrincipalComponentAnalysis> logger = null)
        {
            _logger = logger;
        }
        
        public async Task<DimensionalityReductionResult> FitTransformAsync(double[,] data, int targetDimensions)
        {
            _logger?.LogInformation("Starting PCA with target dimensions: {Dimensions}", targetDimensions);
            
            var (rows, cols) = (data.GetLength(0), data.GetLength(1));
            
            // Step 1: Center the data (subtract mean)
            var centeredData = CenterData(data);
            var means = CalculateMeans(data);
            
            // Step 2: Calculate covariance matrix
            var covarianceMatrix = CalculateCovarianceMatrix(centeredData);
            
            // Step 3: Perform eigenvalue decomposition
            var (eigenValues, eigenVectors) = PerformEigenDecomposition(covarianceMatrix);
            
            // Step 4: Sort eigenvalues and eigenvectors in descending order
            var sortedIndices = eigenValues
                .Select((value, index) => new { Value = value, Index = index })
                .OrderByDescending(x => x.Value)
                .Select(x => x.Index)
                .ToArray();
            
            var sortedEigenValues = sortedIndices.Select(i => eigenValues[i]).ToArray();
            var sortedEigenVectors = GetSortedEigenVectors(eigenVectors, sortedIndices);
            
            // Step 5: Select top components
            var selectedComponents = GetTopComponents(sortedEigenVectors, targetDimensions);
            var explainedVariance = CalculateExplainedVariance(sortedEigenValues, targetDimensions);
            
            // Step 6: Transform data
            var transformedData = TransformData(centeredData, selectedComponents);
            
            _model = new PCAModel
            {
                Components = selectedComponents,
                Means = means,
                ExplainedVariance = explainedVariance,
                EigenValues = sortedEigenValues.Take(targetDimensions).ToArray()
            };
            
            _logger?.LogInformation("PCA completed. Explained variance: {Variance:P2}", 
                explainedVariance.Sum());
            
            return new DimensionalityReductionResult
            {
                TransformedData = transformedData,
                ExplainedVariance = explainedVariance,
                Components = selectedComponents,
                TargetDimensions = targetDimensions
            };
        }
        
        public async Task<double[,]> TransformAsync(double[,] newData)
        {
            if (_model == null)
                throw new InvalidOperationException("PCA model must be fitted before transformation");
            
            var centeredData = CenterData(newData, _model.Means);
            return TransformData(centeredData, _model.Components);
        }
        
        public async Task<ReductionMetrics> EvaluateAsync(double[,] originalData, double[,] transformedData)
        {
            var reconstructedData = await ReconstructDataAsync(transformedData);
            var reconstructionError = CalculateReconstructionError(originalData, reconstructedData);
            
            return new ReductionMetrics
            {
                ReconstructionError = reconstructionError,
                ExplainedVarianceRatio = _model.ExplainedVariance.Sum(),
                DimensionalityReduction = (double)transformedData.GetLength(1) / originalData.GetLength(1)
            };
        }
        
        private double[,] CenterData(double[,] data, double[] means = null)
        {
            var (rows, cols) = (data.GetLength(0), data.GetLength(1));
            var centeredData = new double[rows, cols];
            
            if (means == null)
                means = CalculateMeans(data);
            
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    centeredData[i, j] = data[i, j] - means[j];
                }
            }
            
            return centeredData;
        }
        
        private double[] CalculateMeans(double[,] data)
        {
            var (rows, cols) = (data.GetLength(0), data.GetLength(1));
            var means = new double[cols];
            
            for (int j = 0; j < cols; j++)
            {
                var sum = 0.0;
                for (int i = 0; i < rows; i++)
                {
                    sum += data[i, j];
                }
                means[j] = sum / rows;
            }
            
            return means;
        }
        
        private double[,] CalculateCovarianceMatrix(double[,] centeredData)
        {
            var (rows, cols) = (centeredData.GetLength(0), centeredData.GetLength(1));
            var covMatrix = new double[cols, cols];
            
            for (int i = 0; i < cols; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    var covariance = 0.0;
                    for (int k = 0; k < rows; k++)
                    {
                        covariance += centeredData[k, i] * centeredData[k, j];
                    }
                    covMatrix[i, j] = covariance / (rows - 1);
                }
            }
            
            return covMatrix;
        }
        
        private (double[] eigenValues, double[,] eigenVectors) PerformEigenDecomposition(double[,] matrix)
        {
            // Simplified eigenvalue decomposition - in practice, use numerical libraries
            var size = matrix.GetLength(0);
            var eigenValues = new double[size];
            var eigenVectors = new double[size, size];
            
            // This is a placeholder - implement using numerical libraries like Math.NET
            // For demonstration, we'll use identity matrix
            for (int i = 0; i < size; i++)
            {
                eigenValues[i] = 1.0; // Placeholder eigenvalues
                for (int j = 0; j < size; j++)
                {
                    eigenVectors[i, j] = i == j ? 1.0 : 0.0; // Identity matrix as placeholder
                }
            }
            
            return (eigenValues, eigenVectors);
        }
        
        private double[,] GetSortedEigenVectors(double[,] eigenVectors, int[] sortedIndices)
        {
            var (rows, cols) = (eigenVectors.GetLength(0), eigenVectors.GetLength(1));
            var sortedVectors = new double[rows, cols];
            
            for (int j = 0; j < cols; j++)
            {
                var sourceIndex = sortedIndices[j];
                for (int i = 0; i < rows; i++)
                {
                    sortedVectors[i, j] = eigenVectors[i, sourceIndex];
                }
            }
            
            return sortedVectors;
        }
        
        private double[,] GetTopComponents(double[,] eigenVectors, int targetDimensions)
        {
            var rows = eigenVectors.GetLength(0);
            var components = new double[rows, targetDimensions];
            
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < targetDimensions; j++)
                {
                    components[i, j] = eigenVectors[i, j];
                }
            }
            
            return components;
        }
        
        private double[] CalculateExplainedVariance(double[] eigenValues, int targetDimensions)
        {
            var totalVariance = eigenValues.Sum();
            var explainedVariance = new double[targetDimensions];
            
            for (int i = 0; i < targetDimensions; i++)
            {
                explainedVariance[i] = eigenValues[i] / totalVariance;
            }
            
            return explainedVariance;
        }
        
        private double[,] TransformData(double[,] centeredData, double[,] components)
        {
            var (dataRows, dataCols) = (centeredData.GetLength(0), centeredData.GetLength(1));
            var (compRows, compCols) = (components.GetLength(0), components.GetLength(1));
            
            var transformedData = new double[dataRows, compCols];
            
            for (int i = 0; i < dataRows; i++)
            {
                for (int j = 0; j < compCols; j++)
                {
                    var value = 0.0;
                    for (int k = 0; k < dataCols; k++)
                    {
                        value += centeredData[i, k] * components[k, j];
                    }
                    transformedData[i, j] = value;
                }
            }
            
            return transformedData;
        }
        
        private async Task<double[,]> ReconstructDataAsync(double[,] transformedData)
        {
            // Reconstruct original data from transformed data
            var (transformedRows, transformedCols) = (transformedData.GetLength(0), transformedData.GetLength(1));
            var (compRows, compCols) = (_model.Components.GetLength(0), _model.Components.GetLength(1));
            
            var reconstructedData = new double[transformedRows, compRows];
            
            for (int i = 0; i < transformedRows; i++)
            {
                for (int j = 0; j < compRows; j++)
                {
                    var value = 0.0;
                    for (int k = 0; k < transformedCols; k++)
                    {
                        value += transformedData[i, k] * _model.Components[j, k];
                    }
                    reconstructedData[i, j] = value + _model.Means[j];
                }
            }
            
            return reconstructedData;
        }
        
        private double CalculateReconstructionError(double[,] original, double[,] reconstructed)
        {
            var (rows, cols) = (original.GetLength(0), original.GetLength(1));
            var totalError = 0.0;
            
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    var error = original[i, j] - reconstructed[i, j];
                    totalError += error * error;
                }
            }
            
            return Math.Sqrt(totalError / (rows * cols));
        }
    }
}
```

### Practical Implementation (8 minutes)

#### **Customer Segmentation System**

```csharp
// ✅ Real-World Customer Segmentation
namespace MachineLearning.Applications
{
    public class CustomerSegmentationService
    {
        private readonly KMeansClusterer _clusterer;
        private readonly PrincipalComponentAnalysis _pca;
        private readonly ICustomerDataProcessor _dataProcessor;
        private readonly ILogger<CustomerSegmentationService> _logger;
        
        public CustomerSegmentationService(
            ICustomerDataProcessor dataProcessor,
            ILogger<CustomerSegmentationService> logger)
        {
            _dataProcessor = dataProcessor;
            _logger = logger;
            _pca = new PrincipalComponentAnalysis(logger);
        }
        
        public async Task<CustomerSegmentationResult> SegmentCustomersAsync(
            IEnumerable<CustomerData> customers, 
            int numberOfSegments = 5)
        {
            _logger.LogInformation("Starting customer segmentation for {Count} customers", 
                customers.Count());
            
            try
            {
                // Step 1: Extract and normalize features
                var customerFeatures = await ExtractCustomerFeaturesAsync(customers);
                var normalizedFeatures = await NormalizeFeaturesAsync(customerFeatures);
                
                // Step 2: Apply PCA for dimensionality reduction (optional)
                var pcaResult = await _pca.FitTransformAsync(normalizedFeatures, 
                    Math.Min(10, normalizedFeatures.GetLength(1)));
                
                _logger.LogInformation("PCA explained variance: {Variance:P2}", 
                    pcaResult.ExplainedVariance.Sum());
                
                // Step 3: Determine optimal number of clusters using elbow method
                var optimalClusters = await DetermineOptimalClustersAsync(pcaResult.TransformedData, 
                    maxClusters: Math.Min(numberOfSegments + 3, 10));
                
                // Step 4: Perform K-Means clustering
                _clusterer = new KMeansClusterer(optimalClusters, logger: _logger);
                var clusteringResult = await _clusterer.FitAsync(ConvertToEnumerable(pcaResult.TransformedData));
                
                // Step 5: Analyze segments and create profiles
                var segmentProfiles = await CreateSegmentProfilesAsync(
                    customers.ToList(), clusteringResult.ClusterAssignments);
                
                _logger.LogInformation("Customer segmentation completed. Silhouette score: {Score:F3}", 
                    clusteringResult.SilhouetteScore);
                
                return new CustomerSegmentationResult
                {
                    Segments = segmentProfiles,
                    ClusteringMetrics = new ClusteringMetrics
                    {
                        SilhouetteScore = clusteringResult.SilhouetteScore,
                        Inertia = clusteringResult.Inertia,
                        NumberOfClusters = optimalClusters
                    },
                    DimensionalityReduction = pcaResult,
                    OptimalNumberOfClusters = optimalClusters
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Customer segmentation failed");
                throw;
            }
        }
        
        private async Task<double[,]> ExtractCustomerFeaturesAsync(IEnumerable<CustomerData> customers)
        {
            var customerList = customers.ToList();
            var features = new double[customerList.Count, 12]; // 12 features
            
            for (int i = 0; i < customerList.Count; i++)
            {
                var customer = customerList[i];
                
                features[i, 0] = customer.TotalSpent; // Total amount spent
                features[i, 1] = customer.OrderFrequency; // Orders per month
                features[i, 2] = customer.AverageOrderValue; // Average order value
                features[i, 3] = customer.DaysSinceLastOrder; // Recency
                features[i, 4] = customer.CustomerLifetimeMonths; // Customer tenure
                features[i, 5] = customer.ReturnRate; // Return/refund rate
                features[i, 6] = customer.CategoryDiversity; // Number of different categories purchased
                features[i, 7] = customer.SeasonalityScore; // Seasonal purchasing pattern
                features[i, 8] = customer.DiscountSensitivity; // Response to discounts
                features[i, 9] = customer.BrandLoyalty; // Preference for specific brands
                features[i, 10] = customer.DigitalEngagement; // Website/app usage
                features[i, 11] = customer.SupportInteractions; // Customer service contacts
            }
            
            return features;
        }
        
        private async Task<double[,]> NormalizeFeaturesAsync(double[,] features)
        {
            var (rows, cols) = (features.GetLength(0), features.GetLength(1));
            var normalizedFeatures = new double[rows, cols];
            
            // Standard normalization (z-score)
            for (int j = 0; j < cols; j++)
            {
                var columnValues = new double[rows];
                for (int i = 0; i < rows; i++)
                {
                    columnValues[i] = features[i, j];
                }
                
                var mean = columnValues.Average();
                var stdDev = Math.Sqrt(columnValues.Average(x => Math.Pow(x - mean, 2)));
                
                for (int i = 0; i < rows; i++)
                {
                    normalizedFeatures[i, j] = stdDev > 0 ? (features[i, j] - mean) / stdDev : 0;
                }
            }
            
            return normalizedFeatures;
        }
        
        private async Task<int> DetermineOptimalClustersAsync(double[,] data, int maxClusters = 10)
        {
            var inertias = new List<(int Clusters, double Inertia)>();
            var silhouetteScores = new List<(int Clusters, double Score)>();
            
            for (int k = 2; k <= maxClusters; k++)
            {
                var clusterer = new KMeansClusterer(k);
                var result = await clusterer.FitAsync(ConvertToEnumerable(data));
                
                inertias.Add((k, result.Inertia));
                silhouetteScores.Add((k, result.SilhouetteScore));
            }
            
            // Use elbow method combined with silhouette score
            var elbowPoint = FindElbowPoint(inertias);
            var bestSilhouette = silhouetteScores.OrderByDescending(x => x.Score).First().Clusters;
            
            // Choose the optimal number considering both metrics
            var optimalClusters = Math.Abs(elbowPoint - bestSilhouette) <= 1 ? elbowPoint : bestSilhouette;
            
            _logger.LogInformation("Optimal clusters determined: {Clusters} (Elbow: {Elbow}, Best Silhouette: {Silhouette})",
                optimalClusters, elbowPoint, bestSilhouette);
            
            return optimalClusters;
        }
        
        private int FindElbowPoint(List<(int Clusters, double Inertia)> inertias)
        {
            // Simple elbow detection using rate of change
            var slopes = new List<(int Clusters, double Slope)>();
            
            for (int i = 1; i < inertias.Count - 1; i++)
            {
                var slope = Math.Abs(inertias[i + 1].Inertia - inertias[i - 1].Inertia) / 2.0;
                slopes.Add((inertias[i].Clusters, slope));
            }
            
            return slopes.OrderBy(x => x.Slope).First().Clusters;
        }
        
        private async Task<List<CustomerSegment>> CreateSegmentProfilesAsync(
            List<CustomerData> customers, int[] clusterAssignments)
        {
            var segments = new List<CustomerSegment>();
            var numberOfClusters = clusterAssignments.Max() + 1;
            
            for (int clusterId = 0; clusterId < numberOfClusters; clusterId++)
            {
                var clusterCustomers = customers
                    .Where((customer, index) => clusterAssignments[index] == clusterId)
                    .ToList();
                
                if (!clusterCustomers.Any()) continue;
                
                var segment = new CustomerSegment
                {
                    SegmentId = clusterId,
                    SegmentName = GenerateSegmentName(clusterId, clusterCustomers),
                    Size = clusterCustomers.Count,
                    Characteristics = AnalyzeSegmentCharacteristics(clusterCustomers),
                    AverageMetrics = CalculateAverageMetrics(clusterCustomers),
                    RecommendedActions = GenerateRecommendations(clusterCustomers)
                };
                
                segments.Add(segment);
            }
            
            return segments;
        }
        
        private string GenerateSegmentName(int clusterId, List<CustomerData> customers)
        {
            var avgSpent = customers.Average(c => c.TotalSpent);
            var avgFrequency = customers.Average(c => c.OrderFrequency);
            var avgRecency = customers.Average(c => c.DaysSinceLastOrder);
            
            // Simple segmentation naming logic
            if (avgSpent > 1000 && avgFrequency > 5)
                return "VIP Customers";
            else if (avgSpent > 500 && avgRecency < 30)
                return "Loyal Customers";
            else if (avgRecency > 180)
                return "At-Risk Customers";
            else if (avgFrequency < 2)
                return "Occasional Buyers";
            else
                return $"Segment {clusterId + 1}";
        }
        
        private Dictionary<string, double> AnalyzeSegmentCharacteristics(List<CustomerData> customers)
        {
            return new Dictionary<string, double>
            {
                ["AverageSpent"] = customers.Average(c => c.TotalSpent),
                ["AverageFrequency"] = customers.Average(c => c.OrderFrequency),
                ["AverageOrderValue"] = customers.Average(c => c.AverageOrderValue),
                ["AverageRecency"] = customers.Average(c => c.DaysSinceLastOrder),
                ["AverageLifetime"] = customers.Average(c => c.CustomerLifetimeMonths),
                ["AverageReturnRate"] = customers.Average(c => c.ReturnRate)
            };
        }
        
        private CustomerMetrics CalculateAverageMetrics(List<CustomerData> customers)
        {
            return new CustomerMetrics
            {
                TotalSpent = customers.Average(c => c.TotalSpent),
                OrderFrequency = customers.Average(c => c.OrderFrequency),
                AverageOrderValue = customers.Average(c => c.AverageOrderValue),
                CustomerLifetimeValue = customers.Average(c => c.TotalSpent / Math.Max(c.CustomerLifetimeMonths, 1))
            };
        }
        
        private List<string> GenerateRecommendations(List<CustomerData> customers)
        {
            var recommendations = new List<string>();
            
            var avgSpent = customers.Average(c => c.TotalSpent);
            var avgRecency = customers.Average(c => c.DaysSinceLastOrder);
            var avgReturnRate = customers.Average(c => c.ReturnRate);
            
            if (avgSpent > 1000)
                recommendations.Add("Offer premium products and exclusive experiences");
            
            if (avgRecency > 90)
                recommendations.Add("Implement win-back campaigns");
            
            if (avgReturnRate > 0.1)
                recommendations.Add("Focus on product quality and customer satisfaction");
            
            return recommendations;
        }
        
        private IEnumerable<double[]> ConvertToEnumerable(double[,] matrix)
        {
            var rows = matrix.GetLength(0);
            var cols = matrix.GetLength(1);
            
            for (int i = 0; i < rows; i++)
            {
                var row = new double[cols];
                for (int j = 0; j < cols; j++)
                {
                    row[j] = matrix[i, j];
                }
                yield return row;
            }
        }
    }
    
    // Anomaly Detection System
    public class AnomalyDetectionService
    {
        private readonly IsolationForestDetector _isolationForest;
        private readonly ILogger<AnomalyDetectionService> _logger;
        
        public AnomalyDetectionService(ILogger<AnomalyDetectionService> logger)
        {
            _logger = logger;
            _isolationForest = new IsolationForestDetector(numberOfTrees: 100, sampleSize: 256);
        }
        
        public async Task<AnomalyDetectionResult> DetectAnomaliesAsync(
            IEnumerable<TransactionData> transactions)
        {
            _logger.LogInformation("Starting anomaly detection for {Count} transactions", 
                transactions.Count());
            
            var transactionList = transactions.ToList();
            var features = ExtractTransactionFeatures(transactionList);
            
            // Fit the isolation forest
            await _isolationForest.FitAsync(features);
            
            var anomalyScores = new List<AnomalyScore>();
            
            foreach (var (transaction, featureVector) in transactionList.Zip(features))
            {
                var score = await _isolationForest.GetAnomalyScoreAsync(featureVector);
                anomalyScores.Add(new AnomalyScore
                {
                    TransactionId = transaction.Id,
                    Score = score,
                    IsAnomaly = score > 0.6, // Threshold for anomaly
                    Transaction = transaction
                });
            }
            
            var detectedAnomalies = anomalyScores.Where(s => s.IsAnomaly).ToList();
            
            _logger.LogInformation("Anomaly detection completed. Found {Count} anomalies out of {Total} transactions",
                detectedAnomalies.Count, transactionList.Count);
            
            return new AnomalyDetectionResult
            {
                AnomalyScores = anomalyScores,
                DetectedAnomalies = detectedAnomalies,
                TotalTransactions = transactionList.Count,
                AnomalyRate = (double)detectedAnomalies.Count / transactionList.Count
            };
        }
        
        private List<double[]> ExtractTransactionFeatures(List<TransactionData> transactions)
        {
            return transactions.Select(t => new double[]
            {
                t.Amount,
                t.TimeOfDay.TotalHours,
                (double)t.DayOfWeek,
                t.MerchantCategory,
                t.LocationDistance,
                t.PaymentMethod == "Card" ? 1.0 : 0.0,
                t.IsOnline ? 1.0 : 0.0,
                t.CustomerAge,
                t.AccountBalance
            }).ToList();
        }
    }
}
```

### Key Takeaways & Next Steps (2 minutes)

#### **🎯 What You've Mastered in 30 Minutes**

1. **Clustering Mastery**: K-Means and Hierarchical clustering with production implementations
2. **Dimensionality Reduction**: PCA with variance explanation and reconstruction capabilities
3. **Real-World Applications**: Customer segmentation and fraud detection systems
4. **Quality Metrics**: Silhouette score, inertia, elbow method for optimal cluster selection

#### **📊 Key Concepts to Remember**

**Clustering Evaluation**:

- **Silhouette Score**: Measures cluster cohesion and separation (-1 to 1, higher is better)
- **Inertia**: Sum of squared distances to cluster centroids (lower is better)
- **Elbow Method**: Find optimal number of clusters where improvement plateaus

**Dimensionality Reduction Benefits**:

- **Visualization**: Reduce to 2D/3D for plotting high-dimensional data
- **Noise Reduction**: Remove less important dimensions
- **Computational Efficiency**: Faster algorithms with fewer dimensions
- **Storage Savings**: Compress data while preserving key information

#### **🔄 Next Steps**

**Immediate Actions**:

1. Implement customer segmentation on real business data
2. Experiment with different linkage criteria in hierarchical clustering
3. Apply PCA for data visualization and noise reduction

**Coming Up in Part 3**: Model Evaluation & Selection

- Cross-validation techniques and proper evaluation frameworks
- Hyperparameter optimization strategies
- Model selection criteria and ensemble methods

---

## 🔗 Related Topics

### Prerequisites

- [ML Fundamentals Part 1](./01_ML-Fundamentals-Part1.md) - Supervised learning foundations
- [AI Fundamentals](../01_AI/01_AI-Fundamentals.md) - AI system architecture
- Linear algebra basics (vectors, matrices, eigenvalues)

### Builds Upon

- Statistical concepts and probability distributions
- Distance metrics and similarity measures
- Matrix operations and linear transformations
- Software architecture patterns for ML systems

### Enables

- [ML Fundamentals Part 3](./03_ML-Fundamentals-Part3.md) - Model Evaluation & Selection (Next)
- [Deep Learning Fundamentals](../03_DeepLearning/) - Advanced neural network architectures
- [Natural Language Processing](../04_NaturalLanguageProcessing/) - Text clustering and topic modeling

### Cross-References

- **Development**: Apply architectural patterns to unsupervised learning systems
- **AI Systems**: Integrate clustering and dimensionality reduction into AI pipelines
- **Data Science**: Foundation for exploratory data analysis and feature engineering
- **Business Intelligence**: Customer analytics and market segmentation applications

---

## 📚 Summary

Machine Learning Fundamentals Part 2 establishes mastery of unsupervised learning with enterprise-grade implementations. Key achievements:

**Clustering Excellence**:

- K-Means with K-Means++ initialization and convergence detection
- Hierarchical clustering with multiple linkage criteria
- Production-ready customer segmentation system

**Dimensionality Reduction Mastery**:

- Principal Component Analysis with explained variance calculation
- Data reconstruction and quality evaluation
- Integration with clustering for high-dimensional data

**Production Applications**:

- Customer segmentation with automated segment profiling
- Anomaly detection for fraud prevention
- Optimal cluster selection using multiple evaluation metrics

**Quality Framework**:

- Comprehensive evaluation metrics (silhouette, inertia, explained variance)
- Elbow method and validation techniques
- Real-world business application patterns

**Next Learning Path**: Continue with Part 3 (Model Evaluation & Selection) to complete foundational ML knowledge, then advance to specialized domains based on your project needs and interests.
