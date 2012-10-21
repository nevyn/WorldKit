#import <WorldKit/Server/WorldGameServer.h>

@interface WorldGameServer ()
/// Takes ownership of the player and its socket. First player to join owns the game.
/// @param leaver When player leaves the game, use this callback to re-add player to lobby
-(void)join:(WorldServerPlayer*)player leaver:(dispatch_block_t)leaver;
@end