//
//  UINavigationBar+HLZBackgroundColorr.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/27/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "UINavigationBar+HLZBackgroundColor.h"

@implementation UINavigationBar (HLZBackgroundColorr)

static UIView *backgroundView = nil;

- (void)hlz_setBackgroundColor:(UIColor *)color
{
    self.shadowImage = [UIImage new];
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    backgroundView = ({
        CGFloat statusBarHeight = 20;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                -statusBarHeight,
                                                                CGRectGetWidth(self.bounds),
                                                                CGRectGetHeight(self.bounds) + statusBarHeight)];
        view.backgroundColor = color;
        view;
    });
    [self insertSubview:backgroundView atIndex:0];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

@end
