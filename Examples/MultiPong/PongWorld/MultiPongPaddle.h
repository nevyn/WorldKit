#import <WorldKit/Shared/Shared.h>
#import "Vector2.h"
#import "BNZLine.h"

@interface MultiPongPaddle : WorldEntity
@property(nonatomic,WORLD_WRITABLE) Vector2 *position;
- (Vector2*)cartesianPosition;
- (BNZLine*)cartesianLine;
@property(nonatomic,WORLD_WRITABLE) CGSize size;
@property(nonatomic,WORLD_WRITABLE) Vector2 *velocity;
@property(nonatomic,WORLD_WRITABLE) Vector2 *acceleration;
@end
