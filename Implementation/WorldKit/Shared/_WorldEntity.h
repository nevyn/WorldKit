#import "WorldEntity.h"
@protocol WorldCounterpartMessaging;

@interface WorldEntity ()
@property(nonatomic,weak) id<WorldCounterpartMessaging> counterpartMessaging;
@end


@protocol WorldCounterpartMessaging <NSObject>
@required
- (void)entity:(WorldEntity*)entity requestsSendingCounterpartCommand:(NSString*)command arguments:(NSDictionary*)args;
@end