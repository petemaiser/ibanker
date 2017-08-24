//
//  MasterViewController.h
//  GameCalc
//
//  Created by Pete Maiser on 10/24/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailViewController;

@interface MasterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) DetailViewController *selectedDetailController;

- (void)loadToolbarItems;
- (void)reloadTable;
- (void)showLog:(id)sender;

@end

