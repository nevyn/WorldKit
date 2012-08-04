#define WORLD_WRITABLE_MODEL 1
#import "WorldGamePlayer.h"
#import "WorldGame.h"
#import "SPLowVerbosity.h"

@implementation WorldGamePlayer
- (void)removeFromParent
{
	[$castIf(WorldGame,self.parent).players removeObject:self];
}
@end
