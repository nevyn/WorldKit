#import <WorldKit/Shared/Shared.h>

@interface MultiPongBall : WorldEntity
@property(nonatomic,WORLD_WRITABLE) CGPoint position; // Radial
@property(nonatomic,WORLD_WRITABLE) float size;
@property(nonatomic,WORLD_WRITABLE) CGPoint velocity;
@end
