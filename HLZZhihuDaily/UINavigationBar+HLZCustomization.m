//
//  UINavigationBar+HLZCustomization.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/27/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "UINavigationBar+HLZCustomization.h"
#import "HLZConstants.h"

@implementation UINavigationBar (HLZCustomization)

static UIView *backgroundView = nil;

- (void)hlz_setAlpha:(CGFloat)alpha {
    backgroundView.alpha = alpha;
}

- (void)hlz_setBackgroundColor:(UIColor *)color {
    self.shadowImage = [UIImage new];
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    backgroundView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                -statusBarHeight,
                                                                CGRectGetWidth(self.bounds),
                                                                CGRectGetHeight(self.bounds) + statusBarHeight)];
        view.backgroundColor = color;
        view;
    });
    [self insertSubview:backgroundView atIndex:0];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)hlz_showNavigationBar:(BOOL)show {
    backgroundView.frame = ({
        CGRect frame = backgroundView.frame;
        frame.size.height = statusBarHeight;
        if (show) {
            frame.size.height += CGRectGetHeight(self.bounds);
        }
        frame;
    });
}

@end
