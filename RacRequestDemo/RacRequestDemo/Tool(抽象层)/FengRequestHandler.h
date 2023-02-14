//
//  FengRequestHandler.h
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,FengParseRequestDataHandlerType) {
    FengParseRequestDataHandlerJson,
    FengParseRequestDataHandlerXml,
    FengParseRequestDataHandlerOriginString,
    FengParseRequestDataHandlerOther
};

typedef NS_ENUM(NSUInteger, FengRequestType) {
    FengRequestTypeGET,
    FengRequestTypePUT,
    FengRequestTypePOST,
    FengRequestTypeDELETE,
};

@protocol FengMultipartFormData <NSObject>

@required
- (void)appendData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

@end

// ================================================================================

@protocol FengCancellable <NSObject>

@required
- (void)feng_cancel;

@end
@protocol FengRequestHandler <NSObject>

@required
- (id<FengCancellable>)requestWithType:(FengRequestType)type
                                 url:(NSString *)url
                          parameters:(id)parameters
                               start:(void (^)(id<FengCancellable> task))start
                            progress:(void (^)(NSProgress *progress))progress
                             success:(void (^)(id<FengCancellable> task, id responseObject))success
                             failure:(void (^)(id<FengCancellable> task, NSError *error))failure;

@optional
- (id<FengCancellable>)uploadFileWithType:(FengRequestType)type
                                    url:(NSString *)url
                             parameters:(NSDictionary *)parameters
                  constructingBodyBlock:(void (^)(id<FengMultipartFormData> formData))constructingBodyBlock
                                  start:(void (^)(id<FengCancellable> task))start
                               progress:(void (^)(NSProgress *progress))progress
                                success:(void (^)(id<FengCancellable> task, id responseObject))success
                                failure:(void (^)(id<FengCancellable> task, NSError *error))failure;


/**
 如需要移除某个key，请设置 @{key : [NSNull null]}
 
 param headers headers description
 */
- (void)setupHeaders:(NSDictionary *)headers;
@end

NS_ASSUME_NONNULL_END
