//
//  Scan.m
//  LearningMetal
//
//  Created by Sam M. on 3/10/22.
//

#import <Metal/Metal.h>

#import "Scan.h"

#define GPU_BLOCK_SIZE 512

typedef struct {
    int n;
} ScanParameters;

@implementation Scan

+(void) execute:(__autoreleasing GPUExecutor*) executor {
    
    NSError* error = nil;
    
    int n = 32;
    
    MTLSize threadGroupSize = MTLSizeMake(GPU_BLOCK_SIZE, 1, 1);
    MTLSize gridSize = MTLSizeMake(GPU_BLOCK_SIZE, 1, 1);
    
    __block id<MTLBuffer> deviceBuffer;
    
    ScanParameters* parameters = malloc(sizeof(ScanParameters));
    parameters->n = n;

    id<MTLCommandBuffer> commandBuffer = [executor exec:@"scan_kern" error:&error gridSize:gridSize threadGroupSize:threadGroupSize prepare:^(id<MTLComputeCommandEncoder> computeEncoder) {
        
        id<MTLDevice> device = [computeEncoder device];
        
        // Set the constant values.
        id<MTLBuffer> paramBuffer = [device newBufferWithBytes:parameters length:sizeof(parameters) options:MTLResourceStorageModeShared];
        [computeEncoder setBuffer:paramBuffer offset:0 atIndex:0];
        
        // Create a buffer on the host...
        int bufferSize = n * sizeof(float);
        float* buffer = malloc(bufferSize);
        for (int i = 0; i < n; i++) {
            buffer[i] = 1.0f;
        }
        
        // ...and copy it to device memory.
        deviceBuffer = [device newBufferWithBytes:buffer length:bufferSize options:MTLResourceStorageModeShared];
        [computeEncoder setBuffer:deviceBuffer offset:0 atIndex:1];
        
    }];
    
    if (error != nil) {
        NSLog(@"An error occurred whilst trying to execute the Metal kernel:\n%@", error);
        return;
    }
    
    NSLog(@"Launching...");
    [commandBuffer waitUntilCompleted];
    
    float* output = (float*) [deviceBuffer contents];
    for (int i = 0; i < n; i++) {
        printf("%f ", output[i]);
    }
    
    printf("\n");
    
}

@end
