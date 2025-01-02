//
//  LogItem.m
//  GameCalc
//
//  Created by Pete Maiser on 3/28/16.
//  Copyright © 2016 Pete Maiser. All rights reserved.
//

#import "LogItem.h"

@implementation LogItem

+ (instancetype)logItemWithText:(NSString *)text
{
    LogItem *logItem;
    logItem = [[self alloc] init];
    
    if (logItem) {
        logItem.text = text;
    }
    
    return logItem;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _text = @"";
    }
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LogItem *copy = [[LogItem alloc] init];
    
    if (copy) {
        copy.text = [self.text copy];
    }
    
    return copy;
}

- (void)encodeWithCoder:( NSCoder *) aCoder
{
    [aCoder encodeObject:self.text forKey:@"text"];
}

- (instancetype)initWithCoder:( NSCoder *) aDecoder
{
    self = [super init];
    if (self) {
        _text = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"text"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
