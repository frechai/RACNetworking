//
//  FengBaseHttpRequest.h
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "FengBaseRequest.h"
#import "FengBaseRequestProtocol.h"
#import "RACSignal+Request.h"
#import <ReactiveObjC/ReactiveObjC.h>
NS_ASSUME_NONNULL_BEGIN
extern NSString *const errorDataKey;//错误返回的数据信息  在NSError里面取userInfo

@interface FengBaseHttpRequest : FengBaseRequest<FengBaseRequestProtocol>

@property (nonatomic, strong, readonly) NSDictionary *staticPramters;

@property (nonatomic, strong, readonly) NSDictionary *staticHeaderParams;

/// 获取请求签名
/// param paramters
/// param token
+ (NSDictionary *)getRequestSignWithParamters:(NSDictionary *)paramters
                                        token:(NSString *)token;

/**
 开始请求

 return
 */
- (RACSignal *)startRequest;

@end

NS_ASSUME_NONNULL_END
