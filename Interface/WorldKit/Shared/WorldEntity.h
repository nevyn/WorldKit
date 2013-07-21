#import <Foundation/Foundation.h>

// Only implementations of entities, server-side code and internals in WorldKit may edit entities directly.
#if defined(WORLD_WRITABLE_MODEL) && WORLD_WRITABLE_MODEL == 1
#define WORLD_WRITABLE readwrite
#define WORLD_ARRAY NSMutableArray
#else
#define WORLD_WRITABLE readonly
#define WORLD_ARRAY NSArray
#endif

/// Type of block that can get an existing entity from a world container, without a direct connection to it.
typedef id (^WorldEntityFetcher)(NSString *identifier, Class expectedClass, BOOL allowNil);

/** Root class for any denizen in your world: an entity that
    should be synchronized across your clients. */
@interface WorldEntity : NSObject
/// designated initializer
- (id)init;
/** When an entity is being published (implicitly or explicitly), it will look for a class called
    [self class]_Server or [self class]_Client. If one is found, its isa is replaced. After this
    setup is done, -awakeFromPublish is called, and it is now safe to setup KVO. */
- (void)awakeFromPublish;
/// A globally unique identifier for this entity.
@property(nonatomic,WORLD_WRITABLE,copy) NSString *identifier;
/** A complete json-safe representation of this entity's to-one relations and attributes,
    that will be sent from server to client whenever this object updates. Be sure to include
    the key-values from calling [super rep]. */
- (NSDictionary*)rep;

#if WORLD_WRITABLE_MODEL
/** Update entity's internal state based on the values in 'rep'. 'rep'  might have been been
    filtered, and some keys may be missing, if World already knows that you don't need to update their values.
    Note: you must call -[super updateFromRep:] */
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher;

// Break relationship
- (void)removeFromParent;
#endif

/// Inverse of whatever relationship this entity is part of. Automatically populated. Content is undefined if
/// the entity belongs to multiple relationships.
@property(nonatomic,readonly,weak) id parent;

/// An entity class that doesn't need to be owned by another entity to avoid garbage collection
+ (BOOL)isRootEntity;

/** Keys of the things you put in 'rep'. If the values for these keys are WorldEntities, they will be published. Automatically populated if not overridden.*/
+ (NSSet*)observableAttributes;
/** Keys of to-many relations to other WorldEntities. If new entities are added or removed to/from the array
    values for these keys, they will be published/unpublished, and if they have a 'parent' attribute, it will be
    automatically set. To-many attributes are automatically synced and should not be included in 'rep'. */
+ (NSSet*)observableToManyAttributes;

/** Sends an arbitrary, named command to the same entity on "the other side" of network.
	@discussion If called on a server-side entity, the command will be sent to the corresponding
	client-side entity on all clients; if called on a client-side entity, it is sent to the server-side entity.
	This is generally how you do client-to-server communication, where you signal intent, so that the server can
	update the world representation, and signal back to clients by sending back an updated world. It can also be
	used to trigger client-side behavior (a server entity telling a client entity that it should display a particular
	animation, e g).
	
	The command is delivered by constructing a selector of the form -[command_%@:(NSDictionary*)args], where %@ is the
	'command' parameter, and calling it on the counterpart entity object.
	@param command Name of the command. The selector to be called is constructed from this name.
	@param args    An NSDictionary of JSON safe objects to be sent as arguments to the other side.
*/
- (void)sendCommandToCounterpart:(NSString*)command arguments:(NSDictionary*)args;
@end


/// Helper for updating properties based on value in 'key' only if it exists
static void WorldIf(NSDictionary *rep, NSString *key, void(^then)(id o)) {
    id o = [rep objectForKey:key];
    if(o) then(o);
}

static NSMutableDictionary *WorldDictAppend(NSDictionary *parent, NSDictionary *overrides) {
    NSMutableDictionary *pmut = [parent mutableCopy];
    for(id key in overrides)
        [pmut setObject:[overrides objectForKey:key] forKey:key];
    return pmut;
}

#if !TARGET_OS_IPHONE
#define NSStringFromCGPoint(p) NSStringFromPoint(NSPointFromCGPoint(p))
#define CGPointFromString(s) NSPointToCGPoint(NSPointFromString(s))
#define NSStringFromCGSize(sz) NSStringFromSize(NSSizeFromCGSize(sz))
#define CGSizeFromString(s) NSSizeToCGSize(NSSizeFromString(s))
#endif


// TODO: Make Entity Component-based