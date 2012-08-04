#define WORLD_WRITABLE_MODEL 1
#import "ExampleBasket.h"

@implementation ExampleBasket
- (id)init
{
    if (!(self = [super init]))
        return nil;
    self.name = @"Unnamed basket";
    return self;
}
- (NSDictionary*)rep
{
    return WorldDictAppend([super rep], @{
        @"name": self.name
    });
}
- (void)updateFromRep:(NSDictionary *)rep
{
    [super updateFromRep:rep];
    WorldIf(rep, @"name", ^(id o) { self.name = o; });
}
@end
