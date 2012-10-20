#import "WorldEntity.h"

/**
    Base class for the root model object for a single game. Subclass and add
    attributes for a game: current level, root entities, etc. Your players are
    already in here, and will be auto-populated as players join and leave.
*/
@interface WorldGame : WorldEntity
@property(nonatomic,WORLD_WRITABLE,copy) NSString *name;
@property(nonatomic,readonly) WORLD_ARRAY *players;
+ (BOOL)isRootEntity;
@end
