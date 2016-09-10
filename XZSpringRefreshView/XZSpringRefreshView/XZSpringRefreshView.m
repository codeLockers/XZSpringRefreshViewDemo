//
//  XZSpringRefreshView.m
//  XZSpringRefreshView
//
//  Created by 徐章 on 16/9/5.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZSpringRefreshView.h"
#import "XZSpringRefreshLoadingView.h"

typedef NS_ENUM(NSInteger,XZSpringState){

    XZSpringRefreshStop,
    XZSpringRefreshDragging,
    XZSpringRefreshBounceback,
    XZSpringRefreshLoading,
    XZSpringRefreshAnimationToStop
};

static NSString *const XZSpringRefreshContentOffset = @"contentOffset";
static NSString *const XZSpringRefreshPanGestureRecognizerState = @"panGestureRecognizer.state";

static CGFloat const XZSpringRefreshMinDragOffset = 95.0f;
static CGFloat const XZSpringRefreshWaveMaxHeight = 70.0f;
static CGFloat const XZSpringRefreshLoadingInset = 50.0f;

@interface XZSpringRefreshView()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) XZSpringState springState;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) UIView *centerControlPoint;
@property (nonatomic, strong) UIView *leftControlPoint1;
@property (nonatomic, strong) UIView *leftControlPoint2;
@property (nonatomic, strong) UIView *leftControlPoint3;
@property (nonatomic, strong) UIView *rightControlPoint1;
@property (nonatomic, strong) UIView *rightControlPoint2;
@property (nonatomic, strong) UIView *rightControlPoint3;
@property (nonatomic, strong) UIView *bouncebackHelpView;
@property (nonatomic, strong) XZSpringRefreshLoadingView *springRefreshLoadingView;
@end

@implementation XZSpringRefreshView

- (id)init{

    self = [super init];
    if (self) {
        
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:CGRectZero];
    if(self){
        
        [self.layer addSublayer:self.shapeLayer];
        
        self.springState = XZSpringRefreshStop;
        
        [self addSubview:self.centerControlPoint];
        
        [self addSubview:self.leftControlPoint3];
        [self addSubview:self.leftControlPoint1];
        [self addSubview:self.leftControlPoint2];
        [self addSubview:self.rightControlPoint1];
        [self addSubview:self.rightControlPoint2];
        [self addSubview:self.rightControlPoint3];
        [self addSubview:self.bouncebackHelpView];
        
        [self addSubview:self.springRefreshLoadingView];
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLink_Method)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink.paused = YES;
        
    }
    return self;
}

- (void)layoutSubviews{

    [super layoutSubviews];
    if (!self.scrollView)
        return;
    CGFloat width = CGRectGetWidth(self.scrollView.frame);
    CGFloat height = self.scrollView.contentOffset.y;

    self.frame = CGRectMake(0, height, width, -height);
    
    if (self.springState == XZSpringRefreshDragging) {
        
        CGFloat locationX = [self.scrollView.panGestureRecognizer locationInView:self.scrollView].x;
        //水波浪的高度
        CGFloat waveHeight = MIN(CGRectGetHeight(self.bounds)/3.0*1.6, XZSpringRefreshWaveMaxHeight);
        CGFloat baseHeight = CGRectGetHeight(self.bounds) - waveHeight;
        
        self.centerControlPoint.center = CGPointMake(locationX, baseHeight + waveHeight * 1.36);
        
        CGFloat minLeftX = MIN((locationX - width/2.0f)*0.28, 0.0f);
        CGFloat leftPartWidth = locationX - minLeftX;
        
        self.leftControlPoint1.center = CGPointMake(minLeftX + leftPartWidth * 0.71, baseHeight + waveHeight*0.64);
        self.leftControlPoint2.center = CGPointMake(minLeftX + leftPartWidth * 0.44, baseHeight);
        self.leftControlPoint3.center = CGPointMake(minLeftX, baseHeight);
        
        CGFloat maxRightX = MAX(width + (locationX - width/2.0f)*0.28, width);
        CGFloat rightPartWidth = maxRightX - locationX;
        
        self.rightControlPoint1.center = CGPointMake(maxRightX - rightPartWidth * 0.71, baseHeight + waveHeight*0.64);
        self.rightControlPoint2.center = CGPointMake(maxRightX - rightPartWidth * 0.44, baseHeight);
        self.rightControlPoint3.center = CGPointMake(maxRightX, baseHeight);
        
        self.shapeLayer.path = [self currentPath].CGPath;
    }
    
    [self layoutLoadingView];
}

- (void)layoutLoadingView{
    
    CGFloat y;
    
    if (self.springState == XZSpringRefreshStop) {
        
        return;
    }else if (self.springState == XZSpringRefreshDragging) {
        
        y = MIN(CGRectGetHeight(self.frame)*0.5 - 20.f, XZSpringRefreshLoadingInset/2.0f-10.0f);
        
    }else if (self.springState == XZSpringRefreshBounceback){
        
        y = XZSpringRefreshLoadingInset/2.0f-10.0f;
    }
    
    self.springRefreshLoadingView.frame = CGRectMake((CGRectGetWidth(self.frame) - 20.0f)/2.0f, y, 20.0f, 20.0);
}

