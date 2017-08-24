//
//  DetailViewController.m
//  GameCalc
//
//  Created by Pete Maiser on 10/24/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import "DetailViewController.h"
#import "MasterViewController.h"
#import "Player.h"
#import "PlayerStore.h"
#import "Mode.h"
#import "SettingsStore.h"
#import "LogItem.h"
#import "Log.h"
#import "GameAudioPlayer.h"
#import "GameImageMaker.h"

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) GameAudioPlayer *audioPlayer;
@property (strong, nonatomic) GameImageMaker *imageMaker;
@property (strong, nonatomic) NSMutableArray *sendToPlayerList;
@property (strong, nonatomic) Player *sendToPlayer;

@property (weak, nonatomic) IBOutlet UITableViewCell *addCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *subtractCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *sendCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *photoCell;

@property (weak, nonatomic) IBOutlet UITextField *playerName;
@property (weak, nonatomic) IBOutlet UILabel *playerTagLabel;
@property (weak, nonatomic) IBOutlet UITextField *playerTag;
@property (weak, nonatomic) IBOutlet UITextField *sallaryInDollars;
@property (weak, nonatomic) IBOutlet UITextField *bankAccountInDollars;
@property (weak, nonatomic) IBOutlet UITextField *addDollars;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITextField *subractDollars;
@property (weak, nonatomic) IBOutlet UIButton *subtractButton;
@property (weak, nonatomic) IBOutlet UIPickerView *sendToPlayerName;
@property (weak, nonatomic) IBOutlet UITextField *sendDollars;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

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
    self.audioPlayer = [GameAudioPlayer sharedAudioPlayer];   /* really just starting-up the player so it is ready for the first sound */
    self.imageMaker = [[GameImageMaker alloc] init];
    
    // Set delegatess
    self.playerName.delegate = self;
    self.playerTag.delegate = self;
    self.sallaryInDollars.delegate = self;
    self.bankAccountInDollars.delegate = self;
    self.addDollars.delegate = self;
    self.subractDollars.delegate = self;
    self.sendDollars.delegate = self;
    
    // Select the picker zero row....seems to help the selection indicator to show up
    [self.sendToPlayerName selectRow:0 inComponent:0 animated:NO];
    
    // Add a gesture recognizer to enable dismissing first responders by tapping on the view
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tgr.delegate = self;
    [self.tableView addGestureRecognizer:tgr];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureView];
}

