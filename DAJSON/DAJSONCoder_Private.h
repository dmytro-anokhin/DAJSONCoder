//
//  DAJSONCoder_Private.h
//  DAJSON
//
//  Created by Dmytro Anokhin on 25/09/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//

#import "DAJSONCoder.h"


#define DAJSONCoderVerbose 0

#if DAJSONCoderVerbose == 1
    #define DAJSONCoderLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
    #define DAJSONCoderLog(format, ...) {}
#endif


@interface DAJSONCoder ()
@end


/// The key used in DAJSONCoderObjectGraphCycleResolutionStrategyReference resolution strategy
static NSString * const DAJSONCoderURIReferenceKey = @"$ref";

static NSString * const DAJSONCoderURIDocumentRoot = @"/";

static NSString * const DAJSONCoderURISeparator = @".";
