//
//  UploadImageApi.m
//  CCNetworkDemo
//
//  Created by admin on 2018/1/11.
//  Copyright © 2018年 cuixinkuan. All rights reserved.
//

#import "UploadImageApi.h"
#import "AFNetworking.h"

@implementation UploadImageApi {
    UIImage * _image;
}

- (id)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        _image = image;
    }
    return self;
}

#pragma mark - others -
- (CCRequestMethod)requestMethod {
    return CCRequestMethodPOST;
}

- (NSString *)requestUrl {
    return @"/iphone/image/upload";
}

- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData * data = UIImageJPEGRepresentation(_image, 0.9);
        NSString * name = @"image";
        NSString * formKey = @"image";
        NSString * type = @"image/jpeg";
        [formData appendPartWithFileData:data name:name fileName:formKey mimeType:type];
    };
}

- (id)jsonValidator {
    return @{
             @"imageId":[NSString class]
             };
}

- (NSString *)responseImageId {
    NSDictionary * dict = self.responseJSONObject;
    return dict[@"imageId"];
}

@end
