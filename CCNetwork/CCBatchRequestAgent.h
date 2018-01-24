//
//  CCBatchRequestAgent.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CCBatchRequest;

@interface CCBatchRequestAgent : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (CCBatchRequestAgent *)sharedAgent;

- (void)addBatchRequest:(CCBatchRequest *)request;
- (void)removeBatchRequest:(CCBatchRequest *)request;

@end
NS_ASSUME_NONNULL_END
