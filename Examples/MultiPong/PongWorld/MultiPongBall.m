#define WORLD_WRITABLE_MODEL 1
#import "MultiPongBall.h"
#import "Vector2.h"

@implementation MultiPongBall
- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.size = 5;
    self.position = [Vector2 vectorWithX:.5 y:.5];
    self.velocity = [Vector2 vectorWithX:0.085 y:0.1];
    
    return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"position": NSStringFromCGPoint(self.position.point),
        @"size": @(self.size),
        @"velocity": NSStringFromCGPoint(self.velocity.point)
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"position", ^(id o) { self.position = [Vector2 vectorWithPoint:CGPointFromString(o)]; });
    WorldIf(rep, @"size", ^(id o) { self.size = [o floatValue]; });
    WorldIf(rep, @"velocity", ^(id o) { self.velocity = [Vector2 vectorWithPoint:CGPointFromString(o)]; });
}

@end
