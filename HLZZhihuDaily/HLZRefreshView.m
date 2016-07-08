//
//  HLZRefreshView.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 6/19/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZRefreshView.h"


@interface HLZRefreshView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation HLZRefreshView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [self addSubview:_indicatorView];
        _indicatorView.center = self.center;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.progress == 0) {
        return;
    }
    
    if (!self.isRefreshing) {
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        UIBezierPath *path;
        UIColor *tintColor;
        CGFloat lineWidth = 1.0;
        CGFloat circleRadius = 8.0;
        
        // Draw the background circle.
        path = [UIBezierPath bezierPathWithArcCenter:center
                                              radius:circleRadius
                                          startAngle:0
                                            endAngle:M_PI * 2
                                           clockwise:YES];
        tintColor = [UIColor colorWithWhite:0.5 alpha:0.3];
        [tintColor setStroke];
        path.lineWidth = lineWidth;
        [path stroke];
        
        // Draw the progress circle.
        path = [UIBezierPath bezierPathWithArcCenter:center
                                              radius:circleRadius
                                          startAngle:M_PI/2
                                            endAngle:M_PI/2 + self.progress * M_PI * 2
                                           clockwise:YES];
        tintColor = self.tintColor ?: [UIColor whiteColor];
        [tintColor setStroke];
        path.lineWidth = lineWidth;
        [path stroke];
    }
}

- (void)beginRefreshing {
    self.refreshing = true;
    [self.indicatorView startAnimating];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)endRefreshing {
    [self.indicatorView stopAnimating];
    self.refreshing = false;
    
    self.progress = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.indicatorView.color = tintColor;
}

@end