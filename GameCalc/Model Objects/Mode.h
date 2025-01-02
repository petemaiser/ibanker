//
//  Mode.h
//  GameCalc
//
//  Created by Pete Maiser on 3/23/16.
//  Copyright © 2016 Pete Maiser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface Mode : NSObject <NSSecureCoding>

@property (nonatomic) int version;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) PlayerType playerType;
@property (nonatomic) BOOL defaultSpinnerOn;

+ (instancetype)modeWithName:(NSString *)name
                  playerType:(PlayerType)playerType
            defaultSpinnerOn:(BOOL)defaultSpinnerOn;

+ (instancetype)defaultMode;

@end
