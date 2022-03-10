//
//  Scan.metal
//  LearningMetal
//
//  Created by Sam M. on 3/10/22.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    int n;
} ScanParameters;

// constant int n [[ function_constant(0) ]];

kernel void scan_kern(device const ScanParameters& parameters,
                      device float* data,
                 uint2 threadIdx [[ thread_position_in_threadgroup ]]) {
    
    int thIdx = threadIdx.x;
    float temp = 0;
    
    for (int offset = 1; offset < parameters.n; offset *= 2) {
        if (thIdx >= offset) {
            temp = data[thIdx] + data[thIdx - offset];
        } else {
            temp = data[thIdx];
        }
        
        threadgroup_barrier(mem_flags::mem_device);
        data[thIdx] = temp;
    }
    
}
