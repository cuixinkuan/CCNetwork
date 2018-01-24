//
//  CCBaseRequest+AnimatingAccessory.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CCBaseRequest.h"

@interface CCBaseRequest (AnimatingAccessory)

@property (nonatomic,weak)UIView * animatingView;
@property (nonatomic,strong)NSString * animatingText;

@end
