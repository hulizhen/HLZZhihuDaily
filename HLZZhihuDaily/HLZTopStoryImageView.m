//
//  HLZTopStoryImageView.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/14/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZTopStoryImageView.h"
#import "HLZStory.h"
#import "UIImageView+HLZWebImage.h"

@interface HLZTopStoryImageView ()

@property (nonatomic, weak) IBOutlet UILabel *storyTitle;
@property (nonatomic, weak) IBOutlet UILabel *imageSource;

@end

@implementation HLZTopStoryImageView

- (void)setStory:(HLZStory *)story {
    _story = story;
    
    self.storyTitle.text = _story.title;
    [self hlz_setWebImageWithURL:_story.imageURL];
    self.contentMode = UIViewContentModeScaleAspectFill;
}

@end
