//
//  HLZRefreshView.h
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 6/19/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLZRefreshView : UIView

@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;

/** Range from 0.0 to 1.0. The indicator will start animating when the progress reaches 1.0. */
@property (nonatomic, assign) CGFloat progress;

- (void)beginRefreshing;
- (void)endRefreshing;

@end
