//
//  ExampleMasterViewController.m
//  ExampleIOS
//
//  Created by Joachim Bengtsson on 2012-08-04.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//

#import "ExampleMasterViewController.h"
#import "ExampleDetailViewController.h"
#import <WorldKit/WorldKit.h>

@interface ExampleMasterViewController () {
    WorldGameClient *_gameClient;
}
@end

@implementation ExampleMasterViewController
- (id)initWithGame:(WorldGameClient*)gameClient
{
    if (!(self = [super initWithStyle:UITableViewStylePlain]))
        return nil;
    
    _gameClient = gameClient;
    
    return self;
}
@end
