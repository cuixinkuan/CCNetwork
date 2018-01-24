//
//  CCRequest.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/16.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCRequest.h"
#import "CCNetworkConfig.h"
#import "CCNetworkPrivate.h"

#ifdef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_QoS_Available 1140.11
#else
#define NSFoundationVersionNumber_With_QoS_Available NSFoundationVersionNumber_iOS_8_0
#endif

NSString * const CCRequestCacheErrorDomain = @"com.ceair.request.caching";

static dispatch_queue_t ccrequest_cache_writing_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_With_QoS_Available) {
            attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_BACKGROUND, 0);
        }
        queue = dispatch_queue_create("com.ceair.request.caching", attr);
    });
    return queue;
}

@interface CCCacheMetadata : NSObject<NSSecureCoding>

@property (nonatomic,assign)long long version;
@property (nonatomic,strong)NSString * sensitiveDataString;
@property (nonatomic,assign)NSStringEncoding stringEncoding;
@property (nonatomic,strong)NSDate * creationDate;
@property (nonatomic,strong)NSString * appVersionString;

@end

@implementation CCCacheMetadata

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.version) forKey:NSStringFromSelector(@selector(version))];
    [aCoder encodeObject:self.sensitiveDataString forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    [aCoder encodeObject:@(self.stringEncoding) forKey:NSStringFromSelector(@selector(stringEncoding))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:self.appVersionString forKey:NSStringFromSelector(@selector(appVersionString))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.version = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(version))] integerValue];
    self.sensitiveDataString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    self.stringEncoding = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(stringEncoding))] integerValue];
    self.creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
    self.appVersionString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionString))];
    
    return self;
}

@end

@interface CCRequest ()

@property (nonatomic,strong)NSData * cacheData;
@property (nonatomic,strong)NSString * cacheString;
@property (nonatomic,strong)id cacheJSON;
@property (nonatomic,strong)NSXMLParser * cacheXML;

@property (nonatomic,strong)CCCacheMetadata * cacheMetadata;
@property (nonatomic,assign)BOOL dataFromCache;

@end

@implementation CCRequest

- (void)start {
    if (self.ignoreCache) {
        [self startWithoutCache];
        return;
    }
    // Do not cache downloadCache
    if (self.resumableDownloadPath) {
        [self startWithoutCache];
        return;
    }
    if (![self loadCacheWithError:nil]) {
        [self startWithoutCache];
        return;
    }
    
    _dataFromCache = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestCompletePreprocessor];
        [self requestCompleteFilter];
        CCRequest * StrongSelf = self;
        [StrongSelf.delegate requestFinished:StrongSelf];
        if (StrongSelf.successCompletionBlock) {
            StrongSelf.successCompletionBlock(StrongSelf);
        }
        [StrongSelf clearCompletionBlock];
    });
}

- (void)startWithoutCache {
    [self clearCacheVariables];
    [super start];
}

- (void)clearCacheVariables {
    _cacheData = nil;
    _cacheXML = nil;
    _cacheJSON = nil;
    _cacheString = nil;
    _cacheMetadata = nil;
    _dataFromCache = NO;
}

#pragma mark - Network Request Delegate -
- (void)requestCompletePreprocessor {
    [super requestCompletePreprocessor];
    
    if (self.writeCacheAsynchronously) {
        dispatch_async(ccrequest_cache_writing_queue(), ^{
            [self saveResponseDataToCacheFile:[super responseData]];
        });
    }else {
        [self saveResponseDataToCacheFile:[super responseData]];
    }
}

#pragma mark - Subcalss Override -
- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (long long)cacheVersion {
    return 0;
}

- (id)cacheSensitiveData {
    return nil;
}

- (BOOL)writeCacheAsynchronously {
    return YES;
}

#pragma mark -
- (BOOL)isDataFromCache {
    return _dataFromCache;
}

- (NSData *)responseData {
    if (_cacheData) {
        return _cacheData;
    }
    return [super responseData];
}

