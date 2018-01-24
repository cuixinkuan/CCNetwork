//
//  CCUrlArgumentsFilter.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCUrlArgumentsFilter.h"
#import "AFURLRequestSerialization.h"

@implementation CCUrlArgumentsFilter {
    NSDictionary * _arguments;
}

+ (CCUrlArgumentsFilter *)filterWithArguments:(NSDictionary *)arguments {
    return [[self alloc] initWithArguments:arguments];
}

- (id)initWithArguments:(NSDictionary *)arguments {
    if (self = [super init]) {
        _arguments = arguments;
    }
    return self;
}

#pragma mark - YTKUrlFilterProtocol -
- (NSString *)filterUrl:(NSString *)originUrl withRequest:(CCBaseRequest *)request {
    return [self urlStringWithOriginUrlString:originUrl appendParameters:_arguments];
}

- (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters {
    NSString * paraUrlString = AFQueryStringFromParameters(parameters);
    if (!(paraUrlString.length > 0)) {
        return originUrlString;
    }
    BOOL useDummyUrl = NO;
    static NSString * dummyUrl = nil;
    NSURLComponents * components = [NSURLComponents componentsWithString:originUrlString];
    if (!components) {
        useDummyUrl = YES;
        if (!dummyUrl) {
            dummyUrl = @"http://www.dummy.com";
        }
        components = [NSURLComponents componentsWithString:dummyUrl];
    }
    
    NSString * queryString = components.query ? : @"";
    NSString * newQueryString = [queryString stringByAppendingFormat:queryString.length > 0 ? @"&%@" : @"%@",paraUrlString];
    components.query = newQueryString;
    
    if (useDummyUrl) {
        return [components.URL.absoluteString substringFromIndex:dummyUrl.length - 1];
    }else {
        return components.URL.absoluteString;
    }
    
}

@end
