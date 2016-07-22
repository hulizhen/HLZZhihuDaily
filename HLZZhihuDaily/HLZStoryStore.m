//
//  HLZStoryStore.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import "HLZStoryStore.h"
#import "HLZConstants.h"
#import "HLZStory.h"

@interface HLZStoryStore ()

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *mutableLatestStories;
@property (nonatomic, strong) NSMutableArray *mutableTopStories;
@property (nonatomic, strong) NSDate         *earliestDate;

@end

@implementation HLZStoryStore

#pragma mark - Lifecycle

+ (instancetype)sharedInstance {
    static HLZStoryStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:nil] initSharedInstance];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)initSharedInstance {
    self = [super init];
    if (self) {
        _mutableLatestStories = [[NSMutableArray alloc] init];
        _mutableTopStories = [[NSMutableArray alloc] init];
        _earliestDate = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[HLZStoryStore sharedInstance] instead" userInfo:nil];
    return nil;
}

- (void)updateStoriesWithCompletion:(void(^)(void))completion {
    NSURL *url = [NSURL URLWithString:LatestStoriesURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        return;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [self.mutableLatestStories removeAllObjects];
    [self.mutableTopStories removeAllObjects];
    
    // Latest stories.
    [self willChangeValueForKey:NSStringFromSelector(@selector(latestStories))];
    NSArray *stories = json[@"stories"];
    NSMutableArray *newestStories = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in stories) {
        HLZStory *story = [[HLZStory alloc] initWithDictionary:dictionary];
        [newestStories addObject:story];
    }
    [self.mutableLatestStories addObject:newestStories];
    [self didChangeValueForKey:NSStringFromSelector(@selector(latestStories))];
    
    // Top stories.
    [self willChangeValueForKey:NSStringFromSelector(@selector(topStories))];
    stories = json[@"top_stories"];
    for (NSDictionary *dictionary in stories) {
        HLZStory *story = [[HLZStory alloc] initWithDictionary:dictionary];
        [self.mutableTopStories addObject:story];
    }
    [self didChangeValueForKey:NSStringFromSelector(@selector(topStories))];
    
    // Update the earliest date.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    self.earliestDate = [dateFormatter dateFromString:json[@"date"]];
    
    if (completion) {
        completion();
    }
}

- (void)loadMoreStories:(void(^)(void))completion {
    NSDate *earlierDate = [NSDate dateWithTimeInterval:-SecondsPerDay sinceDate:self.earliestDate];
    NSLog(@"%@", earlierDate);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSString *urlString = [NSString stringWithFormat:BeforeStoriesURL, [dateFormatter stringFromDate:earlierDate]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        return;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSMutableArray *moreStories = [[NSMutableArray alloc] init];
    NSArray *stories = json[@"stories"];
    for (NSDictionary *dictionary in stories) {
        HLZStory *story = [[HLZStory alloc] initWithDictionary:dictionary];
        [moreStories addObject:story];
    }
    [self.mutableLatestStories addObject:moreStories];
    
    // Update the earliestDate.
    self.earliestDate = earlierDate;
    
    // Insert the stories just got into table view.
    if (completion) {
        completion();
    }
}

#pragma mark - Accessors

- (NSArray *)latestStories {
    return [self.mutableLatestStories copy];
}

- (NSArray *)topStories {
    return [self.mutableTopStories copy];
}

@end
