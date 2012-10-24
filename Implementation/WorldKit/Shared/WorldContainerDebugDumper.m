#import "WorldContainerDebugDumper.h"
#import <SPSuccinct/SPSuccinct.h>
#import "WorldEntity+debug.h"

@implementation WorldContainerDebugDumper {
    WorldContainer *_container;
    NSURL *_path;
    NSTimer *_timer;
}
- (id)initWithContainer:(WorldContainer*)container to:(NSURL*)path
{
    if (!(self = [super init]))
        return nil;
    
    _container = container;
    _path = path;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dumpStats) userInfo:0 repeats:YES];
    return self;
}
- (void)dumpStats
{
    WorldEntity *root = [_container.allEntities sp_any:^BOOL(id obj) {
        return [[obj class] isRootEntity];
    }];
    [root.dotDescription writeToURL:_path atomically:NO encoding:NSUTF8StringEncoding error:NULL];
}

- (void)stop;
{
    [_timer invalidate];
}
@end
