//
//  UITableView+HLZStickyHeader.m
//  HLZStickyTableHeaderView
//
//  Created by Hu Lizhen on 6/13/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "UITableView+HLZStickyHeader.h"
#import <objc/runtime.h>

@implementation UITableView (HLZStickyHeader)

#pragma mark - Lifecycle

+ (void)load {
    // Swizzle the `layoutSubviews` method.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(layoutSubviews));
        Method swizzledMethod = class_getInstanceMethod([self class], @selector(hlz_layoutSubviews));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)hlz_layoutSubviews {
    [self hlz_layoutSubviews];
    
    [self hlz_updateTableViewHeader];
}

#pragma mark - Accessors

- (void)hlz_setStickyHeaderView:(UIView *)stickyHeaderView {
    objc_setAssociatedObject(self, @selector(hlz_stickyHeaderView), stickyHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.hlz_stickyHeaderView.clipsToBounds = YES;
    
    // Put scroll view into the top inset of table view.
    // This is exactly the trick to make scroll view stick to the top of view controller.
    [self addSubview:stickyHeaderView];
    self.contentInset = UIEdgeInsetsMake(self.hlz_stickyHeaderViewHeightMin, 0, 0, 0);
    self.contentOffset = CGPointMake(0, -self.hlz_stickyHeaderViewHeightMin);
}

- (UIView *)hlz_stickyHeaderView {
    return objc_getAssociatedObject(self, @selector(hlz_stickyHeaderView));
}

- (void)hlz_setStickyHeaderViewHeightMin:(CGFloat)stickyHeaderViewHeightMin {
    NSNumber *number = [NSNumber numberWithFloat:stickyHeaderViewHeightMin];
    objc_setAssociatedObject(self, @selector(hlz_stickyHeaderViewHeightMin), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)hlz_stickyHeaderViewHeightMin {
    NSNumber *number = objc_getAssociatedObject(self, @selector(hlz_stickyHeaderViewHeightMin));
    if (number == nil) {
        number = [[NSNumber alloc] initWithFloat:220];
        objc_setAssociatedObject(self, @selector(hlz_stickyHeaderViewHeightMin), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [number floatValue];
}

- (void)hlz_setStickyHeaderViewHeightMax:(CGFloat)stickyHeaderViewHeightMax {
    NSNumber *number = [NSNumber numberWithFloat:stickyHeaderViewHeightMax];
    objc_setAssociatedObject(self, @selector(hlz_stickyHeaderViewHeightMax), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)hlz_stickyHeaderViewHeightMax {
    NSNumber *number = objc_getAssociatedObject(self, @selector(hlz_stickyHeaderViewHeightMax));
    if (number == nil) {
        number = [[NSNumber alloc] initWithFloat:320];
        objc_setAssociatedObject(self, @selector(hlz_stickyHeaderViewHeightMax), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [number floatValue];
}

// Update the scroll view's height, thus make it stretchable.
- (void)hlz_updateTableViewHeader {
    // Stop stretching when the height of table view header is out of range.
    CGFloat contentOffsetX = self.contentOffset.x;
    CGFloat contentOffsetY = self.contentOffset.y > -self.hlz_stickyHeaderViewHeightMax ? self.contentOffset.y : -self.hlz_stickyHeaderViewHeightMax;
    
    self.contentOffset = CGPointMake(self.contentOffset.x, contentOffsetY);
    self.hlz_stickyHeaderView.frame = CGRectMake(contentOffsetX, contentOffsetY, [UIScreen mainScreen].bounds.size.width, -contentOffsetY);
}

@end
