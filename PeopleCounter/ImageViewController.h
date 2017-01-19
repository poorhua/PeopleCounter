//
//  ImageViewController.h
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalHeader.h"

/**
 `ImageViewController` 图片加载的视图控制器，下载图片
 */
@interface ImageViewController : UIViewController

/**
 所获取的图片
 
 @param str 图片的uuid
 
 */
- (void)setUuid:(NSString *)str;

@end
