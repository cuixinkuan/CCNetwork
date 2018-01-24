//
//  CCBatchRequestAgent.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCBatchRequestAgent.h"
#import "CCBatchRequest.h"

@interface CCBatchRequestAgent()

@property (nonatomic,strong)NSMutableArray<CCBatchRequest *> * requestArray;

@end

@implementation CCBatchRequestAgent

+ (CCBatchRequestAgent *)sharedAgent {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addBatchRequest:(CCBatchRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeBatchRequest:(CCBatchRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}

@end
