#!/usr/bin/env python3
"""
Classical MDS Implementation from Scratch
This script reads a distance matrix and computes 3D coordinates using a custom
implementation of classical MDS (without using scikit-learn's MDS)
"""

import numpy as np
import argparse
import time

def read_distance_matrix(filename):
    """Read the distance matrix from the input file"""
    try:
        # Load the distance matrix
        distance_matrix = np.loadtxt(filename)
        print(f"Successfully loaded distance matrix with shape: {distance_matrix.shape}")
        return distance_matrix
    except Exception as e:
        print(f"Error reading distance matrix file: {e}")
        exit(1)

def classical_mds(distance_matrix, n_components=3):
    """
    Implement Classical MDS algorithm from scratch
    
    Parameters:
    -----------
    distance_matrix : numpy.ndarray
        The input distance matrix
    n_components : int
        Number of dimensions in the output coordinates
        
    Returns:
    --------
    coordinates : numpy.ndarray
        The coordinates in n_components-dimensional space
    """
    n = distance_matrix.shape[0]
    print(f"Running Classical MDS on {n}x{n} distance matrix...")
    
    # Square the distances (D²)
    squared_distances = np.square(distance_matrix)
    
    # Double centering: B = -1/2 J D² J where J = I - 1/n 11ᵀ
    # This is equivalent to the following operations:
    
    # 1. Calculate row and column means
    row_means = np.mean(squared_distances, axis=1, keepdims=True)
    col_means = np.mean(squared_distances, axis=0, keepdims=True)
    
    # 2. Calculate the grand mean
    grand_mean = np.mean(squared_distances)
    
    # 3. Apply double centering formula to get similarity matrix
    B = -0.5 * (squared_distances - row_means - col_means + grand_mean)
    
    # Get eigenvectors and eigenvalues
    print("Computing eigendecomposition...")
    eigenvalues, eigenvectors = np.linalg.eigh(B)
    
    # Sort eigenvalues in descending order and get corresponding eigenvectors
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]
    
    # Select top n_components eigenvalues and eigenvectors
    eigenvalues = eigenvalues[:n_components]
    eigenvectors = eigenvectors[:, :n_components]
    
    # Check for negative eigenvalues (indicates non-Euclidean distance matrix)
    if np.any(eigenvalues < 0):
        print("Warning: Negative eigenvalues detected. The distance matrix may not be Euclidean.")
        # Ensure positive eigenvalues for coordinate calculation
        eigenvalues = np.maximum(eigenvalues, 0)
    
    # Calculate coordinates from eigenvectors and eigenvalues
    coordinates = eigenvectors * np.sqrt(eigenvalues)
    
    print(f"MDS completed. Generated coordinates with shape: {coordinates.shape}")
    return coordinates

def save_coordinates(coordinates, output_file):
    """Save the coordinates to the output file"""
    try:
        np.savetxt(output_file, coordinates, fmt='%.6f')
        print(f"Successfully saved coordinates to: {output_file}")
    except Exception as e:
        print(f"Error saving coordinates to file: {e}")
        exit(1)

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Generate 3D coordinates from distance matrix using Classical MDS')
    parser.add_argument('-d', '--distance', required=True, help='Input distance matrix file')
    parser.add_argument('-o', '--output', required=True, help='Output coordinates file')
    parser.add_argument('-n', '--components', type=int, default=3, help='Number of dimensions (default: 3)')
    args = parser.parse_args()
    
    # Record start time
    start_time = time.time()
    
    # Process the data
    distance_matrix = read_distance_matrix(args.distance)
    coordinates = classical_mds(distance_matrix, args.components)
    save_coordinates(coordinates, args.output)
    
    # Calculate and print execution time
    execution_time = time.time() - start_time
    print(f"Classical MDS completed in {execution_time:.2f} seconds")

if __name__ == "__main__":
    main()