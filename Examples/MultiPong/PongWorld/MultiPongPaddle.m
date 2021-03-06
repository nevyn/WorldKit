#define WORLD_WRITABLE_MODEL 1
#import "MultiPongPaddle.h"


@implementation MultiPongPaddle
- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.size = (CGSize){0.1, 0.02};
	self.position = [Vector2 vectorWithX:0 y:0];
	self.velocity = [Vector2 vectorWithX:0 y:0];
	self.acceleration = [Vector2 vectorWithX:0 y:0];
    
    return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"position": NSStringFromCGPoint(self.position.point),
        @"size": NSStringFromCGSize(self.size),
        @"velocity": NSStringFromCGPoint(self.velocity.point),
		@"acceleration": NSStringFromCGPoint(self.acceleration.point),
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"position", ^(id o) { self.position = [Vector2 vectorWithPoint:CGPointFromString(o)]; });
    WorldIf(rep, @"size", ^(id o) { self.size = CGSizeFromString(o); });
    WorldIf(rep, @"velocity", ^(id o) { self.velocity = [Vector2 vectorWithPoint:CGPointFromString(o)]; });
    WorldIf(rep, @"acceleration", ^(id o) { self.acceleration = [Vector2 vectorWithPoint:CGPointFromString(o)]; });
}

- (Vector2*)cartesianPosition
{
	Vector2 *direction = [Vector2 vectorWithX:cos(self.position.x) y:sin(self.position.x)];
	Vector2 *pos = [[Vector2 vectorWithX:.5 y:.5] vectorByAddingVector:[direction vectorByMultiplyingWithScalar:.5]]; // {.5,.5} + dir*.5 + (inv(dir)*y)
	return pos;
}

- (BNZLine*)cartesianLine
{
	Vector2 *direction = [Vector2 vectorWithX:cos(self.position.x) y:sin(self.position.x)];
	Vector2 *center = [self cartesianPosition];
	Vector2 *l = [[direction leftHandNormal] vectorByMultiplyingWithScalar:self.size.width/2.];
	Vector2 *r = [[direction rightHandNormal] vectorByMultiplyingWithScalar:self.size.width/2.];
	return [BNZLine lineAt:[center vectorByAddingVector:l] to:[center vectorByAddingVector:r]];
}

@end
