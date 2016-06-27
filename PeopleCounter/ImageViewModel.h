//
//  ImageViewModel.h
//  PeopleCounter
//
//  Created by Air_chen on 16/6/21.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalHeader.h"
#import <UIKit/UIKit.h>

@interface ImageViewModel : NSObject

@property(nonatomic,strong) RACCommand *imageLoadCommand;
@property(nonatomic,strong) NSString *uuid;
@property(nonatomic,strong) UIImageView *imageView;
@property(null_resettable, nonatomic,strong) UIView *view;

@end
