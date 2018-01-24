//
//  CCUrlArgumentsFilter.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNetworkConfig.h"
#import "CCBaseRequest.h"

@interface CCUrlArgumentsFilter : NSObject <CCUrlFilterProtocol>

+ (CCUrlArgumentsFilter *)filterWithArguments:(NSDictionary *)arguments;
- (NSString *)filterUrl:(NSString *)originUrl withRequest:(CCBaseRequest *)request;

@end
