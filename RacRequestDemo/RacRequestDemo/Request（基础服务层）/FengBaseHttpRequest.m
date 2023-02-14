//
//  FengBaseHttpRequest.m
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "FengBaseHttpRequest.h"
#import "FengMacro.h"
#import "FengPersistenceHttpRequest+FengBaseRequest.h"

NSString *const errorDataKey = @"errorDataKey";
@interface FengBaseHttpRequest()

@property (nonatomic, strong, nullable) RACSignal *signal;

@end
@implementation FengBaseHttpRequest
- (RACSignal *)startRequest {
    
    [self callBackLogs:FengRequestLogTypePreStart data:nil];
    
    self->_url = [self.url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.signal = self.isUpload
    ? [self uploadSignal] : [self requestSignal];
    FengWeakify(self);
    [self startBlock:^(id<FengCancellable> task) {
        FengStrongify(self);
        [self callBackLogs:FengRequestLogTypeStart data:nil];
    }];
    
    return
    [[[self.signal
     flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            FengStrongify(self);
            return [self handleResponse:value subscriber:subscriber];
        }] deliverOn:[RACScheduler scheduler]];
    }]
      doError:^(NSError *error) {
          if ( error.code == kCFURLErrorTimedOut
              || error.code == kCFURLErrorCannotConnectToHost
              || error.code == kCFURLErrorNetworkConnectionLost
              || error.code == kCFURLErrorNotConnectedToInternet) {
              [error setValue:@(FengRequestErrorNetWork) forKey:@"code"];
              [error setValue:@"哎呀，网络正在开小差" forKey:@"domain"];
          }else {
              [error setValue:@(FengRequestErrorService) forKey:@"code"];
              [error setValue:@"哎呀，服务器正在开小差，请稍后重试" forKey:@"domain"];
          }
      }]
    flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [[RACSignal createSignal:^RACDisposable * _Nonnull(id<RACSubscriber>  _Nonnull subscriber) {
            if ([value isKindOfClass:[NSError class]]) {
                [subscriber sendError:value];
            } else {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
            }
            return nil;
        }] deliverOnMainThread];
    }];
}

- (RACSignal *)requestSignal {
    
    [self handleParamtersSign];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @autoreleasepool {
            id<FengCancellable> task =
            [self startRequestSuccess:^(id<FengCancellable> task, id responseObject) {
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
            } failure:^(id<FengCancellable> task, NSError *error) {
                [subscriber sendError:error];
            }];
            return [RACDisposable disposableWithBlock:^{
                [task feng_cancel];
            }];
        }
    }];
}

- (void)dealloc {
    self.handler = nil;
    self.signal = nil;
    NSLog(@"dealloc,%@",self);
}

- (RACSignal *)uploadSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @autoreleasepool {
            id<FengCancellable> task =
            [self startUploadFileSuccess:^(id<FengCancellable> task, id responseObject) {
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
            } failure:^(id<FengCancellable> task, NSError *error) {
                [subscriber sendError:error];
            }];
            return [RACDisposable disposableWithBlock:^{
                [task feng_cancel];
            }];
        }
    }];
}

- (RACDisposable *)handleResponse:(id)value subscriber:(id<RACSubscriber>)subscriber  {
    @autoreleasepool {
        FengResponseObject *obj = nil;
        int code = 0;
        if ([value isKindOfClass:[NSDictionary class]]) {
            if ([[value allKeys] containsObject:@"code"]) {
                code = [[value objectForKey:@"code"] intValue];
            } else if ([[value allKeys] containsObject:@"status"]) {
                code = [[value objectForKey:@"status"] intValue];
            } else {
                code = 500;
            }
            obj = [[FengResponseObject alloc] initWithCode:code
                                                   message:[value objectForKey:@"msg"]
                                                  errorMsg:[value objectForKey:@"error"]
                                                      data:[value objectForKey:@"data"]
                                        withOriginalString:nil];
        } else if ([value isKindOfClass:[NSString class]] && ((FengPersistenceHttpRequest *)self.handler).dataHandlerType == FengParseRequestDataHandlerOriginString) {
            obj = [[FengResponseObject alloc] initWithCode:code
                                                   message:nil
                                                  errorMsg:nil
                                                      data:nil
                                        withOriginalString:value];
        } else {
            code = 500;
        }
        
        if (code == 0) {
            [self callBackLogs:FengRequestLogTypeSuccess data:obj.data];
            [subscriber sendNext:obj];
            [subscriber sendCompleted];
        } else if (code == 10401
                   || code == 10402
                   || code == 10403
                   || code == 10404
                   || code == 10405
                   || code == 60010
                   || code == 100201) {
            [self callBackLogs:FengRequestLogTypeAuthenticationFail data:value];
            [subscriber sendNext:[NSError errorWithDomain:@"登录失效" code:code userInfo:nil]];
           
        } else {
            [self callBackLogs:FengRequestLogTypeError data:value];
            NSError *error = [NSError errorWithDomain:obj.message.length ? obj.message : obj.errorMsg?:@"服务器出错" code:code userInfo:obj.data?@{errorDataKey:obj.data}:nil];
            [self handleError:error] ? [subscriber sendNext:error] : [subscriber sendCompleted];
        }
        return nil;
    }
}

