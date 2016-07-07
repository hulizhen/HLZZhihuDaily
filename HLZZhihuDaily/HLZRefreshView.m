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

#pragma mark - Lifecycle

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
    if (!self.isRefreshing) {
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:8.0
                                                        startAngle:M_PI/2
                                                          endAngle:M_PI/2 + self.progress * M_PI * 2
                                                         clockwise:YES];
        UIColor *tintColor = self.tintColor ?: [UIColor whiteColor];
        [tintColor setStroke];
        path.lineWidth = 1.5;
        [path stroke];
    }
}

- (void)beginRefreshing {
    self.refreshing = true;
    [self.indicatorView startAnimating];
}

- (void)endRefreshing {
    [self.indicatorView stopAnimating];
    self.refreshing = false;
}

#pragma mark - Accessors

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

@end









#if 0

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


#pragma mark - HLZRefreshView

@interface HLZRefreshView ()

@property (nonatomic, strong) HLZRefreshCircleView *refreshControlView;

@end

@implementation HLZRefreshView

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
        self.refreshControlView = nil;
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.refreshControlView.progress = progress;
}

- (void)endRefreshing {
    [super endRefreshing];
    self.progress = 0;
}

@end

#endif