//
//  ACPhotoViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/8/21.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACPhotoViewController.h"

@interface ACPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readwrite, strong) UIImageView *imgView;

@end

@implementation ACPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.imgView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    [self.imgView setContentMode:UIViewContentModeScaleAspectFit];
    
    self.imgView.image = self.img;
    
    [self.scrollView addSubview:self.imgView];
    self.scrollView.delegate =self;
    
    CGFloat imgWid = self.img.size.width;
    CGFloat imgHei = self.img.size.height;
    CGFloat actrueWid = [UIScreen mainScreen].bounds.size.width;
    
    self.scrollView.contentSize = CGSizeMake(actrueWid,imgHei * actrueWid/imgWid);
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.minimumZoomScale = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgView;
}

@end