- (void)configureView
{
    // Setup view title and data depending on how it is being used
    
    if (!self.masterViewController) {
        
        // No MVC is setup, so we must have arrived here from a split view vs being called via the segue.
        // This would happen at app startup.  There is nothing to show.
        
        self.navigationItem.title = [NSString stringWithFormat:@""];
        if (self.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible ) {
            self.navigationItem.leftBarButtonItem = nil;
        }
        self.navigationItem.rightBarButtonItem = nil;
        
    } else if (!self.detailPlayer) {
    
        // This must be a new player.  Create the player.
        
        self.navigationItem.title = @"Add Player";
        self.addCell.hidden = YES;
        self.subtractCell.hidden = YES;
        self.sendCell.hidden = YES;
        
        SettingsStore *settings = [SettingsStore sharedStore];
        Player *player = [[PlayerStore sharedStore] createPlayerOfType:settings.selectedMode.playerType];
        
        if (player) {
            self.detailPlayer = player;
        }
        
    } else if (!self.newPlayer) {
        
        // We are using the view for editing an existing player
        
        self.navigationItem.title = self.detailPlayer.playerName;
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        
        [self.bankAccountInDollars setEnabled:NO];
        [self.bankAccountInDollars setTextColor:[UIColor grayColor]];
        
    }
    
    // Set initial values
    if (self.detailPlayer) {
        
        if ( !self.detailPlayer.playerTagLabel ||
             [self.detailPlayer.playerTagLabel isEqualToString:@""]) {
            self.playerTagLabel.text = @"Token";
        } else {
            self.playerTagLabel.text = self.detailPlayer.playerTagLabel;
        }
        
        self.playerName.text = self.detailPlayer.playerName;
        self.playerTag.text = self.detailPlayer.playerTag;
        
        if (self.detailPlayer.salaryInDollars == 0) {
            self.sallaryInDollars.text = @"";
        }
        else {
            self.sallaryInDollars.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithInt:self.detailPlayer.salaryInDollars]];
        }
        
        if (self.detailPlayer.bankAccountInDollars == 0) {
            self.bankAccountInDollars.text = @"";
        }
        else {
            self.bankAccountInDollars.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:self.detailPlayer.bankAccountInDollars]];
        }
        
        if ([[[PlayerStore sharedStore] allPlayers] count] > 1) {
            // There is more than 1 player, so build an array
            // of other possible players to send money to
            // (i.e. not including the current player)
            if (!self.sendToPlayerList) {
                self.sendToPlayerList = [[NSMutableArray alloc] init];
                
                NSArray *players = [[PlayerStore sharedStore] allPlayers];
                NSInteger playerCount = [players count];
                
                for (int i = 0; i < playerCount; i++) {
                    
                    if (players[i] != self.detailPlayer)
                    {
                        [self.sendToPlayerList addObject:players[i]];
                    }
                }
            }
        }
        
        [self setPlaceholders];
        
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.newPlayer) {      // We are using the view for editing an existing player
        NSInteger playerCount = [[[PlayerStore sharedStore] allPlayers] count];
        
        if (playerCount <= 1) {  // This is the only player, so hide the Send View
            self.sendCell.hidden = YES;
        }
        else if (playerCount == 2) {   // if the player count is 2...then select the other player
                [self.sendToPlayerName selectRow:1 inComponent:0 animated:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Clear the first responder
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Alter View Appearance

- (void)clearDetailPlayer
{
    self.navigationItem.title = @"";
    self.playerName.text = @"";
    self.playerTag.text = @"";
    self.sallaryInDollars.text = @"";
    self.bankAccountInDollars.text = @"";
    self.addCell.hidden = YES;
    self.subtractCell.hidden = YES;
    self.sendCell.hidden = YES;
    self.photoCell.hidden = YES;
}

- (void)viewTapped:(UITapGestureRecognizer *)tgr
{
    // Use this code to dismiss Key Pad when the user touches the background
    [self.playerName resignFirstResponder];
    [self.playerTag resignFirstResponder];
    [self.sallaryInDollars resignFirstResponder];
    [self.bankAccountInDollars resignFirstResponder];
    [self.addDollars resignFirstResponder];
    [self.subractDollars resignFirstResponder];
    [self.sendDollars resignFirstResponder];
}


#pragma mark - Navigation

- (IBAction)save:(id)sender
{
    // Change any untouched placeholder values to the actual values
    if ((![self.sallaryInDollars.placeholder isEqualToString:@""]) &&
        ( [self.sallaryInDollars.text isEqualToString:@""]       ))
    {
        self.sallaryInDollars.text = [self.sallaryInDollars.placeholder copy];
    }
    
    // Log the creation of the new player
    if (self.detailPlayer &&
        self.newPlayer )
    {
        Log *sharedLog = [Log sharedLog];
        if (sharedLog) {
            [sharedLog addDivider];
            LogItem *logTextLineFirst = [LogItem logItemWithText:[NSString stringWithFormat:@"Player \"%@\" created: %@"
                                                                  ,self.detailPlayer.playerName
                                                                  ,[self.dateFormatter stringFromDate:self.detailPlayer.dateCreated] ]];
            [sharedLog addItem:logTextLineFirst];
            [sharedLog logTag:self.detailPlayer.playerTag
                       salary:self.detailPlayer.salaryInDollars
                  bankAccount:self.detailPlayer.bankAccountInDollars
                   withPrefix:@""];
            LogItem *logTextLineLast = [LogItem logItemWithText:[NSString stringWithFormat:@"Touch Player Name when ready to play!"] ];
            [sharedLog addItem:logTextLineLast];
            [sharedLog addDivider];
        }
    }
    
    // Refresh Master view, if needed
    if (self.masterViewController.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible ) {
        
        // Clear the other Detail View
        self.masterViewController.selectedDetailController.detailPlayer = nil;
        [self.masterViewController.selectedDetailController clearDetailPlayer];
        
        // If we are adding a player, show the log view (only when in split view)
        if (self.masterViewController.splitViewController.collapsed == NO) {
            if (self.newPlayer) {
                [self.masterViewController showLog:(self)];
            }
        }
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancel:(id)sender
{
    // Remove the Player that was passed to the view
    [[PlayerStore sharedStore] deletePlayer:self.detailPlayer];
    self.detailPlayer = nil;
    
    // Clear the other Detail View, if there is one appearing
    if (self.masterViewController.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible ) {
        self.masterViewController.selectedDetailController.detailPlayer = nil;
        [self.masterViewController.selectedDetailController clearDetailPlayer];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Actions

- (IBAction)add:(id)sender
{
    // It is possible the player may click the "Add" button immediately after changine the salary;
    // if so this should function as a "return" - i.e. record the changed salary
    NSString *unformattedSalary = [self stripString:self.sallaryInDollars.text];
    int salaryInDollarsInteger  = [unformattedSalary intValue];
    if ( !self.newPlayer &&
         self.detailPlayer.salaryInDollars != salaryInDollarsInteger ) {
        
        // Log the change
        NSString *formattedSallary  = [self.numberFormatter stringFromNumber:[NSNumber numberWithInt:salaryInDollarsInteger]];
        LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"%@: changed salary to %@."
                                                         ,self.detailPlayer.playerName
                                                         ,formattedSallary ]];
        Log *sharedLog = [Log sharedLog];
        if (sharedLog) {
            [sharedLog addItem:logTextLine];
        }

        // Record the changed salary
        self.detailPlayer.salaryInDollars = salaryInDollarsInteger;
    }
    
    // If there is a placeholder, consider the placeholder as the actual value if the actual value is blank
    [self setPlaceholders];
    NSString *unformattedPlaceholder = [self stripString:self.addDollars.placeholder];
    
    if ( [unformattedPlaceholder longLongValue] > 0 ) {
        if ( [self.addDollars.text isEqualToString:@""] ) {
            self.addDollars.text = unformattedPlaceholder;
        }
    }

    long long int addDollars = [ [self stripString:self.addDollars.text] longLongValue ];
    
    if (addDollars > 0) {

        // This audio file is used as a public domain work / per rights granted for unlimited use per Myoung8~commonswiki (https://commons.wikimedia.org)
        if (self.audioPlayer) {
            [self.audioPlayer playMPEG4:@"CashRegister.Myoung8.commonswiki"
                            volume:1.0];
        }

        // Record the change
        self.detailPlayer.bankAccountInDollars += addDollars;
        self.bankAccountInDollars.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:self.detailPlayer.bankAccountInDollars]];

        // Refresh Master view, if needed
        if (self.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible ) {
            NSIndexPath *selectedRow = [self.masterViewController.tableView indexPathForSelectedRow];
            [self.masterViewController reloadTable];
            [self.masterViewController.tableView selectRowAtIndexPath:selectedRow
                                                             animated:NO
                                                       scrollPosition:UITableViewScrollPositionNone];
        }
        
        // Log the change
        LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"%@: %@ added to account."
                                                         ,self.detailPlayer.playerName
                                                         ,[self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:addDollars]] ]];
        Log *sharedLog = [Log sharedLog];
        if (sharedLog) {
            [sharedLog addItem:logTextLine];
        }
        
        // Reset
        [self setPlaceholders];
        self.addDollars.text = @"";
        
    }
}

