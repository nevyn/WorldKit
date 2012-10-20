#import <Foundation/Foundation.h>
#import "WorldEntity.h"

/**
    Holds the list of entities in a game.
*/
@interface WorldContainer : NSObject
- (id)initWithEntityClassSuffix:(NSString*)suffix;

- (WorldEntity*)entityForIdentifier:(NSString*)identifier;
- (NSSet*)allEntities;

/** A published entity is one that is known by the network syncing code, and whose representation will be
    synced to clients from servers, and which is allowed to send commands from client to server. You need to manually
    publish at least one root entity. Relations to child entities are then found, and automatically published.
*/
- (void)publishEntity:(WorldEntity*)entity;
/// Unpublish a root entity. Don't call this yourself on a non-root entity: just remove it from its parent instead.
- (void)unpublishEntity:(WorldEntity*)entity;

/// Complete world representation
- (NSDictionary*)rep;
/// Delta between `oldrep' and `newRep'. Returns nil if there are no changes.
- (NSDictionary*)diffRep:(NSDictionary*)newRep fromRep:(NSDictionary*)oldRep;

- (void)updateFromDeltaRep:(NSDictionary*)rep;

/// Find entities that are unreferenced. If you just stop referencing an entity in a relation, it won't magically be collected: you need to manually call this and unpublishEntity:.
/// @return Pruned entities
- (NSArray*)unusedEntities;
@end
