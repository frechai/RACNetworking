//
//  FengPersistenceHttpRequest.h
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "YTKBaseRequest.h"
#import "FengRequestHandler.h"
NS_ASSUME_NONNULL_BEGIN

@interface FengPersistenceHttpRequest : YTKBaseRequest

@property (nonatomic, assign, readonly) FengParseRequestDataHandlerType dataHandlerType;

/**
 *  设置请求结果解析方式
 *
 *  param dataHandle   请求结果解析方式
 *
 *  return FengBaseHttpRequest
 */
- (instancetype)setDataHandle:(FengParseRequestDataHandlerType)dataHandle;

/**
 添加请求头
 
 param paramters
 return
 */
- (instancetype)addRequestHeaderParamters:(NSDictionary *)paramters;

/**
 设置通用请求头

 param paramater
 return
 */
- (instancetype)setStaticHeaderParamater:(NSDictionary *)paramater;

/**
 设置特别的host
 
 param requestBaseUrl
 return
 */
- (instancetype)setRequestBaseUrl:(NSString *)requestBaseUrl;

/**
 设置临时token
 
 param tempToken
 return
 */
- (instancetype)setTempToken:(NSString *)tempToken;

/**
设置请求的path

param subPath
return
*/
- (instancetype)setRequestSubPath:(NSString *)subPath;

/// 设置认证头
/// @param array 认证头
- (instancetype)setRequestAuthorizationHeaderFieldArray:(NSArray <NSString *>*)array;

/**
设置请求方法

param requestMethod
return
*/
- (instancetype)setRequestMethod:(YTKRequestMethod)requestMethod;

/**
设置请求体

param reqParame
return
*/
- (instancetype)setReqParame:(id)reqParame;

/// 取消所有请求
+ (void)cancelAllRequest;
@end

NS_ASSUME_NONNULL_END
