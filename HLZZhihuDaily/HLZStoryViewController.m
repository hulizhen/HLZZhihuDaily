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

@interface HLZStoryViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) HLZStoryImageView *imageView;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation HLZStoryViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureToolbar];
    [self configureViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.toolbarHidden = NO;
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
        view;
    });
    [self.view addSubview:self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[[self.webView.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor],
                                              [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              [self.webView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor]]];
}

- (void)configureToolbar {
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = -16;
    self.toolbarItems = @[fixedItem,
                          [self barButtonItemWithImageNamed:@"NavigationBackButton" action:@selector(goBack)], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationNextButton" action:nil], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationVoteButton" action:nil], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationShareButton" action:nil], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationCommentButton" action:nil], fixedItem];
}

- (UIBarButtonItem *)barButtonItemWithImageNamed:(NSString *)imageName action:(SEL)selector {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 43)];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - Actions

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
