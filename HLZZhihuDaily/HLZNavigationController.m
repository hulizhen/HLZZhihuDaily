//
//  HLZNavigationController.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 8/6/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZNavigationController.h"

@interface HLZNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation HLZNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id target = self.interactivePopGestureRecognizer.delegate;
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");
    UIView *view = self.interactivePopGestureRecognizer.view;
    
    // Create a full screen pan gesture recognizer for navigating back.
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:target action:action];
    recognizer.delegate = self;
    [view addGestureRecognizer:recognizer];
    
    // Disable the default gesture recognizer.
    self.interactivePopGestureRecognizer.enabled = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // Disable the gesture recognizer when there is the only root view controller.
    return self.childViewControllers.count == 1 ? NO : YES;
}

@end
