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

@interface ACMainViewModel : NSObject

@property(nonatomic,strong,nonnull) RACCommand *acMainCommand;

@property (weak, nonatomic) UIButton *humanBtn;
@property (weak, nonatomic) UIButton *tempBtn;
@property (weak, nonatomic) UIButton *airBtn;

@property(nonatomic,weak) UINavigationItem *navigationItem;
@property(nonatomic,weak) UINavigationController *navigationController;
@property (weak, nonatomic) UIView *btnView;
@property (weak, nonatomic) UIView *comboView;

@end
