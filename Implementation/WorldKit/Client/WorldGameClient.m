#import "_WorldGameClient.h"
#import "_WorldContainer.h"
#import "WorldGamePlayer.h"
#import "TCAsyncHashProtocol.h"
#import <SPSuccinct/SPLowVerbosity.h>
#import "WorldContainerDebugDumper.h"

@interface WorldGameClient () <WorldCounterpartMessaging>
@property(nonatomic,readwrite,copy) NSString *name;
@property(nonatomic,readwrite,strong) WorldGame *game;
@property(nonatomic,readwrite,strong) WorldGamePlayer *me;
@end

@implementation WorldGameClient {
    WorldContainer *_entities;
    TCAsyncHashProtocol *_proto;
    WorldContainerDebugDumper *_dumper;
    
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
	_entities.counterpartMessaging = self;
    _dumper = [[WorldContainerDebugDumper alloc] initWithContainer:_entities to:[NSURL fileURLWithPath:@"/tmp/client.dot"]];
    _proto = proto;
    
    return self;
}

- (void)invalidate;
{
    [_dumper stop];
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

- (void)entity:(WorldEntity *)entity requestsSendingCounterpartCommand:(NSString *)command arguments:(NSDictionary *)args
{
	[_proto sendHash:@{
		@"command": @"counterpartMessage",
		@"counterpartCommand": @"command",
		@"entity": entity.identifier,
		@"arguments": args,
	}];
}

- (void)command:(TCAsyncHashProtocol*)proto counterpartMessage:(NSDictionary*)hash
{
	NSString *identifier = $cast(NSString, hash[@"entity"]);
	NSString *command = $cast(NSString, hash[@"counterpartCommand"]);
	NSDictionary *args = hash[@"arguments"];
	
	WorldEntity *e = [_entities entityForIdentifier:identifier];
	SEL sel = NSSelectorFromString([NSString stringWithFormat:@"command_%@:", command]);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[e performSelector:sel withObject:args];
#pragma clang diagnostic pop
}

@end