#pragma mark - Private_Methods
/**
 *  添加监听
 */
- (void)addObserving{
    
    if (!self.scrollView)
        return;
    [self addScrollViewContentOffsetObserver];
    [self.scrollView addObserver:self forKeyPath:XZSpringRefreshPanGestureRecognizerState options:NSKeyValueObservingOptionNew context:nil];
}

- (void)addScrollViewContentOffsetObserver{

    [self.scrollView addObserver:self forKeyPath:XZSpringRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeScrollViewContentOffsetObserver{
    
    [self.scrollView removeObserver:self forKeyPath:XZSpringRefreshContentOffset];
}

/**
 *  停止拖拽
 *
 *  @param offset 停止拖拽时的offset
 */
- (void)stopDragWithOffset:(CGFloat)offset{

    if (-offset > XZSpringRefreshMinDragOffset && self.springState == XZSpringRefreshDragging) {
        //回弹
        self.springState = XZSpringRefreshBounceback;
    }else if (offset <=0 && -offset < XZSpringRefreshMinDragOffset){

    }
}


- (UIBezierPath *)currentPath{

    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:[self getView:self.leftControlPoint3 presentationLayer:YES]];
    
    [path addCurveToPoint:[self getView:self.leftControlPoint1 presentationLayer:YES] controlPoint1:[self getView:self.leftControlPoint3 presentationLayer:YES] controlPoint2:[self getView:self.leftControlPoint2 presentationLayer:YES]];
    
    [path addCurveToPoint:[self getView:self.rightControlPoint1 presentationLayer:YES] controlPoint1:[self getView:self.centerControlPoint presentationLayer:YES] controlPoint2:[self getView:self.rightControlPoint1 presentationLayer:YES]];
    
    [path addCurveToPoint:[self getView:self.rightControlPoint3 presentationLayer:YES] controlPoint1:[self getView:self.rightControlPoint1 presentationLayer:YES] controlPoint2:[self getView:self.rightControlPoint2 presentationLayer:YES]];
    
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
    
    [path closePath];
    
    return path;
}

- (void)displayLink_Method{
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = 0.0f;

    if(self.springState == XZSpringRefreshBounceback){
        
        if (!self.scrollView)
            return;
        
        self.scrollView.contentInset = UIEdgeInsetsMake([self getView:self.bouncebackHelpView presentationLayer:YES].y, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);

        self.frame = CGRectMake(0, -height - 1.0, width, height);
        
    }else if (self.springState == XZSpringRefreshAnimationToStop){
    
//        NSLog(@"%f",self.scrollView.contentOffset.y);
    }


    
    
    self.shapeLayer.path = [self currentPath].CGPath;

}

- (CGPoint)getView:(UIView *)view presentationLayer:(BOOL)animation{

    if (animation) {
        
         CALayer *layer = (CALayer *)[view.layer presentationLayer];
        return layer.position;
    }else{
    
        return view.center;
    }
}

#pragma mark - Observe_Method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    CGFloat contentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue].y;
    
    if (keyPath == XZSpringRefreshContentOffset) {
        
        
        if (contentOffset < 0){
            [self layoutSubviews];
            self.springState = XZSpringRefreshDragging;
            
            CGFloat progress = -contentOffset / XZSpringRefreshMinDragOffset;
            NSLog(@"%f",progress);
            [self.springRefreshLoadingView setProgress:progress];
        }
        
    }else if (keyPath == XZSpringRefreshPanGestureRecognizerState){
    
        UIGestureRecognizerState gestureState = self.scrollView.panGestureRecognizer.state;
        if (gestureState == UIGestureRecognizerStateEnded || gestureState == UIGestureRecognizerStateFailed || gestureState == UIGestureRecognizerStateCancelled) {
            //停止拖拽
            [self stopDragWithOffset:self.scrollView.contentOffset.y];
        }
    }
}

#pragma mark - Setter && Getter
- (void)setObserving:(BOOL)observing{

    _observing = observing;
    if (_observing) {
        [self addObserving];
    }else{
    
    }
}

