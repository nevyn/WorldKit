#import <UIKit/UIKit.h>
@class WorldGameClient;

@interface MPGameViewController : UIViewController
- (id)initWithGameClient:(WorldGameClient*)gameClient;
- (void)stopGame;
@end
