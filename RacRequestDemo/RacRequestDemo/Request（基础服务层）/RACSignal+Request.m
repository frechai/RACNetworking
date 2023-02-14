//
//  RACSignal+Request.m
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "RACSignal+Request.h"

@implementation FengResponseObject

- (instancetype)initWithCode:(int)code message:(nullable NSString *)message errorMsg:(nullable NSString *)errorMsg data:(nullable id)data withOriginalString:(nullable NSString *)originalString {
    if (self = [super init]) {
        self.code = code;
        self.message = message;
        self.errorMsg = errorMsg;
        self.data = data;
        self.originalString = originalString;
    }
    return self;
}

@end

@implementation RACSignal (Request)
- (instancetype)feng_requstMap:(id  _Nullable (^)(FengResponseObject * _Nullable))block
{
    return [self map:block];
}
@end
