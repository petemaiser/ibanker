//
//  Player.h
//  GameCalc
//
//  Created by Pete Maiser on 10/9/15.
//  Copyright (c) 2015 Pete Maiser. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PlayerType) {
     defaultType
    ,BankAccount1500Type
    ,BankAccount10kType
    ,BankAccount400kType
    ,BankAccount15mType
};

@interface Player : NSObject <NSSecureCoding>

@property (nonatomic) int version;
@property (nonatomic) UIImage *playerImage;
@property (nonatomic, copy) NSString * playerName;
@property (nonatomic, copy) NSString * playerTag;
@property (nonatomic, copy) NSString * playerTagLabel;
@property (nonatomic) int salaryInDollars;
@property (nonatomic) long long int bankAccountInDollars;
@property (nonatomic, readonly, strong) NSDate * dateCreated;

+ (Player *)emptyPlayerOfType:(PlayerType)type;

- (void)resetPlayerWithType:(PlayerType)type;

@end