- (void)setSpringState:(XZSpringState)springState{

    _springState = springState;
    
    if (_springState == XZSpringRefreshAnimationToStop) {
        
//        [self removeScrollViewContentOffsetObserver];
        [UIView animateWithDuration:0.35 animations:^{
            
            self.scrollView.contentInset = UIEdgeInsetsZero;
//
            
        } completion:^(BOOL finished) {
            
//            [self addScrollViewContentOffsetObserver];
            
            self.springState = XZSpringRefreshStop;
            
            CGFloat width = self.scrollView.bounds.size.width;
            self.centerControlPoint.center = CGPointMake(width / 2.0, 0);
            self.leftControlPoint1.center = CGPointMake(0, 0);
            self.leftControlPoint2.center = CGPointMake(0, 0);
            self.leftControlPoint3.center = CGPointMake(0, 0);
            self.rightControlPoint1.center = CGPointMake(width, 0);
            self.rightControlPoint2.center = CGPointMake(width, 0);
            self.rightControlPoint3.center = CGPointMake(width, 0);
            self.shapeLayer.path = [self currentPath].CGPath;
        }];
        
        NSLog(@"AnimationToStop");
      
    }else if (_springState == XZSpringRefreshBounceback){
    
        NSLog(@"Bounceback");
        
        [self.springRefreshLoadingView startAnimating];
        
        self.scrollView.scrollEnabled = NO;
        
        self.displayLink.paused = NO;
        
        [self removeScrollViewContentOffsetObserver];
        
        [UIView animateWithDuration:0.9 delay:0 usingSpringWithDamping:0.43 initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
            self.centerControlPoint.center = CGPointMake(self.centerControlPoint.center.x, XZSpringRefreshLoadingInset);
            self.leftControlPoint1.center = CGPointMake(self.leftControlPoint1.center.x, XZSpringRefreshLoadingInset);
            self.leftControlPoint2.center = CGPointMake(self.leftControlPoint2.center.x, XZSpringRefreshLoadingInset);
            self.leftControlPoint3.center = CGPointMake(self.leftControlPoint3.center.x, XZSpringRefreshLoadingInset);
            self.rightControlPoint1.center = CGPointMake(self.rightControlPoint1.center.x, XZSpringRefreshLoadingInset);
            self.rightControlPoint2.center = CGPointMake(self.rightControlPoint2.center.x, XZSpringRefreshLoadingInset);
            self.rightControlPoint3.center = CGPointMake(self.rightControlPoint3.center.x, XZSpringRefreshLoadingInset);
            
        } completion:^(BOOL finished) {
            
            self.displayLink.paused = YES;
//
//
            [self addScrollViewContentOffsetObserver];
            self.springState = XZSpringRefreshLoading;
            
        }];
        
        self.bouncebackHelpView.center = CGPointMake(0, -self.scrollView.contentOffset.y);
        [UIView animateWithDuration:0.35 animations:^{
           
            self.bouncebackHelpView.center = CGPointMake(0, XZSpringRefreshLoadingInset);
        }];
        
    }
    
    else if (_springState == XZSpringRefreshLoading){
    
        NSLog(@"Loading");
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.springState = XZSpringRefreshAnimationToStop;
            [self.springRefreshLoadingView stopLoading];
        });
        
    }else if (_springState == XZSpringRefreshStop){
    
        self.scrollView.scrollEnabled = YES;
    }
    
}

- (UIScrollView *)scrollView{
    
    return (UIScrollView *)self.superview;
}

- (CAShapeLayer *)shapeLayer{

    if (!_shapeLayer) {
        
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor greenColor].CGColor;
    }
    return _shapeLayer;
}

- (UIView *)centerControlPoint{

    if (!_centerControlPoint) {
        
        _centerControlPoint = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _centerControlPoint.backgroundColor = [UIColor yellowColor];
    }
    return _centerControlPoint;
}

- (UIView *)leftControlPoint1{

    if (!_leftControlPoint1) {
        
        _leftControlPoint1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _leftControlPoint1.backgroundColor = [UIColor blackColor];
    }
    return _leftControlPoint1;
}

- (UIView *)leftControlPoint2{
    
    if (!_leftControlPoint2) {
        
        _leftControlPoint2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _leftControlPoint2.backgroundColor = [UIColor blackColor];
    }
    return _leftControlPoint2;
}

- (UIView *)leftControlPoint3{
    
    if (!_leftControlPoint3) {
        
        _leftControlPoint3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _leftControlPoint3.backgroundColor = [UIColor blackColor];
    }
    return _leftControlPoint3;
}

- (UIView *)rightControlPoint1{

    if (!_rightControlPoint1) {
        
        _rightControlPoint1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _rightControlPoint1.backgroundColor = [UIColor purpleColor];
    }
    return _rightControlPoint1;
}

- (UIView *)rightControlPoint2{
    
    if (!_rightControlPoint2) {
        
        _rightControlPoint2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _rightControlPoint2.backgroundColor = [UIColor purpleColor];
    }
    return _rightControlPoint2;
}

- (UIView *)rightControlPoint3{
    
    if (!_rightControlPoint3) {
        
        _rightControlPoint3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _rightControlPoint3.backgroundColor = [UIColor purpleColor];
    }
    return _rightControlPoint3;
}

- (UIView *)bouncebackHelpView{

    if (!_bouncebackHelpView) {
        
        _bouncebackHelpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _bouncebackHelpView.backgroundColor = [UIColor grayColor];
    }
    return _bouncebackHelpView;
}

- (XZSpringRefreshLoadingView *)springRefreshLoadingView{

    if (!_springRefreshLoadingView) {
     
        _springRefreshLoadingView = [[XZSpringRefreshLoadingView alloc] init];
        _springRefreshLoadingView.backgroundColor = [UIColor blackColor];
    }
    return _springRefreshLoadingView;
}
@end
