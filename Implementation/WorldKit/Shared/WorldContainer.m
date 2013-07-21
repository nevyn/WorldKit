#define WORLD_WRITABLE_MODEL 1
#import "_WorldContainer.h"
#import "SPLowVerbosity.h"
#import "SPFunctional.h"
#import "SPKVONotificationCenter.h"

#import <objc/runtime.h>
#import <MAObjCRuntime/MARTNSObject.h>

@interface WorldPublishedEntity : NSObject
@property(nonatomic,strong) WorldEntity *entity;
@property(nonatomic,strong) NSMutableArray *subscriptions;
- (id)initWithEntity:(WorldEntity*)obj;
- (void)invalidate;
@end


@implementation WorldContainer {
    NSMutableDictionary *_entities;
    NSString *_entityClassSuffix;
}
@synthesize counterpartMessaging = _counterpartMessaging;
- (id)initWithEntityClassSuffix:(NSString*)suffix
{
    if (!(self = [super init]))
        return nil;
    _entities = [NSMutableDictionary dictionaryWithCapacity:1000];
    _entityClassSuffix = suffix;
    
    return self;
}

- (WorldEntity*)entityForIdentifier:(NSString*)identifier
{
    return [(WorldPublishedEntity*)[_entities objectForKey:identifier] entity];
}
- (NSSet*)allEntities
{
    return [NSSet setWithArray:[_entities.allValues valueForKeyPath:@"entity"]];
}

- (void)publishEntity:(WorldEntity*)entity
{
    // Already published?
    if ([self entityForIdentifier:entity.identifier])
        return;
    
	WorldPublishedEntity *pub = [[WorldPublishedEntity alloc] initWithEntity:entity];
	[_entities setObject:pub forKey:entity.identifier];
	
	entity.counterpartMessaging = self.counterpartMessaging;
    
    // Switch the class of the object
    NSString *substitutionClassName = [NSString stringWithFormat:@"%@%@", NSStringFromClass([entity class]), _entityClassSuffix];
    Class newClass = NSClassFromString(substitutionClassName);
    if (newClass)
        object_setClass(entity, newClass);
    [entity awakeFromPublish];
    
    // Automatically publish child entities
    __weak __typeof(self) weakSelf = self;
    NSSet *allAttributes = [[[entity class] observableAttributes] setByAddingObjectsFromSet:[[entity class] observableToManyAttributes]];
    [pub.subscriptions addObjectsFromArray:[allAttributes sp_map:^id(NSString *key) {
        return [entity sp_observe:key removed:nil added:^(id added) {
            if ([added isKindOfClass:[WorldEntity class]])
                [weakSelf publishEntity:added];
        } initial:YES];
    }].allObjects];
}
- (void)unpublishEntity:(WorldEntity*)entity
{
	WorldPublishedEntity *pobj = [_entities objectForKey:entity.identifier];
	NSAssert(pobj != nil, @"Wouldn't expect to ever reach this metod with an unpublished object!");
	[pobj invalidate];
    NSLog(@"Destroying %@", pobj);
	[_entities removeObjectForKey:entity.identifier];
}

- (NSDictionary*)rep;
{
    return @{
        @"entities": [_entities sp_map:^id(NSString *key, WorldPublishedEntity *value) {
            NSMutableDictionary *rel = [NSMutableDictionary dictionary];
            for(NSString *relKey in [[[value entity] class] observableToManyAttributes])
                [rel setObject:[[[value entity] valueForKey:relKey] valueForKeyPath:@"identifier"] forKey:relKey];

            return @{
                @"identifier" : value.entity.identifier,
                @"class": NSStringFromClass([value.entity class]),
                @"attributes": [[value entity] rep],
                @"relationships": rel
            };
        }]
    };
}
- (NSDictionary*)diffRep:(NSDictionary*)newRep fromRep:(NSDictionary*)oldRep
{
    NSMutableDictionary *newOrChangedEntities = [NSMutableDictionary dictionaryWithCapacity:[newRep[@"entities"] count]];
    for(NSString *uuid in newRep[@"entities"]) {
        NSDictionary *oldEntRep = oldRep[@"entities"][uuid];
        NSDictionary *newEntRep = newRep[@"entities"][uuid];
        if([newEntRep isEqualToDictionary:oldEntRep])
            continue;
        // TODO: make a smaller delta with just the changes in newEntRep
        [newOrChangedEntities setObject:newEntRep forKey:uuid];
    }

    NSArray *removedEntityIdentifiers = [[oldRep[@"entities"] allKeys] sp_filter:^BOOL(NSString *uuid) {
        return newRep[@"entities"][uuid] == nil;
    }];
    
    if (newOrChangedEntities.count == 0 && removedEntityIdentifiers.count == 0)
        return nil;
    
    return @{
        @"entities": newOrChangedEntities,
        @"removedEntityIdentifiers": removedEntityIdentifiers ?: @[]
    };
}
- (void)updateFromDeltaRep:(NSDictionary*)rep
{
    NSDictionary *entities = rep[@"entities"];
    
    // 1. Create all the entities we need. In case they reference each other,
    //    they need to be in the list of published entities.
    for(NSString *uuid in entities) {
        NSDictionary *definition = entities[uuid];
        NSString *className = definition[@"class"];
        
        WorldEntity *entity = [[_entities objectForKey:uuid] entity];
        if(!entity) {
            Class klass = [[WorldEntity rt_subclasses] sp_any:^BOOL(id obj) {
                return [NSStringFromClass(obj) isEqual:className];
            }];
            if(!klass) {
                [self handleError:[NSString stringWithFormat:@"WARNING!! Remote tried to instantiate %@, which is not an entity.", className] file:__FILE__ line:__LINE__];
                continue;
            }
            entity = [klass new];
            entity.identifier = uuid;
            [self publishEntity:entity];
        }
    }
    
    // 2. Setup attributes and relationships
    for(NSString *uuid in entities) {
        WorldEntity *entity = [[_entities objectForKey:uuid] entity];
        NSDictionary *definition = entities[uuid];
        [self updateEntity:entity fromDefinition:definition];
    }
    
    // 3. Remove killed entities
    for (NSString *uuid in rep[@"removedEntityIdentifiers"])
        [self unpublishEntity:[_entities[uuid] entity]];
}

