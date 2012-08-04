#import "WorldEntity.h"

@interface ExampleBasket : WorldEntity
@property(nonatomic,WORLD_WRITABLE,retain) NSString *name;
@property(nonatomic,readonly) WORLD_ARRAY *eggs;
@end
