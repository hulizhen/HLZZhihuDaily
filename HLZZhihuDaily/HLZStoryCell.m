//
//  HLZStoryCell.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import "HLZStoryCell.h"
#import "HLZStory.h"

@import SDWebImage;

@interface HLZStoryCell ()

@property (nonatomic, weak) IBOutlet UILabel     *storyTitle;
@property (nonatomic, weak) IBOutlet UIImageView *storyImageView;

@end

@implementation HLZStoryCell

- (void)setStory:(HLZStory *)story {
    _story = story;
    
    self.storyTitle.text = story.title;
    [self.storyImageView sd_setImageWithURL:story.imageURL];
}

@end
