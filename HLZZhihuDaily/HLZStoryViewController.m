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

@interface HLZStoryViewController ()

@property (nonatomic, strong) HLZStoryImageView *imageView;
@property (nonatomic, strong) HLZWebView *webView;

@end

@implementation HLZStoryViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureToolbar];
    [self configureWebView];
    [self configureImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Helpers

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
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         }];
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
        
        HLZWebView *view = [[HLZWebView alloc] initWithFrame:CGRectZero configuration:configuration];
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
    [self.webView addSubview:self.imageView];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[[self.imageView.topAnchor constraintEqualToAnchor:self.webView.topAnchor],
                                              [self.imageView.leftAnchor constraintEqualToAnchor:self.webView.leftAnchor],
                                              [self.imageView.rightAnchor constraintEqualToAnchor:self.webView.rightAnchor],
                                              [self.imageView.heightAnchor constraintEqualToConstant:StickyHeaderViewHeightMin]]];
    self.imageView.clipsToBounds = YES;
}

- (void)configureToolbar {
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = -16;
    self.toolbarItems = @[fixedItem,
                          [self barButtonItemWithImageNamed:@"NavigationBackButton" action:@selector(navigateBack)], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationNextButton" action:@selector(buttonType)], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationVoteButton" action:@selector(buttonType)], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationShareButton" action:@selector(buttonType)], flexibleItem,
                          [self barButtonItemWithImageNamed:@"NavigationCommentButton" action:@selector(buttonType)], fixedItem];
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
