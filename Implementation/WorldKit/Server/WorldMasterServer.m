#define WORLD_WRITABLE_MODEL 1
#import "_WorldMasterServer.h"
#import "_WorldGameServer.h"
#import "WorldServerPlayer.h"
#import "WorldServerTypes.h"

#import <WorldKit/Shared/WorldGame.h>
#import <WorldKit/Shared/WorldGamePlayer.h>

#import "AsyncSocket.h"
#import "TCAsyncHashProtocol.h"
#import "SPDepends.h"
#import "SPLowVerbosity.h"

@interface WorldMasterServer ()
-(void)broadcast:(NSDictionary*)hash;
-(WorldServerPlayer*)playerForSocket:(AsyncSocket*)sock;
-(NSDictionary*)cmd_updateGameList;
@end

@implementation WorldMasterServer {
	AsyncSocket *_listen;
    NSMutableDictionary *_socketsToPlayers;
	NSMutableSet *_gamelessPlayers;
	NSMutableSet *_games;
    WorldGameServer *_singleGame;
	int _listenPort;
}
- (id)initListeningOnBasePort:(int)port
{
    if (!(self = [super init]))
        return nil;
    
	_listen = [[AsyncSocket alloc] initWithDelegate:self];
	_gamelessPlayers = [NSMutableSet new];
	_games = [NSMutableSet new];
    _socketsToPlayers = [NSMutableDictionary new];
	
	_listenPort = port;
	NSError *err = nil;
	while(![_listen acceptOnPort:_listenPort error:&err]) {
		if([[err domain] isEqualToString:AsyncSocketErrorDomain] && [err code] == -1 && _listenPort - port < 20) {
			_listenPort++;
			NSLog(@"%s: Port %d busy, trying next...", __PRETTY_FUNCTION__, _listenPort-1);
		} else {
			NSAssert(NO, @"Failed to listen: %@", err);
			return nil;
		}
	}
	
	NSLog(@"Listening on port %d", _listenPort);
	$depends(@"broadcast games", self, @"games", (id)^{
		[selff broadcast:selff.cmd_updateGameList];
	});
    
    return self;
}

- (int)usedListeningPort
{
	return _listenPort;
}

- (WorldGameServer*)createGameServerWithParameters:(NSDictionary*)hash error:(NSError**)err
{
	NSString *name = [hash objectForKey:WorldMasterServerParamGameName] ?: @"Unnamed game";
    
	WorldGameServer *sgame = [_delegate masterServer:self createGameForRequest:hash error:err];
    if (!sgame)
        return nil;
    
    sgame.game.name = name;
	
	[[self mutableSetValueForKey:@"games"] addObject:sgame];
    
    return sgame;
}

- (void)serveOnlyGame:(WorldGameServer*)server;
{
    _singleGame = server;
}

#pragma mark Listen socket

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	TCAsyncHashProtocol *proto = [[TCAsyncHashProtocol alloc] initWithSocket:newSocket delegate:(id)self];
	proto.autoDispatchCommands = YES;
	
	WorldServerPlayer *splayer = [WorldServerPlayer new];
	splayer.connection = proto;
    [_socketsToPlayers setObject:splayer forKey:[NSValue valueWithPointer:(__bridge const void *)(proto.socket)]];
	
	NSLog(@"Accepted new connection: %@", newSocket);
	[self join:splayer];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	if(sock == _listen) {
		NSLog(@"Dropped listen socket: %@", err);
		abort();
	}
        WorldServerPlayer *player = [self playerForSocket:sock];
	NSLog(@"Lost connection: %@/%@: %@", sock, player, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	WorldServerPlayer *player = [self playerForSocket:sock];
	[_gamelessPlayers removeObject:player];
    [_socketsToPlayers removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(sock)]];
}


#pragma mark Players
-(WorldServerPlayer*)playerForSocket:(AsyncSocket*)sock;
{
	return [_socketsToPlayers objectForKey:[NSValue valueWithPointer:(__bridge const void *)(sock)]];
}

-(void)join:(WorldServerPlayer*)splayer;
{
	[_gamelessPlayers addObject:splayer];
	splayer.connection.delegate = (id)self;
	[splayer.connection sendHash:self.cmd_updateGameList];
}


