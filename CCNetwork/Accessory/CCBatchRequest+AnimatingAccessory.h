//
//  CCBatchRequest+AnimatingAccessory.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCBatchRequest.h"

@interface CCBatchRequest (AnimatingAccessory)

@property (nonatomic,weak)UIView * animatingView;

@property (nonatomic,strong)NSString * animatingText;

@end
