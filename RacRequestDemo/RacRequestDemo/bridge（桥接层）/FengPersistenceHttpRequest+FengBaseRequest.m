//
//  FengPersistenceHttpRequest+FengBaseRequest.m
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "FengPersistenceHttpRequest+FengBaseRequest.h"
#import "FengMacro.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <ReactiveObjC/ReactiveObjC.h>

static NSString * FengUploadKey= @"FengUploadKey";
static NSString * FengUploadData= @"FengUploadData";
static NSString * FengUploadFileName= @"FengUploadFileName";
static NSString * FengUploadContentType= @"FengUploadContentType";

@implementation FengMultipartForDataForYTKNetwork

+ (NSDictionary *)buildUploadData:(id)data
                     withFileName:(NSString *)fileName
                   andContentType:(NSString *)contentType
                           forKey:(NSString *)key
{
    NSAssert(data, @"UploadData don`t be nil");
    NSAssert(key, @"UploadKey don`t be nil");
    
    if (!contentType) {
        contentType = @"application/octet-stream";
    }
    
    return @{FengUploadData:data,
             FengUploadFileName:fileName? :@"file",
             FengUploadContentType:contentType,
             FengUploadKey:key};
}

- (void)appendData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    NSDictionary *dict = [FengMultipartForDataForYTKNetwork buildUploadData:data withFileName:name andContentType:fileName forKey:mimeType];
    [self.datas addObject:dict];
}

- (NSMutableArray<NSDictionary *> *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

@end

@implementation FengPersistenceHttpRequest (FengBaseRequest)
- (id<FengCancellable>)requestWithType:(FengRequestType)type
                                 url:(NSString *)url
                          parameters:(id)parameters
                               start:(void (^)(id<FengCancellable> task))start
                            progress:(void (^)(NSProgress *))progress
                             success:(void (^)(id<FengCancellable>, id))success
                             failure:(void (^)(id<FengCancellable>, NSError *))failure {
    
    [self setRequestMethod:[self changeMethod:type]];
    [self setReqParame:parameters];
    
    FengWeakify(self);
    [[self rac_signalForSelector:@selector(requestWillStart:)
                    fromProtocol:@protocol(YTKRequestAccessory)]
     subscribeNext:^(RACTuple * _Nullable x) {
        FengStrongify(self);
        if (start) {
            start(self);
        }
    }];

    [self addAccessory:self];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        FengStrongify(self);
        if (success && self) {
            success((FengPersistenceHttpRequest *)request,self.dataHandlerType == FengParseRequestDataHandlerOriginString?request.responseString : request.responseObject);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (failure) {
            failure((FengPersistenceHttpRequest*)request, request.error);
        }
    }];
    
    return self;
}

- (id<FengCancellable>)uploadFileWithType:(FengRequestType)type
                                    url:(NSString *)url
                             parameters:(NSDictionary *)parameters
                  constructingBodyBlock:(void (^)(id<FengMultipartFormData>))constructingBodyBlock
                                  start:(void (^)(id<FengCancellable> task))start
                               progress:(void (^)(NSProgress *))progress
                                success:(void (^)(id<FengCancellable>, id))success
                                failure:(void (^)(id<FengCancellable>, NSError *))failure {
    FengMultipartForDataForYTKNetwork *uploadData = [FengMultipartForDataForYTKNetwork new];
    if (constructingBodyBlock) {
        constructingBodyBlock(uploadData);
        self.constructingBodyBlock = ^(id<AFMultipartFormData>  _Nonnull formData) {
            [uploadData.datas enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [formData appendPartWithFileData:obj[FengUploadData]
                                            name:obj[FengUploadKey]
                                        fileName:obj[FengUploadFileName]
                                        mimeType:obj[FengUploadContentType]];
            }];
        };
    }
    
    [self setRequestMethod:[self changeMethod:type]];
    [self setReqParame:parameters];
    
    FengWeakify(self);
    [[self rac_signalForSelector:@selector(requestWillStart:)
                    fromProtocol:@protocol(YTKRequestAccessory)]
     subscribeNext:^(RACTuple * _Nullable x) {
        FengStrongify(self);
        if (start) {
            start(self);
        }
    }];
    
    [self addAccessory:self];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        FengStrongify(self);
        if (success) {
            success((FengPersistenceHttpRequest *)request, self.dataHandlerType == FengParseRequestDataHandlerOriginString?request.responseString : request.responseObject);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (failure) {
            failure((FengPersistenceHttpRequest*)request, request.error);
        }
    }];
    
    return self;
}

- (YTKRequestMethod)changeMethod:(FengRequestType)type {
    switch (type) {
        case FengRequestTypeGET:return YTKRequestMethodGET;
        case FengRequestTypePUT:return YTKRequestMethodPUT;
        case FengRequestTypeDELETE:return YTKRequestMethodDELETE;
        case FengRequestTypePOST:return YTKRequestMethodPOST;
    }
    return 0;
}

- (void)feng_cancel {
   [self.requestAccessories removeAllObjects];
    [self stop];
}

@end
