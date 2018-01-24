//
//  RegisterApi.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCRequest.h"

@interface RegisterApi : CCRequest

- (id)initWithUsername:(NSString *)username password:(NSString *)password;

- (NSString *)userId;

@end
