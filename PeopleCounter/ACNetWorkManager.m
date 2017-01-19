//
//  ACNetWork.m
//  PeopleCounter
//
//  Created by Air_chen on 2016/12/28.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACNetWorkManager.h"

@implementation ACNetWorkManager

typedef NS_ENUM(NSInteger, MothodType) {
    POST = 0,//POST
    GET = 1,//GET
};

static ACNetWorkManager *instance = nil;

+ (instancetype)shareManager
{
    if (instance == nil) {
        instance = [[ACNetWorkManager alloc] init];
    }
    return instance;
}

- (void)postWithMsgStr:(NSString *)msgStr thatResult:(resultBlock)resData
{
    NSString *str = [NSString stringWithFormat:@"http://api.heclouds.com/devices/3124697/datapoints"];
    NSLog(@"%@",str);
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"%@",url);
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:now];
    NSDictionary *reqDic = @{
                             @"datastreams":@[
                                     @{
                                         @"id":@"001",
                                         @"datapoints":@[
                                                 @{
                                                     @"at":strDate,
                                                     @"value":msgStr
                                                     }
                                                 ]
                                         }
                                     ]
                             };
    NSData *reqData = [NSJSONSerialization dataWithJSONObject:reqDic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *content = [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",content);
    
    NSDictionary *dic = @{ @"api-key":apiKey };
    
    [self postWithUrl:url withValue:dic withHttpBody:reqData result:resData];
}

- (void)getPicWithUuidStr:(NSString *)uuidStr thatResult:(resultBlock)resData
{
    NSString *str = [NSString stringWithFormat:@"http://api.heclouds.com/bindata/%@",uuidStr];
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:str];
    
    NSDictionary *dic = @{ @"api-key":apiKey };
    
    [self getWithUrl:url withValue:dic result:resData];
}

- (void)getWithUrlStr:(NSString *)urlStr thatResult:(resultBlock)resData
{
#ifdef TRUEDATE
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    //    加上100，然后转化为字符串，取后两位，可以保证以0x的形式出现
    NSRange range;
    range.location = 1;
    range.length = 2;
    
    NSInteger year = [dateComponent year];
    NSString *month = [[NSString stringWithFormat:@"%ld",(long)([dateComponent month]+100)] substringWithRange:range];
    NSString *day = [[NSString stringWithFormat:@"%ld",(long)([dateComponent day]+100)]substringWithRange:range];
    NSString *hour1 = [[NSString stringWithFormat:@"%ld",(long)([dateComponent hour]+100)] substringWithRange:range];
    NSString *hour2 = [[NSString stringWithFormat:@"%ld",(long)([dateComponent hour] - 1+100)] substringWithRange:range];
    NSString *minute = [[NSString stringWithFormat:@"%ld",(long)([dateComponent minute] - 1+100)] substringWithRange:range];
    NSString *second = [[NSString stringWithFormat:@"%ld",(long)([dateComponent second]+100)] substringWithRange:range];
    
    NSString *endData = [NSString stringWithFormat:@"%ld-%@-%@T%@:%@:%@",(long)year,month,day,hour1,minute,second];
    NSString *startData = [NSString stringWithFormat:@"%ld-%@-%@T%@:%@:%@",(long)year,month,day,hour2,minute,second];
#else
    NSString *endData = nil;
    NSString *startData = nil;
    
    if ([urlStr isEqualToString:uuidUrl]) {
        endData = [NSString stringWithFormat:@"2016-06-23T11:45:00"];
        startData = [NSString stringWithFormat:@"2016-06-23T11:00:00"];
    }else{
        endData = [NSString stringWithFormat:@"2016-08-07T14:20:00"];
        startData = [NSString stringWithFormat:@"2016-08-07T13:20:00"];
    }
    
#endif
    
    NSString *str = [NSString stringWithFormat:@"%@? datastream_id=001 2&start=%@&end=%@",urlStr,startData,endData];
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:str];

    NSDictionary *dic = @{ @"api-key":apiKey };
    
    [self getWithUrl:url withValue:dic result:resData];
}

- (void)youdaoTranslaterWithStr:(NSString *)contentStr thatResult:(resultBlock)resData
{
    NSString *str = [NSString stringWithFormat:@"http://fanyi.youdao.com/openapi.do?keyfrom=RaspiTranslater&key=31594945&type=data&doctype=json&version=1.1&q=%@",contentStr];
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:str];
    
    [self getWithUrl:url withValue:[NSDictionary dictionary] result:resData];
}

#pragma mark - 核心方法
- (void)postWithUrl:(NSURL *)aUrl withValue:(NSDictionary *)aDic withHttpBody:(NSData *)aData result:(resultBlock)resData {
    [self requestUrl:aUrl type:POST withValue:aDic withHttpBody:aData result:resData];
}

- (void)getWithUrl:(NSURL *)aUrl withValue:(NSDictionary *)aDic result:(resultBlock)resData {
    [self requestUrl:aUrl type:GET withValue:aDic withHttpBody:[NSData data] result:resData];
}

- (void)requestUrl:(NSURL *)aUrl
              type:(MothodType)type
         withValue:(NSDictionary *)aDic
     withHttpBody:(NSData *)aData
           result:(resultBlock)resData{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    if (type == POST) {
        [request setHTTPMethod:@"POST"];
        if ([aDic count] != 0) {
            [request setValue:aDic[aDic.allKeys[0]] forHTTPHeaderField:aDic.allKeys[0]];
        }
        [request setHTTPBody:aData];
    }else{
        [request setHTTPMethod:@"GET"];
        if ([aDic count] != 0) {
            [request setValue:aDic[aDic.allKeys[0]] forHTTPHeaderField:aDic.allKeys[0]];
        }
    }
    
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        resData(x);
    }];
}

@end
