//
//  HLZStoryImageView.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/14/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZStoryImageView.h"
#import "HLZStory.h"

@import SDWebImage.UIImageView_WebCache;

@interface HLZStoryImageView ()

@property (nonatomic, weak) IBOutlet UILabel *storyTitle;
@property (nonatomic, weak) IBOutlet UILabel *imageSource;

@end

@implementation HLZStoryImageView

- (void)setStory:(HLZStory *)story {
    _story = story;
    
    self.storyTitle.text = _story.title;
    [self sd_setImageWithURL:_story.imageURL];
    self.contentMode = UIViewContentModeScaleAspectFill;
}

@end
