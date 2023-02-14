//
//  FengBaseRequestProtocol.h
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FengRequestHandler.h"
#import <ReactiveObjC/ReactiveObjC.h>
NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    ///请求开始
    FengRequestLogTypeStart = 0,
    ///请求出错
    FengRequestLogTypeError,
    ///请求成功
    FengRequestLogTypeSuccess,
    ///token鉴权出错
    FengRequestLogTypeAuthenticationFail,
    ///将要请求开始
    FengRequestLogTypePreStart,
} FengRequestLogType;

typedef enum : NSUInteger {
    FengRequestErrorNetWork,//网络错误
    FengRequestErrorService,//服务器错误
} FengRequestErrorCode;

@protocol FengBaseRequestProtocol <NSObject>

@optional

/**
 处理返回信息
 
 param value
 param subscriber
 return
 */
- (RACDisposable *)handleResponse:(id)value subscriber:(id<RACSubscriber>)subscriber;

/**
 处理错误信息
 
 param error
 return 是否回调错误信息
 */
- (BOOL)handleError:(NSError *)error;

/**
 获取host
 
 return
 */
- (NSString *)getHost;

/**
获取请求路径

return
*/
- (NSString *)getSubPath;

/**
 设置请求地址的path

return
*/
- (instancetype)setSubPath:(NSString *)subPath;

/**
 设置请求url
 
 param requestBaseUrl
 return
 */
- (instancetype)setRequestBaseUrl:(NSString *)requestBaseUrl;

/**
 设置解析方式
 
 param dataHandle 解析方式
 return
 */
- (instancetype)setDataHandle:(FengParseRequestDataHandlerType)dataHandle;

/// 设置认证头
/// @param array 认证头
- (instancetype)setRequestAuthorizationHeaderFieldArray:(NSArray <NSString *>*)array;

/**
 设置特殊的请求头，会覆盖基类的请求头
 
 param params
 return
 */
- (instancetype)setSpecialStaticHeaderParams:(NSDictionary *)params;

/**
 设置临时token
 
 param tempToken
 return
 */
- (instancetype)setTempToken:(NSString *)tempToken;

/**
 添加请求头
 
 param paramters
 return
 */
- (instancetype)addRequestHeaderParamters:(NSDictionary *)paramters;

/**
 日志回调信息
 
 param logs
 */
- (void)callBackLogs:(FengRequestLogType)logType data:(nullable id)data;
@end

NS_ASSUME_NONNULL_END
