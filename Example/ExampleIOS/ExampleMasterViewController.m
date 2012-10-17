//
//  ExampleMasterViewController.m
//  ExampleIOS
//
//  Created by Joachim Bengtsson on 2012-08-04.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//

#import "ExampleMasterViewController.h"
#import "ExampleDetailViewController.h"

#import "ExampleGame.h"

#import <WorldKit/WorldKit.h>
#import <SPSuccinct/SPSuccinct.h>

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
    self.title = gameClient.name;
    
    [self sp_addDependency:@"Refresh table view when new games or baskets come in" on:@[gameClient, @"game.baskets"] target:self action:@selector(reload)];
    
    UIBarButtonItem *leave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(leaveGame)];
    self.navigationItem.leftBarButtonItem = leave;
    
    return self;
}

- (void)leaveGame
{
    // Should show a loading UI while we are waiting to be told to return to the menu.
    [_gameClient leave];
}

- (ExampleGame*)game
{
    return (ExampleGame*)[_gameClient game];
}

- (void)reload
{
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.game.baskets.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const ident = @"BasketCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    
    cell.textLabel.text = [self.game.baskets[indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExampleDetailViewController *detail = [[ExampleDetailViewController alloc] initWithBasket:self.game.baskets[indexPath.row]];
    [self.navigationController pushViewController:detail animated:YES];
}

@end
