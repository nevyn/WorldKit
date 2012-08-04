#define WORLD_WRITABLE_MODEL 1
#import "WorldEntity.h"
#import "NSString+UUID.h"
#import "MARTNSObject.h"
#import "RTProperty.h"
#import "SPFunctional.h"
#import "SPKVONotificationCenter.h"

@interface WorldEntity (HypotheticalParentableEntity)
- (WorldEntity*)parent;
- (void)setParent:(WorldEntity*)parent;
- (void)removeFromParent;
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
    
    for(NSString *toManyKey in [self observableToManyAttributes])
        [self setValue:[NSMutableArray array] forKey:toManyKey];
    
    return self;
}
-(void)awakeFromPublish;
{
    __weak __typeof(self) weakSelf = self;
    NSSet *allAttributes = [[self observableAttributes] setByAddingObjectsFromSet:[self observableToManyAttributes]];
    
    _observations = [allAttributes sp_map:^id(NSString *keyPath) {
        return [self sp_observe:keyPath
            removed:^(WorldEntity *removed)
            {
                if([removed respondsToSelector:@selector(setParent:)] && [removed parent] == weakSelf)
                    [removed setParent:nil];
            }
            added:^(WorldEntity *added)
            {
                if(![added respondsToSelector:@selector(setParent:)]) return;
                if([added parent] == self) return;
                [added removeFromParent];
                [added setParent:self];
            }
        ];
    }];
}
-(void)dealloc;
{
    for(id obs in _observations)
        [obs invalidate];
}

#pragma mark Representations

- (NSDictionary*)rep
{
    return @{};
}
- (void)updateFromRep:(NSDictionary*)rep
{
    // nop
}

#pragma mark Enumerating attributes
- (NSSet*)observableAttributes
{
    return [NSSet setWithArray:[[[[self class] rt_properties] sp_filter:^BOOL(id obj) {
        return [[obj typeEncoding] rangeOfString:@"Array"].location == NSNotFound;
    }] valueForKeyPath:@"name"]];
}
- (NSSet*)observableToManyAttributes
{
    return [NSSet setWithArray:[[[[self class] rt_properties] sp_filter:^BOOL(id obj) {
        return [[obj typeEncoding] rangeOfString:@"Array"].location != NSNotFound;
    }] valueForKeyPath:@"name"]];
}

@end
