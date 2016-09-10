//
//  XZSpringRefreshLoadingView.m
//  XZSpringRefreshView
//
//  Created by 徐章 on 16/9/8.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZSpringRefreshLoadingView.h"

@interface XZSpringRefreshLoadingView()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (assign, nonatomic) CATransform3D identityTransform;

@end

@implementation XZSpringRefreshLoadingView

- (id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        
        self.progressLayer = [[CAShapeLayer alloc] init];
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.progressLayer.anchorPoint = CGPointMake(0.5, 0.5);
        self.progressLayer.actions = @{@"strokeEnd":[NSNull null], @"transform":[NSNull null]};
        [self.layer addSublayer:self.progressLayer];
    }
    return self;
}

- (void)layoutSubviews{

    [super layoutSubviews];
    
     self.progressLayer.frame = self.bounds;
    
    CGFloat inset = self.progressLayer.lineWidth/2.0f;
    self.progressLayer.path = [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, inset, inset)] CGPath];
    
}

- (CATransform3D)identityTransform {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -500;
    _identityTransform = CATransform3DRotate(transform, (-90.0 * M_PI / 180.0), 0, 0, 1.0);
    
    return _identityTransform;
}

#pragma mark - Public_Methods
- (void)setProgress:(CGFloat)progress{

    self.progressLayer.strokeEnd = MIN(0.9*progress, 0.9);
    if (progress > 1.0) {
        CGFloat degress = ((progress - 1.0) * 200.0);
        self.progressLayer.transform = CATransform3DRotate(self.identityTransform, (degress * M_PI / 180.0) , 0, 0, 1.0);
    } else {
        self.progressLayer.transform = self.identityTransform;
    }

}


- (void)startAnimating {
    
    if ([self.progressLayer animationForKey:@"RotationAnimation"]) {
        return;
    }
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(2.0 * M_PI + [[self.progressLayer valueForKeyPath:@"transform.rotation.z"] doubleValue]);
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = INFINITY;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [self.progressLayer addAnimation:rotationAnimation forKey:@"RotationAnimation"];
}

- (void)stopLoading {
    
    [self.progressLayer removeAnimationForKey:@"RotationAnimation"];
}

@end
