//
//  HLZLaunchView.m
//  HLZZhihuDaily
//
//  Created by Hu Lizhen on 7/9/16.
//  Copyright © 2016 hulizhen. All rights reserved.
//

#import "HLZLaunchView.h"

@import SDWebImage.UIImageView_WebCache;

@interface HLZLaunchView ()

@property (nonatomic, strong) UIImageView *lauchImageView;
@property (nonatomic, strong) UIView      *bottomView;
@property (nonatomic, strong) UILabel     *authorLabel;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *subtitleLabel;
@property (nonatomic, strong) UIView      *logoView;

@property (nonatomic, strong) NSLayoutConstraint *bottomViewBottomAnchorConstraint;

@end

@implementation HLZLaunchView

static const CGFloat BottomViewHeight                         = 95;
static const CGFloat LogoViewSide                             = 45;
static const NSTimeInterval BottomViewHeightAnimationDuration = 0.5;
static const NSTimeInterval LogoViewAnimationDuration         = 1.5;
static const NSTimeInterval LaunchImageViewAnimationDuration  = 0.2;
static const NSTimeInterval StayStillDuration                 = 1.5;
static const NSTimeInterval FadeOutDuration                   = 0.5;

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    @throw [NSException exceptionWithName:@"Initializer" reason:@"Use -[initWithFrame] instead" userInfo:nil];
    return nil;
}

- (void)didMoveToSuperview {
    // Layout without animation.
    [self layoutIfNeeded];
    
    // Layout with animation.
    [UIView animateWithDuration:BottomViewHeightAnimationDuration animations:^{
        self.bottomViewBottomAnchorConstraint.constant = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished){
        // Show logo view with animation.
        [self showLogoView];
        
        // Show launch image view with animation.
        [self showLaunchView];
    }];
}

#pragma mark - Helpers

- (void)showLaunchView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:LaunchImageViewAnimationDuration animations:^{
            self.lauchImageView.alpha = 1.0;
        }];
    });
}

- (void)setLaunchImageURL:(NSURL *)launchImageURL {
    _launchImageURL = launchImageURL;
    
    NSData *data = [NSData dataWithContentsOfURL:_launchImageURL];
    if (!data) {
        return;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    self.authorLabel.text = json[@"text"];
    self.titleLabel.text = @"我的日报";
    self.subtitleLabel.text = @"每天三次，每次七分钟";
    
    [self.lauchImageView sd_setImageWithURL:[NSURL URLWithString:json[@"img"]]];
    self.lauchImageView.alpha = 0;
}

- (void)setUp:(CGRect)frame {
    self.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.10 alpha:1.0];
    
    // Set up bottom view.
    _bottomView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.10 alpha:1.0];
        [self addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomViewBottomAnchorConstraint = [view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:BottomViewHeight];
        [NSLayoutConstraint activateConstraints:@[_bottomViewBottomAnchorConstraint,
                                                  [view.widthAnchor constraintEqualToConstant:frame.size.width],
                                                  [view.heightAnchor constraintEqualToConstant:BottomViewHeight]]];
        view;
    });
    
    // Set up launch image view.
    _lauchImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
                                                  [imageView.bottomAnchor constraintEqualToAnchor:_bottomView.topAnchor],
                                                  [imageView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
                                                  [imageView.rightAnchor constraintEqualToAnchor:self.rightAnchor]]];
        imageView;
    });
    
    // Set up author label.
    _authorLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"Avenir-Book" size:12];
        label.textColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
        [label sizeToFit];
        [self addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[label.bottomAnchor constraintEqualToAnchor:_bottomView.topAnchor constant:-8.0],
                                                  [label.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]]];
        label;
    });
    
    // Set up logo view.
    _logoView = ({
        UIView *view = [[UIView alloc] init];
        [_bottomView addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[view.centerYAnchor constraintEqualToAnchor:_bottomView.centerYAnchor],
                                                  [view.leftAnchor constraintEqualToAnchor:_bottomView.leftAnchor
                                                                                  constant:(BottomViewHeight - LogoViewSide)/2],
                                                  [view.widthAnchor constraintEqualToConstant:LogoViewSide],
                                                  [view.heightAnchor constraintEqualToConstant:LogoViewSide]]];
        view;
    });
    
    // Set up title label.
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"Avenir-Book" size:19];
        label.textColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.00];
        [label sizeToFit];
        [_bottomView addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[label.leftAnchor constraintEqualToAnchor:_logoView.rightAnchor constant:14.0],
                                                  [label.topAnchor constraintEqualToAnchor:_logoView.topAnchor]]];
        label;
    });
    
    // Set up subtitle label.
    _subtitleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"Avenir-Book" size:14];
        label.textColor = [UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1.00];
        [label sizeToFit];
        [_bottomView addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[label.leftAnchor constraintEqualToAnchor:_logoView.rightAnchor constant:14.0],
                                                  [label.bottomAnchor constraintEqualToAnchor:_logoView.bottomAnchor]]];
        label;
    });
}

- (void)showLogoView {
    UIColor *color = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.00];
    CGPoint center = CGPointMake(CGRectGetMidX(self.logoView.bounds), CGRectGetMidY(self.logoView.bounds));
    CGFloat radius = LogoViewSide/4;
    CGFloat lineWidth;
    UIBezierPath *path;
    CAShapeLayer *layer;
    
    // The outer rectangle layer.
    lineWidth = 1.0;
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.logoView.bounds, lineWidth/2, lineWidth/2)
                                      cornerRadius:10.0];
    layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.lineWidth = lineWidth;
    layer.strokeColor = color.CGColor;
    layer.fillColor = nil;
    [self.logoView.layer addSublayer:layer];
    
    
    // The inner circle layer.
    lineWidth = 4.0;
    path = [UIBezierPath bezierPathWithArcCenter:center
                                          radius:radius
                                      startAngle:M_PI/2
                                        endAngle:0
                                       clockwise:YES];
    layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.lineWidth = lineWidth;
    layer.lineCap = kCALineCapRound;
    layer.strokeColor = color.CGColor;
    layer.fillColor = nil;
    
    // Animate when drawing the inner circle.
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = LogoViewAnimationDuration;
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LaunchImageViewAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [layer addAnimation:animation forKey:@"strokeEnd"];
        [self.logoView.layer addSublayer:layer];
    });
}

#pragma mark - CAAnimation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CAShapeLayer *animatedLogoLayer = (CAShapeLayer *)self.logoView.layer.sublayers[1];
    
    if (anim == [animatedLogoLayer animationForKey:@"strokeEnd"]) {
        [NSThread sleepForTimeInterval:StayStillDuration];
        
        if (self.completionBlock) {
            self.completionBlock();
        }
        
        self.alpha = 1.0;
        [UIView animateWithDuration:FadeOutDuration animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

@end
