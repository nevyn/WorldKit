#define WORLD_WRITABLE_MODEL 1
#import "WorldGame.h"

@implementation WorldGame
+ (BOOL)isRootEntity
{
    return YES;
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
