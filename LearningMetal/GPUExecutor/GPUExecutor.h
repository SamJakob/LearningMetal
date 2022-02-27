//
//  GPUExecutor.h
//  LearningMetal
//
//  Created by Sam M. on 2/27/22.
//

#import <Metal/Metal.h>

#pragma once

#define EXECUTOR_ERROR_DOMAIN @"com.samjakob.gpuexecutor"

@interface GPUExecutor : NSObject

@property (class) id<MTLDevice> defaultMetalDevice;
@property (class) id<MTLLibrary> defaultMetalLibrary;

-(instancetype) init;
-(instancetype) init:(id<MTLLibrary>) library;

-(id<MTLLibrary>) library;
-(id<MTLDevice>) device;

-(id<MTLCommandBuffer>) exec:(NSString*) kernelName error:(__autoreleasing NSError**) error gridSize:(MTLSize) gridSize threadGroupSize:(MTLSize) threadGroupSize;
-(id<MTLCommandBuffer>) exec:(NSString*) kernelName error:(__autoreleasing NSError**) error gridSize:(MTLSize) gridSize threadGroupSize:(MTLSize) threadGroupSize prepare:(void(^)(id<MTLComputeCommandEncoder>)) prepare;

@end
