//
//  HLZStoryImageView.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/14/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZStoryImageView.h"
#import "HLZStory.h"
#import "UIImageView+HLZWebImage.h"

@interface HLZStoryImageView ()

@property (nonatomic, weak) IBOutlet UILabel *storyTitle;
@property (nonatomic, weak) IBOutlet UILabel *imageSource;

@end

@implementation HLZStoryImageView

- (void)setStory:(HLZStory *)story {
    _story = story;
    
    self.storyTitle.text = _story.title;
    [self hlz_setWebImageWithURL:_story.imageURL];
    self.contentMode = UIViewContentModeScaleAspectFill;
}

@end
