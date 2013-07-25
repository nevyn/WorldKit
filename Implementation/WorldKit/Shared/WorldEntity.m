#define WORLD_WRITABLE_MODEL 1
#import "_WorldEntity.h"
#import "NSString+UUID.h"
#import "MARTNSObject.h"
#import "RTProperty.h"
#import "SPFunctional.h"
#import "SPKVONotificationCenter.h"
#import <objc/runtime.h>

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
    self.identifier = TCUUID();
    
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
                if([added parent] == weakSelf) return;
                //[added removeFromParent]; // TODO: deal with being in multiple relationships
                added.parent = weakSelf;
                __weak typeof(added) weakAdded = added;
                added.unparenter = ^{
					if([[weakSelf valueForKeyPath:keyPath] isKindOfClass:[NSArray class]])
						[[weakSelf mutableArrayValueForKey:keyPath] removeObject:weakAdded];
					else
						[weakSelf setValue:nil forKey:keyPath];
                };
            }
            initial: YES
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
	static void * key = &key;
	NSSet *attributes = objc_getAssociatedObject(self, key);
	if(!attributes) {
		attributes = [NSSet setWithArray:[[[self _allProperties] sp_filter:^BOOL(id obj) {
			if([[obj name] isEqual:@"parent"])
				return NO;
			NSString *typeEncoding = [obj typeEncoding];
			if(![typeEncoding hasPrefix:@"@"])
				return NO;
			NSString *className = [typeEncoding substringWithRange:NSMakeRange(2, typeEncoding.length-3)];
			Class klass = NSClassFromString(className);
			if(!klass || ![klass isSubclassOfClass:[WorldEntity class]])
				return NO;
			return YES;
		}] valueForKeyPath:@"name"]];
		objc_setAssociatedObject(self, key, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return attributes;
}
+ (NSSet*)observableToManyAttributes
{
	static void * key = &key;
	NSSet *attributes = objc_getAssociatedObject(self, key);
	if(!attributes) {
		attributes = [NSSet setWithArray:[[[self _allProperties] sp_filter:^BOOL(id obj) {
			return [[obj typeEncoding] rangeOfString:@"Array"].location != NSNotFound;
		}] valueForKeyPath:@"name"]];
		objc_setAssociatedObject(self, key, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return attributes;

}

#pragma mark Counterpart communication
- (void)sendCommandToCounterpart:(NSString*)command arguments:(NSDictionary*)args
{
	[self.counterpartMessaging entity:self requestsSendingCounterpartCommand:command arguments:args];
}
@end
