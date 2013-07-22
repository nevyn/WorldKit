#define WORLD_WRITABLE_MODEL 1
#import "MultiPongGame.h"
#import "Vector2.h"

@implementation MultiPongGame
- (id)init
{
    if (!(self = [super init]))
        return nil;
    self.boardSize = CGSizeMake(320, 420);
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

#define MPRectMaxX(rect) (rect.origin.x + rect.size.width)
#define MPRectMaxY(rect) (rect.origin.y + rect.size.height)

- (void)tick
{
    CGFloat delta = 1/60.;
    
	NSArray *physicsables = [[self.players valueForKeyPath:@"paddle"] arrayByAddingObject:self.ball];
	for(MultiPongBall *thing in physicsables) {
		MutableVector2 *pos = [MutableVector2 vectorWithPoint:thing.position];
		MutableVector2 *vel =[MutableVector2 vectorWithPoint:thing.velocity];
		pos = [pos addVector:[vel vectorByMultiplyingWithScalar:delta]];
		
		CGRect bounds = (CGRect){.size = self.boardSize };
		
		if(pos.x < bounds.origin.x) {
			vel.x = -vel.x;
			pos.x = bounds.origin.x;
		} else if(pos.x > MPRectMaxX(bounds)) {
			vel.x = -vel.x;
			pos.x = MPRectMaxX(bounds);
		} else if(pos.y < bounds.origin.y) {
			vel.y = -vel.y;
			pos.y = bounds.origin.y;
		} else if(pos.y > MPRectMaxY(bounds)) {
			vel.y = -vel.y;
			pos.y = MPRectMaxY(bounds);
		}
		
		thing.position = pos.point;
		thing.velocity = vel.point;
	}
}

- (void)moveCurrentPlayer:(MultiPongMovement)movement
{
	[self sendCommandToCounterpart:@"playerMovement" arguments:@{
		@"movement": @(movement),
	}];
}

@end

@implementation MultiPongGameServer
- (void)commandFromPlayer:(MultiPongPlayer*)player playerMovement:(NSDictionary*)args
{
	MultiPongMovement movement = [args[@"movement"] intValue];
	player.paddle.velocity = CGPointMake(movement == MultiPongMovementLeft ? -250 : movement == MultiPongMovementRight ? 250 : 0, 0);
}
@end