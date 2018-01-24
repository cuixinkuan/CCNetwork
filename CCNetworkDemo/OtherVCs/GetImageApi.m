//
//  GetImageApi.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "GetImageApi.h"

@implementation GetImageApi {
    NSString * _imageId;
}

- (id)initWithImageId:(NSString *)imageId {
    if (self = [super init]) {
        _imageId = imageId;
    }
    return self;
}

#pragma mark - others -
- (BOOL)useCDN {
    return YES;
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"/iphone/images/%@",_imageId];
}

- (NSString *)resumableDownloadPath {
    NSString * libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
    NSString * filePath = [cachePath stringByAppendingPathComponent:_imageId];
    return filePath;
}

@end
