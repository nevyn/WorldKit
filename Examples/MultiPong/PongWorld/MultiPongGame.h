#import <WorldKit/Shared/Shared.h>
#import "MultiPongBall.h"
#import "MultiPongPlayer.h"
#import "MultiPongPaddle.h"

typedef enum {
	MultiPongMovementStop,
	MultiPongMovementLeft,
	MultiPongMovementRight,
} MultiPongMovement;


@interface MultiPongGame : WorldGame
@property(nonatomic,WORLD_WRITABLE) MultiPongBall *ball;
@property(nonatomic,WORLD_WRITABLE) CGSize boardSize;

/** When called from client, signals to server that the sending player wants to move as indicated. */
- (void)moveCurrentPlayer:(MultiPongMovement)movement;

/** When called client-side, updates world with interpolated future values. When called server-side,
	updates the world authoritatively for what should happen next frame. Should be called at 60hz. */
- (void)tick;
@end

/** MultiPongGame automatically becomes a MultiPongGameServer when instantiated server-side. This instance
    will handle server-side game logic for the game. */
@interface MultiPongGameServer : MultiPongGame
@end

static const int kMultiPongServerPort = 13296;