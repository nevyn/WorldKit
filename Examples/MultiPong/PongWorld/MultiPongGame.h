#import <WorldKit/Shared/Shared.h>
#import "MultiPongBall.h"
#import "MultiPongPlayer.h"
#import "MultiPongPaddle.h"

@interface MultiPongGame : WorldGame
@property(nonatomic,WORLD_WRITABLE) MultiPongBall *ball;
@property(nonatomic,WORLD_WRITABLE) CGSize boardSize;
@end

static const int kMultiPongServerPort = 13296;