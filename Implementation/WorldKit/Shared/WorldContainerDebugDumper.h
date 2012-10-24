#import <Foundation/Foundation.h>
#import "WorldContainer.h"

@interface WorldContainerDebugDumper : NSObject
- (id)initWithContainer:(WorldContainer*)container to:(NSURL*)file;
- (void)stop;
@end
