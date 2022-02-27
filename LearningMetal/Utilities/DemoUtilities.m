//
//  DemoUtilities.m
//  LearningMetal
//
//  Created by Sam M. on 2/27/22.
//

#import <Foundation/Foundation.h>
#import "DemoUtilities.h"

@implementation DemoUtilities

+(void) generateRandomFloats:(id<MTLBuffer>) buffer {
    float* data = [buffer contents];
    NSUInteger arrayLength = [buffer length] / sizeof(float);
    assert(arrayLength > 0);
    
    for (NSUInteger index = 0; index < arrayLength; index++) {
        data[index] = (float) rand() / (float) (RAND_MAX);
    }
}

@end
