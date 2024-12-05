//
//  EllipticBridge.h
//  Pendulum
//
//  Created by Bernard Greenberg on 12/10/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EllipticBridge : NSObject
+(double)K:(double) m;
+(double)sn: (double)u m:(double)m;


@end

NS_ASSUME_NONNULL_END
