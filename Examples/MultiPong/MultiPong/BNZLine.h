//
//  BNZLine.h
//  Aurora2D
//
//  Created by Joachim Bengtsson on 2007-12-10.
//  Copyright 2007 Joachim Bengtsson. All rights reserved.
//

#import "Vector2.h"

typedef enum {
	BNZLinesDoNotIntersect = 0,
    BNZLinesIntersect = 1,
    BNZLinesAreParallel,
    BNZLinesAreCoincident
} BNZLineIntersectionResult;

@interface BNZLine : NSObject
@property (nonatomic, strong) Vector2 *start, *end;

-(instancetype)initAt:(Vector2*)start_ to:(Vector2*)end_;
+(instancetype)lineAt:(Vector2*)start_ to:(Vector2*)end_;

-(Vector2*)vector;

-(BNZLineIntersectionResult)getIntersectionPoint:(Vector2**)intersectionPoint_ withLine:(BNZLine*)other;
-(Vector2*)intersectionPointWithLine:(BNZLine*)other;

-(CGFloat)distanceToPoint:(Vector2*)point;
-(CGFloat)length;
@end
