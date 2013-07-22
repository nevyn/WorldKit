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
	
	Vector2 *viewScale = [Vector2 vectorWithX:self.frame.size.width y:self.frame.size.height];
    
    for(MultiPongPlayer *player in _game.players) {
        MultiPongPaddle *paddle = player.paddle;
        
        CGRect r = {.size = paddle.size};
		Vector2 *paddleCartesianPosition = paddle.cartesianPosition;
        
        [[UIColor colorWithHue:player.hue saturation:1 brightness:1 alpha:1] set];
		
        UIBezierPath *bzp = [UIBezierPath bezierPathWithRect:r];
		CGAffineTransform transform = CGAffineTransformIdentity;
			transform = CGAffineTransformScale(transform, self.frame.size.width, self.frame.size.height);
			transform = CGAffineTransformTranslate(transform, paddleCartesianPosition.x, paddleCartesianPosition.y);
			transform = CGAffineTransformRotate(transform, paddle.position.x + M_PI/2);
			transform = CGAffineTransformTranslate(transform, -paddle.size.width/2, 0);

		[bzp applyTransform:transform];
		
		[bzp fill];
    }
    
    MultiPongBall *ball = _game.ball;
	Vector2 *ballPosition = [Vector2 vectorWithX:ball.position.x y:ball.position.y];
	CGRect r = (CGRect){
		.origin = [[ballPosition vectorByMultiplyingWithVector:viewScale] vectorBySubtractingScalar:ball.size/2.].point,
		.size = {ball.size, ball.size}
	};
	
	NSLog(@"Ball: %@", NSStringFromCGRect(r));
    
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
