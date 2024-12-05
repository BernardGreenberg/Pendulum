Accurate Pendulum-Simulator in Cocoa Swift (for Mac).  Requires  https://www.alglib.net/ to be built and packed into Universal dylib containing Intel and ARM64 builds.
The current source code points to a place in my file system where its header files live (in EllipticBridge.mm). This obviously could be better, but I wanted to check this stuff in.

App offers simulation of pendulum with simple formula used in elementary physics classes, accurate formula involving Jacobi Elliptic Functions, "correct period but simple harmonic
motion" simulation, which is surprisingly accurate for a good range of angles, as well as simulation by incremental acceleration calculation at small intervals, essentially
numerical integration, which comes out with the "accurate" answer as well.

Built app works on either variety of Mac.
