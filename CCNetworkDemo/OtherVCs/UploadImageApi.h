//
//  UploadImageApi.h
//  CCNetworkDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "CCRequest.h"
#import <UIKit/UIKit.h>


@interface UploadImageApi : CCRequest

- (id)initWithImage:(UIImage *)image;

- (NSString *)responseImageId;

@end
