# Vectors

Vectors are mathematical objects representing data as ordered numerical lists in a multi-dimensional space. In AI, they are the numerical representations of data used for computation, enabling similarity measurement, clustering, and other operations.

## 1. Key Features of Vectors

### 1.1. Multi-Dimensionality

Vectors exist in _n_-dimensional space, where _n_ represents the number of features (e.g., `[0.1, -0.3, 0.5]` is a 3-dimensional vector).

### 1.2. Similarity Measurement

Vector similarity is quantified using metrics such as:

- **Cosine Similarity:** Measures the angle between vectors (range: -1 to 1; 1 indicates perfect similarity).
- **Euclidean Distance:** Calculates the straight-line distance between two points.
- **Dot Product:** Measures the projection of one vector onto another.

## 2. Vector Operations

- **Arithmetic:** Addition, subtraction, scalar multiplication.
- **Normalization:** Scaling a vector to unit length (magnitude 1).
- **Distance/Similarity Computation:** Applying the metrics described above.

## 3. Applications of Vectors

- **Clustering:** Grouping similar data points based on vector proximity (e.g., k-means clustering).
- **Classification:** Assigning data points to categories based on vector relationships and decision boundaries (e.g., support vector machines).
- **Dimensionality Reduction:** Techniques like PCA (Principal Component Analysis) and t-SNE (t-distributed Stochastic Neighbor Embedding) transform high-dimensional vectors into lower-dimensional representations for visualization or improved efficiency.
