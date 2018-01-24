//
//  CCBatchRequest.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCBatchRequest.h"
#import "CCNetworkPrivate.h"
#import "CCBatchRequestAgent.h"
#import "CCRequest.h"

@interface CCBatchRequest() <CCRequestDelegate>

@property (nonatomic)NSInteger finishedCount;

@end


@implementation CCBatchRequest

- (instancetype)initWithRequestArray:(NSArray<CCRequest *> *)requestArray {
    if (self = [super init]) {
        _requestArray = [requestArray copy];
        _finishedCount = 0;
        for (CCRequest * req in _requestArray) {
            if (![req isKindOfClass:[CCRequest class]]) {
                CCLog(@"Error, request item must be CCRequest instance.");
                return nil;
            }
        }
    }
    return self;
}

- (void)start {
    if (_finishedCount > 0) {
        CCLog(@"Error,Batch request has already started.");
        return;
    }
    _failedRquest = nil;
    [[CCBatchRequestAgent sharedAgent] addBatchRequest:self];
    [self toggleAccessoriesWillStartCallBack];
    for (CCRequest * req in _requestArray) {
        req.delegate = self;
        [req clearCompletionBlock];
        [req start];
    }
}

- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    _delegate = nil;
    [self clearRequest];
    [self toggleAccessoriesDidStopCallBack];
    [[CCBatchRequestAgent sharedAgent] removeBatchRequest:self];
}

- (void)startWithCompletionBlockWithSuccess:(void (^)(CCBatchRequest * _Nonnull))success failure:(void (^)(CCBatchRequest * _Nonnull))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(void (^)(CCBatchRequest * _Nonnull))success failure:(void (^)(CCBatchRequest * _Nonnull))failure {
    self.successCompletionBlock = success;
    self.failedCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    self.successCompletionBlock = nil;
    self.failedCompletionBlock = nil;
}

- (BOOL)isDataFromCache {
    BOOL result = YES;
    for (CCRequest * request in _requestArray) {
        if (!request.isDataFromCache) {
            result = NO;
        }
    }
    return result;
}

- (void)dealloc {
    [self clearRequest];
}

#pragma mark - Network Request Delegate -
- (void)requestFinished:(CCRequest *)request {
    _finishedCount ++;
    if (_finishedCount == _requestArray.count) {
        [self toggleAccessoriesWillStopCallBack];
        if ([_delegate respondsToSelector:@selector(batchRequestFinished:)]) {
            [_delegate batchRequestFinished:self];
        }
        if (_successCompletionBlock) {
            _successCompletionBlock(self);
        }
        [self clearCompletionBlock];
        [self toggleAccessoriesDidStopCallBack];
        [[CCBatchRequestAgent sharedAgent] removeBatchRequest:self];
    }
}

- (void)requestFailed:(CCRequest *)request {
    _failedRquest = request;
    [self toggleAccessoriesWillStopCallBack];
    // Stop
    for (CCRequest * req in _requestArray) {
        [req stop];
    }
    // Callback
    if ([_delegate respondsToSelector:@selector(batchRequestFailed:)]) {
        [_delegate batchRequestFailed:self];
    }
    if (_failedCompletionBlock) {
        _failedCompletionBlock(self);
    }
    // Clear
    [self clearCompletionBlock];
    
    [self toggleAccessoriesDidStopCallBack];
    [[CCBatchRequestAgent sharedAgent] removeBatchRequest:self];
}

- (void)clearRequest {
    for (CCRequest * req in _requestArray) {
        [req stop];
    }
    [self clearCompletionBlock];
}

#pragma mark - Request Accessoies -
- (void)addAccessory:(id<CCRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end
