#import "WorldEntity+debug.h"
#import <SPSuccinct/SPLowVerbosity.h>

@implementation WorldEntity (Debug)
- (NSString*)dotDescription;
{
    NSMutableString *nsm = [NSMutableString string];
    [nsm appendFormat:@"digraph g {\n"];
    [nsm appendString:self.dot_forSelfAndRecurse];
    [nsm appendString:@"}"];
    return nsm;
}
- (NSString*)dot_forSelfAndRecurse
{
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:self.dot_nodeDesc];
    [lines addObject:self.dot_relationships];
    
    for(NSString *key in [[self class] observableAttributes]) {
        id val = [self valueForKey:key];
        if([val isKindOfClass:[WorldEntity class]])
            [lines addObject:[val dot_forSelfAndRecurse]];
    }
    
    for(NSString *key in [[self class] observableToManyAttributes])
        for (WorldEntity *other in [self valueForKey:key])
            [lines addObject:[other dot_forSelfAndRecurse]];
    
    return [lines componentsJoinedByString:@"\n"];
}
- (NSString*)dot_nodeAttrs
{
    NSMutableArray *fields = [NSMutableArray array];
    [fields addObject:NSStringFromClass([self class])];
    for(NSString *key in [[self class] observableAttributes])
        [fields addObject:$sprintf(@"%@: %@", key, [self valueForKey:key])];
    return [fields componentsJoinedByString:@"|"];
}
- (NSString*)dot_nodeDesc
{
    return $sprintf(@"\"node_%@\" [\n"
        @"\tlabel = \"%@\"\n"
        @"\tshape = record\n"
        @"];\n", self.identifier, self.dot_nodeAttrs
    );
}
- (NSString*)dot_relationships
{
    NSMutableArray *relationships = [NSMutableArray array];
    for(NSString *key in [[self class] observableToManyAttributes]) {
        for (WorldEntity *other in [self valueForKey:key]) {
            [relationships addObject:$sprintf(@"\"node_%@\" -> \"node_%@\" [\n"
                @"\tlabel = \"%@\"\n"
                @" ];",
                self.identifier, other.identifier,
                key
            )];
        }
    }
    return [relationships componentsJoinedByString:@"\n"];
}
@end
