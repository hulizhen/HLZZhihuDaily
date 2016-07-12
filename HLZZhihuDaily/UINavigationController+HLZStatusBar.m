//
//  UINavigationController+HLZStatusBar.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/12/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "UINavigationController+HLZStatusBar.h"
#import "objc/runtime.h"

@implementation UINavigationController (HLZStatusBar)

+ (void)load {
    // Swizzle the `childViewControllerForStatusBarStyle` method.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(childViewControllerForStatusBarStyle));
        Method swizzledMethod = class_getInstanceMethod([self class], @selector(hlz_childViewControllerForStatusBarStyle));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (UIViewController *)hlz_childViewControllerForStatusBarStyle {
    return self.topViewController;
}

@end
