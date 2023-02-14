//
//  FengMainPageHttpRequest.m
//  RacRequestDemo
//
//  Created by frechai on 2021/7/2.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "FengMainPageHttpRequest.h"
@implementation FengMainModel

@end
@implementation FengMainPageHttpRequest
+ (RACSignal *)requestMainPage:(int)page paramString:(NSString *)paramString
{
    NSDictionary *params =@{
        @"a":@(page),
        @"b":paramString
    };
    
   
   return  [[[FengBaseHttpRequest POST:@"qqq/wwwww/rrrr.do" params:params]
      startRequest] feng_requstMap:^id _Nullable(FengResponseObject * _Nullable value) {
        return value;
    }];
    
    
}


+ (RACSignal <FengMainModel *>*)requestMainPage2:(int)page paramString:(NSString *)paramString
{
    
    NSDictionary *params =@{
           @"a":@(page),
           @"b":paramString
       };
       
      return  [[[FengBaseHttpRequest POST:@"qqq/wwwww/rrrr.do" params:params]
         startRequest] feng_requstMap:^id _Nullable(FengResponseObject * _Nullable value) {
         //模拟数据
          FengMainModel *mainModel =[[FengMainModel alloc] init];
          mainModel.string1 =@"1";
           mainModel.string2 =@"1";
           mainModel.string3 =@"1";
          
          return mainModel;
       }];
    
    
    
}
@end
