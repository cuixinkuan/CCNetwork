//
//  CCChainRequest.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CCChainRequest;
@class CCBaseRequest;
@protocol CCRequestAccessory;

@protocol CCChainRequestDelegate <NSObject>

@optional

// Tell the delegate that the chain request has finished successfully.
- (void)chainRequestFinished:(CCChainRequest *)chainRequest;
// Tell the delegate that the chain request has failed.
- (void)chainRequestFailed:(CCChainRequest *)chainRequest failedBaseRequest:(CCBaseRequest *)request;

@end

typedef void (^CCChainCallback)(CCChainRequest * chainRequest, CCBaseRequest * baseRequest);

@interface CCChainRequest : NSObject

- (NSArray<CCBaseRequest *> *)requestArray;

@property (nonatomic,weak,nullable) id<CCChainRequestDelegate> delegate;

@property (nonatomic,strong,nullable) NSMutableArray<id<CCRequestAccessory>> * requestAccessories;

- (void)addAccessory:(id<CCRequestAccessory>) accessory;

- (void)start;

- (void)stop;

- (void)addRequest:(CCBaseRequest *)request callback:(nullable CCChainCallback)callback;

@end

NS_ASSUME_NONNULL_END
