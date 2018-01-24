//
//  CCBatchRequest.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CCRequest;
@class CCBatchRequest;
@protocol CCRequestAccessory;

@protocol CCBatchRequestDelegate <NSObject>

@optional

// Tell the delegate that the batch request has finished successfully.
- (void)batchRequestFinished:(CCBatchRequest *)batchRequest;
// Tell the delegate that the batch request has failed.
- (void)batchRequestFailed:(CCBatchRequest *)batchRequest;

@end

/// CCBatchRequest can be used to batch several CCRequest. Note that when used inside CCBatchRequest, a single CCRequest will have its own callback and delegate cleared, in favor of the batch request callback.
@interface CCBatchRequest : NSObject

@property (nonatomic,strong,readonly)NSArray<CCRequest *> * requestArray;

@property (nonatomic,weak,nullable)id<CCBatchRequestDelegate> delegate;

@property (nonatomic,copy,nullable)void (^successCompletionBlock)(CCBatchRequest *);

@property (nonatomic,copy,nullable)void (^failedCompletionBlock)(CCBatchRequest *);

@property (nonatomic)NSInteger tag;

@property (nonatomic,strong,nullable)NSMutableArray<id<CCRequestAccessory>> * requestAccessories;

@property (nonatomic,strong,readonly,nullable)CCRequest * failedRquest;

- (instancetype)initWithRequestArray:(NSArray<CCRequest *> *)requestArray;

- (void)setCompletionBlockWithSuccess:(nullable void (^)(CCBatchRequest *batchRequest))success
                              failure:(nullable void (^)(CCBatchRequest *batchRequest))failure;

- (void)clearCompletionBlock;

- (void)addAccessory:(id<CCRequestAccessory>)accessory;

- (void)start;

- (void)stop;

- (void)startWithCompletionBlockWithSuccess:(nullable void (^)(CCBatchRequest *batchRequest))success
                                    failure:(nullable void (^)(CCBatchRequest *batchRequest))failure;

- (BOOL)isDataFromCache;

@end
NS_ASSUME_NONNULL_END
