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
@property(nonatomic,assign) CGFloat lastScale;
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
        
//        添加捏合手势
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pichEvents:)];
        self.imageView.userInteractionEnabled = YES;
        self.imageView.multipleTouchEnabled = YES;
        _lastScale = 1.0;
        [self.imageView addGestureRecognizer:pinchGesture];
        
        RACSignal *requestSig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           
            NSMutableURLRequest *request = [self makeUpURLConnection];
            
            [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
                RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = x;
                
                //NSInteger statusCode = response.statusCode;
                
                UIImage *image = [UIImage imageWithData:data];
                
                _image = image;
                
                [subscriber sendNext:image];
                [subscriber sendCompleted];
            }];
            
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
            self.imageView.image = [self transImage:_image];
            
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

-(void)pichEvents:(UIPinchGestureRecognizer *)gesture
{
    CGFloat scale = gesture.scale;
    
    NSLog(@"%f",scale);

//    UIGraphicsBeginImageContext(_imageView.bounds.size);
//    
//    [_imageView.image drawInRect:_imageView.bounds];
//    
//    CGContextRef cxt = UIGraphicsGetCurrentContext();
//    
//    CGContextScaleCTM(cxt,0.001,0.001);
//    
//    _imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();

    if(gesture.state == UIGestureRecognizerStateEnded) {
        _lastScale = 1.0;
        return;
    }
    
    CGFloat cscale = 1.0 - (_lastScale - scale);
    _imageView.transform = CGAffineTransformScale(_imageView.transform, cscale, cscale);
    
//    _imageView.layer.transform = CATransform3DMakeScale(cscale, cscale, 0);
    _lastScale = scale;
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

@end
