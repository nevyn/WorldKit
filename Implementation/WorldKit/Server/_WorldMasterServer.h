#import <WorldKit/Server/WorldMasterServer.h>

@interface WorldMasterServer ()
/// Takes ownership of the player and its socket.
-(void)join:(WorldServerPlayer*)player;
@end