//
//  GameAudioPlayer.h
//  GameCalc
//
//  Created by Pete Maiser on 11/29/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//
//  GameAudioPlayer makes use of AVAudioPlayer, which is a great simple way to play a quick audio file,
//  but it tends to get cleaned-up by ARC after you complete the method in which you called it - which is
//  before you get any sound out of it - ARC rudely interupts it before it performs its function for you.
//
//  The typcial fix is to make AVAudio player a property in whatever object you are using it in.  But if you
//  need sound more than once in that object, the result is that you end up calling initWithContentsOfURL:error:
//  multiple times, and that ends up in the potential for a memory leak.  GameAudioPlayer solves that problem
//  by creating an NSObject singleton from which to call AVAudioPlayer.  GameAudioPlayer puts each AVAudioPlayer
//  into a private array, sets itself up as the AVAudioPlayer delegate and implements audioPlayerDidFinishPlaying
//  :successfully:, which removes the finished AVAudioPlayer from the private array.  ARC can then clean it
//  up without only after it is done playing.

#import <AVFoundation/AVFoundation.h>

@interface GameAudioPlayer : NSObject

+ (instancetype)sharedAudioPlayer;

- (void)playMPEG4:(NSString *)soundFile        // Play sound immediately
           volume:(float)volume;
- (void)queueMPEG4:(NSString *)soundFile       // Add sound to a play queue; sounds will be pulled from queue FIFO and played when no other sounds are being played
            volume:(float)volume;

- (void)playSystemSound:(NSString *)soundFile  // Play a sound file from the system sound folder
                 volume:(float)volume;

@end