- (void)updateEntity:(WorldEntity*)entity fromDefinition:(NSDictionary*)definition
{
    // TODO: Add error handling to the unpacking of 'definition'
    
    WorldEntityFetcher fetcher = ^ id (NSString *identifier, Class expectedClass, BOOL allowNil) {
        WorldPublishedEntity *fetched = [_entities objectForKey:identifier];
        if(!fetched && allowNil) return nil;
        
        if(expectedClass && ![fetched.entity isKindOfClass:expectedClass]) {
            [self handleError:[NSString stringWithFormat:@"Unexpected class %@ for identifier %@ (asked for by %@)", fetched.entity.class, identifier, entity.identifier] file:__FILE__ line:__LINE__];
            return nil;
        }
        
        return fetched.entity;
    };
    
    // UPDATE ATTRIBUTES
    NSDictionary *attributes = definition[@"attributes"];
    [entity updateFromRep:attributes fetcher:fetcher];

    // UPDATE TO-MANY RELATIONSHIPS
    NSDictionary *relationships = definition[@"relationships"];
    
	WorldPublishedEntity *published = _entities[entity.identifier];
    for(NSString *key in relationships) {
        if(![published.entity respondsToSelector:NSSelectorFromString(key)]) {
            [self handleError:[NSString stringWithFormat:@"Expected %@ to have attribute %@", published.entity.class, key] file:__FILE__ line:__LINE__];
            return;
        }
        if(![[published.entity valueForKey:key] isKindOfClass:[NSArray class]]) {
            [self handleError:[NSString stringWithFormat:@"Expected %@'s %@ attribute to be to-many", published.entity.class, key] file:__FILE__ line:__LINE__];
            return;
        }
        if(![relationships[key] sp_all:^BOOL(id obj) { return [obj isKindOfClass:[NSString class]]; }]) {
            [self handleError:@"Unexpected class in list of identifiers" file:__FILE__ line:__LINE__];
            return;
        }
        NSArray *newRelationship = [relationships[key] sp_map:^id(id obj) {
            WorldEntity *e = [[_entities objectForKey:obj] entity];
            if(!e) {
                [self handleError:@"Missing local entity" file:__FILE__ line:__LINE__];
                return nil;
            }
            return e;
        }];
        [published.entity setValue:newRelationship forKey:key];
    }
}

- (void)handleError:(NSString*)reason file:(const char*)file line:(int)line
{
    // TODO!! Must handle errors here with disconnections!
    NSLog(@"%s:%d FATAL ERROR: %@ (Should disconnect this player!)", file, line, reason);
}

- (NSArray*)unusedEntities
{
    return [[_entities.allValues sp_filter:^BOOL(WorldPublishedEntity *obj) {
		return ![[[obj entity] class] isRootEntity] && [[obj entity] parent] == nil;
	}] valueForKeyPath:@"entity"];
}
@end


@implementation WorldPublishedEntity
- (id)initWithEntity:(WorldEntity*)obj
{
	if(!(self = [super init])) return nil;
	self.entity = obj;
	self.subscriptions = [NSMutableArray array];
	return self;
}
- (void)invalidate
{
	for(id thing in _subscriptions) [thing invalidate];
    [_subscriptions removeAllObjects];
}
- (void)dealloc
{
	[self invalidate];
}
- (NSString*)description
{
    return $sprintf(@"<Published %@, %lu subs>", self.entity, (unsigned long)self.subscriptions.count);
}
@end
