//
//  CCNetworkPrivate.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/16.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCRequest.h"
#import "CCBaseRequest.h"
#import "CCBatchRequest.h"
#import "CCChainRequest.h"
#import "CCNetworkConfig.h"
#import "CCNetworkAgent.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void CCLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
@class AFHTTPSessionManager;

@interface CCNetworkUtils : NSObject

+ (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)appVersionString;

+ (NSStringEncoding)stringEncodingWithRequest:(CCBaseRequest *)request;

+ (BOOL)validateResumeData:(NSData *)data;

@end

@interface CCRequest (Getter)

- (NSString *)cacheBasePath;

@end

@interface CCBaseRequest (Setter)

@property (nonatomic,strong,readwrite)NSURLSessionTask * requestTask;
@property (nonatomic,strong,readwrite,nullable)NSData * responseData;
@property (nonatomic,strong,readwrite,nullable)id responseJSONObject;
@property (nonatomic,strong,readwrite,nullable)id responseObject;
@property (nonatomic,strong,readwrite,nullable)NSString * responseString;
@property (nonatomic,strong,readwrite,nullable)NSError * error;

@end

@interface CCBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end
////////////
@interface CCBatchRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

@interface CCChainRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

////////////
@interface CCNetworkAgent (Private)

- (AFHTTPSessionManager *)manager;
- (void)resetURLSessionManager;
- (void)resetURLSessionManagerWithConfiguration:(NSURLSessionConfiguration *)configuration;
- (NSString *)incompleteDownloadTempCacheFolder;

@end

NS_ASSUME_NONNULL_END


















