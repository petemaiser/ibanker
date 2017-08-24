//
//  MasterViewController.m
//  GameCalc
//
//  Created by Pete Maiser on 10/24/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SettingsViewController.h"
#import "SettingsStore.h"
#import "Player.h"
#import "PlayerStore.h"
#import "LogViewController.h"
#import "LogItem.h"
#import "Log.h"
#import "PlayerCell.h"
#import "InstructionsCell.h"
#import "SpinnerViewController.h"
#import "GameImageMaker.h"

@interface MasterViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) GameImageMaker *gameImageMaker;
@property (nonatomic) BOOL instructionsMode;
@end

@implementation MasterViewController

#pragma mark - Managing the View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure helpers
    
    if (self.numberFormatter == nil) {
        self.numberFormatter = [[NSNumberFormatter alloc] init];
        [self.numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        [self.numberFormatter setMaximumFractionDigits:0];
    }
    
    if (self.dateFormatter == nil) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    self.gameImageMaker = [[GameImageMaker alloc] init];
    
    // Setup the Instructions Cell
    self.instructionsMode = NO;
    UINib *nib = [UINib nibWithNibName:@"InstructionsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"InstructionsCell"];
    
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    self.navigationItem.title = @"Players";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // Reload the toolbar items
    [self loadToolbarItems];

    // Reload table data
    [self reloadTable];
    
    // If no players exist and we are in split screen mode, have the settings view appear as the secondary view
    // If players do exist (in split screen), then select the first player
    if (self.splitViewController.collapsed == NO) {
        if ( [[[PlayerStore sharedStore] allPlayers] count] == 0 ) {
            [self showSettings:(self)];
        } else if (!self.tableView.indexPathForSelectedRow) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionNone];
            [self showDetail:self];
        }
    }

}

- (void)reloadTable
{
    [self.tableView reloadData];
    if ([[[PlayerStore sharedStore] allPlayers] count] > 0) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    
}

