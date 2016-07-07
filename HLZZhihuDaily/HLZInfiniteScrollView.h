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

@property (nonatomic, copy) NSArray<UIView *> *contentViews;
@property (nonatomic, assign, getter=isAutoScrollEnabled) BOOL autoScrollEnabled;
@property (nonatomic, assign) AutoScrollDirection autoScrollDirection;
@property (nonatomic, assign) NSTimeInterval autoScrollTimerInterval;
@property (nonatomic, readonly, assign) NSInteger currentViewIndex;

// NOTE: The paging will be enabled when enabling auto scrolling.
@property(nonatomic, getter=isPagingEnabled) BOOL pagingEnabled;

@end
