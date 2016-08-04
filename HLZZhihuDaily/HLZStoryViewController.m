//
//  HLZStoryViewController.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/30/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZStoryViewController.h"

@interface HLZStoryViewController ()

@end

@implementation HLZStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationController];
    [self configureToolbar];
}

#pragma mark - Helpers

- (void)configureNavigationController {
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;
}

- (void)configureToolbar {
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = -16;
    self.toolbarItems = @[fixedItem, [self barButtonItemWithImageNamed:@"NavigationBackButton"], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationNextButton"], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationVoteButton"], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationShareButton"], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationCommentButton"], fixedItem];
}

- (UIBarButtonItem *)barButtonItemWithImageNamed:(NSString *)imageName {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 43)];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
