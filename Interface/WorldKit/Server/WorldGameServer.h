#import <Foundation/Foundation.h>
@class WorldServerPlayer, WorldGame, WorldGamePlayer;

/** The server for a single game. Takes ownership of a player's network sockets
    once she joins.
*/
@interface WorldGameServer : NSObject
/** @param gameClass   A subclass of WorldGame that this sgame will wrap
    @param playerClass A subclass of WorldGamePlayer that will be instantiated
                       when a ServerPlayer joins the game
    @param master      Master server to return to after leaving the game
*/
- (id)initWithGameClass:(Class)gameClass playerClass:(Class)playerClass;
- (WorldGame*)game;
- (WorldGamePlayer*)owner;

// Ends the game and stops its timers. Must be called before it can be deallocated.
- (void)stop;
@end
