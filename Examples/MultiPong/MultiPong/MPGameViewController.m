#import "MPGameViewController.h"
#import "../PongWorld/MultiPongGame.h"
#import "MPGameView.h"

#import <WorldKit/WorldKit.h>
#import <SPSuccinct/SPSuccinct.h>


@interface MPGameViewController () {
    WorldGameClient *_gameClient;
    MPGameView *_gameView;
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
    
    return self;
}

- (void)dealloc
{
    [_gameView stop];
}

- (void)leaveGame
{
    // Should show a loading UI while we are waiting to be told to return to the menu.
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


@end
