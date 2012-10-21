#import <Foundation/Foundation.h>
@class TCAsyncHashProtocol;
@class WorldGame, WorldGamePlayer;

/**
    Client-side end point for a single game. Matches WorldGameServer.
*/
@interface WorldGameClient : NSObject
@property(nonatomic,readonly,copy) NSString *name;
@property(nonatomic,readonly,strong) WorldGame *game;
@property(nonatomic,readonly,strong) WorldGamePlayer *me;

/// Leave this game and return to lobby
- (void)leave;
@end
