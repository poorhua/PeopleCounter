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
    
    self.imgView = [[UIImageView alloc] initWithImage:self.img];
    [self.imgView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.scrollView addSubview:self.imgView];
    self.scrollView.delegate =self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGFloat imgWid = self.img.size.width;
    CGFloat imgHei = self.img.size.height;
    CGFloat actrueWid = [UIScreen mainScreen].bounds.size.width;
    
    self.scrollView.contentSize = CGSizeMake(actrueWid,imgHei * actrueWid/imgWid);
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.minimumZoomScale = 1;
    
    self.imgView.frame = CGRectMake(0,(self.imgView.bounds.size.height - self.scrollView.bounds.size.height+64)/2.0, actrueWid,imgHei * actrueWid/imgWid);
    [self rectangleImgView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIScrollViewDelegate
- (void)rectangleImgView
{
    CGSize scrollSize = self.scrollView.bounds.size;
    CGSize imgSize = self.imgView.bounds.size;
    CGFloat verticleSpace = scrollSize.height > imgSize.height ? (scrollSize.height - imgSize.height)/2.0 : 0.0;
    CGFloat horizenSpace = scrollSize.width > imgSize.width ? (scrollSize.width - imgSize.width)/2.0 : 0.0;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, horizenSpace, verticleSpace, horizenSpace);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self rectangleImgView];
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgView;
}

@end
