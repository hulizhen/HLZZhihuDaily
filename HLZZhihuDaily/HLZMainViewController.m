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
#import "HLZTopStoryImageView.h"

@import SDWebImage;

@interface HLZMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) HLZRefreshView *refreshView;
@property (nonatomic, strong) HLZInfiniteScrollView *scrollView;
@property (nonatomic, assign) BOOL hideStatusBar;
@property (nonatomic, assign, getter=isLoadingStories) BOOL loadingStories;

@end

@implementation HLZMainViewController

static NSString * const StoryCellIdentifier = @"HLZStoryCell";

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hideStatusBar = YES;
        
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
    
    [self loadTopStories];
    
    [self showLaunchViewWithCompletion];
}

- (BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.tableView) {
        if (self.refreshView.progress >= 1) {
            [self.refreshView beginRefreshing];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[HLZStoryStore sharedInstance] updateStoriesWithCompletion:^{
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
        difference = (StickyHeaderViewHeightMin + 5) + self.tableView.contentOffset.y;
        CGFloat alpha = difference / StickyHeaderViewHeightMin;
        alpha = alpha < 0 ? 0 : alpha;
        alpha = alpha > 1 ? 1 : alpha;
        self.navigationController.navigationBar.subviews[0].alpha = alpha;
        NSLog(@"alpha = %f", alpha);
        
        // Update refresh view.
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        difference = -(self.tableView.contentOffset.y + StickyHeaderViewHeightMin + statusBarHeight);
        CGFloat progress = difference / (StickyHeaderViewHeightMax - StickyHeaderViewHeightMin) * 1.5;
        if (progress >= 0) {
            self.refreshView.progress = progress;
        }
        
        // Load more stories.
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if (scrollView.contentSize.height - scrollView.contentOffset.y <= 1.5 * screenHeight) {
            if (!self.isLoadingStories) {
                self.loadingStories = YES;
                [[HLZStoryStore sharedInstance] loadMoreStories: ^{
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[HLZStoryStore sharedInstance].latestStories.count - 1];
                    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
                    self.loadingStories = NO;
                }];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [HLZStoryStore sharedInstance].latestStories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [HLZStoryStore sharedInstance].latestStories[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLZStoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:StoryCellIdentifier forIndexPath:indexPath];
    NSArray<NSArray *> *latestStories = [HLZStoryStore sharedInstance].latestStories;
    
    NSArray *stories = latestStories[indexPath.section];
    cell.story = (HLZStory *)stories[indexPath.row];
    
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
    header.contentView.backgroundColor = [UIColor colorWithRed:0.01 green:0.56 blue:0.84 alpha:1.0];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] init];
    header.textLabel.text = [NSString stringWithFormat:@"section header %ld", section];
    return header;
}

#pragma mark - Helpers

- (void)loadTopStories {
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    for (HLZStory *story in [HLZStoryStore sharedInstance].topStories) {
        HLZTopStoryImageView *imageView = [[NSBundle mainBundle] loadNibNamed:@"HLZTopStoryImageView" owner:nil options:nil][0];
        imageView.story = story;
        
        [imageViews addObject:imageView];
    }
    
    self.scrollView.contentViews = imageViews;
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
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.01 green:0.56 blue:0.84 alpha:1.0];
    self.navigationController.navigationBar.subviews[0].alpha = 0;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // Customize title view.
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
    
    self.refreshView = [[HLZRefreshView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [titleView addSubview:self.refreshView];
    
    UILabel *titleLabel = ({
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 80, 30)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"今日热闻";
        titleLabel;
    });
    [titleView addSubview:titleLabel];
    
    self.navigationItem.titleView = titleView;
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
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Register table view cell.
    UINib *cellNib = [UINib nibWithNibName:StoryCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:StoryCellIdentifier];
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
        scrollView;
    });
}

- (void)showLaunchViewWithCompletion {
    HLZLaunchView *launchView = [[HLZLaunchView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    launchView.launchImageURL = [NSURL URLWithString:[NSString stringWithFormat:LaunchImageURL, [NSString stringWithFormat:@"%d*%d", 1080, 177]]];
    launchView.completionBlock = ^{
        self.scrollView.currentPage = 0;
        self.hideStatusBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    };
    
    // Add launch view to the window.
    [[[UIApplication sharedApplication].delegate window] addSubview:launchView];
}

@end
