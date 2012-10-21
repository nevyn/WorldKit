#import "WorldEntity+debug.h"
#import <SPSuccinct/SPSuccinct.h>

@implementation WorldEntity (WorldDebug)
- (NSString*)dotDescription;
{
    NSMutableString *nsm = [NSMutableString string];
    [nsm appendFormat:@"digraph g {\ncompound = true;\n"];
    [nsm appendString:[self dot_forSelfAndRecurse:YES]];
    [nsm appendString:@"}"];
    return nsm;
}
- (NSString*)dot_forSelfAndRecurse:(BOOL)showSelf
{
    NSMutableArray *lines = [NSMutableArray array];
    
    // Describe this node
    if(showSelf)
        [lines addObject:self.dot_nodeDesc];
    
    // Recurse into to-one relationships
    for(NSString *key in [[self class] observableAttributes]) {
        id val = [self valueForKey:key];
        if([val isKindOfClass:[WorldEntity class]])
            [lines addObject:[val dot_forSelfAndRecurse:YES]];
    }
    
    // Recurse into to-many relationships    
    for(NSString *key in [[self class] observableToManyAttributes]) {
        NSArray *value = [self valueForKey:key];
        if(value.count == 0) continue;
        NSString *clustername = $sprintf(@"cluster_%@_%@", self.identifier, key);
        [lines addObject:$sprintf(@"subgraph \"%@\" {\n\tranksep = 0; label=\"%@\"\n", clustername, key)];

        for (WorldEntity *other in value)
            [lines addObject:other.dot_nodeDesc];

        // setup order
        if(value.count > 1)
            [lines addObject:[[[value sp_map:^id(id obj) { return $sprintf(@"\"node_%@\"", [obj identifier]); }] componentsJoinedByString:@" -> "] stringByAppendingFormat:@"[style=invis];"]];
        [lines addObject:@"}\n"];
        
        [lines addObject:$sprintf(@"\"node_%@\" -> \"node_%@\" [\n"
            @"\tlhead = \"%@\"\n"
            @" ];",
            self.identifier, [value[0] identifier], clustername
        )];
    }
    
    for(NSString *key in [[self class] observableToManyAttributes]) {
        NSArray *value = [self valueForKey:key];
        for (WorldEntity *other in value)
            [lines addObject:[other dot_forSelfAndRecurse:NO]];
    }
    
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
