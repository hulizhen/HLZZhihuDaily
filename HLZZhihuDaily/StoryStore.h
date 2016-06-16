//
//  StoryStore.h
//  oZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoryStore : NSObject

@property (nonatomic, readonly) NSArray *latestStories;
@property (nonatomic, readonly) NSArray *topStories;

+ (instancetype)sharedInstance;
- (void)fetchStories;

@end
