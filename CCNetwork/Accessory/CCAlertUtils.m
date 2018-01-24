//
//  CCAlertUtils.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/15.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCAlertUtils.h"
#define SCREEN_WIDTH CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT CGRectGetHeight([[UIScreen mainScreen] bounds])

@implementation CCAlertUtils {
    int theta;
    NSTimer * _timer;
}

static CCAlertUtils * instance = nil;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CCAlertUtils alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if(self = [super init]){
        [self createLoadUI];
    }
    return self;
}

+ (void)showLoadingAlertView:(NSString *)animatingText inView:(UIView *)animatingView {
    CCAlertUtils * instance = [self shared];
    instance.titleLabel.text = animatingText;
    [animatingView addSubview:instance];
}

+ (void)hideLoadingView {
    [[self shared] removeFromSuperview];
}

// 自定义加载动画
- (void)createLoadUI {
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    
    CGFloat whi_W = 80;
    CGFloat whi_H = 100;
    UIView * whiteView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 80)/2, (SCREEN_HEIGHT - 100)/2, 80, 100)];
    whiteView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    whiteView.layer.cornerRadius = 10;
    [self addSubview:whiteView];
    
    CGFloat image_WH = 90;
    UIImageView * centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((whi_W - image_WH)/2.0, (whi_H - image_WH)/2.0 - (whi_H - image_WH)/2.0, image_WH, image_WH)];
    centerImageView.image = [UIImage imageNamed:@"loading_bg.png"];
    [whiteView addSubview:centerImageView];
    
    CGFloat loading_WH = 75;
    UIImageView *loadingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, loading_WH, loading_WH)];
    loadingImgView.tag = 101;
    loadingImgView.image = [UIImage imageNamed:@"loading.png"];
    loadingImgView.center = centerImageView.center;
    [whiteView addSubview:loadingImgView];
    
    CGFloat lab_H = 20;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, whi_H - lab_H, whi_W, lab_H)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"";
    [whiteView addSubview:self.titleLabel];
    
    // loading动画
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(loadingAnimationWithTimer:) userInfo:nil repeats:YES];
    [self loadingAnimationWithTimer:nil];
}

- (void)loadingAnimationWithTimer:(NSTimer *)aTimer {
    // Rotate each iteration by 1% of PI
    CGFloat angle = theta * (M_PI / 100.0f);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    // Theta ranges between 0% and 199% of PI, i.e. between 0 and 2*PI
    theta = (theta + 1) % 200;
    CGAffineTransform scaled = CGAffineTransformScale(transform, 1.0, 1.0);
    // Apply the affine transform
    [[self viewWithTag:101] setTransform:scaled];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
