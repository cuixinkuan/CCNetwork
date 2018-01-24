//
//  CCChainRequest.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCChainRequest.h"
#import "CCChainRequestAgent.h"
#import "CCNetworkPrivate.h"
#import "CCBaseRequest.h"

@interface CCChainRequest() <CCRequestDelegate>

@property (nonatomic,strong)NSMutableArray<CCBaseRequest *> * requestArray;
@property (nonatomic,strong)NSMutableArray<CCChainCallback> * requestCallbackArray;
@property (nonatomic,assign)NSUInteger nextRequestIndex;
@property (nonatomic,strong)CCChainCallback emptyCallback;

@end

@implementation CCChainRequest

- (instancetype)init {
    if (self = [super init]) {
        _nextRequestIndex = 0;
        _requestArray = [NSMutableArray array];
        _requestCallbackArray = [NSMutableArray array];
        _emptyCallback = ^(CCChainRequest *chainRequest, CCBaseRequest *baseRequest) {
            // do nothing.
        };
    }
    return self;
}

- (void)start {
    if (_nextRequestIndex > 0) {
        CCLog(@"Error! Chain request has already started.");
        return;
    }
    
    if ([_requestArray count] > 0) {
        [self toggleAccessoriesWillStartCallBack];
        [self startNextRequest];
        [[CCChainRequestAgent sharedAgent] addChainRequest:self];
    }else {
        CCLog(@"Error! Chain request array is empty.");
    }
}

- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    [self clearRequest];
    [[CCChainRequestAgent sharedAgent] removeChainRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)addRequest:(CCBaseRequest *)request callback:(CCChainCallback)callback {
    [_requestArray addObject:request];
    if (callback != nil) {
        [_requestCallbackArray addObject:callback];
    }else {
        [_requestCallbackArray addObject:_emptyCallback];
    }
}

- (NSArray<CCBaseRequest *> *)requestArray {
    return _requestArray;
}

- (BOOL)startNextRequest {
    if (_nextRequestIndex < [_requestArray count]) {
        CCBaseRequest * request = _requestArray[_nextRequestIndex];
        _nextRequestIndex ++;
        request.delegate = self;
        [request clearCompletionBlock];
        [request start];
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - Network Request Delegate -
- (void)requestFinished:(__kindof CCBaseRequest *)request {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    CCChainCallback callback = _requestCallbackArray[currentRequestIndex];
    callback(self, request);
    if (![self startNextRequest]) {
        [self toggleAccessoriesWillStopCallBack];
        if ([_delegate respondsToSelector:@selector(chainRequestFinished:)]) {
            [_delegate chainRequestFinished:self];
            [[CCChainRequestAgent sharedAgent] removeChainRequest:self];
        }
        [self toggleAccessoriesDidStopCallBack];
    }
}

- (void)requestFailed:(__kindof CCBaseRequest *)request {
    [self toggleAccessoriesWillStopCallBack];
    if ([_delegate respondsToSelector:@selector(chainRequestFailed:failedBaseRequest:)]) {
        [_delegate chainRequestFailed:self failedBaseRequest:request];
        [[CCChainRequestAgent sharedAgent] removeChainRequest:self];
    }
    [self toggleAccessoriesDidStopCallBack];
}

- (void)clearRequest {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    if (currentRequestIndex < [_requestArray count]) {
        CCBaseRequest * request = _requestArray[currentRequestIndex];
        [request stop];
    }
    [_requestArray removeAllObjects];
    [_requestCallbackArray removeAllObjects];
}

#pragma mark - Request Accessories -
- (void)addAccessory:(id<CCRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end
