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

@interface ImageViewModel : NSObject<UIScrollViewDelegate>

@property (nonatomic, readwrite, strong, nonnull) RACCommand *imageLoadCommand;
@property (nonatomic, readwrite, copy, nonnull) NSString *uuid;
@property (nonatomic, readwrite, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite, weak) UIView *view;

@end
