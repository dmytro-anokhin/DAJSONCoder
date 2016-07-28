//
//  DAJSONUnarchiver.m
//  DAJSON
//
//  Created by Dmytro Anokhin on 24/09/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//

#import "DAJSONUnarchiver.h"
#import "DAJSONCoder_Private.h"


@interface DAJSONUnarchiver ()

@property (nonatomic) id jsonObject;

@end


@implementation DAJSONUnarchiver

+ (nullable id)unarchiveObjectWithData:(NSData *)data
{
    if (nil == data)
        return nil;

    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

    if (nil == jsonObject) {
        DAJSONCoderLog(@"%@: %@", NSStringFromClass(self), jsonError);
        return nil;
    }

    DAJSONUnarchiver *unarchiver = [[self alloc] initForReadingWithJSONObject:jsonObject];
    NSError *coderError = nil;
    id object = [unarchiver decodeTopLevelObjectAndReturnError:&coderError];

    if (nil == object) {
        DAJSONCoderLog(@"%@: %@", NSStringFromClass(self), coderError);
        return nil;
    }
    
    return object;
}

- (instancetype)initForReadingWithJSONObject:(id)jsonObject
{
    self = [super init];
    if (nil == self)
        return nil;
    
    _jsonObject = jsonObject;
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, jsonObject=%@>", NSStringFromClass([self class]), self, _jsonObject];
}

#pragma mark - NSCoder

- (void)decodeValueOfObjCType:(const char *)type at:(void *)data
{
    // void * pointer is dangerous. Handle all the cases without falling to this method
    // data = (__bridge void *)_jsonObject;
    // *((id __strong *) data) = array;
}

- (nullable NSData *)decodeDataObject
{
    DAJSONCoderLog(@"%@", NSStringFromSelector(_cmd));
    return nil;
}

#pragma mark - NSExtendedCoder

- (nullable id)decodeObject
{
    return [self decodedObject:_jsonObject];
}

- (nullable id)decodeTopLevelObjectAndReturnError:(NSError **)error
{
    DAJSONCoderLog(@"%@", NSStringFromSelector(_cmd));
    return [super decodeTopLevelObjectAndReturnError:error];
}

- (void)decodeValuesOfObjCTypes:(const char *)types, ...
{
    DAJSONCoderLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)decodeArrayOfObjCType:(const char *)itemType count:(NSUInteger)count at:(void *)array
{
    DAJSONCoderLog(@"%@", NSStringFromSelector(_cmd));
}

- (nullable void *)decodeBytesWithReturnedLength:(NSUInteger *)lengthp NS_RETURNS_INNER_POINTER
{
    DAJSONCoderLog(@"%@", NSStringFromSelector(_cmd));
    return NULL;
}

- (BOOL)containsValueForKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return nil != [_jsonObject objectForKey:key];
}

- (nullable id)decodeObjectForKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return [self decodedObject:_jsonObject[key]];
}

- (nullable id)decodeTopLevelObjectForKey:(NSString *)key error:(NSError **)error
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return nil;
}

- (BOOL)decodeBoolForKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return [_jsonObject[key] boolValue];
}

- (int)decodeIntForKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return [_jsonObject[key] intValue];
}

- (int32_t)decodeInt32ForKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return [_jsonObject[key] intValue];
}

- (int64_t)decodeInt64ForKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return [_jsonObject[key] integerValue];
}

- (float)decodeFloatForKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return [_jsonObject[key] floatValue];
}

- (double)decodeDoubleForKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return [_jsonObject[key] doubleValue];
}

- (nullable const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(nullable NSUInteger *)lengthp
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    
    if (NULL == lengthp)
        return NULL;
    
    NSString *base64EncodedString = _jsonObject[key];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64EncodedString options:0];
    
    *lengthp = data.length;
    
    return [data bytes];
}

- (NSInteger)decodeIntegerForKey:(NSString *)key
{
    DAJSONCoderLog(@"%@, key: %@", NSStringFromSelector(_cmd), key);
    return [_jsonObject[key] integerValue];
}

#pragma mark - Private

- (nullable id)decodedObject:(nullable id)object
{
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[object count]];
        
        for (id element in object) {
            DAJSONUnarchiver *unarchiver = [[[self class] alloc] initForReadingWithJSONObject:element];
            id object = [unarchiver decodeObject];
            [array addObject:object];
        }
    
        return array;
    }
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        id key = [object allKeys].firstObject;
        
        if (nil == key)
            return nil;
        
        DAJSONUnarchiver *unarchiver = [[[self class] alloc] initForReadingWithJSONObject:object[key]];
        id decodedObject = [self makeObjectForKey:key withCoder:unarchiver];
        
        if (nil != decodedObject) {
            // Dictionary represents class
            return [decodedObject awakeAfterUsingCoder:self];
        }
        else {
            // Regular dictionary
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:[object count]];
            
            [object enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                DAJSONUnarchiver *unarchiver = [[[self class] alloc] initForReadingWithJSONObject:obj];
                dictionary[key] = [unarchiver decodeObject];
            }];

            return dictionary;
        }
    }

    return [object awakeAfterUsingCoder:self];
}

@end
