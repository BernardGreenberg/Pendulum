//
//  EllipticBridge.mm
//  Pendulum
//
//  Created by Bernard Greenberg on 12/10/22.
//
/*
 This is in Objective-C, which is the only non-Swift language whose objects are understood
 by Swift, and which can call C and C++ as programs in those languages do,.
 
 */
#import "EllipticBridge.h" // outbound header file for this file

/* Have not succeeded in getting the search path into the project definition, so
 putting the whole pathname here was necessary. You have to build alglib anyway (if you're
 attempting to build this, https://www.alglib.net/ .*/
#import "/Users/bsg/Library/alglib-cpp/src/specialfunctions.h"

@implementation EllipticBridge : NSObject
/* use static class functions, so no objects needed (that's what "+" means */
+(double)K:(double) m
{
    return alglib::ellipticintegralk(m);
}

+(double)sn:(double)u m:(double)m
{
    double sn,cn,dn,phi;
    alglib::jacobianellipticfunctions(u, m, sn, cn, dn, phi);
    return sn;
}
@end
