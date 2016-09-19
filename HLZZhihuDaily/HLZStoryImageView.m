//
//  HLZStoryImageView.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/14/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZStoryImageView.h"
#import "HLZStory.h"

@import SDWebImage;

@interface HLZStoryImageView ()

@property (nonatomic, weak) IBOutlet UILabel *storyTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *imageSourceLabel;

@end

@implementation HLZStoryImageView

- (void)setStory:(HLZStory *)story {
    _story = story;
    
    self.storyTitleLabel.text = _story.title;
    [self sd_setImageWithURL:_story.imageURL];
    self.contentMode = UIViewContentModeScaleAspectFill;
}

@end
