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

@interface StoryStore ()

@property (nonatomic, strong) NSMutableArray *privateLatestStories;
@property (nonatomic, strong) NSMutableArray *privateTopStories;

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
        _privateLatestStories = [[NSMutableArray alloc] init];
        _privateTopStories = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[StoryStore sharedInstance]" userInfo:nil];
    return nil;
}

- (void)fetchStories {
    NSURL *url = [NSURL URLWithString:LatestStoriesURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    // Latest stories.
    NSArray *stories = json[@"stories"];
    for (NSDictionary *dictionary in stories) {
        Story *story = [[Story alloc] initWithDictionary:dictionary];
        [self.privateLatestStories addObject:story];
    }
    
    // Top stories.
    stories = json[@"top_stories"];
    for (NSDictionary *dictionary in stories) {
        Story *story = [[Story alloc] initWithDictionary:dictionary];
        [self.privateTopStories addObject:story];
    }
    
    [self dumpStories];
}


#pragma mark - Accessors

- (NSArray *)latestStories {
    return [self.privateLatestStories copy];
}

- (NSArray *)topStories {
    return [self.privateTopStories copy];
}

#pragma mark - Utils

- (void)dumpStories {
    for (Story *story in self.privateLatestStories) {
        NSLog(@"Latest Story: %@", story);
    }
    
    printf("\n");
    for (Story *story in self.privateTopStories) {
        NSLog(@"Top Story: %@", story);
    }
    
    printf("\n");
}

@end
