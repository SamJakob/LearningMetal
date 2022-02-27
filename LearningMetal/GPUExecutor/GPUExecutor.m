//
//  GPUExecutor.m
//  LearningMetal
//
//  Created by Sam M. on 2/27/22.
//

#import "GPUExecutor.h"

@implementation GPUExecutor {
    id<MTLLibrary> _library;
}

// Public accessors/setters for the default metal device.
static id<MTLDevice> _defaultMetalDevice = nil;
+(id<MTLDevice>) defaultMetalDevice { return _defaultMetalDevice; }
+(void) setDefaultMetalDevice:(id<MTLDevice>)defaultMetalDevice { _defaultMetalDevice = defaultMetalDevice; }

// Public accessors/setters for the default metal library.
static id<MTLLibrary> _defaultMetalLibrary = nil;
+(id<MTLLibrary>) defaultMetalLibrary { return _defaultMetalLibrary; }
+(void) setDefaultMetalLibrary:(id<MTLLibrary>)defaultMetalLibrary { _defaultMetalLibrary = defaultMetalLibrary; };

-(instancetype) init {
    return [self init:nil];
}

-(instancetype) init:(id<MTLLibrary>)library {
    if (self = [super init]) {
        // Initialize self.
        
        // If the library is set as a parameter, ensure that it is now set
        // (and for future invocations).
        if (library == nil) {
            // If the default metal library is set, use it.
            if (_defaultMetalLibrary != nil) library = _defaultMetalLibrary;
            // Otherwise...
            else {
                // Create the default metal device if it is not already set.
                // (If the library was set, it guarantees that this would already have been set.)
                if (_defaultMetalDevice == nil) {
                    _defaultMetalDevice = MTLCreateSystemDefaultDevice();
                }
                
                // Now that we've attempted to create one with system defaults, ensure that it
                // does exist.
                if (_defaultMetalDevice == nil) {
                    NSLog(@"Failed to locate default Metal device, and the library was not set.");
                    return nil;
                }
                
                // Now, use the default metal device to create a new default library.
                _defaultMetalLibrary = library = [_defaultMetalDevice newDefaultLibrary];
            }
        }
        
        // Ensure that the library has a valid device.
        if ([library device] == nil) {
            // 'from the specified library' => we already checked if we could load the system device, which is what
            // would be used if the user had *not* specified a library. Hence, if the device could not be located at
            // this point, it had to be a bad device from the user's own specified library.
            NSLog(@"Failed to locate the Metal device from the specified library.");
            return nil;
        }
        
        // Finally, set the GPUExecutor's instance library to either the selected or newly created
        // library.
        _library = library;
    }
    
    return self;
}

-(id<MTLLibrary>) library {
    return _library;
}

-(id<MTLDevice>) device {
    return [_library device];
}

-(id<MTLCommandBuffer>) exec:(NSString *)kernelName error:(__autoreleasing NSError**) error gridSize:(MTLSize) gridSize threadGroupSize:(MTLSize) threadGroupSize {
    return [self exec:kernelName error:error gridSize:gridSize threadGroupSize:threadGroupSize prepare:nil];
}

-(id<MTLCommandBuffer>) exec:(NSString *)kernelName error:(__autoreleasing NSError**) error gridSize:(MTLSize) gridSize threadGroupSize:(MTLSize) threadGroupSize prepare:(void(^)(id<MTLComputeCommandEncoder>)) prepare {
    
    // Now that the library should have been either specified or set, ensure that it is, in
    // fact, set.
    if (_library == nil) {
        *error = [[NSError alloc] initWithDomain:EXECUTOR_ERROR_DOMAIN code:1000 userInfo:@{
            @"message": @"An invalid library was specified and the default library could not be located."
        }];
        return nil;
    }
    
    // Locate the specified kernel.
    id<MTLFunction> kernel = [_library newFunctionWithName:kernelName];
    if (kernel == nil) {
        *error = [[NSError alloc] initWithDomain:EXECUTOR_ERROR_DOMAIN code:2000 userInfo:@{
            @"message": [NSString stringWithFormat:@"The specified kernel function, `%@`, was not found in the default Metal library.", kernelName]
        }];
        return nil;
    }
    
    // Ensure that the error is cleared.
    *error = nil;
    
    // Prepare a Metal pipeline to send the commands to the GPU.
    id<MTLDevice> device = [_library device];
    id<MTLComputePipelineState> pipelineState = [device newComputePipelineStateWithFunction:kernel error:error];
    
    id<MTLCommandQueue> commandQueue = [device newCommandQueue];
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    
    // Set the compute encoder pipeline.
    [computeEncoder setComputePipelineState:pipelineState];
    
    // Pass control to an input block which can prepare buffers for the compute encoder.
    if (prepare != nil) prepare(computeEncoder);
    
    // Set thread count and organization.
    [computeEncoder dispatchThreads:gridSize threadsPerThreadgroup:threadGroupSize];
    
    // End the compute pass and commit the buffer.
    [computeEncoder endEncoding];
    [commandBuffer commit];
    
    return commandBuffer;
    
}

@end
