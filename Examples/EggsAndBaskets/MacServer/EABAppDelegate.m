//
//  WorldAppDelegate.m
//  WorldKit
//
//  Created by Joachim Bengtsson on 2012-07-19.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//

#import "EABAppDelegate.h"
#import <WorldKit/WorldKit.h>
#import "../EABWorld/EABGame.h"

@interface EABAppDelegate () <WorldMasterServerDelegate>
@end

@implementation EABAppDelegate {
    WorldMasterServer *_master;
    WorldGameServer *_gameServer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self willChangeValueForKey:@"gameServer"];
    _master = [[WorldMasterServer alloc] initListeningOnPort:kExampleServerPort];
    _master.delegate = self;
    NSError *err = nil;
    _gameServer = [_master createGameServerWithParameters:@{WorldMasterServerParamGameName: @"Test game"} error:&err];
    NSAssert(_gameServer != nil, @"Failed game creation: %@", err);
    [_master serveOnlyGame:_gameServer];
    [self didChangeValueForKey:@"gameServer"];
}

- (WorldGameServer*)masterServer:(WorldMasterServer*)master createGameForRequest:(NSDictionary*)dict error:(NSError**)err;
{
    return [[WorldGameServer alloc] initWithGameClass:[EABGame class] playerClass:[WorldGamePlayer class]];
}

@end
