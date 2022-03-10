//
//  MatrixMultiplication.metal
//  LearningMetal
//
//  Created by Sam M. on 2/27/22.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    int width;
    int height;
} MatrixDimensions;

kernel void matrix_mul(device const MatrixDimensions& ADim,
                       device const MatrixDimensions& BDim,
                       device const MatrixDimensions& CDim,
                       device const float* A,
                       device const float* B,
                       device float* C,
                       uint2 threadIdx [[ thread_position_in_threadgroup ]],
                       uint2 blockIdx [[ threadgroup_position_in_grid ]],
                       uint2 blockDim [[ threads_per_threadgroup ]]) {
    
    // Calculate the column index of B and C.
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    
    // Calculate the row index of A and C.
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    
    if ((row < ADim.height) && (col < BDim.width)) {
        float value = 0;

        for (int k = 0; k < ADim.width; k++) {
            value += A[row * ADim.width + k] * B[k * BDim.width + col];
        }

        C[row * CDim.width + col] = value;
    }
    
}
