//
//  HLZTopStoryImageView.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/14/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZTopStoryImageView.h"
#import "HLZStory.h"

@import SDWebImage;

@interface HLZTopStoryImageView ()

@property (nonatomic, weak) IBOutlet UILabel *storyTitle;

@end

@implementation HLZTopStoryImageView

- (void)setStory:(HLZStory *)story {
    _story = story;
    
    self.storyTitle.text = _story.title;
    [self sd_setImageWithURL:_story.imageURL placeholderImage:nil];
    self.contentMode = UIViewContentModeScaleAspectFill;
}

@end
