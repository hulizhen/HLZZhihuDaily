//
//  UINavigationBar+HLZCustomization.h
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/27/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (HLZBackgroundColor)

- (void)hlz_setAlpha:(CGFloat)alpha;
- (void)hlz_setBackgroundColor:(UIColor *)color;
- (void)hlz_showNavigationBar:(BOOL)show;

@end
