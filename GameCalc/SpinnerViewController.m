//
//  SpinnerViewController.m
//  GameCalc
//
//  Created by Pete Maiser on 11/29/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import "SpinnerViewController.h"
#import "MasterViewController.h"
#import "Player.h"
#import "PlayerStore.h"
#import "LogItem.h"
#import "Log.h"
#import "GameAudioPlayer.h"

const NSInteger headerGroupCount  = 1;  // should be set at one  - this is the group at the top that the random spinner never gets up to
const NSInteger topGroupCount     = 1;  // should be set at one  - the random spinner will go back and forth between the "top group" and
                                        // the "bottom group".
const NSInteger middleGroupCount  = 1;  // middle group that the spinner spins through
const NSInteger bottomGroupCount  = 1;  // should be set at one  - the random spinner will go back and forth between the "top group" and
                                        // the "bottom group".
const NSInteger trailerGroupCount = 1;  // should be set at one  - this is the group at the bottom that the random spinner never gets up to

@interface SpinnerViewController () < UINavigationControllerDelegate, UIImagePickerControllerDelegate >

@property (strong, nonatomic) NSArray *dollarList;         // The list of values that the random spinner is spinnning through
@property (strong, nonatomic) NSArray *dollarListDefault;  // The list that the spinner starts with and defaults back to...e.g. "????"
@property (nonatomic) NSInteger dollarListCount;
@property (nonatomic) NSInteger dollarListDefaultCount;
@property (nonatomic) NSInteger dollarListDefaultRow;      // The default row (with the possible default values) that should be chosen within the defaults
@property (nonatomic) NSInteger dollarListDefaultIndex;    // The index (from the top of the spinner) of the default row
@property (weak, nonatomic) IBOutlet UIPickerView *dollarSpinner;
@property (strong, nonatomic) NSMutableArray *sendToPlayerList;
@property (weak, nonatomic) IBOutlet UIPickerView *sendToPlayerName;

@end

@implementation SpinnerViewController

#pragma mark - Managing the View

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup the parameters for the random "spinner" for prize dollars
    if (!self.dollarList) {
        self.dollarList = @[@"$200,000", @"$300,000", @"$400,000", @"$500,000"];
        self.dollarListCount = [self.dollarList count];
    }
    
    if (!self.dollarListDefault) {
        self.dollarListDefault = @[@"?", @"??", @"???", @"??", @"?"];
        self.dollarListDefaultCount = [self.dollarListDefault count];
        self.dollarListDefaultRow = [self dollarListDefaultCount]/2;
    }
    
    self.dollarListDefaultIndex = (headerGroupCount + topGroupCount + middleGroupCount + bottomGroupCount + trailerGroupCount)*[self dollarListCount] + [self dollarListDefaultRow];
    
    // Build an array of players to send money to
    if (!self.sendToPlayerList) {
        
        self.sendToPlayerList = [[NSMutableArray alloc] init];
        
        NSArray *players = [[PlayerStore sharedStore] allPlayers];
        NSInteger playerCount = [players count];
        
        for (int i = 0; i < playerCount; i++) {
            [self.sendToPlayerList addObject:players[i]];
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Put the random spinner into the default position and disable user interaction
    [self.dollarSpinner selectRow:self.dollarListDefaultIndex
                      inComponent:0
                         animated:NO];
    [self.dollarSpinner setUserInteractionEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)spin:(id)sender
{
    NSInteger selectedDollarsIndex = [self.dollarSpinner selectedRowInComponent:0];
    NSInteger randomIndex = arc4random() % [self dollarListCount];
    NSInteger newRowIndex = 0;
    
    if (selectedDollarsIndex >= (headerGroupCount + topGroupCount)*[self dollarListCount]){

        // The spinner is at the "bottom".  Send it up to the top.
        newRowIndex = ((headerGroupCount) * [self dollarListCount] + randomIndex);
    }
    else {
        // The spinner is at the "top".  Send it down to the bottom
        newRowIndex = ((headerGroupCount + topGroupCount + middleGroupCount) * [self dollarListCount] + randomIndex);
    }
    
    GameAudioPlayer *audioPlayer = [GameAudioPlayer sharedAudioPlayer];
    if (audioPlayer) {
        [audioPlayer playSystemSound:@"keyboard_press_clear.caf"
                              volume:1.0];
    }
    
    [self.dollarSpinner selectRow:newRowIndex
                      inComponent:0
                         animated:YES];
}

- (IBAction)send:(id)sender
{
    NSInteger selectedRow = [self.dollarSpinner selectedRowInComponent:0];
    
    if (selectedRow != self.dollarListDefaultIndex) {
        
        NSInteger selectedDollarsIndex = selectedRow % [self dollarListCount];
        
        int sendDollars = [[[self.dollarList[selectedDollarsIndex] stringByReplacingOccurrencesOfString:@"$"
                                                                                             withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""] intValue];
        if (sendDollars > 0) {
            
            NSInteger sendToPlayerIndex = [self.sendToPlayerName selectedRowInComponent:0]-1;
            
            if (sendToPlayerIndex >= 0) {
                
                // This audio file recorded by Pete Maiser and Kate Maiser.  Copywrite 2015.  Authorized for inclusion into this work, and any derivations thereof, by PM and KM.
                GameAudioPlayer *audioPlayer = [GameAudioPlayer sharedAudioPlayer];
                if (audioPlayer) {
                    [audioPlayer playMPEG4:@"HappySound"
                                    volume:1.0];
                }
                
                // "Send" the money
                Player *sendToPlayer = self.sendToPlayerList[sendToPlayerIndex];
                if (sendToPlayer) {
                    sendToPlayer.bankAccountInDollars += sendDollars;
                }
                
                // Log the receiving player as the winner
                LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"%@ won the spin!  %@ added to account."
                                                                 ,sendToPlayer.playerName
                                                                 ,self.dollarList[selectedDollarsIndex] ]];
                Log *sharedLog = [Log sharedLog];
                if (sharedLog) {
                    [sharedLog addItem:logTextLine];
                }
                
                // Refresh Master view, if needed
                if (self.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible ) {
                    [self.masterViewController reloadTable];
                }
                
                // Reset the spinner
                [self.dollarSpinner selectRow:self.dollarListDefaultIndex
                                  inComponent:0
                                     animated:NO];
                [self.sendToPlayerName selectRow:0
                                     inComponent:0
                                        animated:YES];
                
            }
        }
    }
}


#pragma mark - Picker View Delegate, Picker View Data Source for Player Send

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.dollarSpinner) {
        return ((headerGroupCount + topGroupCount + middleGroupCount + bottomGroupCount + trailerGroupCount)*[self dollarListCount] + [self dollarListDefaultCount]);
    
    }
    else if (pickerView == self.sendToPlayerName) {
        return [self.sendToPlayerList count] + 1;
    
    }
    else {
        return 1;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (pickerView == self.dollarSpinner) {
        if (row < (headerGroupCount + topGroupCount + middleGroupCount + bottomGroupCount + trailerGroupCount)*[self dollarListCount]) {
            // Load the set of list values in the spinner
            return (self.dollarList[row % [self dollarListCount]]);
        } else {
            // Load the defaults at the end of the spinner
            return (self.dollarListDefault[row % [self dollarListDefaultCount]]);
        }        
    }
    else if (pickerView == self.sendToPlayerName) {
        if (row <= 0) {
            return @"";
        } else {
            Player *player = self.sendToPlayerList[row-1];
            return [player playerName];
        }

    }
    else {
        return @"?";
    }
}

#pragma mark - Navigation

// None...see storyboard

@end
