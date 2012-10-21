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

/** Designated initializer
    @param ident The UUID of the root game entity that will come later in an applyDiff
    @param name The name of the game
*/
- (id)initWithControlProto:(TCAsyncHashProtocol*)proto ident:(NSString*)ident name:(NSString*)name;

/// Leave this game and return to lobby
- (void)leave;
@end
