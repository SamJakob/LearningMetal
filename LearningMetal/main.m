//
//  main.m
//  LearningMetal
//
//  Created by Sam M. on 2/26/22.
//

#import <Cocoa/Cocoa.h>
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
    
    NSError* error = nil;
    
    // Compute the grid and thread size.
    int arrayLength = 1 << 12;
    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
    MTLSize threadGroupSize = MTLSizeMake(arrayLength, 1, 1); // number of threads per thread group.
    
    __block id<MTLBuffer> bufferA, bufferB, bufferResult;
    
    // Run the add_arrays kernel from the default Metal library.
    GPUExecutor* executor = [[GPUExecutor alloc] init];
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
    return 0;
    
}


// Here's an alternative example that does not use GPUExecutor.
// Based on the Apple Metal tutorial: https://developer.apple.com/documentation/metal/basic_tasks_and_concepts/performing_calculations_on_a_gpu?preferredLanguage=occ
int mainAdderExample(int argc, const char * argv[]) {
    
    @autoreleasepool {
        ///
        /// Stage 1
        ///
        
        // Setup code that might create autoreleased objects goes here.
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        
        NSError* error = nil;
        
        // Attempt to load the default library.
        id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];
        if (defaultLibrary == nil) {
            NSLog(@"Failed to locate default library.");
            return 1;
        }
        
        // Get adder function.
        id<MTLFunction> gpuAddFunction = [defaultLibrary newFunctionWithName:@"add_arrays"];
        if (gpuAddFunction == nil) {
            NSLog(@"Failed to locate adder function.");
            return 1;
        }
        
        ///
        /// Stage 2
        ///
        
        // Now, prepare a Metal pipeline.
        id <MTLComputePipelineState> pipeline = [device newComputePipelineStateWithFunction:gpuAddFunction error:&error];
        
        // Create a command queue.
        id<MTLCommandQueue> commandQueue = [device newCommandQueue];
        id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
        id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
        
        // Create data buffers (alloc) and load data.
        int arrayLength = 1 << 28;
        id<MTLBuffer> bufferA = [device newBufferWithLength:(arrayLength * sizeof(float)) options:MTLResourceStorageModeShared];
        id<MTLBuffer> bufferB = [device newBufferWithLength:(arrayLength * sizeof(float)) options:MTLResourceStorageModeShared];
        id<MTLBuffer> bufferResult = [device newBufferWithLength:(arrayLength * sizeof(float)) options:MTLResourceStorageModeShared];
        
        generateRandomData(bufferA);
        generateRandomData(bufferB);
        
        // Set compute pipeline state and buffers.
        [computeEncoder setComputePipelineState:pipeline];
        [computeEncoder setBuffer:bufferA offset:0 atIndex:0];
        [computeEncoder setBuffer:bufferB offset:0 atIndex:1];
        [computeEncoder setBuffer:bufferResult offset:0 atIndex:2];
        
        ///
        /// Stage 3
        ///
        
        // Set thread count and organization.
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        
        // Specify the size of the thread group.
        NSUInteger initialThreadGroupSize = [pipeline maxTotalThreadsPerThreadgroup];
        if (initialThreadGroupSize > arrayLength) initialThreadGroupSize = arrayLength;
        MTLSize threadGroupSize = MTLSizeMake(initialThreadGroupSize, 1, 1);
        
        // Encode the compute function to execute threads.
        [computeEncoder dispatchThreads:gridSize threadsPerThreadgroup:threadGroupSize];
        
        // End the compute pass and commit the buffer.
        [computeEncoder endEncoding];
        [commandBuffer commit];
        
        NSLog(@"GPU calculation start");
        
        // Wait for completion (alternatively, one can add a completion handler).
        [commandBuffer waitUntilCompleted];
        
        NSLog(@"GPU calculation done");
        
        ///
        /// Stage 4
        ///
        
        // Read the results from the GPU buffer and verify them.
        NSLog(@"CPU calculation start");
        
        float* a = [bufferA contents];
        float* b = [bufferB contents];
        float* result = [bufferResult contents];
        
        for (unsigned long index = 0; index < arrayLength; index++) {
            if (result[index] != a[index] + b[index]) {
                printf("COMPUTE ERROR: index=%lu, result=%g vs %g=a+b\n", index, result[index], a[index] + b[index]);
                assert(result[index] == a[index] + b[index]);
            }
        }
        
        NSLog(@"CPU calculation done");
        
        printf("%d\n", arrayLength);
        
        printf("Results computed as expected.\n");
    }
    
    return 0;
    
}
