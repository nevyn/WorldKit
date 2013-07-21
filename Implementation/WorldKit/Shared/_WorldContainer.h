#import <WorldKit/Shared/WorldContainer.h>
#import "_WorldEntity.h"

@interface WorldContainer ()
@property(nonatomic,weak) id<WorldCounterpartMessaging> counterpartMessaging;

- (id)initWithEntityClassSuffix:(NSString*)suffix;

/// Complete world representation
- (NSDictionary*)rep;
/// Delta between `oldrep' and `newRep'. Returns nil if there are no changes.
- (NSDictionary*)diffRep:(NSDictionary*)newRep fromRep:(NSDictionary*)oldRep;

- (void)updateFromDeltaRep:(NSDictionary*)rep;

/// Find entities that are unreferenced. If you just stop referencing an entity in a relation, it won't magically be collected: you need to manually call this and unpublishEntity:.
/// @return Pruned entities
- (NSArray*)unusedEntities;
@end
