#define WORLD_WRITABLE_MODEL 1
#import "MultiPongGame.h"
#import "Vector2.h"

@implementation MultiPongGame
- (id)init
{
    if (!(self = [super init]))
        return nil;
    self.boardSize = CGSizeMake(1, 1);
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
	
	Vector2 *oldBallPos = [self.ball position];
    
	NSArray *physicsables = [[self.players valueForKeyPath:@"paddle"] arrayByAddingObject:self.ball];
	for(MultiPongBall *thing in physicsables) {
		MutableVector2 *pos = [thing.position mutableCopy];
		MutableVector2 *vel =[thing.velocity mutableCopy];
		pos = [pos addVector:[vel vectorByMultiplyingWithScalar:delta]];
		
		thing.position = pos;
		thing.velocity = vel;
	}
	
	Vector2 *newBallPos = [self.ball position];
	BNZLine *ballMovement = [BNZLine lineAt:oldBallPos to:newBallPos];
	
	for(MultiPongPlayer *player in self.players) {
		MultiPongPaddle *paddle = player.paddle;
		BNZLine *paddleLine = paddle.cartesianLine;
		
		Vector2 *collision;
		if([paddleLine getIntersectionPoint:&collision withLine:ballMovement] == BNZLinesIntersect) {
			Vector2 *collisionVector = [[[BNZLine lineAt:oldBallPos to:collision] vector] invertedVector];
			Vector2 *paddleVector = [paddleLine vector];
			Vector2 *normal = [paddleVector rightHandNormal];
			Vector2 *mirror = [collisionVector vectorByProjectingOnto:normal];
			Vector2 *lefty = [collisionVector vectorBySubtractingVector:mirror];
			Vector2 *righty = [lefty invertedVector];
			Vector2 *outgoingVector = [mirror vectorByAddingVector:[righty vectorByMultiplyingWithScalar:3]];
			newBallPos = [collision vectorByAddingVector:outgoingVector];
			self.ball.position = newBallPos;
			self.ball.velocity = [[outgoingVector normalizedVector] vectorByMultiplyingWithScalar:[self.ball.velocity length]];
			break;
		}
	}
	
	Vector2 *ballVectorFromMiddle = [newBallPos vectorBySubtractingVector:[Vector2 vectorWithX:.5 y:.5]];
	if([ballVectorFromMiddle length] > 0.51) {
		self.ball.position = [Vector2 vectorWithX:.5 y:.5];
		Vector2 *newVelocity = [self.ball.velocity vectorByRotatingByRadians:((rand()%1000)/1000.)*M_PI];
		self.ball.velocity = [Vector2 vectorWithX:0 y:0];
		[self.ball performSelector:@selector(setVelocity:) withObject:newVelocity afterDelay:1.0];
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
	player.paddle.velocity = [Vector2
		vectorWithX:movement == MultiPongMovementLeft ? -1 : movement == MultiPongMovementRight ? 1 : 0
		y:0
	];
}
@end