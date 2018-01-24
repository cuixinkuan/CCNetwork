//
//  CCBaseRequest+AnimatingAccessory.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCBaseRequest+AnimatingAccessory.h"
#import "CCAnimatingRequestAccessory.h"

@implementation CCBaseRequest (AnimatingAccessory)

- (CCAnimatingRequestAccessory *)animatingRequestAccessory {
    for (id accessory in self.requestAccessories) {
        if ([accessory isKindOfClass:[CCAnimatingRequestAccessory class]]) {
            return accessory;
        }
    }
    return nil;
}

- (UIView *)animatingView {
    return self.animatingRequestAccessory.animatingView;
}

- (void)setAnimatingView:(UIView *)animatingView {
    if (!self.animatingRequestAccessory) {
        [self addAccessory:[CCAnimatingRequestAccessory accessoryWithAnimatingView:animatingView animatingText:nil]];
    }else {
        self.animatingRequestAccessory.animatingView = animatingView;
    }
}

- (NSString *)animatingText {
    return self.animatingRequestAccessory.animatingText;
}

- (void)setAnimatingText:(NSString *)animatingText {
    if (!self.animatingRequestAccessory) {
        [self addAccessory:[CCAnimatingRequestAccessory accessoryWithAnimatingView:nil animatingText:animatingText]];
    }else {
        self.animatingRequestAccessory.animatingText = animatingText;
    }
}

@end
