#!/usr/bin/env python3
"""
MDS implementation using scikit-learn for 3D chromosome structure reconstruction
This script reads a distance matrix and computes 3D coordinates using MDS
"""

import numpy as np
import argparse
from sklearn.manifold import MDS
import os

def read_distance_matrix(filename):
    """Read the distance matrix from the input file"""
    try:
        # Load the distance matrix with tab separator
        distance_matrix = np.loadtxt(filename, delimiter='\t')
        print(f"Successfully loaded distance matrix with shape: {distance_matrix.shape}")
        
        # Ensure the matrix is symmetric
        if not np.allclose(distance_matrix, distance_matrix.T):
            print("Warning: Matrix is not symmetric. Making it symmetric by averaging with its transpose.")
            distance_matrix = (distance_matrix + distance_matrix.T) / 2
            
        return distance_matrix
    except Exception as e:
        print(f"Error reading distance matrix file: {e}")
        exit(1)

def perform_mds(distance_matrix, n_components=3):
    """Perform MDS on the distance matrix to get coordinates"""
    print(f"Performing MDS with n_components={n_components}...")
    
    # Create MDS model
    mds = MDS(n_components=n_components, 
              dissimilarity='precomputed',
              random_state=42,
              normalized_stress='auto')
    
    # Fit the model to get the coordinates
    coordinates = mds.fit_transform(distance_matrix)
    
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
    parser = argparse.ArgumentParser(description='Generate 3D coordinates from distance matrix using MDS')
    parser.add_argument('-d', '--distance', required=True, help='Input distance matrix file')
    parser.add_argument('-o', '--output', required=True, help='Output coordinates file')
    parser.add_argument('-n', '--components', type=int, default=3, help='Number of dimensions (default: 3)')
    args = parser.parse_args()
    
    # Process the data
    distance_matrix = read_distance_matrix(args.distance)
    coordinates = perform_mds(distance_matrix, args.components)
    save_coordinates(coordinates, args.output)
    
    print("MDS processing completed successfully.")

if __name__ == "__main__":
    main()