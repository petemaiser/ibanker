//
//  GameImageMaker.m
//  GameCalc
//
//  Created by Pete Maiser on 12/6/15.
//  Copyright © 2015 Pete Maiser. All rights reserved.
//

#import "GameImageMaker.h"

@implementation GameImageMaker

- (UIImage *)getImage:(NSString *)imageFile
{
    return [[UIImage imageNamed:imageFile] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)makeSquareImage:(UIImage *)originalImage
                        size:(int)newSize
{
    if ((originalImage) &&
        (newSize > 0)) {
        
        CGSize originalImageSize = originalImage.size;
        
        // The rectangle of the thumbnail
        CGRect newRect = CGRectMake(0, 0, newSize, newSize);
        
        // Figure out a scaling ratio to make sure we maintain the same aspect ratio
        float ratio = MAX(newRect.size.width / originalImageSize.width, newRect.size.height / originalImageSize.height);
        
        // Create a transparent bitmap context with scaling factor equal to that of the screen
        UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
        
        // Create a path that is a rounded triangle
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
        
        // Make all subsequent drawing clip to this rounded rectangle
        [path addClip];
        
        // Center the image in the thumbnail rectangle
        CGRect projectRect;
        projectRect.size.width = originalImageSize.width * ratio;
        projectRect.size.height = originalImageSize.height * ratio;
        projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
        projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
        
        // Draw the image on it
        [originalImage drawInRect:projectRect];
        
        // Get the image from the image context; keep it as our thumbnail
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // Now that we have the image we can "clean up" the image context
        UIGraphicsEndImageContext();
        
        return newImage;
        
    } else {
        return nil;
    }
}

@end
