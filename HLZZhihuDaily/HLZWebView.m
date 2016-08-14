//
//  HLZWebView.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 8/9/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZWebView.h"

@import WebKit;

@interface HLZWebView () <UIScrollViewDelegate>

@end

@implementation HLZWebView

- (void)layoutSubviews {
    NSLog(@"offset = %f", self.scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"offset = %f", self.scrollView.contentOffset.y);
}

@end
