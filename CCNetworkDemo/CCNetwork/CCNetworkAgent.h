//
//  CCNetworkAgent.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/16.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CCBaseRequest;
// CCNetworkAgent id the underlying class that handles actual request generation,serializaion and response handling.
@interface CCNetworkAgent : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

// Get the shared agent.
+ (CCNetworkAgent *)sharedAgent;

// add request to session and start it.
- (void)addRequest:(CCBaseRequest *)request;

// Cancel a reuqest that was previously added.
- (void)cancelRequest:(CCBaseRequest *)request;

// Cancel all requests that were previously added.
- (void)cancelAllRequests;

/**
 Return the constructed URL of request.

 @param request The request to parse, should not be nil.
 @return The result URL.
 */
- (NSString *)buildRequestUrl:(CCBaseRequest *)request;

@end

NS_ASSUME_NONNULL_END
