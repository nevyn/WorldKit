#import "WorldMasterClient.h"
#import "WorldGameClient.h"
#import <SPSuccinct/SPSuccinct.h>

// set to 0 to debug without Internet connection
#define HC_WITH_GAMEKIT 0

@interface WorldMasterClient () <TCAsyncHashProtocolDelegate>
// only one of these will be set
@property(strong) AsyncSocket *sck;
@property(strong) TCAsyncHashProtocol *proto;

@property(nonatomic,readwrite,strong) GKLocalPlayer *authenticatedPlayer;
@property(strong) NSString *authenticatedPlayerId;
@property(nonatomic,readwrite,strong) WorldGameClient *currentGame;
@property(nonatomic,readwrite,getter=isConnected) BOOL connected;
@property(nonatomic,readwrite,copy) NSString *debugStatus;
-(void)connect;
@end

@interface HCMockLocalPlayer : NSObject
@property(strong) NSString *alias;
@property(strong) NSString *playerID;
@end
@implementation HCMockLocalPlayer
@synthesize alias, playerID;
@end

@interface WorldListedGame ()
@property(readwrite) NSString *owner;
@property(readwrite) NSString *name;
@property(readwrite) NSString *identifier;
@end

@implementation WorldMasterClient {
	NSTimeInterval _retryDelay;
	NSMutableArray *_publicGames;
    NSInteger _lastTriedMasterHostIndex;
}
@synthesize sck = _sck, proto = _proto;
@synthesize connected = _connected;
@synthesize delegate = _delegate;
@synthesize authenticatedPlayer = _authenticatedPlayer;
@synthesize authenticatedPlayerId = _authenticatedPlayerId;
@synthesize currentGame = _currentGame;

-(id)initWithDelegate:(id<WorldMasterClientDelegate>)delegate;
{
	if(!(self = [super init])) return nil;
    
    self.delegate = delegate;
	
	_retryDelay = .5; // short delay until we've iterated all the servers
	_publicGames = [NSMutableArray new];
    
    [self updateDebugStatus:@"Idle."];
	
	[self connect];
	
	return self;
}
-(void)dealloc;
{
	_sck.delegate = nil;
	[_sck disconnect];	
}

- (void)updateDebugStatus:(NSString*)status
{
    NSLog(@"WorldMasterClient: %@", status);
    self.debugStatus = status;
}

-(NSArray*)publicGames;
{
	return _publicGames;
}

#pragma mark Game Center
-(void)connectToGameCenter;
{
    [self updateDebugStatus:@"Connecting to Game Center…"];
#if HC_WITH_GAMEKIT
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];
    [player authenticateWithCompletionHandler:^(NSError *error) { dispatch_async(dispatch_get_main_queue(), ^{
        
        // Switched user or authentication expired?
        if(![self.authenticatedPlayerId isEqual:player.playerID] || !player.authenticated) {
            [_sck disconnect]; [_proto.socket disconnect];
        }

        // Successfully logged in (again)?
        if(player.authenticated) {
            self.authenticatedPlayer = player;
            self.authenticatedPlayerId = player.playerID;
            [self connect]; // reconnects if we disconnected above
            return;
        } 
        
        // Some kind of failure. Reconnect as soon as you can.
        [self updateDebugStatus:$sprintf(@"Failed Game Center connection: %@. Reconnecting in %.0f…", [error localizedDescription], _retryDelay)];
        [self performSelector:@selector(connect) withObject:nil afterDelay:_retryDelay];
    }); }];
#else
    HCMockLocalPlayer *player = [HCMockLocalPlayer new]; player.alias = [UIDevice currentDevice].name; player.playerID = [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
    self.authenticatedPlayer = (id)player;
    self.authenticatedPlayerId = player.playerID;
    [self connect];
#endif
}


#pragma mark Socket and connection establishment

