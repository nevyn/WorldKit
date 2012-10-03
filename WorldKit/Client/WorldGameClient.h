#import <Foundation/Foundation.h>
#import "TCAsyncHashProtocol.h"

/**
    Client-side end point for a single game. Matches WorldGameServer.
*/
@interface WorldGameClient : NSObject
- (id)initWithControlProto:(TCAsyncHashProtocol*)proto ident:(NSString*)ident name:(NSString*)name;
@end
