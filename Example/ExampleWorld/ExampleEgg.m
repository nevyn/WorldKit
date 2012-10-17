#define WORLD_WRITABLE_MODEL 1
#import "ExampleEgg.h"

@implementation ExampleEgg
- (id)init
{
    if (!(self = [super init]))
        return nil;
    self.shape = @"round";
    return self;
}
- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"shape": self.shape
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"shape", ^(id o) { self.shape = o; });
}
@end
