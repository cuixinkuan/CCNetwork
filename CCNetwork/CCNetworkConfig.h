//
//  CCNetworkConfig.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/16.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CCBaseRequest;
@class AFSecurityPolicy;

@protocol CCUrlFilterProtocol <NSObject>

/**
 Preprocess request url before actually sending them.

 @param originUrl request's origin url
 @param request request itself
 @return a new url
 */
- (NSString * )filterUrl:(NSString *)originUrl withRequest:(CCBaseRequest *)request;

@end

@protocol CCCacheDirPathFilterProtocol <NSObject>

/**
 Preprocess cache path before actually sending them.

 @param originPath original base cache path
 @param request request itself
 @return a new path which will be used as base path when caching
 */
- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(CCBaseRequest *)request;

@end

@interface CCNetworkConfig : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

// Return a shared config object
+ (CCNetworkConfig *)sharedConfig;

@property (nonatomic,strong)NSString * baseUrl;

@property (nonatomic,strong)NSString * cdnUrl;

@property (nonatomic,strong,readonly)NSArray<id<CCUrlFilterProtocol>> * urlFilters;

@property (nonatomic,strong,readonly)NSArray<id<CCCacheDirPathFilterProtocol>> * cacheDirPathFilters;

@property (nonatomic,strong)AFSecurityPolicy * securityPolicy;

@property (nonatomic)BOOL debugLogEnabled;

@property (nonatomic,strong)NSURLSessionConfiguration * sessionConfiguration;

- (void)addUrlFilter:(id<CCUrlFilterProtocol>)filter;

- (void)clearUrlFilter;

- (void)addCacheDirPathFilter:(id<CCCacheDirPathFilterProtocol>)filter;

- (void)clearCacheDirPathFilter;

@end

NS_ASSUME_NONNULL_END
