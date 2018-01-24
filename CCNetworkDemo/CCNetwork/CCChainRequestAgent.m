//
//  CCChainRequestAgent.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/23.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCChainRequestAgent.h"
#import "CCChainRequest.h"

@interface CCChainRequestAgent()

@property (nonatomic,strong)NSMutableArray<CCChainRequest *> * requestArray;

@end

@implementation CCChainRequestAgent

+ (CCChainRequestAgent *)sharedAgent {
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

- (void)addChainRequest:(CCChainRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeChainRequest:(CCChainRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}

@end
