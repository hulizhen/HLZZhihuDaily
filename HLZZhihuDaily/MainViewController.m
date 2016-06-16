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
    
    // Hide table view and show launch image.
    self.view.alpha = 0.0;
    [self showLaunchImage];
    
    self.scrollView = [[HLZInfiniteScrollView alloc] init];
    self.tableView.stickyHeaderView = self.scrollView;
    self.pageControl = [[UIPageControl alloc] init];
    
    [self configureTableView:self.tableView];
    [self configureScrollView:self.scrollView];
    [self configurePageControl:self.pageControl];
    
    [self updateStories];
}

- (void)viewDidLayoutSubviews {
    CGRect frame = self.pageControl.frame;
    self.pageControl.frame = CGRectMake(frame.origin.x, -self.tableView.contentOffset.y - 40, frame.size.width, frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Show table view and hide launch image.
    [NSThread sleepForTimeInterval:1.5];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished){
        [self hideLaunchImage];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
    } else if (scrollView == self.scrollView) {
    }
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
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView sd_setImageWithURL:story.imageURL placeholderImage:nil];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageViews addObject:imageView];
        ++i;
    }
    
    self.scrollView.contentViews = imageViews;
    self.pageControl.numberOfPages = imageViews.count;
}

- (void)configureTableView:(UITableView *)tableView {
    tableView.estimatedRowHeight = StoryCellRowHeight;
    tableView.rowHeight = UITableViewAutomaticDimension;
    
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    
    // Register table view cell.
    UINib *cellNib = [UINib nibWithNibName:StoryCellIdentifier bundle:nil];
    [tableView registerNib:cellNib forCellReuseIdentifier:StoryCellIdentifier];
}

- (void)configureScrollView:(HLZInfiniteScrollView *)scrollView {
    scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 3, 220);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.infiniteScrollEnabled = YES;
    scrollView.autoScrollEnabled = YES;
    scrollView.autoScrollTimerInterval = 5.0;
    scrollView.autoScrollAnimationDuration = 0.5;
    scrollView.autoScrollLeftShift = YES;
    scrollView.delegate = self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqual:@"currentViewIndex"] && object == self.scrollView) {
        self.pageControl.currentPage = [change[NSKeyValueChangeNewKey] integerValue];
    }
}

- (void)configurePageControl:(UIPageControl *)pageControl {
    pageControl.currentPage = self.scrollView.currentViewIndex;
    [self.view addSubview:pageControl];
    
    [self.scrollView addObserver:self forKeyPath:@"currentViewIndex" options:NSKeyValueObservingOptionNew context:nil];

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