- (NSString *)responseString {
    if (_cacheString) {
        return _cacheString;
    }
    return [super responseString];
}

- (id)responseJSONObject {
    if (_cacheJSON) {
        return _cacheJSON;
    }
    return [super responseJSONObject];
}

- (id)responseObject {
    if (_cacheJSON) {
        return _cacheJSON;
    }
    if (_cacheXML) {
        return _cacheXML;
    }
    if (_cacheData) {
        return _cacheData;
    }
    return [super responseObject];
}

#pragma mark -
- (BOOL)loadCacheWithError:(NSError * _Nullable __autoreleasing *)error {
    // Make sure cache time in valid.
    if ([self cacheTimeInSeconds] < 0) {
        if (error) {
            * error = [NSError errorWithDomain:CCRequestCacheErrorDomain code:CCRequestCacheErrorInvalidCacheTime userInfo:@{NSLocalizedDescriptionKey:@"Invalid cache time"}];
        }
        return NO;
    }
    
    // Try load metadata.
    if (![self loadCacheMetadata]) {
        if (error) {
            * error = [NSError errorWithDomain:CCRequestCacheErrorDomain code:CCRequestCacheErrorInvalidMetadata userInfo:@{NSLocalizedDescriptionKey:@"Invalid metadata. Cache may not exist"}];
        }
        return NO;
    }
    
    // Check if cache is still valid.
    if (![self validateCacheWithError:error]) {
        return NO;
    }
    
    // Try load cache.
    if (![self loadCacheData]) {
        if (error) {
            *error = [NSError errorWithDomain:CCRequestCacheErrorDomain code:CCRequestCacheErrorInvalidCacheData userInfo:@{NSLocalizedDescriptionKey:@"Invalid cache data"}];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)validateCacheWithError:(NSError * _Nullable __autoreleasing *)error {
    // Date
    NSDate * createDate = self.cacheMetadata.creationDate;
    NSTimeInterval duration = -[createDate timeIntervalSinceNow];
    if (duration < 0 || duration > [self cacheTimeInSeconds]) {
        if (error) {
            *error = [NSError errorWithDomain:CCRequestCacheErrorDomain code:CCRequestCacheErrorExpired userInfo:@{NSLocalizedDescriptionKey:@"Cache expried"}];
        }
        return NO;
    }
    
    // Version
    long long cacheVersionfileContent = self.cacheMetadata.version;
    if (cacheVersionfileContent != [self cacheVersion]) {
        if (error) {
            *error = [NSError errorWithDomain:CCRequestCacheErrorDomain code:CCRequestCacheErrorVersionMismatch userInfo:@{NSLocalizedDescriptionKey:@"Cache version mismatch"}];
        }
        return NO;
    }
    
    // Sensitive data
    NSString * sensitiveDataString = self.cacheMetadata.sensitiveDataString;
    NSString * currentSentiveDataString = ((NSObject *)[self cacheSensitiveData]).description;
    if (sensitiveDataString || currentSentiveDataString) {
        // If one of the strings is nil, short-circuit evluation will trigger.
        if (sensitiveDataString.length != currentSentiveDataString.length || ![sensitiveDataString isEqualToString:currentSentiveDataString]) {
            if (error) {
                *error = [NSError errorWithDomain:CCRequestCacheErrorDomain code:CCRequestCacheErrorSensitiveDataMismatch userInfo:@{NSLocalizedDescriptionKey:@"Cache sensitive data mismatch"}];
            }
            return NO;
        }
    }
    
    // App version
    NSString * appVersionString = self.cacheMetadata.appVersionString;
    NSString * currentAppVersionString = [CCNetworkUtils appVersionString];
    if (appVersionString || currentAppVersionString) {
        if (appVersionString.length != currentAppVersionString.length || ![appVersionString isEqualToString:currentAppVersionString]) {
            if (error) {
                *error = [NSError errorWithDomain:CCRequestCacheErrorDomain code:CCRequestCacheErrorAppVersionMismatch userInfo:@{NSLocalizedDescriptionKey:@"App version mismatch"}];
            }
            return NO;
        }
    }
    return YES;
}

- (void)saveResponseDataToCacheFile:(NSData *)data {
    if ([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]) {
        if (data != nil) {
            @try {
                // New data will always overwrite old data.
                [data writeToFile:[self cacheFilePath] atomically:YES];
                
                CCCacheMetadata * metadata = [[CCCacheMetadata alloc] init];
                metadata.version = [self cacheVersion];
                metadata.sensitiveDataString = ((NSObject *)[self cacheSensitiveData]).description;
                metadata.stringEncoding = [CCNetworkUtils stringEncodingWithRequest:self];
                metadata.creationDate = [NSDate date];
                metadata.appVersionString = [CCNetworkUtils appVersionString];
                [NSKeyedArchiver archiveRootObject:metadata toFile:[self cacheMetadataFilePath]];
            } @catch (NSException * exception) {
                CCLog(@"Save cache failed, reason = %@",exception.reason);
            }
        }
    }
}

#pragma mark -
- (BOOL)loadCacheMetadata {
    NSString * path = [self cacheMetadataFilePath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        @try {
            _cacheMetadata = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            return YES;
        }@catch (NSException * exception){
            CCLog(@"Load cache metadata failed, reason = %@",exception.reason);
            return NO;
        }
    }
    return NO;
}

- (BOOL)loadCacheData {
    NSString * path = [self cacheFilePath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        NSData * data = [NSData dataWithContentsOfFile:path];
        _cacheData = data;
        _cacheString = [[NSString alloc] initWithData:_cacheData encoding:self.cacheMetadata.stringEncoding];
        switch (self.responseSerializerType) {
            case CCResponseSerializerTypeHTTP:
                // Do nothing.
                return YES;
            case CCResponseSerializerTypeJSON:
                _cacheJSON = [NSJSONSerialization JSONObjectWithData:_cacheData options:(NSJSONReadingOptions)0 error:&error];
                return error == nil;
                case CCResponseSerializerTypeXMLParser:
                _cacheXML = [[NSXMLParser alloc] initWithData:_cacheData];
                return YES;
        }
    }
    return NO;
}

#pragma mark -
- (NSString *)cacheFilePath {
    NSString * cacheFileName = [self cacheFileName];
    NSString * path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

- (NSString *)cacheFileName {
    NSString * requestUrl = [self requestUrl];
    NSString * baseUrl = [CCNetworkConfig sharedConfig].baseUrl;
    id argment = [self cacheFileNameFilterForRequestArgument:[self requestArgument]];
    NSString * requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argment:%@",(long)[self requestMethod],baseUrl,requestUrl,argment];
    NSString * cacheFileName = [CCNetworkUtils md5StringFromString:requestInfo];
    return cacheFileName;
}

- (NSString *)cacheBasePath {
    NSString * pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [pathOfLibrary stringByAppendingPathComponent:@"lazyRequestCache"];
    
    // Filter cache base path
    NSArray<id<CCCacheDirPathFilterProtocol>> * filters = [[CCNetworkConfig sharedConfig] cacheDirPathFilters];
    if (filters.count > 0) {
        for (id<CCCacheDirPathFilterProtocol> f in filters) {
            path = [f filterCacheDirPath:path withRequest:self];
        }
    }
    
    [self createDirectoryIfNeeded:path];
    return path;
}

-  (NSString *)cacheMetadataFilePath {
    NSString * cacheMetadataFileName = [NSString stringWithFormat:@"%@.metadata",[self cacheFileName]];
    NSString * path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheMetadataFileName];
    return path;
}

- (void)createDirectoryIfNeeded:(NSString *)path {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    }else {
        if (!isDir) {
            NSError * error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        CCLog(@"create cache directory failed, error = %@",error);
    }else {
        [CCNetworkUtils addDoNotBackupAttribute:path];
    }
}

@end