- (IBAction)subract:(id)sender
{
    long long int beforeDollars = self.detailPlayer.bankAccountInDollars;
    long long int subtractDollars = [ [self stripString:self.subractDollars.text] longLongValue];
    
    if (subtractDollars > 0) {
       
        // This audio file recorded by Pete Maiser.  Copywrite 2015.  Authorized for use in this application by PM.
        if (self.audioPlayer) {
            [self.audioPlayer playMPEG4:@"CoinDrop"
                            volume:1.0];
        }
        
        // Record the change
        self.detailPlayer.bankAccountInDollars -= subtractDollars;
        self.bankAccountInDollars.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:self.detailPlayer.bankAccountInDollars]];
    
        // If this gets the player to a negative balance (for the first time), play a sad sound
        if ((self.detailPlayer.bankAccountInDollars < 0) &&
            (beforeDollars >= 0)) {
            
            // This audio file recorded by Pete Maiser and Kate Maiser.  Copywrite 2015.  Authorized for inclusion into this work, and any derivations thereof, by PM and KM.
            if (self.audioPlayer) {
                [self.audioPlayer queueMPEG4:@"SadSound"
                                 volume:1.0];
            }
        }
        
        // Log the change
        LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"%@: %@ subtracted from account."
                                                         ,self.detailPlayer.playerName
                                                         ,[self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:subtractDollars]] ]];
        Log *sharedLog = [Log sharedLog];
        if (sharedLog) {
            [sharedLog addItem:logTextLine];
        }
        
        // Refresh Master view, if needed
        if (self.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible ) {
            NSIndexPath *selectedRow = [self.masterViewController.tableView indexPathForSelectedRow];
            [self.masterViewController reloadTable];
            [self.masterViewController.tableView selectRowAtIndexPath:selectedRow
                                                             animated:NO
                                                       scrollPosition:UITableViewScrollPositionNone];
        }
        
        // Reset
        self.subractDollars.text = @"";
        
    }
}

