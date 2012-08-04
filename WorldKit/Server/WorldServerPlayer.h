#import <Foundation/Foundation.h>
@class WorldGamePlayer;
@class TCAsyncHashProtocol;
@class WorldServerSnapshot;

/** A user, an actor in World, with an associated network
    connection, and an entity representing it in-world. Belongs to a
    specific World Partition (a game or room) that it receives
    updates from. Represented in-game by a specific Entity.
*/
@interface WorldServerPlayer : NSObject
@property(strong) WorldGamePlayer *representation;
@property(strong) NSString *name;
@property(strong) NSString *gameCenterIdentifier;
@property(strong) TCAsyncHashProtocol *connection;

// WorldGameServer properties
@property(copy) dispatch_block_t leaver;
@property(readonly) NSMutableArray *snapshots;
- (WorldServerSnapshot*)latestAckedSnapshot;
- (void)ackSnapshotIdentified:(NSString*)identifier;
- (WorldServerSnapshot*)addSnapshot:(NSDictionary*)rep;
- (void)leave;
@end

@interface WorldServerSnapshot : NSObject
@property(retain) NSDictionary *rep;
@property(copy) NSString *identifier;
@property NSTimeInterval timestamp;
@property BOOL acked;
@end
