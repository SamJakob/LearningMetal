//
//  Scan.h
//  LearningMetal
//
//  Created by Sam M. on 3/10/22.
//

#import "../GPUExecutor/GPUExecutor.h"

#pragma once

@interface Scan : NSObject

+(void) execute:(__autoreleasing GPUExecutor*) executor;

@end
