//
//  DAJSONTests.m
//  DAJSONTests
//
//  Created by Dmytro Anokhin on 04/10/15.
//  Copyright © 2015 Dmytro Anokhin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <DAJSON/DAJSON.h>


static inline BOOL IsEqual(id object1, id object2) {
    return object1 == object2 || [object1 isEqual:object2];
}


@interface TestObject : NSObject <NSCoding>

@property (nonatomic) int intValue;
@property (nonatomic, getter=isBoolValue) BOOL boolValue;
@property (nonatomic) NSString *stringValue;
@property (nonatomic) NSNumber *numberValue;
@property (nonatomic) CGSize sizeValue;
@property (nonatomic) UIView *view;

@property (nonatomic) TestObject *objectValue;
@property (nonatomic, weak) TestObject *objectReference;

@property (nonatomic) NSDictionary *dictionary;
@property (nonatomic) NSArray *array;
@property (nonatomic) NSSet *set;

@property (nonatomic) UIColor *color;

@end


@implementation TestObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self)
        return nil;
    
    _intValue = [aDecoder decodeIntForKey:@"intValue"];
    _boolValue = [aDecoder decodeBoolForKey:@"boolValue"];
    _stringValue = [aDecoder decodeObjectForKey:@"stringValue"];
    _numberValue = [aDecoder decodeObjectForKey:@"numberValue"];
    _sizeValue = [aDecoder decodeCGSizeForKey:@"sizeValue"];
    _objectValue = [aDecoder decodeObjectForKey:@"objectValue"];
    _objectReference = [aDecoder decodeObjectForKey:@"objectReference"];
    _view = [aDecoder decodeObjectForKey:@"view"];
    _dictionary = [aDecoder decodeObjectForKey:@"dictionary"];
    _array = [aDecoder decodeObjectForKey:@"array"];
    _set = [aDecoder decodeObjectForKey:@"set"];
    _color = [aDecoder decodeObjectForKey:@"color"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_intValue forKey:@"intValue"];
    [aCoder encodeBool:_boolValue forKey:@"boolValue"];
    [aCoder encodeObject:_stringValue forKey:@"stringValue"];
    [aCoder encodeObject:_numberValue forKey:@"numberValue"];
    [aCoder encodeCGSize:_sizeValue forKey:@"sizeValue"];
    [aCoder encodeObject:_objectValue forKey:@"objectValue"];
    [aCoder encodeObject:_objectReference forKey:@"objectReference"];
    [aCoder encodeObject:_view forKey:@"view"];
    [aCoder encodeObject:_dictionary forKey:@"dictionary"];
    [aCoder encodeObject:_array forKey:@"array"];
    [aCoder encodeObject:_set forKey:@"set"];
    [aCoder encodeObject:_color forKey:@"color"];
}

- (BOOL)isEqual:(id)object
{
    if ([super isEqual:object])
        return YES;
    
    if (![object isKindOfClass:[self class]])
        return NO;
    
    __typeof__(self) anotherObject = object;
    
    if (self.intValue != anotherObject.intValue)
        return NO;
    
    if (self.boolValue != anotherObject.boolValue)
        return NO;
    
    if (!IsEqual(self.stringValue, anotherObject.stringValue))
        return NO;
    
    if (!IsEqual(self.numberValue, anotherObject.numberValue))
        return NO;
    
    if (!CGSizeEqualToSize(self.sizeValue, anotherObject.sizeValue))
        return NO;
    
    if (!IsEqual(self.objectValue, anotherObject.objectValue))
        return NO;

    if (!IsEqual(self.objectReference, anotherObject.objectReference))
        return NO;

    if (!IsEqual(self.dictionary, anotherObject.dictionary))
        return NO;
    
    if (!IsEqual(self.array, anotherObject.array))
        return NO;
    
    if (!IsEqual(self.set, anotherObject.set))
        return NO;
    
    if (!IsEqual(self.color, anotherObject.color))
        return NO;
    
//    if (!IsEqual(self.view, anotherObject.view))
//        return NO;
    
    return YES;
}

@end


@interface DAJSONTests : XCTestCase

@end

