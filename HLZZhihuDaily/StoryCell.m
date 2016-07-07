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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - Accessors

- (void)setStory:(Story *)story {
    _story = story;
    
    self.storyTitle.text = story.title;
    [self.storyImageView sd_setImageWithURL:story.imageURL placeholderImage:nil];
}

@end
