//
//  RegisterApi.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "RegisterApi.h"

@implementation RegisterApi {
    NSString * _username;
    NSString * _password;
}
- (id)initWithUsername:(NSString *)username password:(NSString *)password {
    if (self = [super init]) {
        _username = username;
        _password = password;
    }
    return self;
}

- (NSString *)userId {
    return [[[self responseJSONObject] objectForKey:@"userId"] stringValue];
}

#pragma mark - others -
- (CCRequestMethod)requestMethod {
    return CCRequestMethodPOST;
}

- (NSString *)requestUrl {
    return @"/iphone/register";
}

- (id)requestArgument {
    return @{
             @"username":_username,
             @"password":_password
             };
}

- (id)jsonValidator {
    return @{
             @"userId":[NSNumber class],
             @"nick":[NSString class],
             @"level":[NSNumber class]
             };
}

@end
