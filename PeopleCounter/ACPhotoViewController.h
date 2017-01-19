//
//  ACPhotoViewController.h
//  PeopleCounter
//
//  Created by Air_chen on 16/8/21.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 `ACPhotoViewController` 图片浏览
 */
@interface ACPhotoViewController : UIViewController<UIScrollViewDelegate>

/**
 要浏览的image
 */
@property (nonatomic, readwrite, strong) UIImage *img;

@end
