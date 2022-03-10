//
//  ArrayAddition.h
//  LearningMetal
//
//  Created by Sam M. on 2/27/22.
//

#import "../GPUExecutor/GPUExecutor.h"

#pragma once

@interface ArrayAddition : NSObject

+(void) execute:(__autoreleasing GPUExecutor*) executor
    arrayLength:(unsigned int) arrayLength;

@end
