//
//  HLZInfiniteScrollView.h
//  HLZInfiniteScrollView
//
//  Created by Hu Lizhen on 7/6/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AutoScrollDirection) {
    AutoScrollDirectionLeft,
    AutoScrollDirectionRight
};

@interface HLZInfiniteScrollView : UIView

// The views which will be showed in the scroll view.
@property (nonatomic, copy) NSArray<UIView *> *contentViews;

@property (nonatomic, assign, getter=isPageControlEnabled) BOOL pageControlEnabled;

// If you want to set this property, do it after the view did layout.
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign, getter=isAutoScrollEnabled) BOOL autoScrollEnabled;
@property (nonatomic, assign) AutoScrollDirection autoScrollDirection;
@property (nonatomic, assign) NSTimeInterval autoScrollTimerInterval;

// The paging will be enabled when enabling auto scrolling.
@property(nonatomic, getter=isPagingEnabled) BOOL pagingEnabled;

@end
