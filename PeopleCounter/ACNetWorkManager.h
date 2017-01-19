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

/**
 `ACNetWorkManager` 专门负责网络请求的单例
 */
@interface ACNetWorkManager : NSObject
/**
 创建单例
 */
+ (instancetype)shareManager;

///---------------------
/// @name 调用的接口
///---------------------
/**
 代URL的get请求，获取图片列表，和温湿度信息列表
 
 @param urlStr 请求的链接
 @param resData 返回结果的块

 */
- (void)getWithUrlStr:(NSString *)urlStr thatResult:(resultBlock)resData;

/**
 发送post请求，上传通知内容
 
 @param msgStr 通知内容
 @param resData 返回结果的块
 
 */
- (void)postWithMsgStr:(NSString *)msgStr thatResult:(resultBlock)resData;
/**
 获取图片
 
 @param uuidStr 图片的UUID标示
 @param resData 返回结果的块

 */
- (void)getPicWithUuidStr:(NSString *)uuidStr thatResult:(resultBlock)resData;
/**
 调用有道翻译接口
 
 @param contentStr 等待翻译的字符串
 @param resData 返回结果的块
 */
- (void)youdaoTranslaterWithStr:(NSString *)contentStr thatResult:(resultBlock)resData;
@end
