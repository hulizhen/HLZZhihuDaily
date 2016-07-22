//
//  HLZStoryStore.h
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLZStoryStore : NSObject

@property (nonatomic, readonly, strong) NSArray<NSArray *> *latestStories;
@property (nonatomic, readonly, strong) NSArray *topStories;

+ (instancetype)sharedInstance;
- (void)updateStoriesWithCompletion:(void(^)(void))completion;
- (void)loadMoreStories:(void(^)(void))completion;

@end