- (IBAction)send:(id)sender
{
    long long int beforeDollars = self.detailPlayer.bankAccountInDollars;
    long long int sendDollars = [ [self stripString:self.sendDollars.text] longLongValue ];
    
    if (sendDollars > 0) {

        NSInteger sendToPlayerIndex = [self.sendToPlayerName selectedRowInComponent:0]-1;

        if (sendToPlayerIndex >= 0) {
            
            // Play a sound on behalf of the player getting the money.
            // This audio file recorded by Pete Maiser and Kate Maiser.  Copywrite 2015.  Authorized for inclusion into this work, and any derivations thereof, by PM and KM.
            if (self.audioPlayer) {
                [self.audioPlayer playMPEG4:@"HappySound"
                                volume:1.0];
            }

            // Send the money
            self.detailPlayer.bankAccountInDollars -= sendDollars;
            self.bankAccountInDollars.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:self.detailPlayer.bankAccountInDollars]];
            Player *sendToPlayer = self.sendToPlayerList[sendToPlayerIndex];
            if (sendToPlayer) {
                sendToPlayer.bankAccountInDollars += sendDollars;
            }
            
            // If this gets the player to a negative balance (for the first time), play a sad sound.
            if ((self.detailPlayer.bankAccountInDollars < 0) &&
                (beforeDollars >= 0)) {
                
                // This audio file recorded by Pete Maiser and Kate Maiser.  Copywrite 2015.  Authorized for inclusion into this work, and any derivations thereof, by PM and KM.
                if (self.audioPlayer) {
                    [self.audioPlayer queueMPEG4:@"SadSound"
                                     volume:1.0];
                }
            }
            
            // Log the send
            LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"%@ sent %@ to %@."
                                                             ,self.detailPlayer.playerName
                                                             ,[self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:sendDollars]]
                                                             ,sendToPlayer.playerName ]];
            
            Log *sharedLog = [Log sharedLog];
            if (sharedLog) {
                [sharedLog addItem:logTextLine];
            }
            
            // Refresh Master view, if needed
            if (self.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible ) {
                NSIndexPath *selectedRow = [self.masterViewController.tableView indexPathForSelectedRow];
                [self.masterViewController reloadTable];
                [self.masterViewController.tableView selectRowAtIndexPath:selectedRow
                                                                 animated:NO
                                                           scrollPosition:UITableViewScrollPositionNone];
            }
            
            // Reset: set the picker back to the default
            self.sendDollars.text = @"";
            [self.sendToPlayerName selectRow:0
                                 inComponent:0
                                    animated:YES];
        }
    }
}

- (IBAction)setPlayerPhoto:(id)sender
{
    UIImagePickerController * imageController = [[UIImagePickerController alloc] init];
    imageController.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"Choose a player photo from the photo library, or take a picture.  Photo will appear in the Players view."
                                                                preferredStyle:UIAlertControllerStyleAlert];
       
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        if (alert && cancelAction) {
            [alert addAction:cancelAction];
        }
        
        UIAlertAction* libraryAction = [UIAlertAction actionWithTitle:@"Photo Library"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) { [self popPhotoLibrary:imageController]; }];
        
        if (alert && libraryAction) {
            [alert addAction:libraryAction];
        }
        
        UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Take Picture"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) { [self popCamera:imageController]; }];
        if (alert && cameraAction) {
            [alert addAction:cameraAction];
        }
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self popPhotoLibrary:imageController];
    }
}

- (void)popPhotoLibrary:(UIImagePickerController *)controller
{
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)popCamera:(UIImagePickerController *)controller
{
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:controller animated:YES completion:NULL];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.hidden) {
        return 0;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


#pragma mark - UI Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return ([self.sendToPlayerList count] +1);
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (row <= 0) {
        return @"";
    }
    else {
        Player *player = self.sendToPlayerList[row-1];
        return [player playerName];
    }
}


#pragma mark - Text Fields

- (void)setPlaceholders
{
    NSString *unformattedSalary = [self stripString:self.sallaryInDollars.text];
    
    if ([unformattedSalary intValue] != 0) {
        
        self.addDollars.placeholder = self.sallaryInDollars.text;
    }
}

