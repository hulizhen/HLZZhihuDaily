//
//  HLZStoryStore.h
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLZStoryStore : NSObject

// ! Memory layout of array `latestStories` !
// -------------------------------------------
// | NSDate | HLZStory | HLZStory | HLZStory |
// | NSDate | HLZStory | HLZStory | HLZStory |
// | NSDate | HLZStory | HLZStory | HLZStory |
// | NSDate | HLZStory | HLZStory | HLZStory |
// | NSDate | HLZStory | HLZStory | HLZStory |
// |   .    |     .    |     .    |     .    |
// |   .    |     .    |     .    |     .    |
// |   .    |     .    |     .    |     .    |
// -------------------------------------------
@property (nonatomic, readonly, strong) NSArray<NSArray *> *latestStories;

@property (nonatomic, readonly, strong) NSArray *topStories;

+ (instancetype)sharedInstance;
- (void)updateStoriesWithCompletion:(void(^)(BOOL finished))completion;
- (void)loadMoreStories:(void(^)(BOOL finished))completion;

@end
