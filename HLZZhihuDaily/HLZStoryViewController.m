//
//  HLZStoryViewController.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/30/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZStoryViewController.h"
#import "HLZStoryImageView.h"
#import "HLZConstants.h"
#import "HLZWebView.h"

@import AFNetworking;

@interface HLZStoryViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) HLZStoryImageView *imageView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSLayoutConstraint *imageViewBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *imageViewHeightConstraint;
@property (nonatomic, strong) UIView *statusBarBackgroundView;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation HLZStoryViewController

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureStatusBar];
    [self configureToolbar];
    [self configureWebView];
    [self configureImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.webView.scrollView.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.webView.scrollView.delegate = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetX = self.webView.scrollView.contentOffset.x;
    CGFloat contentOffsetY = self.webView.scrollView.contentOffset.y;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat imageViewHeight = StickyHeaderViewHeightMin - contentOffsetY;
    CGFloat newContentOffsetY = -(StickyHeaderViewHeightMax - StickyHeaderViewHeightMin);
    
    // Update image view constraint.
    if (contentOffsetY < 2 * StickyHeaderViewHeightMin) {
        if (contentOffsetY < 0) {
            self.imageViewHeightConstraint.constant = imageViewHeight;
        }
        self.imageViewBottomConstraint.constant = imageViewHeight;
        [self.webView layoutIfNeeded];
    }
    
    // Update scroll view content offset.
    if (contentOffsetY < newContentOffsetY) {
        self.webView.scrollView.contentOffset = CGPointMake(contentOffsetX, newContentOffsetY);
    }
    
    // Update status bar style.
    UIStatusBarStyle oldStatusBarStyle = self.statusBarStyle;
    self.statusBarStyle = (contentOffsetY > StickyHeaderViewHeightMin - statusBarHeight) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
    if (oldStatusBarStyle != self.statusBarStyle) {
        [UIView transitionWithView:self.statusBarBackgroundView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.statusBarBackgroundView.hidden = (self.statusBarStyle == UIStatusBarStyleDefault) ? NO : YES;
                        } completion:nil];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - Helpers

- (void)configureStatusBar {
    CGFloat statusBarWidth = [UIApplication sharedApplication].statusBarFrame.size.width;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, statusBarWidth, statusBarHeight)];
    self.statusBarBackgroundView.backgroundColor = [UIColor whiteColor];
    self.statusBarBackgroundView.hidden = YES;
    self.statusBarBackgroundView.layer.zPosition = 1.0;
    [self.view addSubview:self.statusBarBackgroundView];
}

- (NSString *)getHTMLStringWithBody:(NSString *)body css:(NSString *)css {
    NSMutableString *html = [[NSMutableString alloc] init];
    [html appendString:@"<html><head>"];
    [html appendString:[NSString stringWithFormat:@"<link rel=\"stylesheet\" href=\"%@\">", css]];
    [html appendString:@"</head>"];
    [html appendString:[NSString stringWithFormat:@"<body>%@</body>", body]];
    [html appendString:@"</html>"];
    
    return html;
}

- (void)loadWebView {
    // Load content.
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:StoryContentsURL, self.story.id] parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = responseObject;
             
             NSString *html = [self getHTMLStringWithBody:json[@"body"] css:json[@"css"][0]];
             
             [self.webView loadHTMLString:html baseURL:nil];
         } failure:nil];
}

- (void)configureWebView {
    // Add web view.
    self.webView = ({
        // Java script for scaling page to fit, disable zooming.
        NSString *javaScript = @"var meta = document.createElement('meta');"
                                "meta.setAttribute('name', 'viewport');"
                                "meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');"
                                "document.getElementsByTagName('head')[0].appendChild(meta);";
        
        WKUserScript *script = [[WKUserScript alloc] initWithSource:javaScript
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:YES];
        WKUserContentController *contentController = [[WKUserContentController alloc] init];
        [contentController addUserScript:script];
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = contentController;
        
        WKWebView *view = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        view;
    });
    [self.view addSubview:self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[[self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                                              [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]]];
    [self loadWebView];
}

- (void)configureImageView {
    // Add image view.
    self.imageView = ({
        HLZStoryImageView *view = [[NSBundle mainBundle] loadNibNamed:@"HLZStoryImageView" owner:nil options:nil].firstObject;
        view.story = self.story;
        view;
    });
    [self.webView.scrollView addSubview:self.imageView];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageViewBottomConstraint = [self.imageView.bottomAnchor constraintEqualToAnchor:self.webView.topAnchor constant:StickyHeaderViewHeightMin];
    self.imageViewHeightConstraint = [self.imageView.heightAnchor constraintEqualToConstant:StickyHeaderViewHeightMin];
    [NSLayoutConstraint activateConstraints:@[[self.imageView.leftAnchor constraintEqualToAnchor:self.webView.leftAnchor],
                                              [self.imageView.rightAnchor constraintEqualToAnchor:self.webView.rightAnchor],
                                              self.imageViewBottomConstraint,
                                              self.imageViewHeightConstraint]];
    self.imageView.clipsToBounds = YES;
}

- (void)configureToolbar {
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = -16;
    self.toolbarItems = @[fixedItem,
                          [self barButtonItemWithImageNamed:@"NavigationBackButton" action:@selector(navigateBack)], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationNextButton" action:@selector(buttonTapped)], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationVoteButton" action:@selector(buttonTapped)], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationShareButton" action:@selector(buttonTapped)], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationCommentButton" action:@selector(buttonTapped)], fixedItem];
}

- (UIBarButtonItem *)barButtonItemWithImageNamed:(NSString *)imageName action:(SEL)selector {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 43)];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - Actions

- (void)navigateBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonTapped {
    
}

@end
