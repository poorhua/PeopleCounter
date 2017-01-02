//
//  ACDevModel.m
//  PeopleCounter
//
//  Created by Air_chen on 2017/1/1.
//  Copyright © 2017年 Air_chen. All rights reserved.
//

#import "ACDevModel.h"
#import "GlobalHeader.h"

@implementation ACDevPointModel

//value有可能为字典
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property
{
    if ([property.name isEqualToString:@"value"] && [property.type.code isEqualToString:@"NSDictionary"]) {
        NSDictionary *dic = oldValue;
        return dic[@"index"];
    }
    return oldValue;
}

@end

@implementation ACDevStreamModel
@end

@implementation ACDevDataModel
@end

@implementation ACDevModel

+ (instancetype)setUpDevModelFromDic:(NSDictionary *)dic
{
    [ACDevStreamModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"datapoints" : @"ACDevPointModel",
                 };
    }];
    
    [ACDevDataModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"datastreams" : @"ACDevStreamModel",
                 };
    }];
    
    [ACDevModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"errNO" : @"errno",
                 };
    }];
    
    [ACDevStreamModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"ID" : @"id",
                 };
    }];
    
    return [ACDevModel mj_objectWithKeyValues:dic];
}

@end
