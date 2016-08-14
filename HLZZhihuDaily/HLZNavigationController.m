//
//  HLZNavigationController.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 8/6/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZNavigationController.h"
#import "objc/runtime.h"

@interface HLZNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation HLZNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Enable full screen pan back feature.
    object_setClass(self.interactivePopGestureRecognizer, [UIPanGestureRecognizer class]);
    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // Disable the gesture recognizer when there is the only root view controller.
    return self.childViewControllers.count == 1 ? NO : YES;
}

@end
