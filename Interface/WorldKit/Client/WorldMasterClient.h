#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "WorldGameClient.h"
@protocol WorldMasterClientDelegate;

@interface WorldMasterClient : NSObject
/// Connects to the master server. Designated initializer.
-(id)initWithDelegate:(id<WorldMasterClientDelegate>)delegate;

/** @property connected
	Whether a link (incl handshake) has been established to the MasterServer.
*/
@property(nonatomic,readonly,getter=isConnected) BOOL connected;
@property(nonatomic,readonly,strong) GKLocalPlayer *authenticatedPlayer;
@property(nonatomic,readonly,strong) WorldGameClient *currentGame;
@property(nonatomic,weak) id<WorldMasterClientDelegate> delegate;
@property(nonatomic,readonly,copy) NSString *debugStatus;

/// A list of public games that the user can ask join
@property(weak, nonatomic,readonly) NSArray *publicGames;

-(void)joinGameWithIdentifier:(NSString*)identifier;
-(void)createGameNamed:(NSString*)gameName;
@end


@protocol WorldMasterClientDelegate <NSObject>
/** The delegate is expected to have a list of servers that we can connect to. When the client
    needs to try a new one, it will ask the client for one. */
- (NSString*)nextMasterHostForMasterClient:(WorldMasterClient*)mc port:(int*)port;

/** The master server forcefully disconnected this client, likely because it is too old.
	If the URL is not nil, display it to the user as a redirect for more information. It will
	likely redirect to AppStore.
*/
-(void)masterClient:(WorldMasterClient*)mc wasDisconnectedWithReason:(NSString*)reason redirect:(NSURL*)url;

-(void)masterClient:(WorldMasterClient *)mc failedGameCreationWithReason:(NSString*)reason;
-(void)masterClient:(WorldMasterClient *)mc failedGameJoinWithReason:(NSString*)reason;

/**
	Your latest game join request was granted: you are now in a game. You must not send
	commands on the master client; interact only with the given WorldGameClient until you leave it.
*/
-(void)masterClient:(WorldMasterClient *)mc isNowInGame:(WorldGameClient*)gameClient;
-(void)masterClientLeftCurrentGame:(WorldMasterClient *)mc;
@end


@interface WorldListedGame : NSObject
@property(readonly) NSString *owner;
@property(readonly) NSString *name;
@property(readonly) NSString *identifier;
@end