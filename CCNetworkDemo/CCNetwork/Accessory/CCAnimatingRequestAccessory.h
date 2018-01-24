//
//  CCAnimatingRequestAccessory.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBaseRequest.h"

@interface CCAnimatingRequestAccessory : NSObject <CCRequestAccessory>

@property (nonatomic,weak)UIView * animatingView;;
@property (nonatomic,strong)NSString * animatingText;

- (id)initWithAnimatingView:(UIView *)animatingView;
- (id)initWithAnimatingView:(UIView *)animatingView animatingText:(NSString *)animatingText;

+ (id)accessoryWithAnimatingView:(UIView *)animatingView;
+ (id)accessoryWithAnimatingView:(UIView *)animatingView animatingText:(NSString *)animatingText;

@end
