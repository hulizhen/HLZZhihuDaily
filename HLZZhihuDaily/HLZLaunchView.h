//
//  HLZLaunchView.h
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/9/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLZLaunchView : UIView

@property (nonatomic, copy) void (^completionBlock)(void);

- (void)setLaunchImageWithURL:(NSString *)urlString;

@end
