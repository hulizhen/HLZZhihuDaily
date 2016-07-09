//
//  HLZLaunchView.h
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/9/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLZLaunchView : UIView

@property (nonatomic, copy) UIImage *launchImage;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) void (^completionBlock)(void);

@end
