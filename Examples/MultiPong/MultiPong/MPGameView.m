#import "MPGameView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MPGameView {
    CADisplayLink *_timer;
	UITouch *_latest;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_latest = [touches anyObject];
	if([[touches anyObject] locationInView:self].x < self.frame.size.width/2.)
		[_game moveCurrentPlayer:MultiPongMovementLeft];
	else
		[_game moveCurrentPlayer:MultiPongMovementRight];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([touches anyObject] == _latest)
		[_game moveCurrentPlayer:MultiPongMovementStop];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_game moveCurrentPlayer:MultiPongMovementStop];
}

@end
