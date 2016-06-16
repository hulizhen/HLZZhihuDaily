//
//  UITableView+HLZStickyHeader.h
//  HLZStickyTableHeaderView
//
//  Created by Hu Lizhen on 6/13/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (HLZStickyHeader)

/** The view you want to add to the top of table view. */
@property (nonatomic, strong) UIView *stickyHeaderView;

/** The minimal height of the sticky header view. The default is 220 points. */
@property (nonatomic, assign) CGFloat stickyHeaderViewHeightMin;

/** The maximal height of the sticky header view. The default is 320 points. */
@property (nonatomic, assign) CGFloat stickyHeaderViewHeightMax;

@end
