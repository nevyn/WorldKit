#define WORLD_WRITABLE_MODEL 1
#import "WorldGameServer.h"
#import "WorldServerPlayer.h"
#import "WorldServerTypes.h"
#import <WorldKit/Shared/WorldContainer.h>
#import <WorldKit/Shared/WorldGame.h>
#import <WorldKit/Shared/WorldGamePlayer.h>
#import "TCAsyncHashProtocol.h"

@implementation WorldGameServer {
    WorldGame *_game;
    Class _playerClass;
    WorldGamePlayer *_owner;
    NSMutableArray *_splayers;
    WorldContainer *_entities;
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
    
    return self;
}

- (WorldGame*)game
{
    return _game;
}
- (WorldGamePlayer*)owner
{
    return _owner;
}

/// Takes ownership of the player and its socket.
-(void)join:(WorldServerPlayer*)splayer leaver:(dispatch_block_t)leaver
{
    ProtoAssert(splayer.connection.socket, ![_splayers containsObject:splayer], @"A player already in the game cannot join");
    splayer.leaver = leaver;
    
    WorldGamePlayer *gplayer = [_playerClass new];
    gplayer.name = splayer.name;
    gplayer.identifier = splayer.gameCenterIdentifier;
    [_game.players addObject:gplayer];
    
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
    
    [self sendChanges:_entities.rep toUser:splayer];
    
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

- (void)sendChanges:(NSDictionary*)rep toUser:(WorldServerPlayer*)splayer
{
    NSDictionary *newRep = [_entities rep];
    NSDictionary *oldRep = [splayer latestAckedSnapshot].rep;
    WorldServerSnapshot *snapshot = [splayer addSnapshot:newRep];
    NSDictionary *diff = [_entities diffRep:newRep fromRep:oldRep];
    
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
