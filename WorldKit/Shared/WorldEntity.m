#define WORLD_WRITABLE_MODEL 1
#import "WorldEntity.h"
#import "NSString+UUID.h"
#import "MARTNSObject.h"
#import "RTProperty.h"
#import "SPFunctional.h"
#import "SPKVONotificationCenter.h"

@interface WorldEntity ()
- (void)removeFromParent;
@property(nonatomic,readwrite,weak) id parent;
@property(nonatomic,copy) void(^unparenter)();
@end

@implementation WorldEntity {
    NSSet *_observations;
}
- (id)init
{
    if (!(self = [super init]))
        return nil;
    // Setup a default UUID. Before being published, some external party may override it, but we need a sensible default
    self.identifier = [NSString dt_uuid];
    
    for(NSString *toManyKey in [[self class] observableToManyAttributes])
        [self setValue:[NSMutableArray array] forKey:toManyKey];
    
    return self;
}
-(void)dealloc;
{
    for(id obs in _observations)
        [obs invalidate];
    // TODO: Tear down inverse relationships
}

-(void)awakeFromPublish;
{
    __weak __typeof(self) weakSelf = self;
    NSSet *allAttributes = [[[self class] observableAttributes] setByAddingObjectsFromSet:[[self class] observableToManyAttributes]];
    
    _observations = [allAttributes sp_map:^id(NSString *keyPath) {
        return [self sp_observe:keyPath
            removed:^(WorldEntity *removed)
            {
                if([removed respondsToSelector:@selector(setParent:)] && [removed parent] == weakSelf) {
                    removed.unparenter = nil;
                    removed.parent = nil;
                }
            }
            added:^(WorldEntity *added)
            {
                if(![added respondsToSelector:@selector(setParent:)]) return;
                if([added parent] == weakSelf) return;
                [added removeFromParent];
                added.parent = weakSelf;
                __weak typeof(added) weakAdded = added;
                added.unparenter = ^{
                    // XXX<nevyn>: This won't work for to-one relationships :(
                    [[weakSelf mutableArrayValueForKey:keyPath] removeObject:weakAdded];
                };
            }
        ];
    }];
}

- (void)removeFromParent
{
    if(self.unparenter)
        self.unparenter();
}
+ (BOOL)isRootEntity
{
    return NO;
}

#pragma mark Representations

- (NSDictionary*)rep
{
    return @{};
}
- (void)updateFromRep:(NSDictionary*)rep fetcher:(WorldEntityFetcher)fetcher;
{
    // nop
}

#pragma mark Enumerating attributes
+ (NSMutableArray*)_allProperties
{
    NSMutableArray *props = [NSMutableArray array];
    Class klass = [self class];
    while(klass != [WorldEntity class]) {
        [props addObjectsFromArray:[klass rt_properties]];
        klass = [klass superclass];
    }
    return props;
}
+ (NSSet*)observableAttributes
{
    return [NSSet setWithArray:[[[self _allProperties] sp_filter:^BOOL(id obj) {
        return [[obj typeEncoding] rangeOfString:@"Array"].location == NSNotFound && ![[obj name] isEqual:@"parent"];
    }] valueForKeyPath:@"name"]];
}
+ (NSSet*)observableToManyAttributes
{
    return [NSSet setWithArray:[[[self _allProperties] sp_filter:^BOOL(id obj) {
        return [[obj typeEncoding] rangeOfString:@"Array"].location != NSNotFound;
    }] valueForKeyPath:@"name"]];
}

@end
