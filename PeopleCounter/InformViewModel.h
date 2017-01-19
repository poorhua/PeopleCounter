//
//  InformViewModel.h
//  PeopleCounter
//
//  Created by Air_chen on 16/6/29.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GlobalHeader.h"

/**
 `InformViewModel` 通知发送试图的Viewmodel
 */
@interface InformViewModel : NSObject
@property (nonatomic, readwrite, strong, nonnull) RACCommand *informCommand;
@property (nonatomic, readwrite, weak) UIViewController *viewController;

@property (weak, nonatomic) UITextField *nameTextField;
@property (weak, nonatomic) UITextView *detailTextView;
@property (weak, nonatomic) UIButton *sendBtn;
@property (weak, nonatomic) NSLayoutConstraint *heightContraint;

@end
