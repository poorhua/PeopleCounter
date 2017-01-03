//
//  ACMainViewModel.h
//  PeopleCounter
//
//  Created by Air_chen on 16/8/19.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GlobalHeader.h"

@class ACMainViewController;

@interface ACMainViewModel : NSObject

@property (nonatomic, readwrite, strong, nonnull) RACCommand *acMainCommand;

@property (nonatomic, readwrite, weak) UIButton *humanBtn;
@property (nonatomic, readwrite, weak) UIButton *tempBtn;
@property (nonatomic, readwrite, weak) UIButton *airBtn;

@property (nonatomic, readwrite, weak) UINavigationItem *navigationItem;
@property (nonatomic, readwrite, weak) UINavigationController *navigationController;
@property (nonatomic, readwrite, weak) UIView *btnView;
@property (nonatomic, readwrite, weak) UIView *comboView;

@property (nonatomic, readwrite, weak) ACMainViewController *controller;

@end
