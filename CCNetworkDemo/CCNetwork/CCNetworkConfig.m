//
//  CCNetworkConfig.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/16.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCNetworkConfig.h"
#import "CCBaseRequest.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@implementation CCNetworkConfig {
    NSMutableArray<id<CCUrlFilterProtocol>> * _urlFilters;
    NSMutableArray<id<CCCacheDirPathFilterProtocol>> * _cacheDirPathFilters;
}

+ (CCNetworkConfig *)sharedConfig {
    static id shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _baseUrl = @"";
        _cdnUrl = @"";
        _urlFilters = [NSMutableArray array];
        _cacheDirPathFilters = [NSMutableArray array];
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        _debugLogEnabled = NO;
    }
    return self;
}

- (void)addUrlFilter:(id<CCUrlFilterProtocol>)filter {
    [_urlFilters addObject:filter];
}

- (void)clearUrlFilter {
    [_urlFilters removeAllObjects];
}

- (void)addCacheDirPathFilter:(id<CCCacheDirPathFilterProtocol>)filter {
    [_cacheDirPathFilters addObject:filter];
}

- (void)clearCacheDirPathFilter {
    [_cacheDirPathFilters removeAllObjects];
}

- (NSArray<id<CCUrlFilterProtocol>> *)urlFilters {
    return [_urlFilters copy];
}

- (NSArray<id<CCCacheDirPathFilterProtocol>> *)cacheDirPathFilters {
    return [_cacheDirPathFilters copy];
}

#pragma mark - NSObject -
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ baseURL: %@} { cdnURL: %@ }",NSStringFromClass([self class]),self,self.baseUrl,self.cdnUrl];
}

@end