-(void)broadcast:(NSDictionary*)hash;
{
	for(WorldServerPlayer *player in _gamelessPlayers)
		[player.connection sendHash:hash];
}

#pragma mark Games
-(NSDictionary*)cmd_updateGameList;
{
	NSMutableArray *gameDescs = [NSMutableArray array];
	NSArray *sortedGames = [_games.allObjects sortedArrayUsingComparator:^(id obj1, id obj2) {
		return [[[obj1 game] name] compare:[[obj2 game] name]];
	}];
	for(WorldGameServer *game in sortedGames)
		[gameDescs addObject:@{
			@"name": game.game.name,
			@"identifier": game.game.identifier,
			@"ownerName": game.owner.name ?: @"(Ownerless)"
		}];
	
	return @{
		@"command": @"updateGameList",
		@"games": gameDescs
	};
}
-(WorldGameServer*)gameForIdentifier:(NSString*)identifier;
{
	for(WorldGameServer *game in _games)
		if([game.game.identifier isEqual:identifier])
			return game;
	return nil;
}


#pragma mark commands & requests
-(void)request:(TCAsyncHashProtocol*)proto clientHello:(NSDictionary*)hash responder:(TCAsyncHashProtocolResponseCallback)callback;
{
	WorldServerPlayer *splayer = [self playerForSocket:proto.socket];
	
	ProtoAssert(proto.socket, splayer.gameCenterIdentifier == nil, @"Can only receive clientHello once");
	
	NSString *playerName = [hash objectForKey:@"name"];
	ProtoAssert(proto.socket, playerName != nil, @"Must have player name");
    
    NSString *playerId = [hash objectForKey:@"playerIdentifier"];
	ProtoAssert(proto.socket, playerId != nil, @"Must have player ident");
    
    splayer.name = playerName;
    splayer.gameCenterIdentifier = playerId;
	
	callback(@{
		@"success": @YES
	});
    
    if (!_singleGame) {
        // join lobby
    	[self join:splayer];
    } else {
        // immediately join the single hosted game
        __weak __typeof(self) weakSelf = self;
        [_singleGame join:splayer leaver:^{
            [weakSelf join:splayer];
        }];
    }

}

-(void)request:(TCAsyncHashProtocol*)proto createGame:(NSDictionary*)hash responder:(TCAsyncHashProtocolResponseCallback)callback;
{
	WorldServerPlayer *player = [self playerForSocket:proto.socket];
	ProtoAssert(proto.socket, player.gameCenterIdentifier != nil, @"Must have gotten clientHello once");
    
    NSError *err = nil;
	WorldGameServer *sgame = [self createGameServerWithParameters:hash error:&err];
    if (!sgame) {
        callback(@{
            @"success": @NO,
            @"error": [err localizedDescription]
        });
        return;
    }
	
	NSLog(@"%@ created and joined game %@", player, sgame);
	
	callback(@{
        @"success": @YES
    });
	
	[_gamelessPlayers removeObject:player];
    __weak __typeof(self) weakSelf = self;
	[sgame join:player leaver:^{
        [weakSelf join:player];
    }];
    
	[[self mutableSetValueForKey:@"games"] addObject:sgame];
}

-(void)request:(TCAsyncHashProtocol*)proto joinGame:(NSDictionary*)hash responder:(TCAsyncHashProtocolResponseCallback)callback;
{
	WorldServerPlayer *player = [self playerForSocket:proto.socket];
	ProtoAssert(proto.socket, player.gameCenterIdentifier != nil, @"Must have gotten clientHello once");
	
	NSString *ident = [hash objectForKey:@"identifier"];
	ProtoAssert(proto.socket, ident != nil, @"Must have identifier of the game to join");

	WorldGameServer *sgame = [self gameForIdentifier:ident];
	if(!sgame) {
		callback($dict(
			@"success", @NO,
			@"reason", @"No such game"
		));
		return;
	}
	
	[_gamelessPlayers removeObject:player];
    __weak __typeof(self) weakSelf = self;
	[sgame join:player leaver:^{
        [weakSelf join:player];
    }];

	callback(@{
        @"success": @YES
    });
}

@end

NSString *WorldMasterServerParamGameName = @"gameName";