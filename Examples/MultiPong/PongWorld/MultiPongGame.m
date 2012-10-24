#define WORLD_WRITABLE_MODEL 1
#import "MultiPongGame.h"

@implementation MultiPongGame
- (id)init
{
    if (!(self = [super init]))
        return nil;
    self.boardSize = CGSizeMake(320, 440);
    return self;
}
- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"ball": self.ball.identifier ?: [NSNull null],
        @"boardSize": NSStringFromCGSize(self.boardSize)
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"ball", ^(id o) {
        if([o isEqual:[NSNull null]])
            self.ball = nil;
        else
            self.ball = fetcher(o, [MultiPongBall class], NO);
    });
    WorldIf(rep, @"boardSize", ^(id o) { self.boardSize = CGSizeFromString(o); });
}

@end
