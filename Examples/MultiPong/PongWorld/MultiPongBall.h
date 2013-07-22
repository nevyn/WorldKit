#import <WorldKit/Shared/Shared.h>
#import "Vector2.h"

@interface MultiPongBall : WorldEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *position; // Radial
@property(nonatomic,WORLD_WRITABLE) float size;
@property(nonatomic,WORLD_WRITABLE) Vector2 *velocity;
@end
