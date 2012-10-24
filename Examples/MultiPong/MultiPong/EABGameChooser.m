#import "EABGameChooser.h"
#import <SPSuccinct/SPSuccinct.h>

@interface EABGameChooser () {
    WorldMasterClient *_master;
    NSArray *_data;
}

@end

@implementation EABGameChooser

- (id)initWithMaster:(WorldMasterClient*)master
{
    if(!(self = [super initWithStyle:UITableViewStylePlain]))
        return nil;
    
    _master = master;
    
    [self sp_addDependency:@"Refresh" on:@[SPD_PAIR(master, connected), SPD_PAIR(master, publicGames)] target:self action:@selector(reload)];
    
    
    return self;
}
- (void)reload
{
    if(!_master.connected) {
        _data = @[@"Not connected"];
    } else {
        _data = [_master.publicGames sp_map:^id(id obj) {
            return [obj name];
        }];
    }
    [self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const ident = @"GameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    
    cell.textLabel.text = _data[indexPath.row];
    cell.selectionStyle = _master.connected ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = _master.connected ? [UIColor blackColor] : [UIColor grayColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Should show a loading UI while we are waiting to be told to enter the game
    [_master joinGameWithIdentifier:[_master.publicGames[indexPath.row] identifier]];
}

@end
