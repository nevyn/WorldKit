#define WORLD_WRITABLE_MODEL 1
#import "WorldGamePlayer.h"
#import "WorldGame.h"
#import "SPLowVerbosity.h"

@implementation WorldGamePlayer
- (void)removeFromParent
{
	[$castIf(WorldGame,self.parent).players removeObject:self];
}
- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"name": self.name
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"name", ^(id o) { self.name = o; });
}

@end
