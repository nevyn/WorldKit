//
//  EABasketsViewController.h
//  ExampleIOS
//
//  Created by Joachim Bengtsson on 2012-08-04.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WorldGameClient;

@interface EABGameViewController : UITableViewController
- (id)initWithGame:(WorldGameClient*)gameClient;
@end
