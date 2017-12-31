//
//  PlayerStore.m
//  GameCalc
//
//  Created by Pete Maiser on 10/10/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import "PlayerStore.h"

@interface PlayerStore ()
@property (nonatomic) NSMutableArray *privatePlayers;
@end

@implementation PlayerStore

+ (instancetype)sharedStore
{
    // As a singleton, make the pointer to the store static so that it will always exist
    static PlayerStore *sharedStore;
    
    // Check if the shared store already exists; if not create it
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init
{
    // this method should not be used
    [NSException raise:@"Singleton" format:@"Use +[PlayerStore sharedStore]"];
    return nil;
}

- (instancetype)initPrivate
{
    // This is the real initializer
    self = [super init];
    if (self) {
        
        ///First try to retrieve saved players
        NSString * path = [self archivePath];
        _privatePlayers = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If there are no saved players then start fresh
        if (!_privatePlayers) {
            _privatePlayers = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSArray *)allPlayers
{
    //Override the getter of allPlayers to return a copy of private players
    return [self.privatePlayers copy];
}

- (NSString *)archivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"players.archive"];
}

- (Player *)createPlayerOfType:(PlayerType)type
{
    Player *player = [Player emptyPlayerOfType:type];
    
    if (player) {
        [self.privatePlayers addObject:player];
    }
    
    return player;
}

- (void)deletePlayer:(Player *)player
{
    NSInteger playerIndex = [_privatePlayers indexOfObject:player];
    [_privatePlayers removeObjectAtIndex:playerIndex];
    
    return;
}

- (void)movePlayerAtIndex:(NSUInteger)fromIndex
                  toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex){
        return;
    }
    
    // Get a pointer to the object being moved
    Player *player = self.privatePlayers[fromIndex];
    
    // Remove the item being moved from the store
    [self.privatePlayers removeObjectAtIndex:fromIndex];
    
    // And reinsert it at the appropriate location
    if (player) {
        [self.privatePlayers insertObject:player
                                  atIndex:toIndex];
    }
}

- (BOOL)savePlayers
{
    NSString *path = [self archivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.privatePlayers
                                       toFile:path];
}

@end
