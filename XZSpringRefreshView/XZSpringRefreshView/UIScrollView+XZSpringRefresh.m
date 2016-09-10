//
//  UIScrollView+XZSpringRefresh.m
//  XZSpringRefreshView
//
//  Created by 徐章 on 16/9/5.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "UIScrollView+XZSpringRefresh.h"
#import "XZSpringRefreshView.h"

@implementation UIScrollView (XZSpringRefresh)

- (void)xz_springRefresh{

    self.multipleTouchEnabled = NO;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    
    XZSpringRefreshView *springRefreshView = [[XZSpringRefreshView alloc] init];
    springRefreshView.backgroundColor = [UIColor redColor];
    [self addSubview:springRefreshView];
    springRefreshView.observing = YES;
}

@end