-(void)connect;
{
	if(_sck || _proto) return;
    if(!_authenticatedPlayer) {
        [self connectToGameCenter];
        return;
    }
	
	self.sck = [[AsyncSocket alloc] initWithDelegate:self];
    
    /*++_lastTriedMasterHostIndex;
    if(_lastTriedMasterHostIndex >= _masterHosts.count) {
        _lastTriedMasterHostIndex = 0;
        _retryDelay = 5; // tried all the servers: slow down.
    }*/
	int port;
	NSString *host = [_delegate nextMasterHostForMasterClient:self port:&port];
	
    [self updateDebugStatus:$sprintf(@"Connected to GC as %@. Connecting to master at %@:%d…", _authenticatedPlayer.alias, host, port)];
    
	NSError *err = nil;
	BOOL success = [_sck connectToHost:host onPort:port withTimeout:2 error:&err];
    if (!success) {
        [self updateDebugStatus:$sprintf(@"Failed initial connection attempt to %@: %@. Reconnecting in %.0f…", host, err.localizedDescription, _retryDelay)];
        [self performSelector:@selector(connect) withObject:nil afterDelay:_retryDelay];
    }
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
    [self updateDebugStatus:$sprintf(@"Connected to master %@:%d.", host, port)];
    
	self.proto = [[TCAsyncHashProtocol alloc] initWithSocket:_sck delegate:self];
	_proto.autoDispatchCommands = YES;
	self.sck = nil;
	[_proto readHash];
	
    
	[_proto requestHash:$dict(
		@"command", @"clientHello",
		@"name", self.authenticatedPlayer.alias,
        @"playerIdentifier", self.authenticatedPlayer.playerID,
		@"version", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
	) response:^(NSDictionary *response) {
		if([[response objectForKey:@"success"] boolValue]) {
			self.connected = YES;
		} else {
			NSString *reason = [response objectForKey:@"reason"];
			NSString *redirectS = [response objectForKey:@"redirect"];
			NSURL *redirect = redirectS?[NSURL URLWithString:redirectS]:nil;
			
			_retryDelay = [[response objectForKey:@"retryDelay"] intValue] ? : 60*10;
			
			[_delegate masterClient:self wasDisconnectedWithReason:reason redirect:redirect];
			
			[sock disconnect];
		}
	}];
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err;
{
    [self updateDebugStatus:$sprintf(@"Lost connection to master: %@. Reconnecting in %.0fs.", err.localizedDescription, _retryDelay)];
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	self.sck = nil;
	self.proto = nil;
	self.connected = NO;
    if(self.currentGame)
        [_delegate masterClientLeftCurrentGame:self];
	self.currentGame = nil;
	[[self mutableArrayValueForKey:@"publicGames"] removeAllObjects];

	[self performSelector:@selector(connect) withObject:nil afterDelay:_retryDelay];
}

-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash payload:(NSData*)payload;
{
	NSString *selNs = [NSString stringWithFormat:@"command:%@:", [hash objectForKey:kTCCommand]];
	SEL sel = NSSelectorFromString(selNs);
	if([_currentGame respondsToSelector:sel])
		((void(*)(id, SEL, id, id))[_currentGame methodForSelector:sel])(_currentGame, sel, proto, hash);
	else
		NSLog(@"Unexpected server command: %@", hash);
}
-(void)protocol:(TCAsyncHashProtocol*)proto receivedRequest:(NSDictionary*)hash payload:(NSData*)payload responder:(TCAsyncHashProtocolResponseCallback)responder;
{
	NSString *selNs = [NSString stringWithFormat:@"request:%@:responder:", [hash objectForKey:@"command"]];
	SEL sel = NSSelectorFromString(selNs);
	
	if([_currentGame respondsToSelector:sel]) {
		((void(*)(id, SEL, id, id, TCAsyncHashProtocolResponseCallback))[_currentGame methodForSelector:sel])(_currentGame, sel, proto, hash, responder);
	} else {
		NSLog(@"Unexpected server request, disconnecting: %@", hash);
		[_proto.socket disconnect];
	}
}

#pragma mark Incoming commands and requests
-(void)command:(TCAsyncHashProtocol*)proto updateGameList:(NSDictionary*)hash;
{
	NSMutableArray *newGames = [NSMutableArray array];
	for(NSDictionary *gameDesc in [hash objectForKey:@"games"]) {
		WorldListedGame *game = [WorldListedGame new];
		game.name = [gameDesc objectForKey:@"name"];
		game.owner = [gameDesc objectForKey:@"ownerName"];
		game.identifier = [gameDesc objectForKey:@"identifier"];
		[newGames addObject:game];
	}
	[[self mutableArrayValueForKey:@"publicGames"] setArray:newGames];
}
-(void)command:(TCAsyncHashProtocol*)proto joinGame:(NSDictionary*)hash;
{
	self.currentGame = [[WorldGameClient alloc]
		initWithControlProto:self.proto
                       ident:[hash objectForKey:@"identifier"]
				        name:[hash objectForKey:@"name"]
	];
	[_delegate masterClient:self isNowInGame:_currentGame];
}
-(void)command:(TCAsyncHashProtocol*)proto leaveGame:(NSDictionary*)hash;
{
	[_delegate masterClientLeftCurrentGame:self];
	self.currentGame = nil;
}

-(void)command:(TCAsyncHashProtocol*)proto forceDisconnect:(NSDictionary*)hash;
{
    [_delegate masterClient:self wasDisconnectedWithReason:[hash objectForKey:@"reason"] redirect:nil];    
    [proto.socket disconnect];
}

#pragma mark Outgoing commands
-(void)createGameNamed:(NSString*)gameName;
{
	[_proto requestHash:$dict(
		@"command", @"createGame",
		@"gameName", gameName
	) response:^(NSDictionary *response) {
		if([[response objectForKey:@"success"] boolValue]) return;
		
		[_delegate masterClient:self failedGameCreationWithReason:[response objectForKey:@"reason"]];
	}];
}
-(void)joinGameWithIdentifier:(NSString*)identifier;
{
	[_proto requestHash:$dict(
		@"command", @"joinGame",
		@"identifier", identifier
	) response:^(NSDictionary *response) {
		if([[response objectForKey:@"success"] boolValue]) return;
		
		[_delegate masterClient:self failedGameJoinWithReason:[response objectForKey:@"reason"]];
	}];
}

@end

@implementation WorldListedGame
@end