#import "WorldEntity.h"
@class WorldGame;

/**
    Base class for the in-game model object for a player. Might contain
    attributes such as score, avatar, level, etc.
*/
@interface WorldGamePlayer : WorldEntity
@property(nonatomic,WORLD_WRITABLE,strong) NSString *name;
@property(nonatomic,WORLD_WRITABLE,weak) WorldGame *parent;
- (void)removeFromParent;
@end
