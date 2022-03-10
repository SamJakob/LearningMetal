//
//  main.m
//  LearningMetal
//
//  Created by Sam M. on 2/26/22.
//

#import "Utilities/DemoUtilities.h"
#import "GPUExecutor/GPUExecutor.h"

#import "ObjC/ArrayAddition.h"
#import "ObjC/MatrixMultiplication.h"
#import "ObjC/Scan.h"

int main(int argc, const char* argv[]) {
    
    @autoreleasepool {
        
        // Initialize the GPUExecutor (which will select the default library with the default device if others are not specified)
        GPUExecutor* executor = [GPUExecutor new];
        assert(executor != nil);
        
        /*
         * ArrayAddition
         * -------------
         * Sums the values in two equal-length arrays, A and B, and places the
         * result in a third array, C.
         */
//        [ArrayAddition execute:executor
//            // The size of the array to populate. [1 << 20 = ~1 million].
//            arrayLength: (1 << 20)
//        ];
        
        /*
         * MatrixMultiplication
         * --------------------
         * Multiplies two matrices, A and B, and places the result in a third
         * matrix, C.
         */
//        [MatrixMultiplication execute:executor
//            matrixAHeight:16 matrixAWidth:16
//            matrixBWidth:16
//        ];
        
        /*
         * Scan
         * ----
         * A parallel implementation of the Scan algorithm.
         */
        [Scan execute:executor];
        
    }
    
    return 0;
    
}
