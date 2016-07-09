//
//  StoryStore.m
//  oZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import "StoryStore.h"
#import "Constants.h"
#import "Story.h"
#import "Macros.h"

@interface StoryStore ()

@property (nonatomic, strong) NSMutableArray *mutableLatestStories;
@property (nonatomic, strong) NSMutableArray *mutableTopStories;

@end

@implementation StoryStore

#pragma mark - Lifecycle

+ (instancetype)sharedInstance {
    static StoryStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initSharedInstance];
    });
    return sharedInstance;
}

- (instancetype)initSharedInstance {
    self = [super init];
    if (self) {
        _mutableLatestStories = [[NSMutableArray alloc] init];
        _mutableTopStories = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[StoryStore sharedInstance]" userInfo:nil];
    return nil;
}

- (void)updateStoriesWithCompletion:(void(^)(void))completion {
    NSURL *url = [NSURL URLWithString:LatestStoriesURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [self.mutableLatestStories removeAllObjects];
    [self.mutableTopStories removeAllObjects];
    
    // Latest stories.
    [self willChangeValueForKey:NSStringFromSelector(@selector(latestStories))];
    NSArray *stories = json[@"stories"];
    for (NSDictionary *dictionary in stories) {
        Story *story = [[Story alloc] initWithDictionary:dictionary];
        [self.mutableLatestStories addObject:story];
    }
    [self didChangeValueForKey:NSStringFromSelector(@selector(latestStories))];
    
    // Top stories.
    [self willChangeValueForKey:NSStringFromSelector(@selector(topStories))];
    stories = json[@"top_stories"];
    for (NSDictionary *dictionary in stories) {
        Story *story = [[Story alloc] initWithDictionary:dictionary];
        [self.mutableTopStories addObject:story];
    }
    [self didChangeValueForKey:NSStringFromSelector(@selector(topStories))];
    
    if (completion) {
        completion();
    }
    
#ifdef DumpStories
    [self dumpStories];
#endif
}


#pragma mark - Accessors

- (NSArray *)latestStories {
    return [self.mutableLatestStories copy];
}

- (NSArray *)topStories {
    return [self.mutableTopStories copy];
}

#pragma mark - Utils

#ifdef DumpStories
- (void)dumpStories {
    for (Story *story in self.mutableLatestStories) {
        NSLog(@"Latest Story: %@", story);
    }
    
    printf("\n");
    for (Story *story in self.mutableTopStories) {
        NSLog(@"Top Story: %@", story);
    }
    
    printf("\n");
}
#endif

@end
