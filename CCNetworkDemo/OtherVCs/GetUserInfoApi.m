//
//  GetUserInfoApi.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "GetUserInfoApi.h"

@implementation GetUserInfoApi {
    NSString * _userId;
}

- (id)initWithUserId:(NSString *)userId {
    if (self = [super init]) {
        _userId = userId;
    }
    return self;
}

#pragma mark - others -
- (NSString *)requestUrl {
    return @"/iphone/users";
}

- (id)requestArgument {
    return @{@"id":_userId};
}

- (id)jsonValidator {
    return @{
             @"nick":[NSString class],
             @"level":[NSNumber class]
             };
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 3;
}

@end
