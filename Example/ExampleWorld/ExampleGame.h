#import "WorldGame.h"

@interface ExampleGame : WorldGame
@property(nonatomic,readonly) WORLD_ARRAY *baskets;
@end

static const int kExampleServerPort = 12345;