//
//  DetailViewController.h
//  GameCalc
//
//  Created by Pete Maiser on 10/24/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Player;
@class MasterViewController;

@interface DetailViewController : UITableViewController

@property (weak, nonatomic) MasterViewController *masterViewController;
@property (strong, nonatomic) Player *detailPlayer;
@property (nonatomic) BOOL newPlayer;

- (void)clearDetailPlayer;

@end

