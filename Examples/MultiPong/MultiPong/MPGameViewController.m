#import "MPGameViewController.h"
#import "../PongWorld/MultiPongGame.h"
#import "MPGameView.h"

#import <WorldKit/WorldKit.h>
#import <SPSuccinct/SPSuccinct.h>


@interface MPGameViewController () {
    WorldGameClient *_gameClient;
    MPGameView *_gameView;
	NSTimer *_gameTimer;
}

@end

@implementation MPGameViewController
- (id)initWithGameClient:(WorldGameClient*)gameClient
{
    if (!(self = [super init]))
        return nil;
    
    _gameClient = gameClient;
    
    UIBarButtonItem *leave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(leaveGame)];
    self.navigationItem.leftBarButtonItem = leave;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		self.edgesForExtendedLayout = UIRectEdgeNone;
#endif

	_gameTimer = [NSTimer scheduledTimerWithTimeInterval:1/60. target:self selector:@selector(tick) userInfo:0 repeats:YES];
    
    return self;
}

- (void)stopGame
{
	[_gameTimer invalidate];
    [_gameView stop];
}

- (void)tick
{
	[self.game tick];
}

- (void)leaveGame
{
    // Should show a loading UI while we are waiting to be told to return to the menu.
	[self stopGame];
    [_gameClient leave];
}

- (void)loadView
{
    self.view = _gameView = [[MPGameView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    [self sp_addDependency:@"new game" on:@[SPD_PAIR(_gameClient, game)] target:self action:@selector(gameIsAvailable)];
}
- (void)gameIsAvailable
{
    _gameView.game = $cast(MultiPongGame,_gameClient.game);
}

- (MultiPongGame*)game
{
	return $cast(MultiPongGame, _gameClient.game);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([[touches anyObject] locationInView:self.view].x < self.view.frame.size.width/2.)
		[self.game moveCurrentPlayer:MultiPongMovementLeft];
	else
		[self.game moveCurrentPlayer:MultiPongMovementRight];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.game moveCurrentPlayer:MultiPongMovementStop];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.game moveCurrentPlayer:MultiPongMovementStop];
}


@end
