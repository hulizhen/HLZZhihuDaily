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

@property (nonatomic, getter=isInfiniteScrollEnabled) BOOL infiniteScrollEnabled;
@property (nonatomic, copy, nullable) NSArray<UIView *> *contentViews;

@property (nonatomic, getter=isAutoScrollEnabled) BOOL autoScrollEnabled;
@property (nonatomic, getter=isAutoScrollLeftShift) BOOL autoScrollLeftShift;
@property (nonatomic) NSTimeInterval autoScrollTimerInterval;
@property (nonatomic) NSTimeInterval autoScrollAnimationDuration;

@end
