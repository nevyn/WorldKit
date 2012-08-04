#import "WorldServerPlayer.h"
#import "TCAsyncHashProtocol.h"
#import <WorldKit/Shared/WorldGamePlayer.h>
#import "NSString+UUID.h"

@implementation WorldServerPlayer
- (id)init
{
    if (!(self = [super init]))
        return nil;
    _snapshots = [NSMutableArray array];
    return self;
}
- (void)leave
{
    [self.representation removeFromParent];
    self.representation = nil;
    if(self.leaver && [_connection.socket isConnected])
        self.leaver();
    self.leaver = nil;
    [self.snapshots removeAllObjects];
}
- (WorldServerSnapshot*)latestAckedSnapshot;
{
    for(WorldServerSnapshot *snapshot in [_snapshots reverseObjectEnumerator]) {
        if (snapshot.acked)
            return snapshot;
    }
    return nil;
}
- (void)ackSnapshotIdentified:(NSString*)identifier
{
    for(WorldServerSnapshot *snapshot in _snapshots) {
        if ([snapshot.identifier isEqual:identifier])
            snapshot.acked = YES;
    }
}
- (WorldServerSnapshot*)addSnapshot:(NSDictionary*)rep
{
    WorldServerSnapshot *snapshot = [WorldServerSnapshot new];
    snapshot.rep = rep;
    snapshot.timestamp = [NSDate timeIntervalSinceReferenceDate];
    snapshot.identifier = [NSString dt_uuid];
    [_snapshots insertObject:snapshot atIndex:0];
    
    if(_snapshots.count == 11)
        [_snapshots removeLastObject];
    return snapshot;
}
@end


@implementation WorldServerSnapshot
@end