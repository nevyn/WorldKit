#define WORLD_WRITABLE_MODEL 1
#import "MultiPongServer.h"
#import <WorldKit/WorldKit.h>
#import "../PongWorld/MultiPongGame.h"
#import <SPSuccinct/SPSuccinct.h>
#import "Vector2.h"

@interface MultiPongServer () <WorldMasterServerDelegate>
@end

@implementation MultiPongServer {
    WorldMasterServer *_master;
    WorldGameServer *_gameServer;
}

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    _master = [[WorldMasterServer alloc] initListeningOnPort:kMultiPongServerPort];
    _master.delegate = self;
    NSError *err = nil;
    _gameServer = [_master createGameServerWithParameters:@{WorldMasterServerParamGameName: @"Test game"} error:&err];
    NSAssert(_gameServer != nil, @"Failed game creation: %@", err);
    [_master serveOnlyGame:_gameServer];
    
    [NSTimer scheduledTimerWithTimeInterval:1/60. target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    return self;
}

- (WorldGameServer*)masterServer:(WorldMasterServer*)master createGameForRequest:(NSDictionary*)dict error:(NSError**)err;
{
    WorldGameServer *newGameServer = [[WorldGameServer alloc] initWithGameClass:[MultiPongGame class] playerClass:[MultiPongPlayer class] heartBeatRate:60.];
    
    MultiPongGame *game = $cast(MultiPongGame,newGameServer.game);
    
    game.ball = [MultiPongBall new];
    
    [newGameServer sp_observe:@"game.players" removed:^(id oldPlayer) {
        
    } added:^(MultiPongPlayer *newPlayer) {
        if (!newPlayer.paddle)
            newPlayer.paddle = [MultiPongPaddle new];
    }];
    
    return newGameServer;
}

#define MPRectMaxX(rect) (rect.origin.x + rect.size.width)
#define MPRectMaxY(rect) (rect.origin.y + rect.size.height)

- (void)tick
{
    CGFloat delta = 1/60.;
    
    MultiPongGame *game = $cast(MultiPongGame,_gameServer.game);
    MultiPongBall *ball = game.ball;
    MutableVector2 *pos = [MutableVector2 vectorWithPoint:ball.position];
    MutableVector2 *vel =[MutableVector2 vectorWithPoint:ball.velocity];
    pos = [pos addVector:[vel vectorByMultiplyingWithScalar:delta]];
    
    CGRect bounds = (CGRect){.size = game.boardSize };
    
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
    
    ball.position = pos.point;
    ball.velocity = vel.point;
}

@end
