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
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, readonly, assign) NSInteger currentViewIndex;

@end

@implementation HLZInfiniteScrollView

@synthesize pageControlEnabled = _pageControlEnabled;

static NSString * const CollectionViewCellIdentifier = @"HLZCollectionViewCell";

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - Accessors

- (void)setContentViews:(NSArray<UIView *> *)contentViews {
    _contentViews = [contentViews copy];
    
    // Create a working version of contentViews for internal working,
    // by inserting the last object of original contentViews at index zero of working version of contentViews,
    // and appending the first object of original contentViews to the working version of contentViews.
    // Thus, the item number of working version always has two more than the original version.
    self.workingContentViews = [_contentViews mutableCopy];
    [self.workingContentViews insertObject:_contentViews.lastObject atIndex:0];
    [self.workingContentViews addObject:_contentViews.firstObject];
    
    [self.containerView reloadData];
    
    // Update the number of pages and current page.
    self.pageControl.numberOfPages = _contentViews.count;
    self.pageControl.currentPage = 0;
    
    [self.containerView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:NO];
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
    
    if (_autoScrollEnabled) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}

// Index of the original contentViews.
- (NSInteger)currentViewIndex {
    NSInteger count = self.contentViews.count;
    CGFloat offsetX = self.containerView.contentOffset.x;
    CGFloat width = self.containerView.frame.size.width;
    if (width == 0) {
        // The self.frame has not been layouted.
        return 0;
    }
    
    // Calculate the current view index, by determining which view
    // is occupying larger proportion of the frame of scroll view.
    NSInteger remainder = (NSInteger)offsetX % (NSInteger)width;
    NSInteger currentWorkingViewIndex = (int)(offsetX / width) + (remainder > width/2 ? 1 : 0);
    
    // Convert the current view index from the working version to the original version.
    if (currentWorkingViewIndex == 0) {
        return count - 1;
    } else if (currentWorkingViewIndex == count + 1) {
        return 0;
    } else {
        return currentWorkingViewIndex - 1;
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (currentPage < 0 || currentPage >= self.contentViews.count) {
        return;
    }
    self.pageControl.currentPage = currentPage;
    
    // Scroll to the item of `currentPage` in the contentViews.
    [self.containerView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentPage + 1 inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:NO];
    [self resetTimer];
}

- (NSInteger)currentPage {
    return self.currentViewIndex;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    self.containerView.pagingEnabled = pagingEnabled;
}

- (BOOL)isPagingEnabled {
    return self.containerView.pagingEnabled;
}

// Explicitly synthesize this property, since we customize the getter.
- (void)setPageControlEnabled:(BOOL)pageControlEnabled {
    _pageControlEnabled = pageControlEnabled;
    
    if (_pageControlEnabled) {
        self.pageControl = [[UIPageControl alloc] init];
        [self.pageControl sizeToFit];
        [self addSubview:self.pageControl];
        self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[self.pageControl.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
                                                  [self.pageControl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]]];
    } else {
        [self.pageControl removeFromSuperview];
        self.pageControl = nil;
    }
}

- (BOOL)isPageControlEnabled {
    return _pageControlEnabled;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self setItemSize:frame.size];
    [self layoutIfNeeded];
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

- (void)setUp {
    // Set up the container view.
    _containerView = ({
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.scrollsToTop = NO;
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
    
    // Set the default auto scroll direction.
    self.autoScrollDirection = AutoScrollDirectionRight;
}

- (void)adjustContentOffset {
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

- (void)autoScroll {
    NSInteger count = self.workingContentViews.count;
    NSArray<NSIndexPath *> *indexPaths = [self.containerView indexPathsForVisibleItems];
    if (indexPaths == nil || indexPaths.count == 0) {
        return;
    }
    NSInteger index = [self.containerView indexPathsForVisibleItems][0].row;
    
    // Adjust the index in case it is out of range.
    index += (self.autoScrollDirection == AutoScrollDirectionLeft) ? -1 : 1;
    if (index < 0) {
        index += count;
    } else if (index >= count) {
        index = 0;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.containerView scrollToItemAtIndexPath:indexPath
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:YES];
}

- (void)setItemSize:(CGSize)size {
    // Make sure that the item size is always equal to the frame size.
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.containerView.collectionViewLayout;
    layout.itemSize = size;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.workingContentViews.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.containerView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    // Remove subviews before adding new view.
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *view = self.workingContentViews[indexPath.row];
    [cell.contentView addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[[view.leftAnchor constraintEqualToAnchor:cell.contentView.leftAnchor],
                                              [view.rightAnchor constraintEqualToAnchor:cell.contentView.rightAnchor],
                                              [view.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor],
                                              [view.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor]]];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self adjustContentOffset];
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
