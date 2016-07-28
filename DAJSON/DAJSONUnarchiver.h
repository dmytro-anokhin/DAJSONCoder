//
//  DAJSONUnarchiver.h
//  DAJSON
//
//  Created by Dmytro Anokhin on 24/09/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//

@import Foundation;

#import "DAJSONCoder.h"


NS_ASSUME_NONNULL_BEGIN


@interface DAJSONUnarchiver : DAJSONCoder

+ (nullable id)unarchiveObjectWithData:(NSData *)data;

- (instancetype)initForReadingWithJSONObject:(id)jsonObject;

@end


NS_ASSUME_NONNULL_END
