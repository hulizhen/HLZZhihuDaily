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
#import "NSDate+HLZConversion.h"

@import AFNetworking.AFHTTPSessionManager;

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

- (void)updateStoriesWithCompletion:(void(^)(BOOL finished))completion {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:LatestStoriesURL parameters:nil progress: nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             NSDictionary *json = responseObject;
             [self.mutableLatestStories removeAllObjects];
             [self.mutableTopStories removeAllObjects];
             
             NSDate *currentDate = [NSDate hlz_dateFromString:json[@"date"] format:@"yyyyMMdd"];
             
             // Latest stories.
             NSMutableArray *newestStories = [[NSMutableArray alloc] init];
             NSString *dateString = [currentDate hlz_stringWithFormat:@"MM月dd日 EEEE"];
             
             NSArray *stories = json[@"stories"];
             [self willChangeValueForKey:NSStringFromSelector(@selector(latestStories))];
             [newestStories addObject:dateString];  // Add current date as the first object.
             [self populateStories:newestStories withDictionaries:stories];
             [self.mutableLatestStories addObject:newestStories];
             [self didChangeValueForKey:NSStringFromSelector(@selector(latestStories))];
             
             // Top stories.
             stories = json[@"top_stories"];
             [self willChangeValueForKey:NSStringFromSelector(@selector(topStories))];
             [self populateStories:self.mutableTopStories withDictionaries:stories];
             [self didChangeValueForKey:NSStringFromSelector(@selector(topStories))];
             
             // Update the earliest date.
             self.earliestDate = currentDate;
             
             if (completion) {
                 completion(true);
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             if (completion) {
                 completion(false);
             }
         }];
}

- (void)loadMoreStories:(void(^)(BOOL finished))completion {
    NSDate *earlierDate = [NSDate dateWithTimeInterval:-SecondsPerDay sinceDate:self.earliestDate];
    
    NSString *urlString = [NSString stringWithFormat:BeforeStoriesURL, [earlierDate hlz_stringWithFormat:@"yyyyMMdd"]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             NSDictionary *json = responseObject;
             NSMutableArray *moreStories = [[NSMutableArray alloc] init];
             NSArray *stories = json[@"stories"];
             NSString *dateString = [earlierDate hlz_stringWithFormat:@"MM月dd日 EEEE"];
             
             [moreStories addObject:dateString];   // Add current date as the first object.
             [self populateStories:moreStories withDictionaries:stories];
             [self.mutableLatestStories addObject:moreStories];
             
             // Update the earliestDate.
             self.earliestDate = earlierDate;
             
             if (completion) {
                 completion(true);
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             if (completion) {
                 completion(false);
             }
             return;
         }];
}

#pragma mark - Accessors

- (NSArray *)latestStories {
    return [self.mutableLatestStories copy];
}

- (NSArray *)topStories {
    return [self.mutableTopStories copy];
}

#pragma mark - Helpers

- (NSDate *)dateFromString:(NSString *)string {
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        dateFormatter.dateFormat = @"yyyyMMdd";
    }
    return [dateFormatter dateFromString:string];
}

- (void)populateStories:(NSMutableArray *)stories withDictionaries:(NSArray *)dictionaries {
    for (NSDictionary *dictionary in dictionaries) {
        HLZStory *story = [[HLZStory alloc] initWithDictionary:dictionary];
        [stories addObject:story];
    }
}

@end
