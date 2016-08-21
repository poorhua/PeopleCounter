//
//  ImageViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/21.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ImageViewModel.h"
#import "UIImage+Bitmap.h"

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
    _imageLoadCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *requestSig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            filePath = [filePath stringByAppendingPathComponent:self.uuid];
            
            NSData *imgData = [NSData dataWithContentsOfFile:filePath];
            if (imgData == nil) {
                NSMutableURLRequest *request = [self makeUpURLConnection];
            
                [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
                    RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = x;
                    
                    //NSInteger statusCode = response.statusCode;
                    
                    [data writeToFile:filePath atomically:YES];
                    
                    _image = [UIImage imageWithData:data];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        self.imgView.image = _image;
                    });
                }];
            }else{
                _image = [UIImage imageWithData:imgData];
            }
           
            [subscriber sendNext:_image];
            [subscriber sendCompleted];
            
            return nil;
        }];
        
        return requestSig;
    }];
    
    [[_imageLoadCommand.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            NSLog(@"loading!");
            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.mode = MBProgressHUDModeIndeterminate;
            hub.labelText = @"loading...";
        }else
        {
            NSLog(@"done!");
            
            //设置图片显示，Scrollview的代理
            _imgView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
            [_imgView setContentMode:UIViewContentModeScaleAspectFit];
            
            _imgView.image = _image;
            
            [self.scrollView addSubview:_imgView];
            self.scrollView.delegate =self;
            
            CGFloat imgWid = self.imgView.image.size.width;
            CGFloat imgHei = self.imgView.image.size.height;
            CGFloat actrueWid = [UIScreen mainScreen].bounds.size.width;
            
            self.scrollView.contentSize = CGSizeMake(actrueWid,imgHei * actrueWid/imgWid);
            self.scrollView.maximumZoomScale = 2.0;
            self.scrollView.minimumZoomScale = 1;
            
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

-(NSMutableURLRequest *) makeUpURLConnection
{
    NSString *str = [NSString stringWithFormat:@"http://api.heclouds.com/bindata/%@",self.uuid];
    NSLog(@"%@",str);
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:APIKEY forHTTPHeaderField:@"api-key"];
    
    return request;
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
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imgView;
}

@end
