#import <WorldKit/Shared/Shared.h>
#import "MultiPongPaddle.h"

typedef struct {
	float start;
	float length;
} MPFloatRange;

@interface MultiPongPlayer : WorldGamePlayer
@property(nonatomic,WORLD_WRITABLE) MultiPongPaddle *paddle;
@property(nonatomic,WORLD_WRITABLE) int score;
@property(nonatomic,WORLD_WRITABLE) MPFloatRange scoringArc;
- (float)hue;
@end
