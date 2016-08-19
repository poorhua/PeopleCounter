//
//  ImageViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ImageViewController.h"
#import "ImageViewModel.h"

@interface ImageViewController()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) ImageViewModel *imageVM;
@end

@implementation ImageViewController

-(ImageViewModel *)imageVM
{
    if (_imageVM == nil) {
        _imageVM = [[ImageViewModel alloc] init];
    }
    
    return _imageVM;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageVM.scrollView = self.scrollView;
    self.imageVM.view = self.view;
    
     RACSignal *sig = [self.imageVM.imageLoadCommand execute:nil];
    
    [sig subscribeNext:^(UIImage* x) {
//        self.imgView.image = x;
    }];
}

-(void)setUuid:(NSString *)str
{
    self.imageVM.uuid = str;
}

@end
