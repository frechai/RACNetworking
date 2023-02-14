//
//  ViewController.m
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#import "ViewController.h"
#import "FengMainPageHttpRequest.h"
#import "FengMacro.h"
@interface ViewController ()
@property(nonatomic,strong)RACCommand *request;

@property(nonatomic,strong)RACCommand *request1;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    
   
    
    self.request = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
         
             return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                 
                 FengWeakify(self);
                 return [[FengMainPageHttpRequest requestMainPage:1 paramString:@"123456"]
                    subscribeNext:^(id  _Nullable x) {
                     FengStrongify(self);
                                         
                    [subscriber sendNext:x];
                    [subscriber sendCompleted];
                    } error:^(NSError * _Nullable error) {
                     
//                        [subscriber sendNext:error];
//                        [subscriber sendCompleted];
                        [subscriber sendError:error];
                                               
                        
                    }
                         ];
                 
             }];
         }];
    [[self.request execute:nil] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@====订阅数据",x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"错误");
    }];
    
    
    
     self.request1 = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
             
                 return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                     
                     FengWeakify(self);
                     return [[FengMainPageHttpRequest requestMainPage2:1 paramString:@"123456"]
                        subscribeNext:^(FengMainModel  *x) {
                         FengStrongify(self);
                                             
                        [subscriber sendNext:x];
                        [subscriber sendCompleted];
                        } error:^(NSError * _Nullable error) {
                         
    //                        [subscriber sendNext:error];
    //                        [subscriber sendCompleted];
                            [subscriber sendError:error];
                                                   
                            
                        }
                             ];
                     
                 }];
             }];
        [[self.request1 execute:nil] subscribeNext:^(id  _Nullable x) {
            NSLog(@"%@====订阅数据",x);
        } error:^(NSError * _Nullable error) {
            NSLog(@"错误");
        }];
        
    
    
    
    
    
    
    
    
    
    
}


@end