@implementation DAJSONTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testArray
{
    NSArray *array = @[ @0, @1, @2 ];
    NSData *data = [DAJSONArchiver archivedDataWithRootObject:array];
    XCTAssertNotNil(data);
    
    NSString *stringRepresentation = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(stringRepresentation, @"[0,1,2]");
    
    id unarchived = [DAJSONUnarchiver unarchiveObjectWithData:data];
    XCTAssert([unarchived isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(unarchived, array);
}

- (void)testDictionary
{
    NSDictionary *dictionary = @{ @"0" : @0, @"1" : @1, @"2" : @2 };
    NSData *data = [DAJSONArchiver archivedDataWithRootObject:dictionary];
    XCTAssertNotNil(data);
    
    id unarchived = [DAJSONUnarchiver unarchiveObjectWithData:data];
    XCTAssert([unarchived isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(unarchived, dictionary);
}

- (void)testHierarchicalStructure
{
    NSDictionary *dictionary = @{
        @"0" : @0,
        @"1" : @[
            @"1.0",
            @{
                @"2.0" : @0,
                @"2.1" : @[
                    @"3.0",
                    @{
                        @"4.0" : @0
                    }
                ]
            }
        ],
        @"2" : @{
            @"1.0" : @0,
            @"1.1" : @{
                @"2.0" : @0,
                @"2.1" : @{
                    @"3.0" : @0
                }
            }
        }
    };
    
    NSData *data = [DAJSONArchiver archivedDataWithRootObject:dictionary];
    XCTAssertNotNil(data);
    
    id unarchived = [DAJSONUnarchiver unarchiveObjectWithData:data];
    XCTAssert([unarchived isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(unarchived, dictionary);
}

- (void)testSerialization
{
    TestObject *object1 = [TestObject new];
    object1.intValue = 1;
    object1.boolValue = YES;
    object1.stringValue = @"First";
    object1.numberValue = @123.456789;
    object1.sizeValue = CGSizeMake(320.0, 480.0);
    object1.objectValue = ({
        TestObject *object = [TestObject new];
        object.stringValue = @"First child";
        object;
    });
    object1.view = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(40.0, 50.0, 200.0, 44.0)];
        view.backgroundColor = [UIColor cyanColor];
        view;
    });
    object1.array = @[ @1, @2, @3 ];
    object1.color = [UIColor yellowColor];

    TestObject *object2 = [TestObject new];
    object2.intValue = 2;
    object2.set = [NSSet setWithObjects:@1, @2, @3, nil];

    TestObject *object3 = [TestObject new];
    object3.intValue = 3;
    object3.stringValue = @"Third";

    object1.dictionary = @{ @"mykey" : @"myvalue", @"mycustomobjectindictionary" : object3 };
    
    id prototype = @[object1, object2];
    
    NSData *data = [DAJSONArchiver archivedDataWithRootObject:prototype];
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    id unarchived = [DAJSONUnarchiver unarchiveObjectWithData:data];
    NSLog(@"unarchived: %@", unarchived);
    
    XCTAssertEqualObjects(unarchived, prototype);
}

- (void)testDataEncoding
{
    NSString *string = @"Hello, world!";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *archived = [DAJSONArchiver archivedDataWithRootObject:data];
    NSLog(@"%@", [[NSString alloc] initWithData:archived encoding:NSUTF8StringEncoding]);
    
    id unarchived = [DAJSONUnarchiver unarchiveObjectWithData:archived];

    XCTAssertEqualObjects(unarchived, data);
    
    NSString *unarchivedString = [[NSString alloc] initWithData:unarchived encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(unarchivedString, string);
}

- (void)testCycles
{
    TestObject *object1 = [TestObject new];
    object1.stringValue = @"First";

    TestObject *object2 = [TestObject new];
    object2.stringValue = @"Second";
/*
    object1.objectValue = object2;
    object2.objectValue = object1;
*/
    TestObject *object3 = [TestObject new];
    object3.stringValue = @"Third";
    
    object1.objectValue = object2;
    object2.objectValue = object3;
    object3.objectValue = object2;
    
    id prototype = object1;
    NSData *archived = [DAJSONArchiver archivedDataWithRootObject:prototype objectGraphCycleResolutionStrategy:DAJSONCoderObjectGraphCycleResolutionStrategyReference];
    
    NSString *stringRepresentation =  [[NSString alloc] initWithData:archived encoding:NSUTF8StringEncoding];
    NSLog(@"%@", stringRepresentation);
    
    id unarchived = [DAJSONUnarchiver unarchiveObjectWithData:archived];

    NSLog(@"%@", unarchived);

//    XCTAssertEqualObjects(unarchived, prototype);
}

- (void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
