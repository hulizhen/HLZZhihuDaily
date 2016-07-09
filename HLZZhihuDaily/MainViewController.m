//
//  MainViewController.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 5/31/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"
#import "HLZStoryStore.h"
#import "HLZStory.h"
#import "HLZStoryCell.h"
#import "HLZInfiniteScrollView.h"
#import "UITableView+HLZStickyHeader.h"
#import "HLZRefreshView.h"
#import "HLZLaunchView.h"
#import "Macros.h"

@import SDWebImage;

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) HLZRefreshView *refreshView;
@property (nonatomic, strong) HLZInfiniteScrollView *scrollView;

@end

@implementation MainViewController

static NSString * const StoryCellIdentifier = @"HLZStoryCell";

#pragma mark - Lifecycle

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
    
    [self showLaunchViewWithCompletion:^{
        self.scrollView.currentPage = 0;
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat progress = -(self.tableView.contentOffset.y + StickyHeaderViewHeightMin)/(StickyHeaderViewHeightMax - StickyHeaderViewHeightMin) * 1.5;
        if (progress >= 0 && scrollView.isDragging) {
            self.refreshView.progress = progress;
        }
    }
}

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
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        // Reset the progress to 0 if it did not reach 1.0.
        self.refreshView.progress = 0;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [HLZStoryStore sharedInstance].latestStories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLZStoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:StoryCellIdentifier forIndexPath:indexPath];
    
    NSArray *stories = [HLZStoryStore sharedInstance].latestStories;
    cell.story = (HLZStory *)stories[indexPath.row];
    
    return cell;
}

#pragma mark - Helpers

- (void)loadTopStories {
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    for (HLZStory *story in [HLZStoryStore sharedInstance].topStories) {
        UIImageView *imageView = [[NSBundle mainBundle] loadNibNamed:@"TopStoryImageView" owner:nil options:nil][0];
        [imageView sd_setImageWithURL:story.imageURL placeholderImage:nil];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageViews addObject:imageView];
        
        // Add title label.
        UILabel *label = [imageView viewWithTag:LabelInTopStoryImageViewTag];
        label.text = story.title;
        [imageView addSubview:label];
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
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
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    self.tableView.hlz_stickyHeaderViewHeightMin = StickyHeaderViewHeightMin - statusBarHeight - navigationBarHeight;
    self.tableView.hlz_stickyHeaderViewHeightMax = StickyHeaderViewHeightMax;
    self.tableView.hlz_stickyHeaderView = self.scrollView;
    
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
    
    [[HLZStoryStore sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(latestStories)) options:NSKeyValueObservingOptionNew context:nil];
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
    
    [[HLZStoryStore sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(topStories)) options:NSKeyValueObservingOptionNew context:nil];
}

- (void)showLaunchViewWithCompletion:(void (^)(void))completion {
    HLZLaunchView *launchView = [[HLZLaunchView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:LaunchImageURL, [NSString stringWithFormat:@"%d*%d", 1080, 177]]];
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    if (!json) {
        return;
    }
    
    // Get launch image.
    NSURL *imageURL = [NSURL URLWithString:json[@"img"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *launchImage = [UIImage imageWithData:imageData];
    
    launchView.launchImage = launchImage;
    launchView.authorName = json[@"text"];
    launchView.title = @"知乎日报";
    launchView.subtitle = @"每天三次，每次七分钟";
    launchView.completionBlock = completion;
    
    // Add launch view to the window.
    [[[UIApplication sharedApplication].delegate window] addSubview:launchView];
}

@end
