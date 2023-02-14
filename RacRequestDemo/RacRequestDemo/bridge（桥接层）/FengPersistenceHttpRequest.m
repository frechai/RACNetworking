//
//  FengPersistenceHttpRequest.m
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "FengPersistenceHttpRequest.h"
#import <YTKNetwork.h>
#import <pthread/pthread.h>

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)
@interface FengPersistenceHttpRequest() {
    pthread_mutex_t _lock;
    NSArray <NSString *>*_requestAuthorizationHeaderFieldArray;
    FengParseRequestDataHandlerType _dataHandle;
    NSString *_requestBaseUrl;
    NSString *_tempToken;
    NSString *_subPath;
    YTKRequestMethod _requestMethod;
    id _reqParame;
}

@property (nonatomic, strong, nullable) NSMutableDictionary *appendHeaderParamaters;

@property (nonatomic, strong, nullable) NSDictionary *headerParamater;

@end
@implementation FengPersistenceHttpRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (instancetype)setDataHandle:(FengParseRequestDataHandlerType)dataHandle {
    _dataHandle = dataHandle;
    return self;
}

- (instancetype)addRequestHeaderParamters:(NSDictionary *)paramters {
    Lock();
    [self.appendHeaderParamaters addEntriesFromDictionary:paramters];
    Unlock();
    return self;
}

- (instancetype)setStaticHeaderParamater:(NSDictionary *)paramater {
    _headerParamater = paramater;
    return self;
}

- (instancetype)setRequestAuthorizationHeaderFieldArray:(NSArray <NSString *>*)array {
    _requestAuthorizationHeaderFieldArray = array;
    return self;
}

- (instancetype)setRequestBaseUrl:(NSString *)requestBaseUrl {
    _requestBaseUrl = requestBaseUrl;
    return self;
}

- (instancetype)setRequestSubPath:(NSString *)subPath {
    _subPath = subPath;
    return self;
}

- (instancetype)setTempToken:(NSString *)tempToken {
    _tempToken = tempToken;
    return self;
}

- (instancetype)setRequestMethod:(YTKRequestMethod)requestMethod {
    _requestMethod = requestMethod;
    return self;
}

- (instancetype)setReqParame:(id)reqParame {
    _reqParame = reqParame;
    return self;
}
- (FengParseRequestDataHandlerType)dataHandlerType {
    return _dataHandle;
}

/// 设置请求耗时时间
- (NSTimeInterval)requestTimeoutInterval {
    return 15.0f;
}

/// 请求入参
- (id)requestArgument {
    return _reqParame;
}

- (NSString *)requestUrl {
    if (_subPath) {
        return _subPath;
    }
    return @"url";
}
- (NSString *)baseUrl {
    if (_requestBaseUrl&&[_requestBaseUrl length] > 0) {
        return _requestBaseUrl;
    }
    return @"https:xx";
}
- (YTKRequestMethod)requestMethod {
    return _requestMethod;
}

- (NSArray<NSString *> *)requestAuthorizationHeaderFieldArray {
    return _requestAuthorizationHeaderFieldArray;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

+ (void)cancelAllRequest {
    [[YTKNetworkAgent sharedAgent] cancelAllRequests];
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    @autoreleasepool {
        Lock();
        NSMutableDictionary *staticHeaderParams = [NSMutableDictionary dictionary];
        if ([self.appendHeaderParamaters count] > 0) {
            [staticHeaderParams addEntriesFromDictionary:self.appendHeaderParamaters.copy];
        }
        
        if ([self.headerParamater count] > 0) {
            [staticHeaderParams addEntriesFromDictionary:self.headerParamater.copy];
        }
        
        if (self->_tempToken && [self->_tempToken length] > 0) {
            [staticHeaderParams addEntriesFromDictionary:@{@"token":self? self->_tempToken : @""}];
        }
        Unlock();
        return staticHeaderParams;
    }
}

- (NSMutableDictionary *)appendHeaderParamaters {
    if (!_appendHeaderParamaters) {
        _appendHeaderParamaters = [NSMutableDictionary dictionary];
        
    }
    
    return _appendHeaderParamaters;
}

- (void)dealloc {
    NSLog(@"dealloc,%@",self);
    pthread_mutex_destroy(&_lock);
    self.appendHeaderParamaters = nil;
    self.headerParamater = nil;
}

@end
