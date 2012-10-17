#define WORLD_WRITABLE_MODEL 1
#import "WorldGameServer.h"
#import "WorldServerPlayer.h"
#import "WorldServerTypes.h"
#import <WorldKit/Shared/WorldContainer.h>
#import <WorldKit/Shared/WorldGame.h>
#import <WorldKit/Shared/WorldGamePlayer.h>
#import <SPSuccinct/SPSuccinct.h>
#import "TCAsyncHashProtocol.h"

@implementation WorldGameServer {
    WorldGame *_game;
    Class _playerClass;
    WorldGamePlayer *_owner;
    NSMutableArray *_splayers;
    WorldContainer *_entities;
    NSTimer *_tickTimer;
}
- (id)initWithGameClass:(Class)gameClass playerClass:(Class)playerClass
{
    if (!(self = [super init]))
        return nil;
    _game = [[gameClass alloc] init];
    _playerClass = playerClass;
    _splayers = [NSMutableArray array];
    _entities = [[WorldContainer alloc] initWithEntityClassSuffix:@"Server"];
    [_entities publishEntity:_game];
    _tickTimer = [NSTimer scheduledTimerWithTimeInterval:1/10. target:self selector:@selector(tick) userInfo:nil repeats:YES];
    return self;
}

- (void)stop
{
    [_tickTimer invalidate];
    _tickTimer = nil;
}

- (WorldGame*)game
{
    return _game;
}
- (WorldGamePlayer*)owner
{
    return _owner;
}

#pragma mark - Join/leave

/// Takes ownership of the player and its socket.
-(void)join:(WorldServerPlayer*)splayer leaver:(dispatch_block_t)leaver
{
    ProtoAssert(splayer.connection.socket, ![_splayers containsObject:splayer], @"A player already in the game cannot join");
    splayer.leaver = leaver;
    [_splayers addObject:splayer];
    splayer.connection.delegate = (id)self;
    
    WorldGamePlayer *gplayer = [_playerClass new];
    gplayer.name = splayer.name;
    gplayer.identifier = splayer.gameCenterIdentifier;
    [[_game mutableArrayValueForKey:@"players" ] addObject:gplayer];
    
    splayer.representation = gplayer;
    
    // First player to join the game owns it
    if (!_owner)
        _owner = gplayer;
    
    [splayer.connection sendHash:@{
		@"command": @"joinGame",
		@"name": self.game.name,
		@"ownerName": _owner.name,
		@"identifier": self.game.identifier
	}];
    
    [self sendWorld:_entities.rep toUserIfNeeded:splayer];
    
    [splayer.connection sendHash:@{
        @"command": @"thisIsYou",
        @"identifier": gplayer.identifier
    }];
}
-(void)leave:(WorldServerPlayer*)splayer
{
    ProtoAssert(splayer.connection.socket, [_splayers containsObject:splayer], @"A player not in the game cannot leave");
    
	[splayer.connection sendHash:@{
		@"command": @"leaveGame"
	}];
	[_splayers removeObject:splayer];
	[self.game.players removeObject:splayer.representation];
    
    [splayer leave];
}

- (WorldServerPlayer*)splayerForConnection:(TCAsyncHashProtocol*)proto
{
    return [_splayers sp_any:^BOOL(WorldServerPlayer *potential) {
        return potential.connection == proto;
    }];
}

-(void)command:(TCAsyncHashProtocol*)proto leaveGame:(NSDictionary*)hash;
{
    [self leave:[self splayerForConnection:proto]];
}

#pragma mark - Game contents

- (void)tick
{
    NSDictionary *now = [_entities rep];
    for(WorldServerPlayer *player in _splayers)
        [self sendWorld:now toUserIfNeeded:player];
}

- (void)sendWorld:(NSDictionary*)newRep toUserIfNeeded:(WorldServerPlayer*)splayer
{
    NSDictionary *oldRep = [splayer latestAckedSnapshot].rep;
    NSDictionary *diff = [_entities diffRep:newRep fromRep:oldRep];
    if(!diff)
        return;
    
    WorldServerSnapshot *snapshot = [splayer addSnapshot:newRep];
    
    [splayer.connection sendHash:@{
        @"command": @"applyDiff",
        @"snapshotIdentifier": snapshot.identifier,
        @"timestamp": @(snapshot.timestamp),
        @"diff": diff
    }];
    
    // Until we get UDP...
    [splayer ackSnapshotIdentified:snapshot.identifier];
}


@end
