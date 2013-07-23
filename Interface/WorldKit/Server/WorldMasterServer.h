#import <Foundation/Foundation.h>
@class WorldServerPlayer;
@class WorldGameServer;
@protocol WorldMasterServerDelegate;

/** @class HCMasterServer
	Listens for connections, owns games, and all players not in a game.
*/
@interface WorldMasterServer : NSObject
@property(nonatomic,weak) id<WorldMasterServerDelegate> delegate;

- (id)initListeningOnBasePort:(int)port;
- (int)usedListeningPort;

- (WorldGameServer*)createGameServerWithParameters:(NSDictionary*)parameters error:(NSError**)err;
- (void)serveOnlyGame:(WorldGameServer*)server;
@end

@protocol WorldMasterServerDelegate <NSObject>
- (WorldGameServer*)masterServer:(WorldMasterServer*)master createGameForRequest:(NSDictionary*)dict error:(NSError**)err;
@end


extern NSString *WorldMasterServerParamGameName;