- (id<FengRequestHandler>)getHandler {
    return [FengPersistenceHttpRequest new];
}
- (NSString *)getHost {
    return ((FengPersistenceHttpRequest *)self.handler).baseUrl;
}

- (NSString *)getSubPath {
    return ((FengPersistenceHttpRequest *)self.handler).requestUrl;
}

- (instancetype)setSubPath:(NSString *)subPath {
    [((FengPersistenceHttpRequest *)self.handler) setRequestSubPath:subPath];
    return self;
}

- (instancetype)setRequestAuthorizationHeaderFieldArray:(NSArray<NSString *> *)array {
    [((FengPersistenceHttpRequest *)self.handler) setRequestAuthorizationHeaderFieldArray:array];
    return self;
}

- (instancetype)setDataHandle:(FengParseRequestDataHandlerType)dataHandle {
    [((FengPersistenceHttpRequest *)self.handler) setDataHandle:dataHandle];
    return self;
}

- (instancetype)setRequestBaseUrl:(NSString *)requestBaseUrl {
    [((FengPersistenceHttpRequest *)self.handler) setRequestBaseUrl:requestBaseUrl];
    return self;
}

- (instancetype)setTempToken:(NSString *)tempToken {
    [((FengPersistenceHttpRequest *)self.handler) setTempToken:tempToken];
    return self;
}

- (instancetype)setSpecialStaticHeaderParams:(NSDictionary *)params {
    [((FengPersistenceHttpRequest *)self.handler) setStaticHeaderParamater:params];
    return self;
}

- (instancetype)addRequestHeaderParamters:(NSDictionary *)paramters {
    [((FengPersistenceHttpRequest *)self.handler) addRequestHeaderParamters:paramters];
    return self;
}

- (NSDictionary *)staticHeaderParams {
    return ((FengPersistenceHttpRequest *)self.handler).requestHeaderFieldValueDictionary;
}

- (NSDictionary *)staticPramters {
    return ((FengPersistenceHttpRequest *)self.handler).requestArgument;
}

- (BOOL)handleError:(NSError *)error {
    [error setValue:@(FengRequestErrorService) forKey:@"code"];
    return YES;
}

- (void)callBackLogs:(FengRequestLogType)logType data:(nullable id)data {
    
}

- (void)handleParamtersSign {
    
    NSMutableDictionary *paramters = @{}.mutableCopy;
    if ([self.params isKindOfClass:[NSDictionary class]]) {
        [paramters addEntriesFromDictionary:self.params];
        _params = paramters;
    }
   
    [self addRequestHeaderParamters:@{
                                      @"Content-Type":@"application/json"

                                      }];
    
}

/** 获取签名 */
+ (NSDictionary *)getRequestSignWithParamters:(NSDictionary *)paramters
                                        token:(NSString *)token {
    NSString *timeStamp = [NSString stringWithFormat:@"%ld",(long)[NSDate date].timeIntervalSince1970 * 1000];
    NSString *parametersStr = [self dictionaryToJson:paramters];
    
    return @{
        @"token" : token,
        @"timestamp" : timeStamp,
        @"fsf": parametersStr
    };
}


+ (NSString *)dictionaryToJson:(NSDictionary *)dic {
    if (!dic ||([dic isKindOfClass:[NSDictionary class]] && [[dic allKeys] count] == 0) || ([dic isKindOfClass:[NSArray class]] && [dic count] == 0) ) {
        return @"";
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:(NSJSONWritingOptions)0 error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
