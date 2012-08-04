#import "WorldContainer.h"
#import "SPLowVerbosity.h"
#import "SPFunctional.h"
#import "SPKVONotificationCenter.h"

#import <objc/runtime.h>

@interface WorldPublishedEntity : NSObject
@property(nonatomic,strong) WorldEntity *entity;
@property(nonatomic,strong) NSMutableArray *subscriptions;
- (id)initWithEntity:(WorldEntity*)obj;
@end


@implementation WorldContainer {
    NSMutableDictionary *_entities;
    NSString *_entityClassSuffix;
}
- (id)initWithEntityClassSuffix:(NSString*)suffix
{
    if (!(self = [super init]))
        return nil;
    _entities = [NSMutableDictionary dictionaryWithCapacity:1000];
    _entityClassSuffix = suffix;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dumpStats) userInfo:0 repeats:YES];
    return self;
}
- (void)dumpStats
{
    NSLog(@"Rep: %@", [self rep]);
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
    
    // Switch the class of the object
    NSString *substitutionClassName = [NSString stringWithFormat:@"%@%@", NSStringFromClass([entity class]), _entityClassSuffix];
    Class newClass = NSClassFromString(substitutionClassName);
    if (newClass)
        object_setClass(entity, newClass);
    [entity awakeFromPublish];
    
    // Automatically publish child entities
    __weak __typeof(self) weakSelf = self;
    NSSet *allAttributes = [[entity observableAttributes] setByAddingObjectsFromSet:[entity observableToManyAttributes]];
    [pub.subscriptions addObjectsFromArray:[allAttributes sp_map:^id(NSString *key) {
        return [entity sp_observe:key removed:nil added:^(id added) {
            if ([added isKindOfClass:[WorldEntity class]])
                [weakSelf publishEntity:added];
        }];
    }].allObjects];
}
- (void)unpublishEntity:(WorldEntity*)entity
{
    
}

- (NSDictionary*)rep;
{
    return @{
        @"entities": [_entities sp_map:^id(NSString *key, WorldPublishedEntity *value) {
            NSMutableDictionary *rel = [NSMutableDictionary dictionary];
            for(NSString *relKey in [[value entity] observableToManyAttributes])
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
