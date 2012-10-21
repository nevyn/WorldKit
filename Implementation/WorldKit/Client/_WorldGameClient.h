#import <Foundation/Foundation.h>
#import <WorldKit/Client/WorldGameClient.h>

@interface WorldGameClient ()
/** Designated initializer
    @param ident The UUID of the root game entity that will come later in an applyDiff
    @param name The name of the game
*/
- (id)initWithControlProto:(TCAsyncHashProtocol*)proto ident:(NSString*)ident name:(NSString*)name;
@end
