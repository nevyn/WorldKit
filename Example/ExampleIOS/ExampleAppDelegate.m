//
//  ExampleAppDelegate.m
//  ExampleIOS
//
//  Created by Joachim Bengtsson on 2012-08-04.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//

#import "ExampleAppDelegate.h"

#import "ExampleMasterViewController.h"
#import "ExampleGameChooserViewController.h"
#import <WorldKit/WorldKit.h>
#import "ExampleWorld/ExampleGame.h"

@interface ExampleAppDelegate () <WorldMasterClientDelegate> {
    WorldMasterClient *_master;
}
@end

@implementation ExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _master = [[WorldMasterClient alloc] initWithDelegate:self];

    ExampleGameChooserViewController *masterViewController = [[ExampleGameChooserViewController alloc] initWithMaster:_master];
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
    ExampleMasterViewController *vc = [[ExampleMasterViewController alloc] initWithGame:gameClient];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)masterClientLeftCurrentGame:(WorldMasterClient *)mc
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
