//
//  ACTranslateManager.h
//  PeopleCounter
//
//  Created by Air_chen on 2017/1/9.
//  Copyright © 2017年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^translateBlock)(NSString *resStr);

@interface ACTranslateManager : NSObject

+ (instancetype)shareManager;

- (BOOL)isChineseInString:(NSString *) orgStr;
- (void)translateWithOrgString:(NSString *) orgStr withResult:(translateBlock) resStr;

@end
