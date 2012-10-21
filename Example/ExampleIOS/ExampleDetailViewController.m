//
//  ExampleDetailViewController.m
//  ExampleIOS
//
//  Created by Joachim Bengtsson on 2012-08-04.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//

#import "ExampleDetailViewController.h"

#import "ExampleBasket.h"
#import "ExampleEgg.h"
#import <WorldKit/WorldKit.h>
#import <SPSuccinct/SPSuccinct.h>

@interface ExampleDetailViewController () {
    ExampleBasket *_basket;
    NSMutableDictionary *_listeners;
}
@end

@implementation ExampleDetailViewController
- (id)initWithBasket:(ExampleBasket*)basket;
{
    if (!(self = [super initWithStyle:UITableViewStylePlain]))
        return nil;
    
    _basket = basket;
    self.title = basket.name;
    
    // Listen to changes in the number of eggs, and on the shape of eggs
    _listeners = [NSMutableDictionary dictionary];
    __weak typeof(self) weakSelf = self;
    [_basket sp_observe:@"eggs" removed:^(ExampleEgg *egg) {
        if (!egg) return;
        
        // Stop listening to this basket's contents
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->_listeners removeObjectForKey:egg.identifier];
        [weakSelf.tableView reloadData];
    } added:^(ExampleEgg *egg) {
        if (!egg) return;
        
        // Start listening to changes in the name of the basket
        id listener = [weakSelf sp_addDependency:nil on:@[egg, @"shape"] changed:^(id change){
            [weakSelf.tableView reloadData];
        }];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->_listeners setObject:listener forKey:egg.identifier];
    } initial:YES];

    
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _basket.eggs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const ident = @"BasketCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    
    cell.textLabel.text = [_basket.eggs[indexPath.row] shape];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
