#import <WorldKit/Shared/Shared.h>

@interface MultiPongPaddle : WorldEntity
@property(nonatomic,WORLD_WRITABLE) CGPoint position;
@property(nonatomic,WORLD_WRITABLE) CGSize size;
@property(nonatomic,WORLD_WRITABLE) CGPoint velocity;
@end
