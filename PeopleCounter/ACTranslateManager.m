//
//  ACTranslateManager.m
//  PeopleCounter
//
//  Created by Air_chen on 2017/1/9.
//  Copyright © 2017年 Air_chen. All rights reserved.
//

#import "ACTranslateManager.h"
#import "ACNetWorkManager.h"
#import "GlobalHeader.h"

@implementation ACTranslateManager

static ACTranslateManager *instance = nil;
+ (instancetype)shareManager
{
    if (instance == nil) {
        instance = [[ACTranslateManager alloc] init];
    }
    return instance;
}

- (BOOL)isChineseInString:(NSString *) orgStr
{
//    NSUInteger hanCount = 0;
//    NSUInteger yinCount = 0;
    
    for (NSUInteger i = 0; i < orgStr.length; i++) {
        unichar c = [orgStr characterAtIndex:i];
        if (c >=0x4E00 && c <=0x9FFF)
        {
            return YES;
//            hanCount ++;
        }
        else
        {
//            yinCount ++;
        }
    }

    return NO;
}

- (void)translateWithOrgString:(NSString *) orgStr withResult:(translateBlock) resStr
{
    [[ACNetWorkManager shareManager] youdaoTranslaterStr:orgStr thatResult:^(RACTuple *resData) {
        RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = resData;
        
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //                        状态码
        NSLog(@"%ld",(long)response.statusCode);
        
        NSLog(@"%@",content);
        
        NSDictionary *initDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSString *transStr = initDic[@"translation"][0];
        
        resStr(transStr);
    }];
}

@end
