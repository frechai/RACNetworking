//
//  FengPersistenceHttpRequest+FengBaseRequest.h
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//



#import "FengPersistenceHttpRequest.h"
#import "FengBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN
@interface FengMultipartForDataForYTKNetwork : NSObject <FengMultipartFormData>

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *datas;

@end

@interface FengPersistenceHttpRequest (FengBaseRequest)<FengRequestHandler,FengCancellable,YTKRequestAccessory>

@end

NS_ASSUME_NONNULL_END
