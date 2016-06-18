//
//  MainViewController.m
//  oZhihuDaily
//
//  Created by Hu Lizhen on 5/31/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"
#import "StoryStore.h"
#import "Story.h"
#import "StoryCell.h"
#import "HLZInfiniteScrollView.h"
#import "UITableView+HLZStickyHeader.h"
#import "Macros.h"

@import SDWebImage;

@interface MainViewController () <UITableViewDataSource, HLZInfiniteScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) HLZInfiniteScrollView *scrollView;
@property (nonatomic, strong) UIImageView *launchImageView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation MainViewController

static NSString * const StoryCellIdentifier = @"StoryCell";

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef LaunchImageEnabled
    // Hide table view and show launch image.
    self.view.alpha = 0.0;
    [self showLaunchImage];
#endif
    
    self.scrollView = [[HLZInfiniteScrollView alloc] init];
    self.tableView.stickyHeaderViewHeightMin = StickyHeaderViewHeightMin;
    self.tableView.stickyHeaderViewHeightMax = StickyHeaderViewHeightMax;
    self.tableView.stickyHeaderView = self.scrollView;
    self.pageControl = [[UIPageControl alloc] init];
    
    [self configureNavigationBar];
    [self configureTableView];
    [self configureScrollView];
    [self configurePageControl];
    
    [self updateStories];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
#ifdef LaunchImageEnabled
    // Show table view and hide launch image.
    [NSThread sleepForTimeInterval:ShowLaunchImageDuration];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished){
        [self hideLaunchImage];
    }];
#endif
}

- (void)viewDidLayoutSubviews {
    self.pageControl.frame = ({
        CGRect frame = self.pageControl.frame;
        frame.origin.y = -self.tableView.contentOffset.y - 32;
        frame;
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        self.pageControl.frame = ({
            CGRect frame = self.pageControl.frame;
            frame.origin.y = -self.tableView.contentOffset.y - 32;
            frame;
        });
    } else if (scrollView == self.scrollView) {
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = self.scrollView.currentViewIndex;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.pageControl.currentPage = self.scrollView.currentViewIndex;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [StoryStore sharedInstance].latestStories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:StoryCellIdentifier forIndexPath:indexPath];
    
    NSArray *stories = [StoryStore sharedInstance].latestStories;
    cell.story = (Story *)stories[indexPath.row];
    
    return cell;
}

#pragma mark - Helpers

- (void)updateStories {
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    NSInteger i = 0;
    for (Story *story in [StoryStore sharedInstance].topStories) {
        UIImageView *imageView = [[NSBundle mainBundle] loadNibNamed:@"TopStoryImageView" owner:nil options:nil][0];
        [imageView sd_setImageWithURL:story.imageURL placeholderImage:nil];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageViews addObject:imageView];
        
        UILabel *label = [imageView viewWithTag:LabelInTopStoryImageViewTag];
        label.text = story.title;
        [imageView addSubview:label];
        
        ++i;
    }
    
    self.scrollView.contentViews = imageViews;
    self.pageControl.numberOfPages = imageViews.count;
}

- (void)configureNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.title = @"今日热闻";
}

- (void)configureTableView {
    self.tableView.estimatedRowHeight = StoryCellRowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    // Register table view cell.
    UINib *cellNib = [UINib nibWithNibName:StoryCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:StoryCellIdentifier];
}

- (void)configureScrollView {
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 3, StickyHeaderViewHeightMin);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.infiniteScrollEnabled = YES;
    self.scrollView.autoScrollEnabled = YES;
    self.scrollView.autoScrollTimerInterval = AutoScrollTimerInterval;
    self.scrollView.autoScrollLeftShift = YES;
    self.scrollView.delegate = self;
}

- (void)configurePageControl {
    self.pageControl.currentPage = self.scrollView.currentViewIndex;
    [self.view addSubview:self.pageControl];
    
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[[self.pageControl.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]]];
}

- (void)showLaunchImage {
    self.launchImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // Get the launch image.
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:LaunchImageURL, [NSString stringWithFormat:@"%d*%d", 1080, 177]]];
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    NSURL *imageURL = [NSURL URLWithString:json[@"img"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *launchImage = [UIImage imageWithData:imageData];
    
    if (launchImage) {
        self.launchImageView.image = launchImage;
        [[[UIApplication sharedApplication].delegate window] addSubview:self.launchImageView];
    }
}

- (void)hideLaunchImage {
    if (self.launchImageView) {
        [self.launchImageView removeFromSuperview];
        self.launchImageView = nil;
    }
}

@end
