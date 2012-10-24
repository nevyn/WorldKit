#import <UIKit/UIKit.h>
#import "../PongWorld/MultiPongGame.h"

@interface MPGameView : UIView
- (id)initWithFrame:(CGRect)frame;
- (void)stop;
@property(nonatomic,retain) MultiPongGame *game;
@end
