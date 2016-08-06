//
//  HLZMainViewController.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 5/31/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import "HLZMainViewController.h"
#import "HLZConstants.h"
#import "HLZStoryStore.h"
#import "HLZStory.h"
#import "HLZStoryCell.h"
#import "HLZInfiniteScrollView.h"
#import "UITableView+HLZStickyHeader.h"
#import "HLZRefreshView.h"
#import "HLZLaunchView.h"
#import "HLZStoryImageView.h"
#import "UINavigationBar+HLZCustomization.h"
#import "HLZStoryViewController.h"

@interface HLZMainViewController () <UITableViewDataSource, UITableViewDelegate, HLZInfiniteScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) HLZRefreshView *refreshView;
@property (nonatomic, strong) HLZInfiniteScrollView *scrollView;
@property (nonatomic, assign) BOOL hideStatusBar;
@property (nonatomic, strong) UIView *titleView;

@end

@implementation HLZMainViewController

static NSString *const StoryCellIdentifier = @"HLZStoryCell";

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hideStatusBar = NO;
        
        [[HLZStoryStore sharedInstance] addObserver:self
                                         forKeyPath:NSStringFromSelector(@selector(latestStories))
                                            options:NSKeyValueObservingOptionNew
                                            context:nil];
        [[HLZStoryStore sharedInstance] addObserver:self
                                         forKeyPath:NSStringFromSelector(@selector(topStories))
                                            options:NSKeyValueObservingOptionNew
                                            context:nil];
    }
    return self;
}

- (void)dealloc {
    [[HLZStoryStore sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(latestStories))];
    [[HLZStoryStore sharedInstance] removeObserver:self forKeyPath:NSStringFromSelector(@selector(topStories))];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationBar];
    [self configureScrollView];
    [self configureTableView];
    
    [self showLaunchView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
    
    // Use custom navigation bar instead of the one within navigation controller.
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    // Reset the content inset of table view.
    self.tableView.hlz_stickyHeaderViewHeightMin = StickyHeaderViewHeightMin;
    return YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.tableView) {
        if (self.refreshView.progress >= 1) {
            [self.refreshView beginRefreshing];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[HLZStoryStore sharedInstance] updateStoriesWithCompletion:^(BOOL finished){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.refreshView endRefreshing];
                    });
                }];
            });
        } else {
            // Reset the progress to 0 if it did not reach 1.0.
            self.refreshView.progress = 0;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        // Reset the progress to 0 if it did not reach 1.0.
        self.refreshView.progress = 0;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat difference = 0;
        
        // Update the alpha value of navigation bar, according to the contentOffset.y of table view.
        difference = StickyHeaderViewHeightMin + self.tableView.contentOffset.y;
        CGFloat alpha = difference / StickyHeaderViewHeightMin;
        alpha = alpha < 0 ? 0 : alpha;
        alpha = alpha > 1 ? 1 : alpha;
        [self.navigationBar hlz_setAlpha:alpha];
        
        // Update refresh view.
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        difference = -(self.tableView.contentOffset.y + StickyHeaderViewHeightMin + statusBarHeight);
        CGFloat progress = difference / (StickyHeaderViewHeightMax - StickyHeaderViewHeightMin) * 1.5;
        if (progress >= 0) {
            self.refreshView.progress = progress;
        }
        
        // Load more stories.
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if (scrollView.contentSize.height - scrollView.contentOffset.y <= 2 * screenHeight) {
            [self loadMoreStories];
        }
        
        // Update title on the navigation bar.
        BOOL isFirstSection = self.tableView.indexPathsForVisibleRows.firstObject.section == 0;
        self.navigationBar.topItem.titleView = isFirstSection ? self.titleView : nil;
        [self.navigationBar hlz_showNavigationBar:isFirstSection];
    }
}

#pragma mark - HLZInfiniteScrollViewDeleate

- (void)scrollView:(HLZInfiniteScrollView *)scrollView didTapOnPage:(NSInteger)page {
    [self showStoryDetail:[HLZStoryStore sharedInstance].topStories[page]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [HLZStoryStore sharedInstance].latestStories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // One minus for storing NSDate.
    return [HLZStoryStore sharedInstance].latestStories[section].count - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLZStoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:StoryCellIdentifier forIndexPath:indexPath];
    NSArray<NSArray *> *latestStories = [HLZStoryStore sharedInstance].latestStories;
    
    NSLog(@"section = %ld, row = %ld, count = %ld", indexPath.section, indexPath.row, latestStories.count);
    NSArray *stories = latestStories[indexPath.section];
    cell.story = (HLZStory *)stories[indexPath.row + 1];    // One plus for storing NSDate.
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section > 0 ? TableViewSectionHeaderHeight : 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.font = [UIFont systemFontOfSize:16];
    header.contentView.backgroundColor = [UIColor colorWithRed:0.01 green:0.55 blue:0.83 alpha:1.0];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] init];
    NSString *dateString = [HLZStoryStore sharedInstance].latestStories[section].firstObject;
    header.textLabel.text = dateString;
    return header;
}

