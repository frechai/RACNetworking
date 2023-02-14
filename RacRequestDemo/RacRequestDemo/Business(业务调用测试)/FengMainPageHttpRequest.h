//
//  FengMainPageHttpRequest.h
//  RacRequestDemo
//
//  Created by frechai on 2021/7/2.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "FengBaseHttpRequest.h"

NS_ASSUME_NONNULL_BEGIN
@interface FengMainModel : NSObject

@property (nonatomic,copy) NSString *string1;

@property (nonatomic,copy) NSString *string2;

@property (nonatomic,copy) NSString *string3;
@end
@interface FengMainPageHttpRequest : FengBaseHttpRequest
+ (RACSignal *)requestMainPage:(int)page paramString:(NSString *)paramString;

+ (RACSignal <FengMainModel *>*)requestMainPage2:(int)page paramString:(NSString *)paramString;

@end

NS_ASSUME_NONNULL_END
