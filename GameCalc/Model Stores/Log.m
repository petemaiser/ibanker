//
//  Log.m
//  GameCalc
//
//  Created by Pete Maiser on 3/25/16.
//  Copyright © 2016 Pete Maiser. All rights reserved.
//

#import "Log.h"
#import "LogItem.h"

@interface Log ()
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (nonatomic) NSMutableArray *privateLogItems;
@end

@implementation Log

+ (instancetype)sharedLog
{
    // As a singleton, make the pointer to the store static so that it will always exist
    static Log *sharedLog;
    
    // Check if the shared store already exists; if not create it
    if (!sharedLog) {
        sharedLog = [[self alloc] initPrivate];
    }
    
    return sharedLog;
    
}

- (instancetype)init
{
    // This method should not be used
    [NSException raise:@"Singleton" format:@"Use +[Log sharedLog]"];
    return nil;
}

- (instancetype)initPrivate
{
    
    // This is the real initializer
    self = [super init];
    if (self) {
        
        // First try to retrieve saved players
        NSString * path = [self archivePath];
        _privateLogItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If there is no saved log then start fresh
        if (!_privateLogItems) {
            _privateLogItems = [[NSMutableArray alloc] init];
            
            [self addDivider];
            
            LogItem *logTextTopLine1 = [LogItem logItemWithText:[NSString stringWithFormat:@"iBanker takes the place"] ];
            [_privateLogItems addObject:logTextTopLine1];
            LogItem *logTextTopLine2 = [LogItem logItemWithText:[NSString stringWithFormat:@"of paper money in board games."] ];
            [_privateLogItems addObject:logTextTopLine2];

            [self addDivider];
            
            LogItem *logTextTopLine3 = [LogItem logItemWithText:[NSString stringWithFormat:@"Touch + in the Players"] ];
            [_privateLogItems addObject:logTextTopLine3];
            LogItem *logTextTopLine4 = [LogItem logItemWithText:[NSString stringWithFormat:@"view to create players!"] ];
            [_privateLogItems addObject:logTextTopLine4];
            
            [self addDivider];
            
            LogItem *logTextTopLine5 = [LogItem logItemWithText:[NSString stringWithFormat:@"Touch \u2699 in the players"] ];
            [_privateLogItems addObject:logTextTopLine5];
            LogItem *logTextTopLine6 = [LogItem logItemWithText:[NSString stringWithFormat:@"view to reset players,"] ];
            [_privateLogItems addObject:logTextTopLine6];
            LogItem *logTextTopLine7 = [LogItem logItemWithText:[NSString stringWithFormat:@"or to change other settings"] ];
            [_privateLogItems addObject:logTextTopLine7];
            LogItem *logTextTopLine8 = [LogItem logItemWithText:[NSString stringWithFormat:@"such as starting $."] ];
            [_privateLogItems addObject:logTextTopLine8];
            
            [self addDivider];
            
        }
        
        // Start the numberFormatter
        if (self.numberFormatter == nil) {
            self.numberFormatter = [[NSNumberFormatter alloc] init];
            [self.numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
            [self.numberFormatter setMaximumFractionDigits:0];
        }
        
    }
    
    return self;
}

- (NSArray *)logItems
{
    //Override the getter of all* to return a copy of private *
    return [self.privateLogItems copy];
}

- (void)addItem:(LogItem *)logItem
{
    if (logItem) {
        [self.privateLogItems addObject:logItem];
    }
}

- (void)trimTopItems:(long int)trimCount
{
    NSRange trimRange = NSMakeRange(0, trimCount);
    [self.privateLogItems removeObjectsInRange:trimRange];

    LogItem *logTextLine = [LogItem logItemWithText:[NSString stringWithFormat:@"Oldest %ld lines deleted from log to reduce log size."
                                                     ,trimCount]];
    [self addItem:logTextLine];
}

- (void)addDivider
{
    LogItem *logTextDivder = [LogItem logItemWithText:[NSString stringWithFormat:@"----------------------------------------"]];
    [self addItem:logTextDivder];
}

- (void)logTag:(NSString *)tag
        salary:(int)salary
   bankAccount:(long long int)bankAccount
    withPrefix:(NSString *)prefix
{
    NSString *formattedPrefix;
    
    if ([prefix isEqualToString:@""]) {
        formattedPrefix = [NSString stringWithFormat:@"   %@", prefix];
    } else {
        formattedPrefix = [NSString stringWithFormat:@"   %@ ", prefix];
    }
    
    LogItem *logTextLine2 =  [LogItem logItemWithText:[NSString stringWithFormat:@"%@Tag: %@", formattedPrefix, tag]];
    LogItem *logTextLine3 =  [LogItem logItemWithText:[NSString stringWithFormat:@"%@Salary: %@", formattedPrefix,
                                                       [self.numberFormatter stringFromNumber:[NSNumber numberWithInt:salary]]]];
    LogItem *logTextLine4 =  [LogItem logItemWithText:[NSString stringWithFormat:@"%@Bank Account: %@", formattedPrefix,
                                                       [self.numberFormatter stringFromNumber:[NSNumber numberWithLongLong:bankAccount]]]];
    
    [self addItem:logTextLine2];
    [self addItem:logTextLine3];
    [self addItem:logTextLine4];
    
}

- (NSString *)archivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"log.archive"];
}

- (BOOL)saveLog
{
    // Check if the log is too big, and if so trip some top lines
    long int logItemsCount = [self.privateLogItems count];
    if (logItemsCount > maxItems) {
        [self trimTopItems:(logItemsCount - maxItems)];
    }
    
    // Archive
    NSString *path = [self archivePath];
    return [NSKeyedArchiver archiveRootObject:self.privateLogItems
                                       toFile:path];
}

- (void)encodeWithCoder:( NSCoder *) aCoder
{
    [aCoder encodeObject:self.privateLogItems forKey:@"privateLogItems"];

}

- (instancetype)initWithCoder:( NSCoder *) aDecoder
{
    self = [super init];
    if (self) {
        _privateLogItems = [aDecoder decodeObjectForKey:@"privateLogItems"];
    }
    
    return self;
}

@end