#pragma mark - Helpers

- (void)showStoryDetail:(HLZStory *)story {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HLZStoryViewController *storyViewController = (HLZStoryViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"StoryViewController"];
    storyViewController.story = story;
    [self.navigationController pushViewController:storyViewController animated:YES];
}

- (void)loadTopStories {
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    for (HLZStory *story in [HLZStoryStore sharedInstance].topStories) {
        HLZStoryImageView *imageView = [[NSBundle mainBundle] loadNibNamed:@"HLZStoryImageView" owner:nil options:nil].firstObject;
        imageView.story = story;
        
        [imageViews addObject:imageView];
    }
    
    self.scrollView.contentViews = imageViews;
}

- (void)loadMoreStories {
    static BOOL isLoading = NO;
    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)self.tableView.tableFooterView;
    
    if (!isLoading) {
        isLoading = YES;
        [indicatorView startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[HLZStoryStore sharedInstance] loadMoreStories: ^(BOOL finished){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finished) {
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[HLZStoryStore sharedInstance].latestStories.count - 1];
                        [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
                        [indicatorView stopAnimating];
                    }
                    isLoading = NO;
                });
            }];
        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isEqual:[HLZStoryStore sharedInstance]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(latestStories))]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(topStories))]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadTopStories];
            });
        }
    }
}

- (void)configureNavigationBar {
    // Customize title view.
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
    
    // Add refresh view.
    self.refreshView = [[HLZRefreshView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.refreshView.tintColor = [UIColor whiteColor];
    [self.titleView addSubview:self.refreshView];
    
    // Add title label.
    UILabel *titleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 80, 30)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:18];
        label.text = @"今日热闻";
        label;
        });
    [self.titleView addSubview:titleLabel];
    
    // Customize navigation bar.
    [self.navigationBar hlz_setBackgroundColor:[UIColor colorWithRed:0.01 green:0.55 blue:0.83 alpha:1.0]];
    [self.navigationBar hlz_setAlpha:0];
    self.navigationBar.topItem.titleView = self.titleView;
}

- (void)configureTableView {
    self.tableView.hlz_stickyHeaderViewHeightMin = StickyHeaderViewHeightMin;
    self.tableView.hlz_stickyHeaderViewHeightMax = StickyHeaderViewHeightMax;
    self.tableView.hlz_stickyHeaderView = self.scrollView;
    
    self.tableView.sectionHeaderHeight = TableViewSectionHeaderHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = StoryCellRowHeight;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    self.tableView.scrollsToTop = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Register table view cell.
    UINib *cellNib = [UINib nibWithNibName:StoryCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:StoryCellIdentifier];
    
    // Add activity indicator view to footer view.
    UIActivityIndicatorView *indicatorView = ({
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 64)];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        indicator.hidesWhenStopped = YES;
        indicator;
    });
    self.tableView.tableFooterView = indicatorView;
}

- (void)configureScrollView {
    self.scrollView = ({
        HLZInfiniteScrollView *scrollView = [[HLZInfiniteScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                                    -StickyHeaderViewHeightMin,
                                                                                                    [UIScreen mainScreen].bounds.size.width,
                                                                                                    StickyHeaderViewHeightMin)];
        scrollView.pagingEnabled = YES;
        scrollView.pageControlEnabled = YES;
        scrollView.autoScrollEnabled = YES;
        scrollView.autoScrollTimerInterval = AutoScrollTimerInterval;
        scrollView.autoScrollDirection = AutoScrollDirectionRight;
        scrollView.delegate = self;
        scrollView;
    });
}

- (void)showLaunchView {
    HLZLaunchView *launchView = [[HLZLaunchView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.hideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    [launchView setLaunchImageWithURL:[NSString stringWithFormat:LaunchImageURL, [NSString stringWithFormat:@"%d*%d", 1080, 177]]];
    launchView.completionBlock = ^{
        self.scrollView.currentPage = 0;
        self.hideStatusBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    };
    
    // Add launch view to the window.
    [[[UIApplication sharedApplication].delegate window] addSubview:launchView];
}

@end
