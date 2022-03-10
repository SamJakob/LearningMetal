//
//  MatrixMultiplication.m
//  LearningMetal
//
//  Created by Sam M. on 2/27/22.
//


#import <Metal/Metal.h>

#import "MatrixMultiplication.h"
#import "../Utilities/DemoUtilities.h"

#define GPU_BLOCK_SIZE 16

typedef struct {
    int width;
    int height;
} MatrixDimensions;

void launchMatrixMult(__autoreleasing const GPUExecutor* executor,
                      const Matrix A,
                      const Matrix B,
                      const Matrix C) {
    
    NSError* error = nil;
    
    // Set the thread group and grid sizes.
    MTLSize threadGroupSize = MTLSizeMake(GPU_BLOCK_SIZE, GPU_BLOCK_SIZE, 1);
    MTLSize gridSize = MTLSizeMake(
       B.width,
       A.height,
       1
   );
    
    __block id<MTLBuffer> deviceABuffer, deviceBBuffer, deviceCBuffer;
    __block size_t sizeC;
    
    id<MTLCommandBuffer> commandBuffer = [executor exec:@"matrix_mul" error:&error gridSize:gridSize threadGroupSize:threadGroupSize prepare:^(id<MTLComputeCommandEncoder> computeEncoder) {
        
        id<MTLDevice> device = [computeEncoder device];
        
        // Copy the matrix dimensions to device memory.
        MatrixDimensions dimA, dimB, dimC;
        dimA.width = A.width; dimA.height = A.height;
        dimB.width = B.width; dimB.height = B.height;
        dimC.width = C.width; dimC.height = C.height;
        [computeEncoder setBytes:&dimA length:sizeof(MatrixDimensions) atIndex:0];
        [computeEncoder setBytes:&dimB length:sizeof(MatrixDimensions) atIndex:1];
        [computeEncoder setBytes:&dimC length:sizeof(MatrixDimensions) atIndex:2];
        
        // Copy the matrix buffers to device memory.
        size_t sizeA = A.width * A.height * sizeof(float);
        size_t sizeB = B.width * B.height * sizeof(float);
        sizeC = C.width * C.height * sizeof(float);
        deviceABuffer = [device newBufferWithBytes:A.elements length:sizeA options:MTLResourceStorageModeShared];
        deviceBBuffer = [device newBufferWithBytes:B.elements length:sizeB options:MTLResourceStorageModeShared];
        deviceCBuffer = [device newBufferWithLength:sizeC options:MTLResourceStorageModeShared];
        
        [computeEncoder setBuffer:deviceABuffer offset:0 atIndex:3];
        [computeEncoder setBuffer:deviceBBuffer offset:0 atIndex:4];
        [computeEncoder setBuffer:deviceCBuffer offset:0 atIndex:5];
        
    }];
    
    if (error != nil) {
        NSLog(@"An error occurred whilst trying to execute the Metal kernel:\n%@", error);
        return;
    }
    
    NSLog(@"Launching...");
    [commandBuffer waitUntilCompleted];
    memcpy(C.elements, [deviceCBuffer contents], sizeC);
    
}

@implementation MatrixMultiplication

+ (void) execute:(__autoreleasing GPUExecutor*) executor
    matrixAHeight:(unsigned int) matrixAHeight
    matrixAWidth:(unsigned int) matrixAWidth
    matrixBWidth:(unsigned int) matrixBWidth {
    
    NSLog(@"Performing Matrix Multiplication, with:");
    NSLog(@"-> Matrix A height:\t%u", matrixAHeight);
    NSLog(@"-> Matrix A width:\t%u", matrixAWidth);
    NSLog(@"-> Matrix B width:\t%u", matrixBWidth);
    
    
    // Define the Matrices A and B.
    Matrix A, B;
    
    // Set height and width of A and B.
    A.height = matrixAHeight;
    A.width = matrixAWidth;
    B.height = A.width;
    B.width = matrixBWidth;
    
    // Allocate memory for A and B.
    A.elements = (float*) malloc(A.width * A.height * sizeof(float));
    B.elements = (float*) malloc(B.width * B.height * sizeof(float));
    
    // Fill A and B with random values.
    for (int i = 0; i < A.height; i++) {
        for (int j = 0; j < A.width; j++) {
            A.elements[i * A.width + j] = (float) (rand() % 3);
        }
    }
    
    for (int i = 0; i < B.height; i++) {
        for (int j = 0; j < B.width; j++) {
            B.elements[i * B.width + j] = (float) (rand() % 2);
        }
    }
    
    
    // Define Matrix C.
    Matrix C;
    
    // Set height and width of C (which is calculable from A and B).
    C.height = A.height;
    C.width = B.width;
    
    // Allocate memory for C's elements.
    C.elements = (float*) malloc(C.width * C.height * sizeof(float));
    
    // Prepare and launch the GPU compute kernel.
    launchMatrixMult(executor, A, B, C);
    
    
    // Print the output.
    for(int i = 0; i < A.height; i++) {
        for(int j = 0; j < A.width; j++)
            printf("%f ", A.elements[i*A.width + j]);
        printf("\n");
    }
    
    printf("\n");
    
    for(int i = 0; i < B.height; i++){
        for(int j = 0; j < B.width; j++)
            printf("%f ", B.elements[i*B.width + j]);
        printf("\n");
    }
    
    printf("\n");
    
    for(int i = 0; i < C.height; i++){
        for(int j = 0; j < C.width; j++)
            printf("%f ", C.elements[i*C.width + j]);
        printf("\n");
    }
    
    printf("\n");
    
}

@end