- (void)loadToolbarItems
{
    // Add buttons to the toolbar
    NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];
    
    UIImage *gearImage = [[UIImage imageNamed:@"bluegear32.edited.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:gearImage
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showSettings:)];
    if (settingsButton) {
        [toolbarButtons addObject:settingsButton];
    }
    
    UIImage *logImage = [[UIImage imageNamed:@"log28.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *logButton = [[UIBarButtonItem alloc] initWithImage:logImage
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showLog:)];
    if (logButton) {
        [toolbarButtons addObject:logButton];
    }
    
    SettingsStore *settings = [SettingsStore sharedStore];
    if (settings.enabledSpinner) {
        UIImage *spinnerImage = [[UIImage imageNamed:@"bluespinner28.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *spinnerButton = [[UIBarButtonItem alloc] initWithImage:spinnerImage
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(showSpinner:)];
        if (spinnerButton) {
            [toolbarButtons addObject:spinnerButton];
        }
    }
    
    [self.bottomToolbar setItems:toolbarButtons];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Protocols for Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger count = [[[PlayerStore sharedStore] allPlayers] count];
    
    if (count == 0) {
        
        // If we are not in editing mode (i.e. just starting-up), then set instructions mode to YES
        // to load some instruction cells into the otherwise emplty table.  Note that Split-screens
        // will already have some of the instructions showing in the settings view on initial start-up.
        if (!tableView.isEditing) {
            self.instructionsMode = YES;
            if (self.splitViewController.collapsed == YES) {
                count = 3;
            } else {
                count = 1;
            }
        }
    } else {
        self.instructionsMode = NO;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell;
    
    if (self.instructionsMode) {

        InstructionsCell *instructionsCell  = [tableView dequeueReusableCellWithIdentifier:@"InstructionsCell" forIndexPath:indexPath];
        
        switch (indexPath.row) {
                
            case (0):
                instructionsCell.instructionsLabel.text = @"iBanker takes the place\nof paper money in board games.";
                break;
                
            case (1):
                instructionsCell.instructionsLabel.text = @"Touch + to create players!";
                break;
                
            case (2):
                instructionsCell.instructionsLabel.text = @"Touch \u2699 to change settings,\nsuch as starting $.";
                break;
                
            default:
                instructionsCell.instructionsLabel.text = @"";
                break;
        }
        
        cell = instructionsCell;
        
    } else {

        PlayerCell *playerCell = [tableView dequeueReusableCellWithIdentifier:@"Player Cell" forIndexPath:indexPath];

        NSArray *players = [[PlayerStore sharedStore] allPlayers];
        Player *player = players[indexPath.row];

        if ([player playerImage]) {
            playerCell.playerImageView.image = [player playerImage];
        }
        else {
            playerCell.playerImageView.image =  [self.gameImageMaker makeSquareImage:[self.gameImageMaker getImage:@"smiley.png"] size:54];
        }

        playerCell.playerNameLabel.text = [player playerName];
        playerCell.playerTagLabel.text = [player playerTag];
        playerCell.playerMoneyLabel.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:[player bankAccountInDollars]]];
        
        cell = playerCell;

    }
        
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.instructionsMode) {
        return NO;
    } else {
        return YES;
    }

}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    
        NSArray *players = [[PlayerStore sharedStore] allPlayers];
        Player *player = players[indexPath.row];
        
        if (player) {
        
            // Log deletion of the player
            NSDate *dateDeleted = [[NSDate alloc] init];
            Log *sharedLog = [Log sharedLog];
            if (sharedLog) {
                [sharedLog addDivider];
                LogItem *logTextLine1 = [LogItem logItemWithText:[NSString stringWithFormat:@"Player \"%@\" deleted: %@"
                                                                  ,player.playerName
                                                                  ,[self.dateFormatter stringFromDate:dateDeleted] ]];
                [sharedLog addItem:logTextLine1];
                [sharedLog logTag:player.playerTag
                           salary:player.salaryInDollars
                      bankAccount:player.bankAccountInDollars
                       withPrefix:@""];
                [sharedLog addDivider];
            }
            
            // Delete the player from the store and the table
            [[PlayerStore sharedStore] deletePlayer:player];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            // Clean-up the secondary view in a split view controller, if relevant and needed
            UIViewController *secondaryViewController = [[self.splitViewController.viewControllers lastObject] topViewController];
            
            if (self != secondaryViewController) {
                
                if ( [secondaryViewController isMemberOfClass:[DetailViewController class]] ) {
                    
                    DetailViewController *detailViewController = (DetailViewController *)secondaryViewController;

                    if (player == detailViewController.detailPlayer) {
                        
                        //  We are deleting a player that happens to be showing right now in the Detail View.  Clean up a bit.
                        detailViewController.detailPlayer = nil;
                        [detailViewController clearDetailPlayer];
                    }
                    
                }
                else if ( [secondaryViewController isMemberOfClass:[SettingsViewController class]] ) {
                    
                }
                else if ( [secondaryViewController isMemberOfClass:[LogViewController class]] ) {
                    
                    // We just deleted a player; update the log view
                    LogViewController *logViewController = (LogViewController *)secondaryViewController;
                    
                    [logViewController loadLogItems];
                    [logViewController scrollViewToBottom];
                    
                }
                else if ( [secondaryViewController isMemberOfClass:[SpinnerViewController class]] ) {
                    
                }
            }
        }
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
       toIndexPath:(NSIndexPath *)toIndexPath
{
    [[PlayerStore sharedStore] movePlayerAtIndex:fromIndexPath.row
                                        toIndex:toIndexPath.row];
}

#pragma mark - Navigation

- (void)setEditing:(BOOL)editing
          animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)showDetail:(id)sender
{
    [self performSegueWithIdentifier:@"showDetail" sender:sender];
}

- (void)showSettings:(id)sender
{
    [self performSegueWithIdentifier:@"showSettings" sender:sender];
}

- (void)showLog:(id)sender
{
    [self performSegueWithIdentifier:@"showLog" sender:sender];
}

- (void)showSpinner:(id)sender
{
    [self performSegueWithIdentifier:@"showSpinner" sender:sender];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *players = [[PlayerStore sharedStore] allPlayers];
        Player *player = players[indexPath.row];
        
        DetailViewController *dvc = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        if (dvc) {
            self.selectedDetailController = dvc;
            [dvc setDetailPlayer:player];
            dvc.masterViewController = self;
            dvc.newPlayer = NO;
            dvc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        }
        
    }
    else if ([[segue identifier] isEqualToString:@"addPlayer"]) {
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
        
        DetailViewController *dvc= (DetailViewController *)[[segue destinationViewController] topViewController];
        
        if (dvc) {
            dvc.masterViewController = self;
            dvc.newPlayer = YES;
        }
        
    }
    else if ([[segue identifier] isEqualToString:@"showSettings"]) {
        
        SettingsViewController *svc = (SettingsViewController *)[[segue destinationViewController] topViewController];
        
        if (svc) {
            svc.masterViewController = self;
        }
        
    }
    else if ([[segue identifier] isEqualToString:@"showLog"]) {
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
        
    }
    else if ([[segue identifier] isEqualToString:@"showSpinner"]) {
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
        
        SpinnerViewController *svc = (SpinnerViewController *)[[segue destinationViewController] topViewController];
        
        if (svc) {
            svc.masterViewController = self;
        }
        
    }
}

@end
