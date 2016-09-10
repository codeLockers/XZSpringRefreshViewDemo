//
//  XZSpringRefreshLoadingView.h
//  XZSpringRefreshView
//
//  Created by 徐章 on 16/9/8.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZSpringRefreshLoadingView : UIView

- (void)setProgress:(CGFloat)progress;

- (void)startAnimating;

- (void)stopLoading;

@end
