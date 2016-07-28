//
//  DAJSONCoder.m
//  DAJSON
//
//  Created by Dmytro Anokhin on 24/09/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//

#import "DAJSONCoder.h"
#import "DAJSONCoder_Private.h"


@implementation DAJSONCoder

- (NSString *)keyForObject:(id)object
{
    return NSStringFromClass([object classForCoder]);
}

- (nullable id)makeObjectForKey:(NSString *)key withCoder:(NSCoder *)coder
{
    Class class = NSClassFromString(key);
    if (Nil == class)
        return nil;
    
    return [[class alloc] initWithCoder:coder];
}

#pragma mark - NSCoder

- (NSInteger)versionForClassName:(NSString *)className
{
    return 0;
}

- (BOOL)allowsKeyedCoding
{
    return YES;
}

@end
