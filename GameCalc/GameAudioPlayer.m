//
//  GameAudioPlayer.m
//  GameCalc
//
//  Created by Pete Maiser on 11/29/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import "GameAudioPlayer.h"

@interface GameAudioPlayer () <AVAudioPlayerDelegate>
@property (nonatomic, strong) NSMutableArray *AVAudioPlayers;
@property (nonatomic, strong) NSMutableArray *AVAudioPlayersQueue;
@end

@implementation GameAudioPlayer

+ (instancetype)sharedAudioPlayer
{
    // As a singleton, make the pointer to the store static so that it will always exist
    static GameAudioPlayer *sharedAudioPlayer;
    
    // Check if the shared object already exists; if not create it
    if (!sharedAudioPlayer) {
        sharedAudioPlayer = [[self alloc] initPrivate];
    }
    
    return sharedAudioPlayer;
}

- (instancetype)init
{
    // this method should not be used
    [NSException raise:@"Singleton" format:@"Use +[GameAudioPlayer sharedAudioPlayer]"];
    return nil;
}

- (instancetype)initPrivate
{
    // This is the real initializer
    self = [super init];
    
    if (self) {
        // Do any other Singleton first-time setup
        
        _AVAudioPlayers = [[NSMutableArray alloc]  init];
        _AVAudioPlayersQueue = [[NSMutableArray alloc]  init];
        
    }
    
    return self;
}

- (void)playMPEG4:(NSString *)soundFile
           volume:(float)volume;
{
    if (!soundFile) {
        soundFile = [NSString stringWithFormat:@"DefaultSound"];
    }
    
    NSString * path =[[NSBundle mainBundle] pathForResource:soundFile
                                                     ofType:@"m4a"];
    NSURL * url = [NSURL fileURLWithPath:path];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                                   error:NULL];
    
    if (player) {
        [self.AVAudioPlayers addObject:player];
    
        [player setVolume:volume];
        [player setDelegate:self];
        [player play];
    }
    
}

- (void)queueMPEG4:(NSString *)soundFile
           volume:(float)volume;
{
    if (!soundFile) {
        soundFile = [NSString stringWithFormat:@"DefaultSound"];
    }

    NSString * path =[[NSBundle mainBundle] pathForResource:soundFile
                                                     ofType:@"m4a"];
    NSURL * url = [NSURL fileURLWithPath:path];
    AVAudioPlayer *queuedPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                                   error:NULL];
    
    if (queuedPlayer) {
    
        [queuedPlayer setVolume:volume];
        [queuedPlayer setDelegate:self];
        
        // If nothing is playing right now, go ahead and play the sound right away
        // otherwise, queue it
        if ([self.AVAudioPlayers count] == 0) {
            [self.AVAudioPlayers addObject:queuedPlayer];
            [queuedPlayer play];
        }
        else {
            [self.AVAudioPlayersQueue addObject:queuedPlayer];
        }
    }
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    // If this is the only player, check the queue to see if we should load another one
    if ([self.AVAudioPlayers count] == 1) {

        NSInteger queueCount = [self.AVAudioPlayersQueue count];
        
        if (queueCount > 0) {
            
            AVAudioPlayer *queuedPlayer = self.AVAudioPlayersQueue[queueCount-1];
            
            [self.AVAudioPlayers addObject:queuedPlayer];
            [self.AVAudioPlayersQueue removeObject:queuedPlayer];
            
            [queuedPlayer play];
        }
    }
    
    if (player) {
        [self.AVAudioPlayers removeObject:player];
    }
    
}

- (void)playSystemSound:(NSString *)soundFile
                 volume:(float)volume
{
    NSString *fileName = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@",soundFile];
    NSURL *fileURL = [NSURL URLWithString:fileName];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL
                                                                   error:NULL];
    if (player) {
        [self.AVAudioPlayers addObject:player];
    
        [player setVolume:volume];
        [player setDelegate:self];
        [player play];
    }
    
}

@end
