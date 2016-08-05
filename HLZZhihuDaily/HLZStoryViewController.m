//
//  HLZStoryViewController.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/30/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZStoryViewController.h"
#import "HLZStoryImageView.h"
#import "UIImageView+HLZWebImage.h"
#import "HLZConstants.h"

@interface HLZStoryViewController ()

@property (nonatomic, strong) HLZStoryImageView *imageView;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation HLZStoryViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationController];
    [self configureToolbar];
    [self configureViewController];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Helpers

- (void)configureViewController {
    // Add image view.
    self.imageView = ({
        HLZStoryImageView *view = [[NSBundle mainBundle] loadNibNamed:@"HLZStoryImageView" owner:nil options:nil].firstObject;
        view.story = self.story;
        view;
    });
    [self.view addSubview:self.imageView];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[[self.imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                                              [self.imageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [self.imageView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              [self.imageView.heightAnchor constraintEqualToConstant:StickyHeaderViewHeightMin]]];
    
    // Add web view.
    self.webView = ({
        UIWebView *view = [[UIWebView alloc] init];
        view.scalesPageToFit = YES;
        view.opaque = NO;
        view.backgroundColor = [UIColor redColor];
        view;
    });
    [self.view addSubview:self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[[self.webView.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor],
                                              [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              [self.webView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor]]];
}

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
