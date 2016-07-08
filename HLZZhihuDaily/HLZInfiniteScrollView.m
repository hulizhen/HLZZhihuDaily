//
//  HLZInfiniteScrollView.m
//  HLZInfiniteScrollView
//
//  Created by Hu Lizhen on 7/6/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZInfiniteScrollView.h"

@interface HLZInfiniteScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *containerView;
@property (nonatomic, strong) NSMutableArray<UIView *> *workingContentViews;
@property (nonatomic, readonly, assign) NSInteger currentWorkingViewIndex;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation HLZInfiniteScrollView

static NSString * const CellReuseIdentifier = @"CellReuseIdentifier";

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Set up the container view.
        _containerView = ({
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            flowLayout.itemSize = frame.size;
            flowLayout.minimumLineSpacing = 0;
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
            [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.showsVerticalScrollIndicator = NO;
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView;
        });
        [self addSubview:_containerView];
        _containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[_containerView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
                                                  [_containerView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
                                                  [_containerView.topAnchor constraintEqualToAnchor:self.topAnchor],
                                                  [_containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]]];
        
        // Set up the page control.
        _pageControl = [[UIPageControl alloc] init];
        [_pageControl sizeToFit];
        [self addSubview:_pageControl];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[_pageControl.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
                                                  [_pageControl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]]];
        
        // Set the default auto scroll direction.
        self.autoScrollDirection = AutoScrollDirectionRight;
    }
    return self;
}

#pragma mark - Accessors

- (void)setContentViews:(NSArray<UIView *> *)contentViews {
    _contentViews = contentViews;
    
    // Create a working version of contentViews for internal working,
    // by inserting the last object of original contentViews at index zero of working version of contentViews,
    // and appending the first object of original contentViews to the working version of contentViews.
    // Thus, the item number of working version always has two more than the original version.
    self.workingContentViews = [_contentViews mutableCopy];
    [self.workingContentViews insertObject:self.contentViews.lastObject atIndex:0];
    [self.workingContentViews addObject:self.contentViews.firstObject];
    
    // Update the number of pages and current page.
    self.pageControl.numberOfPages = contentViews.count;
    self.pageControl.currentPage = 0;
    
    // Scroll to the first item in the contentViews.
    [self.containerView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    [self resetTimer];
}

- (void)setAutoScrollTimerInterval:(NSTimeInterval)autoScrollTimerInterval {
    _autoScrollTimerInterval = autoScrollTimerInterval;
    
    // Reset timer whenever the timer interval is updated.
    [self resetTimer];
}

- (void)setAutoScrollEnabled:(BOOL)autoScrollEnabled {
    _autoScrollEnabled = autoScrollEnabled;
    
    // Enable paging when enabling auto scrolling.
    self.containerView.pagingEnabled = YES;
    
    if (autoScrollEnabled) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}

// Index of the working contentViews.
- (NSInteger)currentWorkingViewIndex {
    CGFloat offsetX = self.containerView.contentOffset.x;
    CGFloat width = self.containerView.frame.size.width;
    if (width == 0) {
        // The self.frame has not been layouted.
        return 0;
    }
    
    // Calculate the current view index, by determining which view
    // is occupying the greater proportion of the collection frame.
    NSInteger remainder = (NSInteger)offsetX % (NSInteger)width;
    return (int)(offsetX / width) + (remainder > width/2 ? 1 : 0);
}

// Index of the original contentViews.
- (NSInteger)currentViewIndex {
    NSInteger count = self.contentViews.count;
    
    // Convert the current view index from the working version to the original version.
    if (self.currentWorkingViewIndex == 0) {
        return count - 1;
    } else if (self.currentWorkingViewIndex == count + 1) {
        return 0;
    } else {
        return self.currentWorkingViewIndex - 1;
    }
}

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    self.containerView.pagingEnabled = pagingEnabled;
}

- (BOOL)isPagingEnabled {
    return self.containerView.pagingEnabled;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // Make sure that the item size is always equal to the frame size.
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.containerView.collectionViewLayout;
    layout.itemSize = frame.size;
}

#pragma mark - Timer

- (void)stopTimer {
    [self.timer invalidate];
}

- (void)startTimer {
    if (self.contentViews && self.isAutoScrollEnabled && ![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimerInterval
                                                      target:self
                                                    selector:@selector(autoScroll)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)resetTimer {
    if (self.contentViews && self.isAutoScrollEnabled) {
        [self stopTimer];
        [self startTimer];
    }
}

#pragma mark - Helpers

- (void)autoScroll {
    NSInteger count = self.workingContentViews.count;
    NSInteger index = self.currentWorkingViewIndex + 1;
    
    switch (self.autoScrollDirection) {
        case AutoScrollDirectionLeft:
            index = self.currentWorkingViewIndex - 1;
            break;
        case AutoScrollDirectionRight:
            index = self.currentWorkingViewIndex + 1;
            break;
    }
    
    // Adjust the index in case it is out of range.
    if (index < 0) {
        index += count;
    } else if (index >= count) {
        index = 0;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.containerView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.workingContentViews.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.containerView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
        
    if (cell) {
        cell.contentMode = UIViewContentModeRedraw;
        
        UIView *view = self.workingContentViews[indexPath.row];
        [cell.contentView addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[view.leftAnchor constraintEqualToAnchor:cell.contentView.leftAnchor],
                                                  [view.rightAnchor constraintEqualToAnchor:cell.contentView.rightAnchor],
                                                  [view.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor],
                                                  [view.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor]]];
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger count = self.workingContentViews.count;
    CGFloat width = self.containerView.frame.size.width;
    CGFloat offsetX = self.containerView.contentOffset.x;
    CGFloat offsetY = self.containerView.contentOffset.y;
    
    // When scrolling to one end of the container view, scroll to the other end
    // without animation so that the user can not see the scroll.
    if (offsetX <= 0) {
        self.containerView.contentOffset = CGPointMake(width * (count - 2) + offsetX, offsetY);
    } else if (offsetX >= width * (count - 1)) {
        self.containerView.contentOffset = CGPointMake(offsetX - width * (count - 2), offsetY);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self resetTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = self.currentViewIndex;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.pageControl.currentPage = self.currentViewIndex;
}

@end
