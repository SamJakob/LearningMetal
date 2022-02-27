//
//  main.m
//  LearningMetal
//
//  Created by Sam M. on 2/26/22.
//

#import <Metal/Metal.h>

#import "Utilities/DemoUtilities.h"
#import "GPUExecutor/GPUExecutor.h"

int main(int argc, const char* argv[]) {
    
    @autoreleasepool {
        
        NSError* error = nil;
        
        // Initialize the GPUExecutor (which will select the default library with the default device if others are not specified)
        GPUExecutor* executor = [GPUExecutor new];
        assert(executor != nil);
        
        // The size (in bytes) of the array to populate. 1 << 12 = ~1 million bytes.
        int arrayLength = 1 << 12;
        
        // Compute the grid and thread size.
        MTLSize maxThreadsPerThreadGroup = [[executor device] maxThreadsPerThreadgroup]; // Determine the maxThreadsPerThreadgroup by checking this property on the device.
        MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
        MTLSize threadGroupSize = MTLSizeMake(MIN(arrayLength, maxThreadsPerThreadGroup.width), 1, 1); // number of threads per thread group.
        // ^ The number of threads per thread group (threadGroupSize) cannot exceed the maxThreadsPerThreadGroup.
        // In other words, threadGroupSize.width * threadGroupSize.height * threadGroupSize.depth cannot exceed maxThreadsPerThreadGroup.
        // But because maxThreadsPerThreadgroup is also an MTLSize (3D vector) this can also be checked per-axis which is what we do above.
        
        // We declare these variables in block scope to allow them to be passed into the prepare block (in the next step).
        __block id<MTLBuffer> bufferA, bufferB, bufferResult;
        
        // Run the add_arrays kernel from the default Metal library.
        id<MTLCommandBuffer> commandBuffer = [executor exec:@"add_arrays" error:&error gridSize:gridSize threadGroupSize:threadGroupSize prepare:^(id<MTLComputeCommandEncoder> computeEncoder) {
            
            // Obtain the device from the compute encoder.
            id<MTLDevice> device = [computeEncoder device];
            
            // Create the buffers (we intend to create an array of n=arrayLength floats, but the length of the buffer is in bytes, so
            // we need to allocate enough for [n = arrayLength] * [the size of a float = 4 bytes]).
            bufferA = [device newBufferWithLength:(arrayLength * sizeof(float)) options:MTLResourceStorageModeShared];
            bufferB = [device newBufferWithLength:(arrayLength * sizeof(float)) options:MTLResourceStorageModeShared];
            bufferResult = [device newBufferWithLength:(arrayLength * sizeof(float)) options:MTLResourceStorageModeShared];
            
            // Fill bufferA and bufferB with random data.
            [DemoUtilities generateRandomFloats:bufferA];
            [DemoUtilities generateRandomFloats:bufferB];
            
            // Set compute buffers.
            [computeEncoder setBuffer:bufferA offset:0 atIndex:0];
            [computeEncoder setBuffer:bufferB offset:0 atIndex:1];
            [computeEncoder setBuffer:bufferResult offset:0 atIndex:2];
            
        }];
        
        if (error != nil) {
            NSLog(@"An error occurred whilst trying to execute the Metal kernel:\n%@", error);
            return 1;
        }
        
        // Simply wait until the GPU has finished executing before continuing (execute synchronously).
        // You can, alternatively, use addCompletedHandler instead to set a block to execute once the GPU is finished, which is naturally
        // what one might do in a real application so as not to freeze the main thread, but this is unnecessary, in this case, as we just
        // want to print the values when its finished.
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
