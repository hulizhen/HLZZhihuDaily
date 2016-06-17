//
//  HLZInfiniteScrollView.h
//  HLZInfiniteScrollView
//
//  Created by Hu Lizhen on 6/14/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLZInfiniteScrollViewDelegate <UIScrollViewDelegate>

@end

@interface HLZInfiniteScrollView : UIScrollView

@property (nonatomic, weak, nullable) id<HLZInfiniteScrollViewDelegate> delegate;

@property (nonatomic, assign, getter=isInfiniteScrollEnabled) BOOL infiniteScrollEnabled;
@property (nonatomic, copy, nullable) NSArray<UIView *> *contentViews;

@property (nonatomic, assign, getter=isAutoScrollEnabled) BOOL autoScrollEnabled;
@property (nonatomic, assign, getter=isAutoScrollLeftShift) BOOL autoScrollLeftShift;
@property (nonatomic, assign) NSTimeInterval autoScrollTimerInterval;

@property (nonatomic, assign, readonly) NSInteger currentViewIndex;

@end
