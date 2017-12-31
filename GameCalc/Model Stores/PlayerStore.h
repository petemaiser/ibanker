//
//  PlayerStore.h
//  GameCalc
//
//  Created by Pete Maiser on 10/10/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface PlayerStore : NSObject

@property (nonatomic, readonly, copy) NSArray *allPlayers;

+ (instancetype)sharedStore;

- (Player *)createPlayerOfType:(PlayerType)type;
- (void)deletePlayer:(Player *)player;
- (void)movePlayerAtIndex:(NSUInteger)fromIndex
                  toIndex:(NSUInteger)toIndex;

- (BOOL)savePlayers;

@end
