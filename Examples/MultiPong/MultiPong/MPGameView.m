#import "MPGameView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MPGameView {
    CADisplayLink *_timer;
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(redraw)];
    [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    return self;
}

- (void)stop
{
    [_timer invalidate];
}

- (void)redraw
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    _game ? [[UIColor blackColor] set] : [[UIColor redColor] set];
    UIRectFill(self.bounds);
    
    for(MultiPongPlayer *player in _game.players) {
        MultiPongPaddle *paddle = player.paddle;
        
        CGRect r = {.size = paddle.size, .origin = paddle.position};
        
        [[UIColor whiteColor] set];
        UIRectFill(r);
    }
    
    MultiPongBall *ball = _game.ball;
    CGRect r = {.size = {ball.size,ball.size}, .origin = { ball.position.x - ball.size/2., ball.position.y - ball.size/2.}};
    
    [[UIColor greenColor] set];
    [[UIBezierPath bezierPathWithOvalInRect:r] fill];
}


@end
