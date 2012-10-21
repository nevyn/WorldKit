//
//  WorldEntityTest.m
//  WorldKit
//
//  Created by Joachim Bengtsson on 2012-10-22.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//
#define WORLD_WRITABLE_MODEL 1

#import "WorldEntityTest.h"
#import <WorldKit/Shared/Shared.h>

@interface TwoPropTest : WorldEntity
@property(nonatomic,WORLD_WRITABLE,retain) NSString *toOne;
@property(nonatomic,readonly) WORLD_ARRAY *toMany;
@end
@implementation TwoPropTest
@end

@implementation WorldEntityTest
- (void)testObservableAttributes
{
    STAssertEqualObjects([TwoPropTest observableAttributes], [NSSet setWithObject:@"toOne"], @"To-one attribute not published");
    STAssertEqualObjects([TwoPropTest observableToManyAttributes], [NSSet setWithObject:@"toMany"], @"To-many attribute not published");
}
@end
