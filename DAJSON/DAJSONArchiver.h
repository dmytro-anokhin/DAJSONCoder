//
//  DAJSONArchiver.h
//  DAJSON
//
//  Created by Dmytro Anokhin on 24/09/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//

#import "DAJSONCoder.h"


NS_ASSUME_NONNULL_BEGIN


@interface DAJSONArchiver : DAJSONCoder

+ (nullable NSData *)archivedDataWithRootObject:(id<NSCoding>)rootObject;

+ (nullable NSData *)archivedDataWithRootObject:(id<NSCoding>)rootObject objectGraphCycleResolutionStrategy:(DAJSONCoderObjectGraphCycleResolutionStrategy)objectGraphCycleResolutionStrategy;

@end

NS_ASSUME_NONNULL_END
