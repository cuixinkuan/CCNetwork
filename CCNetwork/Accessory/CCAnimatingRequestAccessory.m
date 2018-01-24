//
//  CCAnimatingRequestAccessory.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCAnimatingRequestAccessory.h"
#import "CCAlertUtils.h"

@implementation CCAnimatingRequestAccessory

- (id)initWithAnimatingView:(UIView *)animatingView {
    if (self = [super init]) {
        _animatingView = animatingView;
    }
    return self;
}

- (id)initWithAnimatingView:(UIView *)animatingView animatingText:(NSString *)animatingText {
    if (self = [super init]) {
        _animatingView = animatingView;
        _animatingText = animatingText;
    }
    return self;
}

+ (id)accessoryWithAnimatingView:(UIView *)animatingView {
    return [[self alloc] initWithAnimatingView:animatingView];
}

+ (id)accessoryWithAnimatingView:(UIView *)animatingView animatingText:(NSString *)animatingText {
    return [[self alloc] initWithAnimatingView:animatingView animatingText:animatingText];
}

#pragma mark - CCRequestAccessory -
- (void)requestWillStart:(id)request {
    if (_animatingView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // TODO: show loading
            [CCAlertUtils showLoadingAlertView:@"loading..." inView:_animatingView];
            NSLog(@"--------> loading start");
        });
    }
}

- (void)requestWillStop:(id)request {
    if (_animatingView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // TODO: hide loading
            [CCAlertUtils hideLoadingView];
            NSLog(@"--------> loading finished");
        });
    }
}

@end
