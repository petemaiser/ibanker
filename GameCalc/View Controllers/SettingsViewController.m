//
//  SettingsViewController.m
//  GameCalc
//
//  Created by Pete Maiser on 12/19/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import "SettingsViewController.h"
#import "MasterViewController.h"
#import "Mode.h"
#import "SettingsStore.h"
#import "Player.h"
#import "PlayerStore.h"
#import "LogItem.h"
#import "Log.h"
#import "GameAudioPlayer.h"

@interface SettingsViewController ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSArray *modeList;
@property (nonatomic) BOOL playersExist;

@property (weak, nonatomic) IBOutlet UILabel *hintLine1;
@property (weak, nonatomic) IBOutlet UILabel *hintLine2;
@property (weak, nonatomic) IBOutlet UILabel *hintLine3;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UISwitch *enableSpinnerSwitch;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure helper
    
    if (self.dateFormatter == nil) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }

    // Setup the properties
    
    if (!self.modeList) {
        self.modeList = [[SettingsStore sharedStore] allModes];
    }
    
    NSArray *players = [[PlayerStore sharedStore] allPlayers];
    if (players) {
        if ([players count] == 0) {
            self.playersExist = NO;
        } else {
            self.playersExist = YES;
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide/show the help text
    if (self.playersExist) {
        self.hintLine1.text = [NSString stringWithFormat:@"To start a new game:"];
        self.hintLine2.text = [NSString stringWithFormat:@"choose a Mode, then touch"];
        self.hintLine3.text = [NSString stringWithFormat:@"\"Reset Players\""];
    } else {
        self.hintLine1.text = [NSString stringWithFormat:@"To start a game: choose a Mode,"];
        self.hintLine2.text = [NSString stringWithFormat:@"then touch + in the Players view"];
        self.hintLine3.text = [NSString stringWithFormat:@"to create players!"];
        
        // disable the spinner setting...since we will be setting it to the default for the mode later we might as well disable it
        self.enableSpinnerSwitch.enabled = NO;
    }
    
    // Set the reset button, if players exist
    self.resetButton.enabled = self.playersExist;
    
    // Update the display to align with the current settings
    [self refreshSettingsFromStore];
}

- (void)refreshSettingsFromStore
{
    SettingsStore *settings = [SettingsStore sharedStore];
    
    // Set the mode picker to the current mode
    if (settings) {
        NSInteger playerType = settings.selectedMode.playerType;
        NSInteger row = 0;
        for (Mode *mode in self.modeList) {
            if (mode.playerType == playerType) {
                break;
            }
            row++;
        }
        [self.modePicker selectRow:row
                       inComponent:0
                          animated:NO];
        
        // Set the Spinner Switch to match the mode
        [self.enableSpinnerSwitch setOn:settings.enabledSpinner];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Get the mode
    NSInteger selectedRow = [self.modePicker selectedRowInComponent:0];
    Mode *selectedMode = self.modeList[selectedRow];
    
    // Save the mode, but only if there are no players (and therefor no real mode)
    // Otherwise the mode only saves when the "Reset" button is hit
    SettingsStore *settings = [SettingsStore sharedStore];
    if (selectedMode && settings) {
        if (self.playersExist == NO) {
            
            settings.selectedMode = selectedMode;
            
            // Set the the spinner to the default value for that player type and save the setting
            self.enableSpinnerSwitch.on = selectedMode.defaultSpinnerOn;
            [self saveSpinnerSetting:(self)];
        } else {
            
            // Save the spinner setting
            [self saveSpinnerSetting:(self)];
            
            if (settings.selectedMode != selectedMode) {
                
                // Set the mode picker to the current mode, just for fun
                NSInteger playerType = settings.selectedMode.playerType;
                NSInteger row = 0;
                for (Mode *mode in self.modeList) {
                    if (mode.playerType == playerType) {
                        break;
                    }
                    row++;
                }
                [self.modePicker selectRow:row
                               inComponent:0
                                  animated:YES];
            }
        }
    }
}


#pragma mark - Actions

- (IBAction)requestPlayerReset:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Are you sure you want to reset all players?\n\nIf you are in the middle of a game the other players will be upset with you."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* resetAction = [UIAlertAction actionWithTitle:@"Reset Players" style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * action) { [self resetPlayers]; }];
    
    if (alert && resetAction) {
        [alert addAction:resetAction];
    }
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) { [self refreshSettingsFromStore]; }];
    if (alert && cancelAction) {
        [alert addAction:cancelAction];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetPlayers
{
    // Get the mode, in case it changed
    NSInteger selectedRow = [self.modePicker selectedRowInComponent:0];
    Mode *selectedMode = self.modeList[selectedRow];
    
    // Save the Mode
    SettingsStore *settings = [SettingsStore sharedStore];
    if (settings) {
        settings.selectedMode = selectedMode;
    }
    
    // Set the the spinner to the default value for that player type and save the setting
    if (selectedMode) {
        self.enableSpinnerSwitch.on = selectedMode.defaultSpinnerOn;
        [self saveSpinnerSetting:(self)];
    }
    
    // Reset each player to that type
    NSArray *players = [[PlayerStore sharedStore] allPlayers];
    Log *sharedLog = [Log sharedLog];
    
    if (players && sharedLog) {
        for (Player *player in players) {

            [sharedLog addDivider];
            LogItem *logTextLine1 = [LogItem logItemWithText:[NSString stringWithFormat:@"Player \"%@\" reset: %@"
                                                              ,player.playerName
                                                              ,[self.dateFormatter stringFromDate:player.dateCreated] ]];
            
            [sharedLog addItem:logTextLine1];
            [sharedLog logTag:player.playerTag
                       salary:player.salaryInDollars
                  bankAccount:player.bankAccountInDollars
                   withPrefix:@"previous"];
            
            [player resetPlayerWithType:selectedMode.playerType];

            [sharedLog logTag:player.playerTag
                       salary:player.salaryInDollars
                  bankAccount:player.bankAccountInDollars
                   withPrefix:@"new"];
            [sharedLog addDivider];
        
        }
    }
    
    GameAudioPlayer *audioPlayer = [GameAudioPlayer sharedAudioPlayer];
    if (audioPlayer) {
        [audioPlayer playSystemSound:@"shake.caf"
                              volume:1.0];
    }
    
    // Reload the master view
    [self.masterViewController reloadTable];
}

- (IBAction)saveSpinnerSetting:(id)sender
{
    SettingsStore *settings = [SettingsStore sharedStore];
    if (settings ) {
        settings.enabledSpinner = self.enableSpinnerSwitch.on;
    }
    
    // Redraw the master bottom toolbar
    [self.masterViewController loadToolbarItems];
}


#pragma mark - Picker View Delegate, Picker View Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.modePicker) {
        return [self.modeList count];
    }
    else {
        return 1;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    NSString *title = @"?";
    
    if (pickerView == self.modePicker) {
        Mode *mode = self.modeList[row];
        title = mode.name;
    }
    
    return title;
}


#pragma mark - Navigation

// None...see storyboard

@end
