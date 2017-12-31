//
//  GameImageMaker.h
//  GameCalc
//
//  Created by Pete Maiser on 12/6/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameImageMaker : NSObject

- (UIImage *)getImage:(NSString *)imageFile;
- (UIImage *)makeSquareImage:(UIImage *)originalImage
                        size:(int)newSize;

@end
