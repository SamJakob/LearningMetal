# LearningMetal
Practicing GPU compute with Apple Metal.

## Directory Structure

- In the Xcode project, there is a 'App' group which simply contains the additional files necessary to create a runnable Cocoa app
(Info.plist and the entitlements file). Info.plist also specifies that the application is an agent to hide the Dock icon as it is
launching.

- Naturally, see/modify [`main.m`](./LearningMetal/main.m) to specify which code should be executed.

### [ObjC/](./LearningMetal/ObjC)
The `.h`/`.m` Objective-C files containing the CPU code necessary to launch and execute the GPU kernel.

### [Metal/](./LearningMetal/Metal)
The `.metal` shader files containing code to be executed on the GPU.

### [GPUExecutor/](./LearningMetal/GPUExecutor)
A 'library' for making interacting with Metal APIs slightly less verbose.
(Essentially just removes the hassle of selecting the default device and library and performing various checks.)

### [Utilities/](./LearningMetal/Utilities)
Helpful utilities for various tasks not particularly relevant to GPU compute.
(e.g., `[DemoUtilities generateRandomFloats]` for filling a buffer with float values).
