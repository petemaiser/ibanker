//
//  SettingsStore.m
//  RemoteServerMonitor (SettingsList.m), GameCalc
//
//  Created by Pete Maiser on 1/3/16, 3/22/216
//  Copyright © 2016 Pete Maiser. All rights reserved.
//

#import "SettingsStore.h"
#import "Player.h"
#import "Mode.h"

@interface SettingsStore ()
@property (nonatomic) NSMutableArray *privateModes;
@end

@implementation SettingsStore

+ (instancetype)sharedStore
{
    // As a singleton, make the pointer to the store static so that it will always exist
    static SettingsStore *sharedStore;
    
    // Check if the shared store already exists; if not create it
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }

    return sharedStore;
}

- (instancetype)init
{
    // This method should not be used
    [NSException raise:@"Singleton" format:@"Use +[Settings sharedSettings]"];
    return nil;
}

- (instancetype)initPrivate
{
    // This is the real initializer
    self = [super init];
    if (self) {
        
        // Try to retrieve saved settings....each setting at a time
        // If there is no saved setting then setup a default
        
        // Selected Mode
        NSSet *set = [NSSet setWithObjects:[Mode class], [NSString class], nil];
        NSString * pathForMode = [[self archiveDirectory] stringByAppendingPathComponent:@"settings.mode.archive"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:pathForMode];
        NSError *error;
        _selectedMode = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:&error];
        if (!_selectedMode) {
            _selectedMode = [Mode defaultMode];
        }
        
        // Spinner Settings
        NSSet *set2 = [NSSet setWithObjects:[NSNumber class], nil];
        NSString * pathForSpinner = [[self archiveDirectory] stringByAppendingPathComponent:@"settings.spinner.archive"];
        NSData *data2 = [[NSData alloc] initWithContentsOfFile:pathForSpinner];
        NSError *error2;
        NSNumber *enabledSpinner = [NSKeyedUnarchiver unarchivedObjectOfClasses:set2 fromData:data2 error:&error2];
        if (enabledSpinner) {
            _enabledSpinner = [enabledSpinner boolValue];
        } else {
            _enabledSpinner = _selectedMode.defaultSpinnerOn;
        }
 
    }
    return self;
}

- (NSArray *)allModes
{
    // Rebuild the possible modes, if needed
    if (!self.privateModes) {
        self.privateModes = [[NSMutableArray alloc] init];
        
        Mode *mode0 = [Mode defaultMode];
        Mode *mode1 = [Mode modeWithName:@"$1500 Bank Account"
                              playerType:BankAccount1500Type
                        defaultSpinnerOn:NO];
        Mode *mode2 = [Mode modeWithName:@"$10K Bank Account"
                              playerType:BankAccount10kType
                        defaultSpinnerOn:NO];
        Mode *mode3 = [Mode modeWithName:@"$400K Bank Account"
                              playerType:BankAccount400kType
                        defaultSpinnerOn:YES];
        Mode *mode4 = [Mode modeWithName:@"$15M Bank Account"
                              playerType:BankAccount15mType
                        defaultSpinnerOn:NO];
        [self.privateModes addObject:mode0];
        [self.privateModes addObject:mode1];
        [self.privateModes addObject:mode2];
        [self.privateModes addObject:mode3];
        [self.privateModes addObject:mode4];
    }
    
    //Override the getter of allModes to return a copy of private Modes
    return [self.privateModes copy];
}

- (BOOL)saveSettings
{
    return ([self saveMode] && [self saveSpinner]);
}

- (BOOL)saveMode
{
    NSError *error;
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.selectedMode requiringSecureCoding:YES error:&error];
    NSString *path = [[self archiveDirectory] stringByAppendingPathComponent:@"settings.mode.archive"];
    return [data writeToFile:path atomically:YES];
}

- (BOOL)saveSpinner
{
    NSError *error;
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:@(self.enabledSpinner) requiringSecureCoding:YES error:&error];
    NSString *path = [[self archiveDirectory] stringByAppendingPathComponent:@"settings.spinner.archive"];
    return [data writeToFile:path atomically:YES];
}

- (NSString *)archiveDirectory
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return documentDirectory;
}

@end
