//
//  MPAppDelegate.m
//  MultiPong
//
//  Created by Joachim Bengtsson on 2012-10-24.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//

#import "MPAppDelegate.h"
#import <WorldKit/WorldKit.h>
#import "../PongWorld/MultiPongGame.h"
#import "EABGameChooser.h"
#import "MPGameViewController.h"

@interface MPAppDelegate () <WorldMasterClientDelegate> {
    WorldMasterClient *_master;
    UINavigationController *_navigationController;
	NSMutableArray *_masterHosts;
}
@end

@implementation MPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	_masterHosts = [@[@"localhost", @"TheOneill.local"] mutableCopy];

    _master = [[WorldMasterClient alloc] initWithDelegate:self];

    EABGameChooser *masterViewController = [[EABGameChooser alloc] initWithMaster:_master];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.window.rootViewController = _navigationController;


    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark Master client delegate
- (NSString*)nextMasterHostForMasterClient:(WorldMasterClient*)mc port:(int*)port
{
    *port = kMultiPongServerPort;
	NSString *host = [_masterHosts objectAtIndex:0];
	[_masterHosts removeObjectAtIndex:0];
	[_masterHosts addObject:host];
    return host;
}

-(void)masterClient:(WorldMasterClient*)mc wasDisconnectedWithReason:(NSString*)reason redirect:(NSURL*)url
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected!" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    // TODO: Navigate to 'url'
}

-(void)masterClient:(WorldMasterClient *)mc failedGameCreationWithReason:(NSString*)reason
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to create game" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)masterClient:(WorldMasterClient *)mc failedGameJoinWithReason:(NSString*)reason
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to join game" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


-(void)masterClient:(WorldMasterClient *)mc isNowInGame:(WorldGameClient*)gameClient
{
    MPGameViewController *vc = [[MPGameViewController alloc] initWithGameClient:gameClient];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
	if([nav respondsToSelector:@selector(interactivePopGestureRecognizer)])
		nav.interactivePopGestureRecognizer.enabled = NO;
#endif
    [_navigationController presentViewController:nav animated:YES completion:nil];
}

-(void)masterClientLeftCurrentGame:(WorldMasterClient *)mc
{
    [_navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
