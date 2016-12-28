//
//  ACNetWork.h
//  PeopleCounter
//
//  Created by Air_chen on 2016/12/28.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalHeader.h"

typedef void (^resultBlock)(RACTuple *resData);

@interface ACNetWorkManager : NSObject
+ (instancetype)shareManager;

- (void)getUrlStr:(NSString *)urlStr thatResult:(resultBlock)resData;

- (void)postMsgStr:(NSString *)msgStr thatResult:(resultBlock)resData;
- (void)getPicUuidStr:(NSString *)uuidStr thatResult:(resultBlock)resData;
- (void)youdaoTranslaterStr:(NSString *)contentStr thatResult:(resultBlock)resData;
@end
