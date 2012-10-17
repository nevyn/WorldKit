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
}
@end

@implementation ExampleDetailViewController
- (id)initWithBasket:(ExampleBasket*)basket;
{
    if (!(self = [super initWithStyle:UITableViewStylePlain]))
        return nil;
    
    _basket = basket;
    self.title = basket.name;
    
    [self sp_addDependency:@"Refresh table view when eggs come in" on:@[SPD_PAIR(_basket, eggs)] target:self action:@selector(reload)];
    
    return self;
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
