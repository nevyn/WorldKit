#define WORLD_WRITABLE_MODEL 1
#import "MultiPongServer.h"
#import <WorldKit/WorldKit.h>
#import "../PongWorld/MultiPongGame.h"
#import <SPSuccinct/SPSuccinct.h>

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
    
    _master = [[WorldMasterServer alloc] initListeningOnBasePort:kMultiPongServerPort];
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
    WorldGameServer *newGameServer = [[WorldGameServer alloc] initWithGameClass:[MultiPongGame class] playerClass:[MultiPongPlayer class] heartBeatRate:10.];
    
    return newGameServer;
}

- (void)tick
{
	[$cast(MultiPongGame, _gameServer.game) tick];
}

@end
