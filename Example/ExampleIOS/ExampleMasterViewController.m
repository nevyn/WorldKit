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
#import "ExampleBasket.h"

#import <WorldKit/WorldKit.h>
#import <SPSuccinct/SPSuccinct.h>

@interface ExampleMasterViewController () {
    WorldGameClient *_gameClient;
    NSMutableDictionary *_listeners;
}
@end

@implementation ExampleMasterViewController
- (id)initWithGame:(WorldGameClient*)gameClient
{
    if (!(self = [super initWithStyle:UITableViewStylePlain]))
        return nil;
    
    _gameClient = gameClient;
    self.title = gameClient.name;
    
    // Listen to changes in the number of baskets, and when there's a new basket, for the contents of the basket.
    _listeners = [NSMutableDictionary dictionary];
    __weak typeof(self) weakSelf = self;
    [gameClient sp_observe:@"game.baskets" removed:^(ExampleBasket *basket) {
        if (!basket) return;
        
        // Stop listening to this basket's contents
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->_listeners removeObjectForKey:basket.identifier];
        [weakSelf.tableView reloadData];
    } added:^(ExampleBasket *basket) {
        if (!basket) return;
        
        // Start listening to changes in the name of the basket
        id listener = [weakSelf sp_addDependency:nil on:@[basket, @"name"] changed:^(id change){
            [weakSelf.tableView reloadData];
        }];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->_listeners setObject:listener forKey:basket.identifier];
    } initial:YES];
    
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
