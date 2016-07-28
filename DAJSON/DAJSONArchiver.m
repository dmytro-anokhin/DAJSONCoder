//
//  DAJSONArchiver.m
//  DAJSON
//
//  Created by Dmytro Anokhin on 24/09/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//

#import "DAJSONArchiver.h"
#import "DAJSONCoder_Private.h"


@interface DAJSONArchiver ()

// Result json object
@property (nonatomic, readonly, nullable) id jsonObject;

/// Stack of jsonObjects
@property (nonatomic) NSMutableArray *stack;

/// Hash with all archived objects references. Used to resolve object graph cycles.
@property (nonatomic) NSMapTable *archivedObjects;

/// URI components for current key path
@property (nonatomic) NSMutableArray<NSString *> *uriComponents;

/// URI for current key path
@property (nonatomic, readonly, copy) NSString *uri;

@end


@implementation DAJSONArchiver

+ (nullable NSData *)archivedDataWithRootObject:(id<NSCoding>)rootObject
{
    return [self archivedDataWithRootObject:rootObject objectGraphCycleResolutionStrategy:DAJSONCoderObjectGraphCycleResolutionStrategyIgnore];
}

+ (nullable NSData *)archivedDataWithRootObject:(id<NSCoding>)rootObject objectGraphCycleResolutionStrategy:(DAJSONCoderObjectGraphCycleResolutionStrategy)objectGraphCycleResolutionStrategy
{
    if (nil == rootObject)
        return nil;

    DAJSONArchiver *archiver = [self new];
    archiver.objectGraphCycleResolutionStrategy = objectGraphCycleResolutionStrategy;
    
    [archiver encodeRootObject:rootObject];

    NSError *error = nil;
    NSData *data = nil;
    
    @try {
        data = [NSJSONSerialization dataWithJSONObject:archiver.jsonObject options:0 error:&error];
    }
    @catch (NSException *exception) {
        DAJSONCoderLog(@"%@: %@", NSStringFromClass(self), exception);
    }
    
    if (nil == data) {
        DAJSONCoderLog(@"%@: %@", NSStringFromClass(self), error);
    }
    
    return data;
}

- (instancetype)init
{
    self = [super init];
    if (nil == self)
        return nil;
    
    _stack = [NSMutableArray new];
    _archivedObjects = [[NSMapTable alloc] initWithKeyOptions:NSMapTableObjectPointerPersonality
		valueOptions:NSMapTableStrongMemory capacity:0];
    _uriComponents = [NSMutableArray new];
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, jsonObject=%@>", NSStringFromClass([self class]), self, self.jsonObject];
}

#pragma mark - NSCoder

- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr
{
    DAJSONCoderLog(@"%@", NSStringFromSelector(_cmd));
    // void * pointer is dangerous. Handle all the cases without falling to this method
}

- (void)encodeDataObject:(NSData *)data
{
    DAJSONCoderLog(@"%@", data);
}

#pragma mark - NSExtendedCoder

- (void)encodeObject:(nullable id)object
{
    DAJSONCoderLog(@"%@", NSStringFromSelector(_cmd));
    id encoded = [self encodedObject:object];
    if (encoded) {
        [self.stack addObject:encoded];
    }
}

- (void)encodeRootObject:(id)rootObject
{
    DAJSONCoderLog(@"%@", NSStringFromSelector(_cmd));
    [super encodeRootObject:rootObject];
}

- (void)encodeObject:(nullable id)objv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    
    [self willEncodeObject:objv forKey:key];
    
    id encoded = [self encodedObject:objv];
    self.jsonObject[key] = encoded;
    
    [self didEncodeObject:encoded];
}

- (void)encodeConditionalObject:(nullable id)objv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    [self doesNotRecognizeSelector:_cmd];
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);

    if (!boolv) // Do not encode NO
        return;

    self.jsonObject[key] = @(boolv);
}

- (void)encodeInt:(int)intv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);

    if (0 == intv) // Do not encode 0
        return;
    
    self.jsonObject[key] = @(intv);
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);

    if (0 == intv) // Do not encode 0
        return;

    self.jsonObject[key] = @(intv);
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);

    if (0 == intv) // Do not encode 0
        return;

    self.jsonObject[key] = @(intv);
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);

    if (0.0 == realv) // Do not encode 0.0
        return;

    self.jsonObject[key] = @(realv);
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    
    if (0.0 == realv) // Do not encode 0.0
        return;

    self.jsonObject[key] = @(realv);
}

- (void)encodeBytes:(nullable const uint8_t *)bytesp length:(NSUInteger)lenv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    
    if (NULL == bytesp)
        return;
    
    NSData *data = [[NSData alloc] initWithBytes:bytesp length:lenv];
    self.jsonObject[key] = [data base64EncodedStringWithOptions:0];
}

- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    
    if (0 == intv) // Do not encode 0
        return;
    
    self.jsonObject[key] = @(intv);
}

#pragma mark - Private

- (nullable id)encodedObject:(nullable id)object
{
    id replacementObject = [object replacementObjectForCoder:self];
    
    if (nil == replacementObject) // Do not encode nil objects
        return nil;
 
    id identity = replacementObject;
    id uriToArchivedObject = [self.archivedObjects objectForKey:identity];

    if (nil != uriToArchivedObject) { // Object graph contains cycle.
        switch (self.objectGraphCycleResolutionStrategy) {
            case DAJSONCoderObjectGraphCycleResolutionStrategyIgnore: {
                return nil;
            } break;
            case DAJSONCoderObjectGraphCycleResolutionStrategyReference: {
                return @{ DAJSONCoderURIReferenceKey : uriToArchivedObject };
            } break;
        }
    }
    
    // Encode array as []
    if ([replacementObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[replacementObject count]];
    
        for (id element in replacementObject) {
            id encoded = [self encodedObject:element];

            if (encoded) {
                [array addObject:encoded];
            }
        }
        
        return array;
    }
    
    // Encode dictionary as {}
    if ([replacementObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[replacementObject count]];

        [replacementObject enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            dictionary[key] = [self encodedObject:obj];
        }];

        return dictionary;
    }

    // Strings and numbers stored as is
    if ([replacementObject isKindOfClass:[NSString class]]
        || [replacementObject isKindOfClass:[NSNumber class]])
    {
        return replacementObject;
    }

    // Custom class is encoded in format of { "key" : { "property" : "value", ... } }

    NSString *key = [self keyForObject:replacementObject];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSDictionary *result = @{ key : dictionary };
    
    switch (self.objectGraphCycleResolutionStrategy) {
        case DAJSONCoderObjectGraphCycleResolutionStrategyIgnore: {
            [self.archivedObjects setObject:[NSNull null] forKey:identity];
        } break;
        case DAJSONCoderObjectGraphCycleResolutionStrategyReference: {
            [self.archivedObjects setObject:self.uri forKey:identity];
        } break;
    }
    
    [self.stack addObject:dictionary];
    [replacementObject encodeWithCoder:self];
    [self.stack removeLastObject];

    return result;
}

- (void)willEncodeObject:(id)object forKey:(NSString *)key
{
    [self.uriComponents addObject:key];
}

- (void)didEncodeObject:(id)object
{
    [self.uriComponents removeLastObject];
}

#pragma mark - Dynamic properties

- (id)jsonObject
{
    return self.stack.lastObject;
}

- (NSString *)uri
{
    return [self.uriComponents componentsJoinedByString:DAJSONCoderURISeparator];
}

@end
