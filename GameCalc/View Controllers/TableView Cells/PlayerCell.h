//
//  PlayerCell.h
//  GameCalc
//
//  Created by Pete Maiser on 10/31/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *playerImageView;
@property (weak, nonatomic) IBOutlet UITextField *playerNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *playerTagLabel;
@property (weak, nonatomic) IBOutlet UITextField *playerMoneyLabel;

@end
