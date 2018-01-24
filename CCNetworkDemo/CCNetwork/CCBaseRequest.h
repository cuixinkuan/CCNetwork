//
//  CCBaseRequest.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/15.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const CCRequestValidationErrorDomain;

NS_ENUM(NSInteger) {
    CCRequestValidationErrorInvalidStatusCode = -8,
    CCRequestValidationErrorInvalidJSONFormat = -9,
    };
    
    // Http request method.
    typedef NS_ENUM(NSInteger, CCRequestMethod) {
        CCRequestMethodGET = 0,
        CCRequestMethodPOST,
        CCRequestMethodHEAD,
        CCRequestMethodPUT,
        CCRequestMethodDELETE,
        CCRequestMethodPATCH,
    };
    
    // Request priority
    typedef NS_ENUM(NSInteger, CCRequestPriority) {
        CCRequestPriorityLow = -4,
        CCRequestPriorityDefault = 0,
        CCRequestPriorityHigh = 4,
    };
    
    // Request serializer type
    typedef NS_ENUM(NSInteger, CCRequestSerializerType) {
        CCRequestSerializerTypeHTTP = 0,
        CCRequestSerializerTypeJSON,
    };
    
    // Response serializer type
    typedef NS_ENUM(NSInteger, CCResponseSerializerType) {
        CCResponseSerializerTypeHTTP, // NSData type
        CCResponseSerializerTypeJSON, // JSON object type
        CCResponseSerializerTypeXMLParser, // NSXMLParser type
    };
    
    @protocol AFMultipartFormData;
    typedef void (^AFConstructingBlock)(id <AFMultipartFormData> formData);
    typedef void(^AFURLSessionTaskProgressBlock)(NSProgress *);
    
    @class CCBaseRequest;
    typedef void (^CCRequestCompletionBlock)(__kindof CCBaseRequest * request);
    
    // All the delegate methods will be called on the main queue
    @protocol CCRequestDelegate <NSObject>
    
    @optional
    // the request has finished successfully
    - (void)requestFinished:(__kindof CCBaseRequest *)request;
    // the request has failed
    - (void)requestFailed:(__kindof CCBaseRequest *)request;
    
    @end
    
    // All the delegate methods will be called on the main queue
    @protocol CCRequestAccessory <NSObject>
    
    @optional
    // the accessory that the request is about to start.
    - (void)requestWillStart:(id)request;
    // this method is called before executing 'requestFinished' and 'successCompletionBlock'
    - (void)requestWillStop:(id)request;
    // this method is called after executing 'requestFinished' and 'successCompletionBlock'
    - (void)requestDidStop:(id)request;
    @end
    
    
@interface CCBaseRequest : NSObject

#pragma mark - Request and Response Information
@property (nonatomic,strong,readonly)NSURLSessionTask * requestTask;

@property (nonatomic,strong,readonly)NSURLRequest * currentRequest;

@property (nonatomic,strong,readonly)NSURLRequest * originalRequest;

@property (nonatomic,strong,readonly)NSHTTPURLResponse * response;

@property (nonatomic,readonly)NSInteger responseStatusCode;

@property (nonatomic,strong,readonly,nullable)NSDictionary * responseHeaders;

@property (nonatomic,strong,readonly,nullable)NSData * responseData;

@property (nonatomic,strong,readonly,nullable)NSString * responseString;

@property (nonatomic,strong,readonly,nullable)id responseObject;

@property (nonatomic,strong,readonly,nullable)id responseJSONObject;

@property (nonatomic,strong,readonly,nullable)NSError * error;

@property (nonatomic,readonly,getter=isCancelled)BOOL cancelled;

@property (nonatomic,readonly,getter=isExecuting)BOOL executing;

#pragma mark - Request Configuration -
// can be used to identify request, Default value is 0.
@property (nonatomic)NSInteger tag;

@property (nonatomic,strong,nullable)NSDictionary * userInfo;

@property (nonatomic,weak,nullable)id<CCRequestDelegate> delegate;

@property (nonatomic,copy,nullable)CCRequestCompletionBlock successCompletionBlock;

@property (nonatomic,copy,nullable)CCRequestCompletionBlock failureCompletionBlock;

@property (nonatomic,strong,nullable)NSMutableArray <id<CCRequestAccessory>>* requestAccessories;

@property (nonatomic,copy,nullable)AFConstructingBlock constructingBodyBlock;
//要启动断点续传功能，只需要覆盖 resumableDownloadPath 方法，指定断点续传时文件的存储路径即可，文件会被自动保存到此路径。
@property (nonatomic,strong,nullable)NSString * resumableDownloadPath;

@property (nonatomic,copy,nullable)AFURLSessionTaskProgressBlock resumableDownloadProgressBlock;

@property (nonatomic)CCRequestPriority requestPriority;

// Set completion callbacks
- (void)setCompletionBlockWithSuccess:(nullable CCRequestCompletionBlock)success
                              failure:(nullable CCRequestCompletionBlock)failure;
// Nil out both success and failure callback blocks
- (void)clearCompletionBlock;
// add request accessory
-(void)addAccessory:(id<CCRequestAccessory>)accessory;

#pragma mark - Request Action -
// Append self to request queue and start the request.
- (void)start;
// Remove self form request queue and cancel the request
- (void)stop;
// Convenience method to start the request with block callbacks
- (void)startWithCompletionBlockWithSuccess:(nullable CCRequestCompletionBlock)success
                                    failure:(nullable CCRequestCompletionBlock)failure;

#pragma mark - Subclass Override -
//
- (void)requestCompletePreprocessor;
//
- (void)requestCompleteFilter;
//
- (void)requestFailedPreprocessor;
//
- (void)requestFailedFilter;

//
- (NSString *)baseUrl;
//
- (NSString *)requestUrl;
//
- (NSString *)cdnUrl;
//
- (NSTimeInterval)requestTimeoutInterval;
//
- (nullable id)requestArgument;
//
- (id)cacheFileNameFilterForRequestArgument:(id)argument;
//
- (CCRequestMethod)requestMethod;
//
- (CCRequestSerializerType)requestSerializerType;
//
- (CCResponseSerializerType)responseSerializerType;
//
- (nullable NSArray<NSString *> *)requestAuthorizationHeaderFieldArray;
//
- (nullable NSDictionary<NSString *,NSString *> *)requestHeaderfieldValueDictionary;

//通过覆盖 buildCustomUrlRequest 方法，返回一个 NSURLRequest 对象来达到完全自定义请求的需求。如果构建自定义的 request，会忽略其他的一切自定义 request 的方法，例如 requestUrl, requestArgument, requestMethod, requestSerializerType,requestHeaderFieldValueDictionary 等等。
- (nullable NSURLRequest *)buildCustomUrlRequest;
//如果要使用 CDN 地址，只需要覆盖 CCRequest 类的 - (BOOL)useCDN; 方法
- (BOOL)useCDN;
//
- (BOOL)allowsCellularAccess;
//用以简单验证服务器返回内容
- (nullable id)jsonValidator;
//
- (BOOL)statusCodeValidator;

@end
NS_ASSUME_NONNULL_END

