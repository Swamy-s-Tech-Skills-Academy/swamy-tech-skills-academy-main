# Autoencoders

An **autoencoder** is an unsupervised neural network model that learns to compress (encode) input data into a lower-dimensional latent representation and then reconstruct (decode) the original data from this representation. The model consists of two main parts:

## 1. Architecture

- **Encoder:** A feedforward network (often fully connected or convolutional) that maps input \(x\) to a latent vector \(z\).  
  \[ z = f_{encoder}(x) \]

- **Decoder:** A symmetric network that reconstructs \(\hat{x}\) from the latent vector \(z\).  
  \[ \hat{x} = f_{decoder}(z) \]

- **Latent Space:** The compressed representation captures the most salient features necessary for reconstruction.

## 2. Training Objective

Autoencoders are trained to minimize the reconstruction loss between the input \(x\) and its reconstruction \(\hat{x}\), commonly using mean squared error (MSE) or binary cross-entropy:

\[ \mathcal{L}(x, \hat{x}) = \|x - \hat{x}\|^2 \]

This encourages the network to learn efficient encodings.

## 3. Variants

- **Undercomplete Autoencoder:** Bottleneck dimension smaller than input, forcing compression.  
- **Denoising Autoencoder:** Adds noise to input and learns to reconstruct the clean data, improving robustness.  
- **Sparse Autoencoder:** Applies a sparsity constraint on activations to learn more interpretable features.  
- **Variational Autoencoder (VAE):** A probabilistic model that enforces a prior (e.g., Gaussian) on the latent space, enabling generative sampling.

## 4. Applications

- **Dimensionality Reduction:** Alternative to PCA for non-linear embeddings.  
- **Anomaly Detection:** Large reconstruction error flags anomalies.  
- **Data Denoising:** Removes noise from images or signals.  
- **Generative Modeling (VAE):** Sample new data from learned latent distribution.
