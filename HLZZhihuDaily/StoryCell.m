//
//  StoryCell.m
//  oZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#import "StoryCell.h"
#import "Story.h"

@import SDWebImage;

@interface StoryCell ()

@property (nonatomic, weak) IBOutlet UILabel     *storyTitle;
@property (nonatomic, weak) IBOutlet UIImageView *storyImageView;

@end

@implementation StoryCell

- (void)setStory:(Story *)story {
    _story = story;
    
    self.storyTitle.text = story.title;
    [self.storyImageView sd_setImageWithURL:story.imageURL placeholderImage:nil];
}

@end