- (NSString *)stripString:(NSString *)string
{
    NSString *strippedString = [ [[[[[string stringByReplacingOccurrencesOfString:@"$" withString:@""]
                                      stringByReplacingOccurrencesOfString:@"," withString:@""]
                                      stringByReplacingOccurrencesOfString:@"M" withString:@"000000"]
                                      stringByReplacingOccurrencesOfString:@"K" withString:@"000"]
                                      stringByReplacingOccurrencesOfString:@"m" withString:@"000000"]
                                      stringByReplacingOccurrencesOfString:@"k" withString:@"000"];
    
    return strippedString;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.sallaryInDollars) {
        NSString *unformattedSalary = [self stripString:self.sallaryInDollars.text];
        self.sallaryInDollars.text = unformattedSalary;
    }
    else if (textField == self.bankAccountInDollars) {
        NSString *unformattedBankAccount = [self stripString:self.bankAccountInDollars.text];
        self.bankAccountInDollars.text = unformattedBankAccount;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    Log *sharedLog = [Log sharedLog];
    
    if (textField == self.playerName) {
        
        // Log the change first (if a change)
        if ( !self.newPlayer &&
             ![self.detailPlayer.playerName isEqualToString:self.playerName.text] ) {
            
            LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"Player \"%@\" changed name to \"%@\"."
                                                             ,self.detailPlayer.playerName
                                                             ,self.playerName.text ]];
            if (sharedLog) {
                [sharedLog addItem:logTextLine];
            }
        }
        
        // Record the name
        self.navigationItem.title = self.playerName.text;
        self.detailPlayer.playerName = self.playerName.text;
        
        // Refresh Master view
        NSIndexPath *selectedRow = [self.masterViewController.tableView indexPathForSelectedRow];
        [self.masterViewController reloadTable];
        [self.masterViewController.tableView selectRowAtIndexPath:selectedRow
                                                         animated:NO
                                                   scrollPosition:UITableViewScrollPositionNone];
    }
    else if (textField == self.playerTag) {
        
        // Log the change first (if a change)
        if ( !self.newPlayer &&
             ![self.detailPlayer.playerTag isEqualToString:self.playerTag.text] ) {
            
            LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"%@: changed tag to %@."
                                                             ,self.detailPlayer.playerName
                                                             ,self.playerTag.text ]];
            if (sharedLog) {
                [sharedLog addItem:logTextLine];
            }
        }
        
        // Record the tag value
        self.detailPlayer.playerTag =  self.playerTag.text;
        
        // Refresh Master view
        NSIndexPath *selectedRow = [self.masterViewController.tableView indexPathForSelectedRow];
        [self.masterViewController reloadTable];
        [self.masterViewController.tableView selectRowAtIndexPath:selectedRow
                                                         animated:NO
                                                   scrollPosition:UITableViewScrollPositionNone];
    }
    else if (textField == self.sallaryInDollars) {
        
        NSString *unformattedSalary = [self stripString:self.sallaryInDollars.text];
        int salaryInDollarsInteger  = [unformattedSalary intValue];
        NSString *formattedSallary  = [self.numberFormatter stringFromNumber:[NSNumber numberWithInt:salaryInDollarsInteger]];
        
        // Log the change first (if a change)
        if ( !self.newPlayer &&
             self.detailPlayer.salaryInDollars != salaryInDollarsInteger ) {
            
            LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"%@: changed salary to %@."
                                                             ,self.detailPlayer.playerName
                                                             ,formattedSallary ]];
            if (sharedLog) {
                [sharedLog addItem:logTextLine];
            }
        }
        
        // Record the salary
        self.sallaryInDollars.text = formattedSallary;
        self.detailPlayer.salaryInDollars = salaryInDollarsInteger;
        
        // Refresh placeholders
        [self setPlaceholders];
        
    }
    else if (textField == self.bankAccountInDollars) {
        
        NSString *unformattedBankAccount           = [self stripString:self.bankAccountInDollars.text];
        long long int bankAccountInDollarsLongLong = [unformattedBankAccount longLongValue];
        NSString *formattedBankAccount             = [self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:[unformattedBankAccount longLongValue]]];
        
        // Record the bank account
        self.bankAccountInDollars.text = formattedBankAccount;
        self.detailPlayer.bankAccountInDollars = bankAccountInDollarsLongLong;
    }
    
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.addDollars) {
        [self add:self];
    } else if (textField == self.subractDollars) {
        [self subract:self];
    } else if (textField == self.sendDollars) {
        [self send:self];
    }
    
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - UI Image Picker View

- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get picked image and set it as the picked image
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (image) {
        
        Player *player = self.detailPlayer;
        
        player.playerImage = [self.imageMaker makeSquareImage:image size:54];
        
        if (!self.newPlayer) {
            LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"%@ set a player photo."
                                                             ,player.playerName]];
            Log *sharedLog = [Log sharedLog];
            [sharedLog addItem:logTextLine];
        }
        
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
