#import <WorldKit/Shared/Shared.h>
#import "MultiPongPaddle.h"

@interface MultiPongPlayer : WorldGamePlayer
@property(nonatomic,WORLD_WRITABLE) MultiPongPaddle *paddle;
@property(nonatomic,WORLD_WRITABLE) int score;
- (float)hue;

@end
