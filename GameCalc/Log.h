//
//  Log.h
//  GameCalc
//
//  Created by Pete Maiser on 3/25/16.
//  Copyright © 2016 Pete Maiser. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LogItem;

@interface Log : NSObject

@property (nonatomic, readonly, copy) NSArray *logItems;

+ (instancetype)sharedLog;

- (void)addItem:(LogItem *)logItem;
- (void)addDivider;
- (void)logTag:(NSString *)tag
        salary:(int)salary
   bankAccount:(long long int)bankAccount
    withPrefix:(NSString *)prefix;

- (BOOL)saveLog;

enum
{
    maxItems = 1000
};

@end
