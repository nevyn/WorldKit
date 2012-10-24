#define WORLD_WRITABLE_MODEL 1
#import "MultiPongPaddle.h"

@implementation MultiPongPaddle
- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.size = (CGSize){100, 20};
    
    return self;
}

- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"position": NSStringFromCGPoint(self.position),
        @"size": NSStringFromCGSize(self.size),
        @"velocity": NSStringFromCGPoint(self.velocity)
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"position", ^(id o) { self.position = CGPointFromString(o); });
    WorldIf(rep, @"size", ^(id o) { self.size = CGSizeFromString(o); });
    WorldIf(rep, @"velocity", ^(id o) { self.velocity = CGPointFromString(o); });
}
@end
