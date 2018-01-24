//
//  CCBaseRequest.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/15.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCBaseRequest.h"
#import "CCNetworkAgent.h"
#import "CCNetworkPrivate.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

NSString * const CCRequestValidationErrorDomain = @"com.ceair.request.validation";

@interface CCBaseRequest ()

@property (nonatomic,strong,readwrite)NSURLSessionTask * requestTask;
@property (nonatomic,strong,readwrite)NSData * responseData;
@property (nonatomic,strong,readwrite)id responseJSONObject;
@property (nonatomic,strong,readwrite)id responseObject;
@property (nonatomic,strong,readwrite)NSString * responseString;
@property (nonatomic,strong,readwrite)NSError * error;

@end

@implementation CCBaseRequest
#pragma mark - Request and Response Information -
- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.requestTask.response;
}

- (NSInteger)responseStatusCode {
    return self.response.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.response.allHeaderFields;
}

- (NSURLRequest *)currentRequest {
    return self.requestTask.currentRequest;
}

- (NSURLRequest *)originalRequest {
    return self.requestTask.originalRequest;
}

- (BOOL)isCancelled {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

#pragma mark - Request Configuration -
- (void)setCompletionBlockWithSuccess:(CCRequestCompletionBlock)success
                              failure:(CCRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (void)addAccessory:(id<CCRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

#pragma mark - Request Action -
- (void)start {
    [self toggleAccessoriesWillStartCallBack];
    [[CCNetworkAgent sharedAgent] addRequest:self];
}

- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    self.delegate = nil;
    [[CCNetworkAgent sharedAgent] cancelRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)startWithCompletionBlockWithSuccess:(CCRequestCompletionBlock)success failure:(CCRequestCompletionBlock)failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

#pragma mark - Subclass Override -
- (void)requestCompletePreprocessor {
}

- (void)requestCompleteFilter {
}

- (void)requestFailedPreprocessor {
}

- (void)requestFailedFilter {
}

- (NSString *)requestUrl {
    return @"";
}

- (NSString *)cdnUrl {
    return @"";
}

- (NSString *)baseUrl {
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

- (id)requestArgument {
    return nil;
}

- (id)cacheFileNameFilterForRequestArgument:(id)argument {
    return argument;
}

- (CCRequestMethod)requestMethod {
    return CCRequestMethodGET;
}

- (CCRequestSerializerType)requestSerializerType {
    return CCRequestSerializerTypeHTTP;
}

- (CCResponseSerializerType)responseSerializerType {
    return CCResponseSerializerTypeJSON;
}

- (NSArray<NSString *> *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderfieldValueDictionary {
    return nil;
}

- (NSURLRequest *)buildCustomUrlRequest {
    return nil;
}

- (BOOL)useCDN {
   return NO;
}

- (BOOL)allowsCellularAccess {
    return YES;
}

- (id)jsonValidator {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    return (statusCode >= 200 && statusCode <= 299);
}

#pragma mark - NSObject -
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ URL: %@ } { method: %@ } {arguments: %@ }",NSStringFromClass([self class]),self,self.currentRequest.URL,self.currentRequest.HTTPMethod,self.requestArgument];
}

@end
