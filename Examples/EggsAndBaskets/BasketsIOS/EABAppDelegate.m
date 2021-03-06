//
//  EABAppDelegate.m
//  ExampleIOS
//
//  Created by Joachim Bengtsson on 2012-08-04.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//

#import "EABAppDelegate.h"

#import "EABGameViewController.h"
#import "EABGameChooser.h"

#import "../EABWorld/EABGame.h"
#import <WorldKit/WorldKit.h>

@interface EABAppDelegate () <WorldMasterClientDelegate> {
    WorldMasterClient *_master;
}
@end

@implementation EABAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _master = [[WorldMasterClient alloc] initWithDelegate:self];

    EABGameChooser *masterViewController = [[EABGameChooser alloc] initWithMaster:_master];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark Master client delegate
- (NSString*)nextMasterHostForMasterClient:(WorldMasterClient*)mc port:(int*)port
{
    *port = kExampleServerPort;
    return @"localhost";
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
    EABGameViewController *vc = [[EABGameViewController alloc] initWithGame:gameClient];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

-(void)masterClientLeftCurrentGame:(WorldMasterClient *)mc
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
