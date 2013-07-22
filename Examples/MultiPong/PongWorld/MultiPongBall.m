#define WORLD_WRITABLE_MODEL 1
#import "MultiPongBall.h"
#import "Vector2.h"

@implementation MultiPongBall
- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.size = 5;
    self.position = CGPointMake(0.5, 0.5);
    self.velocity = CGPointMake(0.085, 0.1);
    
    return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"position": NSStringFromCGPoint(self.position),
        @"size": @(self.size),
        @"velocity": NSStringFromCGPoint(self.velocity)
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"position", ^(id o) { self.position = CGPointFromString(o); });
    WorldIf(rep, @"size", ^(id o) { self.size = [o floatValue]; });
    WorldIf(rep, @"velocity", ^(id o) { self.velocity = CGPointFromString(o); });
}

@end
