//
//  main.m
//  LearningMetal
//
//  Created by Sam M. on 2/26/22.
//

#import <Metal/Metal.h>

#import "GPUExecutor.h"

void generateRandomData(id<MTLBuffer> buffer) {
    float* data = [buffer contents];
    unsigned long arrayLength = [buffer length] / sizeof(float);
    
    for (unsigned long index = 0; index < arrayLength; index++) {
        data[index] = (float) rand() / (float) (RAND_MAX);
    }
}

int main(int argc, const char* argv[]) {
    
    
    @autoreleasepool {
        NSError* error = nil;
        
        // Compute the grid and thread size.
        int arrayLength = 1 << 12;
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        MTLSize threadGroupSize = MTLSizeMake(arrayLength, 1, 1); // number of threads per thread group.
        
        __block id<MTLBuffer> bufferA, bufferB, bufferResult;
        
        // Run the add_arrays kernel from the default Metal library.
        GPUExecutor* executor = [GPUExecutor new];
        id<MTLCommandBuffer> commandBuffer = [executor exec:@"add_arrays" error:&error gridSize:gridSize threadGroupSize:threadGroupSize prepare:^(id<MTLComputeCommandEncoder> computeEncoder) {
            
            // Obtain the device from the compute encoder.
            id<MTLDevice> device = [computeEncoder device];
            
            // Create the buffers.
            bufferA = [device newBufferWithLength:(arrayLength * sizeof(float)) options:MTLResourceStorageModeShared];
            bufferB = [device newBufferWithLength:(arrayLength * sizeof(float)) options:MTLResourceStorageModeShared];
            bufferResult = [device newBufferWithLength:(arrayLength * sizeof(float)) options:MTLResourceStorageModeShared];
            
            // Fill bufferA and bufferB with random data.
            generateRandomData(bufferA);
            generateRandomData(bufferB);
            
            // Set compute buffers.
            [computeEncoder setBuffer:bufferA offset:0 atIndex:0];
            [computeEncoder setBuffer:bufferB offset:0 atIndex:1];
            [computeEncoder setBuffer:bufferResult offset:0 atIndex:2];
            
        }];
        
        [commandBuffer waitUntilCompleted];
        
        ///
        /// Now check the output.
        ///
        
        // Read the results from the GPU buffer and verify them.
        float* a = [bufferA contents];
        float* b = [bufferB contents];
        float* result = [bufferResult contents];
        
        for (unsigned long index = 0; index < arrayLength; index++) {
            if (result[index] != a[index] + b[index]) {
                printf("COMPUTE ERROR: index=%lu, result=%g vs %g=a+b\n", index, result[index], a[index] + b[index]);
                assert(result[index] == a[index] + b[index]);
            }
        }
        NSLog(@"Results computed as expected.");
    }
    
    return 0;
    
}
