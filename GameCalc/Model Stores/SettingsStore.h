//
//  SettingsStore.h
//  RemoteServerMonitor (SettingsList.h), GameCalc
//
//  Created by Pete Maiser on 1/3/16, 3/22/216
//  Copyright © 2016 Pete Maiser. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Mode;

@interface SettingsStore : NSObject

@property (nonatomic, readonly, copy) NSArray *allModes;
@property (nonatomic) Mode *selectedMode;
@property (nonatomic) BOOL enabledSpinner;

+ (instancetype)sharedStore;

- (BOOL)saveSettings;

@end
