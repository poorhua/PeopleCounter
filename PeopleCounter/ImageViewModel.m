//
//  ImageViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/21.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ImageViewModel.h"
#import "UIImage+Bitmap.h"
#import "ACNetWorkManager.h"

@interface ImageViewModel()

@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) UIImageView *imgView;
//@property(nonatomic,assign) CGFloat lastScale;
@end

@implementation ImageViewModel
CGFloat currentScale;

-(instancetype)init
{
    if (self = [super init]) {
        [self bindEvents];
    }
    
    return self;
}

-(void)bindEvents
{
    self.imageLoadCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *requestSig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            filePath = [filePath stringByAppendingPathComponent:self.uuid];
            
            NSData *imgData = [NSData dataWithContentsOfFile:filePath];
            if (imgData == nil) {
                
                [[ACNetWorkManager shareManager] getPicUuidStr:self.uuid thatResult:^(RACTuple *resData) {
                    RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = resData;
                    
                    [data writeToFile:filePath atomically:YES];
                    
                    self.image = [UIImage imageWithData:data];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        self.imgView.image = self.image;
                        [subscriber sendNext:self.image];
                        [subscriber sendCompleted];
                    });
                }];
            }else{
                self.image = [UIImage imageWithData:imgData];
                [subscriber sendNext:self.image];
                [subscriber sendCompleted];
            }
           
//            [subscriber sendNext:_image];
//            [subscriber sendCompleted];
            
            return nil;
        }];
        
        return requestSig;
    }];
    
    [[self.imageLoadCommand.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            NSLog(@"loading!");
            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.mode = MBProgressHUDModeIndeterminate;
            hub.labelText = @"loading...";
        }else
        {
            NSLog(@"done!");
            
            //设置图片显示，Scrollview的代理
            self.imgView = [[UIImageView alloc] initWithImage:self.image];
            [self.imgView setContentMode:UIViewContentModeScaleAspectFit];
            
            [self.scrollView addSubview:self.imgView];
            self.scrollView.delegate = self;
            
            CGFloat imgWid = self.imgView.image.size.width;
            CGFloat imgHei = self.imgView.image.size.height;
            CGFloat actrueWid = [UIScreen mainScreen].bounds.size.width;
            
            self.scrollView.contentSize = CGSizeMake(actrueWid,imgHei * actrueWid/imgWid);
            self.imgView.frame = CGRectMake(0,(self.imgView.bounds.size.height - self.scrollView.bounds.size.height+64)/2.0, actrueWid,imgHei * actrueWid/imgWid);
            
            self.scrollView.maximumZoomScale = 2.0;
            self.scrollView.minimumZoomScale = 1;
            
            [self rectangleImgView];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (UIImage *)transImage:(UIImage *)image//图片转换成小图
{
    //CGSize origImageSize = image.size;
    CGRect newRect = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,image.size.height * ([UIScreen mainScreen].bounds.size.width / image.size.width));
    
    //    得到的图片尺寸
    
    //float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);//根据当前设备屏幕的scaling factor创建透明的位图上下文
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:8.0];
    
    [path addClip];
    CGRect projectRect;
    projectRect.size = newRect.size;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [image drawInRect:projectRect];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    return smallImage;
}

#pragma mark - UIScrollViewDelegate

- (void)rectangleImgView
{
    CGSize scrollSize = self.scrollView.bounds.size;
    CGSize imgSize = self.imgView.bounds.size;
    CGFloat verticleSpace = scrollSize.height > imgSize.height ? (scrollSize.height - imgSize.height)/2.0 : 0.0;
    CGFloat horizenSpace = scrollSize.width > imgSize.width ? (scrollSize.width - imgSize.width)/2.0 : 0.0;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, horizenSpace, 0, horizenSpace);
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self rectangleImgView];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgView;
}

@end
