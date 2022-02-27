//
//  DemoUtilities.h
//  LearningMetal
//
//  Created by Sam M. on 2/27/22.
//

#import <Metal/Metal.h>

#pragma once

@interface DemoUtilities : NSObject

/*!
 * Fills the specified buffer with randomly generated floats.
 * This calculates how many floats to generate and insert based on the 'length' attribute of the MTLBuffer. If this value is not divisible
 * by the size of a float (4), it will insert as many floats as possible until that point.
 */
+(void) generateRandomFloats:(id<MTLBuffer>) buffer;

@end
