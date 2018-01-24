//
//  CCChainRequestAgent.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/23.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CCChainRequest;

@interface CCChainRequestAgent : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (CCChainRequestAgent *)sharedAgent;

- (void)addChainRequest:(CCChainRequest *)request;

- (void)removeChainRequest:(CCChainRequest *)request;

@end
NS_ASSUME_NONNULL_END
