//
//  MatrixMultiplication.h
//  LearningMetal
//
//  Created by Sam M. on 2/27/22.
//

#import "../GPUExecutor/GPUExecutor.h"

#pragma once

typedef struct {
    int width;
    int height;
    float* elements;
} Matrix;

@interface MatrixMultiplication : NSObject

+(void) execute:(__autoreleasing GPUExecutor*) executor
    matrixAHeight:(unsigned int) matrixAHeight
    matrixAWidth:(unsigned int) matrixAWidth
    matrixBWidth:(unsigned int) matrixBWidth;

@end
