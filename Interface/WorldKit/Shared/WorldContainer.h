#import <Foundation/Foundation.h>
#import "WorldEntity.h"

/**
    Holds the list of entities in a game.
*/
@interface WorldContainer : NSObject

- (WorldEntity*)entityForIdentifier:(NSString*)identifier;
- (NSSet*)allEntities;

/** A published entity is one that is known by the network syncing code, and whose representation will be
    synced to clients from servers, and which is allowed to send commands from client to server. You need to manually
    publish at least one root entity. Relations to child entities are then found, and automatically published.
*/
- (void)publishEntity:(WorldEntity*)entity;
/// Unpublish a root entity. Don't call this yourself on a non-root entity: just remove it from its parent instead.
- (void)unpublishEntity:(WorldEntity*)entity;
@end
