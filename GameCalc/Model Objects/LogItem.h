//
//  LogItem.h
//  GameCalc
//
//  Created by Pete Maiser on 3/28/16.
//  Copyright © 2016 Pete Maiser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogItem : NSObject

@property (nonatomic, copy) NSString *text;

+ (instancetype)logItemWithText:(NSString *)text;

@end
