//
//  ACTranslateManager.h
//  PeopleCounter
//
//  Created by Air_chen on 2017/1/9.
//  Copyright © 2017年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^translateBlock)(NSString *resStr);

/**
 `ACTranslateManager` 翻译管理类
 */
@interface ACTranslateManager : NSObject
/**
 单例创建方法
 */
+ (instancetype)shareManager;

/**
 检查字符串中是否包含中文
 
 @param orgStr 待检测的字符串

 */
- (BOOL)isChineseInString:(NSString *)orgStr;
/**
 翻译
 
 @param orgStr 待翻译的字符串
 @param resStr 翻译结果
 
 */
- (void)translateWithOrgString:(NSString *)orgStr withResult:(translateBlock)resStr;

@end
