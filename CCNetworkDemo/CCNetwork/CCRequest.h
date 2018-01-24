//
//  CCRequest.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/16.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const CCRequestCacheErrorDomain;
NS_ENUM(NSInteger) {
    CCRequestCacheErrorExpired = -1,
    CCRequestCacheErrorVersionMismatch = -2,
    CCRequestCacheErrorSensitiveDataMismatch = -3,
    CCRequestCacheErrorAppVersionMismatch = -4,
    CCRequestCacheErrorInvalidCacheTime = -5,
    CCRequestCacheErrorInvalidMetadata = -6,
    CCRequestCacheErrorInvalidCacheData = -7,
};

@interface CCRequest : CCBaseRequest
// Whether to use cache as response or not , default is NO
@property (nonatomic)BOOL ignoreCache;
// Whether data is from local cache
- (BOOL)isDataFromCache;
// Whther cache is successfully loaded
- (BOOL)loadCacheWithError:(NSError * __autoreleasing *)error;
//Start request without reading local cache even if it exists.
- (void)startWithoutCache;
// Save response data to this request's cache location
- (void)saveResponseDataToCacheFile:(NSData *)data;

#pragma  mark - Subclass Override -
// 通过覆盖 cacheTimeInSeconds 方法，添加时间缓存，**分钟内调用调 Api 的 start 方法，实际上并不会发送真正的请求。
- (NSInteger)cacheTimeInSeconds;

- (long long)cacheVersion;

- (nullable id)cacheSensitiveData;
// Whether cache is asynchronously written to storage. Default is YES.
- (BOOL)writeCacheAsynchronously;

@end
    
NS_ASSUME_NONNULL_END
