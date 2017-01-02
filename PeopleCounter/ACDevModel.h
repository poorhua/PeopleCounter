//
//  ACDevModel.h
//  PeopleCounter
//
//  Created by Air_chen on 2017/1/1.
//  Copyright © 2017年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACDevPointModel : NSObject

@property (nonatomic, readwrite, copy) NSString *at;
@property (nonatomic, readwrite, copy) NSString *value;

@end

@interface ACDevStreamModel : NSObject

@property (nonatomic, readwrite, assign) NSInteger ID;//id
@property (nonatomic, readwrite, copy) NSArray<ACDevPointModel *> *datapoints;

@end

@interface ACDevDataModel : NSObject

@property (nonatomic, readwrite, assign) NSInteger count;
@property (nonatomic, readwrite, copy) NSArray<ACDevStreamModel *> *datastreams;

@end

@interface ACDevModel : NSObject

@property (nonatomic, readwrite, assign) NSInteger errNO;//errno
@property (nonatomic, readwrite, copy) NSString *error;
@property (nonatomic, readwrite, strong) ACDevDataModel *data;

+ (instancetype)setUpDevModelFromDic:(NSDictionary *)dic;

@end
