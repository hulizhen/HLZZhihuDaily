//
//  HLZRefreshControl.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 6/19/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZRefreshControl.h"

#pragma mark - HLZRefreshCircleView

@interface HLZRefreshCircleView : UIView

@property (nonatomic, assign) CGFloat progress;

@end

@implementation HLZRefreshCircleView

- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:13.0
                                                    startAngle:M_PI/2
                                                      endAngle:M_PI/2 + self.progress * M_PI * 2
                                                     clockwise:YES];
    [self.tintColor setStroke];
    path.lineWidth = 2.0;
    [path stroke];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

@end


#pragma mark - HLZRefreshControl

@interface HLZRefreshControl ()

@property (nonatomic, strong) HLZRefreshCircleView *refreshControlView;

@end

@implementation HLZRefreshControl

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.refreshControlView && !self.isRefreshing) {
        self.subviews[0].subviews[0].hidden = YES;
        
        self.refreshControlView = [[HLZRefreshCircleView alloc] initWithFrame:self.bounds];
        self.refreshControlView.tintColor = self.tintColor ?: [UIColor whiteColor];
        self.refreshControlView.backgroundColor = [UIColor clearColor];
        [self.subviews[0] addSubview:self.refreshControlView];
        
        self.refreshControlView.translatesAutoresizingMaskIntoConstraints = YES;
        self.refreshControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    if (self.refreshControlView && self.isRefreshing) {
        self.subviews[0].subviews[0].hidden = NO;
        [self.refreshControlView removeFromSuperview];
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.refreshControlView.progress = progress;
}

@end
