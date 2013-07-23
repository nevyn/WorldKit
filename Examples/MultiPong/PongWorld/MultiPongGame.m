#define WORLD_WRITABLE_MODEL 1
#import "MultiPongGame.h"
#import "Vector2.h"
#import <SPSuccinct/SPSuccinct.h>

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
	for(MultiPongPaddle *thing in physicsables) {
		if([thing respondsToSelector:@selector(acceleration)]) {
			thing.velocity = [[thing.velocity vectorByAddingVector:[thing.acceleration vectorByMultiplyingWithScalar:delta]] vectorByMultiplyingWithScalar:0.9];
			if(thing.velocity.length > 2.5)
				thing.velocity = [[thing.velocity normalizedVector] vectorByMultiplyingWithScalar:2.5];
		}
		thing.position = [thing.position vectorByAddingVector:[thing.velocity vectorByMultiplyingWithScalar:delta]];
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
	float scoringAngle = [[Vector2 vectorWithX:0 y:-1] angleTo:ballVectorFromMiddle];
	if(scoringAngle < 0) scoringAngle += M_PI*2;
	
	if([ballVectorFromMiddle length] > 0.51) {
		for(MultiPongPlayer *player in self.players) {
			if(scoringAngle > player.scoringArc.start && scoringAngle <= player.scoringArc.start + player.scoringArc.length) {
				player.score += 1;
				break;
			}
		}
		
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
- (void)awakeFromPublish
{
	[super awakeFromPublish];
	
    self.ball = [MultiPongBall new];
    
	[self sp_addObserver:self forKeyPath:@"players" options:NSKeyValueObservingOptionInitial callback:^(NSDictionary *change, id object, NSString *keyPath) {
		MPFloatRange range = {0, (M_PI*2)/[[object players] count]};
		for(MultiPongPlayer *player in [object players]) {
			if (!player.paddle)
				player.paddle = [MultiPongPaddle new];
			player.scoringArc = range;
			range.start += range.length;
		}
	}];
}

- (void)commandFromPlayer:(MultiPongPlayer*)player playerMovement:(NSDictionary*)args
{
	MultiPongMovement movement = [args[@"movement"] intValue];
	player.paddle.acceleration = [Vector2
		vectorWithX:movement == MultiPongMovementLeft ? -8 : movement == MultiPongMovementRight ? 8 : 0
		y:0
	];
}
@end