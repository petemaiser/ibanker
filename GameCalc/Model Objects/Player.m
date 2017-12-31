//
//  Player.m
//  GameCalc
//
//  Created by Pete Maiser on 10/9/15.
//  Copyright (c) 2015 Pete Maiser. All rights reserved.
//

#import "Player.h"

@implementation Player

+ (Player *)emptyPlayerOfType:(PlayerType)type
{
    
    Player *player;
    player = [[self alloc] init];
    
    if (player) {
        [player resetValuesForType:type];
    }
    
    return player;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _version = 1;
        _playerImage = nil;
        _playerName = @"";
        _playerTag = @"";
        _playerTagLabel = @"";
        _salaryInDollars = 0;
        _bankAccountInDollars = 0;
        _dateCreated = [[NSDate alloc] init];
    }
    
    return self;
}

- (void)resetPlayerWithType:(PlayerType)type
{
    [self resetValuesForType:type];
}

- (void)resetValuesForType:(PlayerType)type
{
    if (self) {
        if (type == defaultType) {
            self.playerTag = @"";
            self.playerTagLabel = @"Token";
            self.salaryInDollars = 0;
            self.bankAccountInDollars = 0;
        } else if (type == BankAccount1500Type){
            self.playerTag = @"";
            self.playerTagLabel = @"Token";
            self.salaryInDollars = 200;
            self.bankAccountInDollars = 1500;
        } else if (type == BankAccount10kType) {
            self.playerTag = @"";
            self.playerTagLabel = @"Career";
            self.salaryInDollars = 0;
            self.bankAccountInDollars = 10000;
        }
        else if (type == BankAccount400kType) {
            self.playerTag = @"";
            self.playerTagLabel = @"Career";
            self.salaryInDollars = 0;
            self.bankAccountInDollars = 400000;
        } else if (type == BankAccount15mType) {
            self.playerTag = @"";
            self.playerTagLabel = @"Token";
            self.salaryInDollars = 2000000;
            self.bankAccountInDollars = 15000000;
        }
    }
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    Player *copy = [[Player alloc] init];
    
    if (copy) {
        copy.version = self.version;
        copy.playerImage = [self.playerImage copy];
        copy.playerName = [self.playerName copy];
        copy.playerTag = [self.playerTag copy];
        copy.playerTagLabel = [self.playerTagLabel copy];
        copy.salaryInDollars = self.salaryInDollars;
        copy.bankAccountInDollars = self.bankAccountInDollars;
    }
    
    return copy;
}

- (void) encodeWithCoder:( NSCoder *) aCoder
{
    [aCoder encodeInt:self.version forKey:@"version"];
    [aCoder encodeObject:self.playerImage forKey:@"playerImage"];
    [aCoder encodeObject:self.playerName forKey:@"playerName"];
    [aCoder encodeObject:self.playerTag forKey:@"playerTag"];
    [aCoder encodeObject:self.playerTagLabel forKey:@"playerTagLabel"];
    [aCoder encodeInt:self.salaryInDollars forKey:@"sallaryInDollars"];
    [aCoder encodeInt64: self.bankAccountInDollars forKey:@"bankAccountInDollars"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
}

- (instancetype) initWithCoder:( NSCoder *) aDecoder
{
    self = [super init];
    if (self) {
        
        _version = [aDecoder decodeIntForKey:@"version"];
        _playerImage = [aDecoder decodeObjectForKey:@"playerImage"];
        _playerName = [aDecoder decodeObjectForKey:@"playerName"];
        _playerTag = [aDecoder decodeObjectForKey:@"playerTag"];
        _playerTagLabel = [aDecoder decodeObjectForKey:@"playerTagLabel"];
        _salaryInDollars = [aDecoder decodeIntForKey:@"sallaryInDollars"];
        _bankAccountInDollars = [aDecoder decodeInt64ForKey:@"bankAccountInDollars"];
        _dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        
    }
    
    return self;
}

- (NSString *)description
{
    NSString *descriptionString = [[NSString alloc] initWithFormat:@"%@, %@ (salary $%d), %lld", self.playerName, self.playerTag, self.salaryInDollars, self.bankAccountInDollars];
    
    return descriptionString;
}

@end
