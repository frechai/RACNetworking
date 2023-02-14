//
//  FengBaseRequest.h
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FengRequestHandler.h"
NS_ASSUME_NONNULL_BEGIN

@interface FengBaseRequest : NSObject
{
@protected
    id<FengRequestHandler> _handler;
    NSString *_url;
    id _params;
    NSArray *_urlParams;
}
@property (nonatomic, strong, readonly) NSString *host;
@property (nonatomic, assign) FengRequestType requestType;

@property (nonatomic, strong, nullable) id<FengRequestHandler> handler;

@property (nonatomic, strong, readonly) NSString     *url;
@property (nonatomic, strong, readonly) NSDictionary *params;///< 普通分割参数
@property (nonatomic, strong, readonly) NSArray      *urlParams;///< Restful 风格参数

@property (nonatomic, assign, readonly) BOOL isUpload;
@property (nonatomic, copy  , readonly) void (^progressBlock)(NSProgress *progress);
@property (nonatomic, copy  , readonly) void (^startBlock) (id<FengCancellable> task);
@property (nonatomic, copy  , readonly) void (^constructingBodyBlock)(id<FengMultipartFormData> formData);

#pragma mark - 普通请求风格创建请求
+ (instancetype)POST:(NSString *)url params:(NSDictionary *)params;
+ (instancetype)JSONPOST:(NSString *)url params:(id)params;
+ (instancetype)GET:(NSString *)url params:(NSDictionary *)params;
+ (instancetype)PUT:(NSString *)url params:(NSDictionary *)params;
+ (instancetype)DELETE:(NSString *)url params:(NSDictionary *)params;

#pragma mark - Restful 风格创建请求
/**
 *  restful 风格请求 url格式 /api/v1/{userId}/page     参数对应大括号内的参数，参数最后需要插入nil作为结束标识
 *
 *  param url description
 */
+ (instancetype)POST:(NSString *)url, ... NS_REQUIRES_NIL_TERMINATION;
/**
 *  restful 风格请求 url格式 /api/v1/{userId}/page     参数对应大括号内的参数，参数最后需要插入nil作为结束标识
 *
 *  param url description
 */
+ (instancetype)GET:(NSString *)url, ... NS_REQUIRES_NIL_TERMINATION;
/**
 *  restful 风格请求 url格式 /api/v1/{userId}/page     参数对应大括号内的参数，参数最后需要插入nil作为结束标识
 *
 *  param url description
 */
+ (instancetype)PUT:(NSString *)url, ... NS_REQUIRES_NIL_TERMINATION;
/**
 *  restful 风格请求 url格式 /api/v1/{userId}/page     参数对应大括号内的参数，参数最后需要插入nil作为结束标识
 *
 *  param url description
 */
+ (instancetype)DELETE:(NSString *)url, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - 创建文件上传请求

/**
 *  创建文件上传请求
 *
 *  param url
 *  param params
 *  param constructingBodyBlock
 */
+ (instancetype)uploadFileForUrl:(NSString *)url params:(NSDictionary *)params constructingBody:(void (^)(id<FengMultipartFormData> formData))constructingBodyBlock;

#pragma mark - 设置

/**
 *  设置进度block
 *
 *  param progressBlock description
 *
 */
- (instancetype)progressBlock:(void (^)(NSProgress *progress))progressBlock;

/**
 设置请求开始block

 param startBlock
 return
 */
- (instancetype)startBlock:(void (^)(id<FengCancellable> task))startBlock;

/**
 *  设置参数
 *
 *  param parameters description
 */
- (instancetype)parameters:(NSDictionary *)parameters;

#pragma mark - 发起请求

- (id<FengCancellable>)startRequestSuccess:(void (^)(id<FengCancellable> task, id responseObject))success failure:(void(^)(id<FengCancellable> task, NSError *error))failure;
- (id<FengCancellable>)startUploadFileSuccess:(void (^)(id<FengCancellable> task, id responseObject))success failure:(void(^)(id<FengCancellable> task, NSError *error))failure;

#pragma mark - subclass override

- (id<FengRequestHandler>)getHandler;
@end

NS_ASSUME_NONNULL_END
