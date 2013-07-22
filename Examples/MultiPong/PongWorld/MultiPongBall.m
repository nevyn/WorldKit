#define WORLD_WRITABLE_MODEL 1
#import "MultiPongBall.h"

@implementation MultiPongBall
- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.size = 5;
    self.position = CGPointMake(100, 100);
    self.velocity = CGPointMake(75, 150);
    
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
