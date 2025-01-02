//
//  Mode.m
//  GameCalc
//
//  Created by Pete Maiser on 3/23/16.
//  Copyright © 2016 Pete Maiser. All rights reserved.
//

#import "Mode.h"

@implementation Mode

+ (instancetype)modeWithName:(NSString *)name
                  playerType:(PlayerType)playerType
            defaultSpinnerOn:(BOOL)defaultSpinnerOn
{
    Mode *mode;
    mode = [[self alloc] init];
    
    if (mode) {
        mode.name = name;
        mode.playerType = playerType;
        mode.defaultSpinnerOn = defaultSpinnerOn;
    }
    
    return mode;
}

+ (instancetype)defaultMode
{
    return [self modeWithName:@"default"
                   playerType:defaultType
             defaultSpinnerOn:NO];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _version = 1;
        _name = @"";
        _playerType = 0;
        _defaultSpinnerOn = NO;
    }
        
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    Mode *copy = [[Mode alloc] init];
    
    if (copy) {
        copy.version = self.version;
        copy.name = [self.name copy];
        copy.playerType = self.playerType;
        copy.defaultSpinnerOn = self.defaultSpinnerOn;
    }
    
    return copy;
}

- (void)encodeWithCoder:( NSCoder *) aCoder
{
    [aCoder encodeInt:self.version forKey:@"version"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.playerType forKey:@"playerType"];
    [aCoder encodeBool:self.defaultSpinnerOn forKey:@"defaultSpinnerOn"];
}

- (instancetype)initWithCoder:( NSCoder *) aDecoder
{
    self = [super init];
    if (self) {
        _version = [aDecoder decodeIntForKey:@"version"];
        _name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _playerType = [aDecoder decodeIntegerForKey:@"playerType"];
        _defaultSpinnerOn = [aDecoder decodeBoolForKey:@"defaultSpinnerOn"];
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
