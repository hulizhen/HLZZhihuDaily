//
//  UIImageView+HLZWebImage.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/30/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "UIImageView+HLZWebImage.h"

@import SDWebImage;

@implementation UIImageView (HLZWebImage)

- (void)hlz_setWebImageWithURL:(NSURL *)url {
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        self.image = [self processImage:image];
    }];
}

- (UIImage *)processImage:(UIImage *)image {
    CGFloat imageHeight = CGImageGetHeight(image.CGImage);
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CISmoothLinearGradient"];
    [filter setDefaults];
    
    // Upper gradient.
    [filter setValue:[[CIVector alloc] initWithCGPoint:CGPointMake(0, 0.5 * imageHeight)] forKey:@"inputPoint0"];
    [filter setValue:[CIColor colorWithCGColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.01].CGColor] forKey:@"inputColor0"];
    [filter setValue:[[CIVector alloc] initWithCGPoint:CGPointMake(0, 0.7 * imageHeight)] forKey:@"inputPoint1"];
    [filter setValue:[CIColor colorWithCGColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor] forKey:@"inputColor1"];
    CIImage* upperGradient = [filter outputImage];
    
    // Lower gradient.
    [filter setValue:[[CIVector alloc] initWithCGPoint:CGPointMake(0, 0)] forKey:@"inputPoint0"];
    [filter setValue:[CIColor colorWithCGColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor] forKey:@"inputColor0"];
    [filter setValue:[[CIVector alloc] initWithCGPoint:CGPointMake(0, 0.4 * imageHeight)] forKey:@"inputPoint1"];
    [filter setValue:[CIColor colorWithCGColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.01].CGColor] forKey:@"inputColor1"];
    CIImage* lowerGradient = [filter outputImage];
    
    // Composite upper and lower gradient.
    filter = [CIFilter filterWithName:@"CIAdditionCompositing"];
    [filter setDefaults];
    [filter setValue:upperGradient forKey:kCIInputImageKey];
    [filter setValue:lowerGradient forKey:kCIInputBackgroundImageKey];
    CIImage *gradientImage = [filter valueForKey:kCIOutputImageKey];
    
    // Composite gradient and the original image.
    filter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [filter setDefaults];
    [filter setValue:gradientImage forKey:kCIInputImageKey];
    [filter setValue:inputImage forKey:kCIInputBackgroundImageKey];
    CIImage *compositedImage = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef compositedImageRef = [context createCGImage:compositedImage fromRect:[inputImage extent]];
    UIImage *outputImage = [UIImage imageWithCGImage:compositedImageRef];
    CGImageRelease(compositedImageRef);
    
    return outputImage;
}

@end
