#define WORLD_WRITABLE_MODEL 1
#import "MultiPongPlayer.h"

@implementation MultiPongPlayer
- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"paddle": self.paddle.identifier ?: [NSNull null],
        @"score": @(self.score),
		@"scoringArc": @[@(self.scoringArc.start), @(self.scoringArc.length)],
    });
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher
{
    [super updateFromRep:rep fetcher:fetcher];
    WorldIf(rep, @"paddle", ^(id o) {
        if([o isEqual:[NSNull null]])
            self.paddle = nil;
        else
            self.paddle = fetcher(o, [MultiPongPaddle class], NO);
    });
    WorldIf(rep, @"score", ^(id o) { self.score = [o intValue]; });
	WorldIf(rep, @"scoringArc", ^(id o) { self.scoringArc = (MPFloatRange){[o[0] floatValue], [o[1] floatValue]}; });
}
- (float)hue
{
	return [self.identifier hash]/(float)NSUIntegerMax;
}
@end
