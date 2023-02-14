//
//  RACSignal+Request.h
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//



#import "RACSignal.h"

NS_ASSUME_NONNULL_BEGIN

@interface FengResponseObject : NSObject

@property (nonatomic, strong) NSString *originalString;
@property (nonatomic, assign) int      code;
@property (nonatomic, copy  ) NSString *message;
@property (nonatomic, copy  ) NSString *errorMsg;
//msg
@property (nonatomic, strong) id       data;

- (instancetype)initWithCode:(int)code message:(nullable NSString *)message errorMsg:(nullable NSString *)errorMsg data:(nullable id)data withOriginalString:(nullable NSString *)originalString;

@end

@interface RACSignal (Request)
- (instancetype)feng_requstMap:(id _Nullable (^)(FengResponseObject* _Nullable value))block;

@end

NS_ASSUME_NONNULL_END
