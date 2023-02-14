//
//  FengBaseRequest.m
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "FengBaseRequest.h"
#import "FengMacro.h"
@implementation FengBaseRequest
+ (instancetype)requestWithType:(FengRequestType)type url:(NSString *)url params:(NSDictionary *)params paramArray:(NSArray *)paramArray {
    FengBaseRequest *req = [[self alloc] init];
    req->_url = url;
    req->_params = params;
    [req setRequestType:type];
    req->_urlParams = paramArray;
    [req fixUrlParamsIntoUrl];// 处理restful 参数
    return req;
}

+ (instancetype)GET:(NSString *)url params:(NSDictionary *)params {
    return [self requestWithType:FengRequestTypeGET url:url params:params paramArray:nil];
}

+ (instancetype)POST:(NSString *)url params:(NSDictionary *)params {
    return [self requestWithType:FengRequestTypePOST url:url params:params paramArray:nil];
}

+ (instancetype)JSONPOST:(NSString *)url params:(id)params {
    return [self requestWithType:FengRequestTypePOST url:url params:params paramArray:nil];
}

+ (instancetype)PUT:(NSString *)url params:(NSDictionary *)params {
    return [self requestWithType:FengRequestTypePUT url:url params:params paramArray:nil];
}

+ (instancetype)DELETE:(NSString *)url params:(NSDictionary *)params {
    return [self requestWithType:FengRequestTypeDELETE url:url params:params paramArray:nil];
}

#pragma mark - Restful style

+ (instancetype)POST:(NSString *)url, ... {
    va_list list;
    va_start(list, url);
    NSArray *array = [self vaListToArray:list];
    va_end(list);
    return [self requestWithType:FengRequestTypePOST url:url params:nil paramArray:array];
}

+ (instancetype)GET:(NSString *)url, ... {
    va_list list;
    va_start(list, url);
    NSArray *array = [self vaListToArray:list];
    va_end(list);
    return [self requestWithType:FengRequestTypeGET url:url params:nil paramArray:array];
}

+ (instancetype)PUT:(NSString *)url, ... {
    va_list list;
    va_start(list, url);
    NSArray *array = [self vaListToArray:list];
    va_end(list);
    return [self requestWithType:FengRequestTypePUT url:url params:nil paramArray:array];
}

+ (instancetype)DELETE:(NSString *)url, ... {
    va_list list;
    va_start(list, url);
    NSArray *array = [self vaListToArray:list];
    va_end(list);
    return [self requestWithType:FengRequestTypeDELETE url:url params:nil paramArray:array];
}

#pragma mark - 文件上传


+ (instancetype)uploadFileForUrl:(NSString *)url params:(NSDictionary *)params constructingBody:(void (^)(id<FengMultipartFormData>))constructingBodyBlock {
    FengBaseRequest *req = [self POST:url params:params];
    req->_constructingBodyBlock = [constructingBodyBlock copy];
    req->_params = params;
    req->_isUpload = YES;
    return req;
}

#pragma mark - setting method

- (instancetype)progressBlock:(void (^)(NSProgress *))progressBlock {
    self->_progressBlock = [progressBlock copy];
    return self;
}

- (instancetype)startBlock:(void (^)(id<FengCancellable> task))startBlock {
    self->_startBlock = [startBlock copy];
    return self;
}

- (instancetype)parameters:(NSDictionary *)parameters {
    self->_params = parameters;
    return self;
}

#pragma mark - request

- (id<FengCancellable>)startRequestSuccess:(void (^)(id<FengCancellable>, id))success failure:(void (^)(id<FengCancellable>, NSError *))failure {
    FengWeakify(self);
    return [self.handler requestWithType:self.requestType url:self.url parameters:self.params start:^(id<FengCancellable> task) {
        FengStrongify(self);
        if (self.startBlock) {
            self.startBlock(task);
        }
    } progress:^(NSProgress *progress) {
        FengStrongify(self);
        if (self.progressBlock) {
            self.progressBlock(progress);
        }
    } success:^(id<FengCancellable> task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(id<FengCancellable> task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

- (id<FengCancellable>)startUploadFileSuccess:(void (^)(id<FengCancellable>, id))success failure:(void (^)(id<FengCancellable>, NSError *))failure {
    
    FengWeakify(self);
    return [self.handler uploadFileWithType:self.requestType url:self.url parameters:self.params constructingBodyBlock:^(id<FengMultipartFormData> formData) {
        FengStrongify(self);
        if (self.constructingBodyBlock) {
            self.constructingBodyBlock(formData);
        }
    } start:^(id<FengCancellable> task) {
        FengStrongify(self);
        if (self.startBlock) {
            self.startBlock(task);
        }
    } progress:^(NSProgress *progress) {
        FengStrongify(self);
        if (self.progressBlock) {
            self.progressBlock(progress);
        }
    } success:^(id<FengCancellable> task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(id<FengCancellable> task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}


#pragma mark - getter

- (id<FengRequestHandler>)handler {
    if (!_handler) {
        _handler = [self getHandler];
    }
    return _handler;
}

#pragma mark - method should be override

- (id<FengRequestHandler>)getHandler {
    NSAssert(NO, @"在子类中实现本方法:%s", __PRETTY_FUNCTION__);
    return nil;
}
#pragma mark - private method

- (void)fixUrlParamsIntoUrl {
    if (self.urlParams.count) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{[^\\{^\\}]*\\}"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        
        // 获取参数
        NSMutableString *modifiedurl = [NSMutableString stringWithFormat:@"%@", self.url];
        NSTextCheckingResult *ret;
        NSMutableArray *array = [self.urlParams mutableCopy];
        while ((ret=[regex firstMatchInString:modifiedurl options:0 range:NSMakeRange(0, modifiedurl.length)])) {
            [modifiedurl replaceCharactersInRange:ret.range
                                       withString:[NSString stringWithFormat:@"%@", array.firstObject]];
            if (array.count) {
                [array removeObjectAtIndex:0];
            }
        };
        self->_urlParams = nil;
        self->_url = modifiedurl;
    }
}

+ (NSArray *)vaListToArray:(va_list)vaList {
    NSMutableArray *array = [NSMutableArray array];
    id value;
    while ((value = va_arg(vaList, id))) {
        [array addObject:value];
    }
    return array.copy;
}

@end
