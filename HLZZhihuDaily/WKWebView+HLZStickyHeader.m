//
//  WKWebView+HLZStickyHeader.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 8/6/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "WKWebView+HLZStickyHeader.h"
#import <objc/runtime.h>

@implementation WKWebView (HLZStickyHeader)

static const float DefaultStickyHeaderViewHeightMin = 180.0;
static const float DefaultStickyHeaderViewHeightMax = 320.0;

#pragma mark - Lifecycle

//+ (void)load {
//    // Swizzle the `layoutSubviews` method.
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Method originalMethod = class_getInstanceMethod([self class], @selector(layoutSubviews));
//        Method swizzledMethod = class_getInstanceMethod([self class], @selector(hlz_layoutSubviews));
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    });
//}
//
//- (void)hlz_layoutSubviews {
//    [self hlz_layoutSubviews];
//    
//    [self hlz_updateTableViewHeader];
//}

// Update the scroll view's height, thus make it stretchable.
- (void)hlz_updateTableViewHeader {
//    // Stop stretching when the height of table view header is out of range.
//    CGFloat contentOffsetX = self.contentOffset.x;
//    CGFloat contentOffsetY = self.contentOffset.y > -self.hlz_stickyHeaderViewHeightMax ? self.contentOffset.y : -self.hlz_stickyHeaderViewHeightMax;
//    
//    // Put header view into the top inset of table view.
//    // This is exactly the trick to make scroll view stick to the top of view controller.
//    CGFloat statusBarHeight = 20.0;
//    CGFloat topEdgeInset = self.contentOffset.y > 0 ? statusBarHeight : self.hlz_stickyHeaderViewHeightMin;
//    self.contentInset = UIEdgeInsetsMake(topEdgeInset, 0, 0, 0);
//    
//    if (-contentOffsetY >= self.hlz_stickyHeaderViewHeightMax) {
//        self.contentOffset = CGPointMake(contentOffsetX, contentOffsetY);
//    }
//    if (-contentOffsetY >= 0 && -contentOffsetY <= self.hlz_stickyHeaderViewHeightMax) {
//        self.hlz_stickyHeaderView.frame = CGRectMake(contentOffsetX, contentOffsetY, [UIScreen mainScreen].bounds.size.width, -contentOffsetY);
//    }
}

@end
