#import "WorldGameClient.h"
#import "WorldContainer.h"
#import "WorldGamePlayer.h"
#import <SPSuccinct/SPLowVerbosity.h>

@interface WorldGameClient ()
@property(nonatomic,readwrite,copy) NSString *name;
@property(nonatomic,readwrite,strong) WorldGame *game;
@property(nonatomic,readwrite,strong) WorldGamePlayer *me;
@end

@implementation WorldGameClient {
    WorldContainer *_entities;
    TCAsyncHashProtocol *_proto;
    
    // needed to know the future game root entity
    NSString *_gameIdentifier;
}

- (id)initWithControlProto:(TCAsyncHashProtocol*)proto ident:(NSString*)ident name:(NSString*)name
{
    if (!(self = [super init]))
        return nil;
    
    self.name = name;
    _gameIdentifier = ident;
    _entities = [[WorldContainer alloc] initWithEntityClassSuffix:@"Client"];
    
    _proto = proto;
    
    return self;
}

- (void)leave
{
    [_proto sendHash:@{
        @"command": @"leaveGame"
    }];
}

- (void)command:(TCAsyncHashProtocol*)proto applyDiff:(NSDictionary*)hash
{
    // TODO: ACK on this
    //NSString *snapshotIdentifier = hash[@"snapshotIdentifier"];
    
    // TODO: Apply interpolation based on this
    //NSTimeInterval timestamp = [hash[@"timestamp"] doubleValue];
    
    NSDictionary *diff = hash[@"diff"];
    [_entities updateFromDeltaRep:diff];
    
    if(!_game) {
        id maybeGame = [_entities entityForIdentifier:_gameIdentifier];
        if(maybeGame)
            self.game = maybeGame;
    }
}

- (void)command:(TCAsyncHashProtocol*)proto thisIsYou:(NSDictionary*)hash
{
    self.me = $cast(WorldGamePlayer,[_entities entityForIdentifier:hash[@"identifier"]]);
    NSAssert(_me != nil, @"Should have gotten the 'me' entity");
}

@end
