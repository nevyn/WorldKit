#import <Foundation/Foundation.h>
#import "MultiPongServer.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        MultiPongServer *server = [MultiPongServer new];
        
        NSLog(@"MPS started");
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}

