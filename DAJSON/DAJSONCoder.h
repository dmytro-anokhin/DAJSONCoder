//
//  DAJSONCoder.h
//  DAJSON
//
//  Created by Dmytro Anokhin on 24/09/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//

@import Foundation;


typedef NS_ENUM(NSUInteger, DAJSONCoderObjectGraphCycleResolutionStrategy) {

    /// Archiver won't archive object graph cycles.
    DAJSONCoderObjectGraphCycleResolutionStrategyIgnore = 0,
    
    // TODO: Implement this strategy
    
    /// Archiver stores references to dublicate objects using format { "$ref": "uri" }.
    DAJSONCoderObjectGraphCycleResolutionStrategyReference
};


NS_ASSUME_NONNULL_BEGIN

/**
    The DAJSONCoder provides encoding/decoding objects that implement NSCoding protocol object to JSON format.
    
    There is no standard for encoding object graph cycles in JSON. Resolving this problem is up to user of this class. JSON archiver will ignore cycles.
*/
@interface DAJSONCoder : NSCoder

/// Defines strategy for resolution of object graph cycles. Archiver and Unarchiver strategies should match.
@property (nonatomic) DAJSONCoderObjectGraphCycleResolutionStrategy objectGraphCycleResolutionStrategy;

/// Key for object JSON representation. Objects are encoded in format of { "key" : { "property" : "value", ... } }. By default, key is string representation of object's class for coder.
- (NSString *)keyForObject:(id)object;

/// Create object for key using -initWithCoder: initializer. By default, key is string representation of object's class.
- (nullable id)makeObjectForKey:(NSString *)key withCoder:(NSCoder *)coder;

@end


NS_ASSUME_NONNULL_END
